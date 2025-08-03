import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider_google.dart';
import 'providers/treino_provider.dart';
import 'core/services/google_auth_service.dart';
import 'core/services/treino_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/network_detector.dart';
import 'core/services/wakelock_service.dart'; // 🆕 IMPORT DO WAKELOCK SERVICE EXPANDIDO
import 'core/constants/api_constants.dart';
import 'screens/auth/auth_wrapper.dart';

// 🆕 IMPORT DO ROUTE GENERATOR - PRINCIPAL MUDANÇA!
import 'core/routes/route_generator.dart';
import 'core/routes/app_routes.dart';

// ✅ IMPORT - Tela Criar Treino (mantido para compatibilidade)
import 'screens/treino/criar_treino_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔒 INICIALIZAR WAKELOCK GLOBAL - PRIMEIRA COISA!
  print('🔒 === INICIALIZANDO WAKELOCK GLOBAL ===');
  try {
    final wakelockService = WakelockService();
    await wakelockService.initialize();
    await wakelockService.initializeGlobal(); // 🆕 NOVO MÉTODO
    wakelockService.logServiceInfo(); // 🆕 LOG DETALHADO
    print('✅ WakelockService global inicializado');
  } catch (e) {
    print('❌ Erro ao inicializar WakelockService global: $e');
  }
  
  // 🧹 LIMPAR CACHE ANTIGO COMPLETAMENTE
  print('🧹 === LIMPEZA COMPLETA ===');
  try {
    final storage = StorageService();
    await storage.init();
    await storage.clearAllData(); // 🔥 LIMPAR TUDO
    print('✅ Todos os dados limpos');
  } catch (e) {
    print('⚠️ Erro ao limpar dados: $e');
  }
  
  // 🌐 DETECÇÃO AUTOMÁTICA FORÇADA
  print('🌐 === FORÇANDO DETECÇÃO AUTOMÁTICA ===');
  try {
    final networkDetector = NetworkDetector();
    print('🔄 Resetando detector...');
    networkDetector.reset();
    
    print('🔍 Iniciando detecção forçada...');
    final detectedUrl = await networkDetector.forceDetection();
    
    print('✅ URL detectada: $detectedUrl');
    print('📡 IP ativo: ${networkDetector.currentIP}');
    print('📋 Info da rede: ${networkDetector.getNetworkInfo()}');
    
    // 🧪 TESTAR SE A URL DETECTADA FUNCIONA
    print('🧪 === TESTANDO URL DETECTADA ===');
    final isWorking = await networkDetector.testCurrentAPI();
    print('📊 URL funcionando: $isWorking');
    
  } catch (e) {
    print('❌ ERRO CRÍTICO na detecção: $e');
    print('🛑 Parando execução para investigar...');
    return; // Parar aqui para debug
  }
  
  // 🔍 VERIFICAR API CONSTANTS
  print('🔍 === VERIFICANDO API CONSTANTS ===');
  try {
    final baseUrl = await ApiConstants.getBaseUrl();
    print('📡 ApiConstants.getBaseUrl(): $baseUrl');
    
    final currentIP = ApiConstants.getCurrentIP();
    print('📍 ApiConstants.getCurrentIP(): $currentIP');
    
    final networkInfo = ApiConstants.getNetworkInfo();
    print('📋 ApiConstants.getNetworkInfo(): $networkInfo');
    
    // Testar status endpoint
    final statusUrl = await ApiConstants.getUrl(ApiConstants.apiStatus);
    print('🧪 Status URL: $statusUrl');
    
  } catch (e) {
    print('❌ Erro no ApiConstants: $e');
  }
  
  // Configurações de sistema
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  
  // 🔐 INICIALIZAR GOOGLE AUTH SERVICE COM DEBUG
  print('🔐 === INICIALIZANDO GOOGLE AUTH (DEBUG) ===');
  try {
    final googleAuthService = GoogleAuthService();
    
    // ADICIONAR LOG ANTES DE INICIALIZAR
    print('📡 URL que será usada pelo GoogleAuth: ${await ApiConstants.getBaseUrl()}');
    
    await googleAuthService.initialize();
    print('✅ Google Auth Service inicializado');
    
    // TESTAR CONECTIVIDADE DO GOOGLE AUTH
    print('🧪 Testando conectividade do GoogleAuth...');
    // Se houver método de teste, chamar aqui
    
  } catch (e) {
    print('❌ ERRO no Google Auth Service: $e');
    print('📚 Stack trace: ${StackTrace.current}');
  }
  
  print('🚀 === INICIANDO APP ===');
  print('📡 URL final configurada: ${await ApiConstants.getBaseUrl()}');
  print('🛣️ Usando RouteGenerator para navegação avançada');
  print('🔒 WakelockService global está ativo');
  
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🌐 PROVIDERS COM DEBUG
        ChangeNotifierProvider(
          create: (context) {
            print('🔧 === CRIANDO AUTH PROVIDER ===');
            print('📡 URL atual: ${ApiConstants.getCurrentIP()}');
            return AuthProviderGoogle();
          }
        ),
        ChangeNotifierProvider(
          create: (context) {
            print('🔧 === CRIANDO TREINO PROVIDER ===');
            print('📡 URL atual: ${ApiConstants.getCurrentIP()}');
            return TreinoProvider();
          }
        ),
        // 🆕 PROVIDER PARA WAKELOCK SERVICE (opcional)
        Provider<WakelockService>(
          create: (_) => WakelockService(),
        ),
      ],
      child: MaterialApp(
        title: 'Treino App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: const Color(0xFF667eea),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667eea),
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
          useMaterial3: true,
          
          // ===== TEMA PERSONALIZADO =====
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            titleTextStyle: TextStyle(
              color: Color(0xFF2D3748),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: Color(0xFF667eea),
            ),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          
          cardTheme: CardThemeData(
            elevation: 2,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // ===== CORES PERSONALIZADAS =====
          scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        ),
        
        // 🆕 USAR RouteGenerator EM VEZ DE ROTAS ESTÁTICAS!
        initialRoute: AppRoutes.splash, // Rota inicial usando AppRoutes
        onGenerateRoute: RouteGenerator.generateRoute, // PRINCIPAL MUDANÇA!
        
        // ❌ REMOVIDO: rotas estáticas que causavam o problema
        // routes: {
        //   '/criar-treino': (context) => const CriarTreinoScreen(),
        // },
        
        // Fallback para rota não encontrada
        onUnknownRoute: (settings) {
          print('❌ Rota desconhecida: ${settings.name}');
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('Erro')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Rota não encontrada: ${settings.name}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(
                        context, 
                        AppRoutes.home,
                      ),
                      child: const Text('Voltar ao Início'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        
        // 🆕 BUILDER COM WAKELOCK WRAPPER
        builder: (context, child) {
          return WakelockAppWrapper(
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: 1.0, // Evitar zoom de texto do sistema
              ),
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

// 🆕 WAKELOCK APP WRAPPER - MONITORA CICLO DE VIDA
class WakelockAppWrapper extends StatefulWidget {
  final Widget child;

  const WakelockAppWrapper({Key? key, required this.child}) : super(key: key);

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
    _initializeWakelock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeWakelock() async {
    // Garantir que wakelock está ativo se o usuário preferir
    await _wakelockService.ensureActive();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.resumed:
        print('🔒 App resumido - verificando wakelock');
        _wakelockService.ensureActive();
        break;
      case AppLifecycleState.paused:
        print('🔒 App pausado - mantendo wakelock se global');
        break;
      case AppLifecycleState.detached:
        print('🔒 App fechando - limpando recursos');
        _wakelockService.dispose();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// ✅ CLASSE HELPER PARA NAVEGAÇÃO - EXPANDIDA
class TreinoNavigation {
  /// Navegar para a tela de criar treino usando RouteGenerator
  static Future<dynamic> irParaCriarTreino(BuildContext context) async {
    return await Navigator.pushNamed(context, AppRoutes.criarTreino);
  }

  /// Navegar para criar treino (compatibilidade)
  static Future<dynamic> irParaCriarTreinoNomeada(BuildContext context) async {
    return await Navigator.pushNamed(context, AppRoutes.criarTreino);
  }

  /// 🆕 Navegar para preparação do treino
  static Future<dynamic> irParaPreparacaoTreino(
    BuildContext context, 
    dynamic treino,
  ) async {
    return await Navigator.pushNamed(
      context, 
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }

  /// 🆕 Navegar para execução do treino
  static Future<dynamic> irParaExecucaoTreino(
    BuildContext context, 
    dynamic treino,
  ) async {
    return await Navigator.pushNamed(
      context, 
      AppRoutes.treinoExecucao,
      arguments: treino,
    );
  }

  /// 🆕 Navegar para detalhes do treino
  static Future<dynamic> irParaDetalhesTreino(
    BuildContext context, 
    dynamic treino,
  ) async {
    return await Navigator.pushNamed(
      context, 
      AppRoutes.detalhesTreino,
      arguments: treino,
    );
  }

  /// Navegar e mostrar resultado
  static Future<void> criarTreinoComFeedback(BuildContext context) async {
    final treinoCriado = await irParaCriarTreino(context);
    
    if (treinoCriado != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Treino "${treinoCriado.nomeTreino}" criado com sucesso!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Ver',
            textColor: Colors.white,
            onPressed: () {
              // Navegar para detalhes do treino
              irParaDetalhesTreino(context, treinoCriado);
            },
          ),
        ),
      );
    }
  }

  /// 🆕 Iniciar treino completo (preparação + execução)
  static Future<void> iniciarTreinoCompleto(
    BuildContext context,
    dynamic treino,
  ) async {
    // Mostrar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Iniciando treino "${treino.nomeTreino}"...'),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Navegar para preparação
    await irParaPreparacaoTreino(context, treino);
  }

  /// 🆕 TESTES DE WAKELOCK
  static Future<void> testarWakelock(BuildContext context) async {
    await WakelockHelper.test(context);
  }

  /// 🆕 LOG DE INFORMAÇÕES DO WAKELOCK
  static void logWakelockInfo() {
    WakelockHelper.logServiceInfo();
  }

  /// 🆕 GARANTIR WAKELOCK ATIVO
  static Future<void> garantirWakelockAtivo() async {
    await WakelockHelper.ensureActive();
  }
}