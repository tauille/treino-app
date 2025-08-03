import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/routes/app_routes.dart';

/// Tela de detalhes do treino com lista de exercícios
class DetalhesTreinoScreen extends StatefulWidget {
  final TreinoModel treino;

  const DetalhesTreinoScreen({
    super.key,
    required this.treino,
  });

  @override
  State<DetalhesTreinoScreen> createState() => _DetalhesTreinoScreenState();
}

class _DetalhesTreinoScreenState extends State<DetalhesTreinoScreen>
    with TickerProviderStateMixin {
  
  // ===== CONTROLLERS =====
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // ===== ESTADO =====
  bool _isLoading = true;
  TreinoModel? _treinoDetalhado;

  @override
  void initState() {
    super.initState();
    
    // Configurar status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    
    _setupAnimations();
    _carregarDetalhes();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  /// Configurar animações
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
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  /// Carregar detalhes completos do treino
  Future<void> _carregarDetalhes() async {
    final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
    
    setState(() => _isLoading = true);
    
    // ===== CORREÇÃO: USAR ApiResponse CORRETAMENTE =====
    final resultado = await treinoProvider.buscarTreino(widget.treino.id!);
    
    if (resultado.success && resultado.data != null) {
      setState(() {
        _treinoDetalhado = resultado.data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado.message ?? 'Erro ao carregar detalhes'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ MÉTODO ÚNICO PARA INICIAR TREINO (DIRETO PARA EXECUÇÃO)
  
  /// Iniciar treino direto para execução (sem preparação)
  void _iniciarTreino() {
    final treino = _treinoDetalhado ?? widget.treino;
    
    if (treino.exercicios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Expanded(child: Text('Este treino não possui exercícios')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Mostrar feedback de início
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.play_arrow, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Iniciando treino "${treino.nomeTreino}"...')),
          ],
        ),
        backgroundColor: const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // ✅ NAVEGAR DIRETO PARA EXECUÇÃO (SEM PREPARAÇÃO)
    Navigator.pushNamed(
      context,
      AppRoutes.treinoExecucao,
      arguments: treino,
    );
  }
  
  /// Verificar se treino pode ser iniciado
  bool get _podeIniciarTreino {
    final treino = _treinoDetalhado ?? widget.treino;
    return treino.exercicios.isNotEmpty;
  }

  /// Widget do header do treino
  Widget _buildHeader() {
    final treino = _treinoDetalhado ?? widget.treino;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            // ===== CORREÇÃO: USAR corDificuldadeColor =====
            treino.corDificuldadeColor,
            // ===== CORREÇÃO: USAR corDificuldadeColor.withOpacity =====
            treino.corDificuldadeColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ===== CORREÇÃO: USAR corDificuldadeColor.withOpacity =====
            color: treino.corDificuldadeColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título e dificuldade
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      treino.nomeTreino,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      treino.tipoTreino,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  // ===== CORREÇÃO: USAR dificuldadeTextoSeguro =====
                  treino.dificuldadeTextoSeguro,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          
          // Descrição (se houver)
          if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              treino.descricao!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Estatísticas
          Row(
            children: [
              _buildHeaderStat(
                Icons.fitness_center,
                '${treino.totalExerciciosCalculado}',
                'Exercícios',
              ),
              const SizedBox(width: 32),
              _buildHeaderStat(
                Icons.timer,
                // ===== CORREÇÃO: USAR duracaoFormatadaSegura =====
                treino.duracaoFormatadaSegura,
                'Duração',
              ),
              const SizedBox(width: 32),
              _buildHeaderStat(
                Icons.trending_up,
                // ===== CORREÇÃO: USAR gruposMuscularesSeguro =====
                treino.gruposMuscularesSeguro,
                'Músculos',
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget de estatística do header
  Widget _buildHeaderStat(IconData icon, String valor, String label) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Widget do card do exercício
  Widget _buildExercicioCard(ExercicioModel exercicio, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do exercício
              Row(
                children: [
                  // Número do exercício
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Nome e grupo muscular
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercicio.nomeExercicio,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                        if (exercicio.grupoMuscular != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            exercicio.grupoMuscular!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Tipo de execução
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF667eea).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      exercicio.tipoExecucao == 'repeticao' 
                          ? 'Repetições'
                          : 'Tempo',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667eea),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Descrição (se houver)
              if (exercicio.descricao != null && exercicio.descricao!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  exercicio.descricao!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Informações de execução
              Row(
                children: [
                  if (exercicio.series != null) ...[
                    _buildExercicioInfo(
                      Icons.repeat,
                      '${exercicio.series}',
                      'Séries',
                    ),
                    const SizedBox(width: 24),
                  ],
                  
                  if (exercicio.tipoExecucao == 'repeticao' && exercicio.repeticoes != null) ...[
                    _buildExercicioInfo(
                      Icons.format_list_numbered,
                      '${exercicio.repeticoes}',
                      'Reps',
                    ),
                    const SizedBox(width: 24),
                  ],
                  
                  if (exercicio.tipoExecucao == 'tempo' && exercicio.tempoExecucao != null) ...[
                    _buildExercicioInfo(
                      Icons.timer,
                      '${exercicio.tempoExecucao}s',
                      'Execução',
                    ),
                    const SizedBox(width: 24),
                  ],
                  
                  if (exercicio.tempoDescanso != null) ...[
                    _buildExercicioInfo(
                      Icons.pause,
                      '${exercicio.tempoDescanso}s',
                      'Descanso',
                    ),
                    const SizedBox(width: 24),
                  ],
                  
                  if (exercicio.peso != null) ...[
                    _buildExercicioInfo(
                      Icons.fitness_center,
                      '${exercicio.peso}${exercicio.unidadePeso ?? 'kg'}',
                      'Peso',
                    ),
                  ],
                ],
              ),
              
              // Observações (se houver)
              if (exercicio.observacoes != null && exercicio.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.amber[700],
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          exercicio.observacoes!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.amber[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Widget de informação do exercício
  Widget _buildExercicioInfo(IconData icon, String valor, String label) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF667eea),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget de estado vazio
  Widget _buildEmptyExercicios() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.fitness_center,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Nenhum exercício',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Este treino ainda não possui exercícios',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ BOTTOM ACTION BAR SIMPLIFICADO (SÓ UM BOTÃO)
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status do treino (se não puder iniciar)
            if (!_podeIniciarTreino)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adicione exercícios para iniciar este treino',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // ✅ BOTÃO ÚNICO - INICIAR TREINO DIRETO
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _podeIniciarTreino ? _iniciarTreino : null,
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
                    Icon(
                      _podeIniciarTreino ? Icons.play_arrow : Icons.block,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _podeIniciarTreino ? 'Iniciar Treino' : 'Sem Exercícios',
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final treino = _treinoDetalhado ?? widget.treino;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF2D3748),
          ),
        ),
        title: Text(
          'Detalhes do Treino',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implementar edição do treino
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edição será implementada em breve'),
                  backgroundColor: Color(0xFF667eea),
                ),
              );
            },
            icon: const Icon(
              Icons.edit,
              color: Color(0xFF667eea),
            ),
            tooltip: 'Editar Treino',
          ),
        ],
      ),
      
      // ✅ BOTTOM NAVIGATION BAR SIMPLIFICADO
      bottomNavigationBar: _buildBottomActionBar(),
      
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: Color(0xFF667eea),
                size: 50.0,
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Header do treino
                      _buildHeader(),
                      
                      // Título da seção de exercícios
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Text(
                              'Exercícios',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2D3748),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF667eea),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${treino.exercicios.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Lista de exercícios
                      if (treino.exercicios.isEmpty)
                        SizedBox(
                          height: 300,
                          child: _buildEmptyExercicios(),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: treino.exercicios.length,
                          itemBuilder: (context, index) {
                            return _buildExercicioCard(
                              treino.exercicios[index],
                              index,
                            );
                          },
                        ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}