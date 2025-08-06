import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // 🔧 CORRIGIDO: Import para kDebugMode

// ✅ IMPORTS DAS TELAS
import '../home/home_dashboard_screen.dart';
import 'dashboard_tab.dart';
import 'treinos_tab.dart';
import 'historico_tab.dart';
import 'perfil_tab.dart';

/// 🔧 TELA PRINCIPAL COM NAVEGAÇÃO POR ABAS CORRIGIDA
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> 
    with TickerProviderStateMixin {
  
  int _currentIndex = 0;
  late PageController _pageController;
  
  // 🔧 CONTROLE DE DISPOSED PARA EVITAR MEMORY LEAKS
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    print('🏠 [DEBUG] MainNavigationScreen initState iniciado');
    
    _pageController = PageController();
  }

  @override
  void dispose() {
    print('🧹 [DEBUG] MainNavigationScreen dispose iniciado');
    
    // 🔧 MARCAR COMO DISPOSED PRIMEIRO
    _isDisposed = true;
    
    // Limpar controladores
    _pageController.dispose();
    
    super.dispose();
    print('✅ [DEBUG] MainNavigationScreen dispose finalizado');
  }

  /// 🔧 NAVEGAÇÃO SEGURA ENTRE ABAS
  void _onTabTapped(int index) {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // 🔧 VERIFICAR SE PAGECONTROLLER AINDA EXISTE
    if (_pageController.hasClients && !_isDisposed) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    
    // Feedback tátil sutil
    HapticFeedback.selectionClick();
    
    print('🧭 [DEBUG] Navegou para aba: $index');
  }

  /// 🔧 MUDANÇA DE PÁGINA SEGURA
  void _onPageChanged(int index) {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    print('📄 [DEBUG] Página alterada para: $index');
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 VERIFICAÇÃO DE SEGURANÇA NO BUILD
    if (_isDisposed) {
      return const SizedBox.shrink();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: Column(
          children: [
            // 🔧 CONTEÚDO PRINCIPAL SEM OVERFLOW
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(), // 🔧 FÍSICA MELHORADA
                children: const [
                  DashboardTab(),
                  TreinosTab(),
                  HistoricoTab(),
                  PerfilTab(),
                ],
              ),
            ),
            
            // 🔧 BOTTOM NAVIGATION BAR COM PADDING FIXO
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  /// 🔧 BOTTOM NAVIGATION BAR MELHORADO (CORRIGE OVERFLOW)
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          // 🔧 ALTURA FIXA PARA EVITAR OVERFLOW
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.fitness_center_rounded,
                label: 'Treinos',
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.history_rounded,
                label: 'Histórico',
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.person_rounded,
                label: 'Perfil',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 🔧 ITEM DE NAVEGAÇÃO MELHORADO (CORRIGE OVERFLOW)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    final primaryColor = const Color(0xFF4ECDC4); // Turquesa
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_isDisposed || !mounted) return;
          _onTabTapped(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected 
              ? primaryColor.withOpacity(0.1) 
              : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🔧 ÍCONE COM TAMANHO CONTROLADO
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                  size: isSelected ? 24 : 22,
                ),
              ),
              
              // 🔧 ESPAÇAMENTO CONTROLADO PARA EVITAR OVERFLOW
              const SizedBox(height: 2),
              
              // 🔧 TEXTO COM OVERFLOW CONTROLADO
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected ? primaryColor : const Color(0xFF9CA3AF),
                  fontSize: isSelected ? 11 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🔧 WRAPPER PARA DEFAULTTABCONTROLLER (SE NECESSÁRIO PARA OUTRAS TELAS)
class MainNavigationWithTabController extends StatelessWidget {
  const MainNavigationWithTabController({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 SE ALGUMA TELA FILHA PRECISAR DE DefaultTabController
    return DefaultTabController(
      length: 4, // Número de abas
      child: const MainNavigationScreen(),
    );
  }
}

/// 🔧 HELPER PARA NAVEGAÇÃO PROGRAMÁTICA
class NavigationHelper {
  static final GlobalKey<_MainNavigationScreenState> _navigationKey = 
      GlobalKey<_MainNavigationScreenState>();
  
  /// Navegar para aba específica
  static void navigateToTab(int tabIndex) {
    final state = _navigationKey.currentState;
    if (state != null && !state._isDisposed && state.mounted) {
      state._onTabTapped(tabIndex);
    }
  }
  
  /// Obter aba atual
  static int getCurrentTab() {
    final state = _navigationKey.currentState;
    return state?._currentIndex ?? 0;
  }
  
  /// Verificar se pode navegar
  static bool canNavigate() {
    final state = _navigationKey.currentState;
    return state != null && !state._isDisposed && state.mounted;
  }
}

/// 🔧 NAVIGATION SCREEN COM KEY PARA CONTROLE PROGRAMÁTICO
class MainNavigationScreenWithKey extends StatefulWidget {
  const MainNavigationScreenWithKey({super.key});

  @override
  State<MainNavigationScreenWithKey> createState() => _MainNavigationScreenWithKeyState();
}

class _MainNavigationScreenWithKeyState extends State<MainNavigationScreenWithKey> {
  @override
  Widget build(BuildContext context) {
    return MainNavigationScreen(
      key: NavigationHelper._navigationKey,
    );
  }
}

/// 🔧 EXTENSÃO PARA CONTEXTO COM NAVEGAÇÃO SEGURA
extension SafeNavigationContext on BuildContext {
  /// Navegar para aba com verificação de contexto válido
  void navigateToTabSafe(int tabIndex) {
    if (mounted) {
      NavigationHelper.navigateToTab(tabIndex);
    }
  }
  
  /// Verificar se contexto está montado
  bool get mounted {
    try {
      widget;
      return true;
    } catch (e) {
      return false;
    }
  }
}

/// 🔧 MIXIN PARA TELAS QUE PRECISAM REAGIR A MUDANÇAS DE ABA
mixin TabAwareMixin<T extends StatefulWidget> on State<T> {
  bool _isTabVisible = true;
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Detectar se a aba está visível
    final route = ModalRoute.of(context);
    if (route != null) {
      _isTabVisible = route.isCurrent;
    }
  }
  
  /// Verificar se a aba está visível
  bool get isTabVisible => _isTabVisible;
  
  /// Callback quando aba fica visível
  void onTabVisible() {}
  
  /// Callback quando aba fica invisível
  void onTabInvisible() {}
}

/// 🔧 WIDGET PARA DEBUG DE NAVEGAÇÃO (APENAS EM DEBUG MODE)
class NavigationDebugInfo extends StatelessWidget {
  const NavigationDebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔧 CORRIGIDO: kDebugMode agora está importado
    if (!kDebugMode) return const SizedBox.shrink();
    
    return Positioned(
      top: 40,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tab: ${NavigationHelper.getCurrentTab()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
            Text(
              'Can Navigate: ${NavigationHelper.canNavigate()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔧 CONSTANTES PARA NAVEGAÇÃO
class NavigationConstants {
  static const int dashboardTab = 0;
  static const int treinosTab = 1;
  static const int historicoTab = 2;
  static const int perfilTab = 3;
  
  static const List<String> tabNames = [
    'Dashboard',
    'Treinos', 
    'Histórico',
    'Perfil',
  ];
  
  static const List<IconData> tabIcons = [
    Icons.dashboard_rounded,
    Icons.fitness_center_rounded,
    Icons.history_rounded,
    Icons.person_rounded,
  ];
}