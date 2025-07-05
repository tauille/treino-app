// lib/core/services/trial_service.dart
// ⚠️ VERSÃO TEMPORÁRIA SIMPLIFICADA - Para fazer o app rodar

import '../../models/user_model.dart';

class TrialService {
  static const int trialDurationDays = 30;

  // ========================================
  // VERIFICAÇÕES DE TRIAL
  // ========================================

  /// Verifica se o usuário pode iniciar trial
  bool canStartTrial(User? user) {
    if (user == null) return false;
    return user.hasNeverUsedTrial; // Usando o getter que acabamos de adicionar
  }

  /// Verifica se o usuário está em trial ativo
  bool isInActiveTrial(User? user) {
    if (user == null) return false;
    return user.isInTrial; // Usando o getter que acabamos de adicionar
  }

  /// Verifica se o trial expirou
  bool isTrialExpired(User? user) {
    if (user == null) return false;
    return user.isTrialExpired;
  }

  /// Verifica se o usuário tem acesso premium (trial ou pagamento)
  bool hasAdvancedAccess(User? user) {
    if (user == null) return false;
    return user.canUseAdvancedFeatures;
  }

  // ========================================
  // INFORMAÇÕES DE TRIAL
  // ========================================

  /// Obter dias restantes do trial
  int getTrialDaysRemaining(User? user) {
    if (user == null) return 0;
    return user.trialDaysRemaining;
  }

  /// Obter data de expiração do trial
  DateTime? getTrialExpirationDate(User? user) {
    if (user?.trialStartedAt == null) return null;
    return user!.trialStartedAt!.add(const Duration(days: trialDurationDays));
  }

  /// Obter status do trial em texto
  String getTrialStatusText(User? user) {
    if (user == null) return 'Usuário não logado';
    return user.trialStatusText;
  }

  /// Obter informações completas do trial
  Map<String, dynamic> getTrialInfo(User? user) {
    if (user == null) {
      return {
        'canStartTrial': false,
        'isInTrial': false,
        'isTrialExpired': false,
        'daysRemaining': 0,
        'statusText': 'Usuário não logado',
        'hasAdvancedAccess': false,
      };
    }

    return {
      'canStartTrial': canStartTrial(user),
      'isInTrial': isInActiveTrial(user),
      'isTrialExpired': isTrialExpired(user),
      'daysRemaining': getTrialDaysRemaining(user),
      'statusText': getTrialStatusText(user),
      'hasAdvancedAccess': hasAdvancedAccess(user),
      'expirationDate': getTrialExpirationDate(user)?.toIso8601String(),
    };
  }

  // ========================================
  // AÇÕES DE TRIAL (simplificadas)
  // ========================================

  /// Iniciar trial (retorna novo usuário)
  User? startTrial(User? user) {
    if (user == null || !canStartTrial(user)) return user;
    return user.startTrial();
  }

  /// Converter para premium (retorna novo usuário)
  User? upgradeToPremium(User? user, {DateTime? expiresAt}) {
    if (user == null) return user;
    return user.upgradeToPremium(expiresAt: expiresAt);
  }

  // ========================================
  // MÉTODOS DE CONVENIÊNCIA
  // ========================================

  /// Verificar se feature está disponível
  bool isFeatureAvailable(User? user, String featureName) {
    // Por enquanto, todas as features dependem de acesso avançado
    return hasAdvancedAccess(user);
  }

  /// Obter lista de features disponíveis
  List<String> getAvailableFeatures(User? user) {
    if (!hasAdvancedAccess(user)) {
      return ['basic_workouts', 'basic_exercises'];
    }
    
    return [
      'basic_workouts',
      'basic_exercises',
      'advanced_workouts',
      'custom_exercises',
      'progress_tracking',
      'export_data',
      'premium_support',
    ];
  }

  /// Verificar se deve mostrar upgrade prompt
  bool shouldShowUpgradePrompt(User? user) {
    if (user == null) return false;
    
    // Mostrar se trial está próximo do fim (últimos 3 dias)
    if (isInActiveTrial(user)) {
      return getTrialDaysRemaining(user) <= 3;
    }
    
    // Mostrar se trial expirou
    return isTrialExpired(user);
  }

  // ========================================
  // DEBUG E TESTES
  // ========================================

  /// Imprimir informações de debug
  void printTrialDebug(User? user) {
    final info = getTrialInfo(user);
    
    print('🎯 Trial Debug Info:');
    print('   User: ${user?.name ?? 'null'}');
    print('   Can Start Trial: ${info['canStartTrial']}');
    print('   Is In Trial: ${info['isInTrial']}');
    print('   Is Trial Expired: ${info['isTrialExpired']}');
    print('   Days Remaining: ${info['daysRemaining']}');
    print('   Status: ${info['statusText']}');
    print('   Has Advanced Access: ${info['hasAdvancedAccess']}');
    print('   Should Show Upgrade: ${shouldShowUpgradePrompt(user)}');
    print('   Available Features: ${getAvailableFeatures(user).join(', ')}');
  }

  /// Simular trial para testes
  User? simulateTrial(User? user, {int daysIntoTrial = 0}) {
    if (user == null) return null;
    
    final trialStart = DateTime.now().subtract(Duration(days: daysIntoTrial));
    
    return user.copyWith(
      trialStartedAt: trialStart,
      isPremium: false,
    );
  }

  /// Simular premium para testes  
  User? simulatePremium(User? user, {DateTime? expiresAt}) {
    if (user == null) return null;
    
    return user.copyWith(
      isPremium: true,
      premiumExpiresAt: expiresAt,
    );
  }
}