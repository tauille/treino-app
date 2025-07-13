// lib/core/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/user_model.dart';
import '../../models/api_response_model.dart';
import '../constants/api_constants.dart';  // ✅ USAR API CONSTANTS
import 'storage_service.dart';

class AuthService {
  // ✅ REMOVER IP FIXO - Usar detecção automática
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Instância do storage
  final StorageService _storage = StorageService();

  // Chaves para armazenamento
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // ========================================
  // MÉTODOS DE AUTENTICAÇÃO
  // ========================================

  /// Login do usuário
  Future<ApiResponse<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Tentando fazer login...');
      
      // ✅ USAR DETECÇÃO AUTOMÁTICA
      final baseUrl = await ApiConstants.getBaseUrl();
      print('📡 URL detectada para login: $baseUrl');
      
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15));

      print('📊 Status da resposta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data']['user'];
          final token = data['data']['token'];
          
          final user = User.fromJson(userData);
          
          // Salvar dados
          await _saveToken(token);
          await _saveUser(user);
          
          print('✅ Login bem-sucedido: ${user.name}');
          
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
      print('❌ Erro no login: $e');
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
      print('👤 Tentando registrar usuário...');
      
      // ✅ USAR DETECÇÃO AUTOMÁTICA
      final baseUrl = await ApiConstants.getBaseUrl();
      print('📡 URL detectada para registro: $baseUrl');
      
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

      print('📊 Status da resposta: ${response.statusCode}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data']['user'];
          final token = data['data']['token'];
          
          final user = User.fromJson(userData);
          
          // Salvar dados
          await _saveToken(token);
          await _saveUser(user);
          
          print('✅ Registro bem-sucedido: ${user.name}');
          
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
      print('❌ Erro no registro: $e');
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
        statusCode: null,
      );
    }
  }

  /// Logout do usuário
  Future<ApiResponse<void>> logout() async {
    try {
      print('🚪 Fazendo logout...');
      
      final token = await _getToken();
      
      if (token != null) {
        // Tentar fazer logout no servidor
        try {
          // ✅ USAR DETECÇÃO AUTOMÁTICA
          final baseUrl = await ApiConstants.getBaseUrl();
          
          await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              ...headers,
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));
        } catch (e) {
          print('⚠️ Erro ao notificar servidor sobre logout: $e');
          // Continuar com logout local mesmo se servidor falhar
        }
      }
      
      // Limpar dados locais
      await _clearAuthData();
      
      print('✅ Logout realizado');
      
      return ApiResponse.success(
        message: 'Logout realizado com sucesso',
      );
    } catch (e) {
      print('❌ Erro no logout: $e');
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
      print('❌ Erro ao verificar autenticação: $e');
      return false;
    }
  }

  /// Obter usuário atual
  Future<User?> getCurrentUser() async {
    try {
      return await _getUser();
    } catch (e) {
      print('❌ Erro ao obter usuário atual: $e');
      return null;
    }
  }

  /// Obter token atual
  Future<String?> getCurrentToken() async {
    try {
      return await _getToken();
    } catch (e) {
      print('❌ Erro ao obter token atual: $e');
      return null;
    }
  }

  // ========================================
  // MÉTODOS PRIVADOS DE ARMAZENAMENTO
  // ========================================

  Future<String?> _getToken() async {
    try {
      await _storage.init();
      return await _storage.getAuthToken();  // ✅ USAR MÉTODO CORRETO
    } catch (e) {
      print('❌ Erro ao buscar token: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    try {
      await _storage.init();
      await _storage.saveAuthToken(token);  // ✅ USAR MÉTODO CORRETO
    } catch (e) {
      print('❌ Erro ao salvar token: $e');
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
      print('❌ Erro ao buscar usuário: $e');
      return null;
    }
  }

  Future<void> _saveUser(User user) async {
    try {
      await _storage.init();
      
      // ✅ USAR MÉTODO CORRETO DO STORAGE
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
      print('❌ Erro ao salvar usuário: $e');
      throw Exception('Erro ao salvar dados do usuário');
    }
  }

  Future<void> _clearAuthData() async {
    try {
      await _storage.init();
      await _storage.clearUserData();  // ✅ USAR MÉTODO CORRETO
    } catch (e) {
      print('❌ Erro ao limpar dados de autenticação: $e');
    }
  }

  // ========================================
  // MÉTODOS DE TESTE
  // ========================================

  /// Testar conectividade com a API
  Future<bool> testConnection() async {
    try {
      print('🔍 Testando conexão com API...');
      
      // ✅ USAR DETECÇÃO AUTOMÁTICA
      return await ApiConstants.testCurrentAPI();
    } catch (e) {
      print('❌ Erro de conexão: $e');
      return false;
    }
  }

  /// Debug: Imprimir informações de autenticação
  Future<void> printAuthDebug() async {
    try {
      final token = await _getToken();
      final user = await _getUser();
      final isAuth = await isAuthenticated();
      
      print('🔍 Auth Debug Info:');
      print('   Token: ${token != null ? 'Presente (${token.length} chars)' : 'Ausente'}');
      print('   User: ${user?.name ?? 'null'} (${user?.email ?? 'no email'})');
      print('   Authenticated: $isAuth');
      print('   Premium: ${user?.isPremium ?? false}');
      print('   Current IP: ${ApiConstants.getCurrentIP()}');
      print('   Base URL: ${await ApiConstants.getBaseUrl()}');
    } catch (e) {
      print('❌ Erro ao imprimir debug de auth: $e');
    }
  }
}