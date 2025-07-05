import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/trial_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'tests/quick_test.dart'

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar serviços
  await StorageService.init();
  print('✅ StorageService inicializado');
  
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthProvider deve vir primeiro
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
          lazy: false, // Carregar imediatamente
        ),
        
        // Outros providers podem vir depois
        Provider<TrialService>(
          create: (context) => TrialService(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Treino App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // Tema principal
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue[600],
          
          // Esquema de cores
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue[600]!,
            brightness: Brightness.light,
          ),
          
          // AppBar tema
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue[600],
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          
          // Botões tema
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
          
          // Input tema
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          
          // Card tema
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          
          // Divider tema
          dividerTheme: DividerThemeData(
            color: Colors.grey[300],
            thickness: 1,
          ),
        ),
        
        // Rota inicial
        home: const AuthWrapper(),
        
        // Rotas nomeadas (opcional)
        routes: {
          '/login': (context) => const AuthWrapper(),
          '/home': (context) => const AuthWrapper(),
        },
        
        // Tratar rotas não encontradas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const AuthWrapper(),
          );
        },
      ),
    );
  }
}

// Widget para debug - pode ser removido em produção
class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Debug Info:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              Text('Estado: ${authProvider.state}'),
              Text('Logado: ${authProvider.isAuthenticated}'),
              Text('Usuário: ${authProvider.user?.name ?? 'null'}'),
              Text('Premium: ${authProvider.hasPremium}'),
              Text('Trial: ${authProvider.hasActiveTrial}'),
              if (authProvider.errorMessage != null)
                Text(
                  'Erro: ${authProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        );
      },
    );
  }
}