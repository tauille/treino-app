import 'package:flutter/material.dart';
import '../../screens/auth/auth_wrapper.dart';
import '../../screens/auth/google_login_screen.dart';
import '../../screens/home/home_dashboard_screen.dart'; // ✅ CORRIGIDO
import '../../screens/treino/treinos_library_screen.dart';
import '../../screens/treino/criar_treino_screen.dart';
import '../../screens/treino/detalhes_treino_screen.dart';
import '../../screens/treino/treino_preparacao_screen.dart';
import '../../screens/treino/execucao_treino_screen.dart';
import '../../screens/main_navigation_screen.dart';
import '../../screens/stats_screen.dart';
import '../../screens/profile_screen.dart';
import '../../models/treino_model.dart';
import 'app_routes.dart';

/// Gerador centralizado de rotas do aplicativo
class RouteGenerator {
  
  /// Gerar rota baseada no settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final arguments = settings.arguments;

    // ===== ROTAS PRINCIPAIS =====
    switch (routeName) {
      
      // ===== AUTENTICACAO =====
      case AppRoutes.splash:
        return _buildRoute(
          const AuthWrapper(),
          settings,
          transitionType: RouteTransition.fade,
        );
        
      case AppRoutes.login:
        return _buildRoute(
          const GoogleLoginScreen(),
          settings,
          transitionType: RouteTransition.slide,
        );

      // ===== NOVA ARQUITETURA =====
      case AppRoutes.main:
        return _buildRoute(
          const MainNavigationScreen(),
          settings,
          transitionType: RouteTransition.fade,
          requiresAuth: true,
        );
        
      case AppRoutes.dashboard:
        return _buildRoute(
          const HomeDashboardScreen(), // ✅ CORRIGIDO
          settings,
          transitionType: RouteTransition.fade,
          requiresAuth: true,
        );
        
      case AppRoutes.biblioteca:
        return _buildRoute(
          const TreinosLibraryScreen(),
          settings,
          transitionType: RouteTransition.slideFromRight,
          requiresAuth: true,
        );
        
      case AppRoutes.stats:
        return _buildRoute(
          const StatsScreen(),
          settings,
          transitionType: RouteTransition.slideFromRight,
          requiresAuth: true,
        );
        
      // ===== ROTAS DE COMPATIBILIDADE =====
      case AppRoutes.home:
        // Redirecionar para nova arquitetura
        return _buildRoute(
          const MainNavigationScreen(),
          settings,
          transitionType: RouteTransition.fade,
          requiresAuth: true,
        );

      // ===== TREINOS =====
      case AppRoutes.meusTreinos:
        // Redirecionar para nova biblioteca
        return _buildRoute(
          const TreinosLibraryScreen(),
          settings,
          transitionType: RouteTransition.slideFromRight,
          requiresAuth: true,
        );
        
      case AppRoutes.criarTreino:
        return _buildRoute(
          const CriarTreinoScreen(),
          settings,
          transitionType: RouteTransition.scale,
          requiresAuth: true,
          requiresPremium: true,
        );
        
      case AppRoutes.detalhesTreino:
        return _buildDetalhesTreinoRoute(settings);

      // ===== EXECUCAO DE TREINO =====
      case AppRoutes.treinoPreparacao:
        return _buildTreinoPreparacaoRoute(settings);
        
      case AppRoutes.treinoExecucao:
        return _buildTreinoExecucaoRoute(settings);
        
      case AppRoutes.treinoDescanso:
        return _buildRoute(
          _buildPlaceholderScreen('Descanso', Icons.pause_circle),
          settings,
          transitionType: RouteTransition.fade,
          requiresAuth: true,
        );
        
      case AppRoutes.treinoResumo:
        return _buildRoute(
          _buildPlaceholderScreen('Resumo do Treino', Icons.analytics),
          settings,
          transitionType: RouteTransition.slideFromBottom,
          requiresAuth: true,
        );
        
      case AppRoutes.treinoPausa:
        return _buildRoute(
          _buildPlaceholderScreen('Treino Pausado', Icons.pause),
          settings,
          transitionType: RouteTransition.scale,
          requiresAuth: true,
        );

      // ===== CONFIGURACOES =====
      case AppRoutes.settings:
        return _buildRoute(
          _buildPlaceholderScreen('Configurações', Icons.settings),
          settings,
          requiresAuth: true,
        );
        
      case AppRoutes.profile:
        return _buildRoute(
          const ProfileScreen(),
          settings,
          transitionType: RouteTransition.slideFromRight,
          requiresAuth: true,
        );

      // ===== HISTORICO =====
      case AppRoutes.historico:
        return _buildRoute(
          _buildPlaceholderScreen('Histórico', Icons.history),
          settings,
          requiresAuth: true,
        );
        
      case AppRoutes.estatisticas:
        return _buildRoute(
          _buildPlaceholderScreen('Estatísticas', Icons.analytics),
          settings,
          requiresAuth: true,
          requiresPremium: true,
        );

      // ===== PREMIUM =====
      case AppRoutes.upgrade:
        return _buildRoute(
          _buildPlaceholderScreen('Upgrade', Icons.star),
          settings,
          requiresAuth: true,
        );

      // ===== TESTE =====
      case AppRoutes.testApi:
        return _buildRoute(
          _buildPlaceholderScreen('Test API', Icons.bug_report),
          settings,
        );
        
      case AppRoutes.quickTest:
        return _buildRoute(
          _buildPlaceholderScreen('Quick Test', Icons.speed),
          settings,
        );

      // ===== ROTA NAO ENCONTRADA =====
      default:
        return _buildErrorRoute(settings);
    }
  }

  /// Construir rota para detalhes do treino
  static Route<dynamic> _buildDetalhesTreinoRoute(RouteSettings settings) {
    final treino = settings.arguments as TreinoModel?;
    
    if (treino == null) {
      return _buildErrorRoute(
        settings,
        'Treino não informado',
        'É necessário passar um treino como argumento',
      );
    }
    
    return _buildRoute(
      DetalhesTreinoScreen(treino: treino),
      settings,
      transitionType: RouteTransition.slideFromBottom,
      requiresAuth: true,
    );
  }

  /// Construir rota para preparação do treino
  static Route<dynamic> _buildTreinoPreparacaoRoute(RouteSettings settings) {
    final treino = settings.arguments as TreinoModel?;
    
    if (treino == null) {
      return _buildErrorRoute(
        settings,
        'Treino não informado',
        'É necessário passar um treino como argumento para a preparação',
      );
    }
    
    return _buildRoute(
      TreinoPreparacaoScreen(treino: treino),
      settings,
      transitionType: RouteTransition.slideFromBottom,
      requiresAuth: true,
    );
  }

  /// Construir rota para execução do treino
  static Route<dynamic> _buildTreinoExecucaoRoute(RouteSettings settings) {
    final treino = settings.arguments as TreinoModel?;
    
    if (treino == null) {
      return _buildErrorRoute(
        settings,
        'Treino não informado',
        'É necessário passar um treino como argumento para a execução',
      );
    }
    
    return _buildRoute(
      ModernExecucaoTreinoScreen(treino: treino), // ✅ CORRIGIDO
      settings,
      transitionType: RouteTransition.fade,
      requiresAuth: true,
    );
  }

  /// Construir rota com verificações de segurança
  static Route<dynamic> _buildRoute(
    Widget page,
    RouteSettings settings, {
    RouteTransition transitionType = RouteTransition.material,
    bool requiresAuth = false,
    bool requiresPremium = false,
  }) {
    // TODO: Implementar verificações de autenticação e premium
    Widget finalPage = page;
    
    // Wrap com verificações se necessário
    if (requiresAuth) {
      finalPage = _wrapWithAuthCheck(finalPage);
    }
    
    if (requiresPremium) {
      finalPage = _wrapWithPremiumCheck(finalPage);
    }

    // Aplicar transição
    switch (transitionType) {
      case RouteTransition.fade:
        return _fadeRoute(finalPage, settings);
      case RouteTransition.slide:
        return _slideRoute(finalPage, settings);
      case RouteTransition.slideFromRight:
        return _slideFromRightRoute(finalPage, settings);
      case RouteTransition.slideFromBottom:
        return _slideFromBottomRoute(finalPage, settings);
      case RouteTransition.scale:
        return _scaleRoute(finalPage, settings);
      case RouteTransition.material:
      default:
        return MaterialPageRoute(builder: (_) => finalPage, settings: settings);
    }
  }

  /// Wrap com verificação de autenticação
  static Widget _wrapWithAuthCheck(Widget page) {
    return Builder(
      builder: (context) {
        // TODO: Verificar se usuário está autenticado
        return page;
      },
    );
  }

  /// Wrap com verificação de premium
  static Widget _wrapWithPremiumCheck(Widget page) {
    return Builder(
      builder: (context) {
        // TODO: Verificar se usuário tem acesso premium
        return page;
      },
    );
  }

  /// Construir tela placeholder para funcionalidades futuras
  static Widget _buildPlaceholderScreen(String title, IconData icon) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF667eea).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 60,
                color: const Color(0xFF667eea),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta funcionalidade será\nimplementada em breve',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir rota de erro
  static Route<dynamic> _buildErrorRoute(
    RouteSettings settings, [
    String? title,
    String? description,
  ]) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          title: Text(title ?? 'Erro'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                title ?? 'Página não encontrada',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description ?? 'A página "${settings.name}" não existe',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (settings.arguments != null)
                Text(
                  'Argumentos: ${settings.arguments}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.main,
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Ir para Início'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
      settings: settings,
    );
  }

  // ===== TRANSICOES CUSTOMIZADAS =====

  static Route<T> _fadeRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  static Route<T> _slideRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );
  }

  static Route<T> _slideFromRightRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  static Route<T> _slideFromBottomRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  static Route<T> _scaleRoute<T>(Widget page, RouteSettings settings) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (context, animation, _) => page,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.0, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
          child: child,
        );
      },
    );
  }
}

/// Tipos de transição disponíveis
enum RouteTransition {
  material,
  fade,
  slide,
  slideFromRight,
  slideFromBottom,
  scale,
}