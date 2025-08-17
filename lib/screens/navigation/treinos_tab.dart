import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../treino/criar_treino_screen.dart';
import '../treino/detalhes_treino_screen.dart';

class TreinosTab extends StatefulWidget {
  const TreinosTab({super.key});

  @override
  State<TreinosTab> createState() => _TreinosTabState();
}

class _TreinosTabState extends State<TreinosTab> 
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<TreinoModel> _todosTreinos = [];
  List<TreinoModel> _treinosFiltrados = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // 🔧 NOVO: Variável para controlar última atualização
  String _ultimoHashProvider = '';
  
  // Filtros
  String? _filtroTipo;
  String? _filtroDificuldade;
  String _textoBusca = '';
  
  @override
  bool get wantKeepAlive => true;
  
  // Opções de filtro
  final List<String> _tiposTreino = [
    'Todos',
    'Musculação',
    'Cardio', 
    'Funcional',
    'Yoga',
    'HIIT',
    'Pilates',
    'Alongamento'
  ];
  
  final List<String> _dificuldades = [
    'Todas',
    'iniciante',
    'intermediario', 
    'avancado'
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _searchController.addListener(_onSearchChanged);
    
    // 🔧 CORREÇÃO DEFINITIVA: POST FRAME CALLBACK
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _carregarTreinos();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  /// 🔧 CORREÇÃO: Carregar treinos sem setState durante build
  Future<void> _carregarTreinos() async {
    if (!mounted) return;
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final treinoProvider = context.read<TreinoProvider>();
      final response = await treinoProvider.listarTreinos();
      
      if (!mounted) return;
      
      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _todosTreinos = response.data!;
            _aplicarFiltros();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response.message ?? 'Erro ao carregar treinos';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar treinos: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // 🔧 NOVO: Método para gerar hash dos treinos (detectar mudanças)
  String _gerarHashTreinos(List<TreinoModel> treinos) {
    if (treinos.isEmpty) return 'empty';
    
    final buffer = StringBuffer();
    for (final treino in treinos) {
      buffer.write('${treino.id}:');
      buffer.write('${treino.nomeTreino}:');
      buffer.write('${treino.exercicios.length}:');
      buffer.write('${treino.totalExercicios ?? 0}:');
      buffer.write('${treino.updatedAt?.millisecondsSinceEpoch ?? 0};');
    }
    return buffer.toString();
  }

  // 🔧 NOVO: Método para detectar se precisa atualizar
  bool _precisaAtualizar(List<TreinoModel> treinosProvider) {
    final novoHash = _gerarHashTreinos(treinosProvider);
    final precisaAtualizar = _ultimoHashProvider != novoHash;
    
    if (precisaAtualizar) {
      print('🔄 TREINOS_TAB: Mudança detectada!');
      print('   • Hash anterior: ${_ultimoHashProvider.substring(0, 50)}...');
      print('   • Hash novo: ${novoHash.substring(0, 50)}...');
      print('   • Treinos provider: ${treinosProvider.length}');
      print('   • Treinos locais: ${_todosTreinos.length}');
    }
    
    return precisaAtualizar;
  }

  void _onSearchChanged() {
    if (!mounted) return;
    
    setState(() {
      _textoBusca = _searchController.text.toLowerCase();
      _aplicarFiltros();
    });
  }

  void _aplicarFiltros() {
    List<TreinoModel> filtrados = List.from(_todosTreinos);

    if (_filtroTipo != null && _filtroTipo != 'Todos') {
      filtrados = filtrados.where((treino) => 
        treino.tipoTreino.toLowerCase() == _filtroTipo!.toLowerCase()).toList();
    }

    if (_filtroDificuldade != null && _filtroDificuldade != 'Todas') {
      filtrados = filtrados.where((treino) => 
        treino.dificuldade?.toLowerCase() == _filtroDificuldade!.toLowerCase()).toList();
    }

    if (_textoBusca.isNotEmpty) {
      filtrados = filtrados.where((treino) =>
        treino.nomeTreino.toLowerCase().contains(_textoBusca) ||
        treino.tipoTreino.toLowerCase().contains(_textoBusca) ||
        (treino.descricao?.toLowerCase().contains(_textoBusca) ?? false)
      ).toList();
    }

    _treinosFiltrados = filtrados;
  }

  void _limparFiltros() {
    if (!mounted) return;
    
    setState(() {
      _filtroTipo = null;
      _filtroDificuldade = null;
      _textoBusca = '';
      _searchController.clear();
      _aplicarFiltros();
    });
    
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Para AutomaticKeepAliveClientMixin
    
    // 🚀 CORREÇÃO PRINCIPAL: CONSUMER CORRIGIDO COM LÓGICA ROBUSTA
    return Consumer<TreinoProvider>(
      builder: (context, treinoProvider, child) {
        
        // ✅ LÓGICA CORRIGIDA: Detectar mudanças de forma inteligente
        if (_precisaAtualizar(treinoProvider.treinos)) {
          // ✅ ATUALIZAR SEM PostFrameCallback (mais direto)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _todosTreinos = List.from(treinoProvider.treinos); // Cópia para evitar referência
                _ultimoHashProvider = _gerarHashTreinos(treinoProvider.treinos); // Atualizar hash
                _aplicarFiltros();
              });
              print('✅ TREINOS_TAB: Lista atualizada - ${_todosTreinos.length} treinos');
              
              // ✅ LOG DETALHADO DOS TREINOS ATUALIZADOS
              for (int i = 0; i < _todosTreinos.length; i++) {
                final treino = _todosTreinos[i];
                final exerciciosCount = treino.exercicios.isNotEmpty 
                    ? treino.exercicios.length 
                    : (treino.totalExercicios ?? 0);
                print('   • Treino ${i + 1}: ${treino.nomeTreino} (${exerciciosCount} exercícios)');
              }
            }
          });
        }
        
        return Scaffold(
          backgroundColor: const Color(0xFF1A1D29),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildFiltros(),
                  Expanded(
                    child: _buildConteudo(),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _criarNovoTreino(context),
            backgroundColor: const Color(0xFFFF8C42),
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Novo Treino',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        );
      },
    );
  }

  /// ✅ CRIAR NOVO TREINO - COM REFRESH AUTOMÁTICO
  void _criarNovoTreino(BuildContext context) {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((result) async {
      print('🔄 TREINOS_TAB: Voltou da tela de criar treino');
      
      // ✅ CORREÇÃO: FORÇA REFRESH APÓS CRIAR/EDITAR
      if (mounted) {
        final treinoProvider = context.read<TreinoProvider>();
        await treinoProvider.recarregar();
        print('✅ TREINOS_TAB: Provider recarregado após criar treino');
      }
    });
  }

  /// ✅ INICIAR TREINO - COM REFRESH AUTOMÁTICO  
  void _iniciarTreino(TreinoModel treino) {
    if (!mounted) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTreinoScreen(treino: treino),
      ),
    ).then((result) async {
      print('🔄 TREINOS_TAB: Voltou da tela de detalhes');
      
      // ✅ CORREÇÃO: FORÇA REFRESH APÓS VER DETALHES/EDITAR
      if (mounted) {
        final treinoProvider = context.read<TreinoProvider>();
        await treinoProvider.recarregar();
        print('✅ TREINOS_TAB: Provider recarregado após detalhes');
      }
    });
  }

  /// Header sem overflow
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'BIBLIOTECA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _treinosFiltrados.isEmpty 
              ? '0 treinos'
              : '${_treinosFiltrados.length} treinos',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Campo de busca
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2A2D3A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _searchFocusNode.hasFocus 
                  ? const Color(0xFF4ECDC4) 
                  : const Color(0xFF374151),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Buscar treinos...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                ),
                suffixIcon: _textoBusca.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.clear,
                        color: Color(0xFF9CA3AF),
                      ),
                      onPressed: () {
                        if (!mounted) return;
                        _searchController.clear();
                        _searchFocusNode.unfocus();
                      },
                    )
                  : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 CORREÇÃO: Filtros sem overflow
  Widget _buildFiltros() {
    final temFiltros = _filtroTipo != null || 
                      _filtroDificuldade != null || 
                      _textoBusca.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChipFiltro(
                  'Tipo',
                  _filtroTipo ?? 'Todos',
                  Icons.fitness_center,
                  () => _mostrarFiltroTipo(),
                ),
                
                const SizedBox(width: 12),
                
                _buildChipFiltro(
                  'Dificuldade',
                  _filtroDificuldade ?? 'Todas',
                  Icons.trending_up,
                  () => _mostrarFiltroDificuldade(),
                ),
                
                const SizedBox(width: 12),
                
                if (temFiltros)
                  GestureDetector(
                    onTap: _limparFiltros,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6B).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF6B6B),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear,
                            color: Color(0xFFFF6B6B),
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Limpar',
                            style: TextStyle(
                              color: Color(0xFFFF6B6B),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Chip de filtro simplificado
  Widget _buildChipFiltro(
    String label,
    String valor,
    IconData icon,
    VoidCallback onTap,
  ) {
    final isAtivo = (label == 'Tipo' && _filtroTipo != null) ||
                   (label == 'Dificuldade' && _filtroDificuldade != null);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isAtivo 
            ? const Color(0xFF4ECDC4).withOpacity(0.1)
            : const Color(0xFF2A2D3A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAtivo 
              ? const Color(0xFF4ECDC4)
              : const Color(0xFF374151),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isAtivo 
                ? const Color(0xFF4ECDC4)
                : const Color(0xFF9CA3AF),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '$label: $valor',
              style: TextStyle(
                color: isAtivo 
                  ? const Color(0xFF4ECDC4)
                  : const Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              color: isAtivo 
                ? const Color(0xFF4ECDC4)
                : const Color(0xFF9CA3AF),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConteudo() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando treinos...',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Color(0xFFFF6B6B),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Erro ao carregar treinos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (!mounted) return;
                  _carregarTreinos();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_treinosFiltrados.isEmpty) {
      final temFiltros = _filtroTipo != null || 
                        _filtroDificuldade != null || 
                        _textoBusca.isNotEmpty;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  temFiltros ? Icons.search_off : Icons.fitness_center,
                  color: const Color(0xFF9CA3AF),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                temFiltros 
                  ? 'Nenhum treino encontrado'
                  : 'Nenhum treino criado',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                temFiltros
                  ? 'Tente ajustar os filtros de busca'
                  : 'Crie seu primeiro treino para começar',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: temFiltros ? _limparFiltros : () => _criarNovoTreino(context),
                icon: Icon(temFiltros ? Icons.clear : Icons.add),
                label: Text(temFiltros ? 'Limpar filtros' : 'Criar primeiro treino'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: temFiltros 
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFFFF8C42),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _carregarTreinos,
      color: const Color(0xFF4ECDC4),
      backgroundColor: const Color(0xFF2A2D3A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _treinosFiltrados.length,
        itemBuilder: (context, index) {
          if (!mounted) {
            return const SizedBox.shrink();
          }
          final treino = _treinosFiltrados[index];
          return _buildCardTreino(treino);
        },
      ),
    );
  }

  /// 🔧 CORREÇÃO PRINCIPAL: Card TOTALMENTE REDESENHADO sem overflow
  Widget _buildCardTreino(TreinoModel treino) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _iniciarTreino(treino),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔧 CORREÇÃO: Header simplificado sem overflow
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getCorTreino(treino.dificuldade).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIconeTreino(treino.tipoTreino),
                        color: _getCorTreino(treino.dificuldade),
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // 🔧 CORREÇÃO: Textos com Expanded garantido
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            treino.nomeTreino,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            treino.tipoTreino,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 🔧 CORREÇÃO: Badge de dificuldade separado
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getCorTreino(treino.dificuldade).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getDificuldadeTexto(treino.dificuldade),
                      style: TextStyle(
                        color: _getCorTreino(treino.dificuldade),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                
                // Descrição se existir
                if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    treino.descricao!,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // 🔧 CORREÇÃO PRINCIPAL: Footer sem overflow usando Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Estatísticas em linha simples
                    Row(
                      children: [
                        _buildInfoTag(
                          Icons.fitness_center,
                          '${treino.exercicios.isNotEmpty ? treino.exercicios.length : (treino.totalExercicios ?? 0)} ex',
                        ),
                        const SizedBox(width: 8),
                        _buildInfoTag(
                          Icons.schedule,
                          treino.duracaoFormatada ?? '0min',
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Botão iniciar em linha separada
                    SizedBox(
                      width: double.infinity,
                      height: 36,
                      child: ElevatedButton.icon(
                        onPressed: () => _iniciarTreino(treino),
                        icon: const Icon(
                          Icons.play_arrow,
                          size: 18,
                        ),
                        label: const Text(
                          'Iniciar Treino',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 🔧 NOVO: Tag de informação minimalista (sem overflow)
  Widget _buildInfoTag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF9CA3AF),
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _mostrarFiltroTipo() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetFiltro(
        'Filtrar por Tipo',
        _tiposTreino,
        _filtroTipo ?? 'Todos',
        (valor) {
          if (!mounted) return;
          setState(() {
            _filtroTipo = valor == 'Todos' ? null : valor;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  void _mostrarFiltroDificuldade() {
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetFiltro(
        'Filtrar por Dificuldade',
        _dificuldades,
        _filtroDificuldade ?? 'Todas',
        (valor) {
          if (!mounted) return;
          setState(() {
            _filtroDificuldade = valor == 'Todas' ? null : valor;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  Widget _buildBottomSheetFiltro(
    String titulo,
    List<String> opcoes,
    String valorAtual,
    Function(String) onSelected,
  ) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: opcoes.length,
              itemBuilder: (context, index) {
                final opcao = opcoes[index];
                final isSelected = opcao == valorAtual;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected 
                      ? const Color(0xFF4ECDC4).withOpacity(0.1)
                      : const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                        ? const Color(0xFF4ECDC4)
                        : const Color(0xFF4B5563),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      _getDificuldadeTexto(opcao),
                      style: TextStyle(
                        color: isSelected 
                          ? const Color(0xFF4ECDC4)
                          : Colors.white,
                        fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFF4ECDC4),
                        )
                      : null,
                    onTap: () {
                      onSelected(opcao);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Color _getCorTreino(String? dificuldade) {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return const Color(0xFF22C55E);
      case 'intermediario':
        return const Color(0xFFFBBF24);
      case 'avancado':
        return const Color(0xFFFF6B6B);
      default:
        return const Color(0xFF4ECDC4);
    }
  }

  IconData _getIconeTreino(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'musculação':
        return Icons.fitness_center;
      case 'cardio':
        return Icons.directions_run;
      case 'funcional':
        return Icons.sports_gymnastics;
      case 'yoga':
        return Icons.self_improvement;
      case 'hiit':
        return Icons.flash_on;
      case 'pilates':
        return Icons.accessibility_new;
      case 'alongamento':
        return Icons.spa;
      default:
        return Icons.fitness_center;
    }
  }

  String _getDificuldadeTexto(String? dificuldade) {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return 'Iniciante';
      case 'intermediario':
        return 'Intermediário';
      case 'avancado':
        return 'Avançado';
      case 'todas':
        return 'Todas';
      case 'todos':
        return 'Todos';
      default:
        return dificuldade ?? 'N/A';
    }
  }
}