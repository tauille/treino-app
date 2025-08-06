import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HistoricoTab extends StatefulWidget {
  const HistoricoTab({super.key});

  @override
  State<HistoricoTab> createState() => _HistoricoTabState();
}

class _HistoricoTabState extends State<HistoricoTab> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _isLoading = false;
  String _periodoSelecionado = 'Esta semana';
  
  // 🔧 CONTROLE DE DISPOSED PARA EVITAR MEMORY LEAKS
  bool _isDisposed = false;
  
  final List<String> _periodos = [
    'Esta semana',
    'Este mês',
    'Últimos 3 meses',
    'Este ano',
    'Todos',
  ];
  
  List<Map<String, dynamic>> _historico = [];
  Map<String, dynamic> _estatisticas = {};

  @override
  void initState() {
    super.initState();
    print('📊 [DEBUG] HistoricoTab initState iniciado');
    
    _setupAnimations();
    
    // 🔧 CORREÇÃO: Mover carregamento para após build completo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        print('📊 [DEBUG] PostFrameCallback - carregando histórico...');
        _carregarHistoricoSeguro();
      }
    });
  }

  @override
  void dispose() {
    print('🧹 [DEBUG] HistoricoTab dispose iniciado');
    
    // 🔧 MARCAR COMO DISPOSED PRIMEIRO
    _isDisposed = true;
    
    // Limpar animações
    _fadeController.dispose();
    
    super.dispose();
    print('✅ [DEBUG] HistoricoTab dispose finalizado');
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
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  /// 🔧 CARREGAR HISTÓRICO DE FORMA SEGURA (CORREÇÃO PRINCIPAL)
  Future<void> _carregarHistoricoSeguro() async {
    if (_isDisposed || !mounted) {
      print('⚠️ [DEBUG] Carregamento de histórico cancelado - widget disposed/unmounted');
      return;
    }
    
    print('🔄 [DEBUG] Iniciando carregamento seguro de histórico...');
    
    // 🔧 USAR FUTURE.MICROTASK PARA EVITAR setState DURANTE BUILD
    Future.microtask(() {
      if (_isDisposed || !mounted) return;
      
      setState(() {
        _isLoading = true;
      });
    });

    try {
      // Simular carregamento
      await Future.delayed(const Duration(milliseconds: 800));
      
      // 🔧 VERIFICAR SE AINDA ESTÁ MONTADO ANTES DE CONTINUAR
      if (_isDisposed || !mounted) {
        print('⚠️ [DEBUG] Widget foi disposed durante carregamento do histórico');
        return;
      }

      // Mock data - substituir por provider depois
      final historicoMock = [
        {
          'id': 1,
          'nome': 'Push Day Completo',
          'data': DateTime.now().subtract(const Duration(hours: 2)),
          'duracao': 45, // minutos
          'exercicios': 8,
          'calorias': 320,
          'status': 'completo',
          'tipo': 'Musculação',
          'observacoes': 'Treino muito produtivo!',
        },
        {
          'id': 2,
          'nome': 'Cardio HIIT',
          'data': DateTime.now().subtract(const Duration(days: 1)),
          'duracao': 30,
          'exercicios': 6,
          'calorias': 280,
          'status': 'completo',
          'tipo': 'HIIT',
          'observacoes': '',
        },
        {
          'id': 3,
          'nome': 'Pull Day',
          'data': DateTime.now().subtract(const Duration(days: 2)),
          'duracao': 38,
          'exercicios': 7,
          'calorias': 295,
          'status': 'completo',
          'tipo': 'Musculação',
          'observacoes': 'Aumentei carga no supino',
        },
        {
          'id': 4,
          'nome': 'Yoga Flow',
          'data': DateTime.now().subtract(const Duration(days: 3)),
          'duracao': 25,
          'exercicios': 12,
          'calorias': 150,
          'status': 'parcial',
          'tipo': 'Yoga',
          'observacoes': 'Interrompido no meio',
        },
      ];

      // 🔧 USAR FUTURE.MICROTASK PARA ATUALIZAÇÃO SEGURA
      Future.microtask(() {
        if (_isDisposed || !mounted) return;
        
        setState(() {
          _historico = historicoMock;
          _calcularEstatisticas();
        });
      });
      
      print('✅ [DEBUG] Histórico carregado com sucesso: ${historicoMock.length} itens');
      
    } catch (e) {
      print('❌ [DEBUG] Erro ao carregar histórico: $e');
      
      // Handle error de forma segura
      Future.microtask(() {
        if (_isDisposed || !mounted) return;
        
        // Aqui poderia definir uma variável de erro se necessário
        // setState(() => _errorMessage = e.toString());
      });
    } finally {
      // 🔧 FINALIZAR LOADING DE FORMA SEGURA
      Future.microtask(() {
        if (_isDisposed || !mounted) return;
        
        setState(() {
          _isLoading = false;
        });
      });
      
      print('🏁 [DEBUG] Carregamento de histórico finalizado com segurança');
    }
  }

  /// Calcular estatísticas do período (sem setState direto)
  void _calcularEstatisticas() {
    final treinosCompletos = _historico.where((t) => t['status'] == 'completo').length;
    final tempoTotal = _historico.fold<int>(0, (sum, treino) => sum + (treino['duracao'] as int));
    final caloriasTotal = _historico.fold<int>(0, (sum, treino) => sum + (treino['calorias'] as int));
    final exerciciosTotal = _historico.fold<int>(0, (sum, treino) => sum + (treino['exercicios'] as int));

    // 🔧 ATUALIZAR _estatisticas SEM setState (será chamado pelo caller)
    _estatisticas = {
      'treinosCompletos': treinosCompletos,
      'tempoTotal': tempoTotal,
      'caloriasTotal': caloriasTotal,
      'exerciciosTotal': exerciciosTotal,
      'mediaMinutos': treinosCompletos > 0 ? (tempoTotal / treinosCompletos).round() : 0,
    };
  }

  /// 🔧 MÉTODO SEGURO PARA MUDANÇA DE PERÍODO
  void _alterarPeriodoSeguro(String periodo) {
    if (_isDisposed || !mounted) return;
    
    setState(() {
      _periodoSelecionado = periodo;
    });
    
    HapticFeedback.selectionClick();
    _carregarHistoricoSeguro(); // Recarregar dados
  }

  @override
  Widget build(BuildContext context) {
    // 🔧 VERIFICAÇÃO DE SEGURANÇA NO BUILD
    if (_isDisposed) {
      return const SizedBox.shrink();
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1D29),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Filtro de período
              _buildFiltroPeriodo(),
              
              // Estatísticas resumidas
              _buildEstatisticas(),
              
              // Lista do histórico
              Expanded(
                child: _buildListaHistorico(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Header (sem alterações significativas)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
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
            'HISTÓRICO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
              ),
            ),
        ],
      ),
    );
  }

  /// Filtro de período (com verificação de disposed)
  Widget _buildFiltroPeriodo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _periodos.map((periodo) {
            final isSelected = periodo == _periodoSelecionado;
            return GestureDetector(
              onTap: () {
                if (_isDisposed || !mounted) return;
                _alterarPeriodoSeguro(periodo);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF4ECDC4)
                    : const Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                      ? const Color(0xFF4ECDC4)
                      : const Color(0xFF374151),
                    width: 1,
                  ),
                ),
                child: Text(
                  periodo,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Estatísticas resumidas (sem alterações significativas)
  Widget _buildEstatisticas() {
    if (_estatisticas.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumo - $_periodoSelecionado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Treinos',
                  '${_estatisticas['treinosCompletos']}',
                  Icons.check_circle,
                  const Color(0xFF22C55E),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Tempo Total',
                  '${_formatarTempo(_estatisticas['tempoTotal'])}',
                  Icons.schedule,
                  const Color(0xFF4ECDC4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Calorias',
                  '${_estatisticas['caloriasTotal']}',
                  Icons.local_fire_department,
                  const Color(0xFFFF6B6B),
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Média/Treino',
                  '${_estatisticas['mediaMinutos']}min',
                  Icons.trending_up,
                  const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Item de estatística (sem alterações)
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Lista do histórico (com verificações de segurança)
  Widget _buildListaHistorico() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4ECDC4)),
            ),
            SizedBox(height: 16),
            Text(
              'Carregando histórico...',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_historico.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2D3A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.history,
                  color: Color(0xFF9CA3AF),
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum treino encontrado',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete seu primeiro treino\npara ver o histórico aqui',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (_isDisposed || !mounted) return;
        await _carregarHistoricoSeguro();
      },
      color: const Color(0xFF4ECDC4),
      backgroundColor: const Color(0xFF2A2D3A),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _historico.length,
        itemBuilder: (context, index) {
          // 🔧 VERIFICAÇÃO DE SEGURANÇA NO ITEM BUILDER
          if (_isDisposed || !mounted) {
            return const SizedBox.shrink();
          }
          
          final treino = _historico[index];
          return _buildCardHistorico(treino);
        },
      ),
    );
  }

  /// Card do histórico (com verificação de disposed)
  Widget _buildCardHistorico(Map<String, dynamic> treino) {
    final isCompleto = treino['status'] == 'completo';
    final data = treino['data'] as DateTime;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2D3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF374151),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_isDisposed || !mounted) return;
            print('📊 [DEBUG] Card histórico clicado: ${treino['nome']}');
            // TODO: navegar para detalhes do treino
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header do card
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleto 
                          ? const Color(0xFF22C55E).withOpacity(0.1)
                          : const Color(0xFFFBBF24).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCompleto ? Icons.check_circle : Icons.pending,
                        color: isCompleto 
                          ? const Color(0xFF22C55E) 
                          : const Color(0xFFFBBF24),
                        size: 24,
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
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatarDataHora(data),
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isCompleto 
                          ? const Color(0xFF22C55E).withOpacity(0.1)
                          : const Color(0xFFFBBF24).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCompleto ? 'COMPLETO' : 'PARCIAL',
                        style: TextStyle(
                          color: isCompleto 
                            ? const Color(0xFF22C55E) 
                            : const Color(0xFFFBBF24),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Estatísticas do treino
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.schedule,
                      '${treino['duracao']}min',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.fitness_center,
                      '${treino['exercicios']} ex',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.local_fire_department,
                      '${treino['calorias']} cal',
                    ),
                  ],
                ),
                
                // Observações (se houver)
                if (treino['observacoes']?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF374151),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.note,
                          color: Color(0xFF9CA3AF),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            treino['observacoes'],
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Chip de informação (sem alterações)
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF374151),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xFF9CA3AF),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Formatar tempo em horas e minutos (sem alterações)
  String _formatarTempo(int minutos) {
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

  /// Formatar data e hora (sem alterações)
  String _formatarDataHora(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);
    
    if (diferenca.inDays == 0) {
      return 'Hoje • ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } else if (diferenca.inDays == 1) {
      return 'Ontem • ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } else if (diferenca.inDays < 7) {
      final diasSemana = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      return '${diasSemana[data.weekday % 7]} • ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    } else {
      return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')} • ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
    }
  }
}