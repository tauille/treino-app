// lib/models/trial_model.dart

/// Modelo para gerenciar dados do período de trial
class Trial {
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final bool isActive;
  final bool hasExpired;

  Trial({
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.isActive,
    required this.hasExpired,
  });

  /// Cria Trial a partir de datas
  factory Trial.fromDates(DateTime startDate, DateTime endDate) {
    final now = DateTime.now();
    final durationDays = endDate.difference(startDate).inDays;
    final isActive = now.isAfter(startDate) && now.isBefore(endDate);
    final hasExpired = now.isAfter(endDate);

    return Trial(
      startDate: startDate,
      endDate: endDate,
      durationDays: durationDays,
      isActive: isActive,
      hasExpired: hasExpired,
    );
  }

  /// Cria Trial para começar agora com duração em dias
  factory Trial.startNow(int durationDays) {
    final startDate = DateTime.now();
    final endDate = startDate.add(Duration(days: durationDays));

    return Trial.fromDates(startDate, endDate);
  }

  /// Cria Trial a partir do JSON
  factory Trial.fromJson(Map<String, dynamic> json) {
    final startDate = DateTime.parse(json['start_date']);
    final endDate = DateTime.parse(json['end_date']);
    
    return Trial.fromDates(startDate, endDate);
  }

  /// Converte Trial para JSON
  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'duration_days': durationDays,
      'is_active': isActive,
      'has_expired': hasExpired,
    };
  }

  // ========================================
  // PROPRIEDADES CALCULADAS
  // ========================================

  /// Dias restantes do trial
  int get daysRemaining {
    if (!isActive) return 0;
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays;
  }

  /// Horas restantes do trial
  int get hoursRemaining {
    if (!isActive) return 0;
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inHours;
  }

  /// Progresso do trial (0.0 a 1.0)
  double get progress {
    final now = DateTime.now();
    final totalDuration = endDate.difference(startDate);
    final usedDuration = now.difference(startDate);
    
    if (usedDuration.inMilliseconds <= 0) return 0.0;
    if (usedDuration >= totalDuration) return 1.0;
    
    return usedDuration.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// Porcentagem do trial (0 a 100)
  int get progressPercentage => (progress * 100).round();

  /// Status do trial em texto
  String get statusText {
    if (hasExpired) return 'Expirado';
    if (isActive) return 'Ativo ($daysRemaining dias restantes)';
    return 'Não iniciado';
  }

  /// Tempo restante formatado
  String get timeRemainingFormatted {
    if (!isActive) return '';
    
    if (daysRemaining > 0) {
      return '$daysRemaining dias restantes';
    } else if (hoursRemaining > 0) {
      return '$hoursRemaining horas restantes';
    } else {
      return 'Expira hoje';
    }
  }

  // ========================================
  // MÉTODOS DE VERIFICAÇÃO
  // ========================================

  /// Verifica se o trial está prestes a expirar (menos de 24h)
  bool get isExpiringSoon {
    if (!isActive) return false;
    return hoursRemaining <= 24;
  }

  /// Verifica se é o último dia do trial
  bool get isLastDay {
    if (!isActive) return false;
    return daysRemaining <= 1;
  }

  /// Verifica se acabou de começar (menos de 24h)
  bool get isJustStarted {
    if (!isActive) return false;
    final now = DateTime.now();
    final timeSinceStart = now.difference(startDate);
    return timeSinceStart.inHours <= 24;
  }

  @override
  String toString() {
    return 'Trial(daysRemaining: $daysRemaining, isActive: $isActive, progress: ${progressPercentage}%)';
  }
}

// ========================================
// CONFIGURAÇÃO DE TRIAL
// ========================================

class TrialConfig {
  final int durationDays;
  final List<String> features;
  final String welcomeMessage;
  final String expirationWarning;

  const TrialConfig({
    required this.durationDays,
    required this.features,
    required this.welcomeMessage,
    required this.expirationWarning,
  });

  /// Configuração padrão do trial
  static const TrialConfig defaultConfig = TrialConfig(
    durationDays: 7,
    features: [
      'Treinos ilimitados',
      'Exercícios personalizados',
      'Acompanhamento de progresso',
      'Sincronização na nuvem',
      'Suporte premium',
    ],
    welcomeMessage: '''
🎉 Bem-vindo ao Treino App!

Experimente GRÁTIS por 7 dias todos os recursos premium.
''',
    expirationWarning: '''
⚠️ Seu trial expira em breve!

Para continuar usando todos os recursos, considere fazer upgrade para Premium.
''',
  );

  /// Cria Trial com esta configuração
  Trial createTrial() {
    return Trial.startNow(durationDays);
  }
}

// ========================================
// STATUS DE TRIAL DO USUÁRIO
// ========================================

enum TrialStatus {
  /// Usuário nunca usou trial
  neverUsed,
  
  /// Trial ativo
  active,
  
  /// Trial expirado
  expired,
  
  /// Usuário é premium (não precisa de trial)
  premium,
}

extension TrialStatusExtension on TrialStatus {
  String get displayName {
    switch (this) {
      case TrialStatus.neverUsed:
        return 'Disponível';
      case TrialStatus.active:
        return 'Ativo';
      case TrialStatus.expired:
        return 'Expirado';
      case TrialStatus.premium:
        return 'Premium';
    }
  }

  bool get canStartTrial => this == TrialStatus.neverUsed;
  bool get hasAccess => this == TrialStatus.active || this == TrialStatus.premium;
}