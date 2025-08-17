import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../models/treino_model.dart';

/// 🏃‍♂️ Tela de Execução de Treino com Timer Visual
class TreinoExecucaoScreen extends StatefulWidget {
  final TreinoModel treino;

  const TreinoExecucaoScreen({
    super.key,
    required this.treino,
  });

  @override
  State<TreinoExecucaoScreen> createState() => _TreinoExecucaoScreenState();
}

class _TreinoExecucaoScreenState extends State<TreinoExecucaoScreen>
    with TickerProviderStateMixin {
  
  // ===== CONTROLE DE EXERCÍCIOS =====
  int _exercicioAtualIndex = 0;
  int _serieAtual = 1;
  
  // ===== CONTROLE DE TIMER =====
  Timer? _timer;
  int _tempoAtual = 0; // segundos
  int _tempoTotal = 0; // segundos
  bool _isTimerAtivo = false;
  bool _isPausado = false;
  
  // ===== ESTADOS DO TREINO =====
  EstadoExecucao _estadoAtual = EstadoExecucao.preparacao;
  
  // ===== ANIMAÇÕES =====
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;
  
  // ===== DADOS MODIFICÁVEIS =====
  late List<ExercicioExecucao> _exerciciosExecucao;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeExercicios();
    _iniciarPreparacao();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
  }

  void _initializeExercicios() {
    _exerciciosExecucao = widget.treino.exercicios.map((exercicio) {
      return ExercicioExecucao.fromModel(exercicio);
    }).toList();
  }

  void _iniciarPreparacao() {
    setState(() {
      _estadoAtual = EstadoExecucao.preparacao;
      _tempoTotal = 10; // 10 segundos de preparação
      _tempoAtual = _tempoTotal;
    });
    _iniciarTimer();
  }

  void _iniciarExercicio() {
    final exercicio = _exerciciosExecucao[_exercicioAtualIndex];
    
    setState(() {
      _estadoAtual = EstadoExecucao.execucao;
      
      if (exercicio.tipoExecucao == 'tempo') {
        // Exercício por tempo (ex: prancha)
        _tempoTotal = exercicio.tempoExecucao ?? 30;
        _tempoAtual = _tempoTotal;
      } else {
        // Exercício por repetição - sem timer automático
        _tempoTotal = 0;
        _tempoAtual = 0;
      }
    });
    
    if (_tempoTotal > 0) {
      _iniciarTimer();
    }
  }

  void _iniciarDescanso() {
    final exercicio = _exerciciosExecucao[_exercicioAtualIndex];
    
    setState(() {
      _estadoAtual = EstadoExecucao.descanso;
      _tempoTotal = exercicio.tempoDescanso ?? 60;
      _tempoAtual = _tempoTotal;
    });
    
    _iniciarTimer();
  }

  void _iniciarTimer() {
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_tempoAtual > 0) {
          _tempoAtual--;
          _progressController.animateTo(
            1.0 - (_tempoAtual / _tempoTotal),
          );
        } else {
          // Timer terminou
          _onTimerCompleto();
        }
      });
    });
    
    setState(() {
      _isTimerAtivo = true;
      _isPausado = false;
    });
  }

  void _onTimerCompleto() {
    _timer?.cancel();
    setState(() {
      _isTimerAtivo = false;
    });
    
    HapticFeedback.mediumImpact();
    
    switch (_estadoAtual) {
      case EstadoExecucao.preparacao:
        _iniciarExercicio();
        break;
      case EstadoExecucao.execucao:
        _proximaSerieOuDescanso();
        break;
      case EstadoExecucao.descanso:
        _iniciarExercicio();
        break;
    }
  }

  void _proximaSerieOuDescanso() {
    final exercicio = _exerciciosExecucao[_exercicioAtualIndex];
    
    if (_serieAtual < exercicio.series) {
      // Mais séries restantes - ir para descanso
      setState(() {
        _serieAtual++;
      });
      _iniciarDescanso();
    } else {
      // Séries completas - próximo exercício
      _proximoExercicio();
    }
  }

  void _proximoExercicio() {
    if (_exercicioAtualIndex < _exerciciosExecucao.length - 1) {
      setState(() {
        _exercicioAtualIndex++;
        _serieAtual = 1;
      });
      _iniciarDescanso(); // Descanso entre exercícios
    } else {
      // Treino completo!
      _finalizarTreino();
    }
  }

  void _finalizarTreino() {
    setState(() {
      _estadoAtual = EstadoExecucao.concluido;
    });
    
    // Mostrar tela de conclusão
    _mostrarDialogoConclusao();
  }

  void _pausarResumir() {
    if (_isTimerAtivo && !_isPausado) {
      // Pausar
      _timer?.cancel();
      setState(() {
        _isPausado = true;
      });
    } else if (_isPausado) {
      // Resumir
      _iniciarTimer();
    }
    
    HapticFeedback.lightImpact();
  }

  void _pularTimer() {
    _timer?.cancel();
    setState(() {
      _tempoAtual = 0;
      _isTimerAtivo = false;
    });
    _onTimerCompleto();
  }

  void _adicionarTempo(int segundos) {
    setState(() {
      _tempoAtual += segundos;
      _tempoTotal += segundos;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            // Header com progresso
            _buildHeader(),
            
            // Conteúdo principal
            Expanded(
              child: _buildMainContent(),
            ),
            
            // Controles inferiores
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (_estadoAtual) {
      case EstadoExecucao.preparacao:
        return const Color(0xFF3B82F6);
      case EstadoExecucao.execucao:
        return const Color(0xFF10B981);
      case EstadoExecucao.descanso:
        return const Color(0xFFF59E0B);
      case EstadoExecucao.concluido:
        return const Color(0xFF8B5CF6);
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progresso do treino
          Row(
            children: [
              IconButton(
                onPressed: () => _mostrarDialogoSair(),
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${_exercicioAtualIndex + 1} de ${_exerciciosExecucao.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_exercicioAtualIndex + 1) / _exerciciosExecucao.length,
                      backgroundColor: Colors.white30,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 48), // Espaço para manter centralizado
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Título do estado atual
          Text(
            _getTituloEstado(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _getTituloEstado() {
    switch (_estadoAtual) {
      case EstadoExecucao.preparacao:
        return 'Prepare-se';
      case EstadoExecucao.execucao:
        return _exerciciosExecucao[_exercicioAtualIndex].nomeExercicio;
      case EstadoExecucao.descanso:
        return 'Descanso';
      case EstadoExecucao.concluido:
        return 'Treino Concluído!';
    }
  }

  Widget _buildMainContent() {
    if (_estadoAtual == EstadoExecucao.concluido) {
      return _buildConclusaoContent();
    }
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Timer visual
          if (_tempoTotal > 0) _buildTimerVisual(),
          
          const SizedBox(height: 40),
          
          // Informações do exercício
          if (_estadoAtual != EstadoExecucao.preparacao) _buildExercicioInfo(),
          
          // Timer em texto
          _buildTimerTexto(),
          
          const SizedBox(height: 20),
          
          // Controles de tempo
          if (_isTimerAtivo) _buildTimerControls(),
        ],
      ),
    );
  }

  Widget _buildTimerVisual() {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de fundo
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white30,
            ),
          ),
          
          // Progresso circular
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
          ),
          
          // Tempo no centro
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isPausado ? 1.0 : _pulseAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatarTempo(_tempoAtual),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (_isPausado)
                      const Text(
                        'PAUSADO',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExercicioInfo() {
    final exercicio = _exerciciosExecucao[_exercicioAtualIndex];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white20,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            exercicio.nomeExercicio,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildInfoItem('Série', '$_serieAtual/${exercicio.series}'),
              if (exercicio.tipoExecucao == 'repeticao')
                _buildInfoItem('Reps', '${exercicio.repeticoes}'),
              if (exercicio.tipoExecucao == 'tempo')
                _buildInfoItem('Tempo', _formatarTempo(exercicio.tempoExecucao ?? 0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String valor) {
    return Column(
      children: [
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerTexto() {
    if (_tempoTotal == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Text(
          _estadoAtual == EstadoExecucao.execucao 
              ? 'Faça ${_exerciciosExecucao[_exercicioAtualIndex].repeticoes} repetições'
              : '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildTimerControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Remover tempo
        IconButton(
          onPressed: () => _adicionarTempo(-10),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.remove_rounded,
              color: Colors.white,
            ),
          ),
        ),
        
        // Adicionar tempo
        IconButton(
          onPressed: () => _adicionarTempo(10),
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Pausar/Resumir
          if (_isTimerAtivo || _isPausado)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pausarResumir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _getBackgroundColor(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(_isPausado ? Icons.play_arrow_rounded : Icons.pause_rounded),
                label: Text(_isPausado ? 'Continuar' : 'Pausar'),
              ),
            ),
          
          if (_isTimerAtivo || _isPausado) const SizedBox(width: 12),
          
          // Pular
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _pularTimer,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white30,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(_getTextoPular()),
            ),
          ),
        ],
      ),
    );
  }

  String _getTextoPular() {
    switch (_estadoAtual) {
      case EstadoExecucao.preparacao:
        return 'Pular Preparação';
      case EstadoExecucao.execucao:
        return 'Finalizar Série';
      case EstadoExecucao.descanso:
        return 'Pular Descanso';
      case EstadoExecucao.concluido:
        return '';
    }
  }

  Widget _buildConclusaoContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Parabéns!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Treino "${widget.treino.nomeTreino}" concluído!',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white30,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Voltar'),
              ),
              
              ElevatedButton(
                onPressed: () {
                  // Salvar progresso e voltar
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
                child: const Text('Finalizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoSair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair do Treino'),
        content: const Text('Tem certeza que deseja sair? O progresso será perdido.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fechar dialog
              Navigator.pop(context); // Sair da tela
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConclusao() {
    // Implementar salvamento de progresso aqui
  }

  String _formatarTempo(int segundos) {
    final minutos = segundos ~/ 60;
    final segs = segundos % 60;
    return '${minutos.toString().padLeft(2, '0')}:${segs.toString().padLeft(2, '0')}';
  }
}

// ===== ENUMS E CLASSES AUXILIARES =====

enum EstadoExecucao {
  preparacao,
  execucao,
  descanso,
  concluido,
}

class ExercicioExecucao {
  final int? id;
  final String nomeExercicio;
  final String tipoExecucao;
  final int repeticoes;
  final int series;
  final int? tempoExecucao;
  final int? tempoDescanso;

  ExercicioExecucao({
    this.id,
    required this.nomeExercicio,
    required this.tipoExecucao,
    required this.repeticoes,
    required this.series,
    this.tempoExecucao,
    this.tempoDescanso,
  });

  factory ExercicioExecucao.fromModel(ExercicioModel model) {
    return ExercicioExecucao(
      id: model.id,
      nomeExercicio: model.nomeExercicio,
      tipoExecucao: model.tipoExecucao,
      repeticoes: model.repeticoes ?? 10,
      series: model.series ?? 3,
      tempoExecucao: model.tempoExecucao,
      tempoDescanso: model.tempoDescanso ?? 60,
    );
  }
}