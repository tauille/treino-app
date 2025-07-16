import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// ===== PROVIDERS =====
import 'providers/auth_provider_google.dart';
import 'providers/treino_provider.dart';

// ===== CORE =====
import 'core/routes/route_generator.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/api_constants.dart';
import 'core/theme/sport_theme.dart';  // ✅ NOVO TEMA ESPORTIVO

// ===== TELAS =====
import 'screens/loading_screen.dart';

/// Aplicativo principal com tema esportivo
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ===== CONFIGURAÇÕES INICIAIS =====
  
  // Configurar status bar esportivo
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: SportColors.darkBlue,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Configurar orientações permitidas
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // ===== INICIALIZAR DETECÇÃO DE REDE =====
  print('🌐 Sistema de detecção automática de rede ativo');
  
  // Nota: A detecção automática já está configurada no ApiConstants
  // e será executada automaticamente nas chamadas da API
  
  // Executar aplicativo
  runApp(const TreinoApp());
}

/// Widget principal do aplicativo
class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ===== PROVIDERS DO APLICATIVO =====
        ChangeNotifierProvider(create: (_) => AuthProviderGoogle()),
        ChangeNotifierProvider(create: (_) => TreinoProvider()),
      ],
      child: Consumer<AuthProviderGoogle>(
        builder: (context, authProvider, child) {
          return MaterialApp(
            // ===== CONFIGURAÇÕES BÁSICAS =====
            title: 'Treino App - Fitness Esportivo',
            debugShowCheckedModeBanner: false,
            
            // ===== TEMA ESPORTIVO =====
            theme: SportTheme.lightTheme,          // ✅ TEMA CLARO ESPORTIVO
            darkTheme: SportTheme.darkTheme,       // ✅ TEMA ESCURO ESPORTIVO
            themeMode: ThemeMode.light,            // Sempre tema claro por enquanto
            
            // ===== CONFIGURAÇÕES DE MATERIAL 3 =====
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  // Configurações adicionais do tema esportivo
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                  
                  // AppBar com gradiente global
                  appBarTheme: const AppBarTheme(
                    systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                    ),
                  ),
                  
                  // Scroll behavior esportivo
                  scrollbarTheme: ScrollbarThemeData(
                    thumbColor: MaterialStateProperty.all(SportColors.primary),
                    trackColor: MaterialStateProperty.all(SportColors.grey200),
                    radius: const Radius.circular(8),
                    thickness: MaterialStateProperty.all(6),
                  ),
                  
                  // Splash color esportivo
                  splashColor: SportColors.primary.withOpacity(0.2),
                  highlightColor: SportColors.primary.withOpacity(0.1),
                ),
                child: child!,
              );
            },
            
            // ===== ROTAS =====
            onGenerateRoute: RouteGenerator.generateRoute,
            initialRoute: AppRoutes.splash,
            
            // ===== TELA INICIAL =====
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

/// Tela de splash esportiva
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _logoController;
  late AnimationController _pulseController;
  late Animation<double> _logoAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  /// Configurar animações esportivas
  void _setupAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _logoAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _logoController.forward();
    _pulseController.repeat(reverse: true);
  }

  /// Inicializar aplicativo
  Future<void> _initializeApp() async {
    try {
      // Aguardar animação mínima
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Inicializar providers
      if (mounted) {
        final authProvider = Provider.of<AuthProviderGoogle>(context, listen: false);
        final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
        
        // Verificar autenticação
        await authProvider.checkAuthStatus();
        
        // Se autenticado, inicializar treinos
        if (authProvider.isAuthenticated) {
          await treinoProvider.inicializar();
        }
        
        // Navegar para tela apropriada
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            authProvider.isAuthenticated ? AppRoutes.home : AppRoutes.login,
          );
        }
      }
    } catch (e) {
      print('❌ Erro na inicialização: $e');
      
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SportColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo animado
                ScaleTransition(
                  scale: _logoAnimation,
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: SportColors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SportColors.white.withOpacity(0.3),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        size: 60,
                        color: SportColors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Título
                FadeTransition(
                  opacity: _logoAnimation,
                  child: const Text(
                    'TREINO APP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: SportColors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Subtítulo
                FadeTransition(
                  opacity: _logoAnimation,
                  child:                   Text(
                    'Sua jornada fitness começa aqui',
                    style: TextStyle(
                      fontSize: 16,
                      color: SportColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Loading indicator esportivo
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      SportColors.white.withOpacity(0.8),
                    ),
                    strokeWidth: 3,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Preparando seu treino...',
                  style: TextStyle(
                    fontSize: 14,
                    color: SportColors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Loading screen personalizada (se necessário)
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: SportColors.primaryGradient,
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center,
                size: 64,
                color: SportColors.white,
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(SportColors.white),
              ),
              SizedBox(height: 16),
              Text(
                'Carregando...',
                style: TextStyle(
                  color: SportColors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}