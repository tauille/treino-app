import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/execucao_treino_provider.dart';
import '../models/execucao_treino.dart';
import '../models/execucao_exercicio.dart';
import '../widgets/timer_widget.dart';
import '../widgets/exercicio_card.dart';
import '../widgets/progresso_widget.dart';
import '../widgets/controles_execucao.dart';
import '../widgets/descanso_overlay.dart';

class ExecucaoTreinoScreen extends StatefulWidget {
  final int? treinoId;

  const ExecucaoTreinoScreen({
    Key? key,
    this.treinoId,
  }) : super(key: key);

  @override
  State<ExecucaoTreinoScreen> createState() => _ExecucaoTreinoScreenState();
}

class _ExecucaoTreinoScreenState extends State<ExecucaoTreinoScreen>
    with WidgetsBindingObserver {
  late ExecucaoTreinoProvider _provider;
  bool _dialogAberto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _provider = context.read<ExecucaoTreinoProvider>();
    _inicializar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pausar timer quando app for para background
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // App foi para background
        break;
      case AppLifecycleState.resumed:
        // App voltou do background - sincronizar com servidor
        _sincronizarExecucao();
        break;
      default:
        break;
    }
  }

  void _inicializar() async {
    if (widget.treinoId != null) {
      // Iniciar novo treino
      final sucesso = await _provider.iniciarTreino(widget.treinoId!);
      if (!sucesso && mounted) {
        _mostrarErro(_provider.errorMessage ?? 'Erro ao iniciar treino');
      }
    } else {
      // Buscar execução em andamento
      await _provider.buscarExecucaoAtual();
    }
  }

  void _sincronizarExecucao() async {
    await _provider.buscarExecucaoAtual();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExecucaoTreinoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && !provider.hasExecucao) {
          return _buildLoadingScreen();
        }

        if (!provider.hasExecucao) {
          return _buildNoExecucaoScreen();
        }

        return Scaffold(
          backgroundColor: Colors.grey[900],
          body: Stack(
            children: [
              _buildMainContent(provider),
              if (provider.emDescanso) DescansoOverlay(),
              if (provider.isLoading) _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando treino...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoExecucaoScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: Colors.grey[600],
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum treino em andamento',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Selecione um treino para começar',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(ExecucaoTreinoProvider provider) {
    final execucao = provider.execucaoAtual!;
    
    return SafeArea(
      child: Column(
        children: [
          _buildAppBar(execucao),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Timer principal
                  TimerWidget(
                    tempoFormatado: provider.tempoTotalFormatado,
                    label: 'Tempo Total',
                    isMain: true,
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Progresso do treino
                  ProgressoWidget(
                    progresso: execucao.progresso,
                    treino: execucao.treino,
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Exercício atual
                  if (execucao.exercicioAtual != null)
                    ExercicioCard(
                      exercicio: execucao.exercicioAtual!,
                      execucaoExercicio: provider.exercicioAtualExecucao,
                      tempoExercicio: provider.tempoExercicioFormatado,
                      onAtualizarProgresso: _atualizarProgresso,
                    ),
                  
                  SizedBox(height: 24),
                  
                  // Controles de execução
                  ControlesExecucao(
                    execucao: execucao,
                    onPausar: _pausarTreino,
                    onRetomar: _retomarTreino,
                    onProximo: _proximoExercicio,
                    onAnterior: _exercicioAnterior,
                    onFinalizar: _finalizarTreino,
                    onCancelar: _cancelarTreino,
                    onIniciarDescanso: _iniciarDescanso,
                  ),
                  
                  SizedBox(height: 32),
                  
                  // Lista de exercícios (resumo)
                  _buildListaExercicios(execucao.exercicios),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(ExecucaoTreino execucao) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _mostrarDialogSair,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  execucao.treino.nome,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  execucao.statusText,
                  style: TextStyle(
                    color: _getStatusColor(execucao.status),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: _mostrarMenu,
          ),
        ],
      ),
    );
  }

  Widget _buildListaExercicios(List<ExecucaoExercicio> exercicios) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercícios do Treino',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...exercicios.asMap().entries.map((entry) {
              final index = entry.key;
              final exercicio = entry.value;
              final isAtual = exercicio.exercicioId == _provider.exercicioAtual?.id;
              
              return Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isAtual ? Colors.blue.withOpacity(0.2) : Colors.grey[800],
                  borderRadius: BorderRadius.circular(8),
                  border: isAtual ? Border.all(color: Colors.blue) : null,
                ),
                child: Row(
                  children: [
                    // Indicador de status
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getExercicioStatusColor(exercicio.status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12),
                    
                    // Número do exercício
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isAtual ? Colors.blue : Colors.grey[600],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(width: 12),
                    
                    // Nome e detalhes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercicio.nome,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: isAtual ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            exercicio.resumoExecucao,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Status
                    Text(
                      exercicio.statusTexto,
                      style: TextStyle(
                        color: _getExercicioStatusColor(exercicio.status),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'iniciado':
        return Colors.green;
      case 'pausado':
        return Colors.orange;
      case 'finalizado':
        return Colors.blue;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getExercicioStatusColor(String status) {
    switch (status) {
      case 'nao_iniciado':
        return Colors.grey;
      case 'em_andamento':
        return Colors.blue;
      case 'completado':
        return Colors.green;
      case 'pulado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // Ações
  void _pausarTreino() async {
    final sucesso = await _provider.pausarTreino();
    if (!sucesso && mounted) {
      _mostrarErro(_provider.errorMessage ?? 'Erro ao pausar');
    }
  }

  void _retomarTreino() async {
    final sucesso = await _provider.retomarTreino();
    if (!sucesso && mounted) {
      _mostrarErro(_provider.errorMessage ?? 'Erro ao retomar');
    }
  }

  void _proximoExercicio() async {
    final sucesso = await _provider.proximoExercicio();
    if (!sucesso && mounted) {
      _mostrarErro(_provider.errorMessage ?? 'Erro ao avançar');
    }
  }

  void _exercicioAnterior() async {
    final sucesso = await _provider.exercicioAnterior();
    if (!sucesso && mounted) {
      _mostrarErro(_provider.errorMessage ?? 'Erro ao voltar');
    }
  }

  void _atualizarProgresso({
    int? series,
    int? repeticoes,
    double? peso,
    String? observacoes,
  }) async {
    final sucesso = await _provider.atualizarExercicio(
      seriesRealizadas: series,
      repeticoesRealizadas: repeticoes,
      pesoUtilizado: peso,
      observacoes: observacoes,
    );
    
    if (!sucesso && mounted) {
      _mostrarErro(_provider.errorMessage ?? 'Erro ao atualizar');
    }
  }

  void _iniciarDescanso() {
    _provider.iniciarDescanso();
  }

  void _finalizarTreino() async {
    if (_dialogAberto) return;
    
    final resultado = await showDialog<String>(
      context: context,
      builder: (context) => _DialogFinalizarTreino(),
    );
    
    if (resultado != null) {
      final sucesso = await _provider.finalizarTreino(observacoes: resultado);
      if (sucesso && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        _mostrarErro(_provider.errorMessage ?? 'Erro ao finalizar');
      }
    }
  }

  void _cancelarTreino() async {
    if (_dialogAberto) return;
    
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Cancelar Treino', style: TextStyle(color: Colors.white)),
        content: Text(
          'Tem certeza que deseja cancelar este treino? Todo o progresso será perdido.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Não', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sim, cancelar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmar == true) {
      final sucesso = await _provider.cancelarTreino();
      if (sucesso && mounted) {
        Navigator.of(context).pop();
      } else if (mounted) {
        _mostrarErro(_provider.errorMessage ?? 'Erro ao cancelar');
      }
    }
  }

  void _mostrarDialogSair() async {
    if (_dialogAberto) return;
    _dialogAberto = true;
    
    final sair = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[850],
        title: Text('Sair do Treino', style: TextStyle(color: Colors.white)),
        content: Text(
          'O treino continuará rodando em segundo plano. Você pode voltar a qualquer momento.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Sair'),
          ),
        ],
      ),
    );
    
    _dialogAberto = false;
    
    if (sair == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  void _mostrarMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850],
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text('Detalhes do Treino', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Implementar tela de detalhes
            },
          ),
          ListTile(
            leading: Icon(Icons.history, color: Colors.green),
            title: Text('Histórico', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Implementar tela de histórico
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: Colors.grey),
            title: Text('Configurações', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              // Implementar configurações
            },
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

class _DialogFinalizarTreino extends StatefulWidget {
  @override
  State<_DialogFinalizarTreino> createState() => _DialogFinalizarTreinoState();
}

class _DialogFinalizarTreinoState extends State<_DialogFinalizarTreino> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[850],
      title: Text('Finalizar Treino', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Parabéns! Você completou o treino. Adicione suas observações:',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Como foi o treino? (opcional)',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: Text('Finalizar'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}