import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/trial_model.dart';
import 'storage_service.dart';

/// Serviço para gerenciar trial de 7 dias e funcionalidades premium
class TrialService {
  // ===== SINGLETON =====
  static final TrialService _instance = TrialService._internal();
  factory TrialService() => _instance;
  TrialService._internal();

  // ===== CONSTANTES =====
  static const int trialDurationDays = 7;
  static const String _trialStartKey = 'trial_start_date';
  static const String _trialStatusKey = 'trial_status';
  static const String _premiumStatusKey = 'premium_status';

  /// Iniciar trial para novo usuário
  Future<TrialModel> startTrial(UserModel user) async {
    try {
      final now = DateTime.now();
      final trialEnd = now.add(const Duration(days: trialDurationDays));
      
      final trial = TrialModel(
        userId: user.id,
        startDate: now,
        endDate: trialEnd,
        isActive: true,
        isPremium: false,
        daysRemaining: trialDurationDays,
      );
      
      // Salvar dados do trial localmente
      await _saveTrialData(trial);
      
      if (kDebugMode) {
        print('✅ Trial iniciado para usuário ${user.name}');
        print('📅 Início: ${now.toIso8601String()}');
        print('📅 Fim: ${trialEnd.toIso8601String()}');
      }
      
      return trial;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao iniciar trial: $e');
      rethrow;
    }
  }

  /// Verificar status atual do trial
  Future<TrialModel?> checkTrialStatus(UserModel user) async {
    try {
      // Primeiro verificar se usuário é premium
      if (user.isPremium) {
        return TrialModel(
          userId: user.id,
          startDate: user.trialStartedAt ?? DateTime.now(),
          endDate: user.premiumExpiresAt,
          isActive: true,
          isPremium: true,
          daysRemaining: -1, // Premium não tem limite
        );
      }
      
      // Verificar trial
      if (user.trialStartedAt != null) {
        final now = DateTime.now();
        final trialEnd = user.trialStartedAt!.add(const Duration(days: trialDurationDays));
        final isActive = now.isBefore(trialEnd);
        final daysRemaining = isActive ? trialEnd.difference(now).inDays + 1 : 0;
        
        final trial = TrialModel(
          userId: user.id,
          startDate: user.trialStartedAt!,
          endDate: trialEnd,
          isActive: isActive,
          isPremium: false,
          daysRemaining: daysRemaining,
        );
        
        // Salvar status atualizado
        await _saveTrialData(trial);
        
        return trial;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao verificar trial: $e');
      return null;
    }
  }

  /// Verificar se usuário tem acesso premium
  bool hasAccess(UserModel user) {
    if (user.isPremium) return true;
    if (user.isInTrial) return true;
    return false;
  }

  /// Verificar se trial está próximo do fim (2 dias ou menos)
  bool isTrialEndingSoon(UserModel user) {
    if (user.isPremium || !user.isInTrial) return false;
    return user.trialDaysLeft <= 2;
  }

  /// Verificar se trial acabou de começar (primeiro dia)
  bool isTrialJustStarted(UserModel user) {
    if (!user.isInTrial || user.trialStartedAt == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(user.trialStartedAt!);
    return difference.inHours < 24;
  }

  /// Obter mensagem motivacional baseada no status
  String getMotivationalMessage(UserModel user) {
    if (user.isPremium) {
      return 'Aproveite todos os treinos premium!';
    } else if (user.isInTrial) {
      if (isTrialJustStarted(user)) {
        return 'Bem-vindo! Explore todos os recursos grátis!';
      } else if (isTrialEndingSoon(user)) {
        return 'Últimos dias do trial. Que tal assinar?';
      } else {
        return 'Aproveite seu trial premium!';
      }
    } else {
      return 'Assine para acessar treinos exclusivos!';
    }
  }

  /// Obter texto do call-to-action
  String getCtaText(UserModel user) {
    if (user.isPremium) {
      return 'Ver Treinos';
    } else if (user.isInTrial) {
      if (isTrialEndingSoon(user)) {
        return 'Assinar Agora';
      } else {
        return 'Explorar Treinos';
      }
    } else {
      return 'Assinar Premium';
    }
  }

  /// Verificar se funcionalidade está disponível
  bool isFeatureAvailable(UserModel user, String feature) {
    // Se é premium, todas as funcionalidades estão disponíveis
    if (user.isPremium) return true;
    
    // Se está em trial, algumas funcionalidades podem estar disponíveis
    if (user.isInTrial) {
      return _isFeatureAvailableInTrial(feature);
    }
    
    // Se não tem acesso, apenas funcionalidades básicas
    return _isBasicFeature(feature);
  }

  /// Verificar se funcionalidade está disponível no trial
  bool _isFeatureAvailableInTrial(String feature) {
    // Durante o trial, usuário tem acesso a quase tudo
    const trialFeatures = {
      'create_workout',
      'view_workouts',
      'basic_exercises',
      'progress_tracking',
      'basic_reports',
    };
    
    const premiumOnlyFeatures = {
      'advanced_reports',
      'export_data',
      'custom_templates',
      'ai_recommendations',
    };
    
    // No trial, liberar tudo exceto funcionalidades premium exclusivas
    return !premiumOnlyFeatures.contains(feature);
  }

  /// Verificar se é funcionalidade básica (sem trial/premium)
  bool _isBasicFeature(String feature) {
    const basicFeatures = {
      'view_demo_workouts',
      'basic_info',
      'account_settings',
    };
    
    return basicFeatures.contains(feature);
  }

  /// Salvar dados do trial localmente
  Future<void> _saveTrialData(TrialModel trial) async {
    try {
      final storage = StorageService();
      
      await storage.saveCache(
        _trialStatusKey,
        trial.toJson(),
        expiry: const Duration(hours: 1), // Cache por 1 hora
      );
      
      if (kDebugMode) print('✅ Dados do trial salvos localmente');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao salvar dados do trial: $e');
    }
  }

  /// Carregar dados do trial salvos localmente
  Future<TrialModel?> _loadTrialData() async {
    try {
      final storage = StorageService();
      final data = await storage.getCache(_trialStatusKey);
      
      if (data != null) {
        return TrialModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao carregar dados do trial: $e');
      return null;
    }
  }

  /// Limpar dados do trial
  Future<void> clearTrialData() async {
    try {
      final storage = StorageService();
      await storage.removeCache(_trialStatusKey);
      await storage.removeCache(_premiumStatusKey);
      
      if (kDebugMode) print('🗑️ Dados do trial limpos');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao limpar dados do trial: $e');
    }
  }

  /// Calcular estatísticas do trial
  Map<String, dynamic> getTrialStats(UserModel user) {
    if (user.trialStartedAt == null) {
      return {
        'has_trial': false,
        'is_active': false,
        'days_used': 0,
        'days_remaining': 0,
        'usage_percentage': 0.0,
      };
    }
    
    final now = DateTime.now();
    final trialStart = user.trialStartedAt!;
    final trialEnd = trialStart.add(const Duration(days: trialDurationDays));
    
    final totalDays = trialDurationDays;
    final daysUsed = now.difference(trialStart).inDays;
    final daysRemaining = user.isInTrial ? user.trialDaysLeft : 0;
    final usagePercentage = (daysUsed / totalDays).clamp(0.0, 1.0);
    
    return {
      'has_trial': true,
      'is_active': user.isInTrial,
      'is_premium': user.isPremium,
      'total_days': totalDays,
      'days_used': daysUsed,
      'days_remaining': daysRemaining,
      'usage_percentage': usagePercentage,
      'trial_start': trialStart.toIso8601String(),
      'trial_end': trialEnd.toIso8601String(),
      'ending_soon': isTrialEndingSoon(user),
      'just_started': isTrialJustStarted(user),
    };
  }

  /// Simular upgrade para premium (para desenvolvimento)
  Future<UserModel> simulateUpgradeToPremium(UserModel user) async {
    if (kDebugMode) {
      print('🎯 Simulando upgrade para premium (desenvolvimento)');
      
      // Simular usuário premium
      final premiumUser = user.copyWith(
        isPremium: true,
        premiumExpiresAt: DateTime.now().add(const Duration(days: 365)),
      );
      
      return premiumUser;
    }
    
    return user;
  }

  /// Verificar se deve mostrar offer de upgrade
  bool shouldShowUpgradeOffer(UserModel user) {
    // Não mostrar se já é premium
    if (user.isPremium) return false;
    
    // Mostrar se trial expirou
    if (!user.isInTrial) return true;
    
    // Mostrar se trial está acabando
    if (isTrialEndingSoon(user)) return true;
    
    return false;
  }

  /// Obter preço para exibição (placeholder)
  Map<String, dynamic> getPricingInfo() {
    return {
      'monthly': {
        'price': 'R\$ 9,90',
        'period': 'mês',
        'features': [
          'Treinos ilimitados',
          'Relatórios detalhados',
          'Sincronização na nuvem',
          'Suporte premium',
        ],
      },
      'annual': {
        'price': 'R\$ 89,90',
        'period': 'ano',
        'monthly_equivalent': 'R\$ 7,49/mês',
        'discount': '25% OFF',
        'features': [
          'Treinos ilimitados',
          'Relatórios detalhados',
          'Sincronização na nuvem',
          'Suporte premium',
          'Funcionalidades exclusivas',
        ],
      },
    };
  }
}