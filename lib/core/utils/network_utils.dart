/// Utilitários de rede
class NetworkUtils {
  /// Obter mensagem de erro amigável
  static String getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('timeout')) {
      return 'Timeout: Verifique sua conexão';
    } else if (errorString.contains('socket')) {
      return 'Erro de conexão. Verifique sua internet';
    } else if (errorString.contains('certificate') || errorString.contains('ssl')) {
      return 'Erro de certificado SSL';
    } else if (errorString.contains('format')) {
      return 'Erro no formato dos dados';
    } else {
      return 'Erro de conexão. Tente novamente';
    }
  }
}