import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/treino_service.dart';
import 'criar_treino_screen.dart';

/// 🔧 Extensões para métodos seguros - CORRIGIDO
extension TreinoModelSafeExtensions on TreinoModel {
  String get dificuldadeTextoSeguro {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return 'Iniciante';
      case 'intermediario':
        return 'Intermediário';
      case 'avancado':
        return 'Avançado';
      default:
        return 'Iniciante';
    }
  }
  
  String get duracaoFormatadaSegura {
    final duracao = duracaoEstimada ?? 0;
    if (duracao == 0) return 'Sem duração';
    return duracao > 60 
        ? '${(duracao / 60).floor()}h ${duracao % 60}min'
        : '${duracao}min';
  }

  int get totalExerciciosCalculado {
    if (exercicios.isNotEmpty) return exercicios.length;
    return totalExercicios ?? 0;
  }

  String get gruposMuscularesSeguro {
    if (exercicios.isEmpty) return 'Nenhum grupo';
    final grupos = exercicios
        .where((e) => e.grupoMuscular != null)
        .map((e) => e.grupoMuscular!)
        .toSet()
        .take(3)
        .join(', ');
    return grupos.isEmpty ? 'Variados' : grupos;
  }

  Color get corDificuldadeColor {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return const Color(0xFF10B981);
      case 'intermediario':
        return const Color(0xFF3B82F6);
      case 'avancado':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF10B981);
    }
  }
}

/// Tela de detalhes do treino com lista de exercícios - CORRIGIDA + AJUSTES
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

  // ===== 🆕 NOVO: ESTADO DOS AJUSTES =====
  Map<int, bool> _exerciciosExpandidos = {}; // Quais exercícios estão expandidos
  Map<int, Map<String, dynamic>> _ajustesTemporarios = {}; // Ajustes não salvos
  bool _temAjustesPendentes = false; // Indica se há ajustes não salvos

  @override
  void initState() {
    super.initState();
    
    // Configurar status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    _setupAnimations();
    
    // ✅ CORREÇÃO: USAR addPostFrameCallback para evitar setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDetalhes();
    });
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

  /// Carregar detalhes completos do treino - CORRIGIDO COM PROTEÇÕES
  Future<void> _carregarDetalhes() async {
    if (!mounted) return;
    
    try {
      print('🔧 Editando treino: ${widget.treino.nomeTreino}');
      print('🔧 Tipo: ${widget.treino.tipoTreino}');
      print('🔧 Dificuldade: ${widget.treino.dificuldade}');
      print('🔧 Exercícios: ${widget.treino.exercicios.length}');
      
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      
      if (mounted) {
        setState(() => _isLoading = true);
      }
      
      final resultado = await treinoProvider.buscarTreino(widget.treino.id!);
      
      if (!mounted) return;
      
      if (resultado.success && resultado.data != null) {
        setState(() {
          _treinoDetalhado = resultado.data;
          _isLoading = false;
        });
        
        print('✅ PROVIDER: Treino carregado: ${resultado.data!.nomeTreino}');
      } else {
        setState(() => _isLoading = false);
        
        _showSnackBar(
          resultado.message ?? 'Erro ao carregar detalhes',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Erro em _carregarDetalhes: $e');
      
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar(
          'Erro ao carregar detalhes: $e',
          isError: true,
        );
      }
    }
  }

  // ===== 🆕 MÉTODOS DE AJUSTE =====

  /// Alternar expansão do exercício
  void _toggleExercicioExpansao(int exercicioIndex) {
    setState(() {
      _exerciciosExpandidos[exercicioIndex] = 
          !(_exerciciosExpandidos[exercicioIndex] ?? false);
    });
    
    HapticFeedback.lightImpact();
  }

  /// Verificar se exercício está expandido
  bool _isExercicioExpandido(int exercicioIndex) {
    return _exerciciosExpandidos[exercicioIndex] ?? false;
  }

  /// Obter valor ajustado ou original
  dynamic _getValorExercicio(int exercicioIndex, String campo, dynamic valorOriginal) {
    final ajustes = _ajustesTemporarios[exercicioIndex];
    if (ajustes != null && ajustes.containsKey(campo)) {
      return ajustes[campo];
    }
    return valorOriginal;
  }

  /// Ajustar valor do exercício
  void _ajustarValorExercicio(int exercicioIndex, String campo, dynamic novoValor) {
    setState(() {
      if (_ajustesTemporarios[exercicioIndex] == null) {
        _ajustesTemporarios[exercicioIndex] = {};
      }
      _ajustesTemporarios[exercicioIndex]![campo] = novoValor;
      _temAjustesPendentes = true;
    });
    
    HapticFeedback.lightImpact();
  }

  /// Resetar ajustes de um exercício
  void _resetarAjustesExercicio(int exercicioIndex) {
    setState(() {
      _ajustesTemporarios.remove(exercicioIndex);
      _verificarAjustesPendentes();
    });
    
    HapticFeedback.lightImpact();
    _showSnackBar('Ajustes resetados');
  }

  /// Verificar se há ajustes pendentes
  void _verificarAjustesPendentes() {
    _temAjustesPendentes = _ajustesTemporarios.isNotEmpty;
  }

  /// Salvar ajustes do exercício
  Future<void> _salvarAjustesExercicio(int exercicioIndex) async {
    final treino = _treinoDetalhado ?? widget.treino;
    final exercicio = treino.exercicios[exercicioIndex];
    final ajustes = _ajustesTemporarios[exercicioIndex];
    
    if (ajustes == null || ajustes.isEmpty) {
      _showSnackBar('Nenhum ajuste para salvar', isError: true);
      return;
    }

    try {
      _showSnackBar('Salvando ajustes...', isLoading: true);

      // Criar exercício atualizado com os ajustes
      final exercicioAtualizado = exercicio.copyWith(
        series: ajustes['series'] ?? exercicio.series,
        repeticoes: ajustes['repeticoes'] ?? exercicio.repeticoes,
        tempoExecucao: ajustes['tempoExecucao'] ?? exercicio.tempoExecucao,
        tempoDescanso: ajustes['tempoDescanso'] ?? exercicio.tempoDescanso,
        peso: ajustes['peso'] ?? exercicio.peso,
      );

      // Atualizar via provider
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      final result = await treinoProvider.atualizarExercicio(
        treino.id!,
        exercicio.id!,
        exercicioAtualizado,
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _ajustesTemporarios.remove(exercicioIndex);
          _verificarAjustesPendentes();
        });

        _showSnackBar('Ajustes salvos com sucesso!');
        
        // Recarregar detalhes
        await _carregarDetalhes();
      } else {
        _showSnackBar(
          result.message ?? 'Erro ao salvar ajustes',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Erro em _salvarAjustesExercicio: $e');
      if (mounted) {
        _showSnackBar(
          'Erro ao salvar ajustes: $e',
          isError: true,
        );
      }
    }
  }

  /// Salvar todos os ajustes pendentes
  Future<void> _salvarTodosAjustes() async {
    if (!_temAjustesPendentes) return;

    try {
      _showSnackBar('Salvando todos os ajustes...', isLoading: true);

      // 🔧 CORREÇÃO: Fazer cópia das chaves para evitar modificação concorrente
      final exerciciosParaSalvar = List<int>.from(_ajustesTemporarios.keys);

      // Salvar cada exercício com ajustes
      for (final exercicioIndex in exerciciosParaSalvar) {
        // Verificar se ainda tem ajustes antes de salvar (pode ter sido removido)
        if (_ajustesTemporarios.containsKey(exercicioIndex)) {
          await _salvarAjustesExercicio(exercicioIndex);
        }
      }

      if (mounted) {
        _showSnackBar('Todos os ajustes foram salvos!');
      }
    } catch (e) {
      print('❌ Erro em _salvarTodosAjustes: $e');
      if (mounted) {
        _showSnackBar(
          'Erro ao salvar ajustes: $e',
          isError: true,
        );
      }
    }
  }

  /// Voltar para tela anterior
  void _voltarTela() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  /// 🚀 CORREÇÃO PRINCIPAL: Editar treino - COM REFRESH DO PROVIDER GLOBAL
  void _editarTreino() {
    final treino = _treinoDetalhado ?? widget.treino;
    
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarTreinoScreen(treinoParaEditar: treino),
      ),
    ).then((result) async {
      // Se houver resultado (treino editado), recarregar
      if (result != null && mounted) {
        print('🔄 DETALHES: Treino foi editado, recarregando...');
        
        // ✅ CORREÇÃO CRÍTICA: REFRESH DO PROVIDER GLOBAL PRIMEIRO
        final treinoProvider = context.read<TreinoProvider>();
        await treinoProvider.recarregar();
        print('✅ DETALHES: Provider global atualizado');
        
        // ✅ DEPOIS RECARREGAR DETALHES LOCAIS
        await _carregarDetalhes();
        print('✅ DETALHES: Detalhes locais recarregados');
        
        _showSnackBar('Treino atualizado com sucesso!');
      }
    });
  }

  /// Excluir treino
  Future<void> _excluirTreino() async {
    final treino = _treinoDetalhado ?? widget.treino;
    
    HapticFeedback.lightImpact();
    
    // Mostrar dialog de confirmação
    final confirmacao = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDialogExclusao(treino),
    );

    if (confirmacao == true) {
      await _executarExclusao(treino);
    }
  }

  /// Dialog de confirmação para exclusão
  Widget _buildDialogExclusao(TreinoModel treino) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: Color(0xFFEF4444),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Excluir Treino',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 16,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Tem certeza que deseja excluir o treino '),
                TextSpan(
                  text: '"${treino.nomeTreino}"',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Esta ação não pode ser desfeita',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text(
            'Cancelar',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  /// 🚀 CORREÇÃO PRINCIPAL: Executar exclusão - COM REFRESH DO PROVIDER GLOBAL
  Future<void> _executarExclusao(TreinoModel treino) async {
    if (!mounted) return;
    
    try {
      // Mostrar loading
      _showSnackBar('Excluindo treino...', isLoading: true);

      print('🗑️ DETALHES: Iniciando exclusão do treino ${treino.id}');

      // ✅ CORREÇÃO CRÍTICA: USAR PROVIDER PARA EXCLUSÃO
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      final result = await treinoProvider.removerTreino(treino.id!);
      
      if (!mounted) return;
      
      print('📱 DETALHES: Resultado da exclusão: success=${result.success}');
      
      if (result.success) {
        _showSnackBar('Treino excluído com sucesso!');
        
        print('✅ DETALHES: Treino excluído - Provider já foi atualizado automaticamente');
        
        // ✅ CORREÇÃO: FORÇAR REFRESH ADICIONAL DO PROVIDER PARA GARANTIR
        await treinoProvider.recarregar();
        print('✅ DETALHES: Provider global recarregado após exclusão');
        
        // Voltar para tela anterior após 1 segundo
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.of(context).pop(true); // Retorna true para indicar exclusão
        }
      } else {
        _showSnackBar(
          result.message ?? 'Erro ao excluir treino',
          isError: true,
        );
      }
    } catch (e) {
      print('❌ Erro em _executarExclusao: $e');
      if (mounted) {
        _showSnackBar(
          'Erro ao excluir treino: $e',
          isError: true,
        );
      }
    }
  }

  /// Mostrar SnackBar
  void _showSnackBar(String message, {bool isError = false, bool isLoading = false}) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError 
            ? const Color(0xFFEF4444) 
            : const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
  
  /// Iniciar treino direto para execução
  void _iniciarTreino() {
    final treino = _treinoDetalhado ?? widget.treino;
    
    if (treino.exercicios.isEmpty) {
      _showSnackBar(
        'Este treino não possui exercícios',
        isError: true,
      );
      return;
    }

    // Mostrar feedback de início
    _showSnackBar('Iniciando treino "${treino.nomeTreino}"...');
    
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

  /// Widget do header do treino - CORRIGIDO
  Widget _buildHeader() {
    final treino = _treinoDetalhado ?? widget.treino;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            treino.corDificuldadeColor,
            treino.corDificuldadeColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
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
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      treino.tipoTreino,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  treino.dificuldadeTextoSeguro,
                  style: const TextStyle(
                    fontSize: 12,
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
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Estatísticas - LAYOUT SIMPLIFICADO
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  Icons.fitness_center_rounded,
                  '${treino.totalExerciciosCalculado}',
                  'Exercícios',
                ),
              ),
              Expanded(
                child: _buildHeaderStat(
                  Icons.timer_rounded,
                  treino.duracaoFormatadaSegura,
                  'Duração',
                ),
              ),
              Expanded(
                child: _buildHeaderStat(
                  Icons.trending_up_rounded,
                  treino.dificuldadeTextoSeguro,
                  'Nível',
                ),
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
          size: 20,
        ),
        const SizedBox(height: 6),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ===== 🆕 WIDGETS DE AJUSTE =====

  /// Widget da seção de ajustes do exercício
  Widget _buildSecaoAjustes(ExercicioModel exercicio, int exercicioIndex) {
    final temAjustes = _ajustesTemporarios[exercicioIndex]?.isNotEmpty ?? false;
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da seção de ajustes
          Row(
            children: [
              Icon(
                Icons.tune_rounded,
                size: 18,
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              const Text(
                'Ajustar para Este Treino',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
              ),
              const Spacer(),
              if (temAjustes) ...[
                // Botão resetar
                IconButton(
                  onPressed: () => _resetarAjustesExercicio(exercicioIndex),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                  tooltip: 'Resetar ajustes',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
                // Botão salvar
                IconButton(
                  onPressed: () => _salvarAjustesExercicio(exercicioIndex),
                  icon: const Icon(
                    Icons.save_rounded,
                    size: 18,
                    color: Color(0xFF10B981),
                  ),
                  tooltip: 'Salvar ajustes',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 12),

          // Controles de ajuste
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              // Séries
              if (exercicio.series != null)
                _buildControleAjuste(
                  exercicioIndex,
                  'series',
                  'Séries',
                  Icons.repeat_rounded,
                  exercicio.series!,
                  1,
                  20,
                ),

              // Repetições (se for exercício de repetição)
              if (exercicio.tipoExecucao == 'repeticao' && exercicio.repeticoes != null)
                _buildControleAjuste(
                  exercicioIndex,
                  'repeticoes',
                  'Repetições',
                  Icons.format_list_numbered_rounded,
                  exercicio.repeticoes!,
                  1,
                  100,
                ),

              // Tempo de execução (se for exercício de tempo)
              if (exercicio.tipoExecucao == 'tempo' && exercicio.tempoExecucao != null)
                _buildControleAjuste(
                  exercicioIndex,
                  'tempoExecucao',
                  'Tempo (s)',
                  Icons.timer_rounded,
                  exercicio.tempoExecucao!,
                  10,
                  600,
                  step: 10,
                ),

              // Tempo de descanso
              if (exercicio.tempoDescanso != null)
                _buildControleAjuste(
                  exercicioIndex,
                  'tempoDescanso',
                  'Descanso (s)',
                  Icons.pause_rounded,
                  exercicio.tempoDescanso!,
                  0,
                  300,
                  step: 15,
                ),

              // Peso
              if (exercicio.peso != null)
                _buildControleAjuste(
                  exercicioIndex,
                  'peso',
                  'Peso (${exercicio.unidadePeso ?? 'kg'})',
                  Icons.fitness_center_rounded,
                  exercicio.peso!,
                  0.0,
                  500.0,
                  step: 2.5,
                  isDouble: true,
                ),
            ],
          ),

          // Indicador de ajustes temporários
          if (temAjustes) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_rounded,
                    color: Color(0xFFF59E0B),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Ajustes não salvos neste exercício',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF59E0B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Widget de controle de ajuste
  Widget _buildControleAjuste(
    int exercicioIndex,
    String campo,
    String label,
    IconData icon,
    dynamic valorOriginal,
    dynamic minValue,
    dynamic maxValue, {
    dynamic step = 1,
    bool isDouble = false,
  }) {
    final valorAtual = _getValorExercicio(exercicioIndex, campo, valorOriginal);
    final temAjuste = _ajustesTemporarios[exercicioIndex]?.containsKey(campo) ?? false;
    
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: temAjuste 
            ? const Color(0xFF6366F1).withOpacity(0.1)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: temAjuste 
              ? const Color(0xFF6366F1).withOpacity(0.3)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          // Header do controle
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: temAjuste 
                    ? const Color(0xFF6366F1) 
                    : const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: temAjuste 
                        ? const Color(0xFF6366F1) 
                        : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (temAjuste)
                Icon(
                  Icons.edit_rounded,
                  size: 12,
                  color: const Color(0xFF6366F1),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Valor atual
          Text(
            isDouble ? valorAtual.toStringAsFixed(1) : valorAtual.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: temAjuste 
                  ? const Color(0xFF6366F1) 
                  : const Color(0xFF0F172A),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Botões de ajuste
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botão diminuir
              GestureDetector(
                onTap: () {
                  dynamic novoValor;
                  if (isDouble) {
                    novoValor = (valorAtual - step).clamp(minValue, maxValue);
                  } else {
                    novoValor = (valorAtual - step).clamp(minValue, maxValue);
                  }
                  _ajustarValorExercicio(exercicioIndex, campo, novoValor);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: const Icon(
                    Icons.remove_rounded,
                    size: 16,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
              
              // Botão aumentar
              GestureDetector(
                onTap: () {
                  dynamic novoValor;
                  if (isDouble) {
                    novoValor = (valorAtual + step).clamp(minValue, maxValue);
                  } else {
                    novoValor = (valorAtual + step).clamp(minValue, maxValue);
                  }
                  _ajustarValorExercicio(exercicioIndex, campo, novoValor);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget do card do exercício - CORRIGIDO + AJUSTES
  Widget _buildExercicioCard(ExercicioModel exercicio, int index) {
    final isExpandido = _isExercicioExpandido(index);
    final temAjustes = _ajustesTemporarios[index]?.isNotEmpty ?? false;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: temAjustes 
            ? Border.all(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                width: 2,
              )
            : isExpandido
                ? Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.2),
                    width: 1,
                  )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: temAjustes 
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (exercicio.grupoMuscular != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercicio.grupoMuscular!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Tipo de execução
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exercicio.tipoExecucao == 'repeticao' ? 'Reps' : 'Tempo',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6366F1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 🆕 BOTÃO AJUSTAR - MAIOR E MAIS CLARO
                GestureDetector(
                  onTap: () => _toggleExercicioExpansao(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isExpandido 
                          ? const Color(0xFF6366F1)
                          : const Color(0xFF6366F1).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isExpandido 
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.tune_rounded,
                          size: 16,
                          color: isExpandido 
                              ? Colors.white
                              : const Color(0xFF6366F1),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpandido ? 'Fechar' : 'Ajustar',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isExpandido 
                                ? Colors.white
                                : const Color(0xFF6366F1),
                          ),
                        ),
                      ],
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
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Informações de execução - LAYOUT SIMPLIFICADO
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                if (exercicio.series != null)
                  _buildExercicioInfo(
                    Icons.repeat_rounded,
                    '${_getValorExercicio(index, 'series', exercicio.series)}',
                    'Séries',
                    temAjuste: _ajustesTemporarios[index]?.containsKey('series') ?? false,
                  ),
                
                if (exercicio.tipoExecucao == 'repeticao' && exercicio.repeticoes != null)
                  _buildExercicioInfo(
                    Icons.format_list_numbered_rounded,
                    '${_getValorExercicio(index, 'repeticoes', exercicio.repeticoes)}',
                    'Reps',
                    temAjuste: _ajustesTemporarios[index]?.containsKey('repeticoes') ?? false,
                  ),
                
                if (exercicio.tipoExecucao == 'tempo' && exercicio.tempoExecucao != null)
                  _buildExercicioInfo(
                    Icons.timer_rounded,
                    '${_getValorExercicio(index, 'tempoExecucao', exercicio.tempoExecucao)}s',
                    'Execução',
                    temAjuste: _ajustesTemporarios[index]?.containsKey('tempoExecucao') ?? false,
                  ),
                
                if (exercicio.tempoDescanso != null)
                  _buildExercicioInfo(
                    Icons.pause_rounded,
                    '${_getValorExercicio(index, 'tempoDescanso', exercicio.tempoDescanso)}s',
                    'Descanso',
                    temAjuste: _ajustesTemporarios[index]?.containsKey('tempoDescanso') ?? false,
                  ),
                
                if (exercicio.peso != null)
                  _buildExercicioInfo(
                    Icons.fitness_center_rounded,
                    '${_getValorExercicio(index, 'peso', exercicio.peso)}${exercicio.unidadePeso ?? 'kg'}',
                    'Peso',
                    temAjuste: _ajustesTemporarios[index]?.containsKey('peso') ?? false,
                  ),
              ],
            ),
            
            // 🆕 SEÇÃO DE AJUSTES (se expandido) - COM ANIMAÇÃO
            if (isExpandido)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _buildSecaoAjustes(exercicio, index),
              ),
            
            // Observações (se houver)
            if (exercicio.observacoes != null && exercicio.observacoes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        exercicio.observacoes!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFFF59E0B),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Widget de informação do exercício - ATUALIZADO COM INDICADOR DE AJUSTE
  Widget _buildExercicioInfo(IconData icon, String valor, String label, {bool temAjuste = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: temAjuste 
              ? const Color(0xFF6366F1)
              : const Color(0xFF6366F1),
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valor,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: temAjuste 
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (temAjuste) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_rounded,
                    size: 10,
                    color: const Color(0xFF6366F1),
                  ),
                ],
              ],
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: temAjuste 
                    ? const Color(0xFF6366F1)
                    : const Color(0xFF94A3B8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'Nenhum exercício',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          
          const SizedBox(height: 8),
          
          const Text(
            'Este treino ainda não possui exercícios',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Widget da barra de ação inferior - ATUALIZADA COM AJUSTES
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🆕 Botão de salvar todos os ajustes (se houver ajustes pendentes)
            if (_temAjustesPendentes) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _salvarTodosAjustes,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Salvar Todos os Ajustes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Status do treino (se não puder iniciar)
            if (!_podeIniciarTreino)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Color(0xFFF59E0B), size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Adicione exercícios para iniciar este treino',
                        style: TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            
            // Botão de iniciar treino
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _podeIniciarTreino ? _iniciarTreino : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _podeIniciarTreino 
                      ? const Color(0xFF6366F1) 
                      : const Color(0xFF94A3B8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _podeIniciarTreino ? Icons.play_arrow_rounded : Icons.block_rounded,
                ),
                label: Text(
                  _podeIniciarTreino ? 'Iniciar Treino' : 'Sem Exercícios',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          onPressed: _voltarTela,
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 20,
          ),
          tooltip: 'Voltar',
        ),
        title: const Text(
          'Detalhes do Treino',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Indicador de ajustes pendentes
          if (_temAjustesPendentes)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton(
                onPressed: _salvarTodosAjustes,
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.save_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                tooltip: 'Salvar ajustes',
              ),
            ),
          
          // Botão editar
          IconButton(
            onPressed: _editarTreino,
            icon: const Icon(
              Icons.edit_rounded,
              color: Color(0xFF6366F1),
              size: 22,
            ),
            tooltip: 'Editar Treino',
          ),
          // Botão excluir
          IconButton(
            onPressed: _excluirTreino,
            icon: const Icon(
              Icons.delete_rounded,
              color: Color(0xFFEF4444),
              size: 22,
            ),
            tooltip: 'Excluir Treino',
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      bottomNavigationBar: _buildBottomActionBar(),
      
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
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
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${treino.exercicios.length}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6366F1),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // 🆕 Indicador de ajustes pendentes
                            if (_temAjustesPendentes)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 12,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Ajustes pendentes',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFFF59E0B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      
                      // 🆕 DICA PARA O USUÁRIO - MELHORADA
                      if (treino.exercicios.isNotEmpty && !_temAjustesPendentes && _exerciciosExpandidos.isEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1).withOpacity(0.1),
                                const Color(0xFF6366F1).withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF6366F1).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.touch_app_rounded,
                                  color: const Color(0xFF6366F1),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Personalize seus exercícios',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF6366F1),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Clique em "Ajustar" para modificar séries, repetições, peso e tempo de cada exercício',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF6366F1),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
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