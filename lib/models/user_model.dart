/// Modelo do usuário com funcionalidades de trial e premium
class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isPremium;
  final DateTime? trialStartedAt;
  final DateTime? premiumExpiresAt;
  final DateTime createdAt;
  final DateTime? emailVerifiedAt;
  final String? googleId;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.isPremium,
    this.trialStartedAt,
    this.premiumExpiresAt,
    required this.createdAt,
    this.emailVerifiedAt,
    this.googleId,
    this.avatarUrl,
  });

  /// Criar UserModel a partir do JSON da API
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isPremium: json['is_premium'] ?? false,
      trialStartedAt: json['trial_started_at'] != null 
          ? DateTime.parse(json['trial_started_at']) 
          : null,
      premiumExpiresAt: json['premium_expires_at'] != null 
          ? DateTime.parse(json['premium_expires_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      emailVerifiedAt: json['email_verified_at'] != null 
          ? DateTime.parse(json['email_verified_at']) 
          : null,
      googleId: json['google_id'],
      avatarUrl: json['avatar_url'],
    );
  }

  /// Converter UserModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'is_premium': isPremium,
      'trial_started_at': trialStartedAt?.toIso8601String(),
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'google_id': googleId,
      'avatar_url': avatarUrl,
    };
  }

  /// Verifica se o usuário está no período de trial
  bool get isInTrial {
    if (isPremium) return false;
    if (trialStartedAt == null) return false;
    
    final now = DateTime.now();
    final trialEnd = trialStartedAt!.add(const Duration(days: 7));
    return now.isBefore(trialEnd);
  }

  /// Dias restantes do trial
  int get trialDaysLeft {
    if (!isInTrial) return 0;
    
    final now = DateTime.now();
    final trialEnd = trialStartedAt!.add(const Duration(days: 7));
    final difference = trialEnd.difference(now);
    
    // Retorna pelo menos 1 dia se ainda está no trial
    return difference.inDays >= 0 ? difference.inDays + 1 : 0;
  }

  /// Horas restantes do trial (mais preciso)
  int get trialHoursLeft {
    if (!isInTrial) return 0;
    
    final now = DateTime.now();
    final trialEnd = trialStartedAt!.add(const Duration(days: 7));
    final difference = trialEnd.difference(now);
    
    return difference.inHours >= 0 ? difference.inHours : 0;
  }

  /// Se tem acesso premium (trial ou pago)
  bool get hasAccess => isPremium || isInTrial;

  /// Status do usuário (para UI)
  String get statusText {
    if (isPremium) {
      return 'Premium Ativo';
    } else if (isInTrial) {
      return 'Trial $trialDaysLeft dias';
    } else {
      return 'Trial Expirado';
    }
  }

  /// Cor do status (para UI)
  String get statusColor {
    if (isPremium) {
      return 'green';
    } else if (isInTrial) {
      return 'blue';
    } else {
      return 'red';
    }
  }

  /// Ícone do status (para UI)
  String get statusIcon {
    if (isPremium) {
      return 'star';
    } else if (isInTrial) {
      return 'access_time';
    } else {
      return 'lock';
    }
  }

  /// Primeiro nome do usuário
  String get firstName {
    return name.split(' ').first;
  }

  /// Iniciais do usuário (para avatar)
  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names.first[0]}${names.last[0]}'.toUpperCase();
    } else {
      return names.first.substring(0, 2).toUpperCase();
    }
  }

  /// Se o trial está próximo do fim (2 dias ou menos)
  bool get trialEndingSoon {
    return isInTrial && trialDaysLeft <= 2;
  }

  /// Se o trial acabou de começar (primeiro dia)
  bool get trialJustStarted {
    if (!isInTrial || trialStartedAt == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(trialStartedAt!);
    return difference.inHours < 24;
  }

  /// Data de expiração do trial
  DateTime? get trialExpiresAt {
    if (trialStartedAt == null) return null;
    return trialStartedAt!.add(const Duration(days: 7));
  }

  /// Se o usuário é novo (criado hoje)
  bool get isNewUser {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final createdDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return createdDay.isAtSameMomentAs(today);
  }

  /// Mensagem motivacional baseada no status
  String get motivationalMessage {
    if (isPremium) {
      return 'Aproveite todos os treinos premium!';
    } else if (isInTrial) {
      if (trialJustStarted) {
        return 'Bem-vindo! Explore todos os recursos grátis!';
      } else if (trialEndingSoon) {
        return 'Últimos dias do trial. Que tal assinar?';
      } else {
        return 'Aproveite seu trial premium!';
      }
    } else {
      return 'Assine para acessar treinos exclusivos!';
    }
  }

  /// Call-to-action baseado no status
  String get ctaText {
    if (isPremium) {
      return 'Ver Treinos';
    } else if (isInTrial) {
      if (trialEndingSoon) {
        return 'Assinar Agora';
      } else {
        return 'Explorar Treinos';
      }
    } else {
      return 'Assinar Premium';
    }
  }

  /// Criar cópia do UserModel com novos valores
  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    bool? isPremium,
    DateTime? trialStartedAt,
    DateTime? premiumExpiresAt,
    DateTime? createdAt,
    DateTime? emailVerifiedAt,
    String? googleId,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isPremium: isPremium ?? this.isPremium,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      createdAt: createdAt ?? this.createdAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      googleId: googleId ?? this.googleId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'UserModel{id: $id, name: $name, email: $email, isPremium: $isPremium, hasAccess: $hasAccess}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}