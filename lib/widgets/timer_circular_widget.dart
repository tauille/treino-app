import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🕐 Timer Circular Customizado e Reutilizável
class TimerCircularWidget extends StatefulWidget {
  final int tempoAtual;
  final int tempoTotal;
  final bool isPausado;
  final Color corPrimaria;
  final Color corFundo;
  final double tamanho;
  final VoidCallback? onTap;

  const TimerCircularWidget({
    super.key,
    required this.tempoAtual,
    required this.tempoTotal,
    this.isPausado = false,
    this.corPrimaria = Colors.white,
    this.corFundo = Colors.white30,
    this.tamanho = 200,
    this.onTap,
  });

  @override
  State<TimerCircularWidget> createState() => _TimerCircularWidgetState();
}

class _TimerCircularWidgetState extends State<TimerCircularWidget>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    if (!widget.isPausado && widget.tempoAtual > 0) {
      _pulseController.repeat(reverse: true);
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(TimerCircularWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isPausado != oldWidget.isPausado) {
      if (widget.isPausado) {
        _pulseController.stop();
        _rotationController.stop();
      } else {
        _pulseController.repeat(reverse: true);
        _rotationController.repeat();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final progresso = widget.tempoTotal > 0 
        ? 1.0 - (widget.tempoAtual / widget.tempoTotal)
        : 0.0;
    
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.tamanho,
        height: widget.tamanho,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Círculo de fundo
            Container(
              width: widget.tamanho,
              height: widget.tamanho,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.corFundo,
              ),
            ),
            
            // Progresso circular customizado
            CustomPaint(
              size: Size(widget.tamanho, widget.tamanho),
              painter: CircularProgressPainter(
                progresso: progresso,
                cor: widget.corPrimaria,
                strokeWidth: 8,
              ),
            ),
            
            // Indicador rotativo (apenas visual)
            if (!widget.isPausado && widget.tempoAtual > 0)
              AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 2 * math.pi,
                    child: Container(
                      width: widget.tamanho - 20,
                      height: widget.tamanho - 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.corPrimaria.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.corPrimaria,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            // Tempo no centro com animação de pulso
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isPausado ? 1.0 : _pulseAnimation.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatarTempo(widget.tempoAtual),
                        style: TextStyle(
                          color: widget.corPrimaria,
                          fontSize: widget.tamanho * 0.18, // Responsivo
                          fontWeight: FontWeight.w900,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      if (widget.isPausado)
                        Text(
                          'PAUSADO',
                          style: TextStyle(
                            color: widget.corPrimaria.withOpacity(0.7),
                            fontSize: widget.tamanho * 0.06,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            
            // Ícone de pause sobreposto
            if (widget.isPausado)
              Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(top: 60),
                decoration: BoxDecoration(
                  color: widget.corPrimaria.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.pause_rounded,
                  color: widget.corPrimaria,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }
}

/// 🎨 Painter customizado para progresso circular
class CircularProgressPainter extends CustomPainter {
  final double progresso;
  final Color cor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progresso,
    required this.cor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = cor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Desenhar progresso
    const startAngle = -math.pi / 2; // Começar no topo
    final sweepAngle = 2 * math.pi * progresso;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
    
    // Adicionar gradiente sutil
    if (progresso > 0) {
      final gradientPaint = Paint()
        ..shader = SweepGradient(
          startAngle: startAngle,
          endAngle: startAngle + sweepAngle,
          colors: [
            cor.withOpacity(0.5),
            cor,
            cor.withOpacity(0.8),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progresso != progresso ||
           oldDelegate.cor != cor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}

/// 🕐 Timer Linear (Barra) para uso alternativo
class TimerLinearWidget extends StatelessWidget {
  final int tempoAtual;
  final int tempoTotal;
  final Color corPrimaria;
  final Color corFundo;
  final double altura;

  const TimerLinearWidget({
    super.key,
    required this.tempoAtual,
    required this.tempoTotal,
    this.corPrimaria = Colors.white,
    this.corFundo = Colors.white30,
    this.altura = 8,
  });

  @override
  Widget build(BuildContext context) {
    final progresso = tempoTotal > 0 ? 1.0 - (tempoAtual / tempoTotal) : 0.0;
    
    return Container(
      height: altura,
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(altura / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(altura / 2),
        child: LinearProgressIndicator(
          value: progresso,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(corPrimaria),
        ),
      ),
    );
  }
}