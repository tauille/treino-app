import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // ✅ MANTIDO - Para HapticFeedback

/// Serviço para gerenciar sons e vibrações durante o treino
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;

  /// Inicializar serviço
  Future<void> initialize() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      if (kDebugMode) print('🔊 SoundService inicializado');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao inicializar SoundService: $e');
    }
  }

  /// Ativar/desativar sons
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
    if (kDebugMode) print('🔊 Sons ${enabled ? "ativados" : "desativados"}');
  }

  /// Ativar/desativar vibrações
  void setVibrationEnabled(bool enabled) {
    _vibrationEnabled = enabled;
    if (kDebugMode) print('📳 Vibrações ${enabled ? "ativadas" : "desativadas"}');
  }

  /// Tocar som de exercício completado
  Future<void> playExerciseComplete() async {
    await _playSound('sounds/exercise_complete.mp3');
    await _vibrate(VibrationPattern.success);
  }

  /// Tocar som de descanso completado
  Future<void> playRestComplete() async {
    await _playSound('sounds/rest_complete.mp3');
    await _vibrate(VibrationPattern.notification);
  }

  /// Tocar som de contagem regressiva (últimos 3 segundos)
  Future<void> playCountdown() async {
    await _playSound('sounds/countdown.mp3');
    await _vibrate(VibrationPattern.light);
  }

  /// Tocar som de treino finalizado
  Future<void> playWorkoutComplete() async {
    await _playSound('sounds/workout_complete.mp3');
    await _vibrate(VibrationPattern.celebration);
  }

  /// Tocar som de início de exercício
  Future<void> playExerciseStart() async {
    await _playSound('sounds/exercise_start.mp3');
    await _vibrate(VibrationPattern.start);
  }

  /// Tocar som de preparação
  Future<void> playPreparation() async {
    await _playSound('sounds/preparation.mp3');
    await _vibrate(VibrationPattern.light);
  }

  /// Método privado para tocar som
  Future<void> _playSound(String soundPath) async {
    if (!_soundEnabled) {
      // Mesmo sem som, ainda fazer vibração
      return;
    }

    try {
      await _audioPlayer.stop(); // Parar som anterior se houver
      await _audioPlayer.play(AssetSource(soundPath));
      if (kDebugMode) print('🔊 Tocando som: $soundPath');
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao tocar som $soundPath: $e');
      // Fallback: usar apenas vibração se som falhar
      await _vibrate(VibrationPattern.notification);
    }
  }

  /// Método privado para vibração - USANDO APENAS HAPTIC FEEDBACK
  Future<void> _vibrate(VibrationPattern pattern) async {
    if (!_vibrationEnabled) return;

    try {
      // ✅ CORRIGIDO - Usar apenas HapticFeedback (nativo do Flutter)
      switch (pattern) {
        case VibrationPattern.light:
          HapticFeedback.lightImpact();
          break;
        case VibrationPattern.notification:
          HapticFeedback.mediumImpact();
          break;
        case VibrationPattern.success:
          // Vibração dupla para sucesso
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact();
          break;
        case VibrationPattern.celebration:
          // Vibração tripla para celebração
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 100));
          HapticFeedback.heavyImpact();
          break;
        case VibrationPattern.start:
          HapticFeedback.mediumImpact();
          break;
      }
      
      if (kDebugMode) print('📳 Haptic feedback: $pattern');
    } catch (e) {
      if (kDebugMode) print('❌ Erro no haptic feedback: $e');
    }
  }

  /// Parar todos os sons
  Future<void> stopAllSounds() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) print('❌ Erro ao parar sons: $e');
    }
  }

  /// Testar som específico
  Future<void> testSound(String soundName) async {
    if (kDebugMode) print('🧪 Testando som: $soundName');
    
    switch (soundName) {
      case 'exercise_start':
        await playExerciseStart();
        break;
      case 'exercise_complete':
        await playExerciseComplete();
        break;
      case 'rest_complete':
        await playRestComplete();
        break;
      case 'countdown':
        await playCountdown();
        break;
      case 'workout_complete':
        await playWorkoutComplete();
        break;
      case 'preparation':
        await playPreparation();
        break;
      default:
        if (kDebugMode) print('❌ Som não encontrado: $soundName');
    }
  }

  /// Dispose
  void dispose() {
    _audioPlayer.dispose();
  }
}

/// Enum para tipos de vibração
enum VibrationPattern {
  light,
  notification,
  success,
  celebration,
  start,
}

/// Extension para facilitar uso
extension SoundServiceExtension on SoundService {
  /// Tocar som baseado no evento
  Future<void> playForEvent(WorkoutEvent event) async {
    switch (event) {
      case WorkoutEvent.exerciseStart:
        await playExerciseStart();
        break;
      case WorkoutEvent.exerciseComplete:
        await playExerciseComplete();
        break;
      case WorkoutEvent.restStart:
        // Som neutro para início de descanso
        await _vibrate(VibrationPattern.light);
        break;
      case WorkoutEvent.restComplete:
        await playRestComplete();
        break;
      case WorkoutEvent.countdown:
        await playCountdown();
        break;
      case WorkoutEvent.workoutComplete:
        await playWorkoutComplete();
        break;
      case WorkoutEvent.preparation:
        await playPreparation();
        break;
    }
  }
}

/// Enum para eventos do treino
enum WorkoutEvent {
  exerciseStart,
  exerciseComplete,
  restStart,
  restComplete,
  countdown,
  workoutComplete,
  preparation,
}