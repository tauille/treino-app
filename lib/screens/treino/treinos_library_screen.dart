import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart'; // ✅ Para detectar quando volta à tela
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/theme/sport_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/treino_service.dart';
import 'criar_treino_screen.dart';
import 'treino_preparacao_screen.dart';
import 'detalhes_treino_screen.dart';

// 🔧 Extensões para métodos seguros
extension TreinoModelExtensions on TreinoModel {
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
}

/// 📚 Biblioteca de Treinos - VERSÃO ANTI-OVERFLOW DEFINITIVA
class TreinosLibraryScreen extends StatefulWidget {
  const TreinosLibraryScreen({super.key});

  @override
  State<TreinosLibraryScreen> createState() => _TreinosLibraryScreenState();
}

class _TreinosLibraryScreenState extends State<TreinosLibraryScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _fabController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<TreinoModel> _todosTreinos = [];
  List<TreinoModel> _treinosFiltrados = [];
  bool _isLoading = false;
  bool _showFilters = false;
  
  // ✅ Controle de visibilidade da tela
  bool _isVisible = false;
  DateTime? _lastRefresh;
  
  // Filtros
  String _filtroTipo = 'Todos';
  String _filtroDificuldade = 'Todos';
  String _textoBusca = '';

  // Opções de filtro
  final List<String> _tiposTreino = ['Todos', 'Musculação', 'Cardio', 'Funcional', 'Yoga', 'Pilates'];
  final List<String> _dificuldades = ['Todos', 'Iniciante', 'Intermediário', 'Avançado'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupScrollListener();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarTreinosComCache();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuart,
    ));
    
    _animationController.forward();
    _fabController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _fabController.value == 1.0) {
        _fabController.reverse();
      } else if (_scrollController.offset <= 100 && _fabController.value == 0.0) {
        _fabController.forward();
      }
    });
  }

  /// ✅ Detectar quando a tela fica visível
  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;
    
    print('👁 SCREEN: Visibilidade mudou: $wasVisible → $_isVisible');
    
    // Se a tela ficou visível E não estava antes, recarregar
    if (_isVisible && !wasVisible) {
      print('👀 SCREEN: Tela ficou visível - verificando se precisa refresh...');
      _verificarERecarregar();
    }
  }

  /// ✅ Verificar se precisa recarregar dados
  void _verificarERecarregar() {
    final agora = DateTime.now();
    final tempoSinceLastRefresh = _lastRefresh != null 
        ? agora.difference(_lastRefresh!)
        : const Duration(hours: 1);
    
    // Recarregar se passou mais de 5 segundos desde último refresh
    if (tempoSinceLastRefresh.inSeconds > 5) {
      print('⏰ SCREEN: Precisa refresh (${tempoSinceLastRefresh.inSeconds}s desde último)');
      _carregarTreinosComCache();
    } else {
      print('✅ SCREEN: Dados ainda frescos (${tempoSinceLastRefresh.inSeconds}s)');
    }
  }

  /// ✅ Carregar treinos com invalidação de cache inteligente
  Future<void> _carregarTreinosComCache() async {
    if (!mounted) return;
    
    print('🔄 SCREEN: Iniciando carregamento inteligente...');
    setState(() => _isLoading = true);
    
    try {
      final treinoProvider = context.read<TreinoProvider>();
      
      // 🎯 FORÇA REFRESH NO PROVIDER (invalidar cache)
      print('💾 SCREEN: Forçando refresh no provider...');
      final resultado = await treinoProvider.listarTreinos(forceRefresh: true);
      
      print('📊 SCREEN: RESULTADO do provider (forceRefresh=true):');
      print('   • Success: ${resultado.success}');
      print('   • Data: ${resultado.data?.length ?? 0} treinos');
      print('   • Message: ${resultado.message}');
      
      if (mounted && resultado.success && resultado.data != null) {
        setState(() {
          _todosTreinos = resultado.data as List<TreinoModel>;
          _aplicarFiltros();
          _lastRefresh = DateTime.now(); // ✅ Marcar horário do refresh
        });
        
        print('✅ SCREEN: Lista atualizada com ${_todosTreinos.length} treinos');
        for (var treino in _todosTreinos) {
          print('   • ${treino.id}: ${treino.nomeTreino}');
        }
      } else {
        print('❌ SCREEN: Erro no carregamento: ${resultado.message}');
        if (mounted) {
          _mostrarErro('Erro ao carregar treinos: ${resultado.message}');
        }
      }
    } catch (e) {
      print('❌ SCREEN: EXCEÇÃO no carregamento: $e');
      if (mounted) {
        _mostrarErro('Erro inesperado ao carregar treinos: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('🏁 SCREEN: Carregamento finalizado');
      }
    }
  }

  /// ✅ Método original de carregamento para compatibilidade
  Future<void> _carregarTreinos() async {
    return _carregarTreinosComCache();
  }

  void _aplicarFiltros() {
    setState(() {
      _treinosFiltrados = _todosTreinos.where((treino) {
        // Filtro por busca
        final matchBusca = _textoBusca.isEmpty || 
            treino.nomeTreino.toLowerCase().contains(_textoBusca.toLowerCase()) ||
            treino.tipoTreino.toLowerCase().contains(_textoBusca.toLowerCase());
        
        // Filtro por tipo
        final matchTipo = _filtroTipo == 'Todos' || 
            treino.tipoTreino.toLowerCase() == _filtroTipo.toLowerCase();
        
        // Filtro por dificuldade
        final matchDificuldade = _filtroDificuldade == 'Todos' || 
            treino.dificuldadeTextoSeguro == _filtroDificuldade;
        
        return matchBusca && matchTipo && matchDificuldade;
      }).toList();
    });
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// 🎨 Obter cor da dificuldade
  Color _getCorDificuldade(String? dificuldade) {
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

  // 🔧 Método auxiliar para normalizar dificuldade
  String _normalizarDificuldade(String dificuldade) {
    switch (dificuldade.toLowerCase()) {
      case 'iniciante':
        return 'iniciante';
      case 'intermediario':
      case 'intermediário':
        return 'intermediario';
      case 'avancado':
      case 'avançado':
        return 'avancado';
      default:
        return 'iniciante';
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector( // ✅ Detector de visibilidade
      key: const Key('treinos-library-screen'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: RefreshIndicator( // ✅ Pull-to-refresh
          onRefresh: _carregarTreinosComCache,
          color: const Color(0xFF6366F1),
          backgroundColor: Colors.white,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // App Bar com gradiente
                _buildGradientAppBar(),
                
                // Search Bar e Filtros
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Padding(
                          padding: const EdgeInsets.all(16), // 🔥 REDUZIDO: 20 → 16
                          child: Column(
                            mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 12), // 🔥 REDUZIDO: 16 → 12
                              if (_showFilters) _buildFilterChips(),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Loading ou Lista de Treinos
                _isLoading 
                    ? SliverToBoxAdapter(child: _buildLoadingState())
                    : _treinosFiltrados.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : _buildTreinosList(),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  /// App Bar com gradiente moderno - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildGradientAppBar() {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      expandedHeight: 110, // 🔥 REDUZIDO: 120 → 110
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFFA855F7),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          titlePadding: const EdgeInsets.only(left: 16, bottom: 12), // 🔥 REDUZIDO: 20→16, 16→12
          title: LayoutBuilder(
            builder: (context, constraints) {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
                      children: [
                        FittedBox( // 🔥 ANTI-OVERFLOW: FittedBox para título
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Meus Treinos',
                            style: TextStyle(
                              fontSize: 20, // 🔥 REDUZIDO: 22 → 20
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // ✅ Indicador de última atualização
                        if (_lastRefresh != null)
                          FittedBox( // 🔥 ANTI-OVERFLOW
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Atualizado há ${DateTime.now().difference(_lastRefresh!).inMinutes}min',
                              style: TextStyle(
                                fontSize: 8, // 🔥 REDUZIDO: 9 → 8
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 🔥 BOTÕES COMPACTOS
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 32, // 🔥 REDUZIDO: 36 → 32
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() => _showFilters = !_showFilters);
                            HapticFeedback.lightImpact();
                          },
                          icon: AnimatedRotation(
                            turns: _showFilters ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 16, // 🔥 REDUZIDO: 18 → 16
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4), // 🔥 ESPAÇAMENTO MÍNIMO
                      SizedBox(
                        width: 32, // 🔥 REDUZIDO: 36 → 32
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _carregarTreinosComCache();
                          },
                          icon: AnimatedRotation(
                            turns: _isLoading ? 1 : 0,
                            duration: const Duration(milliseconds: 1000),
                            child: Icon(
                              Icons.refresh_rounded,
                              color: Colors.white,
                              size: 16, // 🔥 REDUZIDO: 18 → 16
                              shadows: [
                                Shadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 3,
                                  color: Colors.black.withOpacity(0.3),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Search Bar moderna - 🔥 VERSÃO ANTI-OVERFLOW
  Widget _buildSearchBar() {
    return Container(
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
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _textoBusca = value);
          _aplicarFiltros();
        },
        decoration: InputDecoration(
          hintText: 'Buscar treinos...',
          hintStyle: TextStyle(
            color: const Color(0xFF94A3B8),
            fontSize: 15, // 🔥 REDUZIDO: 16 → 15
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF6366F1),
            size: 22, // 🔥 REDUZIDO: 24 → 22
          ),
          suffixIcon: _textoBusca.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _textoBusca = '');
                    _aplicarFiltros();
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20, // 🔥 REDUZIDO
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, // 🔥 REDUZIDO: 20 → 16
            vertical: 14, // 🔥 REDUZIDO: 16 → 14
          ),
        ),
      ),
    );
  }

  /// Chips de filtro - 🔥 VERSÃO ANTI-OVERFLOW
  Widget _buildFilterChips() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
        children: [
          // Filtro por Tipo
          FittedBox( // 🔥 ANTI-OVERFLOW no título
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Tipo de Treino',
              style: TextStyle(
                fontSize: 15, // 🔥 REDUZIDO: 16 → 15
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 6), // 🔥 REDUZIDO: 8 → 6
          Wrap(
            spacing: 6, // 🔥 REDUZIDO: 8 → 6
            runSpacing: 6, // 🔥 REDUZIDO: 8 → 6
            children: _tiposTreino.map((tipo) {
              final isSelected = _filtroTipo == tipo;
              return FilterChip(
                label: FittedBox( // 🔥 ANTI-OVERFLOW
                  fit: BoxFit.scaleDown,
                  child: Text(tipo),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filtroTipo = tipo);
                  _aplicarFiltros();
                  HapticFeedback.lightImpact();
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF6366F1).withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12, // 🔥 TAMANHO FIXO REDUZIDO
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 🔥 COMPACTO
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12), // 🔥 REDUZIDO: 16 → 12
          
          // Filtro por Dificuldade
          FittedBox( // 🔥 ANTI-OVERFLOW no título
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Dificuldade',
              style: TextStyle(
                fontSize: 15, // 🔥 REDUZIDO: 16 → 15
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 6), // 🔥 REDUZIDO: 8 → 6
          Wrap(
            spacing: 6, // 🔥 REDUZIDO: 8 → 6
            runSpacing: 6, // 🔥 REDUZIDO: 8 → 6
            children: _dificuldades.map((dificuldade) {
              final isSelected = _filtroDificuldade == dificuldade;
              return FilterChip(
                label: FittedBox( // 🔥 ANTI-OVERFLOW
                  fit: BoxFit.scaleDown,
                  child: Text(dificuldade),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _filtroDificuldade = dificuldade);
                  _aplicarFiltros();
                  HapticFeedback.lightImpact();
                },
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12, // 🔥 TAMANHO FIXO REDUZIDO
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFFE2E8F0),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // 🔥 COMPACTO
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Lista de treinos - 🔥 VERSÃO ANTI-OVERFLOW
  Widget _buildTreinosList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // 🔥 REDUZIDO: 20 → 16
      sliver: SliverList.builder(
        itemCount: _treinosFiltrados.length,
        itemBuilder: (context, index) {
          final treino = _treinosFiltrados[index];
          return AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final delay = index * 0.1;
              final animationValue = Curves.easeOutQuart.transform(
                (_animationController.value - delay).clamp(0.0, 1.0),
              );
              
              return Transform.translate(
                offset: Offset(0, 30 * (1 - animationValue)),
                child: Opacity(
                  opacity: animationValue,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12), // 🔥 REDUZIDO: 16 → 12
                    child: _buildTreinoCard(treino),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Card do treino premium - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildTreinoCard(TreinoModel treino) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18), // 🔥 REDUZIDO: 20 → 18
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16, // 🔥 REDUZIDO: 20 → 16
            offset: const Offset(0, 6), // 🔥 REDUZIDO: 8 → 6
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _iniciarTreino(treino),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14), // 🔥 REDUZIDO: 16 → 14
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
              children: [
                // Header do card - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
                        children: [
                          Text(
                            treino.nomeTreino,
                            style: const TextStyle(
                              fontSize: 16, // 🔥 REDUZIDO: 18 → 16
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1, // 🔥 REDUZIDO: 2 → 1
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            treino.tipoTreino,
                            style: const TextStyle(
                              fontSize: 12, // 🔥 REDUZIDO: 13 → 12
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6), // 🔥 REDUZIDO: 8 → 6
                    SizedBox(
                      width: 28, // 🔥 REDUZIDO: 32 → 28
                      height: 28,
                      child: PopupMenuButton<String>(
                        onSelected: (value) => _executarAcaoTreino(value, treino),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10), // 🔥 REDUZIDO: 12 → 10
                        ),
                        padding: EdgeInsets.zero,
                        itemBuilder: (context) => [
                          _buildMenuItem('editar', 'Editar Treino', Icons.edit_rounded),
                          _buildMenuItem('exercicios', 'Editar Exercícios', Icons.fitness_center_rounded),
                          _buildMenuItem('duplicar', 'Duplicar', Icons.copy_rounded),
                          _buildMenuItem('compartilhar', 'Compartilhar', Icons.share_rounded),
                          const PopupMenuDivider(),
                          _buildMenuItem('excluir', 'Excluir', Icons.delete_rounded, isDestructive: true),
                        ],
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.more_vert_rounded,
                            color: Color(0xFF64748B),
                            size: 14, // 🔥 REDUZIDO: 16 → 14
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
                
                // Informações do treino - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
                Wrap( // 🔥 WRAP é melhor que Row para overflow
                  spacing: 6, // 🔥 REDUZIDO: 8 → 6
                  runSpacing: 4,
                  children: [
                    _buildInfoChip(
                      Icons.fitness_center_rounded,
                      '${treino.exercicios.isNotEmpty ? treino.exercicios.length : (treino.totalExercicios ?? 0)} exercícios',
                      const Color(0xFF6366F1),
                    ),
                    _buildInfoChip(
                      Icons.timer_rounded,
                      treino.duracaoFormatadaSegura,
                      const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
                
                const SizedBox(height: 6), // 🔥 REDUZIDO: 8 → 6
                
                // Badge de dificuldade - 🔥 VERSÃO ANTI-OVERFLOW
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // 🔥 REDUZIDO
                    decoration: BoxDecoration(
                      color: _getCorDificuldade(treino.dificuldade).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16), // 🔥 REDUZIDO: 20 → 16
                    ),
                    child: Text(
                      treino.dificuldadeTextoSeguro,
                      style: TextStyle(
                        fontSize: 10, // 🔥 REDUZIDO: 11 → 10
                        fontWeight: FontWeight.w600,
                        color: _getCorDificuldade(treino.dificuldade),
                      ),
                    ),
                  ),
                ),
                
                if (treino.descricao?.isNotEmpty == true) ...[
                  const SizedBox(height: 6), // 🔥 REDUZIDO: 8 → 6
                  Text(
                    treino.descricao!,
                    style: const TextStyle(
                      fontSize: 12, // 🔥 REDUZIDO: 13 → 12
                      color: Color(0xFF64748B),
                      height: 1.2, // 🔥 REDUZIDO: 1.3 → 1.2
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
                
                // Botão de ação principal - 🔥 VERSÃO SEM CORTE DE TEXTO
                SizedBox(
                  width: double.infinity,
                  height: 42, // 🔥 AUMENTADO: 40 → 42 para comportar o texto
                  child: ElevatedButton(
                    onPressed: () => _iniciarTreino(treino),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // 🔥 PADDING ESPECÍFICO
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_rounded, size: 16), // 🔥 AUMENTADO: 14 → 16
                        const SizedBox(width: 6),
                        Flexible( // 🔥 FLEXIBLE para evitar overflow do texto
                          child: Text(
                            'Ver Detalhes',
                            style: TextStyle(
                              fontSize: 13, // 🔥 AUMENTADO: 12 → 13
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Chip de informação - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // 🔥 REDUZIDO
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8), // 🔥 REDUZIDO: 10 → 8
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color), // 🔥 REDUZIDO: 14 → 12
          const SizedBox(width: 3), // 🔥 REDUZIDO: 4 → 3
          Flexible( // 🔥 ANTI-OVERFLOW
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10, // 🔥 REDUZIDO: 11 → 10
                fontWeight: FontWeight.w600,
                color: color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Item do menu popup
  PopupMenuItem<String> _buildMenuItem(
    String value,
    String text,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18, // 🔥 REDUZIDO: 20 → 18
            color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 10), // 🔥 REDUZIDO: 12 → 10
          Flexible( // 🔥 ANTI-OVERFLOW
            child: Text(
              text,
              style: TextStyle(
                color: isDestructive ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                fontWeight: FontWeight.w500,
                fontSize: 14, // 🔥 TAMANHO FIXO
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Estado de loading - 🔥 VERSÃO ANTI-OVERFLOW
  Widget _buildLoadingState() {
    return SizedBox(
      height: 350, // 🔥 REDUZIDO: 400 → 350
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
          children: [
            Container(
              width: 56, // 🔥 REDUZIDO: 60 → 56
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6366F1),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 16), // 🔥 REDUZIDO: 20 → 16
            Text(
              'Carregando treinos...',
              style: TextStyle(
                fontSize: 15, // 🔥 REDUZIDO: 16 → 15
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Estado vazio - 🔥 VERSÃO ANTI-OVERFLOW
  Widget _buildEmptyState() {
    final isFiltered = _textoBusca.isNotEmpty || 
        _filtroTipo != 'Todos' || 
        _filtroDificuldade != 'Todos';
    
    return Padding(
      padding: const EdgeInsets.all(32), // 🔥 REDUZIDO: 40 → 32
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
        children: [
          Container(
            width: 100, // 🔥 REDUZIDO: 120 → 100
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1).withOpacity(0.1),
                  const Color(0xFF8B5CF6).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              isFiltered ? Icons.search_off_rounded : Icons.fitness_center_rounded,
              size: 50, // 🔥 REDUZIDO: 60 → 50
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(height: 20), // 🔥 REDUZIDO: 24 → 20
          FittedBox( // 🔥 ANTI-OVERFLOW no título
            fit: BoxFit.scaleDown,
            child: Text(
              isFiltered ? 'Nenhum treino encontrado' : 'Nenhum treino criado',
              style: const TextStyle(
                fontSize: 22, // 🔥 REDUZIDO: 24 → 22
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
          Text(
            isFiltered 
                ? 'Tente ajustar os filtros ou buscar por outros termos'
                : 'Crie seu primeiro treino personalizado para começar',
            style: const TextStyle(
              fontSize: 14, // 🔥 REDUZIDO: 16 → 14
              color: Color(0xFF64748B),
              height: 1.4, // 🔥 REDUZIDO: 1.5 → 1.4
            ),
            textAlign: TextAlign.center,
            maxLines: 3, // 🔥 ANTI-OVERFLOW
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24), // 🔥 REDUZIDO: 32 → 24
          if (!isFiltered)
            SizedBox(
              height: 42, // 🔥 ALTURA CONSISTENTE
              child: ElevatedButton.icon(
                onPressed: _criarNovoTreino,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // 🔥 REDUZIDO
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14), // 🔥 REDUZIDO: 16 → 14
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.add_rounded, size: 18), // 🔥 REDUZIDO
                label: Text(
                  'Criar Primeiro Treino',
                  style: TextStyle(
                    fontSize: 14, // 🔥 REDUZIDO: 16 → 14
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (isFiltered)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _filtroTipo = 'Todos';
                  _filtroDificuldade = 'Todos';
                  _textoBusca = '';
                  _searchController.clear();
                });
                _aplicarFiltros();
              },
              icon: const Icon(Icons.clear_all_rounded, size: 16), // 🔥 REDUZIDO
              label: Text(
                'Limpar Filtros',
                style: TextStyle(fontSize: 14), // 🔥 REDUZIDO
              ),
            ),
        ],
      ),
    );
  }

  /// Floating Action Button animado
  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabController,
      child: SizedBox(
        height: 44, // 🔥 ALTURA CONSISTENTE
        child: FloatingActionButton.extended(
          onPressed: _criarNovoTreino,
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 6, // 🔥 REDUZIDO: 8 → 6
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // 🔥 REDUZIDO: 16 → 14
          ),
          icon: const Icon(Icons.add_rounded, size: 18), // 🔥 REDUZIDO
          label: Text(
            'Novo Treino',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14, // 🔥 TAMANHO FIXO
            ),
          ),
        ),
      ),
    );
  }

  // ========================
  // 🔧 MÉTODOS DE AÇÃO - CORRIGIDOS COM REFRESH AUTOMÁTICO
  // ========================

  /// ✅ CRIAR NOVO TREINO
  void _criarNovoTreino() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((result) async {
      print('🔄 VOLTOU da tela de criar treino - forçando refresh...');
      
      if (mounted) {
        await _carregarTreinosComCache();
        print('✅ Lista de treinos atualizada após criar/editar');
      }
    });
  }

  /// ✅ INICIAR TREINO
  void _iniciarTreino(TreinoModel treino) {
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTreinoScreen(treino: treino),
      ),
    );
  }

  /// ✅ EXECUTAR AÇÃO TREINO
  void _executarAcaoTreino(String acao, TreinoModel treino) {
    HapticFeedback.lightImpact();
    
    switch (acao) {
      case 'editar':
        _editarTreino(treino);
        break;
      case 'exercicios':
        _editarExercicios(treino);
        break;
      case 'duplicar':
        _duplicarTreino(treino);
        break;
      case 'compartilhar':
        _compartilharTreino(treino);
        break;
      case 'excluir':
        _confirmarExclusao(treino);
        break;
    }
  }

  /// ✅ EDITAR TREINO
  void _editarTreino(TreinoModel treino) {
    HapticFeedback.lightImpact();
    
    print('✏️ Abrindo modal de edição para: ${treino.nomeTreino}');
    
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      builder: (BuildContext context) {
        return _buildEditModal(treino);
      },
    ).then((value) async {
      print('📋 Modal de edição fechado - forçando refresh...');
      
      if (mounted) {
        await _carregarTreinosComCache();
        print('✅ Lista de treinos atualizada após editar');
      }
    });
  }

  /// 📝 Modal de edição básico (implementação simplificada)
  Widget _buildEditModal(TreinoModel treino) {
    // Implementação básica - você pode expandir conforme necessário
    return Container(
      height: MediaQuery.of(context).size.height * 0.6, // 🔥 REDUZIDO: 0.7 → 0.6
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16), // 🔥 REDUZIDO: 20 → 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
          children: [
            Text(
              'Editar ${treino.nomeTreino}',
              style: const TextStyle(
                fontSize: 20, // 🔥 REDUZIDO: 24 → 20
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              maxLines: 2, // 🔥 ANTI-OVERFLOW
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16), // 🔥 REDUZIDO: 20 → 16
            Text(
              'Funcionalidade de edição em desenvolvimento...',
              style: TextStyle(
                fontSize: 14, // 🔥 REDUZIDO: 16 → 14
                color: const Color(0xFF64748B),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 44, // 🔥 REDUZIDO: 48 → 44
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Fechar',
                  style: TextStyle(fontSize: 14), // 🔥 TAMANHO FIXO
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ DUPLICAR TREINO
  void _duplicarTreino(TreinoModel treino) async {
    try {
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded( // 🔥 ANTI-OVERFLOW
                child: Text('Duplicando treino "${treino.nomeTreino}"...'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF3B82F6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );

      final treinoProvider = context.read<TreinoProvider>();
      
      final novoTreino = TreinoModel(
        nomeTreino: '${treino.nomeTreino} (Cópia)',
        tipoTreino: treino.tipoTreino,
        descricao: treino.descricao,
        dificuldade: treino.dificuldade ?? 'iniciante',
        exercicios: [],
      );
      
      final resultado = await treinoProvider.criarTreino(novoTreino);
      
      if (mounted && resultado.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Treino "${treino.nomeTreino}" duplicado com sucesso!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        await _carregarTreinosComCache();
      } else {
        _mostrarErro('Erro ao duplicar treino');
      }
    } catch (e) {
      _mostrarErro('Erro ao duplicar treino: $e');
    }
  }

  /// ✅ EDITAR EXERCÍCIOS
  void _editarExercicios(TreinoModel treino) {
    HapticFeedback.lightImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTreinoScreen(treino: treino),
      ),
    ).then((result) async {
      print('🔄 VOLTOU da tela de exercícios - forçando refresh...');
      
      if (mounted) {
        await _carregarTreinosComCache();
        print('✅ Lista de treinos atualizada após editar exercícios');
      }
    });
  }

  void _compartilharTreino(TreinoModel treino) {
    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Compartilhamento do treino "${treino.nomeTreino}" em desenvolvimento'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF3B82F6),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _confirmarExclusao(TreinoModel treino) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36, // 🔥 REDUZIDO: 40 → 36
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFEF4444),
                size: 20, // 🔥 REDUZIDO: 24 → 20
              ),
            ),
            const SizedBox(width: 10), // 🔥 REDUZIDO: 12 → 10
            Expanded(
              child: Text(
                'Excluir Treino',
                style: TextStyle(
                  color: const Color(0xFF0F172A),
                  fontSize: 18, // 🔥 REDUZIDO: 20 → 18
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
                  fontSize: 14, // 🔥 REDUZIDO: 16 → 14
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
            const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
            Container(
              padding: const EdgeInsets.all(10), // 🔥 REDUZIDO: 12 → 10
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: const Color(0xFFEF4444),
                    size: 18, // 🔥 REDUZIDO: 20 → 18
                  ),
                  const SizedBox(width: 6), // 🔥 REDUZIDO: 8 → 6
                  Expanded(
                    child: Text(
                      'Esta ação não pode ser desfeita',
                      style: TextStyle(
                        color: const Color(0xFFEF4444),
                        fontSize: 12, // 🔥 REDUZIDO: 14 → 12
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                fontSize: 14, // 🔥 TAMANHO FIXO
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _excluirTreino(treino);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), // 🔥 REDUZIDO
            ),
            child: Text(
              'Excluir',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14, // 🔥 TAMANHO FIXO
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ EXCLUIR TREINO
  void _excluirTreino(TreinoModel treino) async {
    try {
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded( // 🔥 ANTI-OVERFLOW
                child: Text('Excluindo treino "${treino.nomeTreino}"...'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );

      final result = await TreinoService.deletarTreino(treino.id!);
      
      if (mounted && result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Treino "${treino.nomeTreino}" excluído com sucesso!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        
        await _carregarTreinosComCache();
      } else {
        _mostrarErro(result.message ?? 'Erro ao excluir treino');
      }
    } catch (e) {
      _mostrarErro('Erro ao excluir treino: $e');
    }
  }
}