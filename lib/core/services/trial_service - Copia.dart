// lib/core/services/trial_service.dart

import '../../models/trial_model.dart';
import '../../models/user_model.dart';
import '../constants/google_config.dart';
import 'storage_service.dart';

class TrialService {
  static final TrialService _instance = TrialService._internal();
  factory TrialService() => _instance;
  TrialService._internal();

  final StorageService _storageService = StorageService();

  // Chaves para armazenamento local
  static const String _trialStartKey = 'trial_start_date';
  static const String _trialEndKey = 'trial_end_date';
  static const String _trialOfferedKey = 'trial_offered';
  static const String _trialAcceptedKey = 'trial_accepted';
  static const String _trialDeclinedKey = 'trial_declined';
  static const String _firstOpenKey = 'first_app_open';

  // ========================================
  // INICIALIZAÇÃO
  // ========================================

  Future<void> initialize() async {
    try {
      await _storageService.initialize();
      
      // Marcar primeira abertura do app se necessário
      await _markFirstOpenIfNeeded();
      
      print('⏰ TrialService inicializado');
    } catch (e) {
      print('❌ Erro ao inicializar TrialService: $e');
    }
  }

  // ========================================
  // VERIFICAÇÃO DE PRIMEIRA ABERTURA
  // ========================================

  /// Verifica se é a primeira vez que o app é aberto
  Future<bool> isFirstAppOpen() async {
    try {
      await _storageService.ensurePrefsInitialized();
      final firstOpen = _storageService.prefs?.getString(_firstOpenKey);
      return firstOpen == null;
    } catch (e) {
      print('❌ Erro ao verificar primeira abertura: $e');
      return false;
    }
  }

  /// Marca que o app foi aberto pela primeira vez
  Future<void> _markFirstOpenIfNeeded() async {
    try {
      if (await isFirstAppOpen()) {
        await _storageService.ensurePrefsInitialized();
        await _storageService.prefs?.setString(
          _firstOpenKey, 
          DateTime.now().toIso8601String()
        );
        print('📱 Primeira abertura do app marcada');
      }
    } catch (e) {
      print('❌ Erro ao marcar primeira abertura: $e');
    }
  }

  // ========================================
  // OFERTA DE TRIAL
  // ========================================

  /// Verifica se o trial já foi oferecido ao usuário
  Future<bool> wasTrialOffered() async {
    try {
      await _storageService.ensurePrefsInitialized();
      return _storageService.prefs?.getBool(_trialOfferedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o usuário aceitou o trial
  Future<bool> wasTrialAccepted() async {
    try {
      await _storageService.ensurePrefsInitialized();
      return _storageService.prefs?.getBool(_trialAcceptedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Verifica se o usuário recusou o trial
  Future<bool> wasTrialDeclined() async {
    try {
      await _storageService.ensurePrefsInitialized();
      return _storageService.prefs?.getBool(_trialDeclinedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Marca que a oferta de trial foi apresentada
  Future<void> markTrialOffered() async {
    try {
      await _storageService.ensurePrefsInitialized();
      await _storageService.prefs?.setBool(_trialOfferedKey, true);
      print('📋 Oferta de trial marcada como apresentada');
    } catch (e) {
      print('❌ Erro ao marcar oferta de trial: $e');
    }
  }

  /// Marca que o usuário aceitou o trial
  Future<void> markTrialAccepted() async {
    try {
      await _storageService.ensurePrefsInitialized();
      await _storageService.prefs?.setBool(_trialAcceptedKey, true);
      await _storageService.prefs?.setBool(_trialDeclinedKey, false);
      print('✅ Trial marcado como aceito');
    } catch (e) {
      print('❌ Erro ao marcar aceitação do trial: $e');
    }
  }

  /// Marca que o usuário recusou o trial
  Future<void> markTrialDeclined() async {
    try {
      await _storageService.ensurePrefsInitialized();
      await _storageService.prefs?.setBool(_trialDeclinedKey, true);
      await _storageService.prefs?.setBool(_trialAcceptedKey, false);
      print('❌ Trial marcado como recusado');
    } catch (e) {
      print('❌ Erro ao marcar recusa do trial: $e');
    }
  }

  // ========================================
  // INICIAR TRIAL
  // ========================================

  /// Inicia o período de trial
  Future<Trial?> startTrial({int? customDurationDays}) async {
    try {
      final durationDays = customDurationDays ?? GoogleConfig.trialDurationDays;
      final startDate = DateTime.now();
      final endDate = startDate.add(Duration(days: durationDays));

      // Salvar datas do trial
      await _storageService.ensurePrefsInitialized();
      await _storageService.prefs?.setString(
        _trialStartKey, 
        startDate.toIso8601String()
      );
      await _storageService.prefs?.setString(
        _trialEndKey, 
        endDate.toIso8601String()
      );

      // Marcar como aceito
      await markTrialAccepted();

      final trial = Trial.fromDates(startDate, endDate);
      
      print('🚀 Trial iniciado: ${trial.durationDays} dias');
      print('   Início: ${startDate.day}/${startDate.month}/${startDate.year}');
      print('   Fim: ${endDate.day}/${endDate.month}/${endDate.year}');

      return trial;
    } catch (e) {
      print('❌ Erro ao iniciar trial: $e');
      return null;
    }
  }

  // ========================================
  // OBTER TRIAL ATUAL
  // ========================================

  /// Obtém o trial atual do usuário (se houver)
  Future<Trial?> getCurrentTrial() async {
    try {
      await _storageService.ensurePrefsInitialized();
      final startDateStr = _storageService.prefs?.getString(_trialStartKey);
      final endDateStr = _storageService.prefs?.getString(_trialEndKey);

      if (startDateStr == null || endDateStr == null) {
        return null;
      }

      final startDate = DateTime.parse(startDateStr);
      final endDate = DateTime.parse(endDateStr);

      return Trial.fromDates(startDate, endDate);
    } catch (e) {
      print('❌ Erro ao obter trial atual: $e');
      return null;
    }
  }

  /// Verifica o status do trial baseado no usuário e dados locais
  Future<TrialStatus> getTrialStatus({User? user}) async {
    try {
      // Se usuário é premium, não precisa de trial
      if (user != null && user.isPremium) {
        return TrialStatus.premium;
      }

      // Verificar trial local
      final localTrial = await getCurrentTrial();
      if (localTrial != null) {
        if (localTrial.isActive) {
          return TrialStatus.active;
        } else if (localTrial.hasExpired) {
          return TrialStatus.expired;
        }
      }

      // Verificar trial do usuário no servidor
      if (user != null) {
        if (user.isInTrial) {
          return TrialStatus.active;
        } else if (user.isTrialExpired) {
          return TrialStatus.expired;
        } else if (user.hasNeverUsedTrial) {
          return TrialStatus.neverUsed;
        }
      }

      // Se nunca foi oferecido localmente
      if (!await wasTrialOffered()) {
        return TrialStatus.neverUsed;
      }

      return TrialStatus.expired;
    } catch (e) {
      print('❌ Erro ao verificar status do trial: $e');
      return TrialStatus.neverUsed;
    }
  }

  // ========================================
  // VERIFICAÇÃO DE ELEGIBILIDADE
  // ========================================

  /// Verifica se o usuário deve ver a oferta de trial
  Future<bool> shouldShowTrialOffer({User? user}) async {
    try {
      // Não mostrar se já foi oferecido
      if (await wasTrialOffered()) {
        return false;
      }

      // Não mostrar se já é premium
      if (user != null && user.isPremium) {
        return false;
      }

      // Não mostrar se já está em trial
      if (user != null && user.isInTrial) {
        return false;
      }

      // Não mostrar se já recusou
      if (await wasTrialDeclined()) {
        return false;
      }

      // Mostrar apenas na primeira abertura
      return await isFirstAppOpen();
    } catch (e) {
      print('❌ Erro ao verificar se deve mostrar trial: $e');
      return false;
    }
  }

  // ========================================
  // LIMPEZA E RESET
  // ========================================

  /// Limpa todos os dados de trial
  Future<void> clearTrialData() async {
    try {
      await _storageService.ensurePrefsInitialized();
      await _storageService.prefs?.remove(_trialStartKey);
      await _storageService.prefs?.remove(_trialEndKey);
      await _storageService.prefs?.remove(_trialOfferedKey);
      await _storageService.prefs?.remove(_trialAcceptedKey);
      await _storageService.prefs?.remove(_trialDeclinedKey);
      
      print('🧹 Dados de trial limpos');
    } catch (e) {
      print('❌ Erro ao limpar dados de trial: $e');
    }
  }

  /// Reset completo para debug/desenvolvimento
  Future<void> resetTrialSystem() async {
    try {
      await clearTrialData();
      await _storageService.ensurePrefsInitialized();
      await _storageService.prefs?.remove(_firstOpenKey);
      
      print('🔄 Sistema de trial resetado completamente');
    } catch (e) {
      print('❌ Erro ao resetar sistema de trial: $e');
    }
  }

  // ========================================
  // MÉTODOS DE INFORMAÇÃO
  // ========================================

  /// Retorna informações detalhadas sobre o trial
  Future<Map<String, dynamic>> getTrialInfo({User? user}) async {
    try {
      final status = await getTrialStatus(user: user);
      final trial = await getCurrentTrial();
      final firstOpen = await isFirstAppOpen();
      final offered = await wasTrialOffered();
      final accepted = await wasTrialAccepted();
      final declined = await wasTrialDeclined();

      return {
        'status': status.name,
        'status_display': status.displayName,
        'is_first_open': firstOpen,
        'was_offered': offered,
        'was_accepted': accepted,
        'was_declined': declined,
        'should_show_offer': await shouldShowTrialOffer(user: user),
        'trial_data': trial?.toJson(),
        'can_start_trial': status.canStartTrial,
        'has_access': status.hasAccess,
      };
    } catch (e) {
      print('❌ Erro ao obter informações do trial: $e');
      return {'error': e.toString()};
    }
  }

  /// Imprime informações de debug
  Future<void> printTrialDebugInfo({User? user}) async {
    final info = await getTrialInfo(user: user);
    print('📊 Trial Debug Info:');
    info.forEach((key, value) {
      print('   $key: $value');
    });
  }
}