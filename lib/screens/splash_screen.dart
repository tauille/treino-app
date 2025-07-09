import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../core/services/google_auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart'; // Será criada depois

/// Tela de Splash - Verificação inicial de autenticação
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> 
    with TickerProviderStateMixin {
  
  // ===== CONTROLLERS =====
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  
  // ===== ESTADO =====
  String _statusMessage = 'Iniciando...';
  bool _hasError = false;
  
  @override
  void initState() {
    super.initState();
    
    // Configurar status bar
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
      _fadeController.forward();
    });
  }

  /// Inicializar aplicação
  Future<void> _initializeApp() async {
    try {
      // 1. VERIFICAR CONECTIVIDADE
      await _checkConnectivity();
      
      // 2. INICIALIZAR GOOGLE AUTH SERVICE
      _updateStatus('Configurando autenticação...');
      await GoogleAuthService().initialize();
      
      // 3. VERIFICAR SE JÁ ESTÁ LOGADO
      _updateStatus('Verificando login...');
      await _checkAuthStatus();
      
    } catch (e) {
      _handleError('Erro na inicialização: $e');
    }
  }

  /// Verificar conectividade
  Future<void> _checkConnectivity() async {
    _updateStatus('Verificando conexão...');
    
    final connectivityResult = await Connectivity().checkConnectivity();
    
    if (connectivityResult == ConnectivityResult.none) {
      _handleError('Sem conexão com a internet');
      return;
    }
  }

  /// Verificar status de autenticação
  Future<void> _checkAuthStatus() async {
    final authService = GoogleAuthService();
    
    if (authService.isLoggedIn) {
      // Verificar se token ainda é válido
      _updateStatus('Validando sessão...');
      
      final isValid = await authService.verifyToken();
      
      if (isValid) {
        // Atualizar dados do usuário
        _updateStatus('Carregando dados...');
        await authService.refreshUserData();
        
        // Redirecionar para home
        _navigateToHome();
      } else {
        // Token inválido - ir para login
        _navigateToLogin();
      }
    } else {
      // Não logado - ir para login
      _navigateToLogin();
    }
  }

  /// Atualizar mensagem de status
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
      
      // Mostrar botão de retry após 3 segundos
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {});
        }
      });
    }
  }

  /// Navegar para tela de login
  void _navigateToLogin() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => const LoginScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  /// Navegar para tela home
  void _navigateToHome() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, _) => const HomeScreen(),
            transitionDuration: const Duration(milliseconds: 600),
            transitionsBuilder: (context, animation, _, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  /// Tentar novamente
  void _retry() {
    setState(() {
      _statusMessage = 'Tentando novamente...';
      _hasError = false;
    });
    _initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
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
                            // LOGO/ÍCONE
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fitness_center,
                                size: 60,
                                color: Color(0xFF667eea),
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
                        // LOADING
                        const SpinKitFadingCube(
                          color: Colors.white,
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
                          color: Colors.white.withOpacity(0.8),
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
                        
                        // BOTÃO RETRY
                        ElevatedButton(
                          onPressed: _retry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF667eea),
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
}