import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../providers/treino_provider.dart';
import '../../providers/auth_provider_google.dart';
import '../../models/treino_model.dart';
import 'detalhes_treino_screen.dart';
import 'criar_treino_screen.dart';

/// Tela para visualizar todos os treinos do usuário
class MeusTreinosScreen extends StatefulWidget {
  const MeusTreinosScreen({super.key});

  @override
  State<MeusTreinosScreen> createState() => _MeusTreinosScreenState();
}

class _MeusTreinosScreenState extends State<MeusTreinosScreen> 
    with TickerProviderStateMixin {
  
  // ===== CONTROLLERS =====
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _searchController = TextEditingController();
  
  // ===== ESTADO =====
  String? _filtroAtual;
  String _buscaAtual = '';
  bool _isLoading = true;

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
    final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
    
    setState(() => _isLoading = true);
    
    // ===== CORREÇÃO: USAR O MÉTODO CORRETO =====
    await treinoProvider.listarTreinos(
      busca: _buscaAtual.isEmpty ? null : _buscaAtual,
      dificuldade: _filtroAtual,
    );
    
    setState(() => _isLoading = false);
  }

  /// Aplicar filtro de dificuldade
  void _aplicarFiltro(String? filtro) {
    setState(() {
      _filtroAtual = filtro;
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalhesTreinoScreen(treino: treino),
      ),
    );
  }

  /// Navegar para criar treino
  void _criarNovoTreino() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((_) {
      // Recarregar lista após criar treino
      _carregarTreinos();
    });
  }

  /// Widget da barra de busca
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _buscarTreinos,
        decoration: InputDecoration(
          hintText: 'Buscar treinos...',
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF667eea),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    _buscarTreinos('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  /// Widget dos filtros
  Widget _buildFiltros() {
    const filtros = [
      {'label': 'Todos', 'value': null},
      {'label': 'Iniciante', 'value': 'iniciante'},
      {'label': 'Intermediário', 'value': 'intermediario'},
      {'label': 'Avançado', 'value': 'avancado'},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filtros.length,
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final isSelected = _filtroAtual == filtro['value'];
          
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filtro['label'] as String),
              selected: isSelected,
              onSelected: (_) => _aplicarFiltro(filtro['value'] as String?),
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF667eea),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected 
                      ? const Color(0xFF667eea)
                      : Colors.grey.shade300,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Widget do card do treino
  Widget _buildTreinoCard(TreinoModel treino) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        child: InkWell(
          onTap: () => _verDetalhes(treino),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do card
                Row(
                  children: [
                    // Ícone do treino
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        // ===== CORREÇÃO: USAR corDificuldadeColor =====
                        color: treino.corDificuldadeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconeDoTipoTreino(treino.tipoTreino),
                        // ===== CORREÇÃO: USAR corDificuldadeColor =====
                        color: treino.corDificuldadeColor,
                        size: 24,
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
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            treino.tipoTreino,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Badge de dificuldade
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // ===== CORREÇÃO: USAR corDificuldadeColor =====
                        color: treino.corDificuldadeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          // ===== CORREÇÃO: USAR corDificuldadeColor =====
                          color: treino.corDificuldadeColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        // ===== CORREÇÃO: USAR dificuldadeTextoSeguro =====
                        treino.dificuldadeTextoSeguro,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          // ===== CORREÇÃO: USAR corDificuldadeColor =====
                          color: treino.corDificuldadeColor,
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
                      color: Colors.grey[700],
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
                      Icons.fitness_center,
                      '${treino.totalExerciciosCalculado}',
                      'Exercícios',
                    ),
                    const SizedBox(width: 24),
                    _buildEstatistica(
                      Icons.timer,
                      // ===== CORREÇÃO: USAR duracaoFormatadaSegura =====
                      treino.duracaoFormatadaSegura,
                      'Duração',
                    ),
                    const SizedBox(width: 24),
                    _buildEstatistica(
                      Icons.trending_up,
                      // ===== CORREÇÃO: USAR gruposMuscularesSeguro =====
                      treino.gruposMuscularesSeguro,
                      'Músculos',
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
  Widget _buildEstatistica(IconData icon, String valor, String label) {
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
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
        return Icons.fitness_center;
      case 'cardio':
      case 'cardiovascular':
        return Icons.directions_run;
      case 'funcional':
        return Icons.accessibility_new;
      case 'yoga':
        return Icons.self_improvement;
      case 'pilates':
        return Icons.sports_gymnastics;
      default:
        return Icons.sports;
    }
  }

  /// Widget de estado vazio
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF667eea).withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.fitness_center,
              size: 60,
              color: Color(0xFF667eea),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Nenhum treino encontrado',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            _filtroAtual != null || _buscaAtual.isNotEmpty
                ? 'Tente ajustar os filtros ou criar um novo treino'
                : 'Crie seu primeiro treino personalizado',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 32),
          
          ElevatedButton.icon(
            onPressed: _criarNovoTreino,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Criar Primeiro Treino',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Meus Treinos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _criarNovoTreino,
            icon: const Icon(
              Icons.add,
              color: Color(0xFF667eea),
            ),
            tooltip: 'Criar Treino',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Barra de busca
            _buildSearchBar(),
            
            // Filtros
            _buildFiltros(),
            
            const SizedBox(height: 16),
            
            // Lista de treinos
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: SpinKitFadingCircle(
                        color: Color(0xFF667eea),
                        size: 50.0,
                      ),
                    )
                  : Consumer<TreinoProvider>(
                      builder: (context, treinoProvider, child) {
                        if (treinoProvider.isLoading) {
                          return const Center(
                            child: SpinKitFadingCircle(
                              color: Color(0xFF667eea),
                              size: 50.0,
                            ),
                          );
                        }

                        // ===== CORREÇÃO: USAR error AO INVÉS DE hasError =====
                        if (treinoProvider.error != null) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Erro ao carregar treinos',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  // ===== CORREÇÃO: USAR error AO INVÉS DE errorMessage =====
                                  treinoProvider.error ?? 'Erro desconhecido',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _carregarTreinos,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF667eea),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Tentar Novamente'),
                                ),
                              ],
                            ),
                          );
                        }

                        final treinos = treinoProvider.treinos;

                        if (treinos.isEmpty) {
                          return _buildEmptyState();
                        }

                        return RefreshIndicator(
                          onRefresh: _carregarTreinos,
                          color: const Color(0xFF667eea),
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: treinos.length,
                            itemBuilder: (context, index) {
                              return _buildTreinoCard(treinos[index]);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _criarNovoTreino,
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        tooltip: 'Criar Novo Treino',
        child: const Icon(Icons.add),
      ),
    );
  }
}