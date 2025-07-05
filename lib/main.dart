import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TreinoApp());
}

class TreinoApp extends StatelessWidget {
  const TreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Treino App - Teste de Conectividade',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
      home: const ConnectivityTestScreen(),
    );
  }
}

class ConnectivityTestScreen extends StatefulWidget {
  const ConnectivityTestScreen({super.key});

  @override
  State<ConnectivityTestScreen> createState() => _ConnectivityTestScreenState();
}

class _ConnectivityTestScreenState extends State<ConnectivityTestScreen> {
  // 🔧 CONFIGURE SUA URL AQUI
  static const String baseUrl = 'http://192.168.18.48:8000/api';
  // Para Android Emulator: 'http://10.0.2.2:8000/api'
  // Para dispositivo físico: 'http://SEU_IP:8000/api'
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  String _log = '📱 App iniciado!\n\n';
  bool _isTesting = false;

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
    print(message);
  }

  void _clearLog() {
    setState(() {
      _log = '📱 Log limpo!\n\n';
    });
  }

  Future<void> _testFullConnection() async {
    if (_isTesting) return;
    
    setState(() {
      _isTesting = true;
    });

    _addLog('🚀 INICIANDO TESTE COMPLETO...\n');

    // 1. Testar status
    await _testEndpoint('GET', '$baseUrl/status', 'Status da API');
    
    // 2. Testar health
    await _testEndpoint('GET', '$baseUrl/health', 'Health Check');
    
    // 3. Testar registro
    await _testUserRegistration();
    
    // 4. Testar login básico
    await _testUserLogin();

    _addLog('\n✅ TESTE COMPLETO FINALIZADO!');
    
    setState(() {
      _isTesting = false;
    });
  }

  Future<void> _testEndpoint(String method, String url, String description) async {
    _addLog('\n🔍 Testando $description...');
    
    try {
      http.Response response;
      
      if (method == 'GET') {
        response = await http.get(
          Uri.parse(url),
          headers: headers,
        ).timeout(const Duration(seconds: 10));
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: headers,
        ).timeout(const Duration(seconds: 10));
      }

      _addLog('📊 Status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _addLog('✅ $description OK!');
        
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            _addLog('   💬 ${data['message']}');
          }
          if (data['status'] != null) {
            _addLog('   📊 Status: ${data['status']}');
          }
        } catch (e) {
          _addLog('   📄 Response: ${response.body.substring(0, response.body.length > 50 ? 50 : response.body.length)}...');
        }
        
      } else if (response.statusCode == 401) {
        _addLog('🔒 Endpoint protegido (401) - OK!');
        
      } else if (response.statusCode == 404) {
        _addLog('❌ Endpoint não encontrado (404)');
        _addLog('   💡 Verifique se a rota existe no Laravel');
        
      } else {
        _addLog('⚠️ Status inesperado: ${response.statusCode}');
        _addLog('   📄 Response: ${response.body}');
      }
      
    } catch (e) {
      _addLog('❌ Erro: $e');
      
      if (e.toString().contains('timeout')) {
        _addLog('   ⏱️ Timeout - API pode estar offline');
      } else if (e.toString().contains('Connection refused')) {
        _addLog('   🚫 Conexão recusada - Laravel não está rodando?');
      } else if (e.toString().contains('SocketException')) {
        _addLog('   🌐 Erro de rede - verifique URL');
      }
    }
  }

  Future<void> _testUserRegistration() async {
    _addLog('\n👤 Testando registro de usuário...');
    
    final testUser = {
      'name': 'Teste User ${DateTime.now().millisecondsSinceEpoch}',
      'email': 'teste${DateTime.now().millisecondsSinceEpoch}@test.com',
      'password': 'teste123456',
      'password_confirmation': 'teste123456',
    };
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: headers,
        body: jsonEncode(testUser),
      ).timeout(const Duration(seconds: 15));

      _addLog('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _addLog('✅ Registro bem-sucedido!');
        _addLog('   👤 Nome: ${data['data']?['user']?['name']}');
        _addLog('   📧 Email: ${data['data']?['user']?['email']}');
        _addLog('   🔑 Token: ${data['data']?['token'] != null ? 'Presente' : 'Ausente'}');
        
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        _addLog('⚠️ Erro de validação:');
        _addLog('   💬 ${data['message'] ?? 'Dados inválidos'}');
        if (data['errors'] != null) {
          data['errors'].forEach((key, value) {
            _addLog('   🔸 $key: ${value.join(', ')}');
          });
        }
      } else {
        _addLog('❌ Erro ${response.statusCode}');
        _addLog('   📄 ${response.body}');
      }
      
    } catch (e) {
      _addLog('❌ Erro na conexão: $e');
    }
  }

  Future<void> _testUserLogin() async {
    _addLog('\n🔐 Testando login...');
    
    final loginData = {
      'email': 'admin@test.com', // Mude para um usuário que existe
      'password': 'password',
    };
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: headers,
        body: jsonEncode(loginData),
      ).timeout(const Duration(seconds: 15));

      _addLog('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _addLog('✅ Login bem-sucedido!');
        _addLog('   👤 Usuário: ${data['data']?['user']?['name']}');
        _addLog('   💎 Premium: ${data['data']?['user']?['is_premium']}');
        
      } else if (response.statusCode == 422) {
        _addLog('⚠️ Credenciais inválidas (esperado se usuário não existe)');
        
      } else {
        _addLog('❌ Erro ${response.statusCode}');
        _addLog('   📄 ${response.body}');
      }
      
    } catch (e) {
      _addLog('❌ Erro na conexão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔧 Teste Flutter ↔ Laravel'),
        actions: [
          IconButton(
            onPressed: _clearLog,
            icon: const Icon(Icons.clear),
            tooltip: 'Limpar log',
          ),
        ],
      ),
      body: Column(
        children: [
          // ========================================
          // INSTRUÇÕES
          // ========================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(
                bottom: BorderSide(color: Colors.blue[200]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📋 INSTRUÇÕES:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '1. Configure a URL no código (linha 15)',
                  style: TextStyle(color: Colors.blue[600]),
                ),
                Text(
                  '2. Inicie o Laravel: php artisan serve',
                  style: TextStyle(color: Colors.blue[600]),
                ),
                Text(
                  '3. Pressione "Teste Completo"',
                  style: TextStyle(color: Colors.blue[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'URL atual: $baseUrl',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // ========================================
          // BOTÕES DE TESTE
          // ========================================
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTesting ? null : _testFullConnection,
                        icon: _isTesting 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow),
                        label: Text(_isTesting ? 'Testando...' : 'Teste Completo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTesting ? null : () async {
                          _addLog('\n🔍 Testando apenas status...');
                          await _testEndpoint('GET', '$baseUrl/status', 'Status');
                        },
                        icon: const Icon(Icons.api),
                        label: const Text('Só Status'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTesting ? null : () async {
                          _addLog('\n👤 Testando só registro...');
                          await _testUserRegistration();
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Só Registro'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isTesting ? null : () async {
                          _addLog('\n🔐 Testando só login...');
                          await _testUserLogin();
                        },
                        icon: const Icon(Icons.login),
                        label: const Text('Só Login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // ========================================
          // LOG DE RESULTADOS
          // ========================================
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[700]!),
              ),
              child: SingleChildScrollView(
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _log,
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}