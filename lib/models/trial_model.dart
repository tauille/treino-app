/// Modelo para gerenciar dados do trial de 7 dias
class TrialModel {
  final int userId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isPremium;
  final int daysRemaining;

  TrialModel({
    required this.userId,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isPremium,
    required this.daysRemaining,
  });

  /// Criar TrialModel a partir do JSON
  factory TrialModel.fromJson(Map<String, dynamic> json) {
    return TrialModel(
      userId: json['user_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'] ?? false,
      isPremium: json['is_premium'] ?? false,
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'is_premium': isPremium,
      'days_remaining': daysRemaining,
    };
  }

  /// Se tem acesso aos recursos
  bool get hasAccess => isPremium || isActive;

  /// Se o trial está próximo do fim (2 dias ou menos)
  bool get isEndingSoon => isActive && daysRemaining <= 2;

  /// Se o trial acabou de começar (primeiro dia)
  bool get justStarted {
    if (!isActive) return false;
    final now = DateTime.now();
    final difference = now.difference(startDate);
    return difference.inHours < 24;
  }

  /// Porcentagem de progresso do trial (0.0 a 1.0)
  double get progressPercentage {
    if (isPremium) return 1.0;
    if (endDate == null) return 0.0;
    
    final totalDuration = endDate!.difference(startDate).inDays;
    if (totalDuration <= 0) return 1.0;
    
    final now = DateTime.now();
    final elapsed = now.difference(startDate).inDays;
    
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  /// Horas restantes do trial
  int get hoursRemaining {
    if (isPremium || !isActive || endDate == null) return 0;
    
    final now = DateTime.now();
    final difference = endDate!.difference(now);
    
    return difference.inHours > 0 ? difference.inHours : 0;
  }

  /// Status textual do trial
  String get statusText {
    if (isPremium) {
      return 'Premium Ativo';
    } else if (isActive) {
      if (daysRemaining == 1) {
        return 'Último dia do trial';
      } else if (daysRemaining <= 0) {
        return 'Trial expirando hoje';
      } else {
        return 'Trial $daysRemaining dias';
      }
    } else {
      return 'Trial expirado';
    }
  }

  /// Cor do status (para UI)
  String get statusColor {
    if (isPremium) {
      return 'green';
    } else if (isActive) {
      if (isEndingSoon) {
        return 'orange';
      } else {
        return 'blue';
      }
    } else {
      return 'red';
    }
  }

  /// Ícone do status (para UI)
  String get statusIcon {
    if (isPremium) {
      return 'star';
    } else if (isActive) {
      if (isEndingSoon) {
        return 'schedule';
      } else {
        return 'access_time';
      }
    } else {
      return 'lock';
    }
  }

  /// Mensagem motivacional
  String get motivationalMessage {
    if (isPremium) {
      return 'Aproveite todos os recursos premium!';
    } else if (isActive) {
      if (justStarted) {
        return 'Bem-vindo! Explore todos os recursos grátis!';
      } else if (isEndingSoon) {
        return 'Últimos dias do trial. Que tal assinar?';
      } else {
        return 'Aproveite seu trial premium!';
      }
    } else {
      return 'Assine para acessar recursos exclusivos!';
    }
  }

  /// Call-to-action baseado no status
  String get ctaText {
    if (isPremium) {
      return 'Explorar Recursos';
    } else if (isActive) {
      if (isEndingSoon) {
        return 'Assinar Agora';
      } else {
        return 'Continuar Trial';
      }
    } else {
      return 'Assinar Premium';
    }
  }

  /// Data de expiração formatada
  String get expirationDateFormatted {
    if (endDate == null) return 'Indefinido';
    
    final day = endDate!.day.toString().padLeft(2, '0');
    final month = endDate!.month.toString().padLeft(2, '0');
    final year = endDate!.year;
    
    return '$day/$month/$year';
  }

  /// Tempo restante formatado
  String get timeRemainingFormatted {
    if (isPremium) return 'Ilimitado';
    if (!isActive) return 'Expirado';
    
    if (daysRemaining > 1) {
      return '$daysRemaining dias';
    } else if (daysRemaining == 1) {
      return '1 dia';
    } else {
      final hours = hoursRemaining;
      if (hours > 1) {
        return '$hours horas';
      } else if (hours == 1) {
        return '1 hora';
      } else {
        return 'Expirando';
      }
    }
  }

  /// Se deve mostrar aviso de expiração
  bool get shouldShowExpirationWarning {
    return isActive && (isEndingSoon || daysRemaining <= 0);
  }

  /// Se deve mostrar botão de upgrade
  bool get shouldShowUpgradeButton {
    return !isPremium && (isEndingSoon || !isActive);
  }

  /// Criar cópia do TrialModel com novos valores
  TrialModel copyWith({
    int? userId,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isPremium,
    int? daysRemaining,
  }) {
    return TrialModel(
      userId: userId ?? this.userId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      daysRemaining: daysRemaining ?? this.daysRemaining,
    );
  }

  /// Atualizar dados baseado na data atual
  TrialModel updateWithCurrentDate() {
    if (isPremium || endDate == null) return this;
    
    final now = DateTime.now();
    final newIsActive = now.isBefore(endDate!);
    final newDaysRemaining = newIsActive 
        ? endDate!.difference(now).inDays + 1
        : 0;
    
    return copyWith(
      isActive: newIsActive,
      daysRemaining: newDaysRemaining,
    );
  }

  @override
  String toString() {
    return 'TrialModel{userId: $userId, isActive: $isActive, isPremium: $isPremium, daysRemaining: $daysRemaining}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TrialModel &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          startDate == other.startDate;

  @override
  int get hashCode => userId.hashCode ^ startDate.hashCode;
}