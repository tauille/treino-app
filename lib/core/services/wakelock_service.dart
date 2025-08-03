import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/material.dart';

/// Serviço para gerenciar o wakelock (manter tela ativa)
/// 🆕 VERSÃO EXPANDIDA: Suporte para treinos + global
class WakelockService {
  static final WakelockService _instance = WakelockService._internal();
  factory WakelockService() => _instance;
  WakelockService._internal();

  bool _isEnabled = false;
  bool _wasEnabledBeforeWorkout = false;
  
  // 🆕 VARIÁVEIS PARA FUNCIONALIDADE GLOBAL
  bool _globalEnabled = false;
  bool _userPreference = true; // Padrão: app sempre ativo
  bool _isGlobalInitialized = false;

  /// Verificar se wakelock está ativo
  bool get isEnabled => _isEnabled;
  
  // 🆕 GETTERS PARA FUNCIONALIDADE GLOBAL
  bool get globalEnabled => _globalEnabled;
  bool get userPreference => _userPreference;
  bool get isGlobalInitialized => _isGlobalInitialized;

  /// Inicializar serviço (método original mantido)
  Future<void> initialize() async {
    try {
      _isEnabled = await WakelockPlus.enabled;
      if (kDebugMode) print('📱 WakelockService inicializado - Status: $_isEnabled');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao inicializar WakelockService: $e');
    }
  }

  // 🆕 INICIALIZAR WAKELOCK GLOBAL - Para chamar no main.dart
  Future<void> initializeGlobal() async {
    try {
      if (_userPreference && !_isGlobalInitialized) {
        await WakelockPlus.enable();
        _isEnabled = true;
        _globalEnabled = true;
        _isGlobalInitialized = true;
        if (kDebugMode) print('🔒 WAKELOCK GLOBAL ATIVADO - App sempre ativo');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ativar wakelock global: $e');
    }
  }

  // 🆕 CONFIGURAR PREFERÊNCIA GLOBAL DO USUÁRIO
  Future<void> setGlobalPreference(bool enabled) async {
    _userPreference = enabled;
    
    if (enabled) {
      await _enableGlobal();
    } else {
      await _disableGlobal();
    }
    
    // TODO: Salvar preferência no SharedPreferences se necessário
    if (kDebugMode) print('⚙️ Preferência global definida: $enabled');
  }

  // 🆕 ATIVAR WAKELOCK GLOBAL
  Future<void> _enableGlobal() async {
    try {
      await WakelockPlus.enable();
      _isEnabled = true;
      _globalEnabled = true;
      if (kDebugMode) print('🔒 Wakelock GLOBAL ativado');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ativar wakelock global: $e');
    }
  }

  // 🆕 DESATIVAR WAKELOCK GLOBAL
  Future<void> _disableGlobal() async {
    try {
      await WakelockPlus.disable();
      _isEnabled = false;
      _globalEnabled = false;
      if (kDebugMode) print('🔓 Wakelock GLOBAL desativado');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao desativar wakelock global: $e');
    }
  }

  // 🆕 GARANTIR QUE WAKELOCK ESTÁ ATIVO (uso em lifecycle)
  Future<void> ensureActive() async {
    if (_userPreference || _globalEnabled) {
      try {
        final currentStatus = await WakelockPlus.enabled;
        if (!currentStatus) {
          await WakelockPlus.enable();
          _isEnabled = true;
          if (kDebugMode) print('🔒 Wakelock reativado automaticamente');
        }
      } catch (e) {
        if (kDebugMode) print('❌ Erro ao garantir wakelock ativo: $e');
      }
    }
  }

  // 🆕 TOGGLE GLOBAL
  Future<bool> toggleGlobal() async {
    final newValue = !_userPreference;
    await setGlobalPreference(newValue);
    return newValue;
  }

  /// ===== MÉTODOS ORIGINAIS MANTIDOS PARA COMPATIBILIDADE =====

  /// Ativar wakelock para treino
  Future<bool> enableForWorkout() async {
    try {
      // Salvar estado anterior
      _wasEnabledBeforeWorkout = await WakelockPlus.enabled;
      
      // Ativar wakelock
      await WakelockPlus.enable();
      _isEnabled = true;
      
      if (kDebugMode) print('🔒 Wakelock ATIVADO para treino');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ativar wakelock: $e');
      return false;
    }
  }

  /// Desativar wakelock após treino
  Future<bool> disableAfterWorkout() async {
    try {
      // 🔧 MODIFICADO: Respeitar preferência global
      if (!_wasEnabledBeforeWorkout && !_globalEnabled) {
        await WakelockPlus.disable();
        _isEnabled = false;
        if (kDebugMode) print('🔓 Wakelock DESATIVADO após treino');
      } else {
        if (kDebugMode) print('🔒 Wakelock mantido (global ativo ou estava ativo antes)');
      }
      
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao desativar wakelock: $e');
      return false;
    }
  }

  /// Ativar wakelock manualmente
  Future<bool> enable() async {
    try {
      await WakelockPlus.enable();
      _isEnabled = true;
      if (kDebugMode) print('🔒 Wakelock ATIVADO manualmente');
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao ativar wakelock: $e');
      return false;
    }
  }

  /// Desativar wakelock manualmente
  Future<bool> disable() async {
    try {
      // 🔧 MODIFICADO: Só desativar se global não estiver ativo
      if (!_globalEnabled) {
        await WakelockPlus.disable();
        _isEnabled = false;
        if (kDebugMode) print('🔓 Wakelock DESATIVADO manualmente');
      } else {
        if (kDebugMode) print('🔒 Wakelock mantido (global ativo)');
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao desativar wakelock: $e');
      return false;
    }
  }

  /// Toggle wakelock
  Future<bool> toggle() async {
    if (_isEnabled) {
      return await disable();
    } else {
      return await enable();
    }
  }

  /// Verificar se dispositivo suporta wakelock
  Future<bool> isSupported() async {
    try {
      // Tentar ativar e depois desativar para testar
      await WakelockPlus.enable();
      final isSupported = await WakelockPlus.enabled;
      await WakelockPlus.disable();
      
      if (kDebugMode) print('📱 Wakelock suportado: $isSupported');
      return isSupported;
    } catch (e) {
      if (kDebugMode) print('❌ Wakelock não suportado: $e');
      return false;
    }
  }

  /// Forçar atualização do status
  Future<void> updateStatus() async {
    try {
      _isEnabled = await WakelockPlus.enabled;
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao atualizar status: $e');
    }
  }

  /// Status formatado para UI
  String get statusText {
    // 🔧 MODIFICADO: Incluir informação sobre modo global
    if (_globalEnabled) {
      return 'Global - Sempre ativa';
    }
    return _isEnabled ? 'Tela sempre ativa' : 'Tela pode desligar';
  }

  /// Ícone para UI
  IconData get statusIcon {
    return _isEnabled ? Icons.screen_lock_portrait_rounded : Icons.screen_lock_landscape_rounded;
  }

  /// Cor para UI
  Color get statusColor {
    // 🔧 MODIFICADO: Cor diferente para modo global
    if (_globalEnabled) {
      return Colors.blue; // Azul para global
    }
    return _isEnabled ? Colors.green : Colors.grey;
  }

  // 🆕 MÉTODOS PARA DEBUG E INFORMAÇÕES
  
  /// Obter informações detalhadas do serviço
  Map<String, dynamic> getServiceInfo() {
    return {
      'isEnabled': _isEnabled,
      'globalEnabled': _globalEnabled,
      'userPreference': _userPreference,
      'wasEnabledBeforeWorkout': _wasEnabledBeforeWorkout,
      'isGlobalInitialized': _isGlobalInitialized,
      'statusText': statusText,
    };
  }

  /// Log das informações do serviço
  void logServiceInfo() {
    if (kDebugMode) {
      print('📱 === WAKELOCK SERVICE INFO ===');
      final info = getServiceInfo();
      info.forEach((key, value) {
        print('📱 $key: $value');
      });
      print('📱 ============================');
    }
  }

  // 🆕 CLEANUP
  Future<void> dispose() async {
    try {
      if (_isEnabled && !_globalEnabled) {
        await WakelockPlus.disable();
        if (kDebugMode) print('🧹 Wakelock limpo no dispose');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Erro no dispose: $e');
    }
  }
}

/// Widget helper para mostrar status do wakelock
/// 🔧 MODIFICADO: Melhor suporte para modo global
class WakelockStatusWidget extends StatefulWidget {
  final bool showToggle;
  final VoidCallback? onToggle;
  final bool useGlobalToggle; // 🆕 NOVO: usar toggle global

  const WakelockStatusWidget({
    Key? key,
    this.showToggle = false,
    this.onToggle,
    this.useGlobalToggle = false, // 🆕 NOVO
  }) : super(key: key);

  @override
  State<WakelockStatusWidget> createState() => _WakelockStatusWidgetState();
}

class _WakelockStatusWidgetState extends State<WakelockStatusWidget> {
  final WakelockService _wakelockService = WakelockService();

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  // 🆕 MÉTODO PARA ATUALIZAR STATUS
  Future<void> _updateStatus() async {
    await _wakelockService.updateStatus();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // 🔧 COMPACTO: 12,6→10,5
      decoration: BoxDecoration(
        color: _wakelockService.statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _wakelockService.statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _wakelockService.statusIcon,
            size: 14, // 🔧 COMPACTO: 16→14
            color: _wakelockService.statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            _wakelockService.statusText,
            style: TextStyle(
              fontSize: 11, // 🔧 COMPACTO: 12→11
              fontWeight: FontWeight.w600,
              color: _wakelockService.statusColor,
            ),
          ),
          if (widget.showToggle) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                // 🔧 MODIFICADO: Escolher entre toggle normal ou global
                if (widget.useGlobalToggle) {
                  await _wakelockService.toggleGlobal();
                } else {
                  await _wakelockService.toggle();
                }
                
                await _updateStatus();
                widget.onToggle?.call();
                
                // 🆕 FEEDBACK VISUAL
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _wakelockService.isEnabled 
                            ? '🔒 Wakelock ativado'
                            : '🔓 Wakelock desativado',
                      ),
                      backgroundColor: _wakelockService.isEnabled 
                          ? Colors.green 
                          : Colors.orange,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
              child: Icon(
                _wakelockService.isEnabled ? Icons.toggle_on : Icons.toggle_off,
                size: 18, // 🔧 COMPACTO: 20→18
                color: _wakelockService.statusColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// 🆕 WIDGET PARA CONFIGURAÇÕES GLOBAIS
class WakelockGlobalSettings extends StatefulWidget {
  const WakelockGlobalSettings({Key? key}) : super(key: key);

  @override
  State<WakelockGlobalSettings> createState() => _WakelockGlobalSettingsState();
}

class _WakelockGlobalSettingsState extends State<WakelockGlobalSettings> {
  final WakelockService _service = WakelockService();

  @override
  void initState() {
    super.initState();
    _updateStatus();
  }

  Future<void> _updateStatus() async {
    await _service.updateStatus();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SwitchListTile(
        title: const Text(
          'Tela Sempre Ativa (Global)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          _service.globalEnabled 
              ? 'App inteiro com tela sempre ligada'
              : 'Tela pode desligar normalmente',
          style: const TextStyle(fontSize: 14),
        ),
        secondary: Icon(
          _service.statusIcon,
          color: _service.statusColor,
        ),
        value: _service.userPreference,
        onChanged: (bool value) async {
          await _service.setGlobalPreference(value);
          await _updateStatus();
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value
                      ? '🔒 Wakelock global ativado'
                      : '🔓 Wakelock global desativado',
                ),
                backgroundColor: value ? Colors.green : Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      ),
    );
  }
}

// 🆕 HELPER PARA INTEGRAÇÃO COM APPBAR
class WakelockAppBarWidget extends StatelessWidget {
  final bool useGlobalToggle;

  const WakelockAppBarWidget({
    Key? key,
    this.useGlobalToggle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final service = WakelockService();
        
        if (useGlobalToggle) {
          await service.toggleGlobal();
        } else {
          await service.toggle();
        }
        
        // Feedback
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                service.isEnabled 
                    ? '🔒 Tela sempre ativa'
                    : '🔓 Tela pode desligar',
              ),
              backgroundColor: service.isEnabled ? Colors.green : Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      icon: Icon(
        Icons.screen_lock_portrait_rounded,
        color: WakelockService().statusColor,
      ),
      tooltip: 'Toggle Wakelock',
    );
  }
}

// 🆕 HELPER FUNCTIONS
class WakelockHelper {
  /// Teste rápido de wakelock
  static Future<void> test(BuildContext context) async {
    final service = WakelockService();
    await service.updateStatus();
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                service.isEnabled ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.isEnabled 
                        ? 'Wakelock funcionando!' 
                        : 'Wakelock não está ativo',
                  ),
                  Text(
                    'Status: ${service.statusText}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          backgroundColor: service.isEnabled ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Log detalhado do serviço
  static void logServiceInfo() {
    WakelockService().logServiceInfo();
  }

  /// Garantir que wakelock está ativo
  static Future<void> ensureActive() async {
    await WakelockService().ensureActive();
  }
}