import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../providers/auth_provider_google.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/theme/sport_theme.dart';
import '../../core/routes/app_routes.dart';
import '../treino/criar_treino_screen.dart';

// Extensões para métodos seguros
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

/// Home Dashboard - Versão otimizada sem redundâncias
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  List<TreinoModel> _treinos = [];
  bool _isLoading = false;
  String _saudacao = '';
  
  // Controle de visibilidade e refresh
  bool _isVisible = false;
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupSaudacao();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosComCache();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
    _slideController.forward();
  }

  void _setupSaudacao() {
    final hora = DateTime.now().hour;
    if (hora < 12) {
      _saudacao = 'Bom dia';
    } else if (hora < 18) {
      _saudacao = 'Boa tarde';
    } else {
      _saudacao = 'Boa noite';
    }
  }

  /// Detectar quando a tela fica visível
  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;
    
    if (_isVisible && !wasVisible) {
      _verificarERecarregar();
    }
  }

  /// Verificar se precisa recarregar dados
  void _verificarERecarregar() {
    final agora = DateTime.now();
    final tempoSinceLastRefresh = _lastRefresh != null 
        ? agora.difference(_lastRefresh!)
        : const Duration(hours: 1);
    
    if (tempoSinceLastRefresh.inSeconds > 10) {
      _carregarDadosComCache();
    }
  }

  /// Carregar dados com cache inteligente
  Future<void> _carregarDadosComCache() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    
    try {
      final treinoProvider = context.read<TreinoProvider>();
      final resultado = await treinoProvider.listarTreinos(forceRefresh: true);
      
      if (mounted && resultado.success && resultado.data != null) {
        final todosTreinos = resultado.data as List<TreinoModel>;
        
        setState(() {
          _treinos = todosTreinos;
          _lastRefresh = DateTime.now();
        });
      }
    } catch (e) {
      // Erro silencioso
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: const Key('home-dashboard-screen'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: RefreshIndicator(
          onRefresh: _carregarDadosComCache,
          color: const Color(0xFF6366F1),
          backgroundColor: Colors.white,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  _buildModernAppBar(),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 4),
                          _buildGreetingSection(),
                          const SizedBox(height: 20),
                          _buildQuickStats(),
                          const SizedBox(height: 20),
                          _buildMainActions(),
                          const SizedBox(height: 20),
                          _buildNextWorkoutSection(),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// App Bar moderno e limpo
  Widget _buildModernAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Treino App',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (_lastRefresh != null)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Atualizado há ${DateTime.now().difference(_lastRefresh!).inMinutes}min',
                          style: TextStyle(
                            fontSize: 9,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 40,
                height: 40,
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
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: const Color(0xFF64748B),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seção de saudação moderna
  Widget _buildGreetingSection() {
    return Consumer<AuthProviderGoogle>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        final firstName = user?.firstName ?? 'Usuário';
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$_saudacao, $firstName!',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pronto para seu próximo treino?',
                        style: TextStyle(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFF8B5CF6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Stats rápidos modernos
  Widget _buildQuickStats() {
    final totalTreinos = _treinos.length;
    final totalExercicios = _treinos.fold<int>(
      0, 
      (sum, treino) => sum + (treino.totalExercicios ?? treino.exercicios.length),
    );
    final totalMinutos = _treinos.fold<int>(
      0,
      (sum, treino) => sum + (treino.duracaoEstimada ?? 0),
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Resumo Semanal',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14),
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Treinos',
                  value: '$totalTreinos',
                  subtitle: 'Criados',
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCard(
                  title: 'Exercícios',
                  value: '$totalExercicios',
                  subtitle: 'Total',
                  icon: Icons.format_list_numbered_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _buildStatCard(
                  title: 'Minutos',
                  value: '$totalMinutos',
                  subtitle: 'Estimados',
                  icon: Icons.timer_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card de estatística individual
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 14,
            ),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 8,
                color: const Color(0xFF94A3B8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Ações principais - SEM BIBLIOTECA REDUNDANTE
  Widget _buildMainActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // APENAS UM CARD - CRIAR TREINO (sem biblioteca redundante)
        _buildActionCard(
          title: 'Criar Treino',
          subtitle: 'Monte seu treino personalizado',
          icon: Icons.add_rounded,
          color: const Color(0xFF6366F1),
          onTap: _criarNovoTreino,
        ),
      ],
    );
  }

  /// Card de ação moderno - versão otimizada
  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 100),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Seção próximo treino moderna
  Widget _buildNextWorkoutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Próximo Treino',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _treinos.isNotEmpty 
            ? _buildNextWorkoutCard()
            : _buildEmptyWorkoutState(),
      ],
    );
  }

  /// Card do próximo treino
  Widget _buildNextWorkoutCard() {
    final treino = _treinos.first;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      treino.nomeTreino,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      treino.tipoTreino,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  treino.dificuldadeTextoSeguro,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          Row(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: 14,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '${treino.exercicios.isNotEmpty ? treino.exercicios.length : (treino.totalExercicios ?? 0)} exercícios',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.timer_rounded,
                size: 14,
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  treino.duracaoFormatadaSegura,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () => _iniciarTreino(treino),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.play_arrow_rounded, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Iniciar Treino',
                    style: TextStyle(
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
    );
  }

  /// Estado vazio moderno
  Widget _buildEmptyWorkoutState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 20,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Nenhum treino criado',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crie seu primeiro treino personalizado para começar',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: _criarNovoTreino,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Criar Primeiro Treino',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Métodos de navegação
  void _criarNovoTreino() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((_) => _carregarDadosComCache());
  }

  void _iniciarTreino(TreinoModel treino) {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(
      context,
      AppRoutes.treinoPreparacao,
      arguments: treino,
    );
  }
}