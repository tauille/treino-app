import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Serviço para gerenciar armazenamento local seguro e comum
class StorageService {
  // ===== SINGLETON =====
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // ===== INSTÂNCIAS =====
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  SharedPreferences? _prefs;

  // ===== CHAVES DE ARMAZENAMENTO =====
  
  // Secure Storage (dados sensíveis)
  static const String _authTokenKey = 'auth_token';
  static const String _googleTokenKey = 'google_token';
  static const String _biometricKey = 'biometric_enabled';
  
  // SharedPreferences (dados comuns)
  static const String _userDataKey = 'user_data';
  static const String _appSettingsKey = 'app_settings';
  static const String _cacheDataKey = 'cache_data';
  static const String _onboardingKey = 'onboarding_completed';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _notificationsKey = 'notifications_enabled';

  /// Inicializar SharedPreferences
  Future<void> init() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      if (kDebugMode) print('✅ StorageService inicializado');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao inicializar StorageService: $e');
    }
  }

  /// Garantir que SharedPreferences está inicializado
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ===== SECURE STORAGE (dados sensíveis) =====

  /// Salvar token de autenticação
  Future<bool> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _authTokenKey, value: token);
      if (kDebugMode) print('✅ Token de auth salvo');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar token: $e');
      return false;
    }
  }

  /// Obter token de autenticação
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _authTokenKey);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler token: $e');
      return null;
    }
  }

  /// Remover token de autenticação
  Future<bool> removeAuthToken() async {
    try {
      await _secureStorage.delete(key: _authTokenKey);
      if (kDebugMode) print('🗑️ Token de auth removido');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao remover token: $e');
      return false;
    }
  }

  /// Salvar token do Google
  Future<bool> saveGoogleToken(String token) async {
    try {
      await _secureStorage.write(key: _googleTokenKey, value: token);
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar Google token: $e');
      return false;
    }
  }

  /// Obter token do Google
  Future<String?> getGoogleToken() async {
    try {
      return await _secureStorage.read(key: _googleTokenKey);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler Google token: $e');
      return null;
    }
  }

  /// Verificar se biometria está habilitada
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricKey);
      return value == 'true';
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler biometria: $e');
      return false;
    }
  }

  /// Definir status da biometria
  Future<bool> setBiometricEnabled(bool enabled) async {
    try {
      await _secureStorage.write(key: _biometricKey, value: enabled.toString());
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar biometria: $e');
      return false;
    }
  }

  /// Limpar todos os dados seguros
  Future<bool> clearSecureStorage() async {
    try {
      await _secureStorage.deleteAll();
      if (kDebugMode) print('🗑️ Secure storage limpo');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao limpar secure storage: $e');
      return false;
    }
  }

  // ===== SHARED PREFERENCES (dados comuns) =====

  /// Salvar dados do usuário
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = json.encode(userData);
      final result = await prefs.setString(_userDataKey, jsonString);
      if (kDebugMode) print('✅ Dados do usuário salvos');
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar dados do usuário: $e');
      return false;
    }
  }

  /// Obter dados do usuário
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_userDataKey);
      if (jsonString != null) {
        return json.decode(jsonString);
      }
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler dados do usuário: $e');
      return null;
    }
  }

  /// Remover dados do usuário
  Future<bool> removeUserData() async {
    try {
      final prefs = await _getPrefs();
      final result = await prefs.remove(_userDataKey);
      if (kDebugMode) print('🗑️ Dados do usuário removidos');
      return result;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao remover dados do usuário: $e');
      return false;
    }
  }

  /// Salvar configurações do app
  Future<bool> saveAppSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = json.encode(settings);
      return await prefs.setString(_appSettingsKey, jsonString);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar configurações: $e');
      return false;
    }
  }

  /// Obter configurações do app
  Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_appSettingsKey);
      if (jsonString != null) {
        return json.decode(jsonString);
      }
      return _getDefaultSettings();
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler configurações: $e');
      return _getDefaultSettings();
    }
  }

  /// Configurações padrão
  Map<String, dynamic> _getDefaultSettings() {
    return {
      'theme_mode': 'system',
      'language': 'pt',
      'notifications_enabled': true,
      'sound_enabled': true,
      'vibration_enabled': true,
      'auto_backup': true,
    };
  }

  /// Definir se onboarding foi completado
  Future<bool> setOnboardingCompleted(bool completed) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(_onboardingKey, completed);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar onboarding: $e');
      return false;
    }
  }

  /// Verificar se onboarding foi completado
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler onboarding: $e');
      return false;
    }
  }

  /// Salvar modo do tema
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setString(_themeKey, themeMode);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar tema: $e');
      return false;
    }
  }

  /// Obter modo do tema
  Future<String> getThemeMode() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_themeKey) ?? 'system';
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler tema: $e');
      return 'system';
    }
  }

  /// Salvar idioma
  Future<bool> saveLanguage(String language) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setString(_languageKey, language);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar idioma: $e');
      return false;
    }
  }

  /// Obter idioma
  Future<String> getLanguage() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getString(_languageKey) ?? 'pt';
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler idioma: $e');
      return 'pt';
    }
  }

  /// Definir notificações habilitadas
  Future<bool> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(_notificationsKey, enabled);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar notificações: $e');
      return false;
    }
  }

  /// Verificar se notificações estão habilitadas
  Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(_notificationsKey) ?? true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler notificações: $e');
      return true;
    }
  }

  // ===== CACHE =====

  /// Salvar dados em cache
  Future<bool> saveCache(String key, Map<String, dynamic> data, {Duration? expiry}) async {
    try {
      final prefs = await _getPrefs();
      
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': expiry != null 
            ? DateTime.now().add(expiry).millisecondsSinceEpoch 
            : null,
      };
      
      final jsonString = json.encode(cacheData);
      return await prefs.setString('${_cacheDataKey}_$key', jsonString);
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar cache: $e');
      return false;
    }
  }

  /// Obter dados do cache
  Future<Map<String, dynamic>?> getCache(String key) async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString('${_cacheDataKey}_$key');
      
      if (jsonString != null) {
        final cacheData = json.decode(jsonString);
        
        // Verificar se cache expirou
        if (cacheData['expiry'] != null) {
          final expiry = DateTime.fromMillisecondsSinceEpoch(cacheData['expiry']);
          if (DateTime.now().isAfter(expiry)) {
            // Cache expirado - remover
            await removeCache(key);
            return null;
          }
        }
        
        return cacheData['data'];
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ler cache: $e');
      return null;
    }
  }

  /// Remover cache específico
  Future<bool> removeCache(String key) async {
    try {
      final prefs = await _getPrefs();
      return await prefs.remove('${_cacheDataKey}_$key');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao remover cache: $e');
      return false;
    }
  }

  /// Limpar todo o cache
  Future<bool> clearCache() async {
    try {
      final prefs = await _getPrefs();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cacheDataKey));
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      if (kDebugMode) print('🗑️ Cache limpo');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao limpar cache: $e');
      return false;
    }
  }

  // ===== LIMPEZA GERAL =====

  /// Limpar todos os dados
  Future<bool> clearAllData() async {
    try {
      await clearSecureStorage();
      final prefs = await _getPrefs();
      await prefs.clear();
      if (kDebugMode) print('🗑️ Todos os dados limpos');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao limpar todos os dados: $e');
      return false;
    }
  }

  /// Limpar dados do usuário (manter configurações)
  Future<bool> clearUserData() async {
    try {
      await clearSecureStorage();
      await removeUserData();
      await clearCache();
      if (kDebugMode) print('🗑️ Dados do usuário limpos');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao limpar dados do usuário: $e');
      return false;
    }
  }
}