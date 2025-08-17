import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // ✅ Para kDebugMode
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart'; // ✅ Para auto-refresh
import '../../providers/auth_provider_google.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../core/theme/sport_theme.dart';
import '../../core/routes/app_routes.dart';
import '../treino/criar_treino_screen.dart';
import '../treino/treino_preparacao_screen.dart';
import '../main_navigation_screen.dart';

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

/// 🎨 Home Dashboard - VERSÃO CORRIGIDA ANTI-OVERFLOW DEFINITIVA
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
  
  // ✅ Controle de visibilidade e refresh
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

  /// ✅ Detectar quando a tela fica visível
  void _onVisibilityChanged(VisibilityInfo info) {
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;
    
    print('👁 HOME: Visibilidade mudou: $wasVisible → $_isVisible');
    
    // Se a tela ficou visível E não estava antes, verificar refresh
    if (_isVisible && !wasVisible) {
      print('👀 HOME: Tela ficou visível - verificando se precisa refresh...');
      _verificarERecarregar();
    }
  }

  /// ✅ Verificar se precisa recarregar dados
  void _verificarERecarregar() {
    final agora = DateTime.now();
    final tempoSinceLastRefresh = _lastRefresh != null 
        ? agora.difference(_lastRefresh!)
        : const Duration(hours: 1);
    
    // Recarregar se passou mais de 10 segundos desde último refresh
    if (tempoSinceLastRefresh.inSeconds > 10) {
      print('⏰ HOME: Precisa refresh (${tempoSinceLastRefresh.inSeconds}s desde último)');
      _carregarDadosComCache();
    } else {
      print('✅ HOME: Dados ainda frescos (${tempoSinceLastRefresh.inSeconds}s)');
    }
  }

  /// ✅ Carregar dados com cache inteligente
  Future<void> _carregarDadosComCache() async {
    if (!mounted) return;
    
    print('🔄 HOME: Iniciando carregamento inteligente...');
    setState(() => _isLoading = true);
    
    try {
      final treinoProvider = context.read<TreinoProvider>();
      
      // 🎯 FORÇA REFRESH NO PROVIDER
      print('💾 HOME: Forçando refresh no provider...');
      final resultado = await treinoProvider.listarTreinos(forceRefresh: true);
      
      if (mounted && resultado.success && resultado.data != null) {
        final todosTreinos = resultado.data as List<TreinoModel>;
        
        print('📊 HOME: Total de treinos recebidos: ${todosTreinos.length}');
        for (var treino in todosTreinos) {
          print('📋 HOME: Treino: ${treino.nomeTreino}');
          print('   - Exercícios: ${treino.exercicios.length}');
          print('   - Total exercícios (API): ${treino.totalExercicios ?? 'null'}');
        }
        
        setState(() {
          _treinos = todosTreinos;
          _lastRefresh = DateTime.now(); // ✅ Marcar horário do refresh
        });
        
        print('✅ HOME: Treinos carregados para exibição: ${_treinos.length}');
      }
    } catch (e) {
      print('❌ HOME: Erro ao carregar treinos: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('🏁 HOME: Carregamento finalizado');
      }
    }
  }

  /// ✅ Método original para compatibilidade
  Future<void> _carregarDados() async {
    return _carregarDadosComCache();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector( // ✅ Detector de visibilidade
      key: const Key('home-dashboard-screen'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: RefreshIndicator( // ✅ Pull-to-refresh
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
                  // App Bar moderno
                  _buildModernAppBar(),
                  
                  // Conteúdo principal
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14), // 🔥 REDUZIDO: 16 → 14
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
                        children: [
                          const SizedBox(height: 4), // 🔥 REDUZIDO: 6 → 4
                          
                          // Saudação e resumo rápido
                          _buildGreetingSection(),
                          
                          const SizedBox(height: 20), // 🔥 REDUZIDO: 24 → 20
                          
                          // Stats quick view
                          _buildQuickStats(),
                          
                          const SizedBox(height: 20), // 🔥 REDUZIDO: 24 → 20
                          
                          // Ações principais
                          _buildMainActions(),
                          
                          const SizedBox(height: 20), // 🔥 REDUZIDO: 24 → 20
                          
                          // Próximo treino ou estado vazio
                          _buildNextWorkoutSection(),
                          
                          const SizedBox(height: 8), // 🔥 REDUZIDO: 20 → 8 FINAL
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
          padding: const EdgeInsets.fromLTRB(16, 60, 16, 20), // 🔥 REDUZIDO: 20 → 16
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
                  children: [
                    FittedBox( // 🔥 ANTI-OVERFLOW no título
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Treino App',
                        style: TextStyle(
                          fontSize: 26, // 🔥 REDUZIDO: 28 → 26
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
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
                            fontSize: 9, // 🔥 REDUZIDO: 10 → 9
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8), // 🔥 Garantir espaçamento
              Container(
                width: 40, // 🔥 REDUZIDO: 44 → 40
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
                  size: 20, // 🔥 REDUZIDO: 22 → 20
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
          padding: const EdgeInsets.all(20), // 🔥 REDUZIDO: 24 → 20
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
                  mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
                  children: [
                    FittedBox( // 🔥 ANTI-OVERFLOW
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$_saudacao, $firstName!',
                        style: const TextStyle(
                          fontSize: 18, // 🔥 REDUZIDO: 20 → 18
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    FittedBox( // 🔥 ANTI-OVERFLOW
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pronto para seu próximo treino?',
                        style: TextStyle(
                          fontSize: 13, // 🔥 REDUZIDO: 14 → 13
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 52, // 🔥 REDUZIDO: 56 → 52
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
                  child: FittedBox( // 🔥 ANTI-OVERFLOW
                    fit: BoxFit.scaleDown,
                    child: Text(
                      user?.initials ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18, // 🔥 REDUZIDO: 20 → 18
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

  /// Stats rápidos modernos - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildQuickStats() {
    // 📊 Calcular estatísticas reais dos treinos
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
      mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
      children: [
        FittedBox( // 🔥 ANTI-OVERFLOW no título
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Resumo Semanal',
            style: TextStyle(
              fontSize: 17, // 🔥 REDUZIDO: 18 → 17
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14), // 🔥 REDUZIDO: 16 → 14
        // 🔥 CORREÇÃO OVERFLOW: IntrinsicHeight para garantir altura igual
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded( // 🔥 Expanded para garantir espaço igual
                child: _buildStatCard(
                  title: 'Treinos',
                  value: '$totalTreinos',
                  subtitle: 'Criados',
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 6), // 🔥 REDUZIDO: 8 → 6
              Expanded( // 🔥 Expanded para garantir espaço igual
                child: _buildStatCard(
                  title: 'Exercícios',
                  value: '$totalExercicios',
                  subtitle: 'Total',
                  icon: Icons.format_list_numbered_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 6), // 🔥 REDUZIDO: 8 → 6
              Expanded( // 🔥 Expanded para garantir espaço igual
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

  /// Card de estatística individual - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10), // 🔥 REDUZIDO: 12 → 10
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
        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
        children: [
          Container(
            width: 26, // 🔥 REDUZIDO: 28 → 26
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 14, // 🔥 REDUZIDO: 16 → 14
            ),
          ),
          const SizedBox(height: 6), // 🔥 REDUZIDO: 8 → 6
          Flexible( // 🔥 FLEXIBLE em vez de FittedBox
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18, // 🔥 REDUZIDO: 20 → 18
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible( // 🔥 FLEXIBLE em vez de FittedBox
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10, // 🔥 REDUZIDO: 11 → 10
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Flexible( // 🔥 FLEXIBLE em vez de FittedBox
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 8, // 🔥 REDUZIDO: 9 → 8
                color: const Color(0xFF94A3B8),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Ações principais redesenhadas - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildMainActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
      children: [
        FittedBox( // 🔥 ANTI-OVERFLOW no título
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 17, // 🔥 REDUZIDO: 18 → 17
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14), // 🔥 REDUZIDO: 16 → 14
        // 🔥 CORREÇÃO OVERFLOW: IntrinsicHeight para altura igual
        IntrinsicHeight(
          child: Row(
            children: [
              Expanded( // 🔥 Expanded para maior card
                flex: 2,
                child: _buildActionCard(
                  title: 'Criar Treino',
                  subtitle: 'Monte um novo treino',
                  icon: Icons.add_rounded,
                  color: const Color(0xFF6366F1),
                  onTap: _criarNovoTreino,
                ),
              ),
              const SizedBox(width: 6), // 🔥 REDUZIDO: 8 → 6
              Expanded( // 🔥 Expanded para menor card
                child: _buildActionCard(
                  title: 'Biblioteca',
                  subtitle: 'Ver treinos',
                  icon: Icons.library_books_rounded,
                  color: const Color(0xFF8B5CF6),
                  onTap: _abrirBibliotecaTreinos,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Card de ação moderno - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
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
        constraints: const BoxConstraints(minHeight: 100), // 🔥 ALTURA MÍNIMA
        padding: const EdgeInsets.all(14), // 🔥 REDUZIDO: 16 → 14
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
          mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
          children: [
            Container(
              width: 32, // 🔥 REDUZIDO: 36 → 32
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 16, // 🔥 REDUZIDO: 18 → 16
              ),
            ),
            const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
            Flexible( // 🔥 FLEXIBLE para título
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14, // 🔥 REDUZIDO: 15 → 14
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            Flexible( // 🔥 FLEXIBLE para subtitle
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10, // 🔥 REDUZIDO: 11 → 10
                  color: Colors.white.withOpacity(0.8),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2, // 🔥 MÁXIMO 2 linhas
              ),
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
      mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
      children: [
        FittedBox( // 🔥 ANTI-OVERFLOW no título
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Próximo Treino',
            style: TextStyle(
              fontSize: 17, // 🔥 REDUZIDO: 18 → 17
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),
        const SizedBox(height: 14), // 🔥 REDUZIDO: 16 → 14
        _treinos.isNotEmpty 
            ? _buildNextWorkoutCard()
            : _buildEmptyWorkoutState(),
      ],
    );
  }

  /// Card do próximo treino - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildNextWorkoutCard() {
    final treino = _treinos.first;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // 🔥 REDUZIDO: 20 → 16
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
        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
        children: [
          // 🔥 HEADER RESPONSIVO
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
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // 🔥 MÁXIMO 1 linha
                    ),
                    const SizedBox(height: 2), // 🔥 REDUZIDO: 4 → 2
                    Text(
                      treino.tipoTreino,
                      style: TextStyle(
                        fontSize: 12, // 🔥 REDUZIDO: 14 → 12
                        color: const Color(0xFF64748B),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1, // 🔥 MÁXIMO 1 linha
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // 🔥 BADGE COMPACTO
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // 🔥 REDUZIDO
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  treino.dificuldadeTextoSeguro,
                  style: const TextStyle(
                    fontSize: 9, // 🔥 REDUZIDO: 11 → 9
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
          
          // 🔥 INFO COMPACTA EM LINHA
          Row(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                size: 14, // 🔥 REDUZIDO: 16 → 14
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 4), // 🔥 REDUZIDO: 6 → 4
              Flexible( // 🔥 FLEXIBLE
                child: Text(
                  '${treino.exercicios.isNotEmpty ? treino.exercicios.length : (treino.totalExercicios ?? 0)} exercícios',
                  style: const TextStyle(
                    fontSize: 12, // 🔥 REDUZIDO: 14 → 12
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.timer_rounded,
                size: 14, // 🔥 REDUZIDO: 16 → 14
                color: const Color(0xFF64748B),
              ),
              const SizedBox(width: 4), // 🔥 REDUZIDO: 6 → 4
              Flexible( // 🔥 FLEXIBLE
                child: Text(
                  treino.duracaoFormatadaSegura,
                  style: const TextStyle(
                    fontSize: 12, // 🔥 REDUZIDO: 14 → 12
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12), // 🔥 REDUZIDO: 16 → 12
          
          // 🔥 BOTÃO COMPACTO
          SizedBox(
            width: double.infinity,
            height: 40, // 🔥 REDUZIDO: 44 → 40
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
                  Icon(Icons.play_arrow_rounded, size: 16), // 🔥 REDUZIDO: 18 → 16
                  const SizedBox(width: 4), // 🔥 REDUZIDO: 6 → 4
                  Text(
                    'Iniciar Treino',
                    style: TextStyle(
                      fontSize: 12, // 🔥 REDUZIDO: 13 → 12
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

  /// Estado vazio moderno - 🔥 VERSÃO ANTI-OVERFLOW DEFINITIVA
  Widget _buildEmptyWorkoutState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20), // 🔥 REDUZIDO: 24 → 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔥 ANTI-OVERFLOW
        children: [
          Container(
            width: 48, // 🔥 REDUZIDO: 56 → 48
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14), // 🔥 REDUZIDO: 16 → 14
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 20, // 🔥 REDUZIDO: 24 → 20
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 10), // 🔥 REDUZIDO: 12 → 10
          Text(
            'Nenhum treino criado',
            style: TextStyle(
              fontSize: 14, // 🔥 REDUZIDO: 15 → 14
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4), // 🔥 REDUZIDO: 6 → 4
          Text(
            'Crie seu primeiro treino personalizado para começar',
            style: TextStyle(
              fontSize: 12, // 🔥 REDUZIDO: 13 → 12
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 2, // 🔥 MÁXIMO 2 linhas
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12), // 🔥 REDUZIDO: 16 → 12
          SizedBox(
            width: double.infinity,
            height: 40, // 🔥 REDUZIDO: 44 → 40
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
                  fontSize: 12, // 🔥 REDUZIDO: 13 → 12
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================
  // 🔧 MÉTODOS DE NAVEGAÇÃO
  // ========================

  void _criarNovoTreino() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriarTreinoScreen(),
      ),
    ).then((_) => _carregarDadosComCache());
  }

  void _abrirBibliotecaTreinos() {
    HapticFeedback.lightImpact();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainNavigationScreen(initialTab: 1),
      ),
    );
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