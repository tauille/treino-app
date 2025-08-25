import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import '../../models/treino_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/sport_theme.dart';
import '../../providers/execucao_treino_provider.dart';

class ModernExecucaoTreinoScreen extends StatefulWidget {
  final TreinoModel treino;

  const ModernExecucaoTreinoScreen({
    Key? key,
    required this.treino,
  }) : super(key: key);

  @override
  State<ModernExecucaoTreinoScreen> createState() => _ModernExecucaoTreinoScreenState();
}

class _ModernExecucaoTreinoScreenState extends State<ModernExecucaoTreinoScreen>
    with TickerProviderStateMixin {
  
  int _currentExerciseIndex = 0;
  int _currentSerie = 1;
  bool _isPaused = false;
  
  // Estados para lógica dos timers
  ExercicioModel? _exercicioAtual;
  
  // Controle de timers
  Timer? _timerAtivo;
  int _tempoAtual = 0;
  int _tempoTotalSegundos = 0;
  bool _timerRodando = false;
  
  // Estados de execução
  TimerState _timerState = TimerState.waiting;
  
  // Player de áudio para sons personalizados
  late AudioPlayer _audioPlayer;
  
  // Controladores de animação
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  // Campos para salvar dados de execução
  ExecucaoTreinoProvider? _execucaoProvider;
  DateTime? _inicioTreino;
  Timer? _timerTotal;
  int _totalExerciciosCompletados = 0;
  int _totalSeriesCompletadas = 0;
  List<Map<String, dynamic>> _exerciciosRealizados = [];

  @override
  void initState() {
    super.initState();
    
    _audioPlayer = AudioPlayer();
    _setupAnimations();
    _enableWakelock();
    
    // Inicializar dados de execução
    _execucaoProvider = Provider.of<ExecucaoTreinoProvider>(context, listen: false);
    _inicioTreino = DateTime.now();
    
    // Iniciar timer total
    _iniciarTimerTotal();
    
    _initializeExercicio();
    
    if (widget.treino.exercicios.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoExercisesDialog();
      });
    }
  }

  // Iniciar timer total do treino
  void _iniciarTimerTotal() {
    _timerTotal = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() {
          _tempoTotalSegundos++;
        });
      }
    });
  }

  void _initializeExercicio() {
    if (widget.treino.exercicios.isNotEmpty) {
      _exercicioAtual = widget.treino.exercicios[_currentExerciseIndex];
      _resetarTimer();
    }
  }

  void _resetarTimer() {
    _timerAtivo?.cancel();
    _progressController.reset();
    setState(() {
      _timerRodando = false;
      _tempoAtual = 0;
      _timerState = TimerState.waiting;
    });
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    _timerAtivo?.cancel();
    _timerTotal?.cancel();
    _audioPlayer.dispose();
    _disableWakelock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.treino.exercicios.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: _buildResponsiveLayout(constraints),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveLayout(BoxConstraints constraints) {
    final width = constraints.maxWidth;
    final isSmall = width < 400;
    final isMedium = width >= 400 && width < 700;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 13 : isMedium ? 19 : 26,
        vertical: isSmall ? 13 : 19,
      ),
      child: Column(
        children: [
          _buildModernHeader(isSmall),
          SizedBox(height: isSmall ? 16 : 26),
          _buildExerciseCard(isSmall, isMedium),
          SizedBox(height: isSmall ? 16 : 26),
          _buildCircularTimer(isSmall, isMedium),
          SizedBox(height: isSmall ? 16 : 26),
          _buildActionButtons(isSmall, isMedium),
          SizedBox(height: isSmall ? 13 : 19),
          if (widget.treino.exercicios.length > 1)
            _buildNavigationButtons(isSmall),
        ],
      ),
    );
  }

  Widget _buildModernHeader(bool isSmall) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 13 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6BA6CD), Color(0xFF5B9BD5)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6BA6CD).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.treino.nomeTreino.toUpperCase(),
            style: TextStyle(
              fontSize: isSmall ? 15 : 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: isSmall ? 13 : 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentExerciseIndex + 1}/${widget.treino.exercicios.length}',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    color: Colors.white.withOpacity(0.9),
                    size: isSmall ? 13 : 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(_tempoTotalSegundos),
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white.withOpacity(0.9),
                    size: isSmall ? 13 : 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$_totalExerciciosCompletados',
                    style: TextStyle(
                      fontSize: isSmall ? 11 : 13,
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(bool isSmall, bool isMedium) {
    if (_exercicioAtual == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 16 : 19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFED8936), Color(0xFFFF8C00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFED8936).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _exercicioAtual!.nomeExercicio ?? 'Exercício',
            style: TextStyle(
              fontSize: isSmall ? 18 : isMedium ? 21 : 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  (_exercicioAtual?.isTempo == true)
                      ? Icons.timer_rounded 
                      : Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: isSmall ? 16 : 19,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  _getExerciseDescription(),
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getExerciseDescription() {
    if (_exercicioAtual == null) return '';
    
    final series = _exercicioAtual!.series ?? 1;
    
    if (_exercicioAtual?.isTempo == true) {
      final tempo = _exercicioAtual!.tempoExecucao ?? 30;
      return '$series séries de ${tempo}s';
    } else {
      final reps = _exercicioAtual!.repeticoes ?? 1;
      return '$series séries de $reps repetições';
    }
  }

  Widget _buildCircularTimer(bool isSmall, bool isMedium) {
    final size = isSmall ? 176.0 : isMedium ? 208.0 : 240.0;
    final strokeWidth = isSmall ? 6.4 : 8.0;
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _timerRodando ? _pulseAnimation.value : 1.0,
          child: Container(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size - 20,
                  height: size - 20,
                  child: CircularProgressIndicator(
                    value: _getTimerProgress(),
                    strokeWidth: strokeWidth,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_getTimerColor()),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatTime(_tempoAtual),
                      style: TextStyle(
                        fontSize: isSmall ? 29 : isMedium ? 34 : 38,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTimerColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getTimerStatusText(),
                        style: TextStyle(
                          fontSize: isSmall ? 10 : 11,
                          fontWeight: FontWeight.w600,
                          color: _getTimerColor(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSeriesIndicator(isSmall),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSeriesIndicator(bool isSmall) {
    final totalSeries = _exercicioAtual?.series ?? 1;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSeries, (index) {
        final isCompleted = index < _currentSerie - 1;
        final isCurrent = index == _currentSerie - 1;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: isSmall ? 8 : 10,
          height: isSmall ? 8 : 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : isCurrent
                    ? _getTimerColor()
                    : Colors.grey.withOpacity(0.3),
          ),
        );
      }),
    );
  }

  Widget _buildActionButtons(bool isSmall, bool isMedium) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: isSmall ? 45 : 51,
          child: ElevatedButton(
            onPressed: _getMainButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getMainButtonColor(),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: _getMainButtonColor().withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              _getMainButtonText(),
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: isSmall ? 38 : 45,
          child: ElevatedButton(
            onPressed: _showStopDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BA6CD),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: const Color(0xFF6BA6CD).withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'FINALIZAR TREINO',
              style: TextStyle(
                fontSize: isSmall ? 12 : 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(bool isSmall) {
    return Row(
      children: [
        if (_currentExerciseIndex > 0)
          Expanded(
            child: SizedBox(
              height: isSmall ? 32 : 35,
              child: OutlinedButton.icon(
                onPressed: _previousExercise,
                icon: Icon(Icons.skip_previous_rounded, size: isSmall ? 14 : 16),
                label: Text(
                  'ANTERIOR',
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6BA6CD),
                  side: const BorderSide(color: Color(0xFF6BA6CD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        if (_currentExerciseIndex > 0 && _currentExerciseIndex < widget.treino.exercicios.length - 1)
          const SizedBox(width: 12),
        if (_currentExerciseIndex < widget.treino.exercicios.length - 1)
          Expanded(
            child: SizedBox(
              height: isSmall ? 32 : 35,
              child: OutlinedButton.icon(
                onPressed: _nextExercise,
                icon: Icon(Icons.skip_next_rounded, size: isSmall ? 14 : 16),
                label: Text(
                  'PRÓXIMO',
                  style: TextStyle(
                    fontSize: isSmall ? 10 : 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF6BA6CD),
                  side: const BorderSide(color: Color(0xFF6BA6CD)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6BA6CD),
        foregroundColor: Colors.white,
        title: const Text('Execução do Treino'),
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6BA6CD), Color(0xFF5B9BD5)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Sem Exercícios',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Este treino não possui exercícios\npara executar',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF718096),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6BA6CD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Voltar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos auxiliares
  Color _getTimerColor() {
    switch (_timerState) {
      case TimerState.waiting:
        return const Color(0xFF6BA6CD);
      case TimerState.executing:
        return const Color(0xFFE53E3E);
      case TimerState.resting:
        return const Color(0xFFD69E2E);
      case TimerState.finished:
        return const Color(0xFF4CAF50);
    }
  }

  String _getTimerStatusText() {
    switch (_timerState) {
      case TimerState.waiting:
        return 'Pronto para série $_currentSerie';
      case TimerState.executing:
        return 'Executando série $_currentSerie';
      case TimerState.resting:
        return 'Descansando';
      case TimerState.finished:
        return 'Exercício concluído';
    }
  }

  String _getMainButtonText() {
    if (_exercicioAtual?.isTempo == true) {
      switch (_timerState) {
        case TimerState.waiting:
          return 'INICIAR SÉRIE $_currentSerie';
        case TimerState.executing:
          return 'EXECUTANDO...';
        case TimerState.resting:
          return 'DESCANSANDO...';
        case TimerState.finished:
          if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
            return 'FINALIZAR TREINO 🎉';
          } else {
            return 'PRÓXIMO EXERCÍCIO';
          }
      }
    } else {
      if (_currentSerie <= (_exercicioAtual?.series ?? 1)) {
        return 'COMPLETAR SÉRIE $_currentSerie';
      } else {
        if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
          return 'FINALIZAR TREINO 🎉';
        } else {
          return 'PRÓXIMO EXERCÍCIO';
        }
      }
    }
  }

  Color _getMainButtonColor() {
    if (_isMainButtonDisabled()) {
      return const Color(0xFFA0AEC0);
    }
    
    final isLastExercise = _currentExerciseIndex >= widget.treino.exercicios.length - 1;
    final exerciseFinished = _currentSerie > (_exercicioAtual?.series ?? 1) || _timerState == TimerState.finished;
    
    if (exerciseFinished && isLastExercise) {
      return const Color(0xFF4CAF50);
    } else if (exerciseFinished) {
      return const Color(0xFFED8936);
    } else {
      return const Color(0xFFED8936);
    }
  }

  bool _isMainButtonDisabled() {
    if (_exercicioAtual?.isTempo == true) {
      return _timerState == TimerState.executing || _timerState == TimerState.resting;
    }
    return false;
  }

  VoidCallback? _getMainButtonAction() {
    if (_isMainButtonDisabled()) return null;
    
    if (_exercicioAtual?.isTempo == true) {
      switch (_timerState) {
        case TimerState.waiting:
          return _iniciarTimer;
        case TimerState.executing:
        case TimerState.resting:
          return null;
        case TimerState.finished:
          return _finalizarExercicio;
      }
    } else {
      if (_currentSerie <= (_exercicioAtual?.series ?? 1)) {
        return _completeSet;
      } else {
        return _finalizarExercicio;
      }
    }
  }

  double _getTimerProgress() {
    if (_exercicioAtual == null) return 0.0;
    
    if (_timerState == TimerState.executing) {
      final total = _exercicioAtual!.tempoExecucao ?? 30;
      return (_tempoAtual / total).clamp(0.0, 1.0);
    } else if (_timerState == TimerState.resting) {
      final total = _exercicioAtual!.tempoDescanso ?? 60;
      return (_tempoAtual / total).clamp(0.0, 1.0);
    }
    
    return 0.0;
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Métodos de lógica do timer
  void _iniciarTimer() {
    if (_exercicioAtual == null || _exercicioAtual?.isTempo != true) return;

    setState(() {
      _tempoAtual = _exercicioAtual!.tempoExecucao ?? 30;
      _timerState = TimerState.executing;
      _timerRodando = true;
    });

    _pulseController.repeat(reverse: true);

    _timerAtivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoAtual--;
      });

      if (_tempoAtual == 3 || _tempoAtual == 2 || _tempoAtual == 1) {
        HapticFeedback.heavyImpact();
        _playCountdownSound();
      }

      if (_tempoAtual <= 0) {
        _finalizarExecucao();
      }
    });

    HapticFeedback.mediumImpact();
    _showSnackBar('Série $_currentSerie iniciada! 💪', _getTimerColor());
  }

  void _finalizarExecucao() {
    _timerAtivo?.cancel();
    _pulseController.stop();
    
    if (_currentSerie < (_exercicioAtual?.series ?? 1)) {
      _iniciarDescanso();
    } else {
      setState(() {
        _timerState = TimerState.finished;
        _timerRodando = false;
      });
      HapticFeedback.heavyImpact();
      
      _showSnackBar('Exercício concluído! 🎉', const Color(0xFF4CAF50));
    }
  }

  void _iniciarDescanso() {
    setState(() {
      _currentSerie++;
      _tempoAtual = _exercicioAtual!.tempoDescanso ?? 60;
      _timerState = TimerState.resting;
    });

    _timerAtivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoAtual--;
      });

      if (_tempoAtual == 3 || _tempoAtual == 2 || _tempoAtual == 1) {
        HapticFeedback.heavyImpact();
        _playCountdownSound();
      }

      if (_tempoAtual <= 0) {
        _finalizarDescanso();
      }
    });

    _showSnackBar('Descanso iniciado ⏱️', const Color(0xFFD69E2E));
  }

  void _finalizarDescanso() {
    _timerAtivo?.cancel();
    
    setState(() {
      _timerState = TimerState.waiting;
      _timerRodando = false;
    });

    HapticFeedback.mediumImpact();
    
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timerState == TimerState.waiting) {
        _iniciarTimer();
      }
    });
  }

  void _completeSet() {
    HapticFeedback.mediumImpact();
    
    if (_currentSerie < (_exercicioAtual?.series ?? 1)) {
      _iniciarDescansoRepeticao();
    } else {
      _finalizarExercicio();
    }
  }

  void _iniciarDescansoRepeticao() {
    setState(() {
      _currentSerie++;
      _tempoAtual = _exercicioAtual!.tempoDescanso ?? 60;
      _timerState = TimerState.resting;
      _timerRodando = true;
    });

    _pulseController.repeat(reverse: true);

    _timerAtivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoAtual--;
      });

      if (_tempoAtual == 3 || _tempoAtual == 2 || _tempoAtual == 1) {
        HapticFeedback.heavyImpact();
        _playCountdownSound();
      }

      if (_tempoAtual <= 0) {
        _finalizarDescansoRepeticao();
      }
    });

    _showSnackBar('Descanso iniciado! ⏱️ Próxima série: $_currentSerie', const Color(0xFFD69E2E));
  }

  void _finalizarDescansoRepeticao() {
    _timerAtivo?.cancel();
    _pulseController.stop();
    
    setState(() {
      _timerState = TimerState.waiting;
      _timerRodando = false;
    });

    HapticFeedback.mediumImpact();
    _showSnackBar('Descanso terminado! Vamos para série $_currentSerie! 💪', const Color(0xFF4CAF50));
  }

  void _finalizarExercicio() {
    _salvarDadosExercicio();
    
    _showSnackBar('Exercício completado! 🎉', const Color(0xFF48BB78));
    
    if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
      Future.delayed(const Duration(seconds: 2), () {
        _finishTreinoComDados();
      });
    } else {
      Future.delayed(const Duration(seconds: 1), () {
        _nextExercise();
      });
    }
  }

  void _salvarDadosExercicio() {
    final exercicioData = {
      'exercicio_id': _exercicioAtual?.id,
      'nome_exercicio': _exercicioAtual?.nomeExercicio,
      'grupo_muscular': _exercicioAtual?.grupoMuscular,
      'series_planejadas': _exercicioAtual?.series ?? 1,
      'series_realizadas': _currentSerie - 1,
      'repeticoes_planejadas': _exercicioAtual?.repeticoes,
      'tempo_execucao_segundos': _timerState == TimerState.finished ? 
        ((_exercicioAtual?.series ?? 1) * (_exercicioAtual?.tempoExecucao ?? 30)) : 0,
      'tipo_execucao': (_exercicioAtual?.isTempo == true) ? 'tempo' : 'repeticao',
      'peso': _exercicioAtual?.peso,
      'completado': true,
      'data_execucao': DateTime.now().toIso8601String(),
    };
    
    _exerciciosRealizados.add(exercicioData);
    _totalExerciciosCompletados++;
    _totalSeriesCompletadas += (_currentSerie - 1);
  }

  void _finishTreinoComDados() async {
    HapticFeedback.heavyImpact();
    
    _timerAtivo?.cancel();
    _timerTotal?.cancel();
    _pulseController.stop();
    
    final dadosExecucao = {
      'treino_id': widget.treino.id,
      'nome_treino': widget.treino.nomeTreino,
      'data_inicio': _inicioTreino?.toIso8601String(),
      'data_fim': DateTime.now().toIso8601String(),
      'duracao_total_segundos': _tempoTotalSegundos,
      'total_exercicios': widget.treino.exercicios.length,
      'exercicios_completados': _totalExerciciosCompletados,
      'total_series': _totalSeriesCompletadas,
      'exercicios_detalhes': _exerciciosRealizados,
      'tipo_treino': widget.treino.tipoTreino,
      'dificuldade': widget.treino.dificuldade,
      'status': 'completado',
      'data_salvamento': DateTime.now().toIso8601String(),
    };
    
    try {
      final sucesso = await _execucaoProvider?.finalizarTreino(
        observacoes: 'Treino completado com sucesso via app'
      ) ?? false;
      
      if (!sucesso) {
        print('⚠️ Provider falhou, salvando localmente...');
      }
    } catch (e) {
      print('❌ Erro no provider: $e');
    }
    
    await _salvarDadosLocal(dadosExecucao);
    
    _showSnackBar('Treino salvo com sucesso! 📊', const Color(0xFF4CAF50));
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
    );
  }

  Future<void> _salvarDadosLocal(Map<String, dynamic> dadosExecucao) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final execucoesString = prefs.getString('execucoes_treino') ?? '[]';
      final execucoesExistentes = List<Map<String, dynamic>>.from(
        jsonDecode(execucoesString)
      );
      
      execucoesExistentes.add(dadosExecucao);
      
      await prefs.setString('execucoes_treino', jsonEncode(execucoesExistentes));
      
      print('✅ Dados salvos localmente: ${execucoesExistentes.length} execuções');
      
    } catch (e) {
      print('❌ Erro ao salvar localmente: $e');
    }
  }

  void _nextExercise() {
    HapticFeedback.lightImpact();
    
    if (_currentExerciseIndex < widget.treino.exercicios.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSerie = 1;
      });
      _initializeExercicio();
    } else {
      _finishTreinoComDados();
    }
  }

  void _previousExercise() {
    HapticFeedback.lightImpact();
    
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSerie = 1;
      });
      _initializeExercicio();
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              (_exercicioAtual?.isTempo == true) 
                  ? Icons.auto_awesome 
                  : Icons.info_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showStopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Finalizar Treino?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Tem certeza que deseja finalizar o treino agora? Seus dados serão salvos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF718096)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishTreinoComDados();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BA6CD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Finalizar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showNoExercisesDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Treino Vazio',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Este treino não possui exercícios para executar.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BA6CD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Voltar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
      print('✅ Wakelock ATIVADO');
    } catch (e) {
      print('❌ Erro wakelock: $e');
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
      print('✅ Wakelock DESATIVADO');
    } catch (e) {
      print('❌ Erro ao desativar wakelock: $e');
    }
  }

  Future<void> _playCountdownSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/countdown.mp3'));
      HapticFeedback.heavyImpact();
    } catch (e) {
      print('Erro ao reproduzir som: $e');
      HapticFeedback.heavyImpact();
    }
  }
}

// Enum para estados do timer
enum TimerState {
  waiting,
  executing,
  resting,
  finished,
}