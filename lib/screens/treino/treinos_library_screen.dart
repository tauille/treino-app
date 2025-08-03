import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/theme/sport_theme.dart';
import 'detalhes_treino_screen.dart';
import 'criar_treino_screen.dart';

/// 💪 Biblioteca de Treinos - Tela moderna para gerenciar treinos
class TreinosLibraryScreen extends StatefulWidget {
  const TreinosLibraryScreen({super.key});

  @override
  State<TreinosLibraryScreen> createState() => _TreinosLibraryScreenState();
}

class _TreinosLibraryScreenState extends State<TreinosLibraryScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  
  String? _categoriaAtual;
  String? _dificuldadeAtual;
  String _buscaAtual = '';
  bool _isLoading = true;

  // Categorias de treino
  final List<WorkoutCategory> _categorias = [
    WorkoutCategory(
      id: null,
      name: 'Todos',
      icon: Icons.apps_rounded,
      color: SportColors.primary,
    ),
    WorkoutCategory(
      id: 'musculacao',
      name: 'Musculação',
      icon: Icons.fitness_center_rounded,
      color: SportColors.musculationColor,
    ),
    WorkoutCategory(
      id: 'cardio',
      name: 'Cardio',
      icon: Icons.directions_run_rounded,
      color: SportColors.cardioColor,
    ),
    WorkoutCategory(
      id: 'funcional',
      name: 'Funcional',
      icon: Icons.accessibility_new_rounded,
      color: SportColors.functionalColor,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _carregarTreinos();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
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
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  /// Carregar treinos
  Future<void> _carregarTreinos() async {
    setState(() => _isLoading = true);
    
    final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
    await treinoProvider.listarTreinos(
      busca: _buscaAtual.isEmpty ? null : _buscaAtual,
      dificuldade: _dificuldadeAtual,
      tipoTreino: _categoriaAtual,
    );
    
    setState(() => _isLoading = false);
  }

  /// Aplicar filtro de categoria
  void _aplicarCategoria(String? categoria) {
    HapticFeedback.lightImpact();
    setState(() {
      _categoriaAtual = categoria;
    });
    _carregarTreinos();
  }

  /// Aplicar filtro de dificuldade
  void _aplicarDificuldade(String? dificuldade) {
    HapticFeedback.lightImpact();
    setState(() {
      _dificuldadeAtual = dificuldade;
    });
    _carregarTreinos();
  }

  /// Buscar treinos
  void _buscarTreinos(String termo) {
    setState(() {
      _buscaAtual = termo;
    });
    
    // Debounce de 500ms
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_buscaAtual == termo && mounted) {
        _carregarTreinos();
      }
    });
  }

  /// Navegar para detalhes
  void _verDetalhes(TreinoModel treino) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTreinoScreen(treino: treino),
      ),
    );
  }

  /// Navegar para criar treino
  void _criarNovoTreino() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((_) => _carregarTreinos());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // HEADER
              _buildHeader(),
              
              // SEARCH BAR
              _buildSearchBar(),
              
              // CATEGORIAS
              _buildCategorias(),
              
              // FILTROS DE DIFICULDADE
              _buildFiltrosDificuldade(),
              
              // LISTA DE TREINOS
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _buildTreinosList(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarNovoTreino,
        backgroundColor: SportColors.primary,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  /// Header da tela
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biblioteca',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seus treinos personalizados',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: SportColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Contador de treinos
          Consumer<TreinoProvider>(
            builder: (context, provider, child) {
              return ModernSportWidgets.statusBadge(
                text: '${provider.treinos.length} treinos',
                color: SportColors.primary,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Barra de busca
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SportColors.grey200,
          width: 1,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _buscarTreinos,
        decoration: InputDecoration(
          hintText: 'Buscar treinos...',
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: SportColors.textTertiary,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _buscarTreinos('');
                  },
                  icon: const Icon(
                    Icons.clear_rounded,
                    color: SportColors.textTertiary,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Categorias horizontais
  Widget _buildCategorias() {
    return Container(
      height: 120,
      margin: const EdgeInsets.only(top: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categorias.length,
        itemBuilder: (context, index) {
          final categoria = _categorias[index];
          final isSelected = _categoriaAtual == categoria.id;
          
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => _aplicarCategoria(categoria.id),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: [categoria.color, categoria.color.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : SportColors.grey200,
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: categoria.color.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ] : null,
                    ),
                    child: Icon(
                      categoria.icon,
                      color: isSelected ? Colors.white : categoria.color,
                      size: 28,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    categoria.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected ? categoria.color : SportColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Filtros de dificuldade
  Widget _buildFiltrosDificuldade() {
    const dificuldades = [
      {'label': 'Todos', 'value': null},
      {'label': 'Iniciante', 'value': 'iniciante'},
      {'label': 'Intermediário', 'value': 'intermediario'},
      {'label': 'Avançado', 'value': 'avancado'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 24),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: dificuldades.length,
        itemBuilder: (context, index) {
          final dificuldade = dificuldades[index];
          final isSelected = _dificuldadeAtual == dificuldade['value'];
          
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(dificuldade['label'] as String),
              selected: isSelected,
              onSelected: (_) => _aplicarDificuldade(dificuldade['value'] as String?),
              backgroundColor: Colors.white,
              selectedColor: SportColors.getDifficultyColor(dificuldade['value'] as String?).withOpacity(0.1),
              side: BorderSide(
                color: isSelected 
                    ? SportColors.getDifficultyColor(dificuldade['value'] as String?)
                    : SportColors.grey200,
                width: 1,
              ),
              labelStyle: TextStyle(
                color: isSelected 
                    ? SportColors.getDifficultyColor(dificuldade['value'] as String?)
                    : SportColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Lista de treinos
  Widget _buildTreinosList() {
    return Consumer<TreinoProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return _buildErrorState(provider.error!);
        }

        final treinos = provider.treinos;

        if (treinos.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _carregarTreinos,
          color: SportColors.primary,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              top: 24,
              bottom: 100, // Espaço para o FAB
            ),
            itemCount: treinos.length,
            itemBuilder: (context, index) {
              return _buildTreinoCard(treinos[index]);
            },
          ),
        );
      },
    );
  }

  /// Card do treino
  Widget _buildTreinoCard(TreinoModel treino) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: SportColors.grey200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _verDetalhes(treino),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do card
                Row(
                  children: [
                    // Ícone do tipo de treino
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: SportColors.getWorkoutTypeGradient(treino.tipoTreino),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: SportColors.getWorkoutTypeColor(treino.tipoTreino).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getIconeDoTipoTreino(treino.tipoTreino),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Informações do treino
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            treino.nomeTreino,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: SportColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            treino.tipoTreino,
                            style: const TextStyle(
                              fontSize: 14,
                              color: SportColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Badge de dificuldade
                    ModernSportWidgets.statusBadge(
                      text: treino.dificuldadeTextoSeguro,
                      color: treino.corDificuldadeColor,
                    ),
                  ],
                ),
                
                // Descrição (se houver)
                if (treino.descricao != null && treino.descricao!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    treino.descricao!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: SportColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Estatísticas do treino
                Row(
                  children: [
                    _buildEstatistica(
                      Icons.fitness_center_rounded,
                      '${treino.totalExerciciosCalculado}',
                      'Exercícios',
                      SportColors.musculationColor,
                    ),
                    
                    const SizedBox(width: 24),
                    
                    _buildEstatistica(
                      Icons.timer_rounded,
                      treino.duracaoFormatadaSegura,
                      'Duração',
                      SportColors.primary,
                    ),
                    
                    const SizedBox(width: 24),
                    
                    _buildEstatistica(
                      Icons.trending_up_rounded,
                      treino.gruposMuscularesSeguro,
                      'Grupos',
                      SportColors.secondary,
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

  /// Widget de estatística
  Widget _buildEstatistica(IconData icon, String valor, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
        
        const SizedBox(width: 8),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: SportColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: SportColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Ícone baseado no tipo de treino
  IconData _getIconeDoTipoTreino(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'musculação':
      case 'musculacao':
        return Icons.fitness_center_rounded;
      case 'cardio':
      case 'cardiovascular':
        return Icons.directions_run_rounded;
      case 'funcional':
        return Icons.accessibility_new_rounded;
      case 'yoga':
        return Icons.self_improvement_rounded;
      case 'pilates':
        return Icons.sports_gymnastics_rounded;
      default:
        return Icons.sports_rounded;
    }
  }

  /// Estado de loading
  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: SportColors.primary,
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: SportColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Erro ao carregar treinos',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: SportColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: SportColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _carregarTreinos,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState() {
    final isFiltered = _categoriaAtual != null || 
                      _dificuldadeAtual != null || 
                      _buscaAtual.isNotEmpty;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: SportColors.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: SportColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              isFiltered 
                  ? 'Nenhum treino encontrado'
                  : 'Nenhum treino criado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              isFiltered
                  ? 'Tente ajustar os filtros ou criar um novo treino'
                  : 'Crie seu primeiro treino personalizado',
              style: const TextStyle(
                fontSize: 16,
                color: SportColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            ElevatedButton.icon(
              onPressed: _criarNovoTreino,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(
                isFiltered
                    ? 'Criar Novo Treino'
                    : 'Criar Primeiro Treino',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modelo para categorias de treino
class WorkoutCategory {
  final String? id;
  final String name;
  final IconData icon;
  final Color color;

  const WorkoutCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}