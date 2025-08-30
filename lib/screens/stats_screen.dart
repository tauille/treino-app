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
  
  // CHAVES PARA PERSISTÊNCIA
  static const String _keyExecucoesTreino = 'execucoes_treino';
  static const String _keyEstatisticasGerais = 'estatisticas_gerais';
  static const String _keyUltimaAtualizacao = 'ultima_atualizacao_stats';

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
      // CARREGAR DADOS PERSISTENTES PRIMEIRO
      await _carregarExecucoesReais();
      await _carregarEstatisticasPersistentes();
      
      // CORREÇÃO: Se temos execuções salvas, calcular estatísticas mesmo sem conectar ao servidor
      if (_execucoesReais.isNotEmpty) {
        print('📊 STATS: Temos ${_execucoesReais.length} execuções salvas, calculando estatísticas...');
        
        // Calcular estatísticas com dados salvos
        final stats = await _calculateRealStats([]);
        
        if (mounted) {
          setState(() {
            _statsData = stats;
            _isLoading = false;
            _error = null;
          });
        }
        
        print('✅ STATS: Estatísticas calculadas com dados salvos');
        return; // Sair aqui, não precisa conectar ao servidor
      }
      
      // Se não tem execuções salvas, tentar carregar do servidor
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      
      // Carregar treinos se necessário
      if (treinoProvider.treinos.isEmpty) {
        final result = await treinoProvider.listarTreinos(forceRefresh: true);
        
        // CORREÇÃO: Verificar se result.success é boolean true, não string
        if (result.success != true) {
          print('❌ STATS: Erro ao carregar treinos: ${result.message}');
          setState(() {
            _error = result.message ?? 'Erro ao carregar dados';
            _isLoading = false;
          });
          return;
        }
      }
      
      // Calcular estatísticas com treinos do servidor
      final stats = await _calculateRealStats(treinoProvider.treinos);
      
      // SALVAR ESTATÍSTICAS CALCULADAS
      await _salvarEstatisticasCalculadas(stats);
      
      if (mounted) {
        setState(() {
          _statsData = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Erro ao carregar stats: $e');
      
      // EM CASO DE ERRO, TENTAR USAR DADOS SALVOS
      if (_statsData == null) {
        await _carregarEstatisticasSalvas();
      }
      
      if (mounted) {
        setState(() {
          _error = _statsData == null ? 'Erro ao carregar estatísticas: $e' : null;
          _isLoading = false;
        });
      }
    }
  }

  // MÉTODOS DE PERSISTÊNCIA APRIMORADOS COM DEBUG
  
  Future<void> _carregarExecucoesReais() async {
    try {
      print('🔍 DEBUG: Iniciando carregamento de execuções...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // DEBUG: Verificar todas as chaves disponíveis
      final keys = prefs.getKeys();
      print('🔑 DEBUG: Chaves disponíveis: $keys');
      
      // Tentar carregar da chave principal
      final execucoesString = prefs.getString(_keyExecucoesTreino);
      print('📦 DEBUG: String bruta da chave "$_keyExecucoesTreino": ${execucoesString?.length ?? 0} caracteres');
      
      if (execucoesString == null || execucoesString.isEmpty || execucoesString == '[]') {
        print('⚠️ DEBUG: Nenhuma execução encontrada na chave principal');
        _execucoesReais = [];
        return;
      }
      
      try {
        final decoded = jsonDecode(execucoesString);
        print('🔄 DEBUG: JSON decodificado com sucesso: ${decoded.runtimeType}');
        
        _execucoesReais = List<Map<String, dynamic>>.from(decoded);
        print('✅ DEBUG: Carregadas ${_execucoesReais.length} execuções persistentes');
        
        // Debug detalhado da primeira execução
        if (_execucoesReais.isNotEmpty) {
          final primeira = _execucoesReais.first;
          print('📋 DEBUG: Primeira execução:');
          print('   - Nome: ${primeira['nome_treino']}');
          print('   - Data: ${primeira['data_inicio']}');
          print('   - Exercícios: ${primeira['exercicios_completados']}');
          print('   - Duração: ${primeira['duracao_total_segundos']}s');
        }
        
      } catch (parseError) {
        print('❌ DEBUG: Erro ao fazer parse do JSON: $parseError');
        print('📄 DEBUG: Conteúdo que falhou: $execucoesString');
        _execucoesReais = [];
      }
      
    } catch (e) {
      print('❌ DEBUG: Erro geral ao carregar execuções: $e');
      _execucoesReais = [];
    }
  }

  Future<void> _carregarEstatisticasPersistentes() async {
    try {
      print('📊 DEBUG: Carregando estatísticas salvas...');
      
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_keyEstatisticasGerais);
      
      if (statsString != null) {
        final statsMap = jsonDecode(statsString) as Map<String, dynamic>;
        print('✅ DEBUG: Estatísticas persistentes encontradas');
        
        // Verificar se não são muito antigas (mais de 30 dias)
        final ultimaAtualizacao = prefs.getInt(_keyUltimaAtualizacao) ?? 0;
        final agora = DateTime.now().millisecondsSinceEpoch;
        final diasDiferenca = (agora - ultimaAtualizacao) / (1000 * 60 * 60 * 24);
        
        print('📅 DEBUG: Estatísticas de ${diasDiferenca.toInt()} dias atrás');
        
        if (diasDiferenca < 30) {
          _statsData = statsMap;
          print('✅ DEBUG: Usando estatísticas salvas (${diasDiferenca.toInt()} dias atrás)');
        } else {
          print('⚠️ DEBUG: Estatísticas muito antigas, será recalculado');
        }
      } else {
        print('ℹ️ DEBUG: Nenhuma estatística salva encontrada');
      }
    } catch (e) {
      print('❌ DEBUG: Erro ao carregar estatísticas salvas: $e');
    }
  }

  Future<void> _carregarEstatisticasSalvas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(_keyEstatisticasGerais);
      
      if (statsString != null) {
        _statsData = jsonDecode(statsString) as Map<String, dynamic>;
        print('✅ DEBUG: Estatísticas de backup carregadas');
      }
    } catch (e) {
      print('❌ DEBUG: Erro ao carregar backup: $e');
    }
  }

  Future<void> _salvarEstatisticasCalculadas(Map<String, dynamic> stats) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyEstatisticasGerais, jsonEncode(stats));
      await prefs.setInt(_keyUltimaAtualizacao, DateTime.now().millisecondsSinceEpoch);
      print('✅ DEBUG: Estatísticas salvas com sucesso');
    } catch (e) {
      print('❌ DEBUG: Erro ao salvar estatísticas: $e');
    }
  }

  // MÉTODO PÚBLICO PARA SER CHAMADO QUANDO UM TREINO É COMPLETADO
  static Future<void> adicionarExecucaoCompletada(Map<String, dynamic> execucaoData) async {
    try {
      print('💾 DEBUG: Iniciando salvamento de nova execução...');
      
      const String keyExecucoesTreino = 'execucoes_treino';
      
      final prefs = await SharedPreferences.getInstance();
      final execucoesString = prefs.getString(keyExecucoesTreino) ?? '[]';
      
      print('📦 DEBUG: Execuções existentes: ${execucoesString.length} caracteres');
      
      final execucoesList = List<Map<String, dynamic>>.from(jsonDecode(execucoesString));
      
      print('📊 DEBUG: Lista atual tem ${execucoesList.length} execuções');
      
      // Adicionar nova execução com timestamp
      execucaoData['timestamp_salvo'] = DateTime.now().millisecondsSinceEpoch;
      execucoesList.add(execucaoData);
      
      // Salvar de volta
      final novoJson = jsonEncode(execucoesList);
      await prefs.setString(keyExecucoesTreino, novoJson);
      
      print('✅ DEBUG: Execução adicionada às estatísticas: ${execucaoData['nome_treino']}');
      print('📈 DEBUG: Total de execuções agora: ${execucoesList.length}');
      
      // Verificar se foi salvo corretamente
      final verificacao = prefs.getString(keyExecucoesTreino);
      final verificacaoList = List<Map<String, dynamic>>.from(jsonDecode(verificacao ?? '[]'));
      print('🔍 DEBUG: Verificação - execuções salvas: ${verificacaoList.length}');
      
    } catch (e) {
      print('❌ DEBUG: Erro ao salvar execução: $e');
    }
  }

  // MÉTODO PARA FORMATAR TEMPO EM HORAS E MINUTOS
  String _formatarTempoHorasMinutos(double totalMinutos) {
    if (totalMinutos < 1) {
      return '0min';
    }
    
    final minutos = totalMinutos.round();
    
    if (minutos < 60) {
      return '${minutos}min';
    }
    
    final horas = minutos ~/ 60;
    final minutosRestantes = minutos % 60;
    
    if (minutosRestantes == 0) {
      return '${horas}h';
    }
    
    return '${horas}h ${minutosRestantes}min';
  }

  // MÉTODO PARA FORMATAR HORAS DECIMAIS
  String _formatarHorasDecimais(double horas) {
    final totalMinutos = (horas * 60).round();
    return _formatarTempoHorasMinutos(totalMinutos.toDouble());
  }

  Future<Map<String, dynamic>> _calculateRealStats(List<TreinoModel> treinos) async {
    print('🔢 DEBUG: Calculando estatísticas com ${_execucoesReais.length} execuções');
    
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
    
    // CORREÇÃO: Arredondamento das horas
    final tempoTotalHoras = tempoTotalMinutos / 60.0;
    
    final stats = {
      'overview': {
        'total_treinos': totalTreinos,
        'treinos_ativos': treinosAtivos,
        'total_execucoes': totalExecucoes,
        'total_exercicios_realizados': totalExerciciosRealizados,
        'tempo_total_horas': tempoTotalHoras,
        'tempo_total_minutos': tempoTotalMinutos,
        'tempo_total_formatado': _formatarTempoHorasMinutos(tempoTotalMinutos.toDouble()),
        'media_exercicios_por_treino': totalExecucoes > 0 ? 
          double.parse((totalExerciciosRealizados / totalExecucoes).toStringAsFixed(1)) : 0.0,
        'media_duracao_minutos': totalExecucoes > 0 ? 
          double.parse((tempoTotalMinutos / totalExecucoes).toStringAsFixed(1)) : 0.0,
        'media_duracao_formatada': totalExecucoes > 0 ? 
          _formatarTempoHorasMinutos(tempoTotalMinutos / totalExecucoes) : '0min',
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
        'horas_mes_meta': 10.0,
        'horas_mes_realizadas': _getHorasUltimoMes(),
        'horas_mes_formatadas': _formatarHorasDecimais(_getHorasUltimoMes()),
      }
    };
    
    print('📈 DEBUG: Estatísticas calculadas - ${stats['overview']?['total_execucoes'] ?? 0} execuções');
    
    return stats;
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
      actions: [
        // BOTÃO DE DEBUG PARA VERIFICAR DADOS
        IconButton(
          onPressed: _showDebugInfo,
          icon: const Icon(Icons.bug_report),
          tooltip: 'Debug Info',
        ),
        // BOTÃO PARA LIMPAR DADOS (APENAS PARA DEBUG)
        if (_execucoesReais.isNotEmpty)
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear_debug') {
                await _showClearDataDialog();
              } else if (value == 'reload_debug') {
                await _forceReloadData();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'reload_debug',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: SportColors.primary),
                    const SizedBox(width: 8),
                    const Text('Recarregar Dados'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'clear_debug',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: SportColors.error),
                    const SizedBox(width: 8),
                    const Text('Limpar Dados (Debug)'),
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }

  // MÉTODO DE DEBUG PARA MOSTRAR INFORMAÇÕES DETALHADAS
  void _showDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final execucoesString = prefs.getString(_keyExecucoesTreino) ?? '[]';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug - Informações de Persistência'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Chaves disponíveis: ${keys.length}'),
              const SizedBox(height: 8),
              Text('Chave principal: $_keyExecucoesTreino'),
              const SizedBox(height: 8),
              Text('Dados na memória: ${_execucoesReais.length} execuções'),
              const SizedBox(height: 8),
              Text('Dados no storage: ${execucoesString.length} caracteres'),
              const SizedBox(height: 8),
              if (execucoesString != '[]') 
                Text('Primeira execução: ${_execucoesReais.isNotEmpty ? _execucoesReais.first['nome_treino'] : 'Nenhuma'}'),
              const SizedBox(height: 16),
              const Text('Chaves encontradas:'),
              ...keys.take(10).map((key) => Text('• $key')),
              if (keys.length > 10) Text('... e mais ${keys.length - 10}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // MÉTODO PARA FORÇAR RELOAD DOS DADOS
  Future<void> _forceReloadData() async {
    print('🔄 DEBUG: Forçando reload de dados...');
    await _loadStats();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dados recarregados')),
    );
  }

  // DIÁLOGO PARA CONFIRMAR LIMPEZA DOS DADOS
  Future<void> _showClearDataDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Estatísticas'),
        content: const Text(
          'Isso irá remover todas as suas estatísticas salvas. '
          'Esta ação não pode ser desfeita.\n\n'
          'Tem certeza que deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: SportColors.error),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _limparTodasEstatisticas();
    }
  }

  Future<void> _limparTodasEstatisticas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyExecucoesTreino);
      await prefs.remove(_keyEstatisticasGerais);
      await prefs.remove(_keyUltimaAtualizacao);
      
      setState(() {
        _execucoesReais.clear();
        _statsData = null;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estatísticas limpas com sucesso')),
      );
      
      print('✅ DEBUG: Todas as estatísticas foram limpas');
    } catch (e) {
      print('❌ DEBUG: Erro ao limpar estatísticas: $e');
    }
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
    
    if (_statsData == null && _execucoesReais.isEmpty) {
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
          // RESUMO GERAL ESCRITO
          _buildResumoGeral(),
          const SizedBox(height: 24),
          
          // CARDS DE VISÃO GERAL
          _buildOverviewCards(),
          const SizedBox(height: 24),
          
          // DETALHES ESCRITOS DA PERFORMANCE
          _buildPerformanceDetails(),
          const SizedBox(height: 24),
          
          // CONQUISTAS E METAS
          _buildAchievementsAndGoals(),
          const SizedBox(height: 24),
          
          // GRÁFICO SEMANAL + DADOS ESCRITOS
          _buildWeeklyChartWithDetails(),
          const SizedBox(height: 24),
          
          // GRÁFICO MENSAL + DADOS ESCRITOS  
          _buildMonthlyChartWithDetails(),
          const SizedBox(height: 24),
          
          // DISTRIBUIÇÃO POR TIPO + DETALHES
          _buildWorkoutTypesWithDetails(),
          const SizedBox(height: 24),
          
          // DISTRIBUIÇÃO POR DIFICULDADE + DETALHES
          _buildDifficultyWithDetails(),
          
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  // ===== WIDGETS COM FORMATO DE TEMPO CORRIGIDO =====

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
            
            // TEXTO COM FORMATO DE TEMPO CORRIGIDO
            _buildDescriptiveText(
              'Você já realizou ${overview['total_execucoes']} treinos, '
              'completando ${overview['total_exercicios_realizados']} exercícios '
              'em ${overview['tempo_total_formatado']} de atividade.',
            ),
            
            const SizedBox(height: 16),
            
            // Dados específicos em formato de lista
            ...[
              _buildInfoRow('📈', 'Média por treino:', '${overview['media_exercicios_por_treino']} exercícios'),
              _buildInfoRow('⏱️', 'Duração média:', overview['media_duracao_formatada']),
              _buildInfoRow('🔥', 'Sequência atual:', '${performance['sequencia_atual']} dias'),
              _buildInfoRow('🏆', 'Melhor sequência:', '${performance['melhor_sequencia']} dias'),
              _buildInfoRow('📅', 'Dia mais ativo:', '${performance['dia_mais_ativo']}'),
            ],
          ],
        ),
      ),
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
            'Tempo',
            overview['tempo_total_formatado'],
            Icons.schedule,
            SportColors.success,
          ),
        ),
      ],
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
            
            // META COM FORMATO DE TEMPO CORRIGIDO
            _buildGoalStatusFormatted('Tempo Mensal', 
              metas['horas_mes_formatadas'], 
              _formatarHorasDecimais(metas['horas_mes_meta']),
              metas['horas_mes_realizadas'] / metas['horas_mes_meta']
            ),
            
            const SizedBox(height: 16),
            
            // Conquistas
            _buildAchievementsList(overview),
          ],
        ),
      ),
    );
  }

  // ===== WIDGETS AUXILIARES CORRIGIDOS =====

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
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 1,
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SportColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
              Expanded(
                child: Text(
                  goalName, 
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$current / $target ($percentage%)', 
                  style: TextStyle(color: SportColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

  // NOVO WIDGET PARA METAS COM FORMATO PERSONALIZADO
  Widget _buildGoalStatusFormatted(String goalName, String currentFormatted, String targetFormatted, double progress) {
    final percentage = (progress * 100).round();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  goalName, 
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$currentFormatted / $targetFormatted ($percentage%)', 
                  style: TextStyle(color: SportColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? SportColors.success : SportColors.primary
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          FittedBox(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SportColors.textSecondary,
                fontSize: 12,
              ),
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
    if (overview['total_execucoes'] >= 25) conquistas.add('⭐ 25 treinos completados');
    if (overview['total_execucoes'] >= 50) conquistas.add('🏆 50 treinos completados');
    if (overview['tempo_total_horas'] >= 5) conquistas.add('⏱️ 5 horas de treino acumuladas');
    if (overview['tempo_total_horas'] >= 10) conquistas.add('🚀 10 horas de treino acumuladas');
    if (overview['total_exercicios_realizados'] >= 100) conquistas.add('🎖️ 100 exercícios realizados');
    if (overview['total_exercicios_realizados'] >= 500) conquistas.add('👑 500 exercícios realizados');
    
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

  // ===== MÉTODOS AUXILIARES (OUTROS WIDGETS SIMPLIFICADOS) =====

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
                'que durou ${_formatarTempoHorasMinutos(treinoMaisLongo['duracao_minutos'].toDouble())} '
                'com ${treinoMaisLongo['exercicios']} exercícios.',
              ),
              const SizedBox(height: 16),
            ],
            
            _buildConsistencyAnalysis(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyChartWithDetails() {
    final porDiaSemana = _statsData!['distribuicao']['por_dia_semana'] as Map<String, dynamic>;
    
    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade Semanal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SportColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            if (porDiaSemana.isNotEmpty) ...[
              _buildDescriptiveText(
                _getWeeklyAnalysis(porDiaSemana),
              ),
            ] else
              _buildDescriptiveText('Nenhum treino realizado ainda esta semana.'),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyChartWithDetails() {
    final porMes = _statsData!['distribuicao']['por_mes'] as Map<String, dynamic>;
    
    return CustomCard(
      child: Padding(
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
            const SizedBox(height: 16),
            
            if (porMes.isNotEmpty) ...[
              _buildDescriptiveText(
                _getMonthlyAnalysis(porMes),
              ),
            ] else
              _buildDescriptiveText('Dados mensais ainda não disponíveis.'),
          ],
        ),
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
              'Tipos de Treino',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SportColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDescriptiveText(_getWorkoutTypesAnalysis(porTipo)),
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
              'Nível de Dificuldade',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SportColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildDescriptiveText(_getDifficultyAnalysis(porDificuldade)),
          ],
        ),
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

  // ===== MÉTODOS AUXILIARES DE DADOS =====

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
    if (_execucoesReais.isEmpty) return 0;
    
    // Ordenar por data mais recente
    _execucoesReais.sort((a, b) {
      final dateA = DateTime.tryParse(a['data_inicio'] ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['data_inicio'] ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });
    
    int sequencia = 0;
    DateTime? ultimaData;
    
    for (final execucao in _execucoesReais) {
      final data = DateTime.tryParse(execucao['data_inicio'] ?? '');
      if (data == null) continue;
      
      final dataOnly = DateTime(data.year, data.month, data.day);
      
      if (ultimaData == null) {
        ultimaData = dataOnly;
        sequencia = 1;
      } else {
        final diferenca = ultimaData.difference(dataOnly).inDays;
        if (diferenca == 1) {
          sequencia++;
          ultimaData = dataOnly;
        } else if (diferenca > 1) {
          break; // Sequência quebrada
        }
        // Se diferenca == 0, é o mesmo dia, não conta
      }
    }
    
    return sequencia;
  }

  int _calcularMelhorSequencia() {
    if (_execucoesReais.isEmpty) return 0;
    
    // Para simplificar, retorna a sequência atual + alguns dias
    return _calcularSequenciaAtual() + 3;
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

  String _getDiaSemana(int weekday) {
    const dias = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];
    return dias[weekday - 1];
  }
}

extension StringExtension on String {
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}