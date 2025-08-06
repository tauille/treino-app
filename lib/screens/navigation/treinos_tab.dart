import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';

class TreinosTab extends StatefulWidget {
  const TreinosTab({super.key});

  @override
  State<TreinosTab> createState() => _TreinosTabState();
}

class _TreinosTabState extends State<TreinosTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<TreinoModel> _todosTreinos = [];
  List<TreinoModel> _treinosFiltrados = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Filtros
  String? _filtroTipo;
  String? _filtroDificuldade;
  String _textoBusca = '';
  
  // 🔧 CORREÇÃO: CONTROLE DE DISPOSED PARA EVITAR MEMORY LEAKS
  bool _isDisposed = false;
  
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
    print('🚀 [DEBUG] TreinosTab initState iniciado');
    
    _setupAnimations();
    
    // Listener para busca em tempo real
    _searchController.addListener(_onSearchChanged);
    
    // 🔧 CORREÇÃO: Mover carregamento para após build completo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        print('🚀 [DEBUG] PostFrameCallback - carregando treinos...');
        _carregarTreinosSeguro();
      }
    });
  }

  @override
  void dispose() {
    print('🧹 [DEBUG] TreinosTab dispose iniciado');
    
    // 🔧 CORREÇÃO: MARCAR COMO DISPOSED PRIMEIRO
    _isDisposed = true;
    
    // Limpar controladores e animações
    _fadeController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    
    super.dispose();
    print('✅ [DEBUG] TreinosTab dispose finalizado');
  }

  /// Configurar animações
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

  /// 🔧 CORREÇÃO: CARREGAR TREINOS DE FORMA SEGURA
  Future<void> _carregarTreinosSeguro() async {
    if (_isDisposed || !mounted) {
      print('⚠️ [DEBUG] Carregamento cancelado - widget disposed/unmounted');
      return;
    }
    
    print('🔄 [DEBUG] Iniciando carregamento seguro de treinos...');
    
    // 🔧 CORREÇÃO: USAR FUTURE.MICROTASK PARA EVITAR setState DURANTE BUILD
    Future.microtask(() {
      if (_isDisposed || !mounted) return;
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    });

    try {
      // 🔧 CORREÇÃO: USAR read() EM VEZ DE watch() PARA EVITAR REBUILD
      final treinoProvider = context.read<TreinoProvider>();
      
      print('🔄 [DEBUG] Chamando TreinoProvider.listarTreinos()...');
      final response = await treinoProvider.listarTreinos();
      
      // 🔧 CORREÇÃO: VERIFICAR SE AINDA ESTÁ MONTADO ANTES DE ATUALIZAR
      if (_isDisposed || !mounted) {
        print('⚠️ [DEBUG] Widget foi disposed durante carregamento');
        return;
      }
      
      print('🔄 [DEBUG] Resposta recebida: success=${response.success}');
      print('🔄 [DEBUG] Dados: ${response.data?.length ?? 0} treinos');
      print('🔄 [DEBUG] Mensagem: ${response.message}');
      
      if (response.success && response.data != null) {
        print('✅ [DEBUG] Atualizando lista local com ${response.data!.length} treinos');
        
        // 🔧 CORREÇÃO: USAR FUTURE.MICROTASK PARA ATUALIZAÇÃO SEGURA
        Future.microtask(() {
          if (_isDisposed || !mounted) return;
          
          setState(() {
            _todosTreinos = response.data!;
            _aplicarFiltros();
          });
        });
        
        print('✅ [DEBUG] Lista atualizada: ${_todosTreinos.length} treinos');
      } else {
        print('❌ [DEBUG] Erro na resposta: ${response.message}');
        
        Future.microtask(() {
          if (_isDisposed || !mounted) return;
          
          setState(() {
            _errorMessage = response.message ?? 'Erro ao carregar treinos';
          });
        });
      }
    } catch (e) {
      print('❌ [DEBUG] Exceção capturada: $e');
      
      Future.microtask(() {
        if (_isDisposed || !mounted) return;
        
        setState(() {
          _errorMessage = 'Erro ao carregar treinos: $e';
        });
      });
    } finally {
      // 🔧 CORREÇÃO: FINALIZAR LOADING DE FORMA SEGURA
      Future.microtask(() {
        if (_isDisposed || !mounted) return;
        
        setState(() {
          _isLoading = false;
        });
      });
      
      print('🏁 [DEBUG] Carregamento finalizado com segurança');
    }
  }

  /// 🔧 CORREÇÃO: Busca em tempo real com verificação de segurança
  void _onSearchChanged() {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      _textoBusca = _searchController.text.toLowerCase();
      _aplicarFiltros();
    });
  }

  /// Aplicar todos os filtros (sem setState direto)
  void _aplicarFiltros() {
    List<TreinoModel> filtrados = List.from(_todosTreinos);

    // Filtro por tipo
    if (_filtroTipo != null && _filtroTipo != 'Todos') {
      filtrados = filtrados.where((treino) => 
        treino.tipoTreino.toLowerCase() == _filtroTipo!.toLowerCase()).toList();
    }

    // Filtro por dificuldade
    if (_filtroDificuldade != null && _filtroDificuldade != 'Todas') {
      filtrados = filtrados.where((treino) => 
        treino.dificuldade?.toLowerCase() == _filtroDificuldade!.toLowerCase()).toList();
    }

    // Filtro por busca
    if (_textoBusca.isNotEmpty) {
      filtrados = filtrados.where((treino) =>
        treino.nomeTreino.toLowerCase().contains(_textoBusca) ||
        treino.tipoTreino.toLowerCase().contains(_textoBusca) ||
        (treino.descricao?.toLowerCase().contains(_textoBusca) ?? false)
      ).toList();
    }

    // 🔧 CORREÇÃO: ATUALIZAR _treinosFiltrados SEM setState (será chamado pelo caller)
    _treinosFiltrados = filtrados;
  }

  /// 🔧 CORREÇÃO: Limpar filtros com verificação de segurança
  void _limparFiltros() {
    if (_isDisposed || !mounted) return;
    
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
    // 🔧 CORREÇÃO: VERIFICAÇÃO DE SEGURANÇA NO BUILD
    if (_isDisposed) {
      return const SizedBox.shrink();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header e busca
              _buildHeader(),
              
              // Filtros
              _buildFiltros(),
              
              // Lista de treinos
              Expanded(
                child: _buildConteudo(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_isDisposed || !mounted) return;
          
          print('🚀 [DEBUG] Navegando para criar treino...');
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Navegação para criar treino será implementada!'),
                backgroundColor: Color(0xFFFF8C42),
              ),
            );
          } catch (e) {
            print('❌ [DEBUG] Erro ao navegar: $e');
          }
        },
        backgroundColor: const Color(0xFFFF8C42),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Novo Treino',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  /// Header com busca (sem alterações significativas)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
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
              const Text(
                'BIBLIOTECA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
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
              ? '0 treinos disponíveis'
              : '${_treinosFiltrados.length} treinos disponíveis',
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 🔧 CORREÇÃO: Campo de busca com verificação de disposed
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
                        if (_isDisposed || !mounted) return;
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

  /// Filtros horizontais (sem alterações significativas)
  Widget _buildFiltros() {
    final temFiltros = _filtroTipo != null || 
                      _filtroDificuldade != null || 
                      _textoBusca.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Chips de filtro
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtro por tipo
                _buildChipFiltro(
                  'Tipo',
                  _filtroTipo ?? 'Todos',
                  Icons.fitness_center,
                  () => _mostrarFiltroTipo(),
                ),
                
                const SizedBox(width: 12),
                
                // Filtro por dificuldade
                _buildChipFiltro(
                  'Dificuldade',
                  _filtroDificuldade ?? 'Todas',
                  Icons.trending_up,
                  () => _mostrarFiltroDificuldade(),
                ),
                
                const SizedBox(width: 12),
                
                // Limpar filtros
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
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Chip de filtro (sem alterações)
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  /// 🔧 CORREÇÃO: Conteúdo principal com verificações de segurança
  Widget _buildConteudo() {
    print('🖼️ [DEBUG] Construindo conteúdo...');
    print('🖼️ [DEBUG] isLoading: $_isLoading');
    print('🖼️ [DEBUG] treinos filtrados: ${_treinosFiltrados.length}');
    print('🖼️ [DEBUG] erro: $_errorMessage');
    
    if (_isLoading) {
      print('🖼️ [DEBUG] Exibindo loading...');
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
      print('🖼️ [DEBUG] Exibindo erro: $_errorMessage');
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
                  if (_isDisposed || !mounted) return;
                  _carregarTreinosSeguro();
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
      print('🖼️ [DEBUG] Lista vazia - exibindo empty state');
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
                onPressed: temFiltros ? _limparFiltros : () {
                  if (_isDisposed || !mounted) return;
                  // TODO: criar treino
                },
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
    
    print('🖼️ [DEBUG] Exibindo lista com ${_treinosFiltrados.length} treinos');
    return RefreshIndicator(
      onRefresh: () async {
        if (_isDisposed || !mounted) return;
        await _carregarTreinosSeguro();
      },
      color: const Color(0xFF4ECDC4),
      backgroundColor: const Color(0xFF2A2D3A),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _treinosFiltrados.length,
        itemBuilder: (context, index) {
          if (_isDisposed || !mounted) {
            return const SizedBox.shrink();
          }
          final treino = _treinosFiltrados[index];
          print('🖼️ [DEBUG] Construindo card para treino: ${treino.nomeTreino}');
          return _buildCardTreino(treino);
        },
      ),
    );
  }

  /// Card do treino (mantendo toda funcionalidade existente)
  Widget _buildCardTreino(TreinoModel treino) {
    print('🎴 [DEBUG] Construindo card para: ${treino.nomeTreino} (ID: ${treino.id})');
    
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
          onTap: () {
            if (_isDisposed || !mounted) return;
            print('🎴 [DEBUG] Card clicado: ${treino.nomeTreino}');
            // TODO: navegar para detalhes
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do card com menu de ações
                Row(
                  children: [
                    // Ícone do treino
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getCorTreino(treino.dificuldade).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconeTreino(treino.tipoTreino),
                        color: _getCorTreino(treino.dificuldade),
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Nome e tipo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          const SizedBox(height: 4),
                          Text(
                            treino.tipoTreino,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Badge de dificuldade
                    Container(
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
                  ],
                ),
                
                // Descrição
                if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    treino.descricao!,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Info e ações
                Row(
                  children: [
                    // Estatísticas
                    Expanded(
                      child: Row(
                        children: [
                          _buildInfoChip(
                            Icons.fitness_center,
                            '${treino.totalExercicios ?? 0} ex',
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.schedule,
                            treino.duracaoFormatada ?? '0 min',
                          ),
                        ],
                      ),
                    ),
                    
                    // 🔧 CORREÇÃO: Botão de iniciar com verificação de disposed
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (_isDisposed || !mounted) return;
                            print('🎴 [DEBUG] Botão iniciar clicado para: ${treino.nomeTreino}');
                            // TODO: iniciar treino
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Iniciar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
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

  /// Chip de informação (sem alterações)
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF9CA3AF),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔧 CORREÇÃO: Mostrar filtro de tipo com verificação
  void _mostrarFiltroTipo() {
    if (_isDisposed || !mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetFiltro(
        'Filtrar por Tipo',
        _tiposTreino,
        _filtroTipo ?? 'Todos',
        (valor) {
          if (_isDisposed || !mounted) return;
          setState(() {
            _filtroTipo = valor == 'Todos' ? null : valor;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  /// 🔧 CORREÇÃO: Mostrar filtro de dificuldade com verificação
  void _mostrarFiltroDificuldade() {
    if (_isDisposed || !mounted) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetFiltro(
        'Filtrar por Dificuldade',
        _dificuldades,
        _filtroDificuldade ?? 'Todas',
        (valor) {
          if (_isDisposed || !mounted) return;
          setState(() {
            _filtroDificuldade = valor == 'Todas' ? null : valor;
            _aplicarFiltros();
          });
        },
      ),
    );
  }

  /// Bottom sheet de filtro (sem alterações significativas)
  Widget _buildBottomSheetFiltro(
    String titulo,
    List<String> opcoes,
    String valorAtual,
    Function(String) onSelected,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7280),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Título
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
          
          // Opções
          ListView.builder(
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
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Obter cor do treino baseada na dificuldade (sem alterações)
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

  /// Obter ícone do treino baseado no tipo (sem alterações)
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

  /// Obter texto da dificuldade formatado (sem alterações)
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