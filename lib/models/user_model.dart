import 'dart:convert';

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

  // ========================================
  // FACTORY CONSTRUCTORS
  // ========================================

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isEmailVerified: json['email_verified_at'] != null || json['isEmailVerified'] == true,
      createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
      emailVerifiedAt: _parseDateTime(json['email_verified_at'] ?? json['emailVerifiedAt']),
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      trialStartedAt: _parseDateTime(json['trial_started_at'] ?? json['trialStartedAt']),
      premiumExpiresAt: _parseDateTime(json['premium_expires_at'] ?? json['premiumExpiresAt']),
    );
  }

  /// Factory específico para dados do StorageService (SharedPreferences)
  factory User.fromStorageData(Map<String, dynamic> data) {
    return User(
      id: data['userId'] is String ? int.parse(data['userId']) : data['userId'],
      name: data['userName'] ?? '',
      email: data['userEmail'] ?? '',
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      emailVerifiedAt: _parseDateTime(data['emailVerifiedAt']),
      isPremium: data['isPremium'] ?? false,
      trialStartedAt: _parseDateTime(data['trialStartedAt']),
      premiumExpiresAt: _parseDateTime(data['premiumExpiresAt']),
    );
  }

  /// Helper para parsing seguro de DateTime
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('❌ Erro ao parsear data: $value');
        return null;
      }
    }
    return null;
  }

  // ========================================
  // SERIALIZAÇÃO
  // ========================================

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

  /// Converte para formato do StorageService (SharedPreferences)
  Map<String, dynamic> toStorageData() {
    return {
      'userId': id,
      'userName': name,
      'userEmail': email,
      'isEmailVerified': isEmailVerified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
      'trialStartedAt': trialStartedAt?.toIso8601String(),
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
    };
  }

  /// Converte para JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Cria User a partir de JSON string
  static User fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return User.fromJson(json);
  }

  // ========================================
  // GETTERS COMPUTADOS PARA PREMIUM/TRIAL
  // ========================================

  bool get hasActiveTrial {
    if (isPremium || trialStartedAt == null) return false;
    
    final trialEndDate = trialStartedAt!.add(const Duration(days: 30));
    return DateTime.now().isBefore(trialEndDate);
  }

  // ✅ ADICIONADO: Getter que estava faltando
  bool get isInTrial => hasActiveTrial;

  // ✅ ADICIONADO: Getter que estava faltando  
  bool get hasNeverUsedTrial => trialStartedAt == null && !isPremium;

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

  String get accountStatus {
    if (hasActivePremium) {
      if (premiumExpiresAt == null) return 'Premium Vitalício';
      final daysUntilExpiry = premiumExpiresAt!.difference(DateTime.now()).inDays;
      return 'Premium ($daysUntilExpiry dias restantes)';
    }
    if (hasActiveTrial) return 'Trial ($trialDaysRemaining dias restantes)';
    if (trialStartedAt != null) return 'Trial Expirado';
    return 'Conta Gratuita';
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

  // ========================================
  // MÉTODOS UTILITÁRIOS
  // ========================================

  String get initials {
    final names = name.trim().split(' ');
    if (names.isEmpty) return 'US';
    if (names.length == 1) {
      return names[0].length >= 2 
        ? names[0].substring(0, 2).toUpperCase()
        : names[0].toUpperCase();
    }
    return '${names.first[0]}${names.last[0]}'.toUpperCase();
  }

  String get firstName => name.split(' ').first;

  String get lastName {
    final names = name.split(' ');
    return names.length > 1 ? names.last : '';
  }

  String get fullName => name;

  String get displayName => firstName.isNotEmpty ? firstName : email;

  // ========================================
  // TRIAL INFO PARA UI
  // ========================================

  String get trialStatusText {
    if (hasActivePremium) return 'Premium Ativo';
    if (hasActiveTrial) return 'Trial Ativo ($trialDaysRemaining dias restantes)';
    if (trialStartedAt != null) return 'Trial Expirado';
    return 'Trial Disponível (30 dias grátis)';
  }

  String get subscriptionStatusText {
    if (hasActivePremium) {
      if (premiumExpiresAt == null) return 'Premium Vitalício';
      return 'Premium até ${_formatDate(premiumExpiresAt!)}';
    }
    if (hasActiveTrial) {
      final trialEndDate = trialStartedAt!.add(const Duration(days: 30));
      return 'Trial até ${_formatDate(trialEndDate)}';
    }
    return 'Conta Gratuita';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ========================================
  // VALIDAÇÕES
  // ========================================

  bool get isValid => id > 0 && name.isNotEmpty && email.isNotEmpty;

  bool get hasValidEmail => email.contains('@') && email.contains('.');

  bool get needsEmailVerification => !isEmailVerified && hasValidEmail;

  bool get canStartTrial => !isPremium && trialStartedAt == null;

  bool get isTrialExpired => trialStartedAt != null && !hasActiveTrial && !isPremium;

  // ========================================
  // COPYSWITH PARA ATUALIZAÇÕES
  // ========================================

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

  // ========================================
  // MÉTODOS DE CONVENIÊNCIA
  // ========================================

  /// Atualiza o status do trial
  User startTrial() {
    if (canStartTrial) {
      return copyWith(trialStartedAt: DateTime.now());
    }
    return this;
  }

  /// Atualiza para premium
  User upgradeToPremium({DateTime? expiresAt}) {
    return copyWith(
      isPremium: true,
      premiumExpiresAt: expiresAt,
    );
  }

  /// Marca email como verificado
  User verifyEmail() {
    return copyWith(
      isEmailVerified: true,
      emailVerifiedAt: DateTime.now(),
    );
  }

  /// Cancela premium (mantém até data de expiração)
  User cancelPremium() {
    return copyWith(
      premiumExpiresAt: premiumExpiresAt ?? DateTime.now(),
    );
  }

  // ========================================
  // OVERRIDE METHODS
  // ========================================

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id && other.email == email;
  }

  @override
  int get hashCode => id.hashCode ^ email.hashCode;

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, accountType: $accountType)';
  }
}