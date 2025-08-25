import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider_google.dart';
import 'providers/treino_provider.dart';
import 'providers/execucao_treino_provider.dart'; // ✅ NOVO IMPORT
import 'providers/simple_theme_controller.dart';
import 'core/services/google_auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/network_detector.dart';
import 'core/services/wakelock_service.dart';
import 'core/services/execucao_treino.dart'; // ✅ NOVO IMPORT PARA O SERVICE
import 'core/theme/sport_theme.dart';
import 'core/routes/route_generator.dart';
import 'core/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeController = SimpleThemeController();
  await themeController.loadTheme();
  
  // Inicializar serviços essenciais
  await _initializeServices();
  
  // Configurações do sistema
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(TreinoApp(themeController: themeController));
}

Future<void> _initializeServices() async {
  try {
    // Wakelock
    final wakelockService = WakelockService();
    await wakelockService.initialize();
    await wakelockService.initializeGlobal();
    
    // Storage limpo
    final storage = StorageService();
    await storage.init();
    await storage.clearAllData();
    
    // Detecção de rede
    final networkDetector = NetworkDetector();
    networkDetector.reset();
    await networkDetector.forceDetection();
    
    // Google Auth
    final googleAuthService = GoogleAuthService();
    await googleAuthService.initialize();
  } catch (e) {
    debugPrint('Erro na inicialização: $e');
  }
}

class TreinoApp extends StatelessWidget {
  final SimpleThemeController themeController;
  
  const TreinoApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProviderGoogle()),
        ChangeNotifierProvider(create: (context) => TreinoProvider()),
        // ✅ CORRIGIDO: Provider com service injetado
        ChangeNotifierProvider(create: (context) => ExecucaoTreinoProvider(ExecucaoTreinoService())),
        Provider<WakelockService>(create: (_) => WakelockService()),
        ChangeNotifierProvider.value(value: themeController),
      ],
      
      child: Consumer<SimpleThemeController>(
        builder: (context, themeController, _) {
          return MaterialApp(
            title: 'Treino App',
            debugShowCheckedModeBanner: false,
            
            theme: SportTheme.lightTheme,
            darkTheme: SportTheme.darkTheme,
            themeMode: themeController.themeMode,
            
            initialRoute: AppRoutes.splash,
            onGenerateRoute: RouteGenerator.generateRoute,
            onUnknownRoute: _buildErrorRoute,
            
            builder: (context, child) {
              return WakelockAppWrapper(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                  child: child!,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Route<dynamic> _buildErrorRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: SportColors.backgroundCard,
        ),
        backgroundColor: SportColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: SportColors.error),
              const SizedBox(height: 16),
              Text(
                'Rota não encontrada: ${settings.name}',
                style: TextStyle(color: SportColors.textPrimary),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context, 
                  AppRoutes.main,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportColors.primary,
                ),
                child: const Text('Voltar ao Início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WakelockAppWrapper extends StatefulWidget {
  final Widget child;

  const WakelockAppWrapper({super.key, required this.child});

  @override
  State<WakelockAppWrapper> createState() => _WakelockAppWrapperState();
}

class _WakelockAppWrapperState extends State<WakelockAppWrapper> 
    with WidgetsBindingObserver {
  
  final WakelockService _wakelockService = WakelockService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _wakelockService.ensureActive();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        _wakelockService.ensureActive();
        break;
      case AppLifecycleState.detached:
        _wakelockService.dispose();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class TreinoNavigation {
  static Future<dynamic> irParaPrincipal(BuildContext context) {
    return Navigator.pushNamedAndRemoveUntil(
      context, 
      AppRoutes.main,
      (route) => false,
    );
  }

  static Future<dynamic> irParaCriarTreino(BuildContext context) {
    return Navigator.pushNamed(context, AppRoutes.criarTreino);
  }

  static Future<dynamic> irParaPreparacaoTreino(BuildContext context, dynamic treino) {
    return Navigator.pushNamed(
      context, 
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }

  static Future<dynamic> irParaExecucaoTreino(BuildContext context, dynamic treino) {
    return Navigator.pushNamed(
      context, 
      AppRoutes.treinoExecucao,
      arguments: treino,
    );
  }

  static Future<dynamic> irParaDetalhesTreino(BuildContext context, dynamic treino) {
    return Navigator.pushNamed(
      context, 
      AppRoutes.detalhesTreino,
      arguments: treino,
    );
  }

  static Future<void> criarTreinoComFeedback(BuildContext context) async {
    final treinoCriado = await irParaCriarTreino(context);
    
    if (treinoCriado != null && context.mounted) {
      ModernFeedback.showSuccess(
        context, 
        'Treino "${treinoCriado.nomeTreino}" criado com sucesso!',
      );
    }
  }

  static Future<void> iniciarTreinoCompleto(BuildContext context, dynamic treino) async {
    ModernFeedback.showInfo(context, 'Iniciando treino "${treino.nomeTreino}"...');
    await irParaPreparacaoTreino(context, treino);
  }

  static void alternarTema(BuildContext context) {
    final themeController = Provider.of<SimpleThemeController>(
      context, 
      listen: false,
    );
    themeController.toggleTheme();
    ModernFeedback.showThemeChanged(context, themeController.isDarkMode);
  }

  static bool isThemeEscuro(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class ModernFeedback {
  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(context, message, SportColors.success);
  }

  static void showError(BuildContext context, String message) {
    _showSnackBar(context, message, SportColors.error);
  }

  static void showInfo(BuildContext context, String message) {
    _showSnackBar(context, message, SportColors.info);
  }
  
  static void showThemeChanged(BuildContext context, bool isDark) {
    _showSnackBar(
      context, 
      isDark ? 'Tema escuro ativado 🌙' : 'Tema claro ativado ☀️',
      SportColors.primary,
    );
  }
}