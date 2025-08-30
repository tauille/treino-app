import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:io';
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
  
  ExercicioModel? _exercicioAtual;
  
  Timer? _timerAtivo;
  int _tempoAtual = 0;
  int _tempoTotalSegundos = 0;
  bool _timerRodando = false;
  
  TimerState _timerState = TimerState.waiting;
  
  late AudioPlayer _audioPlayer;
  
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  ExecucaoTreinoProvider? _execucaoProvider;
  DateTime? _inicioTreino;
  Timer? _timerTotal;
  int _totalExerciciosCompletados = 0;
  int _totalSeriesCompletadas = 0;
  List<Map<String, dynamic>> _exerciciosRealizados = [];

  final Map<String, String> _exercicioImagens = {};
  bool _imagensCarregadas = false;
  
  // Sistema otimizado para refresh de imagens (inclusive GIFs)
  Timer? _imageRefreshTimer;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    
    _audioPlayer = AudioPlayer();
    _setupAnimations();
    _enableWakelock();
    
    _execucaoProvider = Provider.of<ExecucaoTreinoProvider>(context, listen: false);
    _inicioTreino = DateTime.now();
    
    _initializeScreen();
    
    if (widget.treino.exercicios.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showNoExercisesDialog();
      });
    }
  }

  Future<void> _initializeScreen() async {
    print('=== INICIALIZANDO TELA DE EXECUÇÃO ===');
    
    await _carregarImagensExecucao();
    _iniciarTimerTotal();
    _initializeExercicio();
    
    print('=== INICIALIZAÇÃO CONCLUÍDA ===');
  }

  Future<void> _carregarImagensExecucao() async {
    print('=== CARREGANDO IMAGENS PARA EXECUÇÃO ===');
    print('Total de exercícios: ${widget.treino.exercicios.length}');
    
    final List<Future<void>> carregamentos = [];
    
    for (final exercicio in widget.treino.exercicios) {
      carregamentos.add(_carregarImagemExercicio(exercicio));
    }
    
    await Future.wait(carregamentos);
    
    print('Carregamento concluído: ${_exercicioImagens.length} imagens disponíveis');
    
    if (mounted) {
      setState(() {
        _imagensCarregadas = true;
      });
    }
  }

  Future<void> _carregarImagemExercicio(ExercicioModel exercicio) async {
    final nome = exercicio.nomeExercicio;
    print('Carregando imagem para: $nome');
    
    String? imagemPath;
    
    try {
      // Método 1: Verificar imagemPath do modelo
      if (exercicio.imagemPath != null && exercicio.imagemPath!.isNotEmpty) {
        final file = File(exercicio.imagemPath!);
        if (await file.exists()) {
          imagemPath = exercicio.imagemPath!;
          print('   Encontrada no modelo');
        }
      }
      
      // Método 2: Verificar backup local
      if (imagemPath == null) {
        final prefs = await SharedPreferences.getInstance();
        final backup = prefs.getString('backup_img_$nome');
        
        if (backup != null && backup.isNotEmpty) {
          final file = File(backup);
          if (await file.exists()) {
            imagemPath = backup;
            print('   Encontrada no backup local');
          }
        }
      }
      
      // Método 3: Procurar no diretório
      if (imagemPath == null) {
        final appDir = await getApplicationDocumentsDirectory();
        final exerciciosDir = Directory('${appDir.path}/exercicios');
        
        if (await exerciciosDir.exists()) {
          final files = exerciciosDir.listSync();
          final nomeNormalizado = nome.replaceAll(' ', '_').toLowerCase();
          
          for (final file in files) {
            if (file is File && file.path.toLowerCase().contains(nomeNormalizado)) {
              final extension = file.path.toLowerCase();
              if (extension.endsWith('.jpg') || 
                  extension.endsWith('.jpeg') || 
                  extension.endsWith('.png') || 
                  extension.endsWith('.gif')) {
                imagemPath = file.path;
                print('   Encontrada no diretório: ${file.path}');
                break;
              }
            }
          }
        }
      }
      
      if (imagemPath != null) {
        final file = File(imagemPath);
        final exists = await file.exists();
        final size = exists ? await file.length() : 0;
        
        if (exists && size > 0) {
          _exercicioImagens[nome] = imagemPath;
          print('   Imagem válida registrada ($size bytes)');
        }
      }
      
    } catch (e) {
      print('   ERRO ao carregar imagem para $nome: $e');
    }
  }

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
      _iniciarRefreshDeImagem();
    }
  }

  // Sistema otimizado para refresh de imagens
  void _iniciarRefreshDeImagem() {
    _imageRefreshTimer?.cancel();
    
    if (_exercicioTemImagem()) {
      final imagemPath = _exercicioImagens[_exercicioAtual!.nomeExercicio]!;
      final isGif = imagemPath.toLowerCase().endsWith('.gif');
      
      if (isGif) {
        print('Iniciando refresh para GIF: ${_exercicioAtual!.nomeExercicio}');
        
        // Força refresh a cada 4 segundos para tentar animar GIF
        _imageRefreshTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
          if (mounted) {
            setState(() {
              _refreshKey++; // Força rebuild da imagem
            });
            print('GIF refresh #$_refreshKey');
          }
        });
      }
    }
  }

  void _pararRefreshDeImagem() {
    _imageRefreshTimer?.cancel();
    _imageRefreshTimer = null;
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
    _pararRefreshDeImagem();
    _audioPlayer.dispose();
    _disableWakelock();
    super.dispose();
  }

  bool _exercicioTemImagem() {
    if (_exercicioAtual == null || !_imagensCarregadas) {
      return false;
    }
    
    final imagemPath = _exercicioImagens[_exercicioAtual!.nomeExercicio];
    return imagemPath != null && imagemPath.isNotEmpty;
  }

  // Widget otimizado para imagens (inclui GIFs com refresh)
  Widget _buildExercicioImagem(bool isSmall, bool isMedium) {
    if (!_imagensCarregadas) {
      final placeholderHeight = isSmall ? 140.0 : isMedium ? 175.0 : 210.0;
      
      return Container(
        margin: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
        height: placeholderHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Carregando imagem...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (!_exercicioTemImagem()) {
      return const SizedBox.shrink();
    }
    
    final imagemPath = _exercicioImagens[_exercicioAtual!.nomeExercicio]!;
    final height = isSmall ? 140.0 : isMedium ? 175.0 : 210.0;
    final isGif = imagemPath.toLowerCase().endsWith('.gif');
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: isSmall ? 12 : 16),
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.file(
          File(imagemPath),
          key: ValueKey('img_${_exercicioAtual!.nomeExercicio}_$_refreshKey'), // Força refresh
          width: double.infinity,
          height: height,
          fit: BoxFit.cover,
          gaplessPlayback: isGif ? false : true, // Para GIFs, false ajuda com frames
          filterQuality: FilterQuality.medium,
          errorBuilder: (context, error, stackTrace) {
            print('Erro ao carregar imagem $imagemPath: $error');
            return _buildImagePlaceholder(height, isGif);
          },
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(double height, bool isGif) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6BA6CD), Color(0xFF5B9BD5)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: height * 0.3,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            isGif ? 'GIF Indisponível' : 'Imagem Indisponível',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Siga as instruções do exercício',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
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
          _buildExercicioImagem(isSmall, isMedium), // Imagem com refresh
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
          
          // Indicador de mídia disponível
          const SizedBox(height: 8),
          if (_imagensCarregadas && _exercicioTemImagem())
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _exercicioImagens[_exercicioAtual!.nomeExercicio]?.toLowerCase().endsWith('.gif') == true
                        ? Icons.play_circle_outline
                        : Icons.image,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    _exercicioImagens[_exercicioAtual!.nomeExercicio]?.toLowerCase().endsWith('.gif') == true
                        ? 'GIF DISPONÍVEL'
                        : 'IMAGEM DISPONÍVEL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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

  // Métodos auxiliares - timer, cores, textos, etc.
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
            return 'FINALIZAR TREINO';
          } else {
            return 'PRÓXIMO EXERCÍCIO';
          }
      }
    } else {
      if (_currentSerie <= (_exercicioAtual?.series ?? 1)) {
        return 'COMPLETAR SÉRIE $_currentSerie';
      } else {
        if (_currentExerciseIndex >= widget.treino.exercicios.length - 1) {
          return 'FINALIZAR TREINO';
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
    _showSnackBar('Série $_currentSerie iniciada!', _getTimerColor());
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
      
      _showSnackBar('Exercício concluído!', const Color(0xFF4CAF50));
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

    _showSnackBar('Descanso iniciado', const Color(0xFFD69E2E));
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

    _showSnackBar('Descanso iniciado! Próxima série: $_currentSerie', const Color(0xFFD69E2E));
  }

  void _finalizarDescansoRepeticao() {
    _timerAtivo?.cancel();
    _pulseController.stop();
    
    setState(() {
      _timerState = TimerState.waiting;
      _timerRodando = false;
    });

    HapticFeedback.mediumImpact();
    _showSnackBar('Descanso terminado! Vamos para série $_currentSerie!', const Color(0xFF4CAF50));
  }

  void _finalizarExercicio() {
    _salvarDadosExercicio();
    
    _showSnackBar('Exercício completado!', const Color(0xFF48BB78));
    
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
    _pararRefreshDeImagem();
    _pulseController.stop();
    
    final dadosExecucao = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'treino_id': widget.treino.id,
      'nome_treino': widget.treino.nomeTreino,
      'data_inicio': _inicioTreino?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'data_fim': DateTime.now().toIso8601String(),
      'duracao_total_segundos': _tempoTotalSegundos,
      'total_exercicios_completados': _totalExerciciosCompletados,
      'exercicios_detalhados': _exerciciosRealizados,
    };
    
    try {
      if (_execucaoProvider != null) {
        await _execucaoProvider!.finalizarTreino(observacoes: 'Treino completado');
      }
      
      // Salvamento local
      final prefs = await SharedPreferences.getInstance();
      final execucoesString = prefs.getString('execucoes_treino') ?? '[]';
      final execucoes = jsonDecode(execucoesString) as List;
      execucoes.add(dadosExecucao);
      await prefs.setString('execucoes_treino', jsonEncode(execucoes));
      
      _showSnackBar('Treino salvo com sucesso!', const Color(0xFF4CAF50));
    } catch (e) {
      _showSnackBar('Treino finalizado!', const Color(0xFFF59E0B));
    }
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
    }
  }

  void _nextExercise() {
    HapticFeedback.lightImpact();
    _pararRefreshDeImagem();
    
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
    _pararRefreshDeImagem();
    
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
        _currentSerie = 1;
      });
      _initializeExercicio();
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
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
        title: const Text('Finalizar Treino?'),
        content: const Text('Tem certeza que deseja finalizar o treino agora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finishTreinoComDados();
            },
            child: const Text('Finalizar'),
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
        title: const Text('Treino Vazio'),
        content: const Text('Este treino não possui exercícios.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Voltar'),
          ),
        ],
      ),
    );
  }

  Future<void> _enableWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (e) {
      print('Erro wakelock: $e');
    }
  }

  Future<void> _disableWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (e) {
      print('Erro ao desativar wakelock: $e');
    }
  }

  Future<void> _playCountdownSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/countdown.mp3'));
    } catch (e) {
      HapticFeedback.heavyImpact();
    }
  }
}

enum TimerState {
  waiting,
  executing,
  resting,
  finished,
}