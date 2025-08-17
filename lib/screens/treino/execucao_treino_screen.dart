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
          child: Column(
            children: [
              _buildModernAppBar(),
              _buildProgressSection(),
              Expanded(
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
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 12,
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showPauseDialog,
                borderRadius: BorderRadius.circular(10),
                child: Icon(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.treino.nomeTreino,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _exercicioAtual?.nomeExercicio ?? 'Em execução',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SportColors.error.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showStopDialog,
                borderRadius: BorderRadius.circular(10),
                child: const Icon(
                  Icons.stop_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 CORREÇÃO OVERFLOW: Progress section usando Wrap
  Widget _buildProgressSection() {
    final totalExercises = widget.treino.exercicios.length;
    final currentProgress = (_currentExerciseIndex + 1) / totalExercises;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 🔧 REDUZIDO: 16→12
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
          // 🔧 CORREÇÃO: Wrap em vez de Row para evitar overflow
          Wrap(
            spacing: 8, // 🔧 Espaçamento entre elementos
            runSpacing: 4, // 🔧 Espaçamento entre linhas
            alignment: WrapAlignment.spaceEvenly,
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
          
          const SizedBox(height: 10), // 🔧 REDUZIDO: 12→10
          
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
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

  // 🔧 CORREÇÃO: Progress info mais compacto
  Widget _buildProgressInfo(String label, String value, IconData icon) {
    return SizedBox(
      width: 90, // 🔧 LARGURA FIXA MENOR para evitar overflow
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32, // 🔧 REDUZIDO: 36→32
            height: 32, // 🔧 REDUZIDO: 36→32
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16, // 🔧 REDUZIDO: 18→16
            ),
          ),
          const SizedBox(height: 3), // 🔧 REDUZIDO: 4→3
          Text(
            value,
            style: const TextStyle(
              fontSize: 11, // 🔧 REDUZIDO: 12→11
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 8, // 🔧 REDUZIDO: 9→8
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
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

  // 🔥 CONTROLES ATUALIZADOS - COM TEMPO DE DESCANSO
  Widget _buildControlsSection() {
    if (_exercicioAtual == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(Icons.tune, color: SportColors.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Ajustar Exercício',
                style: TextStyle(
                  fontSize: 14,
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
                icon: Icon(Icons.close, color: SportColors.grey600, size: 18),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 🆕 SÉRIES
          _buildControlRow(
            'Séries',
            '${_seriesAjustadas ?? 1}',
            () => _ajustarSeries(-1),
            () => _ajustarSeries(1),
          ),
          
          const SizedBox(height: 10),
          
          // 🆕 REPETIÇÕES OU TEMPO DE EXECUÇÃO
          if (_exercicioAtual!.isRepeticao)
            _buildControlRow(
              'Repetições',
              '${_repeticoesAjustadas ?? 1}',
              () => _ajustarRepeticoes(-1),
              () => _ajustarRepeticoes(1),
            )
          else
            _buildControlRow(
              'Tempo Exec (s)',
              '${_tempoExecucaoAjustado ?? 30}',
              () => _ajustarTempoExecucao(-5),
              () => _ajustarTempoExecucao(5),
            ),
          
          const SizedBox(height: 10),
          
          // 🔥 NOVO: SEMPRE MOSTRAR TEMPO DE DESCANSO
          _buildControlRow(
            'Descanso (s)',
            '${_tempoDescansoAjustado ?? 60}',
            () => _ajustarTempoDescanso(-5),
            () => _ajustarTempoDescanso(5),
          ),
          
          const SizedBox(height: 10),
          
          // 🆕 PESO (só se tiver peso)
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
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SportColors.grey700,
            ),
          ),
        ),
        
        Flexible(
          child: Container(
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
                  icon: Icon(Icons.remove, color: SportColors.primary, size: 14),
                  iconSize: 14,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: FittedBox(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: SportColors.grey800,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onPlus,
                  icon: Icon(Icons.add, color: SportColors.primary, size: 14),
                  iconSize: 14,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                ),
              ],
            ),
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

  // 🆕 TIMER PARA EXERCÍCIOS POR TEMPO - COM BARRA DE DESCANSO CORRIGIDA
  Widget _buildTimerExercicio() {
    final timerColor = _getTimerColor();
    final timerText = _getTimerText();
    final statusText = _getStatusText();
    
    // 🔧 CORREÇÃO: Calcular progresso da barra corretamente
    final tempoTotal = _timerState == TimerState.executing 
        ? (_tempoExecucaoAjustado ?? 30)
        : (_tempoDescansoAjustado ?? 60);
    
    // 🔧 LÓGICA CORRIGIDA: progresso diferente para execução vs descanso
    final double progresso;
    if (_timerState == TimerState.executing) {
      // Durante execução: progresso cresce conforme tempo passa
      progresso = (_tempoExecucaoAjustado! - _tempoAtual) / _tempoExecucaoAjustado!;
    } else if (_timerState == TimerState.resting) {
      // Durante descanso: progresso cresce conforme tempo de descanso passa
      progresso = (_tempoDescansoAjustado! - _tempoAtual) / _tempoDescansoAjustado!;
    } else {
      progresso = 0.0;
    }

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
                fontSize: 12,
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
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: timerColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'seg',
                style: TextStyle(
                  fontSize: 16,
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
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: timerColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 🆕 BARRA DE PROGRESSO HORIZONTAL - CORRIGIDA PARA DESCANSO
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 🆕 LABEL DO TIPO DE TIMER COM ÍCONE
                  Row(
                    children: [
                      Icon(
                        _timerState == TimerState.resting 
                            ? Icons.coffee_rounded 
                            : Icons.fitness_center_rounded,
                        size: 12,
                        color: timerColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _timerState == TimerState.resting ? 'Descanso' : 'Execução',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: timerColor,
                        ),
                      ),
                    ],
                  ),
                  // PROGRESSO PERCENTUAL
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
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Progresso das séries
          _buildSeriesProgress(),
        ],
      ),
    );
  }

  // 🔥 EXERCÍCIO POR REPETIÇÕES - AGORA COM TIMER DE DESCANSO!
  Widget _buildRepeticaoExercicio() {
    // 🔥 NOVA FUNCIONALIDADE: Se está em descanso, mostrar timer de descanso
    if (_timerState == TimerState.resting) {
      return _buildTimerDescansoRepeticao();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 🎨 CORREÇÃO LEGIBILIDADE: Azul em vez de laranja
        color: SportColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SportColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 48,
            color: SportColors.primary, // 🎨 CORREÇÃO: Azul em vez de laranja
          ),
          const SizedBox(height: 12),
          Text(
            'Faça ${_repeticoesAjustadas} repetições',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: SportColors.grey800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Série $_currentSerie de ${_seriesAjustadas}',
            style: TextStyle(
              fontSize: 14,
              color: SportColors.grey600,
            ),
          ),
          const SizedBox(height: 16),
          _buildSeriesProgress(),
        ],
      ),
    );
  }

  // 🔥 NOVA FUNCIONALIDADE: Timer de descanso para exercícios de repetição
  Widget _buildTimerDescansoRepeticao() {
    final tempoTotal = _tempoDescansoAjustado ?? 60;
    final progresso = (_tempoDescansoAjustado! - _tempoAtual) / _tempoDescansoAjustado!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // 🎨 BARRA LARANJA PARA DESCANSO - MAIS VISÍVEL
        color: SportColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SportColors.warning.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          // Status de descanso
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SportColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.coffee_rounded, size: 14, color: SportColors.warning),
                const SizedBox(width: 4),
                Text(
                  'DESCANSO APÓS SÉRIE ${_currentSerie - 1}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: SportColors.warning,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Timer grande
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_tempoAtual',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: SportColors.warning,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'seg',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: SportColors.grey600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'DESCANSANDO',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: SportColors.warning,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 🎨 BARRA DE PROGRESSO LARANJA para descanso
          Column(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: SportColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progresso.clamp(0.0, 1.0),
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(SportColors.warning),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.coffee_rounded, size: 12, color: SportColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        'Descanso',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: SportColors.warning,
                        ),
                      ),
                    ],
                  ),
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
            ],
          ),
          
          const SizedBox(height: 16),
          
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
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 10,
              height: 10,
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
        const SizedBox(height: 6),
        Text(
          'Série $_currentSerie de $totalSeries',
          style: TextStyle(
            fontSize: 11,
            color: SportColors.grey600,
          ),
        ),
      ],
    );
  }

  // 🆕 HELPERS PARA TIMER - CORES DIFERENTES PARA DESCANSO
  Color _getTimerColor() {
    switch (_timerState) {
      case TimerState.waiting:
        return SportColors.grey600;
      case TimerState.executing:
        return SportColors.primary;
      case TimerState.resting:
        return SportColors.warning; // 🎨 COR LARANJA PARA DESCANSO
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
        return 'DESCANSO'; // 🆕 TEXTO PARA DESCANSO
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
      return 'Descansando após série ${_currentSerie - 1}'; // 🆕 STATUS PARA DESCANSO
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
              SportColors.primary, // 🎨 CORREÇÃO: Azul em vez de laranja
            ),
          ],
          if (_pesoAjustado != null && _pesoAjustado! > 0) ...[
            const Divider(height: 16),
            _buildInfoRowModern(
              Icons.line_weight_rounded,
              'Peso',
              '${_pesoAjustado!.toStringAsFixed(1)}kg',
              SportColors.primary, // 🎨 CORREÇÃO: Azul em vez de laranja
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        
        const SizedBox(width: 12),
        
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: SportColors.grey800,
            ),
          ),
        ),
        
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard(String instructions) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SportColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Instruções',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SportColors.grey800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            instructions,
            style: TextStyle(
              fontSize: 13,
              color: SportColors.grey700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // 🔧 CORREÇÃO CRÍTICA: Bottom Controls SEM OVERFLOW
  Widget _buildModernBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8), // 🔧 ULTRA COMPACTO: 10→8
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
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🆕 BOTÃO PRINCIPAL (sempre visível)
            SizedBox(
              width: double.infinity,
              height: 40, // 🔧 ALTURA REDUZIDA: 42→40
              child: ElevatedButton.icon(
                onPressed: _getMainButtonAction(),
                icon: Icon(
                  _getMainButtonIcon(),
                  size: 16,
                ),
                label: Text(
                  _getMainButtonTextShort(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getMainButtonColor(),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            // 🆕 NAVEGAÇÃO (só se necessário e em linha separada)
            if (_currentExerciseIndex > 0 || 
                _currentExerciseIndex < widget.treino.exercicios.length - 1) ...[
              const SizedBox(height: 4), // 🔧 ESPAÇAMENTO MENOR: 6→4
              
              // 🔧 CORREÇÃO: Layout em colunas para telas pequenas
              LayoutBuilder(
                builder: (context, constraints) {
                  // Se a tela for muito pequena, usar layout vertical
                  if (constraints.maxWidth < 300) {
                    return Column(
                      children: [
                        if (_currentExerciseIndex > 0)
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: _buildNavButton('Anterior', Icons.skip_previous_rounded, _previousExercise),
                          ),
                        if (_currentExerciseIndex > 0 && _currentExerciseIndex < widget.treino.exercicios.length - 1)
                          const SizedBox(height: 4),
                        if (_currentExerciseIndex < widget.treino.exercicios.length - 1)
                          SizedBox(
                            width: double.infinity,
                            height: 28,
                            child: _buildNavButton('Próximo', Icons.skip_next_rounded, _nextExercise),
                          ),
                      ],
                    );
                  } else {
                    // Layout normal em linha
                    return Row(
                      children: [
                        if (_currentExerciseIndex > 0)
                          Expanded(
                            child: SizedBox(
                              height: 28,
                              child: _buildNavButton('Ant', Icons.skip_previous_rounded, _previousExercise),
                            ),
                          ),
                        if (_currentExerciseIndex > 0 && _currentExerciseIndex < widget.treino.exercicios.length - 1)
                          const SizedBox(width: 4),
                        if (_currentExerciseIndex < widget.treino.exercicios.length - 1)
                          Expanded(
                            child: SizedBox(
                              height: 28,
                              child: _buildNavButton('Pró', Icons.skip_next_rounded, _nextExercise),
                            ),
                          ),
                      ],
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 🔧 HELPER PARA BOTÕES DE NAVEGAÇÃO
  Widget _buildNavButton(String text, IconData icon, VoidCallback onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 12), // 🔧 ÍCONE MENOR: 14→12
      label: Text(
        text,
        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500), // 🔧 TEXTO MENOR: 10→9
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: SportColors.grey600,
        side: BorderSide(color: SportColors.grey300, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // 🔧 PADDING MENOR
      ),
    );
  }

  // 🔥 CORREÇÃO PRINCIPAL: Finalizar treino - texto do botão
  String _getMainButtonTextShort() {
    if (_exercicioAtual?.isTempo == true) {
      switch (_timerState) {
        case TimerState.waiting:
          return 'Iniciar S$_currentSerie';
        case TimerState.executing:
          return 'Executando...';
        case TimerState.resting:
          return 'Descansando...';
        case TimerState.finished:
          // 🔥 VERIFICAR SE É ÚLTIMO EXERCÍCIO
          if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
            return 'Finalizar Treino 🎉';
          } else {
            return 'Próximo Exercício';
          }
      }
    } else {
      if (_currentSerie <= (_seriesAjustadas ?? 1)) {
        return 'Completar S$_currentSerie';
      } else {
        // 🔥 VERIFICAR SE É ÚLTIMO EXERCÍCIO
        if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
          return 'Finalizar Treino 🎉';
        } else {
          return 'Próximo Exercício';
        }
      }
    }
  }

  // 🔧 BOTÃO PRINCIPAL ORIGINAL - MANTIDO PARA COMPATIBILIDADE
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

  // 🔥 ÍCONE DO BOTÃO CORRIGIDO PARA ÚLTIMO EXERCÍCIO
  IconData _getMainButtonIcon() {
    if (_isMainButtonDisabled()) {
      if (_timerState == TimerState.executing) {
        return Icons.timer;
      } else if (_timerState == TimerState.resting) {
        return Icons.coffee;
      }
    }
    
    // 🔥 LÓGICA CORRIGIDA PARA ÚLTIMO EXERCÍCIO
    final isLastExercise = _currentExerciseIndex >= widget.treino.exercicios.length - 1;
    final exerciseFinished = _currentSerie > (_seriesAjustadas ?? 1) || _timerState == TimerState.finished;
    
    if (exerciseFinished && isLastExercise) {
      return Icons.celebration_rounded; // 🎉 Ícone de finalizar treino
    } else if (exerciseFinished) {
      return Icons.arrow_forward_rounded; // ➡️ Próximo exercício
    } else {
      return Icons.play_arrow_rounded; // ▶️ Iniciar/continuar
    }
  }

  // 🔥 COR DO BOTÃO CORRIGIDA PARA ÚLTIMO EXERCÍCIO
  Color _getMainButtonColor() {
    if (_isMainButtonDisabled()) {
      return SportColors.grey500;
    }
    
    // 🔥 LÓGICA PARA COR DO BOTÃO
    final isLastExercise = _currentExerciseIndex >= widget.treino.exercicios.length - 1;
    final exerciseFinished = _currentSerie > (_seriesAjustadas ?? 1) || _timerState == TimerState.finished;
    
    if (exerciseFinished && isLastExercise) {
      return SportColors.success; // 🟢 Verde para finalizar treino
    } else if (exerciseFinished) {
      return SportColors.accent; // 🟠 Laranja para próximo exercício
    } else {
      return SportColors.primary; // 🔵 Azul para ações normais
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
          return () {};
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

  // 🔥 NOVO MÉTODO: Ajustar tempo de descanso
  void _ajustarTempoDescanso(int deltaSegundos) {
    setState(() {
      final novoValor = (_tempoDescansoAjustado ?? 60) + deltaSegundos;
      _tempoDescansoAjustado = novoValor.clamp(5, 300); // Entre 5s e 5min
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

  // 🔥 CORREÇÃO CRÍTICA: Finalizar exercício corretamente
  void _finalizarExercicio() {
    _showSnackBar('Exercício completado! 🎉', SportColors.success);
    
    // 🔧 LÓGICA CORRIGIDA: Verificar se é o último exercício
    if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
      // 🔥 É o último exercício - FINALIZAR TREINO
      Future.delayed(const Duration(seconds: 2), () {
        _finishTreino();
      });
    } else {
      // 🔄 Não é o último - próximo exercício
      Future.delayed(const Duration(seconds: 1), () {
        _nextExercise();
      });
    }
  }

  // 🔥 CORREÇÃO PRINCIPAL: Timer de descanso para exercícios de repetição
  void _completeSet() {
    HapticFeedback.mediumImpact();
    
    if (_currentSerie < (_seriesAjustadas ?? 1)) {
      // 🔥 NOVA FUNCIONALIDADE: Iniciar timer de descanso para repetições
      _iniciarDescansoRepeticao();
    } else {
      _finalizarExercicio();
    }
  }

  // 🔥 NOVO MÉTODO: Timer de descanso para exercícios de repetição
  void _iniciarDescansoRepeticao() {
    setState(() {
      _currentSerie++;
      _tempoAtual = _tempoDescansoAjustado ?? 60;
      _timerState = TimerState.resting;
      _timerRodando = true;
    });

    _timerAtivo = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _tempoAtual--;
      });

      if (_tempoAtual <= 3 && _tempoAtual > 0) {
        HapticFeedback.lightImpact();
      }

      if (_tempoAtual <= 0) {
        _finalizarDescansoRepeticao();
      }
    });

    _showSnackBar('Descanso iniciado! ⏱️ Próxima série: $_currentSerie', SportColors.warning);
  }

  // 🔥 NOVO MÉTODO: Finalizar descanso para repetições
  void _finalizarDescansoRepeticao() {
    _timerAtivo?.cancel();
    
    setState(() {
      _timerState = TimerState.waiting;
      _timerRodando = false;
    });

    HapticFeedback.mediumImpact();
    _showSnackBar('Descanso terminado! Vamos para série $_currentSerie! 💪', SportColors.success);
  }

  // 🔧 CORREÇÃO: NextExercise mais claro
  void _nextExercise() {
    HapticFeedback.lightImpact();
    
    if (_currentExerciseIndex < widget.treino.exercicios.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _currentSerie = 1;
      });
      _initializeExercicio();
    } else {
      // 🔥 ÚLTIMO EXERCÍCIO - FINALIZAR TREINO
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