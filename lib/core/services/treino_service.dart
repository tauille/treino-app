import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/treino_model.dart';
import '../../models/api_response_model.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class TreinoService {
  static final StorageService _storage = StorageService();
  
  // CACHE SIMPLIFICADO - APENAS LISTA PRINCIPAL
  static List<TreinoModel>? _cachedTreinos;
  static DateTime? _lastFetch;
  static const int _cacheExpireMinutes = 5;

  /// Headers padrão para requisições
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      ...ApiConstants.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// LISTAR TREINOS - CACHE SIMPLES
  static Future<ApiResponse<List<TreinoModel>>> listarTreinos({
    String? busca,
    String? dificuldade,
    String? tipoTreino,
    String? orderBy,
    String? orderDirection,
    int? perPage,
    bool forceRefresh = false,
  }) async {
    try {
      print('🔍 LISTAR TREINOS - forceRefresh: $forceRefresh');
      
      // INVALIDAR CACHE SE NECESSÁRIO
      final cacheExpired = _lastFetch == null || 
          DateTime.now().difference(_lastFetch!).inMinutes > _cacheExpireMinutes;
      
      if (forceRefresh || cacheExpired) {
        print('🗑️ Cache expirado ou forçado - buscando da API');
        _invalidateCache();
      }

      // USAR CACHE SE DISPONÍVEL (apenas para consultas sem filtros)
      if (_cachedTreinos != null && !forceRefresh && 
          busca == null && dificuldade == null && tipoTreino == null) {
        print('📦 Retornando ${_cachedTreinos!.length} treinos do cache');
        return ApiResponse<List<TreinoModel>>(
          success: true,
          data: _cachedTreinos!,
          message: 'Treinos do cache',
        );
      }

      // CONSTRUIR URL COM PARÂMETROS
      final queryParams = <String, String>{};
      if (busca != null && busca.isNotEmpty) queryParams['busca'] = busca;
      if (dificuldade != null && dificuldade.isNotEmpty) queryParams['dificuldade'] = dificuldade;
      if (tipoTreino != null && tipoTreino.isNotEmpty) queryParams['tipo_treino'] = tipoTreino;
      if (orderBy != null && orderBy.isNotEmpty) queryParams['order_by'] = orderBy;
      if (orderDirection != null && orderDirection.isNotEmpty) queryParams['order_direction'] = orderDirection;
      if (perPage != null) queryParams['per_page'] = perPage.toString();

      final baseUrl = await ApiConstants.getUrl(ApiConstants.treinos);
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');
      
      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // PROCESSAR DADOS PAGINADOS OU LISTA SIMPLES
          List<TreinoModel> treinos = [];
          final data = apiResponse.data;

          if (data is Map<String, dynamic> && data.containsKey('data')) {
            // Resposta paginada do Laravel
            final List<dynamic> treinosJson = data['data'];
            treinos = treinosJson.map((json) => TreinoModel.fromJson(json)).toList();
          } else if (data is List) {
            // Lista simples
            treinos = data.map((json) => TreinoModel.fromJson(json)).toList();
          }

          print('✅ Carregados ${treinos.length} treinos da API');

          // ATUALIZAR CACHE (apenas se não tiver filtros)
          if (busca == null && dificuldade == null && tipoTreino == null) {
            _cachedTreinos = treinos;
            _lastFetch = DateTime.now();
            print('💾 Cache atualizado com ${treinos.length} treinos');
          }

          return ApiResponse<List<TreinoModel>>(
            success: true,
            data: treinos,
            message: apiResponse.message ?? 'Treinos carregados',
          );
        }
      }

      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao listar treinos: $e');
      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// BUSCAR TREINO ESPECÍFICO
  static Future<ApiResponse<TreinoModel>> buscarTreino(int id) async {
    try {
      print('🔍 Buscando treino ID: $id');

      final uri = Uri.parse(await ApiConstants.getTreinoUrl(id));
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success && apiResponse.data != null) {
          final treino = TreinoModel.fromJson(apiResponse.data);
          print('✅ Treino encontrado: ${treino.nomeTreino} com ${treino.exercicios.length} exercícios');
          
          return ApiResponse<TreinoModel>(
            success: true,
            data: treino,
            message: apiResponse.message ?? 'Treino carregado',
          );
        }
      }

      if (response.statusCode == ApiConstants.statusNotFound) {
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'Treino não encontrado',
        );
      }

      return ApiResponse<TreinoModel>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao buscar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// CRIAR NOVO TREINO
  static Future<ApiResponse<TreinoModel>> criarTreino(TreinoModel treino) async {
    try {
      print('➕ Criando treino: ${treino.nomeTreino}');
      
      final uri = Uri.parse(await ApiConstants.getUrl(ApiConstants.treinoStore));
      final headers = await _getHeaders();
      
      final dadosSimplificados = {
        'nome_treino': treino.nomeTreino,
        'tipo_treino': treino.tipoTreino,
        'dificuldade': treino.dificuldade ?? 'iniciante',
        if (treino.descricao != null && treino.descricao!.isNotEmpty) 
          'descricao': treino.descricao,
      };
      
      final body = json.encode(dadosSimplificados);

      print('🚀 POST $uri');

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treinoCriado = TreinoModel.fromJson(apiResponse.data);
          
          // INVALIDAR CACHE APÓS CRIAÇÃO
          _invalidateCache();
          print('🗑️ Cache invalidado após criação');
          
          // CRIAR EXERCÍCIOS SE EXISTIREM
          if (treino.exercicios.isNotEmpty) {
            print('📝 Criando ${treino.exercicios.length} exercícios...');
            await _criarExerciciosDoTreino(treinoCriado.id!, treino.exercicios);
            
            // BUSCAR TREINO COMPLETO
            final treinoCompleto = await buscarTreino(treinoCriado.id!);
            if (treinoCompleto.success) {
              return treinoCompleto;
            }
          }

          return ApiResponse<TreinoModel>(
            success: true,
            data: treinoCriado,
            message: apiResponse.message ?? 'Treino criado com sucesso',
          );
        }
      }

      if (response.statusCode == ApiConstants.statusUnprocessableEntity) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        return ApiResponse<TreinoModel>(
          success: false,
          message: errorMessages,
        );
      }

      return ApiResponse<TreinoModel>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao criar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// ATUALIZAR TREINO
  static Future<ApiResponse<TreinoModel>> atualizarTreino(TreinoModel treino) async {
    try {
      if (treino.id == null) {
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'ID do treino é obrigatório',
        );
      }

      print('📝 Atualizando treino ID: ${treino.id} - ${treino.nomeTreino}');

      final uri = Uri.parse(await ApiConstants.getTreinoUrl(treino.id!));
      final headers = await _getHeaders();
      
      final dadosAtualizacao = {
        'nome_treino': treino.nomeTreino.trim(),
        'tipo_treino': treino.tipoTreino,
        'dificuldade': treino.dificuldade ?? 'iniciante',
        'descricao': treino.descricao?.trim().isEmpty == true ? null : treino.descricao?.trim(),
      };
      
      final body = json.encode(dadosAtualizacao);

      print('🚀 PUT $uri');

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success && apiResponse.data != null) {
          final treinoAtualizado = TreinoModel.fromJson(apiResponse.data);
          
          // INVALIDAR CACHE APÓS ATUALIZAÇÃO
          _invalidateCache();
          print('🗑️ Cache invalidado após atualização');
          
          return ApiResponse<TreinoModel>(
            success: true,
            data: treinoAtualizado,
            message: apiResponse.message ?? 'Treino atualizado',
          );
        }
      }

      if (response.statusCode == ApiConstants.statusNotFound) {
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'Treino não encontrado',
        );
      }

      if (response.statusCode == ApiConstants.statusUnprocessableEntity) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        return ApiResponse<TreinoModel>(
          success: false,
          message: errorMessages,
        );
      }

      return ApiResponse<TreinoModel>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao atualizar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// ALIAS PARA COMPATIBILIDADE
  static Future<ApiResponse<TreinoModel>> editarTreino(TreinoModel treino) async {
    return await atualizarTreino(treino);
  }

  /// DELETAR TREINO - MÉTODO PRINCIPAL
  static Future<ApiResponse<bool>> deletarTreino(int id) async {
    try {
      print('🗑️ DELETANDO TREINO ID: $id');
      
      final uri = Uri.parse(await ApiConstants.getTreinoUrl(id));
      final headers = await _getHeaders();

      print('🚀 DELETE $uri');

      final response = await http.delete(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');
      print('📡 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // CRÍTICO: INVALIDAR CACHE APÓS EXCLUSÃO
          _invalidateCache();
          print('✅ TREINO $id DELETADO - CACHE INVALIDADO');
          
          return ApiResponse<bool>(
            success: true,
            data: true,
            message: apiResponse.message ?? 'Treino excluído com sucesso',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<bool>(
            success: false,
            message: apiResponse.message ?? 'Erro ao excluir treino',
          );
        }
      }

      if (response.statusCode == ApiConstants.statusNotFound) {
        return ApiResponse<bool>(
          success: false,
          message: 'Treino não encontrado',
        );
      }

      return ApiResponse<bool>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao deletar treino: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// DUPLICAR TREINO
  static Future<ApiResponse<TreinoModel>> duplicarTreino(TreinoModel treinoOriginal) async {
    try {
      print('📋 Duplicando treino: ${treinoOriginal.nomeTreino}');
      
      final treinoCopia = TreinoModel.novo(
        nomeTreino: '${treinoOriginal.nomeTreino} (Cópia)',
        tipoTreino: treinoOriginal.tipoTreino,
        descricao: treinoOriginal.descricao,
        dificuldade: treinoOriginal.dificuldade,
        exercicios: [],
      );
      
      final resultadoTreino = await criarTreino(treinoCopia);
      
      if (resultadoTreino.success && treinoOriginal.exercicios.isNotEmpty) {
        await _criarExerciciosDoTreino(
          resultadoTreino.data!.id!,
          treinoOriginal.exercicios,
        );
        
        final treinoCompleto = await buscarTreino(resultadoTreino.data!.id!);
        if (treinoCompleto.success) {
          return treinoCompleto;
        }
      }
      
      return resultadoTreino;
    } catch (e) {
      print('❌ Erro ao duplicar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// MÉTODO AUXILIAR: CRIAR EXERCÍCIOS DO TREINO
  static Future<void> _criarExerciciosDoTreino(
    int treinoId,
    List<ExercicioModel> exercicios,
  ) async {
    try {
      for (int i = 0; i < exercicios.length; i++) {
        final exercicio = exercicios[i].copyWith(ordem: i + 1);
        final response = await criarExercicio(treinoId, exercicio);
        
        if (response.success) {
          print('✅ Exercício criado: ${exercicio.nomeExercicio}');
        } else {
          print('❌ Erro ao criar exercício: ${exercicio.nomeExercicio}');
        }
      }
    } catch (e) {
      print('❌ Erro ao criar exercícios: $e');
    }
  }

  // ========================================================================
  // MÉTODOS PARA EXERCÍCIOS
  // ========================================================================

  /// LISTAR EXERCÍCIOS DE UM TREINO
  static Future<ApiResponse<List<ExercicioModel>>> listarExercicios(int treinoId) async {
    try {
      print('📋 Listando exercícios do treino $treinoId');

      final uri = Uri.parse(await ApiConstants.getExerciciosUrl(treinoId));
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final data = apiResponse.data as Map<String, dynamic>;
          final List<dynamic> exerciciosJson = data['exercicios'];
          final exercicios = exerciciosJson.map((json) => ExercicioModel.fromJson(json)).toList();
          
          return ApiResponse<List<ExercicioModel>>(
            success: true,
            data: exercicios,
            message: apiResponse.message ?? 'Exercícios carregados',
          );
        }
      }

      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao listar exercícios: $e');
      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// CRIAR EXERCÍCIO
  static Future<ApiResponse<ExercicioModel>> criarExercicio(int treinoId, ExercicioModel exercicio) async {
    try {
      final uri = Uri.parse(await ApiConstants.getExerciciosUrl(treinoId));
      final headers = await _getHeaders();
      final body = json.encode(exercicio.toJson());

      print('🚀 POST $uri - ${exercicio.nomeExercicio}');

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final exercicioCriado = ExercicioModel.fromJson(apiResponse.data);
          
          // INVALIDAR CACHE APÓS CRIAR EXERCÍCIO
          _invalidateCache();
          print('🗑️ Cache invalidado após criar exercício');
          
          return ApiResponse<ExercicioModel>(
            success: true,
            data: exercicioCriado,
            message: apiResponse.message ?? 'Exercício criado',
          );
        }
      }

      if (response.statusCode == ApiConstants.statusUnprocessableEntity) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        return ApiResponse<ExercicioModel>(
          success: false,
          message: errorMessages,
        );
      }

      return ApiResponse<ExercicioModel>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao criar exercício: $e');
      return ApiResponse<ExercicioModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// ATUALIZAR EXERCÍCIO
  static Future<ApiResponse<ExercicioModel>> atualizarExercicio(
    int treinoId, 
    int exercicioId, 
    ExercicioModel exercicio
  ) async {
    try {
      final uri = Uri.parse(await ApiConstants.getExercicioUrl(treinoId, exercicioId));
      final headers = await _getHeaders();
      final body = json.encode(exercicio.toJson());

      print('🚀 PUT $uri - ${exercicio.nomeExercicio}');

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final exercicioAtualizado = ExercicioModel.fromJson(apiResponse.data);
          
          // INVALIDAR CACHE APÓS ATUALIZAR EXERCÍCIO
          _invalidateCache();
          print('🗑️ Cache invalidado após atualizar exercício');
          
          return ApiResponse<ExercicioModel>(
            success: true,
            data: exercicioAtualizado,
            message: apiResponse.message ?? 'Exercício atualizado',
          );
        }
      }

      return ApiResponse<ExercicioModel>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao atualizar exercício: $e');
      return ApiResponse<ExercicioModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// DELETAR EXERCÍCIO
  static Future<ApiResponse<bool>> deletarExercicio(int treinoId, int exercicioId) async {
    try {
      print('🗑️ Deletando exercício $exercicioId do treino $treinoId');
      
      final uri = Uri.parse(await ApiConstants.getExercicioUrl(treinoId, exercicioId));
      final headers = await _getHeaders();

      print('🚀 DELETE $uri');

      final response = await http.delete(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // CRÍTICO: INVALIDAR CACHE APÓS DELETAR EXERCÍCIO
          _invalidateCache();
          print('✅ Exercício $exercicioId deletado - CACHE INVALIDADO');
          
          return ApiResponse<bool>(
            success: true,
            data: true,
            message: apiResponse.message ?? 'Exercício excluído',
          );
        }
      }

      return ApiResponse<bool>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao deletar exercício: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// REORDENAR EXERCÍCIOS
  static Future<ApiResponse<bool>> reordenarExercicios(
    int treinoId,
    List<Map<String, dynamic>> exerciciosOrdenados,
  ) async {
    try { 
      final uri = Uri.parse('${await ApiConstants.getExerciciosUrl(treinoId)}/reordenar');
      final headers = await _getHeaders();
      final body = json.encode({'exercicios': exerciciosOrdenados});

      print('🚀 PUT $uri - Reordenar exercícios');

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // INVALIDAR CACHE APÓS REORDENAR
          _invalidateCache();
          print('🗑️ Cache invalidado após reordenar');
        }

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message ?? 'Exercícios reordenados',
        );
      }

      return ApiResponse<bool>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao reordenar exercícios: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  // ========================================================================
  // MÉTODOS DE CACHE E UTILIDADES
  // ========================================================================

  /// INVALIDAR CACHE - MÉTODO PRINCIPAL
  static void _invalidateCache() {
    _cachedTreinos = null;
    _lastFetch = null;
    print('🧹 CACHE INVALIDADO');
  }

  /// FORÇAR ATUALIZAÇÃO DA LISTA
  static Future<ApiResponse<List<TreinoModel>>> forcarAtualizacao() async {
    print('🔄 Forçando atualização da lista...');
    return await listarTreinos(forceRefresh: true);
  }

  /// LIMPAR CACHE MANUALMENTE
  static void limparCache() {
    _invalidateCache();
    print('🧹 Cache limpo manualmente');
  }

  /// DEBUG: MOSTRAR STATUS DO CACHE
  static void debugCache() {
    print('🔍 === DEBUG CACHE ===');
    print('Cache: ${_cachedTreinos?.length ?? 0} treinos');
    print('Last Fetch: $_lastFetch');
    if (_lastFetch != null) {
      final diff = DateTime.now().difference(_lastFetch!);
      print('Idade: ${diff.inMinutes} minutos');
    }
    print('==================');
  }

  /// ALIAS PARA COMPATIBILIDADE
  static Future<ApiResponse<bool>> removerTreino(int id) async {
    return await deletarTreino(id);
  }

  /// TESTAR CONEXÃO COM API
  static Future<bool> testarConexao() async {
    try {
      return await ApiConstants.testCurrentAPI();
    } catch (e) {
      print('❌ Erro no teste de conexão: $e');
      return false;
    }
  }

  /// LISTAR TREINOS POR DIFICULDADE
  static Future<ApiResponse<List<TreinoModel>>> listarTreinosPorDificuldade(String dificuldade) async {
    return await listarTreinos(dificuldade: dificuldade);
  }

  /// LISTAR EXERCÍCIOS POR GRUPO MUSCULAR
  static Future<ApiResponse<List<ExercicioModel>>> listarExerciciosPorGrupoMuscular(
    int treinoId, 
    String grupoMuscular
  ) async {
    try {
      final uri = Uri.parse('${await ApiConstants.getExerciciosUrl(treinoId)}/grupo/$grupoMuscular');
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📡 Status: ${response.statusCode}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final List<dynamic> exerciciosJson = apiResponse.data;
          final exercicios = exerciciosJson.map((json) => ExercicioModel.fromJson(json)).toList();
          
          return ApiResponse<List<ExercicioModel>>(
            success: true,
            data: exercicios,
            message: apiResponse.message ?? 'Exercícios carregados',
          );
        }
      }

      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      print('❌ Erro ao buscar exercícios por grupo muscular: $e');
      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }
}