class User {
  final int id;
  final String name;
  final String email;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime? emailVerifiedAt;
  
  // Campos premium/trial
  final bool isPremium;
  final DateTime? trialStartedAt;
  final DateTime? premiumExpiresAt;
  
  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isEmailVerified,
    required this.createdAt,
    this.emailVerifiedAt,
    this.isPremium = false,
    this.trialStartedAt,
    this.premiumExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      isEmailVerified: json['email_verified_at'] != null,
      createdAt: DateTime.parse(json['created_at']),
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      isPremium: json['is_premium'] ?? false,
      trialStartedAt: json['trial_started_at'] != null
          ? DateTime.parse(json['trial_started_at'])
          : null,
      premiumExpiresAt: json['premium_expires_at'] != null
          ? DateTime.parse(json['premium_expires_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_premium': isPremium,
      'trial_started_at': trialStartedAt?.toIso8601String(),
      'premium_expires_at': premiumExpiresAt?.toIso8601String(),
    };
  }

  // 🎯 Getters computados para premium/trial
  bool get hasActiveTrial {
    if (isPremium || trialStartedAt == null) return false;
    
    final trialEndDate = trialStartedAt!.add(const Duration(days: 30));
    return DateTime.now().isBefore(trialEndDate);
  }

  int get trialDaysRemaining {
    if (isPremium || trialStartedAt == null) return 0;
    
    final trialEndDate = trialStartedAt!.add(const Duration(days: 30));
    final daysRemaining = trialEndDate.difference(DateTime.now()).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  bool get hasActivePremium {
    if (!isPremium) return false;
    
    // Se não tem data de expiração, é premium vitalício
    if (premiumExpiresAt == null) return true;
    
    return DateTime.now().isBefore(premiumExpiresAt!);
  }

  bool get canUseAdvancedFeatures => hasActiveTrial || hasActivePremium;

  String get accountType {
    if (hasActivePremium) return 'Premium';
    if (hasActiveTrial) return 'Trial';
    return 'Gratuita';
  }

  String get memberSince {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays < 1) {
      return 'Hoje';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semana${weeks > 1 ? 's' : ''}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months mês${months > 1 ? 'es' : ''}';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ano${years > 1 ? 's' : ''}';
    }
  }

  // 👤 Métodos utilitários
  String get initials {
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].substring(0, 2).toUpperCase();
    }
    return '${names.first[0]}${names.last[0]}'.toUpperCase();
  }

  String get firstName => name.split(' ').first;

  // 🎯 Trial info para UI
  String get trialStatusText {
    if (hasActivePremium) return 'Premium Ativo';
    if (hasActiveTrial) return 'Trial Ativo ($trialDaysRemaining dias restantes)';
    if (trialStartedAt != null) return 'Trial Expirado';
    return 'Trial Disponível (30 dias grátis)';
  }

  // 🔄 copyWith para atualizações
  User copyWith({
    int? id,
    String? name,
    String? email,
    bool? isEmailVerified,
    DateTime? createdAt,
    DateTime? emailVerifiedAt,
    bool? isPremium,
    DateTime? trialStartedAt,
    DateTime? premiumExpiresAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      isPremium: isPremium ?? this.isPremium,
      trialStartedAt: trialStartedAt ?? this.trialStartedAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
    );
  }
}