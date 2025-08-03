import 'package:flutter/material.dart';
import 'package:treino_app/core/theme/sport_theme.dart';
import 'dart:async';

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

class ExecutionTimerWidget extends StatefulWidget {
  final TimerType type;
  final int initialSeconds;
  final VoidCallback? onFinished;
  final VoidCallback? onTick;
  final bool autoStart;
  final Color? primaryColor;
  final Color? backgroundColor;
  final double size;
  final bool showControls;

  const ExecutionTimerWidget({
    Key? key,
    required this.type,
    required this.initialSeconds,
    this.onFinished,
    this.onTick,
    this.autoStart = false,
    this.primaryColor,
    this.backgroundColor,
    this.size = 200,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<ExecutionTimerWidget> createState() => _ExecutionTimerWidgetState();
}

class _ExecutionTimerWidgetState extends State<ExecutionTimerWidget>
    with TickerProviderStateMixin {
  
  Timer? _timer;
  int _currentSeconds = 0;
  TimerState _state = TimerState.stopped;
  
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.initialSeconds;
    _initAnimations();
    
    if (widget.autoStart) {
      start();
    }
  }

  void _initAnimations() {
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void start() {
    if (_state == TimerState.running) return;

    setState(() {
      _state = TimerState.running;
    });

    _progressController.forward();
    _startPulseAnimation();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (widget.type == TimerType.countDown || widget.type == TimerType.preparation) {
          _currentSeconds--;
        } else {
          _currentSeconds++;
        }
      });

      widget.onTick?.call();

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
    
    setState(() {
      _state = TimerState.paused;
    });
  }

  void resume() {
    if (_state != TimerState.paused) return;
    start();
  }

  void stop() {
    _timer?.cancel();
    _progressController.reset();
    _pulseController.stop();
    
    setState(() {
      _currentSeconds = widget.initialSeconds;
      _state = TimerState.stopped;
    });
  }

  void _finish() {
    _timer?.cancel();
    _progressController.stop();
    _pulseController.stop();
    
    setState(() {
      _state = TimerState.finished;
    });

    widget.onFinished?.call();
  }

  void _startPulseAnimation() {
    if (widget.type == TimerType.preparation) {
      _pulseController.repeat(reverse: true);
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Color get _primaryColor => widget.primaryColor ?? SportColors.primary;
  Color get _backgroundColor => widget.backgroundColor ?? Colors.grey.shade200;

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimerCircle(),
        if (widget.showControls) ...[
          const SizedBox(height: 24),
          _buildControls(),
        ],
      ],
    );
  }

  Widget _buildTimerCircle() {
    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _pulseAnimation]),
      builder: (context, child) {
        final scale = widget.type == TimerType.preparation 
            ? _pulseAnimation.value 
            : 1.0;

        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              children: [
                // Background circle
                Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _backgroundColor,
                  ),
                ),
                
                // Progress circle
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: CircularProgressIndicator(
                    value: _progressAnimation.value,
                    strokeWidth: 8,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                  ),
                ),
                
                // Time text
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.type == TimerType.countUp 
                            ? _formatTime(_currentSeconds)
                            : _formatTime(_currentSeconds),
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold).copyWith(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.type == TimerType.preparation) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Prepare-se',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500).copyWith(
                            color: _primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // State indicator
                if (_state == TimerState.finished)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
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

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play/Pause button
        if (_state == TimerState.stopped || _state == TimerState.paused)
          _buildControlButton(
            icon: Icons.play_arrow,
            onPressed: _state == TimerState.stopped ? start : resume,
            color: _primaryColor,
          ),
        
        if (_state == TimerState.running)
          _buildControlButton(
            icon: Icons.pause,
            onPressed: pause,
            color: _primaryColor,
          ),
        
        const SizedBox(width: 16),
        
        // Stop button
        if (_state != TimerState.stopped)
          _buildControlButton(
            icon: Icons.stop,
            onPressed: stop,
            color: Colors.grey.shade600,
          ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        iconSize: 32,
      ),
    );
  }
}

// Widget helper para casos específicos
class PreparationTimer extends StatelessWidget {
  final int seconds;
  final VoidCallback? onFinished;

  const PreparationTimer({
    Key? key,
    required this.seconds,
    this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExecutionTimerWidget(
      type: TimerType.preparation,
      initialSeconds: seconds,
      onFinished: onFinished,
      autoStart: true,
      showControls: false,
      size: 180,
    );
  }
}

class RestTimer extends StatelessWidget {
  final int seconds;
  final VoidCallback? onFinished;

  const RestTimer({
    Key? key,
    required this.seconds,
    this.onFinished,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExecutionTimerWidget(
      type: TimerType.countDown,
      initialSeconds: seconds,
      onFinished: onFinished,
      autoStart: true,
      showControls: true,
      size: 160,
    );
  }
}

class ExerciseTimer extends StatelessWidget {
  final VoidCallback? onTick;

  const ExerciseTimer({
    Key? key,
    this.onTick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExecutionTimerWidget(
      type: TimerType.countUp,
      initialSeconds: 0,
      onTick: onTick,
      autoStart: false,
      showControls: true,
      size: 140,
    );
  }
}