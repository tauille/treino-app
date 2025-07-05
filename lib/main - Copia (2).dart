import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/trial_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/auth_wrapper.dart';
import 'tests/quick_test.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ CORRIGIDO: Inicializar serviços
  final storage = StorageService();
  await storage.initialize();
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
          
          // ✅ CORRIGIDO: Card tema
          cardTheme: CardThemeData(
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
        home: const MainAppWrapper(),
        
        // Rotas nomeadas (opcional)
        routes: {
          '/login': (context) => const AuthWrapper(),
          '/home': (context) => const AuthWrapper(),
          '/debug': (context) => const DebugScreen(),
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

// ========================================
// WRAPPER PRINCIPAL COM BOTÃO DE DEBUG
// ========================================

class MainAppWrapper extends StatelessWidget {
  const MainAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const AuthWrapper(), // Sua tela principal normal
      
      // ✅ BOTÃO DE DEBUG NO CANTO INFERIOR DIREITO
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DebugScreen(),
            ),
          );
        },
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        child: const Icon(Icons.bug_report),
        tooltip: 'Abrir tela de debug',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ========================================
// TELA DE DEBUG SEPARADA
// ========================================

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Debug & Testes'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              // Limpar dados e reiniciar
              final storage = StorageService();
              await storage.clearAll();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🗑️ Todos os dados foram limpos!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Limpar todos os dados',
          ),
        ],
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========================================
            // AVISO DE DESENVOLVIMENTO
            // ========================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning,
                    color: Colors.red[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TELA DE DESENVOLVIMENTO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Esta tela será removida na versão final',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // ========================================
            // INFORMAÇÕES DE DEBUG (SEU WIDGET EXISTENTE)
            // ========================================
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: DebugInfo(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ========================================
            // TESTES FLUTTER ↔ LARAVEL
            // ========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.api,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Testes de Conectividade',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configure a URL no quick_test.dart antes de testar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // ✅ BOTÕES DE TESTE DO QuickTest
                    QuickTest.buildTestButton(),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ========================================
            // AÇÕES RÁPIDAS DE DEBUG
            // ========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: Colors.orange[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ações Rápidas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Botões de ação
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final storage = StorageService();
                              await storage.printDebugInfo();
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('📊 Info impressa no console'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.info),
                            label: const Text('Debug Info'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[600],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 8),
                        
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final storage = StorageService();
                              await storage.clearAuthData();
                              
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('🔐 Auth limpo'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.logout),
                            label: const Text('Limpar Auth'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final storage = StorageService();
                          final testResult = await storage.testStorage();
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  testResult 
                                    ? '✅ Storage funcionando!' 
                                    : '❌ Storage com problemas'
                                ),
                                backgroundColor: testResult ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.storage),
                        label: const Text('Testar Storage'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // ========================================
            // INSTRUÇÕES
            // ========================================
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Instruções',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    _buildInstructionItem('1.', 'Configure a URL no quick_test.dart'),
                    _buildInstructionItem('2.', 'Inicie o Laravel: php artisan serve'),
                    _buildInstructionItem('3.', 'Pressione "Teste Completo"'),
                    _buildInstructionItem('4.', 'Verifique resultados no console'),
                    
                    const SizedBox(height: 12),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '💡 URLs comuns:\n'
                        '• Local: http://localhost:8000/api\n'
                        '• Emulador: http://10.0.2.2:8000/api\n'
                        '• Físico: http://SEU_IP:8000/api',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ========================================
// WIDGET DEBUG INFO (SEU WIDGET EXISTENTE - MANTIDO)
// ========================================

class DebugInfo extends StatelessWidget {
  const DebugInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info,
                  color: Colors.blue[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado da Aplicação',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildInfoRow('Estado:', '${authProvider.state}'),
            _buildInfoRow('Logado:', '${authProvider.isAuthenticated}'),
            _buildInfoRow('Usuário:', '${authProvider.user?.name ?? 'null'}'),
            _buildInfoRow('Premium:', '${authProvider.hasPremium}'),
            _buildInfoRow('Trial:', '${authProvider.hasActiveTrial}'),
            
            if (authProvider.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error,
                        color: Colors.red[600],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Erro: ${authProvider.errorMessage}',
                          style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}