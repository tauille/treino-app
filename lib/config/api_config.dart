import 'package:flutter/foundation.dart';
import 'dart:io';

/// Configurações centralizadas da API
class ApiConfig {
  // ===== AMBIENTE =====
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = kDebugMode;
  
  // ===== URLs BASE =====
  
  // Desenvolvimento Local
  static const String _devBaseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator ✅
  static const String _devBaseUrlIOS = 'http://127.0.0.1:8000/api'; // iOS Simulator ✅
  //static const String _devBaseUrlDevice = 'http://10.125.135.38:8000/api'; // IP da máquina
  static const String _devBaseUrlDevice = 'http://192.168.18.48:8000/api'; // IP da máquina
  
  // Homologação
  static const String _stagingBaseUrl = 'https://api-staging.treinoapp.com/api';
  
  // Produção
  static const String _productionBaseUrl = 'https://api.treinoapp.com/api';
  
  // ===== 🔧 VARIÁVEL PARA OVERRIDE MANUAL =====
  static String? _manualUrl;
  
  /// URL base atual baseada no ambiente E plataforma
  static String get baseUrl {
    // ✅ PRIORIDADE 1: URL manual (device real)
    if (_manualUrl != null) {
      return _manualUrl!;
    }
    
    // ✅ PRIORIDADE 2: Produção
    if (isProduction) {
      return _productionBaseUrl;
    } 
    
    // ✅ PRIORIDADE 3: Desenvolvimento baseado na plataforma
    if (Platform.isAndroid) {
      return _devBaseUrl; // http://10.0.2.2:8000/api
    } else if (Platform.isIOS) {
      return _devBaseUrlIOS; // http://127.0.0.1:8000/api
    } else {
      return _devBaseUrl; // Fallback para Android
    }
  }
  
  /// URL base para iOS (desenvolvimento)
  static String get baseUrlIOS => _devBaseUrlIOS;
  
  /// URL base para device físico (desenvolvimento)
  static String get baseUrlDevice => _devBaseUrlDevice;
  
  // ===== CONFIGURAÇÕES DE TIMEOUT (AJUSTADAS) =====
  static const Duration defaultTimeout = Duration(seconds: 15); // ✅ Reduzido de 30 para 15
  static const Duration shortTimeout = Duration(seconds: 5);    // ✅ Reduzido de 10 para 5
  static const Duration longTimeout = Duration(seconds: 45);    // ✅ Reduzido de 2min para 45s
  static const Duration uploadTimeout = Duration(minutes: 3);   // ✅ Reduzido de 5min para 3min
  
  // ===== CONFIGURAÇÕES DE RETRY =====
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  // ===== HEADERS PADRÃO =====
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-App-Version': appVersion,
    'X-Platform': 'mobile',
  };
  
  // ===== INFORMAÇÕES DO APP =====
  static const String appName = 'Treino App';
  static const String appVersion = '1.0.0';
  static const String apiVersion = 'v1';
  
  // ===== CONFIGURAÇÕES DE CACHE =====
  static const Duration cacheDefaultDuration = Duration(minutes: 15);
  static const Duration cacheShortDuration = Duration(minutes: 5);
  static const Duration cacheLongDuration = Duration(hours: 1);
  
  // ===== CONFIGURAÇÕES DE PAGINAÇÃO =====
  static const int defaultPerPage = 15;
  static const int maxPerPage = 50;
  static const int minPerPage = 5;
  
  // ===== CONFIGURAÇÕES DE UPLOAD =====
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'mov', 'avi'];
  
  // ===== CÓDIGOS DE STATUS HTTP =====
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusConflict = 409;
  static const int statusUnprocessableEntity = 422;
  static const int statusTooManyRequests = 429;
  static const int statusInternalServerError = 500;
  static const int statusBadGateway = 502;
  static const int statusServiceUnavailable = 503;
  
  // ===== MENSAGENS DE ERRO =====
  static const Map<int, String> errorMessages = {
    statusBadRequest: 'Requisição inválida. Verifique os dados enviados.',
    statusUnauthorized: 'Sessão expirada. Faça login novamente.',
    statusForbidden: 'Acesso negado. Você não tem permissão para esta ação.',
    statusNotFound: 'Recurso não encontrado.',
    statusConflict: 'Conflito de dados. Tente novamente.',
    statusUnprocessableEntity: 'Dados inválidos. Verifique os campos.',
    statusTooManyRequests: 'Muitas tentativas. Aguarde um momento.',
    statusInternalServerError: 'Erro no servidor. Tente novamente mais tarde.',
    statusBadGateway: 'Servidor temporariamente indisponível.',
    statusServiceUnavailable: 'Serviço em manutenção. Tente mais tarde.',
  };
  
  // ===== CONFIGURAÇÕES DE LOGGING =====
  static const bool enableRequestLogging = !kReleaseMode;
  static const bool enableResponseLogging = !kReleaseMode;
  static const bool enableErrorLogging = true;
  
  // ===== CONFIGURAÇÕES DE SEGURANÇA =====
  static const bool enableCertificatePinning = kReleaseMode;
  static const bool enableRequestEncryption = false; // Para futuro
  
  // ===== MÉTODOS UTILITÁRIOS =====
  
  /// Verificar se código de status é sucesso
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  /// Verificar se código de status é erro do cliente
  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }
  
  /// Verificar se código de status é erro do servidor
  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }
  
  /// Obter mensagem de erro baseada no código de status
  static String getErrorMessage(int statusCode) {
    return errorMessages[statusCode] ?? 'Erro desconhecido (${statusCode})';
  }
  
  /// Obter headers com token de autenticação
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
  
  /// Obter headers para upload de arquivo
  static Map<String, String> getUploadHeaders(String token) {
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'X-App-Version': appVersion,
      'X-Platform': 'mobile',
      // Content-Type será definido automaticamente para multipart
    };
  }
  
  /// Construir URL completa
  static String buildUrl(String endpoint) {
    // Garantir que endpoint comece com /
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    
    return '$baseUrl$endpoint';
  }
  
  /// Construir URL com query parameters
  static String buildUrlWithParams(String endpoint, Map<String, String> params) {
    final uri = Uri.parse(buildUrl(endpoint));
    final newUri = uri.replace(queryParameters: params);
    return newUri.toString();
  }
  
  /// Verificar se deve fazer retry baseado no erro
  static bool shouldRetry(int statusCode, int attemptCount) {
    if (attemptCount >= maxRetries) return false;
    
    // Retry apenas para erros de servidor ou timeout
    return isServerError(statusCode) || 
           statusCode == statusServiceUnavailable ||
           statusCode == statusTooManyRequests;
  }
  
  /// Calcular delay para retry com backoff exponencial
  static Duration getRetryDelay(int attemptCount) {
    final multiplier = attemptCount * attemptCount; // Backoff exponencial
    return Duration(
      milliseconds: retryDelay.inMilliseconds * multiplier,
    );
  }
  
  /// Verificar se arquivo é válido para upload
  static bool isValidFileType(String fileName, {bool isImage = true}) {
    final extension = fileName.split('.').last.toLowerCase();
    
    if (isImage) {
      return allowedImageTypes.contains(extension);
    } else {
      return allowedVideoTypes.contains(extension);
    }
  }
  
  /// Verificar se tamanho do arquivo é válido
  static bool isValidFileSize(int fileSizeBytes) {
    return fileSizeBytes <= maxFileSize;
  }
  
  /// Obter configuração de cache baseada no tipo de dados
  static Duration getCacheDuration(String dataType) {
    switch (dataType) {
      case 'user_profile':
        return cacheLongDuration;
      case 'app_settings':
        return cacheLongDuration;
      case 'workout_list':
        return cacheDefaultDuration;
      case 'exercise_list':
        return cacheDefaultDuration;
      case 'real_time_data':
        return cacheShortDuration;
      default:
        return cacheDefaultDuration;
    }
  }
  
  // ===== 🆕 MÉTODOS DE DEVICE REAL CORRIGIDOS =====
  
  /// 🎛️ Forçar uso de device real (trocar IP manualmente)
  static void useDeviceRealMode(String hostIp) {
    _manualUrl = 'http://$hostIp:8000/api';
    print('📱 DEVICE REAL ATIVO: $_manualUrl');
    print('🔄 URL anterior: ${Platform.isAndroid ? _devBaseUrl : _devBaseUrlIOS}');
    print('✅ URL atual: $baseUrl');
  }
  
  /// 🔄 Resetar para modo automático
  static void resetToAutoMode() {
    _manualUrl = null;
    print('🔄 Modo automático ativado');
    print('✅ URL atual: $baseUrl');
  }
  
  /// 🔍 Testar conectividade com Laravel
  static Future<bool> testConnection() async {
    try {
      print('🔍 Testando conectividade...');
      print('📡 URL: ${buildUrl('/status')}');
      print('🕐 Timeout: ${shortTimeout.inSeconds}s');
      
      final client = HttpClient();
      client.connectionTimeout = shortTimeout;
      
      final request = await client.getUrl(Uri.parse(buildUrl('/status')));
      final response = await request.close();
      
      final success = response.statusCode == 200;
      print(success ? '✅ Laravel conectado!' : '❌ Falhou (${response.statusCode})');
      
      client.close();
      return success;
      
    } catch (e) {
      print('❌ Erro de conexão: $e');
      print('💡 Dica: Verifique se Laravel está rodando com php artisan serve --host=0.0.0.0');
      return false;
    }
  }
  
  /// 📊 Obter estatísticas de configuração
  static Map<String, dynamic> getConfigStats() {
    return {
      'environment': isProduction ? 'PRODUCTION' : 'DEVELOPMENT',
      'platform': Platform.operatingSystem,
      'base_url': baseUrl,
      'timeout_default': '${defaultTimeout.inSeconds}s',
      'timeout_short': '${shortTimeout.inSeconds}s',
      'max_retries': maxRetries,
      'logging_enabled': enableRequestLogging,
      'is_manual_override': _manualUrl != null,
      'manual_url': _manualUrl,
    };
  }
  
  /// Debug: Imprimir configurações atuais
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 === API CONFIG DEBUG ===');
      print('Environment: ${isProduction ? 'PRODUCTION' : 'DEVELOPMENT'}');
      print('Platform: ${Platform.operatingSystem}');
      print('Manual Override: ${_manualUrl != null ? 'SIM' : 'NÃO'}');
      print('Manual URL: ${_manualUrl ?? 'Nenhuma'}');
      print('Base URL Final: $baseUrl');
      print('App Version: $appVersion');
      print('Default Timeout: ${defaultTimeout.inSeconds}s');
      print('Short Timeout: ${shortTimeout.inSeconds}s');
      print('Status URL: ${buildUrl('/status')}');
      print('========================');
    }
  }
}