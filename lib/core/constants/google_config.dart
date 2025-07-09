import 'package:flutter/foundation.dart';

/// Configurações do Google Sign In e Google Play
class GoogleConfig {
  // ===== GOOGLE SIGN IN =====
  
  // TODO: Substituir pelos seus Client IDs reais do Google Cloud Console
  static const String androidClientId = '96714229179-mof7pllbgfsep2k4tv8dbrc553pbbi85.apps.googleusercontent.com'; // ✅ JÁ CORRETO
  static const String iosClientId = '96714229179-mof7pllbgfsep2k4tv8dbrc553pbbi85.apps.googleusercontent.com';     // ✅ TROCAR
  static const String webClientId = '96714229179-mof7pllbgfsep2k4tv8dbrc553pbbi85.apps.googleusercontent.com';     // ✅ TROCAR
  
  /// Client ID baseado na plataforma
  static String get clientId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidClientId;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return iosClientId;
    } else {
      return webClientId;
    }
  }
  
  // ===== SCOPES DO GOOGLE =====
  static const List<String> scopes = [
    'email',
    'profile',
    'openid',
  ];
  
  // ===== GOOGLE PLAY BILLING =====
  
  // IDs dos produtos de assinatura (definidos no Google Play Console)
  static const String monthlySubscriptionId = 'treino_app_monthly';
  static const String annualSubscriptionId = 'treino_app_annual';
  
  // Lista de todos os produtos
  static const List<String> subscriptionIds = [
    monthlySubscriptionId,
    annualSubscriptionId,
  ];
  
  // ===== CONFIGURAÇÕES DE PREÇOS =====
  static const Map<String, Map<String, dynamic>> pricingInfo = {
    'monthly': {
      'id': monthlySubscriptionId,
      'price': 'R\$ 9,90',
      'period': 'mês',
      'description': 'Acesso completo por 1 mês',
      'features': [
        'Treinos ilimitados',
        'Relatórios detalhados',
        'Sincronização na nuvem',
        'Suporte premium',
      ],
    },
    'annual': {
      'id': annualSubscriptionId,
      'price': 'R\$ 89,90',
      'period': 'ano',
      'monthly_equivalent': 'R\$ 7,49/mês',
      'discount': '25% OFF',
      'savings': 'Economize R\$ 29,90',
      'description': 'Acesso completo por 1 ano',
      'features': [
        'Treinos ilimitados',
        'Relatórios detalhados',
        'Sincronização na nuvem',
        'Suporte premium',
        'Funcionalidades exclusivas',
        'Backup automático',
      ],
    },
  };
  
  // ===== CONFIGURAÇÕES DE TRIAL =====
  static const int trialDurationDays = 7;
  static const String trialDescription = '7 dias grátis para testar todos os recursos premium';
  
  // ===== GOOGLE ANALYTICS =====
  // TODO: Adicionar seus IDs do Google Analytics se usar
  static const String googleAnalyticsId = 'G-XXXXXXXXXX';
  static const bool enableAnalytics = kReleaseMode;
  
  // ===== FIREBASE (se usar no futuro) =====
  static const String firebaseProjectId = 'treino-app-firebase';
  static const bool enableFirebase = false; // Manter false por enquanto
  
  // ===== CONFIGURAÇÕES DE DESENVOLVIMENTO =====
  
  /// Se deve usar valores de teste em desenvolvimento
  static const bool useTestValues = kDebugMode;
  
  /// URLs de teste para desenvolvimento
  static const String testAndroidClientId = 'TEST_ANDROID_CLIENT_ID';
  static const String testIosClientId = 'TEST_IOS_CLIENT_ID';
  
  /// Client ID para desenvolvimento
  static String get developmentClientId {
    if (useTestValues) {
      return defaultTargetPlatform == TargetPlatform.android 
          ? testAndroidClientId 
          : testIosClientId;
    }
    return clientId;
  }
  
  // ===== MÉTODOS UTILITÁRIOS =====
  
  /// Verificar se configuração do Google está válida
  static bool get isConfigured {
    return clientId.isNotEmpty && 
           !clientId.contains('SEU_') &&
           !clientId.contains('CLIENT_ID');
  }
  
  /// Verificar se Google Play Billing está configurado
  static bool get isBillingConfigured {
    return subscriptionIds.isNotEmpty &&
           !monthlySubscriptionId.contains('treino_app') &&
           !annualSubscriptionId.contains('treino_app');
  }
  
  /// Obter informações do produto por ID
  static Map<String, dynamic>? getProductInfo(String productId) {
    switch (productId) {
      case monthlySubscriptionId:
        return pricingInfo['monthly'];
      case annualSubscriptionId:
        return pricingInfo['annual'];
      default:
        return null;
    }
  }
  
  /// Obter produto recomendado (anual por ter desconto)
  static String get recommendedProductId => annualSubscriptionId;
  
  /// Obter produto mais barato (mensal)
  static String get cheapestProductId => monthlySubscriptionId;
  
  /// Verificar se produto é válido
  static bool isValidProductId(String productId) {
    return subscriptionIds.contains(productId);
  }
  
  /// Obter configuração de scopes personalizada
  static List<String> getScopesForFeature(String feature) {
    switch (feature) {
      case 'basic_login':
        return ['email', 'profile'];
      case 'calendar_integration':
        return [...scopes, 'https://www.googleapis.com/auth/calendar.readonly'];
      case 'drive_backup':
        return [...scopes, 'https://www.googleapis.com/auth/drive.file'];
      default:
        return scopes;
    }
  }
  
  /// Debug: Imprimir configurações atuais
  static void printConfig() {
    if (kDebugMode) {
      print('🔧 === GOOGLE CONFIG ===');
      print('Platform: $defaultTargetPlatform');
      print('Client ID: ${clientId.substring(0, 20)}...');
      print('Is Configured: $isConfigured');
      print('Billing Configured: $isBillingConfigured');
      print('Use Test Values: $useTestValues');
      print('Trial Duration: $trialDurationDays days');
      print('Scopes: $scopes');
      print('Products: $subscriptionIds');
      print('======================');
    }
  }
  
  /// Validar configuração completa
  static Map<String, dynamic> validateConfig() {
    final issues = <String>[];
    final warnings = <String>[];
    
    // Verificar Client IDs
    if (!isConfigured) {
      issues.add('Client IDs do Google não configurados');
    }
    
    // Verificar Billing
    if (!isBillingConfigured) {
      warnings.add('Google Play Billing não configurado (desenvolvimento OK)');
    }
    
    // Verificar scopes
    if (scopes.isEmpty) {
      issues.add('Nenhum scope definido');
    }
    
    // Verificar se tem pelo menos email e profile
    if (!scopes.contains('email') || !scopes.contains('profile')) {
      issues.add('Scopes básicos (email, profile) são obrigatórios');
    }
    
    return {
      'is_valid': issues.isEmpty,
      'issues': issues,
      'warnings': warnings,
      'ready_for_production': issues.isEmpty && isBillingConfigured,
    };
  }
  
  /// Obter configuração para google_sign_in package
  static Map<String, dynamic> getGoogleSignInConfig() {
    return {
      'scopes': scopes,
      'serverClientId': webClientId.isNotEmpty ? webClientId : null,
      'forceCodeForRefreshToken': true,
    };
  }
}

/// Configurações específicas do Android
class AndroidGoogleConfig {
  // SHA-1 fingerprints (para desenvolvimento e produção)
  static const List<String> sha1Fingerprints = [
    // TODO: Adicionar seus SHA-1 fingerprints
    'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD',
  ];
  
  /// Verificar se SHA-1 está configurado
  static bool get isSha1Configured {
    return sha1Fingerprints.isNotEmpty && 
           !sha1Fingerprints.first.contains('AA:BB:CC');
  }
}

/// Configurações específicas do iOS
class IOSGoogleConfig {
  // Bundle ID
  static const String bundleId = 'com.treinoapp.treino_app';
  
  // URL Scheme
  static const String urlScheme = 'com.googleusercontent.apps.SEU_CLIENT_ID';
  
  /// Verificar se Bundle ID está configurado
  static bool get isBundleIdConfigured {
    return bundleId.isNotEmpty && !bundleId.contains('treinoapp');
  }
  
  /// Obter URL scheme correto
  static String get correctUrlScheme {
    return 'com.googleusercontent.apps.${GoogleConfig.iosClientId}';
  }
}