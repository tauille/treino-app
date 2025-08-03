import '../services/network_detector.dart';

/// Constantes para integração com a API Laravel com detecção automática de rede
class ApiConstants {
  // ===== DETECTOR DE REDE =====
  static final NetworkDetector _networkDetector = NetworkDetector();
  
  // ===== BASE URLs =====
  
  // URLs de produção (não precisa mais de fallback fixo!)
  static const String _prodBaseUrl = 'https://sua-api.com/api';
  
  // ===== MÉTODO PRINCIPAL =====
  
  /// Obter URL base automaticamente (detecta a rede)
  static Future<String> getBaseUrl() async {
    try {
      return await _networkDetector.detectWorkingAPI();
    } catch (e) {
      print('❌ Erro na detecção automática, usando fallback inteligente: $e');
      // ✅ USAR FALLBACK DO PRÓPRIO NETWORKDETECTOR (primeiro IP da lista)
      return _networkDetector.getFallbackUrl();
    }
  }
  
  /// Forçar nova detecção de rede
  static Future<String> forceNetworkDetection() async {
    return await _networkDetector.forceDetection();
  }
  
  /// Testar se a API atual ainda funciona
  static Future<bool> testCurrentAPI() async {
    return await _networkDetector.testCurrentAPI();
  }
  
  // ===== ENDPOINTS AUTH =====
  static const String authGoogle = '/auth/google';
  static const String authLogout = '/auth/logout';
  static const String authMe = '/auth/me';
  static const String authVerifyToken = '/auth/verify-token';
  static const String authUpdateProfile = '/auth/update-profile';
  static const String authChangePassword = '/auth/change-password';
  
  // ===== ENDPOINTS TREINOS =====
  static const String treinos = '/treinos';
  static const String treinoShow = '/treinos'; // + /{id}
  static const String treinoStore = '/treinos';
  static const String treinoUpdate = '/treinos'; // + /{id}
  static const String treinoDelete = '/treinos'; // + /{id}
  static const String treinosByDificuldade = '/treinos/dificuldade'; // + /{dificuldade}
  
  // ===== ENDPOINTS EXERCÍCIOS =====
  static const String exercicios = '/treinos'; // + /{treino}/exercicios
  static const String exercicioShow = '/treinos'; // + /{treino}/exercicios/{exercicio}
  static const String exercicioStore = '/treinos'; // + /{treino}/exercicios
  static const String exercicioUpdate = '/treinos'; // + /{treino}/exercicios/{exercicio}
  static const String exercicioDelete = '/treinos'; // + /{treino}/exercicios/{exercicio}
  static const String exerciciosReordenar = '/treinos'; // + /{treino}/exercicios/reordenar
  static const String exerciciosByGrupo = '/treinos'; // + /{treino}/exercicios/grupo/{grupo}
  
  // ===== ENDPOINTS UTILITÁRIOS =====
  static const String apiStatus = '/status';
  static const String apiHealth = '/health';
  
  // ===== CONFIGURAÇÕES REQUEST =====
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 10);
  static const Duration longTimeout = Duration(minutes: 2);
  
  // ===== HEADERS PADRÃO =====
  static const Map<String, String> defaultHeaders = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // ===== PAGINAÇÃO =====
  static const int defaultPerPage = 15;
  static const int maxPerPage = 50;
  
  // ===== CÓDIGOS DE STATUS =====
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusUnprocessableEntity = 422;
  static const int statusInternalServerError = 500;
  
  // ===== MENSAGENS DE ERRO =====
  static const String errorNetwork = 'Erro de conexão. Verifique sua internet.';
  static const String errorServer = 'Erro no servidor. Tente novamente mais tarde.';
  static const String errorUnauthorized = 'Sessão expirada. Faça login novamente.';
  static const String errorNotFound = 'Recurso não encontrado.';
  static const String errorValidation = 'Dados inválidos. Verifique os campos.';
  static const String errorGeneric = 'Algo deu errado. Tente novamente.';
  
  // ===== HELPER METHODS =====
  
  /// Obter URL completa para endpoint (com detecção automática)
  static Future<String> getUrl(String endpoint) async {
    final baseUrl = await getBaseUrl();
    return baseUrl + endpoint;
  }
  
  /// Obter URL completa de forma síncrona (usa cache se disponível)
  static String getUrlSync(String endpoint) {
    // ✅ USAR FALLBACK INTELIGENTE DO NETWORKDETECTOR
    final cachedBaseUrl = _networkDetector.getCurrentOrFallbackUrl();
    return cachedBaseUrl + endpoint;
  }
  
  /// Obter headers com autenticação
  static Map<String, String> getAuthHeaders(String token) {
    return {
      ...defaultHeaders,
      'Authorization': 'Bearer $token',
    };
  }
  
  /// Obter mensagem de erro baseada no código de status
  static String getErrorMessage(int statusCode) {
    switch (statusCode) {
      case statusUnauthorized:
        return errorUnauthorized;
      case statusNotFound:
        return errorNotFound;
      case statusUnprocessableEntity:
        return errorValidation;
      case statusInternalServerError:
        return errorServer;
      default:
        return errorGeneric;
    }
  }
  
  /// Verificar se código de status é sucesso
  static bool isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }
  
  /// Construir URL para treino específico
  static Future<String> getTreinoUrl(int treinoId) async {
    return await getUrl('$treinoShow/$treinoId');
  }
  
  /// Construir URL para treino específico (síncrono)
  static String getTreinoUrlSync(int treinoId) {
    return getUrlSync('$treinoShow/$treinoId');
  }
  
  /// Construir URL para exercício específico
  static Future<String> getExercicioUrl(int treinoId, int exercicioId) async {
    return await getUrl('$exercicios/$treinoId/exercicios/$exercicioId');
  }
  
  /// Construir URL para exercício específico (síncrono)
  static String getExercicioUrlSync(int treinoId, int exercicioId) {
    return getUrlSync('$exercicios/$treinoId/exercicios/$exercicioId');
  }
  
  /// Construir URL para exercícios de um treino
  static Future<String> getExerciciosUrl(int treinoId) async {
    return await getUrl('$exercicios/$treinoId/exercicios');
  }
  
  /// Construir URL para exercícios de um treino (síncrono)
  static String getExerciciosUrlSync(int treinoId) {
    return getUrlSync('$exercicios/$treinoId/exercicios');
  }
  
  /// Construir URL para treinos por dificuldade
  static Future<String> getTreinosByDificuldadeUrl(String dificuldade) async {
    return await getUrl('$treinosByDificuldade/$dificuldade');
  }
  
  /// Construir URL para treinos por dificuldade (síncrono)
  static String getTreinosByDificuldadeUrlSync(String dificuldade) {
    return getUrlSync('$treinosByDificuldade/$dificuldade');
  }
  
  /// Construir URL para exercícios por grupo muscular
  static Future<String> getExerciciosByGrupoUrl(int treinoId, String grupo) async {
    return await getUrl('$exerciciosByGrupo/$treinoId/exercicios/grupo/$grupo');
  }
  
  /// Construir URL para exercícios por grupo muscular (síncrono)
  static String getExerciciosByGrupoUrlSync(int treinoId, String grupo) {
    return getUrlSync('$exerciciosByGrupo/$treinoId/exercicios/grupo/$grupo');
  }
  
  // ===== MÉTODOS DE REDE =====
  
  /// Obter informações da rede atual
  static Map<String, dynamic> getNetworkInfo() {
    return _networkDetector.getNetworkInfo();
  }
  
  /// Verificar se está usando IP específico
  static bool isUsingIP(String ip) {
    return _networkDetector.isUsingIP(ip);
  }
  
  /// Obter IP atual
  static String? getCurrentIP() {
    return _networkDetector.currentIP;
  }
  
  /// Obter lista de IPs possíveis
  static List<String> getPossibleIPs() {
    return _networkDetector.possibleIPs;
  }
  
  /// Adicionar IP temporário para teste
  static void addTempIP(String ip) {
    _networkDetector.addTempIP(ip);
  }
  
  /// Reset do detector de rede
  static void resetNetwork() {
    _networkDetector.reset();
  }
}