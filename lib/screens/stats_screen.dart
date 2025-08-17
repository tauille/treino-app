import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/sport_theme.dart';

/// 📊 Tela de Estatísticas - DESIGN MODERNO E INFORMATIVO
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> 
    with TickerProviderStateMixin {
  
  late AnimationController _fadeController;
  late AnimationController _progressController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _progressAnimation;
  
  String _periodoSelecionado = 'Semana';
  final List<String> _periodos = ['Semana', 'Mês', 'Ano'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutQuart,
    ));
    
    _fadeController.forward();
    _progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header moderno
              _buildHeader(),
              
              // Selector de período
              SliverToBoxAdapter(
                child: _buildPeriodSelector(),
              ),
              
              // Stats principais
              SliverToBoxAdapter(
                child: _buildMainStats(),
              ),
              
              // Progresso semanal
              SliverToBoxAdapter(
                child: _buildWeeklyProgress(),
              ),
              
              // Conquistas
              SliverToBoxAdapter(
                child: _buildAchievements(),
              ),
              
              // Gráficos (placeholder)
              SliverToBoxAdapter(
                child: _buildChartsSection(),
              ),
              
              // Espaço final
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header moderno
  Widget _buildHeader() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: false,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1),
                          const Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Estatísticas',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Acompanhe seu progresso e evolução',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Selector de período
  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periodos.map((periodo) {
          final isSelected = periodo == _periodoSelecionado;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _periodoSelecionado = periodo;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  periodo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Stats principais
  Widget _buildMainStats() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo Geral',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          // Primeira linha
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Treinos Completos',
                  value: '24',
                  change: '+12%',
                  changePositive: true,
                  icon: Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Horas Treinadas',
                  value: '48h',
                  change: '+8%',
                  changePositive: true,
                  icon: Icons.timer_rounded,
                  color: const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Segunda linha
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Exercícios Feitos',
                  value: '486',
                  change: '+24%',
                  changePositive: true,
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Calorias Queimadas',
                  value: '2.4k',
                  change: '+5%',
                  changePositive: true,
                  icon: Icons.local_fire_department_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Card de estatística
  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool changePositive,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changePositive 
                      ? const Color(0xFF10B981).withOpacity(0.1)
                      : const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: changePositive 
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  /// Progresso semanal
  Widget _buildWeeklyProgress() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progresso da Semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(24),
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
                // Meta semanal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Meta: 5 treinos',
                      style: TextStyle(
                        fontSize: 14,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '4/5 completos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6366F1),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Barra de progresso
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          width: (MediaQuery.of(context).size.width - 88) * 
                                 0.8 * _progressAnimation.value,
                          height: 8,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6366F1),
                                const Color(0xFF8B5CF6),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Dias da semana
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDayIndicator('S', true),
                    _buildDayIndicator('T', true),
                    _buildDayIndicator('Q', true),
                    _buildDayIndicator('Q', true),
                    _buildDayIndicator('S', false),
                    _buildDayIndicator('S', false),
                    _buildDayIndicator('D', false),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDayIndicator(String day, bool completed) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: completed 
            ? const Color(0xFF6366F1)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: completed
            ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              )
            : Text(
                day,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF94A3B8),
                ),
              ),
      ),
    );
  }

  /// Conquistas
  Widget _buildAchievements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conquistas Recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAchievementCard(
                  title: 'Primeira Semana',
                  subtitle: 'Complete 5 treinos',
                  icon: Icons.emoji_events_rounded,
                  color: const Color(0xFFF59E0B),
                  completed: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAchievementCard(
                  title: 'Força Total',
                  subtitle: '100 exercícios',
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF8B5CF6),
                  completed: false,
                  progress: 0.75,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAchievementCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool completed,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: completed ? Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ) : null,
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: completed 
                  ? color 
                  : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              completed ? Icons.check_rounded : icon,
              color: completed ? Colors.white : color,
              size: 24,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
          
          if (!completed && progress != null) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 4,
            ),
          ],
        ],
      ),
    );
  }

  /// Seção de gráficos (placeholder)
  Widget _buildChartsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tendências',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            width: double.infinity,
            height: 200,
            padding: const EdgeInsets.all(24),
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1),
                        const Color(0xFF8B5CF6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.trending_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Gráficos Detalhados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Análises avançadas em breve',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}