import 'package:flutter/material.dart';
import '../../models/treino_model.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/common/empty_state.dart';
import 'dart:async';

class TreinoPreparacaoScreen extends StatefulWidget {
  final TreinoModel treino;

  const TreinoPreparacaoScreen({
    Key? key,
    required this.treino,
  }) : super(key: key);

  @override
  State<TreinoPreparacaoScreen> createState() => _TreinoPreparacaoScreenState();
}

class _TreinoPreparacaoScreenState extends State<TreinoPreparacaoScreen>
    with TickerProviderStateMixin {
  
  // Timer de preparação
  Timer? _preparationTimer;
  int _preparationSeconds = 10; // 10 segundos de preparação
  bool _isPreparationActive = false;
  
  // Animações
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fadeController.forward();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_fadeController);
  }

  void _startPreparationTimer() {
    setState(() {
      _isPreparationActive = true;
      _preparationSeconds = 10;
    });

    _pulseController.repeat(reverse: true);

    _preparationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _preparationSeconds--;
      });

      if (_preparationSeconds <= 0) {
        _finishPreparation();
      }
    });
  }

  void _finishPreparation() {
    _preparationTimer?.cancel();
    _pulseController.stop();
    
    // Navegar para tela de execução
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.treinoExecucao,
      arguments: widget.treino,
    );
  }

  void _skipPreparation() {
    if (_preparationTimer != null) {
      _preparationTimer?.cancel();
      _pulseController.stop();
    }
    _finishPreparation();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}min';
  }

  @override
  void dispose() {
    _preparationTimer?.cancel();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF667eea),
        elevation: 0,
        title: const Text(
          'Preparação do Treino',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: _buildContent(),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _isPreparationActive
              ? _buildPreparationTimer()
              : _buildExercisesList(),
        ),
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF667eea).withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.treino.nomeTreino,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.treino.tipoTreino ?? 'Treino',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                icon: Icons.fitness_center,
                label: '${widget.treino.exercicios.length} exercícios',
              ),
              if (widget.treino.duracaoEstimada != null)
                _buildInfoChip(
                  icon: Icons.timer,
                  label: _formatDuration(widget.treino.duracaoEstimada!),
                ),
              if (widget.treino.dificuldade != null)
                _buildInfoChip(
                  icon: Icons.trending_up,
                  label: widget.treino.dificuldade!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreparationTimer() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF667eea),
                        const Color(0xFF667eea).withOpacity(0.7),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667eea).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_preparationSeconds',
                      style: const TextStyle(
                        fontSize: 72,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Prepare-se!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF667eea),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O treino começará em breve',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: _skipPreparation,
                  child: const Text(
                    'Pular preparação',
                    style: TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.w600,
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

  Widget _buildExercisesList() {
    if (widget.treino.exercicios.isEmpty) {
      return const Center(
        child: EmptyState(
          title: 'Nenhum exercício',
          subtitle: 'Este treino não possui exercícios cadastrados',
          icon: Icons.fitness_center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exercícios do Treino',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.treino.exercicios.length,
              itemBuilder: (context, index) {
                final exercicio = widget.treino.exercicios[index];
                return _buildExercicioCard(exercicio, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercicioCard(dynamic exercicio, int ordem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '$ordem',
                style: const TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercicio.nomeExercicio ?? 'Exercício',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                if (exercicio.grupoMuscular != null)
                  Text(
                    exercicio.grupoMuscular!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                const SizedBox(height: 8),
                _buildExercicioInfo(exercicio),
              ],
            ),
          ),
          const Icon(
            Icons.play_circle_outline,
            color: Color(0xFF667eea),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildExercicioInfo(dynamic exercicio) {
    final List<String> info = [];
    
    if (exercicio.series != null) {
      info.add('${exercicio.series} séries');
    }
    
    if (exercicio.repeticoes != null) {
      info.add('${exercicio.repeticoes} reps');
    }
    
    if (exercicio.peso != null && exercicio.peso > 0) {
      info.add('${exercicio.peso}kg');
    }

    return Text(
      info.join(' • '),
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF667eea),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isPreparationActive) ...[
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: widget.treino.exercicios.isNotEmpty 
                    ? _startPreparationTimer 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      widget.treino.exercicios.isNotEmpty 
                          ? 'Iniciar Treino'
                          : 'Sem Exercícios',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (widget.treino.exercicios.isNotEmpty)
              TextButton(
                onPressed: _skipPreparation,
                child: const Text(
                  'Pular preparação',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}