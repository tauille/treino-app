import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../providers/auth_provider_google.dart';
import '../../core/services/google_auth_service.dart';
import 'google_login_screen.dart';
import '../main_navigation_screen.dart'; // 🆕 MUDANÇA: Nova tela principal
import '../onboarding/welcome_screen.dart';

/// Wrapper que gerencia o estado de autenticação
/// Decide qual tela mostrar baseado no status do usuário
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> 
    with TickerProviderStateMixin {
  
  // ===== CONTROLLERS =====
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  
  // ===== ESTADO =====
  bool _isInitializing = true;
  bool _hasError = false;
  String _statusMessage = 'Iniciando...';

  @override
  void initState() {
    super.initState();
    
    // Configurar status bar para tema escuro
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  /// Configurar animações
  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // Iniciar animações
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fadeController.forward();
    });
  }

  /// Inicializar aplicação
  Future<void> _initializeApp() async {
    final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
    
    try {
      // 1. VERIFICAR CONECTIVIDADE
      await _checkConnectivity();
      
      // 2. INICIALIZAR GOOGLE AUTH SERVICE
      _updateStatus('Configurando autenticação...');
      await GoogleAuthService().initialize();
      
      // 3. VERIFICAR SE JÁ ESTÁ LOGADO
      _updateStatus('Verificando login...');
      await authProvider.checkAuthStatus();
      
      // 4. AGUARDAR ANIMAÇÕES
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // 5. FINALIZAR INICIALIZAÇÃO
      setState(() {
        _isInitializing = false;
      });
      
    } catch (e) {
      _handleError('Erro na inicialização: $e');
    }
  }

  /// Verificar conectividade
  Future<void> _checkConnectivity() async {
    _updateStatus('Verificando conexão...');
    
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('Sem conexão com a internet');
    }
  }

  /// Atualizar status
  void _updateStatus(String message) {
    if (mounted) {
      setState(() {
        _statusMessage = message;
        _hasError = false;
      });
    }
  }

  /// Tratar erro
  void _handleError(String error) {
    if (mounted) {
      setState(() {
        _statusMessage = error;
        _hasError = true;
      });
      
      // Mostrar botão retry após 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() {});
      });
    }
  }

  /// Tentar novamente
  void _retry() {
    setState(() {
      _statusMessage = 'Tentando novamente...';
      _hasError = false;
      _isInitializing = true;
    });
    _initializeApp();
  }

  /// Widget de splash/loading ADAPTADO PARA TEMA ESCURO
  Widget _buildSplashScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1D29),
              Color(0xFF2A2D3A),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ===== LOGO ÁREA =====
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoAnimation.value,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // LOGO/ÍCONE com gradiente
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF8C42), Color(0xFFFF6B6B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8C42).withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // NOME DO APP
                            const Text(
                              'Treino App',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // SUBTÍTULO
                            Text(
                              'Treinos Personalizados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // ===== STATUS ÁREA =====
              Expanded(
                flex: 1,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_hasError) ...[
                        // LOADING com cor turquesa
                        const SpinKitFadingCube(
                          color: Color(0xFF4ECDC4),
                          size: 40.0,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // MENSAGEM STATUS
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        // ERRO
                        Icon(
                          Icons.error_outline,
                          color: const Color(0xFFFF6B6B).withOpacity(0.8),
                          size: 48,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // MENSAGEM ERRO
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _statusMessage,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // BOTÃO RETRY com gradiente
                        Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF8C42), Color(0xFFFF6B6B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8C42).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _retry,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Tentar Novamente',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              // ===== VERSÃO =====
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return _buildSplashScreen();
    }

    return Consumer<AuthProviderGoogle>(
      builder: (context, authProvider, child) {
        // ===== LOADING STATE =====
        if (authProvider.isLoading) {
          return _buildSplashScreen();
        }

        // ===== AUTHENTICATED =====
        if (authProvider.isAuthenticated && authProvider.user != null) {
          final user = authProvider.user!;
          
          // Se usuário tem acesso (premium ou trial válido)
          if (user.hasAccess) {
            return const MainNavigationScreen(); // 🆕 ÚNICA MUDANÇA: Nova tela principal
          }
          
          // Se trial expirou - mostrar welcome com upgrade
          return const WelcomeScreen();
        }

        // ===== NOT AUTHENTICATED =====
        return const GoogleLoginScreen();
      },
    );
  }
}