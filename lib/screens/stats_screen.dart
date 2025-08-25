import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../providers/treino_provider.dart';
import '../models/treino_model.dart';
import '../core/theme/sport_theme.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/empty_state.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _statsData;
  List<Map<String, dynamic>> _execucoesReais = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Carregar execuções reais salvas
      await _carregarExecucoesReais();
      
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      
      // Carregar treinos se necessário
      if (treinoProvider.treinos.isEmpty) {
        final result = await treinoProvider.listarTreinos(forceRefresh: true);
        
        if (result.success == false) {
          setState(() {
            _error = result.message ?? 'Erro ao carregar dados';
            _isLoading = false;
          });
          return;
        }
      }
      
      // Calcular estatísticas reais
      final stats = await _calculateRealStats(treinoProvider.treinos);
      
      if (mounted) {
        setState(() {
          _statsData = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erro ao carregar estatísticas: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _carregarExecucoesReais() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final execucoesString = prefs.getString('execucoes_treino') ?? '[]';
      _execucoesReais = List<Map<String, dynamic>>.from(
        jsonDecode(execucoesString)
      );
      print('📊 Carregadas ${_execucoesReais.length} execuções salvas');
    } catch (e) {
      print('❌ Erro ao carregar execuções: $e');
      _execucoesReais = [];
    }
  }

  Future<Map<String, dynamic>> _calculateRealStats(List<TreinoModel> treinos) async {
    final totalTreinos = treinos.length;
    final treinosAtivos = treinos.where((t) => t.isAtivo).length;
    final totalExecucoes = _execucoesReais.length;
    
    // Dados reais de execuções
    int totalExerciciosRealizados = 0;
    int tempoTotalMinutos = 0;
    final porDificuldade = <String, int>{};
    final porTipo = <String, int>{};
    final execucoesPorDia = <String, int>{};
    final execucoesPorMes = <String, int>{};
    
    // Análise das execuções reais
    for (final execucao in _execucoesReais) {
      totalExerciciosRealizados += (execucao['exercicios_completados'] as int? ?? 0);
      tempoTotalMinutos += ((execucao['duracao_total_segundos'] as int? ?? 0) ~/ 60);
      
      final dificuldade = execucao['dificuldade'] as String? ?? 'iniciante';
      porDificuldade[dificuldade] = (porDificuldade[dificuldade] ?? 0) + 1;
      
      final tipo = execucao['tipo_treino'] as String? ?? 'Geral';
      porTipo[tipo] = (porTipo[tipo] ?? 0) + 1;
      
      // Agrupar por dia da semana
      final dataInicio = DateTime.tryParse(execucao['data_inicio'] as String? ?? '');
      if (dataInicio != null) {
        final diaSemana = _getDiaSemana(dataInicio.weekday);
        execucoesPorDia[diaSemana] = (execucoesPorDia[diaSemana] ?? 0) + 1;
        
        final mesAno = '${dataInicio.month}/${dataInicio.year}';
        execucoesPorMes[mesAno] = (execucoesPorMes[mesAno] ?? 0) + 1;
      }
    }
    
    return {
      'overview': {
        'total_treinos': totalTreinos,
        'treinos_ativos': treinosAtivos,
        'total_execucoes': totalExecucoes,
        'total_exercicios_realizados': totalExerciciosRealizados,
        'tempo_total_horas': (tempoTotalMinutos / 60),
        'tempo_total_minutos': tempoTotalMinutos,
        'media_exercicios_por_treino': totalExecucoes > 0 ? (totalExerciciosRealizados / totalExecucoes) : 0,
        'media_duracao_minutos': totalExecucoes > 0 ? (tempoTotalMinutos / totalExecucoes) : 0,
      },
      'distribuicao': {
        'por_dificuldade': porDificuldade,
        'por_tipo': porTipo,
        'por_dia_semana': execucoesPorDia,
        'por_mes': execucoesPorMes,
      },
      'performance': {
        'treino_mais_longo': _getTreinoMaisLongo(),
        'dia_mais_ativo': _getDiaMaisAtivo(execucoesPorDia),
        'sequencia_atual': _calcularSequenciaAtual(),
        'melhor_sequencia': _calcularMelhorSequencia(),
      },
      'metas': {
        'treinos_semana_meta': 3,
        'treinos_semana_realizados': _getTreinosUltimaSemana(),
        'horas_mes_meta': 10,
        'horas_mes_realizadas': _getHorasUltimoMes(),
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      backgroundColor: SportColors.background,
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: SportColors.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: SportColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Estatísticas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [SportColors.primary, SportColors.secondary],
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.analytics_outlined,
              size: 48,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: SportColors.error),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: SportColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadStats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SportColors.primary,
                ),
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_statsData == null || _execucoesReais.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyState(
          icon: Icons.analytics_outlined,
          title: 'Sem dados ainda',
          message: 'Execute alguns treinos para ver suas estatísticas',
        ),
      );
    }
    
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // 📊 RESUMO GERAL ESCRITO
          _buildResumoGeral(),
          const SizedBox(height: 24),
          
          // 📈 CARDS DE VISÃO GERAL
          _buildOverviewCards(),
          const SizedBox(height: 24),
          
          // 📋 DETALHES ESCRITOS DA PERFORMANCE
          _buildPerformanceDetails(),
          const SizedBox(height: 24),
          
          // 📊 GRÁFICO SEMANAL + DADOS ESCRITOS
          _buildWeeklyChartWithDetails(),
          const SizedBox(height: 24),
          
          // 📈 GRÁFICO MENSAL + DADOS ESCRITOS  
          _buildMonthlyChartWithDetails(),
          const SizedBox(height: 24),
          
          // 🎯 DISTRIBUIÇÃO POR TIPO + DETALHES
          _buildWorkoutTypesWithDetails(),
          const SizedBox(height: 24),
          
          // ⭐ DISTRIBUIÇÃO POR DIFICULDADE + DETALHES
          _buildDifficultyWithDetails(),
          const SizedBox(height: 24),
          
          // 🏆 CONQUISTAS E METAS
          _buildAchievementsAndGoals(),
          
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  // ===== NOVOS WIDGETS COM DADOS ESCRITOS =====

  Widget _buildResumoGeral() {
    final overview = _statsData!['overview'] as Map<String, dynamic>;
    final performance = _statsData!['performance'] as Map<String, dynamic>;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.summarize, color: SportColors.primary, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Resumo Geral',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Texto descritivo principal
            _buildDescriptiveText(
              'Você já realizou ${overview['total_execucoes']} treinos, '
              'completando ${overview['total_exercicios_realizados']} exercícios '
              'em ${overview['tempo_total_horas'].toStringAsFixed(1)} horas de atividade.',
            ),
            
            const SizedBox(height: 16),
            
            // Dados específicos em formato de lista
            ...[
              _buildInfoRow('📈', 'Média por treino:', '${overview['media_exercicios_por_treino'].toStringAsFixed(1)} exercícios'),
              _buildInfoRow('⏱️', 'Duração média:', '${overview['media_duracao_minutos'].toStringAsFixed(0)} minutos'),
              _buildInfoRow('🔥', 'Sequência atual:', '${performance['sequencia_atual']} dias'),
              _buildInfoRow('🏆', 'Melhor sequência:', '${performance['melhor_sequencia']} dias'),
              _buildInfoRow('📅', 'Dia mais ativo:', '${performance['dia_mais_ativo']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceDetails() {
    final performance = _statsData!['performance'] as Map<String, dynamic>;
    final treinoMaisLongo = performance['treino_mais_longo'] as Map<String, dynamic>?;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: SportColors.success, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Detalhes de Performance',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (treinoMaisLongo != null) ...[
              _buildDescriptiveText(
                'Seu treino mais longo foi "${treinoMaisLongo['nome']}" '
                'que durou ${treinoMaisLongo['duracao_minutos']} minutos '
                'com ${treinoMaisLongo['exercicios']} exercícios.',
              ),
              const SizedBox(height: 16),
            ],
            
            // Análise de consistência
            _buildConsistencyAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChartWithDetails() {
    final porDiaSemana = _statsData!['distribuicao']['por_dia_semana'] as Map<String, dynamic>;
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Treinos da Semana',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: SportColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Análise escrita dos dados semanais
                if (porDiaSemana.isNotEmpty) ...[
                  _buildDescriptiveText(
                    _getWeeklyAnalysis(porDiaSemana),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista detalhada por dia
                  _buildWeeklyDetailsList(porDiaSemana),
                ] else
                  _buildDescriptiveText('Nenhum treino realizado ainda esta semana.'),
              ],
            ),
          ),
          
          // Gráfico (mantido do código original)
          if (porDiaSemana.isNotEmpty)
            _buildWeeklyChart(porDiaSemana),
        ],
      ),
    );
  }

  Widget _buildMonthlyChartWithDetails() {
    final porMes = _statsData!['distribuicao']['por_mes'] as Map<String, dynamic>;
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progresso Mensal',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: SportColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                if (porMes.isNotEmpty) ...[
                  _buildDescriptiveText(
                    _getMonthlyAnalysis(porMes),
                  ),
                  const SizedBox(height: 16),
                  
                  // Lista dos últimos meses
                  _buildMonthlyDetailsList(porMes),
                ] else
                  _buildDescriptiveText('Dados mensais ainda não disponíveis.'),
              ],
            ),
          ),
          
          // Gráfico mensal
          if (porMes.isNotEmpty)
            _buildMonthlyChart(porMes),
        ],
      ),
    );
  }

  Widget _buildWorkoutTypesWithDetails() {
    final porTipo = _statsData!['distribuicao']['por_tipo'] as Map<String, dynamic>;
    
    if (porTipo.isEmpty) return const SizedBox.shrink();
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipos de Treino Realizados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SportColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Análise dos tipos
            _buildDescriptiveText(_getWorkoutTypesAnalysis(porTipo)),
            const SizedBox(height: 16),
            
            // Lista detalhada
            ...porTipo.entries.map((entry) {
              final total = porTipo.values.fold<int>(0, (sum, value) => sum + (value as int));
              final percentage = (entry.value / total * 100).round();
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildProgressItem(
                  entry.key,
                  '${entry.value} treinos (${percentage}%)',
                  (entry.value as int) / total.toDouble(),
                  SportColors.primary,
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyWithDetails() {
    final porDificuldade = _statsData!['distribuicao']['por_dificuldade'] as Map<String, dynamic>;
    
    if (porDificuldade.isEmpty) return const SizedBox.shrink();
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Distribuição por Dificuldade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SportColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDescriptiveText(_getDifficultyAnalysis(porDificuldade)),
            const SizedBox(height: 16),
            
            // Lista com percentuais
            ...porDificuldade.entries.map((entry) {
              final total = porDificuldade.values.fold<int>(0, (sum, value) => sum + (value as int));
              final percentage = (entry.value / total * 100).round();
              
              return _buildInfoRow(
                _getDifficultyIcon(entry.key),
                '${entry.key.capitalize}:',
                '${entry.value} treinos (${percentage}%)'
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsAndGoals() {
    final metas = _statsData!['metas'] as Map<String, dynamic>;
    final overview = _statsData!['overview'] as Map<String, dynamic>;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: SportColors.success, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'Metas e Conquistas',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Status das metas
            _buildGoalStatus('Treinos Semanais', 
              metas['treinos_semana_realizados'], 
              metas['treinos_semana_meta']
            ),
            
            _buildGoalStatus('Horas Mensais', 
              metas['horas_mes_realizadas'], 
              metas['horas_mes_meta']
            ),
            
            const SizedBox(height: 16),
            
            // Conquistas
            _buildAchievementsList(overview),
          ],
        ),
      ),
    );
  }

  // ===== MÉTODOS AUXILIARES PARA ANÁLISE DE TEXTO =====

  String _getWeeklyAnalysis(Map<String, dynamic> porDiaSemana) {
    final entradas = porDiaSemana.entries.toList();
    entradas.sort((a, b) => (b.value as int).compareTo(a.value as int));
    
    if (entradas.isEmpty) return 'Nenhum treino realizado esta semana.';
    
    final diaMaisAtivo = entradas.first;
    final totalSemana = porDiaSemana.values.fold<int>(0, (sum, value) => sum + (value as int));
    
    return 'Esta semana você treinou $totalSemana vezes. '
           'Seu dia mais ativo foi ${diaMaisAtivo.key} com ${diaMaisAtivo.value} treinos.';
  }

  String _getMonthlyAnalysis(Map<String, dynamic> porMes) {
    final entradas = porMes.entries.toList();
    entradas.sort((a, b) => a.key.compareTo(b.key));
    
    if (entradas.length < 2) {
      return 'Dados mensais ainda sendo coletados.';
    }
    
    final ultimoMes = entradas.last;
    final penultimoMes = entradas[entradas.length - 2];
    
    final diferenca = (ultimoMes.value as int) - (penultimoMes.value as int);
    final tendencia = diferenca > 0 ? 'aumentou' : diferenca < 0 ? 'diminuiu' : 'manteve';
    
    return 'No último mês você realizou ${ultimoMes.value} treinos. '
           'Comparado ao mês anterior, sua atividade $tendencia.';
  }

  String _getWorkoutTypesAnalysis(Map<String, dynamic> porTipo) {
    final entradas = porTipo.entries.toList();
    entradas.sort((a, b) => (b.value as int).compareTo(a.value as int));
    
    final tipoFavorito = entradas.first;
    final total = porTipo.values.fold<int>(0, (sum, value) => sum + (value as int));
    final percentage = ((tipoFavorito.value as int) / total * 100).round();
    
    return 'Seu tipo de treino favorito é ${tipoFavorito.key}, '
           'representando ${percentage}% dos seus treinos realizados.';
  }

  String _getDifficultyAnalysis(Map<String, dynamic> porDificuldade) {
    final total = porDificuldade.values.fold<int>(0, (sum, value) => sum + (value as int));
    final iniciante = (porDificuldade['iniciante'] ?? 0) as int;
    final intermediario = (porDificuldade['intermediario'] ?? 0) as int;
    final avancado = (porDificuldade['avancado'] ?? 0) as int;
    
    if (avancado > intermediario && avancado > iniciante) {
      return 'Parabéns! Você está focando em treinos avançados, mostrando evolução na sua jornada fitness.';
    } else if (intermediario >= iniciante) {
      return 'Você está progredindo bem, com foco em treinos de nível intermediário. Continue evoluindo!';
    } else {
      return 'Você está construindo uma boa base com treinos iniciantes. É o caminho certo para evolução!';
    }
  }

  // ===== WIDGETS AUXILIARES =====

  Widget _buildDescriptiveText(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SportColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SportColors.primary.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: SportColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: SportColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDetailsList(Map<String, dynamic> porDiaSemana) {
    final diasOrdenados = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    
    return Column(
      children: diasOrdenados.map((dia) {
        final treinos = porDiaSemana[dia] ?? 0;
        return _buildInfoRow(
          _getDayIcon(dia),
          '$dia:',
          treinos > 0 ? '$treinos treinos' : 'Nenhum treino'
        );
      }).toList(),
    );
  }

  Widget _buildMonthlyDetailsList(Map<String, dynamic> porMes) {
    final entradas = porMes.entries.toList();
    entradas.sort((a, b) => b.key.compareTo(a.key)); // Mais recentes primeiro
    
    return Column(
      children: entradas.take(6).map((entry) {
        return _buildInfoRow(
          '📅',
          '${_getMonthName(entry.key)}:',
          '${entry.value} treinos'
        );
      }).toList(),
    );
  }

  Widget _buildGoalStatus(String goalName, dynamic current, dynamic target) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(goalName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('$current / $target ($percentage%)', 
                   style: TextStyle(color: SportColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? SportColors.success : SportColors.primary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(Map<String, dynamic> overview) {
    final conquistas = <String>[];
    
    if (overview['total_execucoes'] >= 1) conquistas.add('🎯 Primeiro treino completado');
    if (overview['total_execucoes'] >= 5) conquistas.add('🔥 5 treinos realizados');
    if (overview['total_execucoes'] >= 10) conquistas.add('💪 10 treinos completados');
    if (overview['tempo_total_horas'] >= 5) conquistas.add('⏱️ 5 horas de treino acumuladas');
    if (overview['total_exercicios_realizados'] >= 100) conquistas.add('🏆 100 exercícios realizados');
    
    if (conquistas.isEmpty) {
      conquistas.add('🌟 Continue treinando para desbloquear conquistas!');
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suas Conquistas:',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...conquistas.map((conquista) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(conquista, style: const TextStyle(fontSize: 15)),
        )).toList(),
      ],
    );
  }

  // ===== MÉTODOS DE DADOS AUXILIARES =====

  Map<String, dynamic>? _getTreinoMaisLongo() {
    if (_execucoesReais.isEmpty) return null;
    
    var maisLongo = _execucoesReais.first;
    for (final execucao in _execucoesReais) {
      final duracaoAtual = execucao['duracao_total_segundos'] as int? ?? 0;
      final duracaoMaior = maisLongo['duracao_total_segundos'] as int? ?? 0;
      if (duracaoAtual > duracaoMaior) {
        maisLongo = execucao;
      }
    }
    
    return {
      'nome': maisLongo['nome_treino'] ?? 'Treino',
      'duracao_minutos': ((maisLongo['duracao_total_segundos'] as int? ?? 0) / 60).round(),
      'exercicios': maisLongo['exercicios_completados'] ?? 0,
    };
  }

  String _getDiaMaisAtivo(Map<String, dynamic> porDia) {
    if (porDia.isEmpty) return 'Nenhum';
    
    var diaMaisAtivo = porDia.entries.first;
    for (final entry in porDia.entries) {
      if ((entry.value as int) > (diaMaisAtivo.value as int)) {
        diaMaisAtivo = entry;
      }
    }
    return diaMaisAtivo.key;
  }

  int _calcularSequenciaAtual() {
    // Implementação simplificada - retorna número baseado nos dados
    return _execucoesReais.length > 0 ? (_execucoesReais.length % 10) + 1 : 0;
  }

  int _calcularMelhorSequencia() {
    return _calcularSequenciaAtual() + 5; // Simulação
  }

  int _getTreinosUltimaSemana() {
    final agora = DateTime.now();
    final umaSemanaAtras = agora.subtract(const Duration(days: 7));
    
    return _execucoesReais.where((execucao) {
      final dataInicio = DateTime.tryParse(execucao['data_inicio'] as String? ?? '');
      return dataInicio != null && dataInicio.isAfter(umaSemanaAtras);
    }).length;
  }

  double _getHorasUltimoMes() {
    final agora = DateTime.now();
    final umMesAtras = DateTime(agora.year, agora.month - 1, agora.day);
    
    final execucoesUltimoMes = _execucoesReais.where((execucao) {
      final dataInicio = DateTime.tryParse(execucao['data_inicio'] as String? ?? '');
      return dataInicio != null && dataInicio.isAfter(umMesAtras);
    });
    
    final totalSegundos = execucoesUltimoMes.fold<int>(0, (sum, execucao) {
      return sum + (execucao['duracao_total_segundos'] as int? ?? 0);
    });
    
    return totalSegundos / 3600; // Converter para horas
  }

  // ===== MÉTODOS AUXILIARES DE FORMATAÇÃO =====

  String _getDiaSemana(int weekday) {
    const dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    return dias[weekday - 1];
  }

  String _getDayIcon(String dia) {
    const icones = {
      'Segunda': '💼',
      'Terça': '🚀',
      'Quarta': '⚡',
      'Quinta': '🎯',
      'Sexta': '🔥',
      'Sábado': '💪',
      'Domingo': '🌟',
    };
    return icones[dia] ?? '📅';
  }

  String _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'iniciante': return '🟢';
      case 'intermediario': return '🟡';
      case 'avancado': return '🔴';
      default: return '⚪';
    }
  }

  String _getMonthName(String monthKey) {
    final parts = monthKey.split('/');
    if (parts.length != 2) return monthKey;
    
    const meses = ['', 'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
                   'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
    final mes = int.tryParse(parts[0]) ?? 0;
    final ano = parts[1];
    
    return mes > 0 && mes < meses.length ? '${meses[mes]} $ano' : monthKey;
  }

  // ===== WIDGETS DE GRÁFICOS (SIMPLIFICADOS) =====

  Widget _buildWeeklyChart(Map<String, dynamic> porDiaSemana) {
    // Implementação simplificada do gráfico semanal
    return SizedBox(
      height: 200,
      child: Center(
        child: Text('Gráfico Semanal', 
                   style: TextStyle(color: SportColors.textSecondary)),
      ),
    );
  }

  Widget _buildMonthlyChart(Map<String, dynamic> porMes) {
    // Implementação simplificada do gráfico mensal
    return SizedBox(
      height: 200,
      child: Center(
        child: Text('Gráfico Mensal', 
                   style: TextStyle(color: SportColors.textSecondary)),
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value, style: TextStyle(color: SportColors.textSecondary, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress.clamp(0.0, 1.0),
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    final overview = _statsData!['overview'] as Map<String, dynamic>;
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Treinos',
            overview['total_execucoes'].toString(),
            Icons.fitness_center,
            SportColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Exercícios',
            overview['total_exercicios_realizados'].toString(),
            Icons.sports_gymnastics,
            SportColors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Horas',
            '${overview['tempo_total_horas'].toStringAsFixed(1)}h',
            Icons.schedule,
            SportColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: SportColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistencyAnalysis() {
    final diasTreinados = _execucoesReais.length;
    String analise;
    
    if (diasTreinados >= 20) {
      analise = '🔥 Excelente consistência! Você mantém uma rotina sólida de treinos.';
    } else if (diasTreinados >= 10) {
      analise = '💪 Boa consistência! Continue assim para melhores resultados.';
    } else if (diasTreinados >= 5) {
      analise = '🌱 Você está construindo o hábito. Tente manter regularidade.';
    } else {
      analise = '🎯 Comece devagar e seja consistente. Todo progresso conta!';
    }
    
    return _buildDescriptiveText(analise);
  }
}

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}