import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'google_auth_service.dart';
import '../utils/network_utils.dart';

/// Serviço para gerenciar treinos via API
class TreinoService {
  // ===== SINGLETON =====
  static final TreinoService _instance = TreinoService._internal();
  factory TreinoService() => _instance;
  TreinoService._internal();

  /// Obter headers com autenticação
  Map<String, String> _getAuthHeaders() {
    final token = GoogleAuthService().authToken;
    if (token == null) {
      throw Exception('Token de autenticação não encontrado');
    }
    return ApiConstants.getAuthHeaders(token);
  }

  /// Obter lista de treinos
  Future<Map<String, dynamic>> getTreinos({
    String? busca,
    String? dificuldade,
    String? tipoTreino,
    String? orderBy = 'created_at',
    String? orderDirection = 'desc',
    int perPage = 15,
  }) async {
    try {
      // Construir query parameters
      final queryParams = <String, String>{};
      
      if (busca != null && busca.isNotEmpty) {
        queryParams['busca'] = busca;
      }
      if (dificuldade != null && dificuldade.isNotEmpty) {
        queryParams['dificuldade'] = dificuldade;
      }
      if (tipoTreino != null && tipoTreino.isNotEmpty) {
        queryParams['tipo_treino'] = tipoTreino;
      }
      
      queryParams['order_by'] = orderBy ?? 'created_at';
      queryParams['order_direction'] = orderDirection ?? 'desc';
      queryParams['per_page'] = perPage.toString();

      // Construir URL com query parameters
      final uri = Uri.parse(ApiConstants.getUrl(ApiConstants.treinos))
          .replace(queryParameters: queryParams);

      if (kDebugMode) {
        print('📤 GET Treinos: $uri');
      }

      final response = await http
          .get(uri, headers: _getAuthHeaders())
          .timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);

      if (kDebugMode) {
        print('📥 Response Treinos: ${response.statusCode}');
      }

      if (ApiConstants.isSuccessStatusCode(response.statusCode)) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? ApiConstants.getErrorMessage(response.statusCode),
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro getTreinos: $e');
      return {
        'success': false,
        'message': NetworkUtils.getErrorMessage(e),
      };
    }
  }

  /// Obter treino específico
  Future<Map<String, dynamic>> getTreino(int treinoId) async {
    try {
      final url = ApiConstants.getTreinoUrl(treinoId);
      
      if (kDebugMode) {
        print('📤 GET Treino: $url');
      }

      final response = await http
          .get(Uri.parse(url), headers: _getAuthHeaders())
          .timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);

      if (kDebugMode) {
        print('📥 Response Treino: ${response.statusCode}');
      }

      if (ApiConstants.isSuccessStatusCode(response.statusCode)) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? ApiConstants.getErrorMessage(response.statusCode),
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro getTreino: $e');
      return {
        'success': false,
        'message': NetworkUtils.getErrorMessage(e),
      };
    }
  }

  /// Criar novo treino
  Future<Map<String, dynamic>> createTreino({
    required String nomeTreino,
    required String tipoTreino,
    String? descricao,
    String? dificuldade,
    String status = 'ativo',
  }) async {
    try {
      final body = {
        'nome_treino': nomeTreino,
        'tipo_treino': tipoTreino,
        if (descricao != null) 'descricao': descricao,
        if (dificuldade != null) 'dificuldade': dificuldade,
        'status': status,
      };

      if (kDebugMode) {
        print('📤 POST Treino: ${ApiConstants.getUrl(ApiConstants.treinoStore)}');
        print('📦 Body: $body');
      }

      final response = await http
          .post(
            Uri.parse(ApiConstants.getUrl(ApiConstants.treinoStore)),
            headers: _getAuthHeaders(),
            body: json.encode(body),
          )
          .timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);

      if (kDebugMode) {
        print('📥 Response Create: ${response.statusCode}');
      }

      if (ApiConstants.isSuccessStatusCode(response.statusCode)) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? ApiConstants.getErrorMessage(response.statusCode),
          'errors': data['errors'],
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro createTreino: $e');
      return {
        'success': false,
        'message': NetworkUtils.getErrorMessage(e),
      };
    }
  }

  /// Atualizar treino
  Future<Map<String, dynamic>> updateTreino({
    required int treinoId,
    String? nomeTreino,
    String? tipoTreino,
    String? descricao,
    String? dificuldade,
    String? status,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      if (nomeTreino != null) body['nome_treino'] = nomeTreino;
      if (tipoTreino != null) body['tipo_treino'] = tipoTreino;
      if (descricao != null) body['descricao'] = descricao;
      if (dificuldade != null) body['dificuldade'] = dificuldade;
      if (status != null) body['status'] = status;

      final url = ApiConstants.getTreinoUrl(treinoId);

      if (kDebugMode) {
        print('📤 PUT Treino: $url');
        print('📦 Body: $body');
      }

      final response = await http
          .put(
            Uri.parse(url),
            headers: _getAuthHeaders(),
            body: json.encode(body),
          )
          .timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);

      if (kDebugMode) {
        print('📥 Response Update: ${response.statusCode}');
      }

      if (ApiConstants.isSuccessStatusCode(response.statusCode)) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? ApiConstants.getErrorMessage(response.statusCode),
          'errors': data['errors'],
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro updateTreino: $e');
      return {
        'success': false,
        'message': NetworkUtils.getErrorMessage(e),
      };
    }
  }

  /// Deletar treino (soft delete)
  Future<Map<String, dynamic>> deleteTreino(int treinoId) async {
    try {
      final url = ApiConstants.getTreinoUrl(treinoId);

      if (kDebugMode) {
        print('📤 DELETE Treino: $url');
      }

      final response = await http
          .delete(Uri.parse(url), headers: _getAuthHeaders())
          .timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);

      if (kDebugMode) {
        print('📥 Response Delete: ${response.statusCode}');
      }

      if (ApiConstants.isSuccessStatusCode(response.statusCode)) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? ApiConstants.getErrorMessage(response.statusCode),
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro deleteTreino: $e');
      return {
        'success': false,
        'message': NetworkUtils.getErrorMessage(e),
      };
    }
  }

  /// Obter treinos por dificuldade
  Future<Map<String, dynamic>> getTreinosByDificuldade(String dificuldade) async {
    try {
      final url = ApiConstants.getTreinosByDificuldadeUrl(dificuldade);

      if (kDebugMode) {
        print('📤 GET Treinos por Dificuldade: $url');
      }

      final response = await http
          .get(Uri.parse(url), headers: _getAuthHeaders())
          .timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);

      if (kDebugMode) {
        print('📥 Response Treinos Dificuldade: ${response.statusCode}');
      }

      if (ApiConstants.isSuccessStatusCode(response.statusCode)) {
        return data;
      } else {
        return {
          'success': false,
          'message': data['message'] ?? ApiConstants.getErrorMessage(response.statusCode),
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro getTreinosByDificuldade: $e');
      return {
        'success': false,
        'message': NetworkUtils.getErrorMessage(e),
      };
    }
  }

  /// Verificar conectividade com a API
  Future<bool> checkApiConnectivity() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.getUrl(ApiConstants.apiStatus)))
          .timeout(ApiConstants.shortTimeout);

      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) print('❌ API não disponível: $e');
      return false;
    }
  }

  /// Verificar saúde da API
  Future<Map<String, dynamic>> checkApiHealth() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConstants.getUrl(ApiConstants.apiHealth)))
          .timeout(ApiConstants.shortTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'error',
          'message': 'API não disponível',
        };
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro checkApiHealth: $e');
      return {
        'status': 'error',
        'message': 'Erro de conexão',
      };
    }
  }
}

/// Utilitários de rede
class NetworkUtils {
  /// Obter mensagem de erro amigável
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Timeout: Verifique sua conexão';
    } else if (errorString.contains('socket')) {
      return 'Erro de conexão. Verifique sua internet';
    } else if (errorString.contains('certificate') || errorString.contains('ssl')) {
      return 'Erro de certificado SSL';
    } else if (errorString.contains('format')) {
      return 'Erro no formato dos dados';
    } else {
      return 'Erro de conexão. Tente novamente';
    }
  }
}