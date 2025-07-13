import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/treino_model.dart';
import '../../models/api_response_model.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class TreinoService {
  static final StorageService _storage = StorageService();
  
  /// Headers padrão para requisições
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.getAuthToken();
    return {
      ...ApiConstants.defaultHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Listar todos os treinos do usuário
  static Future<ApiResponse<List<TreinoModel>>> listarTreinos({
    String? busca,
    String? dificuldade,
    String? tipoTreino,
    String? orderBy,
    String? orderDirection,
    int? perPage,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};
      if (busca != null && busca.isNotEmpty) queryParams['busca'] = busca;
      if (dificuldade != null && dificuldade.isNotEmpty) queryParams['dificuldade'] = dificuldade;
      if (tipoTreino != null && tipoTreino.isNotEmpty) queryParams['tipo_treino'] = tipoTreino;
      if (orderBy != null && orderBy.isNotEmpty) queryParams['order_by'] = orderBy;
      if (orderDirection != null && orderDirection.isNotEmpty) queryParams['order_direction'] = orderDirection;
      if (perPage != null) queryParams['per_page'] = perPage.toString();

      // ✅ Detecção automática de rede
      final baseUrl = await ApiConstants.getUrl(ApiConstants.treinos);
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final headers = await _getHeaders();

      print('🚀 GET $uri');
      print('📋 Headers: ${headers.keys}');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
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
          } else if (data is List) {
            // Lista simples
            treinos = data.map((json) => TreinoModel.fromJson(json)).toList();
          }

          return ApiResponse<List<TreinoModel>>(
            success: true,
            data: treinos,
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<List<TreinoModel>>(
            success: false,
            message: apiResponse.message ?? 'Erro ao listar treinos',
          );
        }
      } else {
        return ApiResponse<List<TreinoModel>>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao listar treinos: $e');
      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Buscar treino específico por ID
  static Future<ApiResponse<TreinoModel>> buscarTreino(int id) async {
    try {
      // ✅ Detecção automática de rede
      final uri = Uri.parse(await ApiConstants.getTreinoUrl(id));
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treino = TreinoModel.fromJson(apiResponse.data);
          return ApiResponse<TreinoModel>(
            success: true,
            data: treino,
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<TreinoModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao buscar treino',
          );
        }
      } else if (response.statusCode == ApiConstants.statusNotFound) {
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'Treino não encontrado',
        );
      } else {
        return ApiResponse<TreinoModel>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao buscar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Criar novo treino
  static Future<ApiResponse<TreinoModel>> criarTreino(TreinoModel treino) async {
    try {
      // ✅ Detecção automática de rede
      final uri = Uri.parse(await ApiConstants.getUrl(ApiConstants.treinoStore));
      final headers = await _getHeaders();
      final body = json.encode(treino.toJson());

      print('🚀 POST $uri');
      print('📤 Body: $body');

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treinoCriado = TreinoModel.fromJson(apiResponse.data);
          
          // Se o treino tem exercícios, criar cada um
          if (treino.exercicios.isNotEmpty) {
            final treinoComExercicios = await _criarExerciciosDoTreino(
              treinoCriado.id!,
              treino.exercicios,
            );
            
            if (treinoComExercicios.success) {
              return ApiResponse<TreinoModel>(
                success: true,
                data: treinoComExercicios.data!,
                message: 'Treino criado com sucesso',
              );
            } else {
              // Treino foi criado mas exercícios falharam
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
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<TreinoModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao criar treino',
          );
        }
      } else if (response.statusCode == ApiConstants.statusUnprocessableEntity) {
        // Erro de validação
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        return ApiResponse<TreinoModel>(
          success: false,
          message: errorMessages,
        );
      } else {
        return ApiResponse<TreinoModel>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao criar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Criar exercícios de um treino
  static Future<ApiResponse<TreinoModel>> _criarExerciciosDoTreino(
    int treinoId,
    List<ExercicioModel> exercicios,
  ) async {
    try {
      final exerciciosCriados = <ExercicioModel>[];
      
      for (final exercicio in exercicios) {
        final response = await criarExercicio(treinoId, exercicio);
        if (response.success) {
          exerciciosCriados.add(response.data!);
        } else {
          print('❌ Erro ao criar exercício: ${exercicio.nomeExercicio}');
        }
      }

      // Buscar treino atualizado com exercícios
      final treinoAtualizado = await buscarTreino(treinoId);
      return treinoAtualizado;
      
    } catch (e) {
      print('❌ Erro ao criar exercícios: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro ao criar exercícios: $e',
      );
    }
  }

  /// Atualizar treino existente
  static Future<ApiResponse<TreinoModel>> atualizarTreino(TreinoModel treino) async {
    try {
      if (treino.id == null) {
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'ID do treino é obrigatório para atualização',
        );
      }

      // ✅ Adicionar await
      final uri = Uri.parse(await ApiConstants.getTreinoUrl(treino.id!));
      final headers = await _getHeaders();
      final body = json.encode(treino.toJson());

      print('🚀 PUT $uri');
      print('📤 Body: $body');

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final treinoAtualizado = TreinoModel.fromJson(apiResponse.data);
          return ApiResponse<TreinoModel>(
            success: true,
            data: treinoAtualizado,
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<TreinoModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao atualizar treino',
          );
        }
      } else if (response.statusCode == ApiConstants.statusNotFound) {
        return ApiResponse<TreinoModel>(
          success: false,
          message: 'Treino não encontrado',
        );
      } else {
        return ApiResponse<TreinoModel>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao atualizar treino: $e');
      return ApiResponse<TreinoModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Deletar treino (soft delete)
  static Future<ApiResponse<bool>> deletarTreino(int id) async {
    try {
      // ✅ Adicionar await
      final uri = Uri.parse(await ApiConstants.getTreinoUrl(id));
      final headers = await _getHeaders();

      print('🚀 DELETE $uri');

      final response = await http.delete(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message,
        );
      } else if (response.statusCode == ApiConstants.statusNotFound) {
        return ApiResponse<bool>(
          success: false,
          message: 'Treino não encontrado',
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao deletar treino: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Listar treinos por dificuldade
  static Future<ApiResponse<List<TreinoModel>>> listarTreinosPorDificuldade(String dificuldade) async {
    try {
      // ✅ Adicionar await
      final uri = Uri.parse(await ApiConstants.getTreinosByDificuldadeUrl(dificuldade));
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final List<dynamic> treinosJson = apiResponse.data;
          final treinos = treinosJson.map((json) => TreinoModel.fromJson(json)).toList();
          
          return ApiResponse<List<TreinoModel>>(
            success: true,
            data: treinos,
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<List<TreinoModel>>(
            success: false,
            message: apiResponse.message ?? 'Erro ao listar treinos por dificuldade',
          );
        }
      } else {
        return ApiResponse<List<TreinoModel>>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao listar treinos por dificuldade: $e');
      return ApiResponse<List<TreinoModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  // ========================================================================
  // MÉTODOS PARA EXERCÍCIOS
  // ========================================================================

  /// Listar exercícios de um treino
  static Future<ApiResponse<List<ExercicioModel>>> listarExercicios(int treinoId) async {
    try {
      // ✅ Adicionar await
      final uri = Uri.parse(await ApiConstants.getExerciciosUrl(treinoId));
      final headers = await _getHeaders();

      print('🚀 GET $uri');

      final response = await http.get(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

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
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<List<ExercicioModel>>(
            success: false,
            message: apiResponse.message ?? 'Erro ao listar exercícios',
          );
        }
      } else {
        return ApiResponse<List<ExercicioModel>>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao listar exercícios: $e');
      return ApiResponse<List<ExercicioModel>>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Criar exercício em um treino
  static Future<ApiResponse<ExercicioModel>> criarExercicio(int treinoId, ExercicioModel exercicio) async {
    try {
      // ✅ Detecção automática de rede
      final uri = Uri.parse(await ApiConstants.getExerciciosUrl(treinoId));
      final headers = await _getHeaders();
      final body = json.encode(exercicio.toJson());

      print('🚀 POST $uri');
      print('📤 Body: $body');

      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusCreated) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        if (apiResponse.success) {
          final exercicioCriado = ExercicioModel.fromJson(apiResponse.data);
          return ApiResponse<ExercicioModel>(
            success: true,
            data: exercicioCriado,
            message: apiResponse.message,
          );
        } else {
          return ApiResponse<ExercicioModel>(
            success: false,
            message: apiResponse.message ?? 'Erro ao criar exercício',
          );
        }
      } else if (response.statusCode == ApiConstants.statusUnprocessableEntity) {
        final jsonData = json.decode(response.body);
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        final errorMessages = errors?.values.expand((e) => e as List).join(', ') ?? 'Dados inválidos';
        
        return ApiResponse<ExercicioModel>(
          success: false,
          message: errorMessages,
        );
      } else {
        return ApiResponse<ExercicioModel>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao criar exercício: $e');
      return ApiResponse<ExercicioModel>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Deletar exercício
  static Future<ApiResponse<bool>> deletarExercicio(int treinoId, int exercicioId) async {
    try {
      // ✅ Adicionar await
      final uri = Uri.parse(await ApiConstants.getExercicioUrl(treinoId, exercicioId));
      final headers = await _getHeaders();

      print('🚀 DELETE $uri');

      final response = await http.delete(uri, headers: headers).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message,
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao deletar exercício: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  /// Reordenar exercícios de um treino
  static Future<ApiResponse<bool>> reordenarExercicios(
    int treinoId,
    List<Map<String, dynamic>> exerciciosOrdenados,
  ) async {
    try {
      final uri = Uri.parse('${ApiConstants.getExerciciosUrl(treinoId)}/reordenar');
      final headers = await _getHeaders();
      final body = json.encode({'exercicios': exerciciosOrdenados});

      print('🚀 PUT $uri');
      print('📤 Body: $body');

      final response = await http.put(
        uri,
        headers: headers,
        body: body,
      ).timeout(ApiConstants.defaultTimeout);

      print('📥 Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == ApiConstants.statusOk) {
        final jsonData = json.decode(response.body);
        final apiResponse = ApiResponse.fromJson(jsonData);

        return ApiResponse<bool>(
          success: apiResponse.success,
          data: apiResponse.success,
          message: apiResponse.message,
        );
      } else {
        return ApiResponse<bool>(
          success: false,
          message: ApiConstants.getErrorMessage(response.statusCode),
        );
      }
    } catch (e) {
      print('❌ Erro ao reordenar exercícios: $e');
      return ApiResponse<bool>(
        success: false,
        message: 'Erro interno: $e',
      );
    }
  }

  // ========================================================================
  // MÉTODOS UTILITÁRIOS
  // ========================================================================

  /// Testar conexão com a API
  static Future<bool> testarConexao() async {
    try {
      // ✅ Usar o detector automático de rede
      return await ApiConstants.testCurrentAPI();
    } catch (e) {
      print('❌ Erro no teste de conexão: $e');
      return false;
    }
  }
}