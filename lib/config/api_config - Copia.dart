import 'package:flutter/foundation.dart';
import 'dart:io';
import '../services/network_detector.dart';

/// Configurações centralizadas da API com detecção automática de rede
class ApiConfig {
  // ===== SINGLETON =====
  static final ApiConfig _instance = ApiConfig._internal();
  factory ApiConfig() => _instance;
  ApiConfig._internal();

  // ===== AMBIENTE =====
  static const bool isProduction = kReleaseMode;
  static const bool isDevelopment = kDebugMode;
  
  // ===== URLs BASE FIXAS =====
  
  // Emuladores (sempre funcionam)
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000/api';
  static const String _iOSSimulatorUrl = 'http://127.0.0.1:8000/api';
  
  // Produção
  static const String _productionBaseUrl = 'https://api.treinoapp.com/api';
  
  // Homologação
  static const String _stagingBaseUrl = 'https://api-staging.treinoapp.com/api';
  
  // ===== ESTADO INTERNO =====
  
  /// URL base detectada automaticamente
  String? _detectedUrl;
  
  /// URL manual (override)
  String? _manualUrl;
  
  /// Se a detecção já foi executada
  bool _hasDetected = false;
  
  /// Se está detectando no momento
  bool _isDetecting = false;

  // ===== PROPRIEDADES PRINCIPAIS =====

  /// 🌐 URL base principal - USA DETECÇÃO AUTOMÁTICA
  Future<String> get baseUrl async {
    // ✅ PRIORIDADE 1: Produção
    if (isProduction) {
      return _productionBaseUrl;
    }
    
    // ✅ PRIORIDADE 2: URL manual (override)
    if (_manualUrl != null) {
      return _manualUrl!;
    }
    
    // ✅ PRIORIDADE 3: URL detectada automaticamente
    if (_detectedUrl != null && _hasDetected) {
      return _detectedUrl!;
    }
    
    // ✅ PRIORIDADE 4: Detectar automaticamente
    if (!_hasDetected && !_isDetecting) {
      await _detectNetwork();
    }
    
    // ✅ PRIORIDADE 5: Emulador (fallback)
    return _getEmulatorUrl();
  }

  /// 📱 URL base síncrona (para casos que não podem aguardar async)
  String get baseUrlSync {
    // Produção
    if (isProduction) {
      return _productionBaseUrl;
    }
    
    // Manual override
    if (_manualUrl != null) {
      return _manualUrl!;
    }
    
    // URL detectada (se já foi detectada)
    if (_detectedUrl != null) {
      return _detectedUrl!;
    }
    
    // Fallback para emulador
    return _getEmulatorUrl();
  }

  // ===== DETECÇÃO AUTOMÁTICA =====

  /// 🔍 Detectar rede automaticamente
  Future<String> _detectNetwork() async {
    if (_isDetecting) {
      // Se já está detectando, aguardar um pouco e retornar o que tiver
      await Future.delayed(const Duration(milliseconds: 500));
      return _detectedUrl ?? _getEmulatorUrl();
    }

    _isDetecting = true;

    try {
      print('🔍 ApiConfig: Iniciando detecção automática...');
      
      // Usar NetworkDetector para encontrar a URL
      final detector = NetworkDetector();
      final detectedUrl = await detector.detectWorkingAPI();
      
      _detectedUrl = detectedUrl;
      _hasDetected = true;
      
      print('✅ ApiConfig: URL detectada: $detectedUrl');
      return detectedUrl;
      
    } catch (e) {
      print('❌ ApiConfig: Erro na detecção: $e');
      
      // Fallback para emulador
      final fallbackUrl = _getEmulatorUrl();
      _detectedUrl = fallbackUrl;
      _hasDetected = true;
      
      return fallbackUrl;
      
    } finally {
      _isDetecting = false;
    }
  }

  /// 🔄 Forçar nova detecção
  Future<String> forceDetection() async {
    print('🔄 ApiConfig: Forçando nova detecção...');
    
    _detectedUrl = null;
    _hasDetected = false;
    _isDetecting = false;
    
    // Forçar detecção no NetworkDetector também
    final detector = NetworkDetector();
    final newUrl = await detector.forceDetection();
    
    _detectedUrl = newUrl;
    _hasDetected = true;
    
    print('✅ ApiConfig: Nova URL detectada: $newUrl');
    return newUrl;
  }

  /// 📱 Obter URL do emulador baseada na plataforma
  String _getEmulatorUrl() {
    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    } else if (Platform.isIOS) {
      return _iOSSimulatorUrl;
    } else {
      return _androidEmulatorUrl; // Fallback
    }
  }

  // ===== CONFIGURAÇÕES MANUAIS =====

  /// 🎛️ Definir URL manual (override)
  void setManualUrl(String url) {
    _manualUrl = url.endsWith('/api') ? url : '$url/api';
    print('🎛️ ApiConfig: URL manual definida: $_manualUrl');
  }

  /// 🎛️ Definir IP manual (helper)
  void setManualIP(String ip, {int port = 8000}) {
    final url = 'http://$ip:$port/api';
    setManualUrl(url);
  }

  /// 🔄 Limpar URL manual (voltar para automático)
  void clearManualUrl() {
    _manualUrl = null;
    print('🔄 ApiConfig: URL manual removida, voltando para automático');
  }

  /// ✅ Verificar se está usando URL manual
  bool get isUsingManualUrl => _manualUrl != null;

  // ===== CONFIGURAÇÕES DE TIMEOUT =====
  static const Duration defaultTimeout = Duration(seconds: 15);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(seconds: 45);
  static const Duration uploadTimeout = Duration(minutes: 3);
  
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
  static const bool enableRequestEncryption = false;

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
    };
  }
  
  /// 🌐 Construir URL completa (ASYNC)
  Future<String> buildUrl(String endpoint) async {
    final base = await baseUrl;
    
    // Garantir que endpoint comece com /
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    
    return '$base$endpoint';
  }

  /// 🌐 Construir URL completa (SYNC - use apenas quando necessário)
  String buildUrlSync(String endpoint) {
    final base = baseUrlSync;
    
    // Garantir que endpoint comece com /
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    
    return '$base$endpoint';
  }
  
  /// 🌐 Construir URL com query parameters (ASYNC)
  Future<String> buildUrlWithParams(String endpoint, Map<String, String> params) async {
    final fullUrl = await buildUrl(endpoint);
    final uri = Uri.parse(fullUrl);
    final newUri = uri.replace(queryParameters: params);
    return newUri.toString();
  }

  /// 🌐 Construir URL com query parameters (SYNC)
  String buildUrlWithParamsSync(String endpoint, Map<String, String> params) {
    final fullUrl = buildUrlSync(endpoint);
    final uri = Uri.parse(fullUrl);
    final newUri = uri.replace(queryParameters: params);
    return newUri.toString();
  }
  
  /// Verificar se deve fazer retry baseado no erro
  static bool shouldRetry(int statusCode, int attemptCount) {
    if (attemptCount >= maxRetries) return false;
    
    return isServerError(statusCode) || 
           statusCode == statusServiceUnavailable ||
           statusCode == statusTooManyRequests;
  }
  
  /// Calcular delay para retry com backoff exponencial
  static Duration getRetryDelay(int attemptCount) {
    final multiplier = attemptCount * attemptCount;
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

  // ===== MÉTODOS DE TESTE E DEBUG =====
  
  /// 🔍 Testar conectividade atual
  Future<bool> testConnection() async {
    try {
      final statusUrl = await buildUrl('/status');
      print('🔍 ApiConfig: Testando conectividade...');
      print('📡 URL: $statusUrl');
      
      final client = HttpClient();
      client.connectionTimeout = shortTimeout;
      
      final request = await client.getUrl(Uri.parse(statusUrl));
      final response = await request.close();
      
      final success = response.statusCode == 200;
      print(success ? '✅ Laravel conectado!' : '❌ Falhou (${response.statusCode})');
      
      client.close();
      return success;
      
    } catch (e) {
      print('❌ ApiConfig: Erro de conexão: $e');
      return false;
    }
  }

  /// 🔄 Testar e validar URL específica
  Future<bool> testSpecificUrl(String testUrl) async {
    try {
      print('🧪 ApiConfig: Testando URL específica: $testUrl');
      
      final client = HttpClient();
      client.connectionTimeout = shortTimeout;
      
      final statusUrl = testUrl.endsWith('/api') ? '$testUrl/status' : '$testUrl/api/status';
      final request = await client.getUrl(Uri.parse(statusUrl));
      final response = await request.close();
      
      final success = response.statusCode == 200;
      print(success ? '✅ URL funcionando!' : '❌ URL falhou (${response.statusCode})');
      
      client.close();
      return success;
      
    } catch (e) {
      print('❌ ApiConfig: Erro testando URL: $e');
      return false;
    }
  }

  /// 📊 Obter informações completas de configuração
  Future<Map<String, dynamic>> getConfigInfo() async {
    final currentUrl = await baseUrl;
    
    return {
      'environment': isProduction ? 'PRODUCTION' : 'DEVELOPMENT',
      'platform': Platform.operatingSystem,
      'current_base_url': currentUrl,
      'detected_url': _detectedUrl,
      'manual_url': _manualUrl,
      'has_detected': _hasDetected,
      'is_detecting': _isDetecting,
      'is_using_manual': isUsingManualUrl,
      'emulator_url': _getEmulatorUrl(),
      'timeout_default': '${defaultTimeout.inSeconds}s',
      'timeout_short': '${shortTimeout.inSeconds}s',
      'max_retries': maxRetries,
      'logging_enabled': enableRequestLogging,
      'app_version': appVersion,
    };
  }

  /// 📊 Obter informações de rede do NetworkDetector
  Map<String, dynamic> getNetworkDetectorInfo() {
    final detector = NetworkDetector();
    return detector.getNetworkInfo();
  }

  /// 🔧 Debug: Imprimir configurações atuais
  Future<void> printConfig() async {
    if (kDebugMode) {
      final info = await getConfigInfo();
      final networkInfo = getNetworkDetectorInfo();
      
      print('🔧 === API CONFIG DEBUG ===');
      print('Environment: ${info['environment']}');
      print('Platform: ${info['platform']}');
      print('Current URL: ${info['current_base_url']}');
      print('Detected URL: ${info['detected_url'] ?? 'Não detectado'}');
      print('Manual URL: ${info['manual_url'] ?? 'Nenhuma'}');
      print('Using Manual: ${info['is_using_manual']}');
      print('Has Detected: ${info['has_detected']}');
      print('Is Detecting: ${info['is_detecting']}');
      print('');
      print('=== NETWORK DETECTOR INFO ===');
      print('Current IP: ${networkInfo['currentIP'] ?? 'Não detectado'}');
      print('Last Range: ${networkInfo['lastDetectedRange']}');
      print('Is Detecting: ${networkInfo['isDetecting']}');
      print('============================');
    }
  }

  /// 🔄 Reset completo (limpar tudo)
  void reset() {
    print('🔄 ApiConfig: Reset completo');
    _detectedUrl = null;
    _manualUrl = null;
    _hasDetected = false;
    _isDetecting = false;
    
    // Reset do NetworkDetector também
    final detector = NetworkDetector();
    detector.reset();
  }

  // ===== MÉTODOS DE CONVENIÊNCIA =====

  /// 🎯 Configuração rápida para IP específico
  Future<bool> quickSetupIP(String ip, {int port = 8000}) async {
    print('🎯 ApiConfig: Configuração rápida para IP: $ip:$port');
    
    // Testar se IP funciona
    final testUrl = 'http://$ip:$port';
    final works = await testSpecificUrl(testUrl);
    
    if (works) {
      setManualIP(ip, port: port);
      print('✅ IP configurado com sucesso!');
      return true;
    } else {
      print('❌ IP não está funcionando');
      return false;
    }
  }

  /// 🔍 Buscar automaticamente IP na rede atual
  Future<String?> findWorkingIP() async {
    print('🔍 ApiConfig: Buscando IP funcionando na rede...');
    
    final detector = NetworkDetector();
    final workingUrl = await detector.detectWorkingAPI();
    
    _detectedUrl = workingUrl;
    _hasDetected = true;
    
    return workingUrl;
  }

  /// 🌐 Obter URL de status para testes
  Future<String> getStatusUrl() async {
    return await buildUrl('/status');
  }

  /// 🌐 Obter URL de health check
  Future<String> getHealthUrl() async {
    return await buildUrl('/health');
  }
}