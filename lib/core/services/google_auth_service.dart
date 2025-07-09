import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../../config/api_config.dart'; // ✅ MUDANÇA: ApiConfig em vez de ApiConstants

/// Serviço de autenticação Google + Laravel
class GoogleAuthService {
  // ===== CONFIGURAÇÕES =====
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // ===== CHAVES DE STORAGE =====
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _googleTokenKey = 'google_token';
  
  // ===== SINGLETON =====
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  // ===== ESTADO =====
  GoogleSignIn? _googleSignIn;
  UserModel? _currentUser;
  String? _authToken;
  
  // ===== GETTERS =====
  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null && _authToken != null;
  String? get authToken => _authToken;

  /// Inicializar Google Sign In
  Future<void> initialize() async {
    try {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        // TODO: Adicionar serverClientId do Google Cloud Console após configuração
        // serverClientId: 'SEU_CLIENT_ID_AQUI.apps.googleusercontent.com',
      );

      // Verificar se já está logado
      await _loadStoredAuth();
      
      if (kDebugMode) {
        print('✅ GoogleAuthService inicializado');
        print('📱 Base URL: ${ApiConfig.baseUrl}'); // ✅ MUDANÇA: ApiConfig
        print('🔐 Token armazenado: ${_authToken != null}');
        print('👤 Usuário carregado: ${_currentUser?.name}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao inicializar GoogleAuthService: $e');
    }
  }

  /// Fazer login com Google
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (_googleSignIn == null) {
        await initialize();
      }

      // 1. GOOGLE SIGN IN
      final GoogleSignInAccount? googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Login cancelado pelo usuário'};
      }

      // 2. OBTER TOKENS GOOGLE
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null) {
        return {'success': false, 'message': 'Erro ao obter token do Google'};
      }

      // 3. ENVIAR PARA LARAVEL
      final response = await _sendGoogleAuthToLaravel({
        'access_token': googleAuth.accessToken!,
        'google_id': googleUser.id,
        'name': googleUser.displayName ?? '',
        'email': googleUser.email,
        'avatar_url': googleUser.photoUrl,
        'id_token': googleAuth.idToken,
      });

      if (response['success']) {
        // 4. SALVAR DADOS
        await _saveAuthData(response['data']);
        
        return {
          'success': true,
          'message': response['message'],
          'user': _currentUser,
          'isNewUser': _isNewUser(response['data']),
        };
      } else {
        // Login falhou - fazer logout do Google
        await _googleSignIn!.signOut();
        return response;
      }

    } catch (e) {
      if (kDebugMode) print('❌ Erro no login Google: $e');
      
      // Limpar estado em caso de erro
      await _googleSignIn?.signOut();
      
      return {
        'success': false,
        'message': 'Erro interno. Tente novamente.',
        'error': e.toString(),
      };
    }
  }

  /// Fazer logout
  Future<void> signOut() async {
    try {
      // 1. LOGOUT DO GOOGLE
      await _googleSignIn?.signOut();
      
      // 2. NOTIFICAR LARAVEL
      if (_authToken != null) {
        await _notifyLaravelLogout();
      }
      
      // 3. LIMPAR STORAGE
      await _clearAuthData();
      
      if (kDebugMode) print('✅ Logout realizado com sucesso');
      
    } catch (e) {
      if (kDebugMode) print('❌ Erro no logout: $e');
      // Mesmo com erro, limpar dados locais
      await _clearAuthData();
    }
  }

  /// Verificar se token ainda é válido
  Future<bool> verifyToken() async {
    if (_authToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl('/auth/verify-token')), // ✅ MUDANÇA: ApiConfig.buildUrl
        headers: _getAuthHeaders(),
      ).timeout(ApiConfig.defaultTimeout); // ✅ MUDANÇA: timeout configurável

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao verificar token: $e');
      return false;
    }
  }

  /// Atualizar dados do usuário
  Future<Map<String, dynamic>> refreshUserData() async {
    if (_authToken == null) {
      return {'success': false, 'message': 'Token não encontrado'};
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.buildUrl('/auth/me')), // ✅ MUDANÇA: ApiConfig.buildUrl
        headers: _getAuthHeaders(),
      ).timeout(ApiConfig.defaultTimeout); // ✅ MUDANÇA: timeout configurável

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _currentUser = UserModel.fromJson(data['data']['user']);
          await _saveUserData();
          return {'success': true, 'user': _currentUser};
        }
      }

      return {'success': false, 'message': 'Erro ao atualizar dados'};
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao atualizar usuário: $e');
      return {'success': false, 'message': 'Erro de conexão'};
    }
  }

  // ===== MÉTODOS PRIVADOS =====

  /// Enviar dados Google para Laravel
  Future<Map<String, dynamic>> _sendGoogleAuthToLaravel(Map<String, dynamic> googleData) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl('/auth/google')), // ✅ MUDANÇA: ApiConfig.buildUrl
        headers: ApiConfig.defaultHeaders, // ✅ MUDANÇA: headers configuráveis
        body: json.encode(googleData),
      ).timeout(ApiConfig.defaultTimeout); // ✅ MUDANÇA: timeout configurável

      final data = json.decode(response.body);
      
      if (kDebugMode) {
        print('📤 Enviando para Laravel: ${response.statusCode}');
        print('📡 URL: ${ApiConfig.buildUrl('/auth/google')}'); // ✅ DEBUG: mostrar URL
        print('📥 Resposta: ${data['message']}');
      }

      return data;
    } catch (e) {
      if (kDebugMode) print('❌ Erro na requisição Laravel: $e');
      return {
        'success': false,
        'message': 'Erro de conexão com servidor',
        'error': e.toString(),
      };
    }
  }

  /// Notificar logout ao Laravel
  Future<void> _notifyLaravelLogout() async {
    try {
      await http.post(
        Uri.parse(ApiConfig.buildUrl('/auth/logout')), // ✅ MUDANÇA: ApiConfig.buildUrl
        headers: _getAuthHeaders(),
      ).timeout(ApiConfig.shortTimeout); // ✅ MUDANÇA: timeout mais curto para logout
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao notificar logout: $e');
    }
  }

  /// Salvar dados de autenticação
  Future<void> _saveAuthData(Map<String, dynamic> authData) async {
    try {
      _authToken = authData['token'];
      _currentUser = UserModel.fromJson(authData['user']);
      
      // Salvar token de forma segura
      await _secureStorage.write(key: _tokenKey, value: _authToken);
      
      // Salvar dados do usuário
      await _saveUserData();
      
      if (kDebugMode) print('✅ Dados salvos com sucesso');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar dados: $e');
    }
  }

  /// Salvar dados do usuário
  Future<void> _saveUserData() async {
    if (_currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
    }
  }

  /// Carregar dados salvos
  Future<void> _loadStoredAuth() async {
    try {
      // Carregar token
      _authToken = await _secureStorage.read(key: _tokenKey);
      
      // Carregar dados do usuário
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        _currentUser = UserModel.fromJson(json.decode(userData));
      }
      
      // Verificar se token ainda é válido
      if (_authToken != null && _currentUser != null) {
        final isValid = await verifyToken();
        if (!isValid) {
          await _clearAuthData();
        }
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao carregar dados: $e');
      await _clearAuthData();
    }
  }

  /// Limpar todos os dados de autenticação
  Future<void> _clearAuthData() async {
    try {
      _currentUser = null;
      _authToken = null;
      
      await _secureStorage.deleteAll();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      
      if (kDebugMode) print('🗑️ Dados do usuário limpos');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao limpar dados: $e');
    }
  }

  /// Obter headers de autenticação
  Map<String, String> _getAuthHeaders() {
    return ApiConfig.getAuthHeaders(_authToken ?? ''); // ✅ MUDANÇA: usar método do ApiConfig
  }

  /// Verificar se é usuário novo
  bool _isNewUser(Map<String, dynamic> data) {
    // Verificar se a conta foi criada recentemente (últimos 10 segundos)
    if (data['user']['created_at'] != null) {
      final createdAt = DateTime.parse(data['user']['created_at']);
      final now = DateTime.now();
      final difference = now.difference(createdAt).inSeconds;
      return difference < 10;
    }
    return false;
  }
}