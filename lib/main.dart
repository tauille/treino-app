import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider_google.dart';
import 'providers/treino_provider.dart';
import 'core/services/google_auth_service.dart';
import 'screens/auth/auth_wrapper.dart';
import 'config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 🔧 CONFIGURAÇÃO DEVICE REAL - PRIMEIRA COISA!
  print('🚀 === CONFIGURAÇÃO DEVICE REAL ===');
  ApiConfig.useDeviceRealMode('10.125.135.38');
  print('✅ Device real configurado: ${ApiConfig.baseUrl}');
  
  // 🔍 VERIFICAR SE A CONFIGURAÇÃO FUNCIONOU
  print('🧪 === TESTE DE CONFIGURAÇÃO ===');
  print('📡 URL configurada: ${ApiConfig.baseUrl}');
  print('📡 URL de teste: ${ApiConfig.buildUrl('/status')}');
  
  final connected = await ApiConfig.testConnection();
  if (connected) {
    print('✅ Laravel conectado na URL correta!');
  } else {
    print('❌ Laravel NÃO conectado!');
    return; // Parar execução se Laravel não estiver acessível
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
  
  // 🔐 INICIALIZAR GOOGLE AUTH SERVICE - DEPOIS DA CONFIGURAÇÃO API
  print('🔐 === INICIALIZANDO GOOGLE AUTH ===');
  print('📡 URL que GoogleAuth vai usar: ${ApiConfig.baseUrl}');
  
  try {
    await GoogleAuthService().initialize();
    print('✅ Google Auth Service inicializado');
  } catch (e) {
    print('❌ Erro no Google Auth Service: $e');
  }
  
  print('🚀 Iniciando app...');
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🔧 PROVIDERS INICIALIZADOS DEPOIS DA CONFIGURAÇÃO API
        ChangeNotifierProvider(
          create: (context) {
            print('🔧 Criando AuthProviderGoogle com URL: ${ApiConfig.baseUrl}');
            return AuthProviderGoogle();
          }
        ),
        ChangeNotifierProvider(
          create: (context) {
            print('🔧 Criando TreinoProvider com URL: ${ApiConfig.baseUrl}');
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