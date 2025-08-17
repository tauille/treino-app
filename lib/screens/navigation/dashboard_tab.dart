import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/sport_theme.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  
  // Dados do dashboard
  Map<String, dynamic> _stats = {
    'treinosCompletos': 0,
    'tempoTotal': '0min',
    'semanaAtual': 0,
    'sequencia': 0,
  };
  
  List<Map<String, dynamic>> _treinosRecentes = [];
  List<Map<String, dynamic>> _proximosTreinos = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _carregarDados();
  }

  @override
  void dispose() {
    _fadeController.dispose();
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

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    try {
      setState(() {
        _stats = {
          'treinosCompletos': 0,
          'tempoTotal': '0min',
          'semanaAtual': 0,
          'sequencia': 0,
        };
        
        _treinosRecentes = [];
        _proximosTreinos = [];
      });
    } catch (e) {
      // Log silencioso
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SportColors.background, // Padronizado
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: RefreshIndicator(
            onRefresh: _carregarDados,
            color: SportColors.iconGreen, // Padronizado
            backgroundColor: SportColors.backgroundCard, // Padronizado
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatsCards(),
                  const SizedBox(height: 32),
                  _buildTreinosRecentes(),
                  const SizedBox(height: 32),
                  _buildProximosTreinos(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Header padronizado
  Widget _buildHeader() {
    final agora = DateTime.now();
    String saudacao = 'Bom dia';
    
    if (agora.hour >= 12 && agora.hour < 18) {
      saudacao = 'Boa tarde';
    } else if (agora.hour >= 18) {
      saudacao = 'Boa noite';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 32,
              decoration: BoxDecoration(
                color: SportColors.iconGreen, // Padronizado
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    saudacao,
                    style: TextStyle(
                      color: SportColors.textTertiary, // Padronizado
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pronto para começar?',
                    style: TextStyle(
                      color: SportColors.textPrimary, // Padronizado
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(SportColors.iconGreen), // Padronizado
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// Cards de estatísticas padronizados
  Widget _buildStatsCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seus números',
          style: TextStyle(
            color: SportColors.textPrimary, // Padronizado
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Treinos\nCompletos',
                _stats['treinosCompletos'].toString(),
                Icons.check_circle,
                SportColors.success, // Padronizado
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Tempo\nTotal',
                _stats['tempoTotal'],
                Icons.schedule,
                SportColors.iconGreen, // Padronizado
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Esta\nSemana',
                '${_stats['semanaAtual']} treinos',
                Icons.calendar_today,
                SportColors.warning, // Padronizado
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Sequência\nAtual',
                '${_stats['sequencia']} dias',
                Icons.local_fire_department,
                SportColors.secondary, // Padronizado
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Card individual de estatística padronizado
  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SportColors.backgroundCard, // Padronizado
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SportColors.border, // Padronizado
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: SportColors.textPrimary, // Padronizado
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: SportColors.textTertiary, // Padronizado
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de treinos recentes padronizada
  Widget _buildTreinosRecentes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Treinos recentes',
              style: TextStyle(
                color: SportColors.textPrimary, // Padronizado
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: ver todos os treinos
              },
              child: Text(
                'Ver todos',
                style: TextStyle(
                  color: SportColors.iconGreen, // Padronizado
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_treinosRecentes.isEmpty)
          _buildEmptyState(
            'Nenhum treino realizado ainda',
            'Comece seu primeiro treino agora!',
            Icons.fitness_center,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _treinosRecentes.length,
            itemBuilder: (context, index) {
              final treino = _treinosRecentes[index];
              return _buildTreinoRecenteCard(treino);
            },
          ),
      ],
    );
  }

  /// Card de treino recente padronizado
  Widget _buildTreinoRecenteCard(Map<String, dynamic> treino) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SportColors.backgroundCard, // Padronizado
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SportColors.border, // Padronizado
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SportColors.success.withOpacity(0.1), // Padronizado
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.check_circle,
              color: SportColors.success, // Padronizado
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treino['nome'],
                  style: const TextStyle(
                    color: SportColors.textPrimary, // Padronizado
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${treino['data']} • ${treino['duracao']}',
                  style: TextStyle(
                    color: SportColors.textTertiary, // Padronizado
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: SportColors.success.withOpacity(0.1), // Padronizado
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Completo',
              style: TextStyle(
                color: SportColors.success, // Padronizado
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Seção de próximos treinos padronizada
  Widget _buildProximosTreinos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos treinos',
          style: TextStyle(
            color: SportColors.textPrimary, // Padronizado
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        if (_proximosTreinos.isEmpty)
          _buildEmptyState(
            'Nenhum treino agendado',
            'Planeje seus próximos treinos',
            Icons.schedule,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _proximosTreinos.length,
            itemBuilder: (context, index) {
              final treino = _proximosTreinos[index];
              return _buildProximoTreinoCard(treino);
            },
          ),
      ],
    );
  }

  /// Card de próximo treino padronizado
  Widget _buildProximoTreinoCard(Map<String, dynamic> treino) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SportColors.backgroundCard, // Padronizado
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SportColors.border, // Padronizado
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SportColors.iconGreen.withOpacity(0.1), // Padronizado
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.schedule,
              color: SportColors.iconGreen, // Padronizado
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  treino['nome'],
                  style: const TextStyle(
                    color: SportColors.textPrimary, // Padronizado
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  treino['horario'],
                  style: TextStyle(
                    color: SportColors.textTertiary, // Padronizado
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: SportColors.iconGreen, // Padronizado
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Iniciar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vazio padronizado
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SportColors.backgroundCard, // Padronizado
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SportColors.border, // Padronizado
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: SportColors.textTertiary, // Padronizado
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: SportColors.textPrimary, // Padronizado
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: SportColors.textTertiary, // Padronizado
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}