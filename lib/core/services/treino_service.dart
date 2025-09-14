import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/treino_model.dart';
import '../../models/api_response_model.dart';
import '../constants/api_constants.dart';
import '../helpers/exercise_assets_helper.dart';
import 'storage_service.dart';

class TreinoService {
  static final StorageService _storage = StorageService();
  
  // CACHE SIMPLIFICADO
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

  /// PROCESSAMENTO DE IMAGENS PARA EXERCÍCIOS (APENAS ASSETS LOCAIS)
  static Future<ExercicioModel> _processExerciseImages(ExercicioModel exercicio) async {
    try {
      // 1. Tentar resolver asset local
      final assetPath = ExerciseAssetsHelper.resolveExerciseAsset(
        exercicio.nomeExercicio,
        muscleGroup: exercicio.grupoMuscular,
      );

      if (assetPath != null) {
        // Verificar se asset existe fisicamente
        final assetExists = await ExerciseAssetsHelper.assetExists(assetPath);
        if (assetExists) {
          print('Usando asset local para ${exercicio.nomeExercicio}: $assetPath');
          return exercicio.copyWith(imagemPath: assetPath);
        }
      }

      // 2. Manter como estava (sem modificação)
      return exercicio;
      
    } catch (e) {
      print('Erro ao processar imagem do exercício ${exercicio.nomeExercicio}: $e');
      return exercicio;
    }
  }

  /// PROCESSAR LISTA DE EXERCÍCIOS (com assets)
  static Future<List<ExercicioModel>> _processExercisesList(List<ExercicioModel> exercicios) async {
    final processedExercicios = <ExercicioModel>[];
    
    for (final exercicio in exercicios) {
      final processedExercicio = await _processExerciseImages(exercicio);
      processedExercicios.add(processedExercicio);
    }
    
    return processedExercicios;
  }

  /// LISTAR TREINOS (COM PROCESSAMENTO DE ASSETS)
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
      // INVALIDAR CACHE SE NECESSÁRIO
      final cacheExpired = _lastFetch == null || 
          DateTime.now().difference(_lastFetch!).inMinutes > _cacheExpireMinutes;
      
      if (forceRefresh || cacheExpired) {
        _invalidateCache();
      }

      // USAR CACHE SE DISPONÍVEL (apenas para consultas sem filtros)
      if (_cachedTreinos != null && !forceRefresh && 
          busca == null && dificuldade == null && tipoTreino == null) {
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

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);
      
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

          // PROCESSAR ASSETS DOS EXERCÍCIOS
          final treinosProcessados = <TreinoModel>[];
          for (final treino in treinos) {
            final exerciciosProcessados = await _processExercisesList(treino.exercicios);
            final treinoProcessado = treino.copyWith(exercicios: exerciciosProcessados);
            treinosProcessados.add(treinoProcessado);
          }

          // ATUALIZAR CACHE (apenas se não tiver filtros)
          if (busca == null && dificuldade == null && tipoTreino == null) {
            _cachedTreinos = treinosProcessados;
            _lastFetch = DateTime.now();
          }

          return ApiResponse<List<TreinoModel>>(
            success: true,
            data: treinosProcessados,
            message: apiResponse.message ?? 'Treinos carregados',
          );
        }
      }

      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// BUSCAR TREINO ESPECÍFICO (COM PROCESSAMENTO DE ASSETS)
  static Future<ApiResponse<TreinoModel>> buscarTreino(int id) async {
    try {
      final uri = Uri.parse(await ApiConstants.getTreinoUrl(id));
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success && apiResponse.data != null) {
          final treino = TreinoModel.fromJson(apiResponse.data);
          
          // PROCESSAR ASSETS DOS EXERCÍCIOS
          final exerciciosProcessados = await _processExercisesList(treino.exercicios);
          final treinoProcessado = treino.copyWith(exercicios: exerciciosProcessados);
          
          return ApiResponse<TreinoModel>(
            success: true,
            data: treinoProcessado,
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
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// CRIAR NOVO TREINO
  static Future<ApiResponse<TreinoModel>> criarTreino(TreinoModel treino) async {
    try {
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

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treinoCriado = TreinoModel.fromJson(apiResponse.data);
          
          // INVALIDAR CACHE APÓS CRIAÇÃO
          _invalidateCache();
          
          // CRIAR EXERCÍCIOS SE EXISTIREM (COM PROCESSAMENTO DE ASSETS)
          if (treino.exercicios.isNotEmpty) {
            await _criarExerciciosDoTreino(treinoCriado.id!, treino.exercicios);
            
            // BUSCAR TREINO COMPLETO (já com processamento de assets)
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

      final uri = Uri.parse(await ApiConstants.getTreinoUrl(treino.id!));
      final headers = await _getHeaders();
      
      final dadosAtualizacao = {
        'nome_treino': treino.nomeTreino.trim(),
        'tipo_treino': treino.tipoTreino,
        'dificuldade': treino.dificuldade ?? 'iniciante',
        'descricao': treino.descricao?.trim().isEmpty == true ? null : treino.descricao?.trim(),
      };
      
      final body = json.encode(dadosAtualizacao);

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success && apiResponse.data != null) {
          final treinoAtualizado = TreinoModel.fromJson(apiResponse.data);
          
          // INVALIDAR CACHE APÓS ATUALIZAÇÃO
          _invalidateCache();
          
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
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// DELETAR TREINO
  static Future<ApiResponse<bool>> deletarTreino(int id) async {
    try {
      final uri = Uri.parse(await ApiConstants.getTreinoUrl(id));
      final headers = await _getHeaders();

      final response = await http.delete(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // INVALIDAR CACHE APÓS EXCLUSÃO
          _invalidateCache();
          
          return ApiResponse<bool>(
            success: true,
            data: true,
            message: apiResponse.message ?? 'Treino excluído com sucesso',
          );
        } else {
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
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// CRIAR EXERCÍCIO (COM PROCESSAMENTO DE ASSETS)
  static Future<ApiResponse<ExercicioModel>> criarExercicio(int treinoId, ExercicioModel exercicio) async {
    try {
      final uri = Uri.parse(await ApiConstants.getExerciciosUrl(treinoId));
      final headers = await _getHeaders();
      final body = json.encode(exercicio.toJson());

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final exercicioCriado = ExercicioModel.fromJson(apiResponse.data);
          
          // PROCESSAR ASSETS DO EXERCÍCIO CRIADO
          final exercicioProcessado = await _processExerciseImages(exercicioCriado);
          
          // INVALIDAR CACHE APÓS CRIAR EXERCÍCIO
          _invalidateCache();
          
          return ApiResponse<ExercicioModel>(
            success: true,
            data: exercicioProcessado,
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
      return ApiResponse<ExercicioModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// LISTAR EXERCÍCIOS DE UM TREINO (COM PROCESSAMENTO DE ASSETS)
  static Future<ApiResponse<List<ExercicioModel>>> listarExercicios(int treinoId) async {
    try {
      final uri = Uri.parse(await ApiConstants.getExerciciosUrl(treinoId));
      final headers = await _getHeaders();

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final data = apiResponse.data as Map<String, dynamic>;
          final List<dynamic> exerciciosJson = data['exercicios'];
          final exercicios = exerciciosJson.map((json) => ExercicioModel.fromJson(json)).toList();
          
          // PROCESSAR ASSETS DOS EXERCÍCIOS
          final exerciciosProcessados = await _processExercisesList(exercicios);
          
          return ApiResponse<List<ExercicioModel>>(
            success: true,
            data: exerciciosProcessados,
            message: apiResponse.message ?? 'Exercícios carregados',
          );
        }
      }

      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// ATUALIZAR EXERCÍCIO (COM PROCESSAMENTO DE ASSETS)
  static Future<ApiResponse<ExercicioModel>> atualizarExercicio(
    int treinoId, 
    int exercicioId, 
    ExercicioModel exercicio
  ) async {
    try {
      final uri = Uri.parse(await ApiConstants.getExercicioUrl(treinoId, exercicioId));
      final headers = await _getHeaders();
      final body = json.encode(exercicio.toJson());

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final exercicioAtualizado = ExercicioModel.fromJson(apiResponse.data);
          
          // PROCESSAR ASSETS DO EXERCÍCIO ATUALIZADO
          final exercicioProcessado = await _processExerciseImages(exercicioAtualizado);
          
          // INVALIDAR CACHE APÓS ATUALIZAR EXERCÍCIO
          _invalidateCache();
          
          return ApiResponse<ExercicioModel>(
            success: true,
            data: exercicioProcessado,
            message: apiResponse.message ?? 'Exercício atualizado',
          );
        }
      }

      return ApiResponse<ExercicioModel>(
        success: false,
        message: ApiConstants.getErrorMessage(response.statusCode),
      );
    } catch (e) {
      return ApiResponse<ExercicioModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// DELETAR EXERCÍCIO
  static Future<ApiResponse<bool>> deletarExercicio(int treinoId, int exercicioId) async {
    try {
      final uri = Uri.parse(await ApiConstants.getExercicioUrl(treinoId, exercicioId));
      final headers = await _getHeaders();

      final response = await http.delete(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // INVALIDAR CACHE APÓS DELETAR EXERCÍCIO
          _invalidateCache();
          
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

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // INVALIDAR CACHE APÓS REORDENAR
          _invalidateCache();
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
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// MÉTODO AUXILIAR: CRIAR EXERCÍCIOS DO TREINO (COM PROCESSAMENTO DE ASSETS)
  static Future<void> _criarExerciciosDoTreino(
    int treinoId,
    List<ExercicioModel> exercicios,
  ) async {
    try {
      for (int i = 0; i < exercicios.length; i++) {
        final exercicio = exercicios[i].copyWith(ordem: i + 1);
        await criarExercicio(treinoId, exercicio);
      }
    } catch (e) {
      // Ignorar erros na criação de exercícios
    }
  }

  /// INVALIDAR CACHE
  static void _invalidateCache() {
    _cachedTreinos = null;
    _lastFetch = null;
  }

  /// FORÇAR ATUALIZAÇÃO DA LISTA
  static Future<ApiResponse<List<TreinoModel>>> forcarAtualizacao() async {
    return await listarTreinos(forceRefresh: true);
  }

  /// LIMPAR CACHE MANUALMENTE
  static void limparCache() {
    _invalidateCache();
  }

  /// TESTAR CONEXÃO COM API
  static Future<bool> testarConexao() async {
    try {
      return await ApiConstants.testCurrentAPI();
    } catch (e) {
      return false;
    }
  }

  /// LISTAR TREINOS POR DIFICULDADE
  static Future<ApiResponse<List<TreinoModel>>> listarTreinosPorDificuldade(String dificuldade) async {
    return await listarTreinos(dificuldade: dificuldade);
  }

  /// ALIAS PARA COMPATIBILIDADE
  static Future<ApiResponse<bool>> removerTreino(int id) async {
    return await deletarTreino(id);
  }

  /// ALIAS PARA COMPATIBILIDADE
  static Future<ApiResponse<TreinoModel>> editarTreino(TreinoModel treino) async {
    return await atualizarTreino(treino);
  }

  /// DEBUG: TESTAR SISTEMA DE ASSETS
  static Future<void> debugTestAssetSystem() async {
    print('=== TESTE DO SISTEMA DE ASSETS ===');
    
    // Testar helper
    ExerciseAssetsHelper.debugPrintMappings();
    await ExerciseAssetsHelper.debugTestAsset('flexão');
    await ExerciseAssetsHelper.debugTestAsset('supino reto');
    
    print('=== FIM TESTE ===');
  }
}