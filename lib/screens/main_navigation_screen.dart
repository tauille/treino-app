import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // ✅ ADICIONADO: Para kDebugMode
import 'package:provider/provider.dart';
import '../providers/auth_provider_google.dart';
import '../providers/treino_provider.dart'; // ✅ NOVO: Import do provider
import '../core/theme/sport_theme.dart';
import 'home/home_dashboard_screen.dart';
import 'treino/treinos_library_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

/// 🗂️ Tela principal com navegação por abas - VERSÃO SEM OVERFLOW
class MainNavigationScreen extends StatefulWidget {
  /// 🔧 Parâmetro para definir tab inicial
  final int initialTab;
  
  const MainNavigationScreen({
    super.key,
    this.initialTab = 0, // Home por padrão
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> 
    with TickerProviderStateMixin {
  
  late int _currentIndex;
  late AnimationController _animationController;
  late PageController _pageController; // ✅ NOVO: PageController para controle manual
  
  // ✅ NOVO: Controle de refresh por aba
  final Map<int, DateTime> _lastTabRefresh = {};
  
  // Lista de telas - ✅ MUDANÇA: Não usar IndexedStack
  late final List<Widget> _screens;
  
  // Dados das abas
  final List<NavigationTab> _tabs = [
    NavigationTab(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Home',
      color: SportColors.primary,
    ),
    NavigationTab(
      icon: Icons.fitness_center_rounded,
      activeIcon: Icons.fitness_center,
      label: 'Treinos',
      color: SportColors.secondary,
    ),
    NavigationTab(
      icon: Icons.analytics_rounded,
      activeIcon: Icons.analytics,
      label: 'Stats',
      color: SportColors.accent,
    ),
    NavigationTab(
      icon: Icons.person_rounded,
      activeIcon: Icons.person,
      label: 'Perfil',
      color: SportColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    // ✅ Usar initialTab do widget
    _currentIndex = widget.initialTab;
    
    // ✅ NOVO: Configurar PageController
    _pageController = PageController(initialPage: _currentIndex);
    
    // Configurar status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: SportColors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // ✅ MUDANÇA: Usar widgets que podem ser recriados
    _screens = [
      const HomeDashboardScreen(),
      const TreinosLibraryScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];
    
    // ✅ NOVO: Marcar refresh inicial
    _lastTabRefresh[_currentIndex] = DateTime.now();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose(); // ✅ NOVO: Dispose do PageController
    super.dispose();
  }

  /// ✅ NOVO: Verificar se precisa refresh automático na aba
  Future<void> _verificarRefreshAba(int index) async {
    final agora = DateTime.now();
    final ultimoRefresh = _lastTabRefresh[index];
    
    // Se nunca foi refreshado ou passou mais de 10 segundos
    if (ultimoRefresh == null || agora.difference(ultimoRefresh).inSeconds > 10) {
      print('🔄 NAV: Aba $index precisa refresh (${ultimoRefresh != null ? agora.difference(ultimoRefresh).inSeconds : 'nunca'} segundos)');
      
      // ✅ Refresh específico por tipo de aba
      await _refreshAbaEspecifica(index);
      
      // Marcar como refreshado
      _lastTabRefresh[index] = agora;
    } else {
      print('✅ NAV: Aba $index não precisa refresh (${agora.difference(ultimoRefresh).inSeconds} segundos)');
    }
  }

  /// ✅ NOVO: Refresh específico por aba
  Future<void> _refreshAbaEspecifica(int index) async {
    if (!mounted) return;
    
    switch (index) {
      case 0: // Home
        print('🏠 NAV: Refreshing Home...');
        // Home normalmente se atualiza sozinho
        break;
        
      case 1: // Treinos (CRÍTICO!)
        print('🏋️ NAV: Refreshing Treinos...');
        try {
          final treinoProvider = context.read<TreinoProvider>();
          await treinoProvider.recarregar(); // Força refresh no provider
          print('✅ NAV: Treinos refreshed via provider');
        } catch (e) {
          print('❌ NAV: Erro ao refresh treinos: $e');
        }
        break;
        
      case 2: // Stats
        print('📊 NAV: Refreshing Stats...');
        // Stats podem precisar de refresh específico
        break;
        
      case 3: // Perfil
        print('👤 NAV: Refreshing Profile...');
        // Perfil normalmente não precisa refresh frequente
        break;
    }
  }

  /// ✅ MUDANÇA: Navegar para aba com refresh automático
  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) return;
    
    // Feedback háptico suave
    HapticFeedback.lightImpact();
    
    print('🔄 NAV: Navegando para aba $index (vinha da $_currentIndex)');
    
    // ✅ NOVO: Verificar se a aba destino precisa refresh
    await _verificarRefreshAba(index);
    
    setState(() {
      _currentIndex = index;
    });
    
    // ✅ NOVO: Navegar via PageController (suave)
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Animar indicador
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  /// Construir item da bottom navigation
  Widget _buildNavItem(NavigationTab tab, int index) {
    final isSelected = index == _currentIndex;
    
    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícone com animação
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? tab.color.withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isSelected ? tab.activeIcon : tab.icon,
                color: isSelected 
                    ? tab.color 
                    : SportColors.bottomNavUnselected,
                size: 24,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Label com animação
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? tab.color 
                    : SportColors.bottomNavUnselected,
                letterSpacing: 0.5,
              ),
              child: Text(tab.label),
            ),
            
            // Indicador
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 24 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: tab.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderGoogle>(
      builder: (context, authProvider, child) {
        // Verificar se o usuário está autenticado
        if (!authProvider.isAuthenticated) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: SportColors.primary,
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: SportColors.background,
          // 🔥 REMOVIDO: appBar que causava overflow
          body: PageView( // ✅ MUDANÇA: PageView em vez de IndexedStack
            controller: _pageController,
            onPageChanged: (index) {
              // Sincronizar com a navegação por tab
              if (index != _currentIndex) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
            children: _screens,
          ),
          bottomNavigationBar: _buildBottomNavigation(),
        );
      },
    );
  }

  /// Construir bottom navigation moderna
  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: SportColors.bottomNavBackground,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: SportColors.grey900.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _tabs.asMap().entries.map((entry) {
              return Expanded(
                child: _buildNavItem(entry.value, entry.key),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Modelo para abas de navegação
class NavigationTab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;

  const NavigationTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
  });
}

/// Extensão para navegação programática
extension MainNavigationExtension on BuildContext {
  /// Navegar para tab específica
  void navigateToTab(int index) {
    Navigator.pushReplacement(
      this,
      MaterialPageRoute(
        builder: (context) => MainNavigationScreen(initialTab: index),
      ),
    );
  }
  
  /// Navegar para Home
  void navigateToHome() => navigateToTab(0);
  
  /// Navegar para Treinos
  void navigateToTreinos() => navigateToTab(1);
  
  /// Navegar para Stats
  void navigateToStats() => navigateToTab(2);
  
  /// Navegar para Perfil
  void navigateToProfile() => navigateToTab(3);
}

/// Widget de transição customizada
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final AxisDirection direction;

  SlidePageRoute({
    required this.child,
    this.direction = AxisDirection.left,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            Offset begin;
            switch (direction) {
              case AxisDirection.up:
                begin = const Offset(0.0, 1.0);
                break;
              case AxisDirection.down:
                begin = const Offset(0.0, -1.0);
                break;
              case AxisDirection.right:
                begin = const Offset(-1.0, 0.0);
                break;
              case AxisDirection.left:
              default:
                begin = const Offset(1.0, 0.0);
                break;
            }

            const end = Offset.zero;
            const curve = Curves.easeInOut;

            final tween = Tween(begin: begin, end: end);
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: curve,
            );

            return SlideTransition(
              position: tween.animate(curvedAnimation),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}