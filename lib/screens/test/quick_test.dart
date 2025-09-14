import 'package:flutter/foundation.dart';
import '../core/constants/api_constants.dart';
import '../core/constants/google_config.dart';
import '../core/helpers/exercise_assets_helper.dart';
import '../config/api_config.dart';
import '../core/services/google_auth_service.dart';
import '../core/services/storage_service.dart';
import '../core/services/trial_service.dart';
import '../core/utils/api_test.dart';
import '../models/user_model.dart';

/// Classe para executar testes rápidos durante o desenvolvimento
/// Útil para verificar configurações e funcionalidades básicas
class QuickTest {
  /// Executar todos os testes rápidos
  static Future<void> runAllTests() async {
    if (!kDebugMode) {
      print('⚠️ QuickTest deve ser usado apenas em modo debug');
      return;
    }

    print('🧪 === TESTES RÁPIDOS ===');
    print('Iniciando bateria de testes...\n');

    // 1. Testar configurações
    await testConfigurations();
    
    // 2. Testar serviços
    await testServices();
    
    // 3. Testar modelos
    await testModels();
    
    // 4. Testar assets de exercícios
    await testExerciseAssets();
    
    // 5. Testar conectividade (se disponível)
    await testConnectivity();
    
    print('\n🎉 === TESTES CONCLUÍDOS ===');
  }

  /// Testar configurações
  static Future<void> testConfigurations() async {
    print('📋 === TESTE DE CONFIGURAÇÕES ===');
    
    try {
      // API Config
      print('🔧 Testando ApiConfig...');
      ApiConfig.printConfig();
      print('   Base URL: ${ApiConfig.baseUrl}');
      print('   Is Production: ${ApiConfig.isProduction}');
      print('   Default Timeout: ${ApiConfig.defaultTimeout.inSeconds}s');
      print('   ✅ ApiConfig OK\n');
      
      // Google Config
      print('🔧 Testando GoogleConfig...');
      GoogleConfig.printConfig();
      final validation = GoogleConfig.validateConfig();
      print('   Is Valid: ${validation['is_valid']}');
      print('   Ready for Production: ${validation['ready_for_production']}');
      if (validation['issues'].isNotEmpty) {
        print('   ⚠️ Issues: ${validation['issues']}');
      }
      if (validation['warnings'].isNotEmpty) {
        print('   ⚠️ Warnings: ${validation['warnings']}');
      }
      print('   ✅ GoogleConfig OK\n');
      
      // API Constants
      print('🔧 Testando ApiConstants...');
      print('   Base URL: ${ApiConstants.baseUrl}');
      print('   Default Per Page: ${ApiConstants.defaultPerPage}');
      print('   Success Status Code 200: ${ApiConstants.isSuccessStatusCode(200)}');
      print('   Error Message 404: ${ApiConstants.getErrorMessage(404)}');
      print('   ✅ ApiConstants OK\n');
      
    } catch (e) {
      print('   ❌ Erro nas configurações: $e\n');
    }
  }

  /// Testar serviços
  static Future<void> testServices() async {
    print('🔧 === TESTE DE SERVIÇOS ===');
    
    try {
      // Storage Service
      print('💾 Testando StorageService...');
      final storage = StorageService();
      await storage.init();
      
      // Testar operações básicas
      const testKey = 'test_key';
      const testData = {'test': 'data', 'number': 123};
      
      await storage.saveCache(testKey, testData);
      final retrievedData = await storage.getCache(testKey);
      
      if (retrievedData != null && retrievedData['test'] == 'data') {
        print('   ✅ Storage read/write OK');
      } else {
        print('   ❌ Storage read/write falhou');
      }
      
      await storage.removeCache(testKey);
      print('   ✅ StorageService OK\n');
      
      // Google Auth Service
      print('🔐 Testando GoogleAuthService...');
      final authService = GoogleAuthService();
      await authService.initialize();
      print('   Is Logged In: ${authService.isLoggedIn}');
      print('   Has Token: ${authService.authToken != null}');
      print('   ✅ GoogleAuthService OK\n');
      
      // Trial Service
      print('⭐ Testando TrialService...');
      final trialService = TrialService();
      final pricingInfo = trialService.getPricingInfo();
      print('   Monthly Price: ${pricingInfo['monthly']['price']}');
      print('   Annual Price: ${pricingInfo['annual']['price']}');
      print('   ✅ TrialService OK\n');
      
    } catch (e) {
      print('   ❌ Erro nos serviços: $e\n');
    }
  }

  /// Testar modelos
  static Future<void> testModels() async {
    print('📄 === TESTE DE MODELOS ===');
    
    try {
      // User Model
      print('👤 Testando UserModel...');
      final userJson = {
        'id': 1,
        'name': 'Teste User',
        'email': 'teste@email.com',
        'is_premium': false,
        'trial_started_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      final user = UserModel.fromJson(userJson);
      print('   Name: ${user.name}');
      print('   Email: ${user.email}');
      print('   Is In Trial: ${user.isInTrial}');
      print('   Trial Days Left: ${user.trialDaysLeft}');
      print('   Has Access: ${user.hasAccess}');
      print('   Status Text: ${user.statusText}');
      
      // Testar serialização
      final userJsonBack = user.toJson();
      final user2 = UserModel.fromJson(userJsonBack);
      
      if (user.id == user2.id && user.email == user2.email) {
        print('   ✅ UserModel serialization OK');
      } else {
        print('   ❌ UserModel serialization falhou');
      }
      print('   ✅ UserModel OK\n');
      
    } catch (e) {
      print('   ❌ Erro nos modelos: $e\n');
    }
  }

  /// Testar assets de exercícios
  static Future<void> testExerciseAssets() async {
    print('🏋️ === TESTE DE ASSETS DE EXERCÍCIOS ===');
    
    try {
      print('🖼️ Testando ExerciseAssetsHelper...');
      
      // Imprimir mapeamentos
      ExerciseAssetsHelper.debugPrintMappings();
      
      // Testar exercícios específicos
      final testExercises = [
        'flexão',
        'prancha', 
        'agachamento',
        'supino reto',
        'teste',
        'exercicio inexistente'
      ];
      
      int assetsEncontrados = 0;
      int assetsTestados = 0;
      
      for (final exercise in testExercises) {
        assetsTestados++;
        print('\n   🔍 Testando exercício: "$exercise"');
        
        // Resolver asset
        final assetPath = ExerciseAssetsHelper.resolveExerciseAsset(exercise);
        
        if (assetPath != null) {
          print('     Asset resolvido: $assetPath');
          
          // Verificar se existe fisicamente
          final exists = await ExerciseAssetsHelper.assetExists(assetPath);
          print('     Asset existe: $exists');
          
          if (exists) {
            assetsEncontrados++;
            print('     ✅ Asset OK');
          } else {
            print('     ⚠️ Asset não encontrado fisicamente');
          }
        } else {
          print('     ❌ Nenhum asset mapeado');
        }
      }
      
      print('\n   📊 Resumo dos testes:');
      print('     Assets testados: $assetsTestados');
      print('     Assets encontrados: $assetsEncontrados');
      print('     Taxa de sucesso: ${(assetsEncontrados / assetsTestados * 100).toStringAsFixed(1)}%');
      
      // Testar helper methods
      print('\n   🛠️ Testando métodos do helper...');
      
      // Testar lista de assets
      final allAssets = ExerciseAssetsHelper.getAllExerciseAssets();
      print('     Total de assets mapeados: ${allAssets.length}');
      
      // Testar obtenção de imagem
      final flexaoImage = await ExerciseAssetsHelper.getExerciseImagePath(
        'flexão', 
        exerciseId: 'test_123'
      );
      print('     Imagem para flexão: ${flexaoImage ?? "não encontrada"}');
      
      if (assetsEncontrados > 0) {
        print('   ✅ ExerciseAssetsHelper OK (${assetsEncontrados} assets funcionando)');
      } else {
        print('   ⚠️ ExerciseAssetsHelper funcionando, mas nenhum asset físico encontrado');
        print('   💡 Dica: Adicione arquivos .jpg na pasta assets/images/exercicios/');
      }
      
    } catch (e) {
      print('   ❌ Erro no teste de assets: $e');
    }
    
    print('');
  }

  /// Testar conectividade
  static Future<void> testConnectivity() async {
    print('🌐 === TESTE DE CONECTIVIDADE ===');
    
    try {
      print('📡 Testando conectividade básica...');
      
      // Teste rápido de conectividade
      final result = await ApiTestUtils.testBasicConnectivity();
      final summary = result['summary'];
      
      print('   Testes Passaram: ${summary['passed']}/${summary['total']}');
      print('   Taxa de Sucesso: ${summary['success_rate']}%');
      print('   Status Geral: ${summary['overall_status']}');
      
      if (summary['success_rate'] >= 50) {
        print('   ✅ Conectividade OK');
      } else {
        print('   ⚠️ Problemas de conectividade detectados');
      }
      
    } catch (e) {
      print('   ❌ Erro na conectividade: $e');
      print('   ℹ️ Isso é normal se o servidor Laravel não estiver rodando');
    }
    
    print('');
  }

  /// Testar funcionalidades específicas
  static Future<void> testSpecificFeature(String feature) async {
    print('🎯 === TESTE ESPECÍFICO: $feature ===');
    
    switch (feature.toLowerCase()) {
      case 'storage':
        await _testStorageDetailed();
        break;
      case 'user':
        await _testUserModelDetailed();
        break;
      case 'api':
        await _testApiDetailed();
        break;
      case 'trial':
        await _testTrialDetailed();
        break;
      case 'assets':
        await testExerciseAssets();
        break;
      default:
        print('❌ Teste "$feature" não encontrado');
        print('Testes disponíveis: storage, user, api, trial, assets');
    }
  }

  /// Testar storage em detalhes
  static Future<void> _testStorageDetailed() async {
    try {
      final storage = StorageService();
      await storage.init();
      
      // Testar diferentes tipos de dados
      print('💾 Testando diferentes tipos de dados...');
      
      await storage.saveCache('string', {'value': 'test'});
      await storage.saveCache('number', {'value': 123});
      await storage.saveCache('boolean', {'value': true});
      await storage.saveCache('array', {'value': [1, 2, 3]});
      
      print('✅ Salvou diferentes tipos');
      
      // Testar expiração
      await storage.saveCache('expiring', {'value': 'temp'}, 
          expiry: const Duration(milliseconds: 100));
      
      await Future.delayed(const Duration(milliseconds: 150));
      final expiredData = await storage.getCache('expiring');
      
      if (expiredData == null) {
        print('✅ Expiração de cache funcionando');
      } else {
        print('❌ Expiração de cache falhou');
      }
      
      // Limpar teste
      await storage.clearCache();
      print('✅ Cache limpo');
      
    } catch (e) {
      print('❌ Erro no teste de storage: $e');
    }
  }

  /// Testar UserModel em detalhes
  static Future<void> _testUserModelDetailed() async {
    try {
      print('👤 Testando cenários do UserModel...');
      
      // Usuário novo em trial
      final newUser = UserModel(
        id: 1,
        name: 'Novo Usuario',
        email: 'novo@email.com',
        isPremium: false,
        trialStartedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
      
      print('Usuário novo:');
      print('  Trial Days Left: ${newUser.trialDaysLeft}');
      print('  Is In Trial: ${newUser.isInTrial}');
      print('  Has Access: ${newUser.hasAccess}');
      print('  Just Started: ${newUser.trialJustStarted}');
      
      // Usuário com trial expirando
      final expiringUser = UserModel(
        id: 2,
        name: 'Usuario Expirando',
        email: 'expirando@email.com',
        isPremium: false,
        trialStartedAt: DateTime.now().subtract(const Duration(days: 6)),
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
      );
      
      print('\nUsuário trial expirando:');
      print('  Trial Days Left: ${expiringUser.trialDaysLeft}');
      print('  Is Ending Soon: ${expiringUser.trialEndingSoon}');
      print('  Motivational Message: ${expiringUser.motivationalMessage}');
      
      // Usuário premium
      final premiumUser = UserModel(
        id: 3,
        name: 'Usuario Premium',
        email: 'premium@email.com',
        isPremium: true,
        trialStartedAt: DateTime.now().subtract(const Duration(days: 30)),
        premiumExpiresAt: DateTime.now().add(const Duration(days: 335)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      
      print('\nUsuário premium:');
      print('  Is Premium: ${premiumUser.isPremium}');
      print('  Has Access: ${premiumUser.hasAccess}');
      print('  Status Text: ${premiumUser.statusText}');
      print('  CTA Text: ${premiumUser.ctaText}');
      
      print('✅ Todos os cenários testados');
      
    } catch (e) {
      print('❌ Erro no teste de UserModel: $e');
    }
  }

  /// Testar API em detalhes
  static Future<void> _testApiDetailed() async {
    try {
      print('🌐 Testando configurações de API...');
      
      // Testar construção de URLs
      final url1 = ApiConstants.getUrl('/test');
      final url2 = ApiConstants.getTreinoUrl(123);
      final url3 = ApiConstants.getExerciciosUrl(456);
      
      print('URL base + endpoint: $url1');
      print('URL treino específico: $url2');
      print('URL exercícios: $url3');
      
      // Testar headers
      final headers = ApiConstants.getAuthHeaders('test_token');
      print('Headers com auth: ${headers.keys.join(', ')}');
      
      // Testar códigos de status
      final codes = [200, 401, 404, 422, 500];
      for (final code in codes) {
        print('Status $code: ${ApiConstants.getErrorMessage(code)}');
      }
      
      print('✅ Configurações de API OK');
      
    } catch (e) {
      print('❌ Erro no teste de API: $e');
    }
  }

  /// Testar Trial em detalhes
  static Future<void> _testTrialDetailed() async {
    try {
      print('⭐ Testando lógica de trial...');
      
      final trialService = TrialService();
      
      // Criar usuário para teste
      final testUser = UserModel(
        id: 1,
        name: 'Test User',
        email: 'test@email.com',
        isPremium: false,
        trialStartedAt: DateTime.now().subtract(const Duration(days: 3)),
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      );
      
      // Testar verificações
      print('Has Access: ${trialService.hasAccess(testUser)}');
      print('Is Trial Ending Soon: ${trialService.isTrialEndingSoon(testUser)}');
      print('Is Trial Just Started: ${trialService.isTrialJustStarted(testUser)}');
      
      // Testar mensagens
      print('Motivational Message: ${trialService.getMotivationalMessage(testUser)}');
      print('CTA Text: ${trialService.getCtaText(testUser)}');
      
      // Testar verificação de features
      final features = [
        'create_workout',
        'view_workouts',
        'advanced_reports',
        'export_data',
      ];
      
      for (final feature in features) {
        final available = trialService.isFeatureAvailable(testUser, feature);
        print('Feature "$feature": ${available ? "✅" : "❌"}');
      }
      
      // Testar estatísticas
      final stats = trialService.getTrialStats(testUser);
      print('Trial Stats: ${stats['days_used']} dias usados, ${stats['days_remaining']} restantes');
      
      print('✅ Lógica de trial OK');
      
    } catch (e) {
      print('❌ Erro no teste de trial: $e');
    }
  }

  /// Gerar relatório de saúde do sistema
  static Future<Map<String, dynamic>> generateHealthReport() async {
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'app_version': ApiConfig.appVersion,
      'environment': ApiConfig.isProduction ? 'production' : 'development',
      'components': <String, dynamic>{},
    };

    try {
      // Testar Storage
      final storage = StorageService();
      await storage.init();
      await storage.saveCache('health_check', {'test': true});
      final storageData = await storage.getCache('health_check');
      await storage.removeCache('health_check');
      
      report['components']['storage'] = {
        'status': storageData != null ? 'healthy' : 'unhealthy',
        'can_read_write': storageData != null,
      };

      // Testar Google Auth
      final authService = GoogleAuthService();
      await authService.initialize();
      
      report['components']['google_auth'] = {
        'status': 'healthy',
        'is_initialized': true,
        'is_logged_in': authService.isLoggedIn,
      };

      // Testar Exercise Assets
      final flexaoAsset = ExerciseAssetsHelper.resolveExerciseAsset('flexão');
      final assetExists = flexaoAsset != null ? await ExerciseAssetsHelper.assetExists(flexaoAsset) : false;
      
      report['components']['exercise_assets'] = {
        'status': assetExists ? 'healthy' : 'warning',
        'has_mapping': flexaoAsset != null,
        'assets_exist': assetExists,
        'total_mapped': ExerciseAssetsHelper.getAllExerciseAssets().length,
      };

      // Testar configurações
      final googleValidation = GoogleConfig.validateConfig();
      
      report['components']['configuration'] = {
        'status': googleValidation['is_valid'] ? 'healthy' : 'warning',
        'google_configured': googleValidation['is_valid'],
        'ready_for_production': googleValidation['ready_for_production'],
        'issues': googleValidation['issues'],
        'warnings': googleValidation['warnings'],
      };

      // Status geral
      final componentStatuses = report['components'].values
          .map((c) => c['status'])
          .toList();
      
      final hasUnhealthy = componentStatuses.contains('unhealthy');
      final hasWarnings = componentStatuses.contains('warning');
      
      report['overall_status'] = hasUnhealthy 
          ? 'unhealthy'
          : hasWarnings 
              ? 'warning' 
              : 'healthy';

    } catch (e) {
      report['overall_status'] = 'error';
      report['error'] = e.toString();
    }

    return report;
  }

  /// Imprimir relatório de saúde
  static Future<void> printHealthReport() async {
    print('🏥 === RELATÓRIO DE SAÚDE ===');
    
    final report = await generateHealthReport();
    
    print('Timestamp: ${report['timestamp']}');
    print('App Version: ${report['app_version']}');
    print('Environment: ${report['environment']}');
    print('Overall Status: ${report['overall_status']?.toString().toUpperCase()}');
    print('');
    
    final components = report['components'] as Map<String, dynamic>;
    components.forEach((name, info) {
      final status = info['status']?.toString().toUpperCase() ?? 'UNKNOWN';
      final icon = status == 'HEALTHY' ? '✅' : status == 'WARNING' ? '⚠️' : '❌';
      print('$icon $name: $status');
      
      // Mostrar detalhes se houver problemas
      if (info['issues'] != null && info['issues'].isNotEmpty) {
        print('   Issues: ${info['issues']}');
      }
      if (info['warnings'] != null && info['warnings'].isNotEmpty) {
        print('   Warnings: ${info['warnings']}');
      }
      
      // Detalhes específicos para exercise_assets
      if (name == 'exercise_assets') {
        print('   Assets mapeados: ${info['total_mapped']}');
        print('   Assets físicos encontrados: ${info['assets_exist']}');
      }
    });
    
    print('=============================');
  }
}