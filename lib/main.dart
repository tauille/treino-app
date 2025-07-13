import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider_google.dart';
import 'providers/treino_provider.dart';
import 'core/services/google_auth_service.dart';
import 'core/services/treino_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/network_detector.dart';
import 'core/constants/api_constants.dart';
import 'screens/auth/auth_wrapper.dart';

// ✅ IMPORT - Tela Criar Treino
import 'screens/treino/criar_treino_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
        
        // Rota inicial
        home: const AuthWrapper(),
        
        // ✅ ROTAS NOMEADAS
        routes: {
          '/criar-treino': (context) => const CriarTreinoScreen(),
        },
        
        // Configurações adicionais
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Evitar zoom de texto do sistema
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

// ✅ CLASSE HELPER PARA NAVEGAÇÃO
class TreinoNavigation {
  /// Navegar para a tela de criar treino
  static Future<dynamic> irParaCriarTreino(BuildContext context) async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    );
  }

  /// Navegar para criar treino usando rota nomeada
  static Future<dynamic> irParaCriarTreinoNomeada(BuildContext context) async {
    return await Navigator.pushNamed(context, '/criar-treino');
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
              // TODO: Navegar para detalhes do treino
              print('Ver treino: ${treinoCriado.id}');
            },
          ),
        ),
      );
    }
  }
}