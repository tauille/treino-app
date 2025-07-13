import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';
import '../constants/api_constants.dart'; // ✅ MUDANÇA: ApiConstants com NetworkDetector

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
        
        // ✅ MUDANÇA: Usar detecção automática
        final baseUrl = await ApiConstants.getBaseUrl();
        print('📱 Base URL detectada: $baseUrl');
        print('📡 IP atual: ${ApiConstants.getCurrentIP()}');
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
      // ✅ MUDANÇA: Usar detecção automática
      final url = await ApiConstants.getUrl(ApiConstants.authVerifyToken);
      
      if (kDebugMode) {
        print('🔍 Verificando token em: $url');
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isValid = data['success'] == true;
        
        if (kDebugMode) {
          print('📊 Token válido: $isValid');
        }
        
        return isValid;
      }
      
      if (kDebugMode) {
        print('❌ Token inválido - Status: ${response.statusCode}');
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
      // ✅ MUDANÇA: Usar detecção automática
      final url = await ApiConstants.getUrl(ApiConstants.authMe);
      
      if (kDebugMode) {
        print('🔄 Atualizando dados do usuário: $url');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(ApiConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          _currentUser = UserModel.fromJson(data['data']['user']);
          await _saveUserData();
          
          if (kDebugMode) {
            print('✅ Dados do usuário atualizados: ${_currentUser?.name}');
          }
          
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
      // ✅ MUDANÇA: Usar detecção automática
      final url = await ApiConstants.getUrl(ApiConstants.authGoogle);
      
      if (kDebugMode) {
        print('📤 Enviando dados Google para Laravel...');
        print('📡 URL detectada: $url');
        print('📋 Dados: ${googleData.keys}');
      }
      
      final response = await http.post(
        Uri.parse(url),
        headers: ApiConstants.defaultHeaders,
        body: json.encode(googleData),
      ).timeout(ApiConstants.defaultTimeout);

      final data = json.decode(response.body);
      
      if (kDebugMode) {
        print('📊 Resposta Laravel: ${response.statusCode}');
        print('📥 Mensagem: ${data['message']}');
        print('✅ Sucesso: ${data['success']}');
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
      // ✅ MUDANÇA: Usar detecção automática
      final url = await ApiConstants.getUrl(ApiConstants.authLogout);
      
      if (kDebugMode) {
        print('🚪 Notificando logout ao Laravel: $url');
      }
      
      await http.post(
        Uri.parse(url),
        headers: _getAuthHeaders(),
      ).timeout(ApiConstants.shortTimeout);
      
      if (kDebugMode) {
        print('✅ Logout notificado ao servidor');
      }
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
      
      if (kDebugMode) {
        print('✅ Dados salvos com sucesso');
        print('👤 Usuário: ${_currentUser?.name} (${_currentUser?.email})');
        print('🔑 Token: ${_authToken?.substring(0, 20)}...');
      }
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
      
      if (kDebugMode) {
        print('📂 Dados carregados do storage:');
        print('   Token: ${_authToken != null ? 'Presente' : 'Ausente'}');
        print('   Usuário: ${_currentUser?.name ?? 'null'}');
      }
      
      // Verificar se token ainda é válido
      if (_authToken != null && _currentUser != null) {
        if (kDebugMode) print('🔍 Verificando validade do token...');
        
        final isValid = await verifyToken();
        if (!isValid) {
          if (kDebugMode) print('❌ Token inválido, limpando dados...');
          await _clearAuthData();
        } else {
          if (kDebugMode) print('✅ Token válido!');
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
    // ✅ MUDANÇA: Usar método do ApiConstants
    return ApiConstants.getAuthHeaders(_authToken ?? '');
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

  /// Teste de conectividade
  Future<bool> testConnection() async {
    try {
      // ✅ MUDANÇA: Usar detecção automática
      return await ApiConstants.testCurrentAPI();
    } catch (e) {
      if (kDebugMode) print('❌ Erro no teste de conectividade: $e');
      return false;
    }
  }

  /// Debug: Imprimir informações de rede
  Future<void> printNetworkDebug() async {
    try {
      if (kDebugMode) {
        print('🌐 === DEBUG REDE GOOGLE AUTH ===');
        final baseUrl = await ApiConstants.getBaseUrl();
        print('📡 Base URL: $baseUrl');
        print('📍 IP atual: ${ApiConstants.getCurrentIP()}');
        print('📋 Info rede: ${ApiConstants.getNetworkInfo()}');
        print('🧪 Conectividade: ${await testConnection()}');
        print('================================');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro no debug de rede: $e');
    }
  }
}