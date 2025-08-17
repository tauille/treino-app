import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/treino_model.dart';
import '../../providers/treino_provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/sport_theme.dart';
import 'criar_treino_screen.dart';

/// 📚 Biblioteca de Treinos - CORRIGIDO COM CONSUMER
class MeusTreinosScreen extends StatefulWidget {
  const MeusTreinosScreen({super.key});

  @override
  State<MeusTreinosScreen> createState() => _MeusTreinosScreenState();
}

class _MeusTreinosScreenState extends State<MeusTreinosScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // 🔥 REMOVIDO: List<TreinoModel> _treinos = []; (não usar estado local)
  // 🔥 REMOVIDO: bool _isLoading = false; (usar do Provider)
  
  String _filtroTipo = 'Todos';
  String _filtroDificuldade = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _tiposFiltro = [
    'Todos', 'Musculação', 'Cardio', 'Funcional', 'Yoga'
  ];
  
  final List<String> _dificuldadesFiltro = [
    'Todos', 'iniciante', 'intermediario', 'avancado'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _carregarTreinosInicial();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
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
    
    _fadeController.forward();
  }

  /// 🔥 CARGA INICIAL - SEM FORCE REFRESH
  Future<void> _carregarTreinosInicial() async {
    try {
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      await treinoProvider.listarTreinos();
    } catch (e) {
      _showSnackBar('Erro ao carregar treinos', isError: true);
    }
  }

  /// 🔥 FORCE REFRESH - PARA PULL-TO-REFRESH E BOTÃO REFRESH
  Future<void> _carregarTreinosForce() async {
    print('🔄 FORÇANDO refresh da lista de treinos...');
    
    try {
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      await treinoProvider.listarTreinos(forceRefresh: true);
      print('✅ Force refresh concluído');
    } catch (e) {
      print('❌ Erro no force refresh: $e');
      _showSnackBar('Erro ao carregar treinos', isError: true);
    }
  }

  /// 🔥 TREINOS FILTRADOS - AGORA USA DIRETAMENTE O PROVIDER
  List<TreinoModel> _getTreinosFiltrados(List<TreinoModel> treinos) {
    return treinos.where((treino) {
      // Filtro por busca
      final searchTerm = _searchController.text.toLowerCase();
      if (searchTerm.isNotEmpty) {
        if (!treino.nomeTreino.toLowerCase().contains(searchTerm) &&
            !treino.tipoTreino.toLowerCase().contains(searchTerm)) {
          return false;
        }
      }
      
      // Filtro por tipo
      if (_filtroTipo != 'Todos' && treino.tipoTreino != _filtroTipo) {
        return false;
      }
      
      // Filtro por dificuldade
      if (_filtroDificuldade != 'Todos' && 
          treino.dificuldade != _filtroDificuldade) {
        return false;
      }
      
      return true;
    }).toList();
  }

  void _criarNovoTreino() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((_) => _carregarTreinosForce());
  }

  void _editarTreino(TreinoModel treino) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarTreinoScreen(treinoParaEditar: treino),
      ),
    ).then((_) => _carregarTreinosForce());
  }

  void _iniciarTreino(TreinoModel treino) {
    HapticFeedback.mediumImpact();
    
    if (treino.exercicios.isEmpty) {
      _showSnackBar('Este treino não possui exercícios', isError: true);
      return;
    }
    
    Navigator.pushNamed(
      context,
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }

  /// 🔥 MÉTODO CORRIGIDO: Excluir treino - SEM FORCE REFRESH (Provider faz tudo)
  void _excluirTreino(TreinoModel treino) async {
    print('🗑️ Iniciando exclusão do treino: ${treino.nomeTreino} (ID: ${treino.id})');
    
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => _buildDeleteDialog(treino),
    );

    if (shouldDelete == true) {
      print('✅ Usuário confirmou exclusão');
      
      try {
        final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
        print('🚀 Chamando provider.removerTreino()...');
        
        final resultado = await treinoProvider.removerTreino(treino.id!);
        
        print('📱 Resultado da exclusão: success=${resultado.success}');
        
        if (resultado.success) {
          _showSnackBar('Treino excluído com sucesso');
          print('✅ Exclusão concluída - Provider deve ter notificado automaticamente');
          
          // 🔥 NÃO PRECISA FORCE REFRESH - Provider já fez tudo!
        } else {
          print('❌ Erro na exclusão: ${resultado.message}');
          _showSnackBar(
            resultado.message ?? 'Erro ao excluir treino',
            isError: true,
          );
        }
      } catch (e) {
        print('❌ Exceção durante exclusão: $e');
        _showSnackBar('Erro ao excluir treino', isError: true);
      }
    } else {
      print('❌ Usuário cancelou exclusão');
    }
  }

  Widget _buildDeleteDialog(TreinoModel treino) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        'Excluir Treino',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
      content: Text(
        'Tem certeza que deseja excluir "${treino.nomeTreino}"?\n\nEsta ação não pode ser desfeita.',
        style: TextStyle(
          color: const Color(0xFF64748B),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('Excluir'),
        ),
      ],
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? const Color(0xFFEF4444) 
            : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _carregarTreinosForce,
          color: const Color(0xFF6366F1),
          backgroundColor: Colors.white,
          child: 
          // 🔥 CONSUMER PRINCIPAL - OUVE O PROVIDER EM TEMPO REAL
          Consumer<TreinoProvider>(
            builder: (context, treinoProvider, child) {
              print('🔔 Consumer rebuild - treinos: ${treinoProvider.treinos.length}, loading: ${treinoProvider.isLoading}');
              
              if (treinoProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF6366F1),
                  ),
                );
              }

              final treinosFiltrados = _getTreinosFiltrados(treinoProvider.treinos);
              
              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  // Header com stats
                  SliverToBoxAdapter(
                    child: _buildHeader(treinoProvider.treinos),
                  ),
                  
                  // Barra de pesquisa e filtros
                  SliverToBoxAdapter(
                    child: _buildSearchAndFilters(),
                  ),
                  
                  // Lista de treinos
                  _buildTreinosList(treinosFiltrados),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// AppBar moderno com botão voltar bem visível
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 16),
        child: IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).pop();
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF6366F1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 18,
          ),
        ),
      ),
      title: Text(
        'Biblioteca',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: IconButton(
            onPressed: _carregarTreinosForce,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF64748B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(
              Icons.refresh_rounded,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  /// 🔥 Header com estatísticas - RECEBE TREINOS COMO PARÂMETRO
  Widget _buildHeader(List<TreinoModel> treinos) {
    final treinosAtivos = treinos.where((t) => 
        (t.status ?? 'ativo') == 'ativo').length;
    final totalExercicios = treinos.fold<int>(
        0, (sum, treino) => sum + treino.exercicios.length);
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.library_books_rounded,
                color: const Color(0xFF6366F1),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Seus Treinos Personalizados',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildHeaderStat(
                  title: 'Total',
                  value: treinos.length.toString(),
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF6366F1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHeaderStat(
                  title: 'Ativos',
                  value: treinosAtivos.toString(),
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHeaderStat(
                  title: 'Exercícios',
                  value: totalExercicios.toString(),
                  icon: Icons.list_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  /// Barra de pesquisa e filtros modernos
  Widget _buildSearchAndFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Barra de pesquisa
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: const Color(0xFF0F172A),
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar treinos...',
                hintStyle: TextStyle(
                  color: const Color(0xFF94A3B8),
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtros
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  value: _filtroTipo,
                  items: _tiposFiltro,
                  hint: 'Tipo',
                  onChanged: (value) => setState(() => _filtroTipo = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  value: _filtroDificuldade,
                  items: _dificuldadesFiltro,
                  hint: 'Dificuldade',
                  onChanged: (value) => setState(() => _filtroDificuldade = value!),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: const Color(0xFF64748B),
          ),
          style: TextStyle(
            color: const Color(0xFF0F172A),
            fontSize: 14,
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item == 'Todos' ? hint : item,
                style: TextStyle(
                  color: item == 'Todos' 
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF0F172A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  /// 🔥 Lista de treinos moderna - RECEBE TREINOS COMO PARÂMETRO
  Widget _buildTreinosList(List<TreinoModel> treinosFiltrados) {
    if (treinosFiltrados.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(treinosFiltrados.isEmpty),
      );
    }
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _buildTreinoCard(treinosFiltrados[index], index);
          },
          childCount: treinosFiltrados.length,
        ),
      ),
    );
  }

  /// Card de treino moderno
  Widget _buildTreinoCard(TreinoModel treino, int index) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFF10B981),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];
    
    final color = colors[index % colors.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header colorido
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        treino.nomeTreino,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        treino.dificuldadeTextoSeguro,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  treino.tipoTreino,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          
          // Conteúdo
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildCardStat(
                        Icons.fitness_center_rounded,
                        '${treino.exercicios.length}',
                        'Exercícios',
                      ),
                    ),
                    Expanded(
                      child: _buildCardStat(
                        Icons.timer_rounded,
                        treino.duracaoFormatadaSegura,
                        'Duração',
                      ),
                    ),
                    Expanded(
                      child: _buildCardStat(
                        Icons.whatshot_rounded,
                        '${treino.exercicios.length * 15}',
                        'Cal (est.)',
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Botões
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _iniciarTreino(treino),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.play_arrow_rounded, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Iniciar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.edit_rounded,
                      onPressed: () => _editarTreino(treino),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.delete_rounded,
                      onPressed: () => _excluirTreino(treino),
                      color: const Color(0xFFEF4444),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: const Color(0xFFF8FAFC),
          foregroundColor: color ?? const Color(0xFF64748B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildEmptyState(bool isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 36,
                color: const Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isEmpty 
                  ? 'Nenhum treino criado'
                  : 'Nenhum treino encontrado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isEmpty
                  ? 'Crie seu primeiro treino personalizado'
                  : 'Tente ajustar os filtros de busca',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
            if (isEmpty) ...[
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _criarNovoTreino,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                ),
                child: Text(
                  'Criar Primeiro Treino',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _criarNovoTreino,
      backgroundColor: const Color(0xFF6366F1),
      foregroundColor: Colors.white,
      elevation: 4,
      child: const Icon(Icons.add_rounded, size: 24),
    );
  }
}