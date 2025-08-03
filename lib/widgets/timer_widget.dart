import 'package:treino_app/core/theme/sport_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

enum TimerType {
  countDown,    // Timer regressivo (descanso)
  countUp,      // Timer progressivo (execução)
  preparation,  // Timer de preparação
}

enum TimerState {
  stopped,
  running,
  paused,
  finished,
}

/// 🎯 Timer Circular Moderno com Animações e Sons
class ModernExecutionTimer extends StatefulWidget {
  final TimerType type;
  final int initialSeconds;
  final VoidCallback? onFinished;
  final VoidCallback? onTick;
  final bool autoStart;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double size;
  final bool showControls;
  final bool enableSounds;
  final bool enableHaptics;
  final String? title;
  final String? subtitle;

  const ModernExecutionTimer({
    Key? key,
    required this.type,
    required this.initialSeconds,
    this.onFinished,
    this.onTick,
    this.autoStart = false,
    this.primaryColor,
    this.backgroundColor,
    this.size = 220,
    this.showControls = true,
    this.enableSounds = true,
    this.enableHaptics = true,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  State<ModernExecutionTimer> createState() => _ModernExecutionTimerState();
}

class _ModernExecutionTimerState extends State<ModernExecutionTimer>
    with TickerProviderStateMixin {
  
  Timer? _timer;
  int _currentSeconds = 0;
  TimerState _state = TimerState.stopped;
  
  // Controladores de animação
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _scaleController;
  
  // Animações
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.initialSeconds;
    _initAnimations();
    
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        start();
      });
    }
  }

  void _initAnimations() {
    // Controlador principal do progresso
    _progressController = AnimationController(
      duration: Duration(seconds: widget.initialSeconds),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: widget.type == TimerType.countDown ? 1.0 : 0.0,
      end: widget.type == TimerType.countDown ? 0.0 : 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));

    // Animação de pulsação
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animação de brilho
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Animação de escala para feedback visual
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Animação de cor baseada no progresso
    _colorAnimation = ColorTween(
      begin: _getTimerColor(),
      end: _getFinishColor(),
    ).animate(_progressAnimation);
  }

  void start() {
    if (_state == TimerState.running) return;

    setState(() {
      _state = TimerState.running;
    });

    // Feedback háptico
    if (widget.enableHaptics) {
      HapticFeedback.mediumImpact();
    }

    // Iniciar animações
    _progressController.forward();
    if (widget.type == TimerType.preparation) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat(reverse: true);
    }

    // Timer principal
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (widget.type == TimerType.countDown || widget.type == TimerType.preparation) {
          _currentSeconds--;
        } else {
          _currentSeconds++;
        }
      });

      widget.onTick?.call();

      // Feedback nos últimos 3 segundos
      if (widget.enableHaptics && widget.type != TimerType.countUp) {
        if (_currentSeconds <= 3 && _currentSeconds > 0) {
          HapticFeedback.lightImpact();
        }
      }

      // Som de tick (simulado com vibração leve)
      if (widget.enableSounds && _currentSeconds <= 5 && _currentSeconds > 0) {
        if (widget.type != TimerType.countUp) {
          HapticFeedback.selectionClick();
        }
      }

      // Verificar se terminou
      if (widget.type == TimerType.countDown || widget.type == TimerType.preparation) {
        if (_currentSeconds <= 0) {
          _finish();
        }
      }
    });
  }

  void pause() {
    if (_state != TimerState.running) return;

    _timer?.cancel();
    _progressController.stop();
    _pulseController.stop();
    _glowController.stop();
    
    setState(() {
      _state = TimerState.paused;
    });

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void resume() {
    if (_state != TimerState.paused) return;
    start();
  }

  void stop() {
    _timer?.cancel();
    _progressController.reset();
    _pulseController.stop();
    _glowController.stop();
    
    setState(() {
      _currentSeconds = widget.initialSeconds;
      _state = TimerState.stopped;
    });

    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _finish() {
    _timer?.cancel();
    _progressController.stop();
    _pulseController.stop();
    _glowController.stop();
    
    setState(() {
      _state = TimerState.finished;
    });

    // Feedback de conclusão
    if (widget.enableHaptics) {
      HapticFeedback.heavyImpact();
      // Vibração dupla para enfatizar
      Future.delayed(const Duration(milliseconds: 100), () {
        HapticFeedback.heavyImpact();
      });
    }

    // Animação de conclusão
    _scaleController.forward().then((_) {
      _scaleController.reverse();
    });

    widget.onFinished?.call();
  }

  Color _getTimerColor() {
    switch (widget.type) {
      case TimerType.preparation:
        return widget.primaryColor ?? SportColors.accent;
      case TimerType.countDown:
        return widget.primaryColor ?? SportColors.secondary;
      case TimerType.countUp:
        return widget.primaryColor ?? SportColors.primary;
    }
  }

  Color _getFinishColor() {
    switch (widget.type) {
      case TimerType.preparation:
        return SportColors.success;
      case TimerType.countDown:
        return SportColors.primary;
      case TimerType.countUp:
        return SportColors.accent;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getTimerTitle() {
    if (widget.title != null) return widget.title!;
    
    switch (widget.type) {
      case TimerType.preparation:
        return 'Prepare-se';
      case TimerType.countDown:
        return 'Descanso';
      case TimerType.countUp:
        return 'Exercitando';
    }
  }

  String _getTimerSubtitle() {
    if (widget.subtitle != null) return widget.subtitle!;
    
    switch (widget.type) {
      case TimerType.preparation:
        return 'O treino começará em';
      case TimerType.countDown:
        return 'Próximo exercício em';
      case TimerType.countUp:
        return 'Tempo de execução';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimerCircle(),
        const SizedBox(height: 16),
        _buildTimerInfo(),
        if (widget.showControls) ...[
          const SizedBox(height: 24),
          _buildControls(),
        ],
      ],
    );
  }

  Widget _buildTimerCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _progressAnimation,
        _pulseAnimation,
        _glowAnimation,
        _scaleAnimation,
        _colorAnimation
      ]),
      builder: (context, child) {
        final scale = widget.type == TimerType.preparation 
            ? _pulseAnimation.value * _scaleAnimation.value
            : _scaleAnimation.value;

        final currentColor = _colorAnimation.value ?? _getTimerColor();

        return Transform.scale(
          scale: scale,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                // Sombra externa
                BoxShadow(
                  color: currentColor.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
                // Brilho animado para preparation
                if (widget.type == TimerType.preparation)
                  BoxShadow(
                    color: currentColor.withOpacity(_glowAnimation.value * 0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Background circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.backgroundColor ?? SportColors.grey100,
                  ),
                ),
                
                // Progress circle com gradiente
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CustomPaint(
                    painter: CircularProgressPainter(
                      progress: _progressAnimation.value,
                      color: currentColor,
                      strokeWidth: 12,
                      gradient: _getProgressGradient(currentColor),
                    ),
                  ),
                ),
                
                // Inner circle com gradiente sutil
                Center(
                  child: Container(
                    width: widget.size * 0.75,
                    height: widget.size * 0.75,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white,
                          SportColors.grey100,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _buildTimerContent(currentColor),
                  ),
                ),
                
                // Estado finished
                if (_state == TimerState.finished)
                  Center(
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SportColors.successGradient,
                        boxShadow: [
                          BoxShadow(
                            color: SportColors.success.withOpacity(0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerContent(Color currentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Tempo principal
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: widget.size * 0.15,
              fontWeight: FontWeight.w800,
              color: currentColor,
              letterSpacing: -1,
            ),
            child: Text(_formatTime(_currentSeconds)),
          ),
          
          const SizedBox(height: 4),
          
          // Status do timer
          AnimatedOpacity(
            opacity: _state == TimerState.finished ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Text(
              _getStateText(),
              style: TextStyle(
                fontSize: widget.size * 0.06,
                fontWeight: FontWeight.w600,
                color: currentColor.withOpacity(0.8),
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerInfo() {
    return Column(
      children: [
        Text(
          _getTimerTitle(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: SportColors.grey800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _getTimerSubtitle(),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: SportColors.grey600,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play/Pause button
        if (_state == TimerState.stopped || _state == TimerState.paused)
          _buildControlButton(
            icon: Icons.play_arrow_rounded,
            onPressed: _state == TimerState.stopped ? start : resume,
            color: _getTimerColor(),
            isPrimary: true,
          ),
        
        if (_state == TimerState.running)
          _buildControlButton(
            icon: Icons.pause_rounded,
            onPressed: pause,
            color: SportColors.warning,
            isPrimary: true,
          ),
        
        const SizedBox(width: 20),
        
        // Stop button
        if (_state != TimerState.stopped)
          _buildControlButton(
            icon: Icons.stop_rounded,
            onPressed: stop,
            color: SportColors.error,
            isPrimary: false,
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
    bool isPrimary = false,
  }) {
    return Container(
      width: isPrimary ? 64 : 56,
      height: isPrimary ? 64 : 56,
      decoration: BoxDecoration(
        gradient: isPrimary 
            ? LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isPrimary ? null : color.withOpacity(0.1),
        shape: BoxShape.circle,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.enableHaptics) {
              HapticFeedback.lightImpact();
            }
            onPressed();
          },
          borderRadius: BorderRadius.circular(32),
          child: Icon(
            icon,
            color: isPrimary ? Colors.white : color,
            size: isPrimary ? 28 : 24,
          ),
        ),
      ),
    );
  }

  LinearGradient _getProgressGradient(Color color) {
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
        color,
      ],
      stops: const [0.0, 0.5, 1.0],
    );
  }

  String _getStateText() {
    switch (_state) {
      case TimerState.running:
        return widget.type == TimerType.countUp ? 'EXECUTANDO' : 'CONTANDO';
      case TimerState.paused:
        return 'PAUSADO';
      case TimerState.stopped:
        return 'PARADO';
      case TimerState.finished:
        return 'CONCLUÍDO';
    }
  }
}

/// Custom painter para o progresso circular com gradiente
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final LinearGradient gradient;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Widgets helpers especializados
class PreparationTimerModern extends StatelessWidget {
  final int seconds;
  final VoidCallback? onFinished;

  const PreparationTimerModern({
    Key? key,
    required this.seconds,
    this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernExecutionTimer(
      type: TimerType.preparation,
      initialSeconds: seconds,
      onFinished: onFinished,
      autoStart: true,
      showControls: false,
      size: 200,
      title: 'Prepare-se!',
      subtitle: 'O treino começará em breve',
    );
  }
}

class RestTimerModern extends StatelessWidget {
  final int seconds;
  final VoidCallback? onFinished;
  final VoidCallback? onSkip;

  const RestTimerModern({
    Key? key,
    required this.seconds,
    this.onFinished,
    this.onSkip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ModernExecutionTimer(
          type: TimerType.countDown,
          initialSeconds: seconds,
          onFinished: onFinished,
          autoStart: true,
          showControls: false,
          size: 180,
          title: 'Descansando',
          subtitle: 'Próximo exercício em',
        ),
        if (onSkip != null) ...[
          const SizedBox(height: 20),
          SportWidgets.gradientButton(
            text: 'Pular Descanso',
            onPressed: onSkip!,
            gradient: SportColors.motivationalGradient,
            width: 200,
            height: 48,
            icon: Icons.skip_next_rounded,
          ),
        ],
      ],
    );
  }
}

class ExerciseTimerModern extends StatelessWidget {
  final VoidCallback? onTick;
  final String? exerciseName;

  const ExerciseTimerModern({
    Key? key,
    this.onTick,
    this.exerciseName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModernExecutionTimer(
      type: TimerType.countUp,
      initialSeconds: 0,
      onTick: onTick,
      autoStart: false,
      showControls: true,
      size: 160,
      title: exerciseName ?? 'Exercitando',
      subtitle: 'Tempo de execução',
    );
  }
}