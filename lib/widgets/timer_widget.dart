import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final String tempoFormatado;
  final String label;
  final bool isMain;
  final Color? color;
  final VoidCallback? onTap;

  const TimerWidget({
    Key? key,
    required this.tempoFormatado,
    required this.label,
    this.isMain = false,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mainColor = color ?? (isMain ? Colors.blue : Colors.green);
    final fontSize = isMain ? 48.0 : 32.0;
    final labelSize = isMain ? 16.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isMain ? 24 : 16,
          horizontal: isMain ? 32 : 24,
        ),
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mainColor.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: mainColor.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer display
            Text(
              tempoFormatado,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: mainColor,
                fontFamily: 'monospace',
                letterSpacing: 2,
              ),
            ),
            
            if (label.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: labelSize,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MultiTimerWidget extends StatelessWidget {
  final String tempoTotal;
  final String tempoExercicio;
  final String? tempoDescanso;
  final bool emDescanso;

  const MultiTimerWidget({
    Key? key,
    required this.tempoTotal,
    required this.tempoExercicio,
    this.tempoDescanso,
    this.emDescanso = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Timer principal (total)
          TimerWidget(
            tempoFormatado: tempoTotal,
            label: 'Tempo Total',
            isMain: true,
          ),
          
          SizedBox(height: 16),
          
          // Timers secundários
          Row(
            children: [
              // Timer do exercício
              Expanded(
                child: TimerWidget(
                  tempoFormatado: tempoExercicio,
                  label: emDescanso ? 'Último Exercício' : 'Exercício Atual',
                  color: emDescanso ? Colors.grey : Colors.green,
                ),
              ),
              
              // Timer de descanso (se ativo)
              if (emDescanso && tempoDescanso != null) ...[
                SizedBox(width: 16),
                Expanded(
                  child: TimerWidget(
                    tempoFormatado: tempoDescanso!,
                    label: 'Descanso',
                    color: Colors.orange,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class CircularTimerWidget extends StatefulWidget {
  final int tempoTotalSegundos;
  final int tempoDecorridoSegundos;
  final String label;
  final Color color;
  final bool isCountdown;

  const CircularTimerWidget({
    Key? key,
    required this.tempoTotalSegundos,
    required this.tempoDecorridoSegundos,
    required this.label,
    this.color = Colors.blue,
    this.isCountdown = false,
  }) : super(key: key);

  @override
  State<CircularTimerWidget> createState() => _CircularTimerWidgetState();
}

class _CircularTimerWidgetState extends State<CircularTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(CircularTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tempoDecorridoSegundos != widget.tempoDecorridoSegundos) {
      _animationController.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.tempoTotalSegundos > 0
        ? (widget.tempoDecorridoSegundos / widget.tempoTotalSegundos).clamp(0.0, 1.0)
        : 0.0;

    final tempoRestante = widget.isCountdown
        ? widget.tempoTotalSegundos - widget.tempoDecorridoSegundos
        : widget.tempoDecorridoSegundos;

    final tempoFormatado = _formatarTempo(tempoRestante);

    return Container(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de fundo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[800],
            ),
          ),
          
          // Círculo de progresso
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: progress * _animationController.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                );
              },
            ),
          ),
          
          // Tempo no centro
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tempoFormatado,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class CountdownTimerWidget extends StatelessWidget {
  final int segundosRestantes;
  final String label;
  final Color color;
  final VoidCallback? onFinished;
  final VoidCallback? onCancel;

  const CountdownTimerWidget({
    Key? key,
    required this.segundosRestantes,
    required this.label,
    this.color = Colors.orange,
    this.onFinished,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tempoFormatado = _formatarTempo(segundosRestantes);
    final isUrgente = segundosRestantes <= 10;

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgente ? Colors.red : color,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isUrgente ? Colors.red : color).withOpacity(0.2),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ícone
          Icon(
            Icons.timer,
            size: 32,
            color: isUrgente ? Colors.red : color,
          ),
          
          SizedBox(height: 8),
          
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Countdown
          Text(
            tempoFormatado,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: isUrgente ? Colors.red : color,
              fontFamily: 'monospace',
            ),
          ),
          
          SizedBox(height: 16),
          
          // Botões
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onCancel != null) ...[
                TextButton(
                  onPressed: onCancel,
                  child: Text(
                    'Pular',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ),
                SizedBox(width: 16),
              ],
              
              ElevatedButton(
                onPressed: onFinished,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }
}