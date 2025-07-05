class ApiConfig {
  // ← Substitua pelo IP do seu PC
  static const String baseUrl = 'http://10.125.135.38:8000/api';
  
  // Endpoints
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String treinos = '$baseUrl/treinos';
}