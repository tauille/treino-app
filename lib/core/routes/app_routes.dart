/// Constantes de rotas centralizadas do aplicativo
class AppRoutes {
  
  // ===== ROTAS DE AUTENTICAÇÃO =====
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String authWrapper = '/auth-wrapper';
  static const String forgotPassword = '/forgot-password';
  
  // ===== ROTAS PRINCIPAIS =====
  static const String home = '/home';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  
  // ===== 🆕 NOVA ARQUITETURA - ROTAS PRINCIPAIS =====
  /// Tela principal com navegação por abas
  static const String main = '/main';
  
  /// Dashboard home moderno
  static const String dashboard = '/dashboard';
  
  /// Biblioteca de treinos moderna
  static const String biblioteca = '/biblioteca';
  
  /// Tela de estatísticas e progresso (nova)
  static const String stats = '/stats';
  
  // ===== ROTAS DE TREINO =====
  static const String meusTreinos = '/meus-treinos';
  static const String criarTreino = '/criar-treino';
  static const String detalhesTreino = '/detalhes-treino';
  static const String editarTreino = '/editar-treino';
  
  // ===== ROTAS DE EXECUÇÃO DE TREINO - EXISTENTES =====
  static const String treinoPreparacao = '/treino-preparacao';
  static const String treinoExecucao = '/treino-execucao';
  static const String treinoDescanso = '/treino-descanso';
  static const String treinoResumo = '/treino-resumo';
  static const String treinoPausa = '/treino-pausa';
  
  // ===== ROTAS DE EXERCÍCIO =====
  static const String exercicios = '/exercicios';
  static const String criarExercicio = '/criar-exercicio';
  static const String editarExercicio = '/editar-exercicio';
  static const String detalhesExercicio = '/detalhes-exercicio';
  
  // ===== ROTAS DE HISTÓRICO =====
  static const String historico = '/historico';
  static const String detalhesHistorico = '/detalhes-historico';
  static const String estatisticas = '/estatisticas';
  
  // ===== ROTAS DE PERFIL =====
  static const String profile = '/profile';
  static const String editarPerfil = '/editar-perfil';
  static const String configuracoes = '/configuracoes';
  
  // ===== ROTAS DE CONFIGURAÇÕES =====
  static const String settings = '/settings';
  static const String notificacoes = '/notificacoes';
  static const String privacidade = '/privacidade';
  static const String termos = '/termos';
  static const String sobre = '/sobre';
  
  // ===== ROTAS PREMIUM =====
  static const String upgrade = '/upgrade';
  static const String planos = '/planos';
  static const String pagamento = '/pagamento';
  
  // ===== ROTAS DE TESTE/DEBUG =====
  static const String testApi = '/test-api';
  static const String quickTest = '/quick-test';
  static const String debug = '/debug';
  
  // ===== LISTAS DE ROTAS POR CATEGORIA =====
  
  /// Rotas que requerem autenticação
  static List<String> get authRequiredRoutes => [
    // 🆕 Novas rotas da arquitetura moderna
    main,
    dashboard,
    biblioteca,
    stats,
    // Rotas existentes
    meusTreinos,
    criarTreino,
    detalhesTreino,
    editarTreino,
    treinoPreparacao,
    treinoExecucao,
    treinoDescanso,
    treinoResumo,
    treinoPausa,
    exercicios,
    criarExercicio,
    editarExercicio,
    detalhesExercicio,
    historico,
    detalhesHistorico,
    estatisticas,
    profile,
    editarPerfil,
    configuracoes,
    settings,
    notificacoes,
    privacidade,
  ];
  
  /// Rotas que requerem premium
  static List<String> get premiumRequiredRoutes => [
    estatisticas,
    upgrade,
    planos,
  ];
  
  /// Rotas de execução de treino (fluxo especial)
  static List<String> get execucaoTreinoRoutes => [
    treinoPreparacao,
    treinoExecucao,
    treinoDescanso,
    treinoResumo,
    treinoPausa,
  ];
  
  /// 🆕 Rotas da nova arquitetura (navegação por abas)
  static List<String> get newArchitectureRoutes => [
    main,
    dashboard,
    biblioteca,
    stats,
  ];
  
  /// Rotas públicas (não requerem autenticação)
  static List<String> get publicRoutes => [
    splash,
    login,
    register,
    authWrapper,
    forgotPassword,
    onboarding,
    welcome,
    termos,
    sobre,
    testApi,
    quickTest,
    debug,
  ];
  
  /// Todas as rotas do aplicativo
  static List<String> get allRoutes => [
    ...publicRoutes,
    ...authRequiredRoutes,
    ...premiumRequiredRoutes,
  ];
  
  // ===== MÉTODOS UTILITÁRIOS =====
  
  /// Verificar se rota requer autenticação
  static bool requiresAuth(String route) {
    return authRequiredRoutes.contains(route);
  }
  
  /// Verificar se rota requer premium
  static bool requiresPremium(String route) {
    return premiumRequiredRoutes.contains(route);
  }
  
  /// Verificar se rota é de execução de treino
  static bool isExecucaoTreino(String route) {
    return execucaoTreinoRoutes.contains(route);
  }
  
  /// 🆕 Verificar se rota é da nova arquitetura
  static bool isNewArchitecture(String route) {
    return newArchitectureRoutes.contains(route);
  }
  
  /// Verificar se rota é pública
  static bool isPublic(String route) {
    return publicRoutes.contains(route);
  }
  
  /// Obter rota anterior no fluxo de execução
  static String? getPreviousExecucaoRoute(String currentRoute) {
    final index = execucaoTreinoRoutes.indexOf(currentRoute);
    if (index > 0) {
      return execucaoTreinoRoutes[index - 1];
    }
    return null;
  }
  
  /// Obter próxima rota no fluxo de execução
  static String? getNextExecucaoRoute(String currentRoute) {
    final index = execucaoTreinoRoutes.indexOf(currentRoute);
    if (index >= 0 && index < execucaoTreinoRoutes.length - 1) {
      return execucaoTreinoRoutes[index + 1];
    }
    return null;
  }
  
  /// 🆕 Obter rota principal baseada no status de autenticação
  static String getMainRoute({bool isAuthenticated = false}) {
    if (isAuthenticated) {
      return main; // Nova tela principal com abas
    }
    return splash;
  }
  
  /// 🆕 Mapear rota antiga para nova (compatibilidade)
  static String migrateRoute(String oldRoute) {
    switch (oldRoute) {
      case home:
        return main; // Redirecionar home antiga para nova
      case meusTreinos:
        return biblioteca; // Redirecionar para nova biblioteca
      default:
        return oldRoute; // Manter rota original
    }
  }
}