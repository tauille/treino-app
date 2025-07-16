/// Centralizador de todas as rotas do aplicativo
class AppRoutes {
  // ===== ROTAS DE AUTENTICAÇÃO =====
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // ===== ROTAS PRINCIPAIS =====
  static const String home = '/home';
  static const String settings = '/settings';
  static const String profile = '/profile';
  
  // ===== ROTAS DE TREINO =====
  static const String meusTreinos = '/meus-treinos';
  static const String criarTreino = '/criar-treino';
  static const String detalhesTreino = '/detalhes-treino';
  static const String editarTreino = '/editar-treino';
  
  // ===== ROTAS DE EXERCÍCIO =====
  static const String exercicios = '/exercicios';
  static const String criarExercicio = '/criar-exercicio';
  static const String editarExercicio = '/editar-exercicio';
  
  // ===== ROTAS DE HISTÓRICO =====
  static const String historico = '/historico';
  static const String estatisticas = '/estatisticas';
  
  // ===== ROTAS DE PREMIUM =====
  static const String upgrade = '/upgrade';
  static const String assinatura = '/assinatura';
  
  // ===== ROTAS DE ONBOARDING =====
  static const String welcome = '/welcome';
  static const String tutorial = '/tutorial';
  
  // ===== UTILITÁRIOS =====
  
  /// Lista de todas as rotas disponíveis
  static List<String> get allRoutes => [
    splash,
    login,
    register,
    home,
    settings,
    profile,
    meusTreinos,
    criarTreino,
    detalhesTreino,
    editarTreino,
    exercicios,
    criarExercicio,
    editarExercicio,
    historico,
    estatisticas,
    upgrade,
    assinatura,
    welcome,
    tutorial,
  ];
  
  /// Verificar se uma rota existe
  static bool routeExists(String route) {
    return allRoutes.contains(route);
  }
  
  /// Obter nome limpo da rota (sem parâmetros)
  static String getCleanRoute(String route) {
    if (route.contains('?')) {
      return route.split('?').first;
    }
    return route;
  }
  
  /// Rotas que requerem autenticação
  static List<String> get protectedRoutes => [
    home,
    meusTreinos,
    criarTreino,
    detalhesTreino,
    editarTreino,
    exercicios,
    criarExercicio,
    editarExercicio,
    historico,
    estatisticas,
    settings,
    profile,
  ];
  
  /// Verificar se rota requer autenticação
  static bool isProtectedRoute(String route) {
    final cleanRoute = getCleanRoute(route);
    return protectedRoutes.contains(cleanRoute);
  }
  
  /// Rotas públicas (sem autenticação)
  static List<String> get publicRoutes => [
    splash,
    login,
    register,
    welcome,
    tutorial,
  ];
  
  /// Rotas que requerem premium
  static List<String> get premiumRoutes => [
    criarTreino,
    editarTreino,
    criarExercicio,
    editarExercicio,
    estatisticas,
  ];
  
  /// Verificar se rota requer premium
  static bool isPremiumRoute(String route) {
    final cleanRoute = getCleanRoute(route);
    return premiumRoutes.contains(cleanRoute);
  }
}