import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../models/api_response_model.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class AuthService {
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final StorageService _storage = StorageService();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Login do usuário
  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final baseUrl = await ApiConstants.getBaseUrl();
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data']['user'];
          final token = data['data']['token'];
          
          final user = User.fromJson(userData);
          
          // Salvar dados
          await _saveToken(token);
          await _saveUser(user);
          
          return ApiResponse.success(
            data: user,
            message: data['message'] ?? 'Login realizado com sucesso',
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            message: data['message'] ?? 'Erro nos dados da resposta',
            statusCode: response.statusCode,
          );
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return ApiResponse.error(
          message: data['message'] ?? 'Credenciais inválidas',
          errors: data['errors'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: 'Erro no servidor (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
        statusCode: null,
      );
    }
  }

  /// Registro de novo usuário
  Future<ApiResponse<User>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final baseUrl = await ApiConstants.getBaseUrl();
      
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data']['user'];
          final token = data['data']['token'];
          
          final user = User.fromJson(userData);
          
          // Salvar dados
          await _saveToken(token);
          await _saveUser(user);
          
          return ApiResponse.success(
            data: user,
            message: data['message'] ?? 'Conta criada com sucesso',
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse.error(
            message: data['message'] ?? 'Erro nos dados da resposta',
            statusCode: response.statusCode,
          );
        }
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return ApiResponse.error(
          message: data['message'] ?? 'Dados inválidos',
          errors: data['errors'],
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          message: 'Erro no servidor (${response.statusCode})',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
        statusCode: null,
      );
    }
  }

  /// Logout do usuário
  Future<ApiResponse<void>> logout() async {
    try {
      final token = await _getToken();
      
      if (token != null) {
        // Tentar fazer logout no servidor
        try {
          final baseUrl = await ApiConstants.getBaseUrl();
          
          await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              ...headers,
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          // Continuar com logout local mesmo se servidor falhar
        }
      }
      
      // Limpar dados locais
      await _clearAuthData();
      
      return ApiResponse.success(
        message: 'Logout realizado com sucesso',
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro no logout: $e',
      );
    }
  }

  /// Verificar se usuário está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final token = await _getToken();
      final user = await _getUser();
      return token != null && user != null;
    } catch (e) {
      return false;
    }
  }

  /// Obter usuário atual
  Future<User?> getCurrentUser() async {
    try {
      return await _getUser();
    } catch (e) {
      return null;
    }
  }

  /// Obter token atual
  Future<String?> getCurrentToken() async {
    try {
      return await _getToken();
    } catch (e) {
      return null;
    }
  }

  Future<String?> _getToken() async {
    try {
      await _storage.init();
      return await _storage.getAuthToken();
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      await _storage.init();
      await _storage.saveAuthToken(token);
    } catch (e) {
      throw Exception('Erro ao salvar credenciais');
    }
  }

  Future<User?> _getUser() async {
    try {
      await _storage.init();
      final userData = await _storage.getUserData();
      
      if (userData == null) return null;
      
      return User.fromStorageData(userData);
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveUser(User user) async {
    try {
      await _storage.init();
      
      await _storage.saveUserData({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'is_premium': user.isPremium,
        'trial_started_at': user.trialStartedAt?.toIso8601String(),
        'premium_expires_at': user.premiumExpiresAt?.toIso8601String(),
        'is_email_verified': user.isEmailVerified,
        'email_verified_at': user.emailVerifiedAt?.toIso8601String(),
        'created_at': user.createdAt?.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao salvar dados do usuário');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _storage.init();
      await _storage.clearUserData();
    } catch (e) {
      // Ignorar erros na limpeza
    }
  }

  /// Testar conectividade com a API
  Future<bool> testConnection() async {
    try {
      return await ApiConstants.testCurrentAPI();
    } catch (e) {
      return false;
    }
  }
}