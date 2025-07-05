// lib/core/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Secure Storage para dados sensíveis (token)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // SharedPreferences para dados não sensíveis
  SharedPreferences? _prefs;

  // ========================================
  // INICIALIZAÇÃO
  // ========================================
  
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print('💾 StorageService inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar StorageService: $e');
    }
  }

  // ========================================
  // CHAVES DE ARMAZENAMENTO
  // ========================================
  
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _isPremiumKey = 'is_premium';
  static const String _lastLoginKey = 'last_login';
  static const String _appThemeKey = 'app_theme';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  // ========================================
  // TOKEN DE AUTENTICAÇÃO (Secure Storage)
  // ========================================
  
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
      print('🔑 Token salvo com segurança');
    } catch (e) {
      print('❌ Erro ao salvar token: $e');
      throw Exception('Erro ao salvar credenciais');
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      print('🔑 Token ${token != null ? 'encontrado' : 'não encontrado'}');
      return token;
    } catch (e) {
      print('❌ Erro ao buscar token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
      print('🗑️ Token removido');
    } catch (e) {
      print('❌ Erro ao remover token: $e');
    }
  }

  // ========================================
  // DADOS DO USUÁRIO (SharedPreferences)
  // ========================================
  
  Future<void> saveUserData({
    required int userId,
    required String userName,
    required String userEmail,
    required bool isPremium,
  }) async {
    try {
      await ensurePrefsInitialized();
      
      await _prefs!.setInt(_userIdKey, userId);
      await _prefs!.setString(_userNameKey, userName);
      await _prefs!.setString(_userEmailKey, userEmail);
      await _prefs!.setBool(_isPremiumKey, isPremium);
      await _prefs!.setString(_lastLoginKey, DateTime.now().toIso8601String());
      
      print('👤 Dados do usuário salvos');
    } catch (e) {
      print('❌ Erro ao salvar dados do usuário: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      await ensurePrefsInitialized();
      
      final userId = _prefs!.getInt(_userIdKey);
      if (userId == null) return null;

      return {
        'userId': userId,
        'userName': _prefs!.getString(_userNameKey),
        'userEmail': _prefs!.getString(_userEmailKey),
        'isPremium': _prefs!.getBool(_isPremiumKey) ?? false,
        'lastLogin': _prefs!.getString(_lastLoginKey),
      };
    } catch (e) {
      print('❌ Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  Future<void> clearUserData() async {
    try {
      await ensurePrefsInitialized();
      
      await _prefs!.remove(_userIdKey);
      await _prefs!.remove(_userNameKey);
      await _prefs!.remove(_userEmailKey);
      await _prefs!.remove(_isPremiumKey);
      await _prefs!.remove(_lastLoginKey);
      
      print('🗑️ Dados do usuário removidos');
    } catch (e) {
      print('❌ Erro ao remover dados do usuário: $e');
    }
  }

  // ========================================
  // CONFIGURAÇÕES DO APP
  // ========================================
  
  Future<void> saveAppTheme(String theme) async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.setString(_appThemeKey, theme);
      print('🎨 Tema salvo: $theme');
    } catch (e) {
      print('❌ Erro ao salvar tema: $e');
    }
  }

  Future<String?> getAppTheme() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getString(_appThemeKey);
    } catch (e) {
      print('❌ Erro ao buscar tema: $e');
      return null;
    }
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.setBool(_onboardingCompletedKey, completed);
      print('✅ Onboarding ${completed ? 'marcado como concluído' : 'resetado'}');
    } catch (e) {
      print('❌ Erro ao salvar status do onboarding: $e');
    }
  }

  Future<bool> isOnboardingCompleted() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      print('❌ Erro ao verificar onboarding: $e');
      return false;
    }
  }

  // ========================================
  // MÉTODOS DE LIMPEZA
  // ========================================
  
  /// Limpa TODOS os dados armazenados
  Future<void> clearAll() async {
    try {
      // Limpar secure storage
      await _secureStorage.deleteAll();
      
      // Limpar shared preferences
      await ensurePrefsInitialized();
      await _prefs!.clear();
      
      print('🧹 Todos os dados foram limpos');
    } catch (e) {
      print('❌ Erro ao limpar todos os dados: $e');
    }
  }

  /// Limpa apenas dados de autenticação
  Future<void> clearAuthData() async {
    try {
      await clearToken();
      await clearUserData();
      print('🔐 Dados de autenticação limpos');
    } catch (e) {
      print('❌ Erro ao limpar dados de autenticação: $e');
    }
  }

  // ========================================
  // MÉTODOS AUXILIARES PÚBLICOS
  // ========================================
  
  Future<void> ensurePrefsInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  // Getter público para SharedPreferences
  SharedPreferences? get prefs => _prefs;

  // ========================================
  // MÉTODOS DE TESTE
  // ========================================
  
  /// Testa se o armazenamento está funcionando
  Future<bool> testStorage() async {
    try {
      print('🧪 Testando armazenamento...');
      
      // Testar SharedPreferences
      await ensurePrefsInitialized();
      await _prefs!.setString('test_key', 'test_value');
      final testValue = _prefs!.getString('test_key');
      await _prefs!.remove('test_key');
      
      if (testValue != 'test_value') {
        throw Exception('SharedPreferences não funcionando');
      }
      
      // Testar SecureStorage
      await _secureStorage.write(key: 'test_secure', value: 'secure_value');
      final secureValue = await _secureStorage.read(key: 'test_secure');
      await _secureStorage.delete(key: 'test_secure');
      
      if (secureValue != 'secure_value') {
        throw Exception('SecureStorage não funcionando');
      }
      
      print('✅ Todos os testes de armazenamento passaram!');
      return true;
    } catch (e) {
      print('❌ Teste de armazenamento falhou: $e');
      return false;
    }
  }

  /// Imprime informações de debug
  Future<void> printDebugInfo() async {
    try {
      await ensurePrefsInitialized();
      
      final hasToken = await getToken() != null;
      final userData = await getUserData();
      final theme = await getAppTheme();
      final onboardingCompleted = await isOnboardingCompleted();

      print('📊 Storage Debug Info:');
      print('   Has Token: $hasToken');
      print('   Has User Data: ${userData != null}');
      print('   Theme: $theme');
      print('   Onboarding Completed: $onboardingCompleted');
      print('   Last Login: ${userData?['lastLogin']}');
    } catch (e) {
      print('❌ Erro ao imprimir debug info: $e');
    }
  }
}