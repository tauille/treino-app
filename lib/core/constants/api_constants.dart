/// Constantes para integração com a API Laravel
class ApiConstants {
  // ===== BASE URLs =====
  
  // Desenvolvimento Local
  static const String _devBaseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  // static const String _devBaseUrl = 'http://localhost:8000/api'; // iOS Simulator
  // static const String _devBaseUrl = 'http://192.168.1.100:8000/api'; // IP da sua máquina
  
  // Produção
  static const String _prodBaseUrl = 'https://sua-api.com/api';
  
  // Base URL atual (mudar para produção quando fazer deploy)
  static const String baseUrl = _devBaseUrl;
  
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
  
  /// Obter URL completa para endpoint
  static String getUrl(String endpoint) {
    return baseUrl + endpoint;
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
  static String getTreinoUrl(int treinoId) {
    return '$baseUrl$treinoShow/$treinoId';
  }
  
  /// Construir URL para exercício específico
  static String getExercicioUrl(int treinoId, int exercicioId) {
    return '$baseUrl$exercicios/$treinoId/exercicios/$exercicioId';
  }
  
  /// Construir URL para exercícios de um treino
  static String getExerciciosUrl(int treinoId) {
    return '$baseUrl$exercicios/$treinoId/exercicios';
  }
  
  /// Construir URL para treinos por dificuldade
  static String getTreinosByDificuldadeUrl(String dificuldade) {
    return '$baseUrl$treinosByDificuldade/$dificuldade';
  }
  
  /// Construir URL para exercícios por grupo muscular
  static String getExerciciosByGrupoUrl(int treinoId, String grupo) {
    return '$baseUrl$exerciciosByGrupo/$treinoId/exercicios/grupo/$grupo';
  }
}