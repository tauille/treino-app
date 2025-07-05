// lib/core/constants/google_config.dart

class GoogleConfig {
  // ⚠️ VOCÊ PRECISA CONFIGURAR NO GOOGLE CONSOLE
  // https://console.developers.google.com/
  
  // Client ID do Google (Android)
  static const String androidClientId = 'SEU_ANDROID_CLIENT_ID.apps.googleusercontent.com';
  
  // Client ID do Google (iOS)  
  static const String iosClientId = 'SEU_IOS_CLIENT_ID.apps.googleusercontent.com';
  
  // Client ID do Google (Web) - para desenvolvimento
  static const String webClientId = 'SEU_WEB_CLIENT_ID.apps.googleusercontent.com';

  // ========================================
  // CONFIGURAÇÕES DO GOOGLE SIGN IN
  // ========================================
  
  /// Escopos solicitados ao Google
  static const List<String> scopes = [
    'email',
    'profile',
  ];

  /// Configuração dos dados solicitados
  static const bool requestEmail = true;
  static const bool requestProfile = true;
  static const bool requestIdToken = true;
  
  // ========================================
  // CONFIGURAÇÕES DE TRIAL
  // ========================================
  
  /// Duração do trial em dias
  static const int trialDurationDays = 7;
  
  /// Mensagem de boas-vindas do trial
  static const String trialWelcomeMessage = '''
🎉 Bem-vindo ao Treino App!

Experimente GRÁTIS por 7 dias todos os recursos premium:

✅ Treinos ilimitados
✅ Exercícios personalizados  
✅ Acompanhamento de progresso
✅ Sincronização na nuvem

Após o período de teste, você pode continuar com a versão gratuita ou fazer upgrade para Premium.
''';

  /// Mensagem de confirmação do trial
  static const String trialConfirmMessage = '''
Deseja começar seu teste grátis de 7 dias?

Você pode cancelar a qualquer momento e não será cobrado nada durante o período de teste.
''';

  // ========================================
  // TEXTOS DA INTERFACE
  // ========================================
  
  static const String loginWithGoogleText = 'Entrar com Google';
  static const String startTrialText = 'Começar Teste Grátis';
  static const String skipTrialText = 'Talvez Depois';
  static const String continueText = 'Continuar';
  static const String cancelText = 'Cancelar';
  
  // ========================================
  // CONFIGURAÇÕES DE DEBUG
  // ========================================
  
  /// Habilita logs detalhados do Google Auth
  static const bool enableDebugLogs = true;
  
  /// Simula login offline (apenas para desenvolvimento)
  static const bool simulateOfflineLogin = false;
}

// ========================================
// CLASSE PARA ARMAZENAR DADOS DO GOOGLE USER
// ========================================

class GoogleUserData {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final String? idToken;
  final String? accessToken;

  GoogleUserData({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.idToken,
    this.accessToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photo_url': photoUrl,
      'id_token': idToken,
      'access_token': accessToken,
    };
  }

  factory GoogleUserData.fromJson(Map<String, dynamic> json) {
    return GoogleUserData(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photo_url'],
      idToken: json['id_token'],
      accessToken: json['access_token'],
    );
  }

  @override
  String toString() {
    return 'GoogleUserData(id: $id, email: $email, name: $name)';
  }
}