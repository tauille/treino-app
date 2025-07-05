// lib/core/utils/api_test.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../services/auth_service.dart';
import '../services/treino_service.dart';

class ApiTest {
  
  // 🔍 TESTE BÁSICO DE CONECTIVIDADE
  static Future<void> testConnection() async {
    print('\n🔍 ==========================================');
    print('🔍 TESTE DE CONECTIVIDADE COM API');
    print('🔍 ==========================================');
    
    try {
      print('📡 Testando: ${ApiConstants.baseUrl}/status');
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/status'),
        headers: ApiConstants.headers,
      ).timeout(ApiConstants.connectionTimeout);
      
      print('📡 Status Code: ${response.statusCode}');
      print('📄 Response: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ CONECTIVIDADE: OK');
        print('✅ API Status: ${data['status']}');
        print('✅ Mensagem: ${data['message']}');
        print('✅ Versão: ${data['version']}');
      } else {
        print('❌ CONECTIVIDADE: FALHOU');
        print('❌ Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ERRO DE CONEXÃO: $e');
      print('❌ Verifique se:');
      print('   - O servidor Laravel está rodando');
      print('   - O IP está correto: 10.125.135.38');
      print('   - O celular está na mesma rede WiFi');
    }
  }
  
  // 🔐 TESTE DE REGISTRO
  static Future<void> testRegister() async {
    print('\n🔐 ==========================================');
    print('🔐 TESTE DE REGISTRO');
    print('🔐 ==========================================');
    
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final email = 'teste_flutter_$timestamp@teste.com';
    
    try {
      print('📝 Registrando usuário: $email');
      
      final response = await AuthService.register(
        name: 'Teste Flutter',
        email: email,
        password: '123456',
        passwordConfirmation: '123456',
      );
      
      if (response.success) {
        print('✅ REGISTRO: SUCESSO');
        print('✅ Usuário ID: ${response.data?.id}');
        print('✅ Nome: ${response.data?.name}');
        print('✅ Email: ${response.data?.email}');
        print('✅ Status Trial: ${response.data?.hasActiveTrial}');
        
        // Verificar se salvou token
        final token = await AuthService.getToken();
        print('✅ Token salvo: ${token != null ? "SIM" : "NÃO"}');
        
        return; // Sucesso!
      } else {
        print('❌ REGISTRO: FALHOU');
        print('❌ Erro: ${response.message}');
        print('❌ Detalhes: ${response.errors}');
      }
    } catch (e) {
      print('❌ EXCEÇÃO NO REGISTRO: $e');
    }
  }
  
  // 🔑 TESTE DE LOGIN
  static Future<void> testLogin() async {
    print('\n🔑 ==========================================');
    print('🔑 TESTE DE LOGIN');
    print('🔑 ==========================================');
    
    try {
      print('🔓 Fazendo login com: usuario@teste.com');
      
      final response = await AuthService.login(
        email: 'usuario@teste.com',
        password: '123456',
      );
      
      if (response.success) {
        print('✅ LOGIN: SUCESSO');
        print('✅ Usuário ID: ${response.data?.id}');
        print('✅ Nome: ${response.data?.name}');
        print('✅ Status: ${response.data?.accountType}');
        
        // Verificar se salvou token
        final token = await AuthService.getToken();
        print('✅ Token salvo: ${token != null ? "SIM" : "NÃO"}');
        
      } else {
        print('❌ LOGIN: FALHOU');
        print('❌ Erro: ${response.message}');
        print('❌ Detalhes: ${response.errors}');
      }
    } catch (e) {
      print('❌ EXCEÇÃO NO LOGIN: $e');
    }
  }
  
  // 🏋️ TESTE DE TREINOS
  static Future<void> testTreinos() async {
    print('\n🏋️ ==========================================');
    print('🏋️ TESTE DE TREINOS');
    print('🏋️ ==========================================');
    
    try {
      // Verificar se está logado
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ ERRO: Usuário não está logado');
        print('💡 Execute testLogin() primeiro');
        return;
      }
      
      print('🔍 Buscando treinos...');
      final response = await TreinoService.getTreinos();
      
      if (response.success) {
        final treinos = response.data ?? [];
        print('✅ TREINOS: SUCESSO');
        print('✅ Total encontrados: ${treinos.length}');
        
        for (int i = 0; i < treinos.length && i < 3; i++) {
          final treino = treinos[i];
          print('   📋 Treino ${i + 1}:');
          print('      - ID: ${treino.id}');
          print('      - Nome: ${treino.nomeTreino}');
          print('      - Tipo: ${treino.tipoTreino}');
          print('      - Dificuldade: ${treino.dificuldadeText}');
          print('      - Exercícios: ${treino.totalExercicios}');
          print('      - Duração: ${treino.duracaoFormatada}');
        }
        
        if (treinos.length > 3) {
          print('   ... e mais ${treinos.length - 3} treinos');
        }
        
      } else {
        print('❌ TREINOS: FALHOU');
        print('❌ Erro: ${response.message}');
      }
    } catch (e) {
      print('❌ EXCEÇÃO NOS TREINOS: $e');
    }
  }
  
  // 🆕 TESTE DE CRIAÇÃO DE TREINO
  static Future<void> testCreateTreino() async {
    print('\n🆕 ==========================================');
    print('🆕 TESTE DE CRIAÇÃO DE TREINO');
    print('🆕 ==========================================');
    
    try {
      // Verificar se está logado
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ ERRO: Usuário não está logado');
        return;
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nomeTreino = 'Treino Flutter Test $timestamp';
      
      print('➕ Criando treino: $nomeTreino');
      
      final response = await TreinoService.createTreino(
        nomeTreino: nomeTreino,
        tipoTreino: 'Teste Flutter',
        descricao: 'Treino criado automaticamente pelo teste do Flutter',
        dificuldade: 'iniciante',
      );
      
      if (response.success) {
        final treino = response.data!;
        print('✅ CRIAÇÃO: SUCESSO');
        print('✅ Treino criado:');
        print('   - ID: ${treino.id}');
        print('   - Nome: ${treino.nomeTreino}');
        print('   - Tipo: ${treino.tipoTreino}');
        print('   - Dificuldade: ${treino.dificuldadeText}');
        print('   - Status: ${treino.status}');
        
        // Testar buscar o treino criado
        print('\n🔍 Buscando treino criado...');
        final getResponse = await TreinoService.getTreino(treino.id);
        
        if (getResponse.success) {
          print('✅ BUSCA: SUCESSO');
          print('✅ Treino encontrado com ${getResponse.data?.exercicios?.length ?? 0} exercícios');
        } else {
          print('❌ BUSCA: FALHOU - ${getResponse.message}');
        }
        
      } else {
        print('❌ CRIAÇÃO: FALHOU');
        print('❌ Erro: ${response.message}');
        print('❌ Detalhes: ${response.errors}');
      }
    } catch (e) {
      print('❌ EXCEÇÃO NA CRIAÇÃO: $e');
    }
  }
  
  // 🧪 TESTE COMPLETO
  static Future<void> runAllTests() async {
    print('🧪 ==========================================');
    print('🧪 INICIANDO TESTES COMPLETOS DA API');
    print('🧪 ==========================================');
    
    await testConnection();
    await Future.delayed(Duration(seconds: 1));
    
    await testRegister();
    await Future.delayed(Duration(seconds: 1));
    
    await testLogin();
    await Future.delayed(Duration(seconds: 1));
    
    await testTreinos();
    await Future.delayed(Duration(seconds: 1));
    
    await testCreateTreino();
    
    print('\n🎯 ==========================================');
    print('🎯 TESTES CONCLUÍDOS');
    print('🎯 ==========================================');
  }
  
  // 📊 TESTE DE STATUS DO USUÁRIO
  static Future<void> testUserStatus() async {
    print('\n📊 ==========================================');
    print('📊 STATUS DO USUÁRIO');
    print('📊 ==========================================');
    
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      print('🔐 Logado: ${isLoggedIn ? "SIM" : "NÃO"}');
      
      if (isLoggedIn) {
        final user = await AuthService.getUser();
        final token = await AuthService.getToken();
        
        if (user != null) {
          print('👤 Usuário Atual:');
          print('   - ID: ${user.id}');
          print('   - Nome: ${user.name}');
          print('   - Email: ${user.email}');
          print('   - Tipo: ${user.accountType}');
          print('   - Premium: ${user.hasActivePremium ? "SIM" : "NÃO"}');
          print('   - Trial: ${user.hasActiveTrial ? "SIM" : "NÃO"}');
          print('   - Dias Trial: ${user.trialDaysRemaining}');
          print('   - Membro desde: ${user.memberSince}');
          print('🔑 Token: ${token != null ? "Presente" : "Ausente"}');
        }
      }
    } catch (e) {
      print('❌ ERRO AO VERIFICAR STATUS: $e');
    }
  }
}