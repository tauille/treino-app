// lib/core/services/storage_service.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Secure Storage com configuração mais compatível
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'treino_app_secure_prefs',
      preferencesKeyPrefix: 'ta_',
      // Removido configurações que podem causar incompatibilidade
    ),
    iOptions: IOSOptions(
      groupId: 'group.treino.app',
      accountName: 'treino_app_account',
      synchronizable: true,
      // Configurações mais conservadoras para compatibilidade
    ),
  );

  // SharedPreferences para dados não sensíveis (configurações, preferências)
  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // ========================================
  // INICIALIZAÇÃO MELHORADA
  // ========================================
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      print('🔄 Inicializando StorageService...');
      
      // Inicializar SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      
      // Testar SecureStorage com fallback
      await _testSecureStorage();
      
      _isInitialized = true;
      print('💾 StorageService inicializado com sucesso!');
    } catch (e) {
      print('❌ Erro ao inicializar StorageService: $e');
      // Tentar inicializar só o SharedPreferences em caso de falha
      try {
        _prefs ??= await SharedPreferences.getInstance();
        _isInitialized = true;
        print('⚠️ StorageService inicializado apenas com SharedPreferences');
      } catch (e2) {
        print('❌ Falha total na inicialização: $e2');
        rethrow;
      }
    }
  }

  Future<void> _testSecureStorage() async {
    try {
      // Teste simples de leitura/escrita
      await _secureStorage.write(key: 'test_init', value: 'ok');
      final testValue = await _secureStorage.read(key: 'test_init');
      await _secureStorage.delete(key: 'test_init');
      
      if (testValue != 'ok') {
        throw Exception('SecureStorage test failed');
      }
      
      print('✅ SecureStorage funcionando');
    } catch (e) {
      print('⚠️ SecureStorage pode não estar funcionando: $e');
      // Não relançar o erro, apenas logar
    }
  }

  // ========================================
  // CHAVES DE ARMAZENAMENTO
  // ========================================
  
  // Secure Storage - dados sensíveis
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _encryptedSettingsKey = 'encrypted_settings';
  
  // SharedPreferences - dados não sensíveis
  static const String _appThemeKey = 'app_theme';
  static const String _languageKey = 'app_language';
  static const String _onboardingCompletedKey = 'onboarding_completed';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _lastAppVersionKey = 'last_app_version';
  static const String _appLaunchCountKey = 'app_launch_count';
  static const String _lastSyncTimeKey = 'last_sync_time';

  // ========================================
  // TOKEN DE AUTENTICAÇÃO (Secure Storage com Fallback)
  // ========================================
  
  Future<void> saveToken(String token) async {
    try {
      await ensureInitialized();
      await _secureStorage.write(key: _tokenKey, value: token);
      print('🔑 Token salvo com segurança');
    } catch (e) {
      print('❌ Erro ao salvar token no SecureStorage: $e');
      
      // Fallback: salvar no SharedPreferences (menos seguro mas funcional)
      try {
        await ensurePrefsInitialized();
        await _prefs!.setString(_tokenKey, token);
        print('🔑 Token salvo no SharedPreferences (fallback)');
      } catch (e2) {
        print('❌ Erro no fallback para token: $e2');
        throw Exception('Erro ao salvar credenciais');
      }
    }
  }

  Future<String?> getToken() async {
    try {
      await ensureInitialized();
      
      // Tentar SecureStorage primeiro
      final token = await _secureStorage.read(key: _tokenKey);
      if (token != null) {
        print('🔑 Token encontrado no SecureStorage');
        return token;
      }
      
      // Fallback: verificar SharedPreferences
      await ensurePrefsInitialized();
      final fallbackToken = _prefs!.getString(_tokenKey);
      if (fallbackToken != null) {
        print('🔑 Token encontrado no SharedPreferences (fallback)');
        return fallbackToken;
      }
      
      print('🔑 Token não encontrado');
      return null;
    } catch (e) {
      print('❌ Erro ao buscar token: $e');
      return null;
    }
  }

  Future<void> clearToken() async {
    try {
      await ensureInitialized();
      
      // Limpar dos dois lugares
      await _secureStorage.delete(key: _tokenKey);
      await ensurePrefsInitialized();
      await _prefs!.remove(_tokenKey);
      
      print('🗑️ Token removido de todos os locais');
    } catch (e) {
      print('❌ Erro ao remover token: $e');
    }
  }

  // Refresh Token
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await ensureInitialized();
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
      print('🔄 Refresh token salvo');
    } catch (e) {
      print('❌ Erro ao salvar refresh token: $e');
      // Fallback para SharedPreferences
      try {
        await ensurePrefsInitialized();
        await _prefs!.setString(_refreshTokenKey, refreshToken);
        print('🔄 Refresh token salvo (fallback)');
      } catch (e2) {
        print('❌ Erro no fallback refresh token: $e2');
      }
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      await ensureInitialized();
      
      // Tentar SecureStorage primeiro
      final token = await _secureStorage.read(key: _refreshTokenKey);
      if (token != null) return token;
      
      // Fallback: SharedPreferences
      await ensurePrefsInitialized();
      return _prefs!.getString(_refreshTokenKey);
    } catch (e) {
      print('❌ Erro ao buscar refresh token: $e');
      return null;
    }
  }

  Future<void> clearRefreshToken() async {
    try {
      await ensureInitialized();
      await _secureStorage.delete(key: _refreshTokenKey);
      await ensurePrefsInitialized();
      await _prefs!.remove(_refreshTokenKey);
    } catch (e) {
      print('❌ Erro ao remover refresh token: $e');
    }
  }

  // ========================================
  // DADOS DO USUÁRIO (Secure Storage com Fallback)
  // ========================================
  
  Future<void> saveUserData({
    required int userId,
    required String userName,
    required String userEmail,
    required bool isPremium,
    DateTime? trialStartedAt,
    DateTime? premiumExpiresAt,
    bool? isEmailVerified,
    DateTime? emailVerifiedAt,
    DateTime? createdAt,
  }) async {
    try {
      await ensureInitialized();
      
      final userData = {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'isPremium': isPremium,
        'trialStartedAt': trialStartedAt?.toIso8601String(),
        'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
        'isEmailVerified': isEmailVerified ?? false,
        'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
        'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'lastLogin': DateTime.now().toIso8601String(),
      };
      
      final userDataJson = jsonEncode(userData);
      
      try {
        await _secureStorage.write(key: _userDataKey, value: userDataJson);
        print('👤 Dados do usuário salvos no SecureStorage');
      } catch (e) {
        print('⚠️ Fallback: salvando dados no SharedPreferences');
        await ensurePrefsInitialized();
        await _prefs!.setString(_userDataKey, userDataJson);
        print('👤 Dados do usuário salvos no SharedPreferences (fallback)');
      }
      
    } catch (e) {
      print('❌ Erro ao salvar dados do usuário: $e');
      throw Exception('Erro ao salvar dados do usuário');
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    try {
      await ensureInitialized();
      
      // Tentar SecureStorage primeiro
      String? userDataJson = await _secureStorage.read(key: _userDataKey);
      
      // Fallback: SharedPreferences
      if (userDataJson == null) {
        await ensurePrefsInitialized();
        userDataJson = _prefs!.getString(_userDataKey);
      }
      
      if (userDataJson == null) return null;

      final userData = jsonDecode(userDataJson) as Map<String, dynamic>;
      print('👤 Dados do usuário recuperados');
      return userData;
    } catch (e) {
      print('❌ Erro ao buscar dados do usuário: $e');
      return null;
    }
  }

  Future<void> clearUserData() async {
    try {
      await ensureInitialized();
      
      // Limpar dos dois lugares
      await _secureStorage.delete(key: _userDataKey);
      await ensurePrefsInitialized();
      await _prefs!.remove(_userDataKey);
      
      print('🗑️ Dados do usuário removidos');
    } catch (e) {
      print('❌ Erro ao remover dados do usuário: $e');
    }
  }

  // ========================================
  // CONFIGURAÇÕES DO APP (SharedPreferences)
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

  Future<void> saveLanguage(String language) async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.setString(_languageKey, language);
      print('🌐 Idioma salvo: $language');
    } catch (e) {
      print('❌ Erro ao salvar idioma: $e');
    }
  }

  Future<String?> getLanguage() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getString(_languageKey);
    } catch (e) {
      print('❌ Erro ao buscar idioma: $e');
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

  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.setBool(_notificationsEnabledKey, enabled);
      print('🔔 Notificações ${enabled ? 'habilitadas' : 'desabilitadas'}');
    } catch (e) {
      print('❌ Erro ao salvar configuração de notificações: $e');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      print('❌ Erro ao verificar notificações: $e');
      return true;
    }
  }

  // ========================================
  // DADOS DE APLICAÇÃO (SharedPreferences)
  // ========================================
  
  Future<void> saveAppVersion(String version) async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.setString(_lastAppVersionKey, version);
    } catch (e) {
      print('❌ Erro ao salvar versão do app: $e');
    }
  }

  Future<String?> getLastAppVersion() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getString(_lastAppVersionKey);
    } catch (e) {
      print('❌ Erro ao buscar versão do app: $e');
      return null;
    }
  }

  Future<void> incrementLaunchCount() async {
    try {
      await ensurePrefsInitialized();
      final currentCount = _prefs!.getInt(_appLaunchCountKey) ?? 0;
      await _prefs!.setInt(_appLaunchCountKey, currentCount + 1);
    } catch (e) {
      print('❌ Erro ao incrementar contador de inicializações: $e');
    }
  }

  Future<int> getLaunchCount() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getInt(_appLaunchCountKey) ?? 0;
    } catch (e) {
      print('❌ Erro ao buscar contador de inicializações: $e');
      return 0;
    }
  }

  Future<void> saveLastSyncTime() async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.setString(_lastSyncTimeKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('❌ Erro ao salvar tempo de sincronização: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      await ensurePrefsInitialized();
      final timeString = _prefs!.getString(_lastSyncTimeKey);
      return timeString != null ? DateTime.parse(timeString) : null;
    } catch (e) {
      print('❌ Erro ao buscar tempo de sincronização: $e');
      return null;
    }
  }

  // ========================================
  // DADOS SENSÍVEIS PERSONALIZADOS (Secure Storage com Fallback)
  // ========================================
  
  Future<void> saveSecureData(String key, dynamic value) async {
    try {
      await ensureInitialized();
      
      String jsonValue;
      if (value is String) {
        jsonValue = value;
      } else {
        jsonValue = jsonEncode(value);
      }
      
      try {
        await _secureStorage.write(key: key, value: jsonValue);
        print('🔐 Dados sensíveis salvos para chave: $key');
      } catch (e) {
        print('⚠️ Fallback: salvando no SharedPreferences');
        await ensurePrefsInitialized();
        await _prefs!.setString('secure_$key', jsonValue);
        print('🔐 Dados salvos (fallback) para chave: $key');
      }
    } catch (e) {
      print('❌ Erro ao salvar dados sensíveis para chave $key: $e');
      throw Exception('Erro ao salvar dados sensíveis');
    }
  }

  Future<T?> getSecureData<T>(String key, {bool isJson = true}) async {
    try {
      await ensureInitialized();
      
      // Tentar SecureStorage primeiro
      String? value = await _secureStorage.read(key: key);
      
      // Fallback: SharedPreferences
      if (value == null) {
        await ensurePrefsInitialized();
        value = _prefs!.getString('secure_$key');
      }
      
      if (value == null) return null;

      if (isJson && T != String) {
        return jsonDecode(value) as T;
      }
      return value as T;
    } catch (e) {
      print('❌ Erro ao buscar dados sensíveis para chave $key: $e');
      return null;
    }
  }

  Future<void> removeSecureData(String key) async {
    try {
      await ensureInitialized();
      
      // Remover dos dois lugares
      await _secureStorage.delete(key: key);
      await ensurePrefsInitialized();
      await _prefs!.remove('secure_$key');
      
      print('🗑️ Dados sensíveis removidos para chave: $key');
    } catch (e) {
      print('❌ Erro ao remover dados sensíveis para chave $key: $e');
    }
  }

  // ========================================
  // MÉTODOS DE LIMPEZA
  // ========================================
  
  /// Limpa TODOS os dados armazenados
  Future<void> clearAll() async {
    try {
      await ensureInitialized();
      
      // Limpar secure storage
      try {
        await _secureStorage.deleteAll();
      } catch (e) {
        print('⚠️ Erro ao limpar SecureStorage: $e');
      }
      
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
      await clearRefreshToken();
      await clearUserData();
      print('🔐 Dados de autenticação limpos');
    } catch (e) {
      print('❌ Erro ao limpar dados de autenticação: $e');
    }
  }

  /// Limpa apenas configurações do app
  Future<void> clearAppSettings() async {
    try {
      await ensurePrefsInitialized();
      await _prefs!.remove(_appThemeKey);
      await _prefs!.remove(_languageKey);
      await _prefs!.remove(_notificationsEnabledKey);
      print('⚙️ Configurações do app limpas');
    } catch (e) {
      print('❌ Erro ao limpar configurações: $e');
    }
  }

  // ========================================
  // MÉTODOS AUXILIARES MELHORADOS
  // ========================================
  
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> ensurePrefsInitialized() async {
    await ensureInitialized();
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
  }

  SharedPreferences? get prefs => _prefs;
  bool get isInitialized => _isInitialized;

  Future<bool> hasSecureKey(String key) async {
    try {
      await ensureInitialized();
      
      // Verificar SecureStorage
      final value = await _secureStorage.read(key: key);
      if (value != null) return true;
      
      // Verificar fallback
      await ensurePrefsInitialized();
      return _prefs!.containsKey('secure_$key');
    } catch (e) {
      print('❌ Erro ao verificar chave segura $key: $e');
      return false;
    }
  }

  Future<bool> hasPrefsKey(String key) async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.containsKey(key);
    } catch (e) {
      print('❌ Erro ao verificar chave $key: $e');
      return false;
    }
  }

  Future<Set<String>> getAllSecureKeys() async {
    try {
      await ensureInitialized();
      final allData = await _secureStorage.readAll();
      return allData.keys.toSet();
    } catch (e) {
      print('❌ Erro ao listar chaves seguras: $e');
      return <String>{};
    }
  }

  Future<Set<String>> getAllPrefsKeys() async {
    try {
      await ensurePrefsInitialized();
      return _prefs!.getKeys();
    } catch (e) {
      print('❌ Erro ao listar chaves do SharedPreferences: $e');
      return <String>{};
    }
  }

  // ========================================
  // MÉTODOS DE TESTE E DEBUG MELHORADOS
  // ========================================
  
  Future<bool> testStorage() async {
    try {
      print('🧪 Testando armazenamento híbrido com fallback...');
      
      await ensureInitialized();
      
      // Testar SharedPreferences
      await ensurePrefsInitialized();
      await _prefs!.setString('test_key', 'test_value');
      final testValue = _prefs!.getString('test_key');
      await _prefs!.remove('test_key');
      
      if (testValue != 'test_value') {
        throw Exception('SharedPreferences não funcionando');
      }
      print('✅ SharedPreferences funcionando');
      
      // Testar SecureStorage (com fallback)
      try {
        await _secureStorage.write(key: 'test_secure', value: 'secure_value');
        final secureValue = await _secureStorage.read(key: 'test_secure');
        await _secureStorage.delete(key: 'test_secure');
        
        if (secureValue != 'secure_value') {
          throw Exception('SecureStorage test value mismatch');
        }
        print('✅ SecureStorage funcionando');
      } catch (e) {
        print('⚠️ SecureStorage com problemas, testando fallback...');
        
        // Testar fallback
        await saveSecureData('test_fallback', {'test': 'fallback_value'});
        final fallbackValue = await getSecureData<Map<String, dynamic>>('test_fallback');
        await removeSecureData('test_fallback');
        
        if (fallbackValue?['test'] != 'fallback_value') {
          throw Exception('Fallback não funcionando');
        }
        print('✅ Sistema de fallback funcionando');
      }
      
      // Testar JSON no sistema híbrido
      final testJson = {'test': 'value', 'number': 42};
      await saveSecureData('test_json', testJson);
      final readJson = await getSecureData<Map<String, dynamic>>('test_json');
      await removeSecureData('test_json');
      
      if (readJson?['test'] != 'value' || readJson?['number'] != 42) {
        throw Exception('JSON no sistema híbrido não funcionando');
      }
      
      print('✅ Todos os testes de armazenamento passaram!');
      return true;
    } catch (e) {
      print('❌ Teste de armazenamento falhou: $e');
      return false;
    }
  }

  Future<void> printDebugInfo() async {
    try {
      await ensureInitialized();
      
      final hasToken = await getToken() != null;
      final hasRefreshToken = await getRefreshToken() != null;
      final userData = await getUserData();
      final theme = await getAppTheme();
      final language = await getLanguage();
      final onboardingCompleted = await isOnboardingCompleted();
      final notificationsEnabled = await areNotificationsEnabled();
      final launchCount = await getLaunchCount();
      final lastSync = await getLastSyncTime();
      final secureKeys = await getAllSecureKeys();
      final prefsKeys = await getAllPrefsKeys();

      print('📊 Storage Debug Info:');
      print('   Storage Type: Híbrido com Fallback (Secure + SharedPreferences)');
      print('   Is Initialized: $_isInitialized');
      print('   Has Token: $hasToken');
      print('   Has Refresh Token: $hasRefreshToken');
      print('   Has User Data: ${userData != null}');
      print('   User: ${userData?['userName']} (${userData?['userEmail']})');
      print('   Premium: ${userData?['isPremium']}');
      print('   Theme: $theme');
      print('   Language: $language');
      print('   Onboarding Completed: $onboardingCompleted');
      print('   Notifications Enabled: $notificationsEnabled');
      print('   Launch Count: $launchCount');
      print('   Last Sync: $lastSync');
      print('   Secure Keys: ${secureKeys.length} (${secureKeys.join(', ')})');
      print('   Prefs Keys: ${prefsKeys.length} (${prefsKeys.join(', ')})');
    } catch (e) {
      print('❌ Erro ao imprimir debug info: $e');
    }
  }
}