// lib/core/constants/api_constants.dart
class ApiConstants {
  // ✅ IP correto (mesmo dos testes que funcionaram)
  static const String baseUrl = 'http://10.125.135.38:8000/api';
  
  // ========================================
  // ENDPOINTS DE AUTENTICAÇÃO (CORRETOS)
  // ========================================
  static const String login = '/login';           // ✅ SEM /auth
  static const String register = '/register';     // ✅ SEM /auth
  static const String logout = '/logout';
  static const String me = '/me';
  static const String changePassword = '/change-password';
  static const String updateProfile = '/profile';
  
  // ========================================
  // ENDPOINTS DE GOOGLE AUTH
  // ========================================
  static const String googleAuth = '/auth/google';
  static const String googleDisconnect = '/auth/google/disconnect';
  static const String googleStatus = '/auth/google/status';
  
  // ========================================
  // ENDPOINTS DE TREINOS
  // ========================================
  static const String treinos = '/treinos';
  static const String treinosPorDificuldade = '/treinos/dificuldade';
  
  // ========================================
  // ENDPOINTS DE EXERCÍCIOS
  // ========================================
  // Usar com TreinoService.getExercicios(treinoId)
  // que monta: /treinos/{treinoId}/exercicios
  
  // ========================================
  // ENDPOINTS DE DADOS AUXILIARES
  // ========================================
  static const String gruposMusculares = '/dados/grupos-musculares';
  static const String tiposExecucao = '/dados/tipos-execucao';
  static const String unidadesPeso = '/dados/unidades-peso';
  static const String dificuldades = '/dados/dificuldades';
  
  // ========================================
  // ENDPOINTS DE STATUS
  // ========================================
  static const String status = '/status';
  static const String health = '/health';
  
  // ========================================
  // HEADERS
  // ========================================
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
  
  // ========================================
  // TIMEOUTS
  // ========================================
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================
  
  /// Monta URL completa
  static String fullUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
  
  /// Monta URL de treino específico
  static String treinoUrl(int treinoId) {
    return '$baseUrl/treinos/$treinoId';
  }
  
  /// Monta URL de exercícios de um treino
  static String exerciciosUrl(int treinoId) {
    return '$baseUrl/treinos/$treinoId/exercicios';
  }
  
  /// Monta URL de exercício específico
  static String exercicioUrl(int treinoId, int exercicioId) {
    return '$baseUrl/treinos/$treinoId/exercicios/$exercicioId';
  }
  
  // ========================================
  // CONFIGURAÇÕES DE AMBIENTE
  // ========================================
  
  static bool get isProduction => !baseUrl.contains('localhost') && 
                                  !baseUrl.contains('127.0.0.1') && 
                                  !baseUrl.contains('10.125.135.38');
  
  static bool get isLocal => baseUrl.contains('localhost') || 
                            baseUrl.contains('127.0.0.1') ||
                            baseUrl.contains('10.125.135.38');
  
  // ========================================
  // LOGS DE DEBUG
  // ========================================
  
  static void debugPrint(String message) {
    if (!isProduction) {
      print('🌐 API: $message');
    }
  }
}