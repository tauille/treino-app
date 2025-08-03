import 'package:flutter/material.dart';
import 'package:treino_app/core/theme/sport_theme.dart';

enum ExerciseStatus {
  pending,     // Ainda não foi executado
  current,     // Está sendo executado agora
  completed,   // Já foi completado
  skipped,     // Foi pulado
}

class ExecutionExerciseCard extends StatelessWidget {
  final dynamic exercicio; // Pode ser ExercicioModel ou Map
  final ExerciseStatus status;
  final int currentSerie;
  final int totalSeries;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool showProgress;

  const ExecutionExerciseCard({
    Key? key,
    required this.exercicio,
    this.status = ExerciseStatus.pending,
    this.currentSerie = 1,
    this.totalSeries = 1,
    this.onTap,
    this.isCompact = false,
    this.showProgress = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: isCompact ? 4 : 8,
        ),
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: status == ExerciseStatus.current ? 2 : 1,
          ),
          boxShadow: status == ExerciseStatus.current
              ? [
                  BoxShadow(
                    color: SportTheme.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: isCompact ? _buildCompactLayout() : _buildFullLayout(),
      ),
    );
  }

  Widget _buildFullLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildStatusIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercicio.nomeExercicio ?? 'Exercício',
                    style: SportTheme.textTheme.subtitle1?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                    ),
                  ),
                  if (exercicio.grupoMuscular != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      exercicio.grupoMuscular,
                      style: SportTheme.textTheme.caption?.copyWith(
                        color: SportTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showProgress && totalSeries > 1)
              _buildProgressChip(),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Informações de execução
        _buildExecutionInfo(),
        
        // Progress bar para séries
        if (showProgress && status == ExerciseStatus.current && totalSeries > 1) ...[
          const SizedBox(height: 12),
          _buildProgressBar(),
        ],
        
        // Observações se houver
        if (exercicio.observacoes != null && exercicio.observacoes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    exercicio.observacoes,
                    style: SportTheme.textTheme.caption?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompactLayout() {
    return Row(
      children: [
        _buildStatusIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercicio.nomeExercicio ?? 'Exercício',
                style: SportTheme.textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _getTextColor(),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                _getCompactInfo(),
                style: SportTheme.textTheme.caption?.copyWith(
                  color: SportTheme.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
        if (showProgress && totalSeries > 1)
          _buildProgressChip(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (status) {
      case ExerciseStatus.pending:
        icon = Icons.radio_button_unchecked;
        color = Colors.grey.shade400;
        break;
      case ExerciseStatus.current:
        icon = Icons.play_circle_filled;
        color = SportTheme.primaryColor;
        break;
      case ExerciseStatus.completed:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case ExerciseStatus.skipped:
        icon = Icons.skip_next;
        color = Colors.orange;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20,
      ),
    );
  }

  Widget _buildExecutionInfo() {
    final List<Widget> infoChips = [];

    // Séries
    if (exercicio.series != null && exercicio.series > 0) {
      infoChips.add(_buildInfoChip(
        icon: Icons.repeat,
        text: '${exercicio.series} séries',
      ));
    }

    // Repetições ou tempo
    if (exercicio.tipoExecucao == 'repeticao' && exercicio.repeticoes != null) {
      infoChips.add(_buildInfoChip(
        icon: Icons.fitness_center,
        text: '${exercicio.repeticoes} reps',
      ));
    } else if (exercicio.tipoExecucao == 'tempo' && exercicio.tempoExecucao != null) {
      infoChips.add(_buildInfoChip(
        icon: Icons.timer,
        text: '${exercicio.tempoExecucao}s',
      ));
    }

    // Peso
    if (exercicio.peso != null && exercicio.peso > 0) {
      infoChips.add(_buildInfoChip(
        icon: Icons.line_weight,
        text: '${exercicio.peso}${exercicio.unidadePeso ?? 'kg'}',
      ));
    }

    // Descanso
    if (exercicio.tempoDescanso != null && exercicio.tempoDescanso > 0) {
      infoChips.add(_buildInfoChip(
        icon: Icons.pause,
        text: '${exercicio.tempoDescanso}s descanso',
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: infoChips,
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getChipBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: _getChipTextColor(),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: SportTheme.textTheme.caption?.copyWith(
              color: _getChipTextColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: SportTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$currentSerie/$totalSeries',
        style: SportTheme.textTheme.caption?.copyWith(
          color: SportTheme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = currentSerie / totalSeries;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progresso das Séries',
          style: SportTheme.textTheme.caption?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(SportTheme.primaryColor),
          minHeight: 6,
        ),
      ],
    );
  }

  String _getCompactInfo() {
    final List<String> info = [];
    
    if (exercicio.series != null) {
      info.add('${exercicio.series} séries');
    }
    
    if (exercicio.tipoExecucao == 'repeticao' && exercicio.repeticoes != null) {
      info.add('${exercicio.repeticoes} reps');
    } else if (exercicio.tipoExecucao == 'tempo' && exercicio.tempoExecucao != null) {
      info.add('${exercicio.tempoExecucao}s');
    }
    
    return info.join(' • ');
  }

  Color _getBackgroundColor() {
    switch (status) {
      case ExerciseStatus.pending:
        return Colors.white;
      case ExerciseStatus.current:
        return SportTheme.primaryColor.withOpacity(0.05);
      case ExerciseStatus.completed:
        return Colors.green.withOpacity(0.05);
      case ExerciseStatus.skipped:
        return Colors.orange.withOpacity(0.05);
    }
  }

  Color _getBorderColor() {
    switch (status) {
      case ExerciseStatus.pending:
        return Colors.grey.shade200;
      case ExerciseStatus.current:
        return SportTheme.primaryColor;
      case ExerciseStatus.completed:
        return Colors.green;
      case ExerciseStatus.skipped:
        return Colors.orange;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case ExerciseStatus.pending:
        return SportTheme.textPrimaryColor;
      case ExerciseStatus.current:
        return SportTheme.primaryColor;
      case ExerciseStatus.completed:
        return Colors.green.shade700;
      case ExerciseStatus.skipped:
        return Colors.orange.shade700;
    }
  }

  Color _getChipBackgroundColor() {
    switch (status) {
      case ExerciseStatus.current:
        return SportTheme.primaryColor.withOpacity(0.1);
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getChipTextColor() {
    switch (status) {
      case ExerciseStatus.current:
        return SportTheme.primaryColor;
      default:
        return SportTheme.textSecondaryColor;
    }
  }
}