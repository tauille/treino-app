import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../config/api_config.dart';

/// Utilitário para testar conectividade e funcionalidade da API
class ApiTestUtils {
  /// Testar conectividade básica com a API
  static Future<Map<String, dynamic>> testBasicConnectivity() async {
    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'tests': <String, dynamic>{},
      'summary': <String, dynamic>{},
    };

    print('🧪 === TESTE DE CONECTIVIDADE API ===');

    // Teste 1: Status da API
    results['tests']['status'] = await _testApiStatus();
    
    // Teste 2: Health check
    results['tests']['health'] = await _testApiHealth();
    
    // Teste 3: Conectividade de rede
    results['tests']['network'] = await _testNetworkConnectivity();
    
    // Teste 4: Latência
    results['tests']['latency'] = await _testApiLatency();

    // Resumo
    final passedTests = results['tests'].values
        .where((test) => test['success'] == true)
        .length;
    
    final totalTests = results['tests'].length;
    
    results['summary'] = {
      'passed': passedTests,
      'total': totalTests,
      'success_rate': (passedTests / totalTests * 100).round(),
      'overall_status': passedTests == totalTests ? 'SUCCESS' : 'PARTIAL_FAILURE',
    };

    print('📊 Resumo: $passedTests/$totalTests testes passaram');
    print('=====================================');

    return results;
  }

  /// Testar autenticação completa (se tiver token)
  static Future<Map<String, dynamic>> testAuthentication(String? token) async {
    if (token == null) {
      return {
        'success': false,
        'message': 'Token não fornecido',
        'error': 'NO_TOKEN',
      };
    }

    print('🔐 === TESTE DE AUTENTICAÇÃO ===');

    final results = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'token_length': token.length,
      'tests': <String, dynamic>{},
    };

    // Teste 1: Verificar token
    results['tests']['verify_token'] = await _testVerifyToken(token);
    
    // Teste 2: Obter dados do usuário
    results['tests']['user_data'] = await _testGetUserData(token);
    
    // Teste 3: Listar treinos
    results['tests']['list_workouts'] = await _testListWorkouts(token);

    final passedTests = results['tests'].values
        .where((test) => test['success'] == true)
        .length;
    
    results['summary'] = {
      'passed': passedTests,
      'total': results['tests'].length,
      'authenticated': passedTests > 0,
    };

    print('🔒 Auth Tests: $passedTests/${results['tests'].length} passaram');
    print('==============================');

    return results;
  }

  /// Teste completo da API
  static Future<Map<String, dynamic>> runFullApiTest({String? authToken}) async {
    print('🚀 === TESTE COMPLETO DA API ===');
    
    final startTime = DateTime.now();
    
    final results = <String, dynamic>{
      'start_time': startTime.toIso8601String(),
      'api_config': _getApiConfigInfo(),
      'connectivity': <String, dynamic>{},
      'authentication': <String, dynamic>{},
      'performance': <String, dynamic>{},
    };

    // Testes de conectividade
    results['connectivity'] = await testBasicConnectivity();
    
    // Testes de autenticação (se token fornecido)
    if (authToken != null) {
      results['authentication'] = await testAuthentication(authToken);
    }
    
    // Testes de performance
    results['performance'] = await _testPerformance();
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    results['end_time'] = endTime.toIso8601String();
    results['total_duration_ms'] = duration.inMilliseconds;

    // Relatório final
    _printTestReport(results);

    return results;
  }

  // ===== TESTES INDIVIDUAIS =====

  /// Testar status da API
  static Future<Map<String, dynamic>> _testApiStatus() async {
    try {
      print('🔍 Testando status da API...');
      
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/status'))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Status API: OK (${stopwatch.elapsedMilliseconds}ms)');
        
        return {
          'success': true,
          'status_code': response.statusCode,
          'response_time_ms': stopwatch.elapsedMilliseconds,
          'data': data,
        };
      } else {
        print('❌ Status API: Falhou (${response.statusCode})');
        return {
          'success': false,
          'status_code': response.statusCode,
          'error': 'HTTP_ERROR',
        };
      }
    } catch (e) {
      print('❌ Status API: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
        'error_type': e.runtimeType.toString(),
      };
    }
  }

  /// Testar health check da API
  static Future<Map<String, dynamic>> _testApiHealth() async {
    try {
      print('🏥 Testando health da API...');
      
      final stopwatch = Stopwatch()..start();
      final response = await http
          .get(Uri.parse('${ApiConstants.baseUrl}/health'))
          .timeout(const Duration(seconds: 10));
      stopwatch.stop();

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Health API: OK (${stopwatch.elapsedMilliseconds}ms)');
        
        return {
          'success': true,
          'status_code': response.statusCode,
          'response_time_ms': stopwatch.elapsedMilliseconds,
          'data': data,
        };
      } else {
        print('❌ Health API: Falhou (${response.statusCode})');
        return {
          'success': false,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Health API: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Testar conectividade de rede
  static Future<Map<String, dynamic>> _testNetworkConnectivity() async {
    try {
      print('🌐 Testando conectividade de rede...');
      
      final stopwatch = Stopwatch()..start();
      
      // Testar resolução DNS
      final addresses = await InternetAddress.lookup('google.com');
      
      // Testar conectividade HTTP
      final response = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      
      stopwatch.stop();

      if (addresses.isNotEmpty && response.statusCode == 200) {
        print('✅ Rede: OK (${stopwatch.elapsedMilliseconds}ms)');
        return {
          'success': true,
          'dns_resolved': addresses.length,
          'http_status': response.statusCode,
          'response_time_ms': stopwatch.elapsedMilliseconds,
        };
      } else {
        print('❌ Rede: Problemas de conectividade');
        return {
          'success': false,
          'error': 'CONNECTIVITY_ISSUE',
        };
      }
    } catch (e) {
      print('❌ Rede: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Testar latência da API
  static Future<Map<String, dynamic>> _testApiLatency() async {
    try {
      print('⚡ Testando latência da API...');
      
      final times = <int>[];
      
      // Fazer 3 requisições para calcular média
      for (int i = 0; i < 3; i++) {
        final stopwatch = Stopwatch()..start();
        
        await http
            .get(Uri.parse('${ApiConstants.baseUrl}/status'))
            .timeout(const Duration(seconds: 5));
        
        stopwatch.stop();
        times.add(stopwatch.elapsedMilliseconds);
      }
      
      final avgLatency = times.reduce((a, b) => a + b) / times.length;
      final minLatency = times.reduce((a, b) => a < b ? a : b);
      final maxLatency = times.reduce((a, b) => a > b ? a : b);
      
      print('✅ Latência: ${avgLatency.toStringAsFixed(1)}ms (avg)');
      
      return {
        'success': true,
        'average_ms': avgLatency.round(),
        'min_ms': minLatency,
        'max_ms': maxLatency,
        'samples': times,
      };
    } catch (e) {
      print('❌ Latência: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Testar verificação de token
  static Future<Map<String, dynamic>> _testVerifyToken(String token) async {
    try {
      print('🎫 Testando verificação de token...');
      
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/auth/verify-token'),
            headers: ApiConstants.getAuthHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Token: Válido');
        
        return {
          'success': true,
          'valid': data['success'] ?? false,
          'data': data,
        };
      } else {
        print('❌ Token: Inválido (${response.statusCode})');
        return {
          'success': false,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Token: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Testar obtenção de dados do usuário
  static Future<Map<String, dynamic>> _testGetUserData(String token) async {
    try {
      print('👤 Testando dados do usuário...');
      
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/auth/me'),
            headers: ApiConstants.getAuthHeaders(token),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Dados do usuário: OK');
        
        return {
          'success': true,
          'has_user_data': data['data'] != null,
          'user_id': data['data']?['user']?['id'],
          'user_name': data['data']?['user']?['name'],
        };
      } else {
        print('❌ Dados do usuário: Falhou (${response.statusCode})');
        return {
          'success': false,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Dados do usuário: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Testar listagem de treinos
  static Future<Map<String, dynamic>> _testListWorkouts(String token) async {
    try {
      print('🏋️ Testando listagem de treinos...');
      
      final response = await http
          .get(
            Uri.parse('${ApiConstants.baseUrl}/treinos'),
            headers: ApiConstants.getAuthHeaders(token),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final workoutCount = data['data']?['data']?.length ?? 0;
        
        print('✅ Treinos: $workoutCount encontrados');
        
        return {
          'success': true,
          'workout_count': workoutCount,
          'has_data': data['data'] != null,
        };
      } else {
        print('❌ Treinos: Falhou (${response.statusCode})');
        return {
          'success': false,
          'status_code': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Treinos: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Testar performance geral
  static Future<Map<String, dynamic>> _testPerformance() async {
    try {
      print('📊 Testando performance...');
      
      final results = <String, dynamic>{};
      
      // Teste de throughput (múltiplas requisições)
      final stopwatch = Stopwatch()..start();
      final futures = List.generate(5, (_) => 
        http.get(Uri.parse('${ApiConstants.baseUrl}/status'))
      );
      
      await Future.wait(futures);
      stopwatch.stop();
      
      results['concurrent_requests'] = {
        'count': 5,
        'total_time_ms': stopwatch.elapsedMilliseconds,
        'avg_time_ms': stopwatch.elapsedMilliseconds / 5,
      };
      
      print('✅ Performance: ${results['concurrent_requests']['avg_time_ms']}ms/req');
      
      return {
        'success': true,
        ...results,
      };
    } catch (e) {
      print('❌ Performance: Erro - $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ===== UTILITÁRIOS =====

  /// Obter informações da configuração da API
  static Map<String, dynamic> _getApiConfigInfo() {
    return {
      'base_url': ApiConstants.baseUrl,
      'is_production': ApiConfig.isProduction,
      'app_version': ApiConfig.appVersion,
      'platform': defaultTargetPlatform.toString(),
      'timeout_seconds': ApiConfig.defaultTimeout.inSeconds,
    };
  }

  /// Imprimir relatório de testes
  static void _printTestReport(Map<String, dynamic> results) {
    print('\n📋 === RELATÓRIO DE TESTES ===');
    
    final connectivity = results['connectivity']['summary'];
    print('🌐 Conectividade: ${connectivity['passed']}/${connectivity['total']} (${connectivity['success_rate']}%)');
    
    if (results['authentication'].isNotEmpty) {
      final auth = results['authentication']['summary'];
      print('🔐 Autenticação: ${auth['passed']}/${auth['total']} (${auth['authenticated'] ? 'OK' : 'FALHOU'})');
    }
    
    print('⏱️  Duração Total: ${results['total_duration_ms']}ms');
    print('🕐 Timestamp: ${results['start_time']}');
    
    print('=============================\n');
  }

  /// Gerar relatório detalhado em formato texto
  static String generateTextReport(Map<String, dynamic> results) {
    final buffer = StringBuffer();
    
    buffer.writeln('=== RELATÓRIO DE TESTES DA API ===');
    buffer.writeln('Timestamp: ${results['start_time']}');
    buffer.writeln('Duração: ${results['total_duration_ms']}ms');
    buffer.writeln('Base URL: ${results['api_config']['base_url']}');
    buffer.writeln('');
    
    // Conectividade
    final conn = results['connectivity'];
    buffer.writeln('CONECTIVIDADE:');
    conn['tests'].forEach((key, value) {
      buffer.writeln('  $key: ${value['success'] ? '✅' : '❌'} ${value['response_time_ms'] ?? ''}ms');
    });
    buffer.writeln('  Resumo: ${conn['summary']['passed']}/${conn['summary']['total']}');
    buffer.writeln('');
    
    // Autenticação
    if (results['authentication'].isNotEmpty) {
      final auth = results['authentication'];
      buffer.writeln('AUTENTICAÇÃO:');
      auth['tests'].forEach((key, value) {
        buffer.writeln('  $key: ${value['success'] ? '✅' : '❌'}');
      });
      buffer.writeln('  Resumo: ${auth['summary']['passed']}/${auth['summary']['total']}');
    }
    
    buffer.writeln('=================================');
    
    return buffer.toString();
  }
}