import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/treino_model.dart';
import '../../models/api_response_model.dart';
import '../../config/api_config.dart';  // ✅ USAR NOVO API CONFIG
import 'storage_service.dart';

class TreinoService {
  // ===== SINGLETON =====
  static final TreinoService _instance = TreinoService._internal();
  factory TreinoService() => _instance;
  TreinoService._internal();

  // ===== CONFIGURAÇÃO =====
  final ApiConfig _apiConfig = ApiConfig();
  final StorageService _storage = StorageService();

  // Headers padrão
  static const Map<String, String> _baseHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========================================
  // MÉTODOS PRINCIPAIS - TREINOS
  // ========================================

  /// 📋 Listar todos os treinos do usuário
  Future<ApiResponse<List<TreinoModel>>> listarTreinos({
    String? busca,
    String? dificuldade,
    String? tipoTreino,
    String? orderBy,
    String? orderDirection,
    int? perPage,
  }) async {
    try {
      print('📋 === LISTANDO TREINOS ===');
      
      // Construir query parameters
      final queryParams = <String, String>{};
      if (busca != null && busca.isNotEmpty) {
        queryParams['busca'] = busca;
        print('🔍 Busca: $busca');
      }
      if (dificuldade != null && dificuldade.isNotEmpty) {
        queryParams['dificuldade'] = dificuldade;
        print('📊 Dificuldade: $dificuldade');
      }
      if (tipoTreino != null && tipoTreino.isNotEmpty) {
        queryParams['tipo_treino'] = tipoTreino;
        print('🏃 Tipo: $tipoTreino');
      }
      if (orderBy != null && orderBy.isNotEmpty) {
        queryParams['order_by'] = orderBy;
        print('📑 Ordenar por: $orderBy');
      }
      if (orderDirection != null && orderDirection.isNotEmpty) {
        queryParams['order_direction'] = orderDirection;
        print('⬆️ Direção: $orderDirection');
      }
      if (perPage != null) {
        queryParams['per_page'] = perPage.toString();
        print('📄 Por página: $perPage');
      }

      // Fazer requisição
      final response = await _makeRequest(
        method: 'GET',
        endpoint: '/treinos',
        queryParams: queryParams,
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          // Tratar dados paginados
          final data = apiResponse.data;
          List<TreinoModel> treinos = [];

          if (data is Map<String, dynamic> && data.containsKey('data')) {
            // Resposta paginada do Laravel
            final List<dynamic> treinosJson = data['data'];
            treinos = treinosJson.map((json) => TreinoModel.fromJson(json)).toList();
            print('✅ ${treinos.length} treinos carregados (paginado)');
          } else if (data is List) {
            // Lista simples
            treinos = data.map((json) => TreinoModel.fromJson(json)).toList();
            print('✅ ${treinos.length} treinos carregados');
          }

          return ApiResponse<List<TreinoModel>>(
            success: true,
            data: treinos,
            message: apiResponse.message ?? 'Treinos carregados com sucesso',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<List<TreinoModel>>(
            success: false,
            message: apiResponse.message ?? 'Erro ao listar treinos',
          );
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<List<TreinoModel>>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao listar treinos: $e');
      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// 🔍 Buscar treino específico por ID
  Future<ApiResponse<TreinoModel>> buscarTreino(int id) async {
    try {
      print('🔍 === BUSCANDO TREINO $id ===');
      
      final response = await _makeRequest(
        method: 'GET',
        endpoint: '/treinos/$id',
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treino = TreinoModel.fromJson(apiResponse.data);
          print('✅ Treino encontrado: ${treino.nomeTreino}');
          print('💪 ${treino.exercicios.length} exercícios');
          
          return ApiResponse<TreinoModel>(
            success: true,
            data: treino,
            message: apiResponse.message ?? 'Treino encontrado',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<TreinoModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao buscar treino',
          );
        }
      } else if (response.statusCode == ApiConfig.statusNotFound) {
        print('❌ Treino não encontrado');
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'Treino não encontrado',
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<TreinoModel>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao buscar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// ➕ Criar novo treino
  Future<ApiResponse<TreinoModel>> criarTreino(TreinoModel treino) async {
    try {
      print('➕ === CRIANDO TREINO ===');
      print('📝 Nome: ${treino.nomeTreino}');
      print('🏃 Tipo: ${treino.tipoTreino}');
      print('📊 Dificuldade: ${treino.dificuldade}');
      print('💪 Exercícios: ${treino.exercicios.length}');
      
      final response = await _makeRequest(
        method: 'POST',
        endpoint: '/treinos',
        body: treino.toJson(),
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treinoCriado = TreinoModel.fromJson(apiResponse.data);
          print('✅ Treino criado: ID ${treinoCriado.id}');
          
          // Se o treino tem exercícios, criar cada um
          if (treino.exercicios.isNotEmpty) {
            print('💪 Criando ${treino.exercicios.length} exercícios...');
            final treinoComExercicios = await _criarExerciciosDoTreino(
              treinoCriado.id!,
              treino.exercicios,
            );
            
            if (treinoComExercicios.success) {
              print('✅ Treino e exercícios criados com sucesso');
              return ApiResponse<TreinoModel>(
                success: true,
                data: treinoComExercicios.data!,
                message: 'Treino criado com sucesso',
              );
            } else {
              print('⚠️ Treino criado, mas erro nos exercícios');
              return ApiResponse<TreinoModel>(
                success: true,
                data: treinoCriado,
                message: 'Treino criado, mas houve erro ao adicionar exercícios',
              );
            }
          }

          return ApiResponse<TreinoModel>(
            success: true,
            data: treinoCriado,
            message: apiResponse.message ?? 'Treino criado com sucesso',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<TreinoModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao criar treino',
          );
        }
      } else if (response.statusCode == ApiConfig.statusUnprocessableEntity) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        print('❌ Dados inválidos: $errorMessages');
        return ApiResponse<TreinoModel>(
          success: false,
          message: errorMessages,
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<TreinoModel>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao criar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// ✏️ Atualizar treino existente
  Future<ApiResponse<TreinoModel>> atualizarTreino(TreinoModel treino) async {
    try {
      if (treino.id == null) {
        print('❌ ID do treino é obrigatório');
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'ID do treino é obrigatório para atualização',
        );
      }

      print('✏️ === ATUALIZANDO TREINO ${treino.id} ===');
      print('📝 Nome: ${treino.nomeTreino}');
      
      final response = await _makeRequest(
        method: 'PUT',
        endpoint: '/treinos/${treino.id}',
        body: treino.toJson(),
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treinoAtualizado = TreinoModel.fromJson(apiResponse.data);
          print('✅ Treino atualizado: ${treinoAtualizado.nomeTreino}');
          
          return ApiResponse<TreinoModel>(
            success: true,
            data: treinoAtualizado,
            message: apiResponse.message ?? 'Treino atualizado com sucesso',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<TreinoModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao atualizar treino',
          );
        }
      } else if (response.statusCode == ApiConfig.statusNotFound) {
        print('❌ Treino não encontrado');
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'Treino não encontrado',
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<TreinoModel>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao atualizar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// 🗑️ Deletar treino (soft delete)
  Future<ApiResponse<bool>> deletarTreino(int id) async {
    try {
      print('🗑️ === DELETANDO TREINO $id ===');
      
      final response = await _makeRequest(
        method: 'DELETE',
        endpoint: '/treinos/$id',
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          print('✅ Treino deletado com sucesso');
        }

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message ?? 'Treino removido com sucesso',
        );
      } else if (response.statusCode == ApiConfig.statusNotFound) {
        print('❌ Treino não encontrado');
        return ApiResponse<bool>(
          success: false,
          message: 'Treino não encontrado',
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<bool>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao deletar treino: $e');
      return ApiResponse<bool>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// 📊 Listar treinos por dificuldade
  Future<ApiResponse<List<TreinoModel>>> listarTreinosPorDificuldade(String dificuldade) async {
    try {
      print('📊 === TREINOS POR DIFICULDADE: $dificuldade ===');
      
      final response = await _makeRequest(
        method: 'GET',
        endpoint: '/treinos/dificuldade/$dificuldade',
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final List<dynamic> treinosJson = apiResponse.data;
          final treinos = treinosJson.map((json) => TreinoModel.fromJson(json)).toList();
          
          print('✅ ${treinos.length} treinos de nível $dificuldade');
          
          return ApiResponse<List<TreinoModel>>(
            success: true,
            data: treinos,
            message: apiResponse.message ?? 'Treinos carregados',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<List<TreinoModel>>(
            success: false,
            message: apiResponse.message ?? 'Erro ao listar treinos por dificuldade',
          );
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<List<TreinoModel>>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao listar treinos por dificuldade: $e');
      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // ========================================
  // MÉTODOS PRINCIPAIS - EXERCÍCIOS
  // ========================================

  /// 💪 Listar exercícios de um treino
  Future<ApiResponse<List<ExercicioModel>>> listarExercicios(int treinoId) async {
    try {
      print('💪 === LISTANDO EXERCÍCIOS DO TREINO $treinoId ===');
      
      final response = await _makeRequest(
        method: 'GET',
        endpoint: '/treinos/$treinoId/exercicios',
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final data = apiResponse.data as Map<String, dynamic>;
          final List<dynamic> exerciciosJson = data['exercicios'];
          final exercicios = exerciciosJson.map((json) => ExercicioModel.fromJson(json)).toList();
          
          print('✅ ${exercicios.length} exercícios carregados');
          
          return ApiResponse<List<ExercicioModel>>(
            success: true,
            data: exercicios,
            message: apiResponse.message ?? 'Exercícios carregados',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<List<ExercicioModel>>(
            success: false,
            message: apiResponse.message ?? 'Erro ao listar exercícios',
          );
        }
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<List<ExercicioModel>>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao listar exercícios: $e');
      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// ➕ Criar exercício em um treino
  Future<ApiResponse<ExercicioModel>> criarExercicio(int treinoId, ExercicioModel exercicio) async {
    try {
      print('➕ === CRIANDO EXERCÍCIO ===');
      print('💪 Nome: ${exercicio.nomeExercicio}');
      print('📋 Treino: $treinoId');
      
      final response = await _makeRequest(
        method: 'POST',
        endpoint: '/treinos/$treinoId/exercicios',
        body: exercicio.toJson(),
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final exercicioCriado = ExercicioModel.fromJson(apiResponse.data);
          print('✅ Exercício criado: ${exercicioCriado.nomeExercicio}');
          
          return ApiResponse<ExercicioModel>(
            success: true,
            data: exercicioCriado,
            message: apiResponse.message ?? 'Exercício criado com sucesso',
          );
        } else {
          print('❌ API retornou erro: ${apiResponse.message}');
          return ApiResponse<ExercicioModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao criar exercício',
          );
        }
      } else if (response.statusCode == ApiConfig.statusUnprocessableEntity) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        print('❌ Dados inválidos: $errorMessages');
        return ApiResponse<ExercicioModel>(
          success: false,
          message: errorMessages,
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<ExercicioModel>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao criar exercício: $e');
      return ApiResponse<ExercicioModel>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// 🗑️ Deletar exercício
  Future<ApiResponse<bool>> deletarExercicio(int treinoId, int exercicioId) async {
    try {
      print('🗑️ === DELETANDO EXERCÍCIO $exercicioId ===');
      print('📋 Treino: $treinoId');
      
      final response = await _makeRequest(
        method: 'DELETE',
        endpoint: '/treinos/$treinoId/exercicios/$exercicioId',
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          print('✅ Exercício deletado com sucesso');
        }

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message ?? 'Exercício removido com sucesso',
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<bool>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao deletar exercício: $e');
      return ApiResponse<bool>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  /// 🔄 Reordenar exercícios de um treino
  Future<ApiResponse<bool>> reordenarExercicios(
    int treinoId,
    List<Map<String, dynamic>> exerciciosOrdenados,
  ) async {
    try {
      print('🔄 === REORDENANDO EXERCÍCIOS ===');
      print('📋 Treino: $treinoId');
      print('🔢 Exercícios: ${exerciciosOrdenados.length}');
      
      final response = await _makeRequest(
        method: 'PUT',
        endpoint: '/treinos/$treinoId/exercicios/reordenar',
        body: {'exercicios': exerciciosOrdenados},
      );

      print('📊 Status: ${response.statusCode}');

      if (response.statusCode == ApiConfig.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          print('✅ Exercícios reordenados com sucesso');
        }

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message ?? 'Exercícios reordenados com sucesso',
        );
      } else {
        print('❌ Erro HTTP: ${response.statusCode}');
        return ApiResponse<bool>(
          success: false,
          message: ApiConfig.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao reordenar exercícios: $e');
      return ApiResponse<bool>(
        success: false,
        message: _getErrorMessage(e),
      );
    }
  }

  // ========================================
  // MÉTODOS PRIVADOS
  // ========================================

  /// 💪 Criar exercícios de um treino
  Future<ApiResponse<TreinoModel>> _criarExerciciosDoTreino(
    int treinoId,
    List<ExercicioModel> exercicios,
  ) async {
    try {
      print('💪 === CRIANDO ${exercicios.length} EXERCÍCIOS ===');
      
      int sucessos = 0;
      int falhas = 0;
      
      for (int i = 0; i < exercicios.length; i++) {
        final exercicio = exercicios[i];
        print('💪 [${i + 1}/${exercicios.length}] ${exercicio.nomeExercicio}');
        
        final response = await criarExercicio(treinoId, exercicio);
        if (response.success) {
          sucessos++;
          print('  ✅ Criado');
        } else {
          falhas++;
          print('  ❌ Falhou: ${response.message}');
        }
      }

      print('📊 Resultado: $sucessos sucessos, $falhas falhas');

      // Buscar treino atualizado com exercícios
      final treinoAtualizado = await buscarTreino(treinoId);
      
      if (treinoAtualizado.success) {
        return ApiResponse<TreinoModel>(
          success: sucessos > 0,
          data: treinoAtualizado.data,
          message: sucessos == exercicios.length 
              ? 'Todos os exercícios criados com sucesso'
              : '$sucessos de ${exercicios.length} exercícios criados',
        );
      } else {
        return treinoAtualizado;
      }
      
    } catch (e) {
      print('❌ Erro ao criar exercícios: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro ao criar exercícios: $e',
      );
    }
  }

  /// 🌐 Fazer requisição HTTP com retry automático
  Future<http.Response> _makeRequest({
    required String method,
    required String endpoint,
    Map<String, String>? queryParams,
    Map<String, dynamic>? body,
    Duration? timeout,
  }) async {
    
    // Obter token de autenticação
    final token = await _storage.getAuthToken();
    
    // Merge headers
    final headers = {
      ..._baseHeaders,
      ...ApiConfig.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    // Timeout padrão
    timeout ??= ApiConfig.defaultTimeout;
    
    int attemptCount = 0;
    Exception? lastException;
    
    while (attemptCount < ApiConfig.maxRetries) {
      try {
        attemptCount++;
        
        if (attemptCount > 1) {
          print('🔄 Tentativa $attemptCount/${ApiConfig.maxRetries}');
          
          // Delay com backoff exponencial
          await Future.delayed(ApiConfig.getRetryDelay(attemptCount - 1));
        }
        
        // Construir URL
        String url;
        if (queryParams != null && queryParams.isNotEmpty) {
          url = await _apiConfig.buildUrlWithParams(endpoint, queryParams);
        } else {
          url = await _apiConfig.buildUrl(endpoint);
        }
        
        final uri = Uri.parse(url);
        late http.Response response;
        
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers).timeout(timeout);
            break;
          case 'POST':
            response = await http.post(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(timeout);
            break;
          case 'PUT':
            response = await http.put(
              uri,
              headers: headers,
              body: body != null ? jsonEncode(body) : null,
            ).timeout(timeout);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers).timeout(timeout);
            break;
          default:
            throw ArgumentError('Método HTTP não suportado: $method');
        }
        
        // Se chegou aqui, a requisição foi bem-sucedida
        if (attemptCount > 1) {
          print('✅ Requisição bem-sucedida na tentativa $attemptCount');
        }
        
        return response;
        
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        
        print('❌ Tentativa $attemptCount falhou: ${e.toString().split(': ').last}');
        
        // Se não deve fazer retry ou é a última tentativa, lançar erro
        if (attemptCount >= ApiConfig.maxRetries) {
          break;
        }
        
        // Verificar se deve fazer retry baseado no tipo de erro
        if (e.toString().contains('Connection') || 
            e.toString().contains('timeout') ||
            e.toString().contains('SocketException')) {
          print('🔄 Erro de rede, tentando novamente...');
          continue;
        } else {
          // Erro que não justifica retry
          break;
        }
      }
    }
    
    // Se chegou aqui, todas as tentativas falharam
    print('❌ Todas as $attemptCount tentativas falharam');
    throw lastException ?? Exception('Erro desconhecido na requisição');
  }

  /// 📝 Obter mensagem de erro amigável
  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Tempo limite esgotado. Verifique sua conexão.';
    } else if (errorString.contains('socket') || errorString.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet.';
    } else if (errorString.contains('certificate') || errorString.contains('ssl')) {
      return 'Erro de certificado SSL.';
    } else if (errorString.contains('format')) {
      return 'Erro no formato dos dados.';
    } else {
      return 'Erro de conexão. Tente novamente.';
    }
  }

  // ========================================
  // MÉTODOS DE TESTE E DEBUG
  // ========================================

  /// 🔍 Testar conectividade com a API
  Future<bool> testarConexao() async {
    try {
      print('🔍 === TESTANDO CONECTIVIDADE ===');
      
      final isWorking = await _apiConfig.testConnection();
      
      if (isWorking) {
        print('✅ API conectada!');
        return true;
      } else {
        print('❌ API não está respondendo');
        
        // Tentar forçar nova detecção
        print('🔄 Tentando nova detecção...');
        await _apiConfig.forceDetection();
        
        // Testar novamente
        return await _apiConfig.testConnection();
      }
    } catch (e) {
      print('❌ Erro de conexão: $e');
      return false;
    }
  }

  /// 🎯 Forçar IP específico para teste
  Future<bool> forceTestIP(String ip, {int port = 8000}) async {
    try {
      print('🎯 Testando IP específico: $ip:$port');
      
      return await _apiConfig.quickSetupIP(ip, port: port);
    } catch (e) {
      print('❌ Erro ao testar IP: $e');
      return false;
    }
  }

  /// 📊 Debug: Imprimir informações do serviço
  Future<void> printServiceDebug() async {
    try {
      print('🔍 === TREINO SERVICE DEBUG ===');
      
      final configInfo = await _apiConfig.getConfigInfo();
      final token = await _storage.getAuthToken();
      
      print('Service Status:');
      print('   Has Auth Token: ${token != null}');
      print('   Token Length: ${token?.length ?? 0} chars');
      print('');
      print('Network Status:');
      print('   Environment: ${configInfo['environment']}');
      print('   Platform: ${configInfo['platform']}');
      print('   Current URL: ${configInfo['current_base_url']}');
      print('   Detected URL: ${configInfo['detected_url'] ?? 'Não detectado'}');
      print('   Manual URL: ${configInfo['manual_url'] ?? 'Nenhuma'}');
      print('   Using Manual: ${configInfo['is_using_manual']}');
      print('===============================');
    } catch (e) {
      print('❌ Erro ao imprimir debug: $e');
    }
  }

  /// 🔄 Reset completo do serviço
  void reset() {
    print('🔄 === RESET TREINO SERVICE ===');
    _apiConfig.reset();
    print('✅ Reset concluído');
  }

  /// 📈 Obter estatísticas do serviço
  Future<Map<String, dynamic>> getServiceStats() async {
    final token = await _storage.getAuthToken();
    final configInfo = await _apiConfig.getConfigInfo();
    
    return {
      'auth': {
        'hasToken': token != null,
      },
      'network': configInfo,
      'timestamps': {
        'checked_at': DateTime.now().toIso8601String(),
      }
    };
  }

  /// 🧪 Teste completo do serviço
  Future<Map<String, dynamic>> testeCompleto() async {
    print('🧪 === TESTE COMPLETO TREINO SERVICE ===');
    
    final resultado = <String, dynamic>{
      'conectividade': false,
      'autenticacao': false,
      'lista_treinos': false,
      'detalhes': {},
    };
    
    try {
      // 1. Teste de conectividade
      print('🔍 1. Testando conectividade...');
      resultado['conectividade'] = await testarConexao();
      
      // 2. Teste de autenticação (token)
      print('🔐 2. Verificando autenticação...');
      final token = await _storage.getAuthToken();
      resultado['autenticacao'] = token != null;
      
      // 3. Teste de listagem de treinos
      if (resultado['conectividade'] && resultado['autenticacao']) {
        print('📋 3. Testando listagem de treinos...');
        final listResponse = await listarTreinos(perPage: 1);
        resultado['lista_treinos'] = listResponse.success;
        
        if (listResponse.success) {
          resultado['detalhes']['total_treinos'] = listResponse.data?.length ?? 0;
        } else {
          resultado['detalhes']['erro_lista'] = listResponse.message;
        }
      }
      
      // 4. Informações da rede
      final configInfo = await _apiConfig.getConfigInfo();
      resultado['detalhes']['network'] = configInfo;
      
      print('✅ Teste completo finalizado');
      return resultado;
      
    } catch (e) {
      print('❌ Erro no teste completo: $e');
      resultado['detalhes']['erro'] = e.toString();
      return resultado;
    }
  }
}