// lib/tests/quick_test.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/services/storage_service.dart';

class QuickTest {
  // 🔧 CONFIGURE SUA URL AQUI
  static const String baseUrl = 'http://192.168.18.48:8000/api'; 
  // Para Android Emulator: 'http://10.0.2.2:8000/api'
  // Para dispositivo físico: 'http://SEU_IP:8000/api'
  
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ========================================
  // TESTE COMPLETO FLUTTER ↔ LARAVEL
  // ========================================
  
  static Future<void> runFullTest() async {
    print('\n🚀 === TESTE COMPLETO FLUTTER ↔ LARAVEL ===\n');
    
    // 1. Teste Storage
    await testStorage();
    
    // 2. Teste API básica
    await testApiConnection();
    
    // 3. Teste endpoints principais
    await testMainEndpoints();
    
    print('\n✅ === TESTE COMPLETO FINALIZADO ===\n');
  }

  // ========================================
  // 1. TESTE STORAGE SERVICE
  // ========================================
  
  static Future<void> testStorage() async {
    print('📦 Testando StorageService...');
    
    try {
      final storage = StorageService();
      await storage.initialize();
      
      final testResult = await storage.testStorage();
      if (testResult) {
        print('✅ StorageService funcionando perfeitamente!');
      } else {
        print('❌ StorageService com problemas');
      }
      
      // Teste rápido de funcionalidades
      await storage.saveAppTheme('dark');
      final theme = await storage.getAppTheme();
      print('🎨 Teste tema: ${theme == 'dark' ? 'OK' : 'ERRO'}');
      
      await storage.setOnboardingCompleted(true);
      final onboarding = await storage.isOnboardingCompleted();
      print('👋 Teste onboarding: ${onboarding ? 'OK' : 'ERRO'}');
      
    } catch (e) {
      print('❌ Erro no teste de storage: $e');
    }
  }

  // ========================================
  // 2. TESTE CONEXÃO API
  // ========================================
  
  static Future<void> testApiConnection() async {
    print('\n🌐 Testando conexão com Laravel API...');
    
    // Teste 1: Status endpoint
    await _testEndpoint(
      'GET', 
      '$baseUrl/status', 
      'Status da API',
    );
    
    // Teste 2: Health endpoint
    await _testEndpoint(
      'GET', 
      '$baseUrl/health', 
      'Health Check',
    );
  }

  // ========================================
  // 3. TESTE ENDPOINTS PRINCIPAIS
  // ========================================
  
  static Future<void> testMainEndpoints() async {
    print('\n🎯 Testando endpoints principais...');
    
    // Teste registro de usuário
    await testUserRegistration();
    
    // Teste login
    await testUserLogin();
    
    // Teste treinos (precisa de auth - vai dar 401, mas é esperado)
    await _testEndpoint(
      'GET', 
      '$baseUrl/treinos', 
      'Lista de treinos (sem auth - esperado 401)',
    );
  }

  // ========================================
  // TESTE REGISTRO DE USUÁRIO
  // ========================================
  
  static Future<void> testUserRegistration() async {
    print('\n👤 Testando registro de usuário...');
    
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

      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Registro bem-sucedido!');
        print('   Nome: ${data['data']?['user']?['name']}');
        print('   Email: ${data['data']?['user']?['email']}');
        print('   Token: ${data['data']?['token'] != null ? 'Presente' : 'Ausente'}');
        
        // Salvar token para próximos testes
        if (data['data']?['token'] != null) {
          final storage = StorageService();
          await storage.saveToken(data['data']['token']);
          print('🔑 Token salvo para próximos testes');
        }
        
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        print('⚠️ Erro de validação:');
        print('   ${data['message'] ?? 'Dados inválidos'}');
        if (data['errors'] != null) {
          data['errors'].forEach((key, value) {
            print('   $key: ${value.join(', ')}');
          });
        }
      } else {
        print('❌ Erro ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Erro na conexão: $e');
      print('💡 Verifique se o Laravel está rodando em $baseUrl');
    }
  }

  // ========================================
  // TESTE LOGIN
  // ========================================
  
  static Future<void> testUserLogin() async {
    print('\n🔐 Testando login...');
    
    // Usar credenciais de teste (assumindo que existe um usuário)
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

      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Login bem-sucedido!');
        print('   Usuário: ${data['data']?['user']?['name']}');
        print('   Premium: ${data['data']?['user']?['is_premium']}');
        
      } else if (response.statusCode == 422) {
        print('⚠️ Credenciais inválidas (esperado se usuário não existe)');
        
      } else {
        print('❌ Erro ${response.statusCode}: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Erro na conexão: $e');
    }
  }

  // ========================================
  // MÉTODO AUXILIAR PARA TESTAR ENDPOINTS
  // ========================================
  
  static Future<void> _testEndpoint(String method, String url, String description) async {
    print('\n🔍 $description...');
    
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

      print('📊 Status: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ $description OK!');
        
        try {
          final data = jsonDecode(response.body);
          if (data['message'] != null) {
            print('   Mensagem: ${data['message']}');
          }
          if (data['status'] != null) {
            print('   Status: ${data['status']}');
          }
        } catch (e) {
          print('   Response: ${response.body.substring(0, 100)}...');
        }
        
      } else if (response.statusCode == 401) {
        print('🔒 Endpoint protegido (precisa de autenticação) - OK!');
        
      } else if (response.statusCode == 404) {
        print('❌ Endpoint não encontrado - verifique a rota');
        
      } else {
        print('⚠️ Status inesperado: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Erro de conexão: $e');
      
      if (e.toString().contains('timeout')) {
        print('⏱️ Timeout - API pode estar lenta ou offline');
      } else if (e.toString().contains('Connection refused')) {
        print('🚫 Conexão recusada - Laravel não está rodando?');
      } else if (e.toString().contains('SocketException')) {
        print('🌐 Erro de rede - verifique URL e conectividade');
      }
      
      print('💡 Dicas:');
      print('   - Laravel rodando: php artisan serve');
      print('   - URL correta: $baseUrl');
      print('   - Firewall liberado');
    }
  }

  // ========================================
  // WIDGET PARA ADICIONAR NO MAIN.dart
  // ========================================
  
  static Widget buildTestButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '🧪 TESTE FLUTTER ↔ LARAVEL',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    print('\n🚀 Iniciando teste completo...');
                    await runFullTest();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Teste Completo'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    print('\n📦 Testando apenas Storage...');
                    await testStorage();
                  },
                  icon: const Icon(Icons.storage),
                  label: const Text('Só Storage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
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
                  onPressed: () async {
                    print('\n🌐 Testando apenas API...');
                    await testApiConnection();
                  },
                  icon: const Icon(Icons.api),
                  label: const Text('Só API'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    print('\n👤 Testando registro...');
                    await testUserRegistration();
                  },
                  icon: const Icon(Icons.person_add),
                  label: const Text('Registro'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            '📱 Verifique o console/debug para resultados',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}