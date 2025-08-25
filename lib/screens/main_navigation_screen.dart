import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider_google.dart';
import '../providers/treino_provider.dart';
import '../core/theme/sport_theme.dart';
import 'home/home_dashboard_screen.dart';
import 'treino/treinos_library_screen.dart';
import 'stats_screen.dart';
import 'profile_screen.dart';

/// Tela principal com navegação global por abas
class MainNavigationScreen extends StatefulWidget {
  final int initialTab;
  
  const MainNavigationScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> 
    with TickerProviderStateMixin {
  
  late int _currentIndex;
  late PageController _pageController;
  late AnimationController _animationController;
  
  // Controle de refresh por aba
  final Map<int, DateTime> _lastTabRefresh = {};
  
  // Telas principais
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
    
    _currentIndex = widget.initialTab;
    _pageController = PageController(initialPage: _currentIndex);
    
    // Configurar status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Inicializar telas
    _screens = [
      const HomeDashboardScreen(),
      const TreinosLibraryScreen(),
      const StatsScreen(),
      const ProfileScreen(),
    ];
    
    // Marcar refresh inicial
    _lastTabRefresh[_currentIndex] = DateTime.now();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  /// Verificar se precisa refresh automático na aba
  Future<void> _verificarRefreshAba(int index) async {
    final agora = DateTime.now();
    final ultimoRefresh = _lastTabRefresh[index];
    
    // Se nunca foi refreshado ou passou mais de 10 segundos
    if (ultimoRefresh == null || agora.difference(ultimoRefresh).inSeconds > 10) {
      await _refreshAbaEspecifica(index);
      _lastTabRefresh[index] = agora;
    }
  }

  /// Refresh específico por aba
  Future<void> _refreshAbaEspecifica(int index) async {
    if (!mounted) return;
    
    switch (index) {
      case 0: // Home
        // Home se atualiza automaticamente
        break;
        
      case 1: // Treinos
        try {
          final treinoProvider = context.read<TreinoProvider>();
          await treinoProvider.recarregar();
        } catch (e) {
          // Erro silencioso
        }
        break;
        
      case 2: // Stats
        // Stats se atualizam automaticamente
        break;
        
      case 3: // Perfil
        // Perfil não precisa refresh frequente
        break;
    }
  }

  /// Navegar para aba com refresh automático
  Future<void> _onTabTapped(int index) async {
    if (index == _currentIndex) return;
    
    // Feedback háptico suave
    HapticFeedback.lightImpact();
    
    // Verificar se a aba destino precisa refresh
    await _verificarRefreshAba(index);
    
    setState(() {
      _currentIndex = index;
    });
    
    // Navegar via PageController
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
                    : SportColors.textSecondary,
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
                    : SportColors.textSecondary,
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
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
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
        color: SportColors.backgroundCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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