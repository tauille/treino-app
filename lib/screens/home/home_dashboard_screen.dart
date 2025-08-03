import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider_google.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/theme/sport_theme.dart';
import '../../core/routes/app_routes.dart';
import '../treino/criar_treino_screen.dart';
import '../treino/treino_preparacao_screen.dart';

/// 🏠 Dashboard principal - Tela inicial moderna e funcional
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  List<TreinoModel> _treinosDisponiveis = [];
  bool _isLoadingTreinos = false;
  TreinoModel? _treinoSugerido;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _carregarDadosDashboard();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Configurar animações
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

  /// Carregar dados do dashboard
  Future<void> _carregarDadosDashboard() async {
    setState(() => _isLoadingTreinos = true);
    
    final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
    final resultado = await treinoProvider.listarTreinos();
    
    if (resultado.success && resultado.data != null) {
      final treinos = resultado.data as List<TreinoModel>;
      setState(() {
        _treinosDisponiveis = treinos
            .where((treino) => treino.exercicios.isNotEmpty)
            .toList();
        
        // Sugerir um treino aleatório
        if (_treinosDisponiveis.isNotEmpty) {
          _treinoSugerido = _treinosDisponiveis.first;
        }
      });
    }
    
    setState(() => _isLoadingTreinos = false);
  }

  /// Saudação baseada no horário
  String _getSaudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) return 'Bom dia';
    if (hora < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  /// Ícone baseado no horário
  IconData _getSaudacaoIcon() {
    final hora = DateTime.now().hour;
    if (hora < 12) return Icons.wb_sunny_rounded;
    if (hora < 18) return Icons.wb_sunny_outlined;
    return Icons.nightlight_round;
  }

  /// Iniciar treino específico
  void _iniciarTreino(TreinoModel treino) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }

  /// Mostrar lista de treinos disponíveis
  void _mostrarTreinosDisponiveis() async {
    HapticFeedback.lightImpact();
    
    if (_treinosDisponiveis.isEmpty) {
      _mostrarSnackBar(
        'Nenhum treino disponível. Crie seu primeiro treino!',
        cor: const Color(0xFFFBBF24),
      );
      return;
    }
    
    final treino = await showModalBottomSheet<TreinoModel>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildTreinoBottomSheet(),
    );
    
    if (treino != null) {
      _iniciarTreino(treino);
    }
  }

  /// Navegar para criar treino
  void _criarNovoTreino() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((_) => _carregarDadosDashboard());
  }

  /// Navegar para biblioteca de treinos
  void _abrirBibliotecaTreinos() {
    HapticFeedback.lightImpact();
    // A navegação será feita pelo bottom nav
    DefaultTabController.of(context)?.animateTo(1);
  }

  /// Navegar para meus treinos
  void _abrirMeusTreinos() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, AppRoutes.meusTreinos);
  }

  /// Mostrar snackbar customizada
  void _mostrarSnackBar(String mensagem, {Color? cor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: cor ?? const Color(0xFF22C55E),
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
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _carregarDadosDashboard,
            color: const Color(0xFFFF8C42),
            backgroundColor: const Color(0xFF2A2D3A),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER COM "HOJE"
                  _buildHeader(),
                  
                  const SizedBox(height: 32),
                  
                  // TREINO SUGERIDO OU ESTADO VAZIO
                  _buildTreinoSection(),
                  
                  const SizedBox(height: 40),
                  
                  // PROGRESSO DA SEMANA
                  _buildProgressoSemana(),
                  
                  const SizedBox(height: 40),
                  
                  // AÇÕES RÁPIDAS
                  _buildAcoesRapidas(),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header com "HOJE" e ícone timeline
  Widget _buildHeader() {
    return Consumer<AuthProviderGoogle>(
      builder: (context, authProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                const Text(
                  'HOJE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.timeline,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
          ],
        );
      },
    );
  }

  /// Seção do treino sugerido ou estado vazio
  Widget _buildTreinoSection() {
    if (_treinoSugerido != null) {
      // Se tem treino sugerido, mostrar card do treino
      return _buildTreinoSugerido();
    } else {
      // Se não tem treino, mostrar estado vazio
      return _buildEstadoVazio();
    }
  }

  /// Estado vazio quando não há treinos
  Widget _buildEstadoVazio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF374151),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fitness_center,
              color: Color(0xFF9CA3AF),
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'NENHUM TREINO AGENDADO\nPARA HOJE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1.4,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Toque em "Criar" para iniciar um novo treino',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _criarNovoTreino,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Criar treino',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C42),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Card do treino sugerido (mantendo a lógica original)
  Widget _buildTreinoSugerido() {
    if (_treinoSugerido == null) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8C42), Color(0xFFFF6B6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8C42).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _mostrarTreinosDisponiveis,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _buildTreinoSugeridoContent(),
          ),
        ),
      ),
    );
  }

  /// Conteúdo do treino sugerido (mantendo lógica original)
  Widget _buildTreinoSugeridoContent() {
    if (_treinoSugerido == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'SUGERIDO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Text(
          '🔥 TREINO SUGERIDO',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _treinoSugerido!.nomeTreino,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          _treinoSugerido!.tipoTreino,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            _buildInfoPill(
              '⏱️ ${_treinoSugerido!.duracaoFormatadaSegura}',
            ),
            const SizedBox(width: 12),
            _buildInfoPill(
              '💪 ${_treinoSugerido!.totalExerciciosCalculado} exercícios',
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'INICIAR TREINO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// Pill de informação (mantendo lógica original)
  Widget _buildInfoPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Progresso da semana (adaptado ao novo design)
  Widget _buildProgressoSemana() {
    return Column(
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
            const Text(
              'PROGRESSO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Progresso da semana:',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        _buildProgressGrid(),
      ],
    );
  }

  /// Grid de progresso (igual ao design da imagem)
  Widget _buildProgressGrid() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Primeira linha
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.calendar_today,
                  label: 'Esta semana',
                  value: '3',
                  color: const Color(0xFF6B7280),
                  isTopLeft: true,
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: const Color(0xFF374151),
              ),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.local_fire_department,
                  label: 'Sequência',
                  value: '5 dias',
                  color: const Color(0xFFFF6B6B),
                  isTopRight: true,
                ),
              ),
            ],
          ),
          Container(
            height: 1,
            color: const Color(0xFF374151),
          ),
          // Segunda linha
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.check_circle,
                  label: 'Exercícios',
                  value: '45 completados',
                  color: const Color(0xFF4ECDC4),
                  isBottomLeft: true,
                ),
              ),
              Container(
                width: 1,
                height: 80,
                color: const Color(0xFF374151),
              ),
              Expanded(
                child: _buildProgressItem(
                  icon: Icons.access_time,
                  label: 'Tempo total',
                  value: '2h 15min',
                  color: const Color(0xFF6B7280),
                  isBottomRight: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Item de progresso individual
  Widget _buildProgressItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isTopLeft = false,
    bool isTopRight = false,
    bool isBottomLeft = false,
    bool isBottomRight = false,
  }) {
    BorderRadius borderRadius = BorderRadius.zero;
    
    if (isTopLeft) {
      borderRadius = const BorderRadius.only(topLeft: Radius.circular(16));
    } else if (isTopRight) {
      borderRadius = const BorderRadius.only(topRight: Radius.circular(16));
    } else if (isBottomLeft) {
      borderRadius = const BorderRadius.only(bottomLeft: Radius.circular(16));
    } else if (isBottomRight) {
      borderRadius = const BorderRadius.only(bottomRight: Radius.circular(16));
    }

    return Container(
      decoration: BoxDecoration(borderRadius: borderRadius),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Ações rápidas (adaptado ao novo design)
  Widget _buildAcoesRapidas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD93D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'AÇÕES RÁPIDAS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _buildQuickActionButton(
                icon: Icons.add,
                label: 'Criar\nTreino',
                color: const Color(0xFFFF8C42),
                onTap: _criarNovoTreino,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.library_books,
                label: 'Biblioteca',
                color: const Color(0xFFFF6B6B),
                onTap: _abrirBibliotecaTreinos,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.list_alt,
                label: 'Meus\nTreinos',
                color: const Color(0xFF6B7280),
                onTap: _abrirMeusTreinos,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Botão de ação rápida
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom sheet de treinos (mantendo lógica original, adaptando visual)
  Widget _buildTreinoBottomSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2D3A),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
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
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Escolha um Treino',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _treinosDisponiveis.length,
              itemBuilder: (context, index) {
                final treino = _treinosDisponiveis[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF374151),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF4B5563),
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C42).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: Color(0xFFFF8C42),
                        size: 24,
                      ),
                    ),
                    title: Text(
                      treino.nomeTreino,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      '${treino.exercicios.length} exercícios • ${treino.tipoTreino}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 14,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                    ),
                    onTap: () => Navigator.pop(context, treino),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}