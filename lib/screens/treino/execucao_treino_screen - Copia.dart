import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'dart:async';
import '../../models/treino_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/sport_theme.dart';
import '../../providers/execucao_treino_provider.dart';
import '../../widgets/execution_timer_widget.dart';

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
  bool _isResting = false;
  bool _isPaused = false;
  
  // 🆕 ESTADOS PARA LÓGICA DOS TIMERS
  ExercicioModel? _exercicioAtual;
  int? _seriesAjustadas;
  int? _repeticoesAjustadas;
  int? _tempoExecucaoAjustado;
  int? _tempoDescansoAjustado;
  double? _pesoAjustado;
  
  // 🔧 CONTROLE DE TIMERS - CORRIGIDO
  Timer? _timerAtivo;
  int _tempoAtual = 0;
  bool _timerRodando = false;
  bool _showAdjustControls = true;
  
  // 🆕 ESTADOS DE EXECUÇÃO MAIS CLAROS
  TimerState _timerState = TimerState.waiting;
  
  // Controladores de animação
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupStatusBar();
    _enableWakelock();
    _initializeExercicio();
    
    if (widget.treino.exercicios.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoExercisesDialog();
      });
    }
  }

  void _initializeExercicio() {
    if (widget.treino.exercicios.isNotEmpty) {
      _exercicioAtual = widget.treino.exercicios[_currentExerciseIndex];
      _resetarValoresAjustados();
      _resetarTimer();
    }
  }

  void _resetarValoresAjustados() {
    if (_exercicioAtual != null) {
      _seriesAjustadas = _exercicioAtual!.series ?? 3;
      _repeticoesAjustadas = _exercicioAtual!.repeticoes ?? 12;
      _tempoExecucaoAjustado = _exercicioAtual!.tempoExecucao ?? 30;
      _tempoDescansoAjustado = _exercicioAtual!.tempoDescanso ?? 60;
      _pesoAjustado = _exercicioAtual!.peso ?? 0.0;
      _showAdjustControls = true;
    }
  }

  // 🆕 RESETAR TIMER
  void _resetarTimer() {
    _timerAtivo?.cancel();
    setState(() {
      _timerRodando = false;
      _tempoAtual = 0;
      _timerState = TimerState.waiting;
      _isResting = false;
    });
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupStatusBar() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _timerAtivo?.cancel();
    _disableWakelock();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.treino.exercicios.isEmpty) {
      return _buildEmptyState();
    }

    final currentExercise = widget.treino.exercicios[_currentExerciseIndex];

    return Scaffold(
      backgroundColor: SportColors.lightGrey,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column( // 🔧 MUDANÇA: Column no lugar de SingleChildScrollView
            children: [
              _buildModernAppBar(),
              _buildProgressSection(),
              Expanded( // 🔧 MUDANÇA: Expanded para o conteúdo
                child: SingleChildScrollView(
                  child: _buildExerciseScreen(currentExercise),
                ),
              ),
              _buildModernBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: SportColors.lightGrey,
      appBar: AppBar(
        backgroundColor: SportColors.primary,
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
              decoration: BoxDecoration(
                gradient: SportColors.primaryGradient,
                borderRadius: BorderRadius.circular(60),
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
                color: SportColors.grey800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Este treino não possui exercícios\npara executar',
              style: TextStyle(
                fontSize: 16,
                color: SportColors.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SportWidgets.gradientButton(
              text: 'Voltar',
              onPressed: () => Navigator.pop(context),
              gradient: SportColors.primaryGradient,
              width: 200,
              icon: Icons.arrow_back_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12, // 🔧 REDUZIDO: 16→12
        left: 16, // 🔧 REDUZIDO: 20→16
        right: 16, // 🔧 REDUZIDO: 20→16
        bottom: 12, // 🔧 REDUZIDO: 16→12
      ),
      decoration: BoxDecoration(
        gradient: SportColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: SportColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40, // 🔧 REDUZIDO: 44→40
            height: 40, // 🔧 REDUZIDO: 44→40
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showPauseDialog,
                borderRadius: BorderRadius.circular(10),
                child: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 22, // 🔧 REDUZIDO: 24→22
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12), // 🔧 REDUZIDO: 16→12
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.treino.nomeTreino,
                  style: const TextStyle(
                    fontSize: 16, // 🔧 REDUZIDO: 20→16 (-20%)
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2), // 🔧 REDUZIDO: 4→2
                Text(
                  _exercicioAtual?.nomeExercicio ?? 'Em execução',
                  style: TextStyle(
                    fontSize: 12, // 🔧 REDUZIDO: 14→12 (-14%)
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            width: 40, // 🔧 REDUZIDO: 44→40
            height: 40, // 🔧 REDUZIDO: 44→40
            decoration: BoxDecoration(
              color: SportColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showStopDialog,
                borderRadius: BorderRadius.circular(10),
                child: const Icon(
                  Icons.stop_rounded,
                  color: Colors.white,
                  size: 22, // 🔧 REDUZIDO: 24→22
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final totalExercises = widget.treino.exercicios.length;
    final currentProgress = (_currentExerciseIndex + 1) / totalExercises;
    
    return Container(
      padding: const EdgeInsets.all(16), // 🔧 REDUZIDO: 20→16
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            SportColors.primary,
            SportColors.primary.withOpacity(0.8),
            SportColors.lightGrey,
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProgressInfo(
                'Exercício',
                '${_currentExerciseIndex + 1}/$totalExercises',
                Icons.fitness_center_rounded,
              ),
              _buildProgressInfo(
                'Série',
                '$_currentSerie/${_seriesAjustadas ?? 1}',
                Icons.repeat_rounded,
              ),
              _buildProgressInfo(
                'Progresso',
                '${(currentProgress * 100).round()}%',
                Icons.timeline_rounded,
              ),
            ],
          ),
          
          const SizedBox(height: 12), // 🔧 REDUZIDO: 16→12
          
          Container(
            height: 6, // 🔧 REDUZIDO: 8→6
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3), // 🔧 REDUZIDO: 4→3
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: currentProgress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 40, // 🔧 REDUZIDO: 48→40 (-17%)
          height: 40, // 🔧 REDUZIDO: 48→40 (-17%)
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20, // 🔧 REDUZIDO: 24→20 (-17%)
          ),
        ),
        const SizedBox(height: 6), // 🔧 REDUZIDO: 8→6
        Text(
          value,
          style: const TextStyle(
            fontSize: 14, // 🔧 REDUZIDO: 18→14 (-22%)
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10, // 🔧 REDUZIDO: 12→10 (-17%)
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseScreen(dynamic exercise) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          Text(
            exercise.nomeExercicio ?? 'Exercício',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: SportColors.grey800,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          if (exercise.grupoMuscular != null)
            SportWidgets.difficultyBadge(
              difficulty: exercise.grupoMuscular!,
            ),
          
          const SizedBox(height: 40),
          
          if (_showAdjustControls) ...[
            _buildControlsSection(),
            const SizedBox(height: 30),
          ],
          
          // 🔧 TIMER PRINCIPAL - CORRIGIDO
          _buildTimerSection(),
          
          const SizedBox(height: 40),
          
          _buildExerciseInfoModern(exercise),
          
          const SizedBox(height: 40),
          
          if (exercise.observacoes != null) ...[
            _buildInstructionsCard(exercise.observacoes!),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsSection() {
    if (_exercicioAtual == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16), // 🔧 REDUZIDO: 20→16
      decoration: BoxDecoration(
        color: SportColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SportColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: SportColors.primary, size: 18), // 🔧 REDUZIDO: 20→18
              const SizedBox(width: 8),
              Text(
                'Ajustar Exercício',
                style: TextStyle(
                  fontSize: 14, // 🔧 REDUZIDO: 16→14 (-12%)
                  fontWeight: FontWeight.w700,
                  color: SportColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() {
                    _showAdjustControls = false;
                  });
                },
                icon: Icon(Icons.close, color: SportColors.grey600, size: 18), // 🔧 REDUZIDO: 20→18
              ),
            ],
          ),
          
          const SizedBox(height: 12), // 🔧 REDUZIDO: 16→12
          
          _buildControlRow(
            'Séries',
            '${_seriesAjustadas ?? 1}',
            () => _ajustarSeries(-1),
            () => _ajustarSeries(1),
          ),
          
          const SizedBox(height: 10), // 🔧 REDUZIDO: 12→10
          
          if (_exercicioAtual!.isRepeticao)
            _buildControlRow(
              'Repetições',
              '${_repeticoesAjustadas ?? 1}',
              () => _ajustarRepeticoes(-1),
              () => _ajustarRepeticoes(1),
            )
          else
            _buildControlRow(
              'Tempo (s)',
              '${_tempoExecucaoAjustado ?? 30}',
              () => _ajustarTempoExecucao(-5),
              () => _ajustarTempoExecucao(5),
            ),
          
          const SizedBox(height: 10), // 🔧 REDUZIDO: 12→10
          
          if (_pesoAjustado != null && _pesoAjustado! > 0)
            _buildControlRow(
              'Peso (kg)',
              '${_pesoAjustado!.toStringAsFixed(1)}',
              () => _ajustarPeso(-2.5),
              () => _ajustarPeso(2.5),
            ),
        ],
      ),
    );
  }

  Widget _buildControlRow(String label, String value, VoidCallback onMinus, VoidCallback onPlus) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13, // 🔧 REDUZIDO: 14→13 (-7%)
              fontWeight: FontWeight.w600,
              color: SportColors.grey700,
            ),
          ),
        ),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: SportColors.grey300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onMinus,
                icon: Icon(Icons.remove, color: SportColors.primary, size: 16),
                iconSize: 16,
                padding: const EdgeInsets.all(6), // 🔧 REDUZIDO: 8→6
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28), // 🔧 REDUZIDO: 32→28
              ),
              Container(
                width: 45, // 🔧 REDUZIDO: 50→45
                alignment: Alignment.center,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13, // 🔧 REDUZIDO: 14→13 (-7%)
                    fontWeight: FontWeight.w700,
                    color: SportColors.grey800,
                  ),
                ),
              ),
              IconButton(
                onPressed: onPlus,
                icon: Icon(Icons.add, color: SportColors.primary, size: 16),
                iconSize: 16,
                padding: const EdgeInsets.all(6), // 🔧 REDUZIDO: 8→6
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28), // 🔧 REDUZIDO: 32→28
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 🔧 TIMER SECTION - COMPLETAMENTE REESCRITO
  Widget _buildTimerSection() {
    if (_exercicioAtual == null) return const SizedBox();

    if (_exercicioAtual!.isTempo) {
      return _buildTimerExercicio();
    } else {
      return _buildRepeticaoExercicio();
    }
  }

  // 🆕 TIMER PARA EXERCÍCIOS POR TEMPO - LAYOUT OTIMIZADO
  Widget _buildTimerExercicio() {
    final timerColor = _getTimerColor();
    final timerText = _getTimerText();
    final statusText = _getStatusText();
    
    // Calcular progresso da barra
    final tempoTotal = _timerState == TimerState.executing 
        ? (_tempoExecucaoAjustado ?? 30)
        : (_tempoDescansoAjustado ?? 60);
    final progresso = _tempoAtual / tempoTotal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: timerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: timerColor.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          // Status atual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: timerColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12, // 🔧 REDUZIDO: 14→12 (-14%)
                fontWeight: FontWeight.w600,
                color: timerColor,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 🆕 TIMER GRANDE COM BARRA DE PROGRESSO
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_tempoAtual',
                style: TextStyle(
                  fontSize: 48, // 🔧 REDUZIDO: 56→48 (-14%)
                  fontWeight: FontWeight.w900,
                  color: timerColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'seg',
                style: TextStyle(
                  fontSize: 16, // 🔧 REDUZIDO: 18→16 (-11%)
                  fontWeight: FontWeight.w600,
                  color: SportColors.grey600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Status do timer
          Text(
            timerText,
            style: TextStyle(
              fontSize: 14, // 🔧 REDUZIDO: 16→14 (-12%)
              fontWeight: FontWeight.w700,
              color: timerColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 🆕 BARRA DE PROGRESSO HORIZONTAL
          Column(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: timerColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progresso.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(timerColor),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(progresso * 100).clamp(0, 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SportColors.grey600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progresso das séries
          _buildSeriesProgress(),
        ],
      ),
    );
  }

  // 🆕 EXERCÍCIO POR REPETIÇÕES - OTIMIZADO
  Widget _buildRepeticaoExercicio() {
    return Container(
      padding: const EdgeInsets.all(20), // 🔧 REDUZIDO: 30→20
      decoration: BoxDecoration(
        color: SportColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 48, // 🔧 REDUZIDO: 60→48 (-20%)
            color: SportColors.secondary,
          ),
          const SizedBox(height: 12), // 🔧 REDUZIDO: 16→12
          Text(
            'Faça ${_repeticoesAjustadas} repetições',
            style: TextStyle(
              fontSize: 18, // 🔧 REDUZIDO: 20→18 (-10%)
              fontWeight: FontWeight.w700,
              color: SportColors.grey800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Série $_currentSerie de ${_seriesAjustadas}',
            style: TextStyle(
              fontSize: 14, // 🔧 REDUZIDO: 16→14 (-12%)
              color: SportColors.grey600,
            ),
          ),
          const SizedBox(height: 16), // 🔧 REDUZIDO: 20→16
          _buildSeriesProgress(),
        ],
      ),
    );
  }

  // 🆕 PROGRESSO DAS SÉRIES - OTIMIZADO
  Widget _buildSeriesProgress() {
    final totalSeries = _seriesAjustadas ?? 1;
    final progress = _currentSerie / totalSeries;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSeries, (index) {
            final isCompleted = index < _currentSerie - 1;
            final isCurrent = index == _currentSerie - 1;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3), // 🔧 REDUZIDO: 4→3
              width: 10, // 🔧 REDUZIDO: 12→10
              height: 10, // 🔧 REDUZIDO: 12→10
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? SportColors.success
                    : isCurrent
                        ? SportColors.primary
                        : SportColors.grey300,
              ),
            );
          }),
        ),
        const SizedBox(height: 6), // 🔧 REDUZIDO: 8→6
        Text(
          'Série $_currentSerie de $totalSeries',
          style: TextStyle(
            fontSize: 11, // 🔧 REDUZIDO: 12→11
            color: SportColors.grey600,
          ),
        ),
      ],
    );
  }

  // 🆕 HELPERS PARA TIMER
  Color _getTimerColor() {
    switch (_timerState) {
      case TimerState.waiting:
        return SportColors.grey600;
      case TimerState.executing:
        return SportColors.primary;
      case TimerState.resting:
        return SportColors.warning;
      case TimerState.finished:
        return SportColors.success;
    }
  }

  String _getTimerText() {
    switch (_timerState) {
      case TimerState.waiting:
        return 'Toque para iniciar';
      case TimerState.executing:
        return 'EXECUÇÃO';
      case TimerState.resting:
        return 'DESCANSO';
      case TimerState.finished:
        return 'CONCLUÍDO';
    }
  }

  String _getStatusText() {
    if (_timerState == TimerState.waiting) {
      return 'Pronto para iniciar série $_currentSerie';
    } else if (_timerState == TimerState.executing) {
      return 'Executando série $_currentSerie de ${_seriesAjustadas}';
    } else if (_timerState == TimerState.resting) {
      return 'Descansando após série ${_currentSerie - 1}';
    } else {
      return 'Exercício concluído';
    }
  }

  Widget _buildExerciseInfoModern(dynamic exercise) {
    return SportWidgets.gradientCard(
      gradient: SportColors.primaryGradient.scale(0.1),
      child: Column(
        children: [
          if (_seriesAjustadas != null)
            _buildInfoRowModern(
              Icons.repeat_rounded,
              'Séries',
              '$_seriesAjustadas',
              SportColors.primary,
            ),
          if (_exercicioAtual?.isRepeticao == true && _repeticoesAjustadas != null) ...[
            const Divider(height: 16),
            _buildInfoRowModern(
              Icons.fitness_center_rounded,
              'Repetições',
              '$_repeticoesAjustadas',
              SportColors.accent,
            ),
          ],
          if (_exercicioAtual?.isTempo == true && _tempoExecucaoAjustado != null) ...[
            const Divider(height: 16),
            _buildInfoRowModern(
              Icons.timer_rounded,
              'Execução',
              '${_tempoExecucaoAjustado}s',
              SportColors.secondary,
            ),
          ],
          if (_pesoAjustado != null && _pesoAjustado! > 0) ...[
            const Divider(height: 16),
            _buildInfoRowModern(
              Icons.line_weight_rounded,
              'Peso',
              '${_pesoAjustado!.toStringAsFixed(1)}kg',
              SportColors.secondary,
            ),
          ],
          if (_tempoDescansoAjustado != null) ...[
            const Divider(height: 16),
            _buildInfoRowModern(
              Icons.timer_rounded,
              'Descanso',
              '${_tempoDescansoAjustado}s',
              SportColors.warning,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRowModern(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 40, // 🔧 REDUZIDO: 48→40 (-17%)
          height: 40, // 🔧 REDUZIDO: 48→40 (-17%)
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10), // 🔧 REDUZIDO: 12→10
          ),
          child: Icon(icon, color: color, size: 20), // 🔧 REDUZIDO: 24→20 (-17%)
        ),
        
        const SizedBox(width: 12), // 🔧 REDUZIDO: 16→12
        
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14, // 🔧 REDUZIDO: 18→14 (-22%)
              fontWeight: FontWeight.w600,
              color: SportColors.grey800,
            ),
          ),
        ),
        
        Text(
          value,
          style: TextStyle(
            fontSize: 16, // 🔧 REDUZIDO: 20→16 (-20%)
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard(String instructions) {
    return Container(
      padding: const EdgeInsets.all(16), // 🔧 REDUZIDO: 20→16
      decoration: BoxDecoration(
        color: SportColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12), // 🔧 REDUZIDO: 16→12
        border: Border.all(
          color: SportColors.info.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: SportColors.info,
                size: 20, // 🔧 REDUZIDO: 24→20
              ),
              const SizedBox(width: 8), // 🔧 REDUZIDO: 12→8
              const Text(
                'Instruções',
                style: TextStyle(
                  fontSize: 14, // 🔧 REDUZIDO: 18→14 (-22%)
                  fontWeight: FontWeight.w700,
                  color: SportColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // 🔧 REDUZIDO: 12→8
          Text(
            instructions,
            style: TextStyle(
              fontSize: 13, // 🔧 REDUZIDO: 16→13 (-19%)
              color: SportColors.grey700,
              height: 1.4, // 🔧 REDUZIDO: 1.5→1.4
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_currentExerciseIndex > 0)
                Expanded(
                  child: SportWidgets.gradientButton(
                    text: 'Anterior',
                    onPressed: _previousExercise,
                    gradient: LinearGradient(
                      colors: [SportColors.grey400, SportColors.grey500],
                    ),
                    height: 56,
                    icon: Icons.skip_previous_rounded,
                  ),
                ),
              
              if (_currentExerciseIndex > 0) const SizedBox(width: 16),
              
              Expanded(
                flex: 2,
                child: SportWidgets.gradientButton(
                  text: _getMainButtonText(),
                  onPressed: _getMainButtonAction(), // 🔧 CORREÇÃO: Removido nullable
                  gradient: _getMainButtonGradient() as LinearGradient,
                  height: 56,
                  icon: _getMainButtonIcon(),
                ),
              ),
              
              if (_currentExerciseIndex < widget.treino.exercicios.length - 1) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: SportWidgets.gradientButton(
                    text: 'Próximo',
                    onPressed: _nextExercise,
                    gradient: LinearGradient(
                      colors: [SportColors.grey400, SportColors.grey500],
                    ),
                    height: 56,
                    icon: Icons.skip_next_rounded,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 🔧 BOTÃO PRINCIPAL - SIMPLIFICADO
  String _getMainButtonText() {
    if (_exercicioAtual?.isTempo == true) {
      switch (_timerState) {
        case TimerState.waiting:
          return 'Iniciar Série $_currentSerie';
        case TimerState.executing:
          return 'Executando...';
        case TimerState.resting:
          return 'Descansando...';
        case TimerState.finished:
          return 'Finalizar Exercício';
      }
    } else {
      if (_currentSerie <= (_seriesAjustadas ?? 1)) {
        return 'Completar Série $_currentSerie';
      } else {
        return 'Finalizar Exercício';
      }
    }
  }

  IconData _getMainButtonIcon() {
    if (_isMainButtonDisabled()) {
      if (_timerState == TimerState.executing) {
        return Icons.timer;
      } else if (_timerState == TimerState.resting) {
        return Icons.coffee;
      }
    }
    
    if (_currentSerie > (_seriesAjustadas ?? 1) || _timerState == TimerState.finished) {
      return Icons.check_circle_rounded;
    } else {
      return Icons.play_arrow_rounded;
    }
  }

  // 🔧 VERIFICAR SE BOTÃO DEVE ESTAR DESABILITADO
  bool _isMainButtonDisabled() {
    if (_exercicioAtual?.isTempo == true) {
      return _timerState == TimerState.executing || _timerState == TimerState.resting;
    }
    return false;
  }

  Gradient _getMainButtonGradient() {
    if (_isMainButtonDisabled()) {
      return LinearGradient(
        colors: [SportColors.grey400, SportColors.grey500],
      );
    } else if (_timerState == TimerState.finished || _currentSerie > (_seriesAjustadas ?? 1)) {
      return SportColors.successGradient;
    } else {
      return SportColors.primaryGradient;
    }
  }

  VoidCallback _getMainButtonAction() {
    if (_exercicioAtual?.isTempo == true) {
      switch (_timerState) {
        case TimerState.waiting:
          return _iniciarTimer;
        case TimerState.executing:
        case TimerState.resting:
          return () {}; // 🔧 CORREÇÃO: Função vazia em vez de null
        case TimerState.finished:
          return _finalizarExercicio;
      }
    } else {
      if (_currentSerie <= (_seriesAjustadas ?? 1)) {
        return _completeSet;
      } else {
        return _finalizarExercicio;
      }
    }
  }

  // 🔧 MÉTODOS DE TIMER - REESCRITOS
  void _iniciarTimer() {
    if (_exercicioAtual == null || !_exercicioAtual!.isTempo) return;

    setState(() {
      _tempoAtual = _tempoExecucaoAjustado ?? 30;
      _timerState = TimerState.executing;
      _timerRodando = true;
      _showAdjustControls = false;
    });

    _timerAtivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoAtual--;
      });

      if (_tempoAtual <= 3 && _tempoAtual > 0) {
        HapticFeedback.lightImpact();
      }

      if (_tempoAtual <= 0) {
        _finalizarExecucao();
      }
    });

    HapticFeedback.mediumImpact();
    _showSnackBar('Série $_currentSerie iniciada! 💪', SportColors.primary);
  }

  void _finalizarExecucao() {
    _timerAtivo?.cancel();
    
    if (_currentSerie < (_seriesAjustadas ?? 1)) {
      // Ainda tem séries - iniciar descanso
      _iniciarDescanso();
    } else {
      // Todas as séries foram feitas
      setState(() {
        _timerState = TimerState.finished;
        _timerRodando = false;
      });
      HapticFeedback.heavyImpact();
      _showSnackBar('Exercício concluído! 🎉', SportColors.success);
    }
  }

  void _iniciarDescanso() {
    setState(() {
      _currentSerie++;
      _tempoAtual = _tempoDescansoAjustado ?? 60;
      _timerState = TimerState.resting;
    });

    _timerAtivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoAtual--;
      });

      if (_tempoAtual <= 3 && _tempoAtual > 0) {
        HapticFeedback.lightImpact();
      }

      if (_tempoAtual <= 0) {
        _finalizarDescanso();
      }
    });

    _showSnackBar('Descanso iniciado ⏱️', SportColors.warning);
  }

  void _finalizarDescanso() {
    _timerAtivo?.cancel();
    
    setState(() {
      _timerState = TimerState.waiting;
      _timerRodando = false;
      _showAdjustControls = true;
    });

    HapticFeedback.mediumImpact();
    
    // Auto-iniciar próxima série após 1 segundo
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _timerState == TimerState.waiting) {
        _iniciarTimer();
      }
    });
  }

  // MÉTODOS DE CONTROLE DE AJUSTE
  void _ajustarSeries(int delta) {
    setState(() {
      final novoValor = (_seriesAjustadas ?? 1) + delta;
      _seriesAjustadas = novoValor.clamp(1, 10);
    });
    HapticFeedback.lightImpact();
  }

  void _ajustarRepeticoes(int delta) {
    setState(() {
      final novoValor = (_repeticoesAjustadas ?? 1) + delta;
      _repeticoesAjustadas = novoValor.clamp(1, 100);
    });
    HapticFeedback.lightImpact();
  }

  void _ajustarTempoExecucao(int deltaSegundos) {
    setState(() {
      final novoValor = (_tempoExecucaoAjustado ?? 30) + deltaSegundos;
      _tempoExecucaoAjustado = novoValor.clamp(5, 300);
    });
    HapticFeedback.lightImpact();
  }

  void _ajustarPeso(double delta) {
    setState(() {
      final novoValor = (_pesoAjustado ?? 0.0) + delta;
      _pesoAjustado = novoValor.clamp(0.0, 500.0);
    });
    HapticFeedback.lightImpact();
  }

  void _finalizarExercicio() {
    _showSnackBar('Exercício completado! 🎉', SportColors.success);
    
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentExerciseIndex < widget.treino.exercicios.length - 1) {
        _nextExercise();
      } else {
        _finishTreino();
      }
    });
  }

  void _completeSet() {
    HapticFeedback.mediumImpact();
    
    if (_currentSerie < (_seriesAjustadas ?? 1)) {
      setState(() {
        _currentSerie++;
      });
      _showSnackBar('Série $_currentSerie concluída!', SportColors.success);
    } else {
      _finalizarExercicio();
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
      _finishTreino();
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
              _exercicioAtual?.isTempo == true 
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showPauseDialog() {
    setState(() {
      _isPaused = !_isPaused;
    });
    
    HapticFeedback.lightImpact();
    
    final message = _isPaused ? 'Treino pausado' : 'Treino retomado';
    final color = _isPaused ? SportColors.warning : SportColors.success;
    
    _showSnackBar(message, color);
  }

  void _showStopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Parar Treino?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Tem certeza que deseja parar o treino?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: SportColors.grey600),
            ),
          ),
          SportWidgets.gradientButton(
            text: 'Parar',
            onPressed: () {
              Navigator.pop(context);
              _finishTreino();
            },
            gradient: SportColors.motivationalGradient,
            width: 100,
            height: 40,
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
          SportWidgets.gradientButton(
            text: 'Voltar',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            gradient: SportColors.primaryGradient,
            width: 120,
            height: 40,
          ),
        ],
      ),
    );
  }

  void _finishTreino() {
    HapticFeedback.heavyImpact();
    
    _timerAtivo?.cancel();
    
    _showSnackBar('Treino "${widget.treino.nomeTreino}" finalizado! 🎉', SportColors.success);
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => route.settings.name == AppRoutes.home,
    );
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
      print('✅ Wakelock ATIVADO - tela sempre ativa');
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
}

// 🆕 ENUM PARA ESTADOS DO TIMER
enum TimerState {
  waiting,    // Aguardando início
  executing,  // Executando exercício
  resting,    // Descansando
  finished,   // Exercício finalizado
}