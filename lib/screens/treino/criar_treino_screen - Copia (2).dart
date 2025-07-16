import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/treino_model.dart';
import '../../core/services/treino_service.dart';

class CriarTreinoScreen extends StatefulWidget {
  final TreinoModel? treinoParaEditar;

  const CriarTreinoScreen({
    super.key,
    this.treinoParaEditar,
  });

  @override
  State<CriarTreinoScreen> createState() => _CriarTreinoScreenState();
}

class _CriarTreinoScreenState extends State<CriarTreinoScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Estado do formulário
  String _tipoTreino = 'Musculação';
  String _dificuldade = 'iniciante';
  List<ExercicioModel> _exercicios = [];
  bool _isLoading = false;
  bool _isSaving = false;

  // Opções para dropdowns
  final List<String> _tiposTreino = [
    'Musculação',
    'Cardio',
    'Funcional',
    'CrossFit',
    'Yoga',
    'Pilates',
    'Calistenia',
    'Natação',
    'Corrida',
    'Ciclismo',
  ];

  final List<Map<String, dynamic>> _dificuldades = [
    {'value': 'iniciante', 'label': 'Iniciante', 'color': Colors.green},
    {'value': 'intermediario', 'label': 'Intermediário', 'color': Colors.orange},
    {'value': 'avancado', 'label': 'Avançado', 'color': Colors.red},
  ];

  @override
  void initState() {
    super.initState();
    
    // Configurar status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    _setupAnimations();
    _initializeForm();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nomeController.dispose();
    _descricaoController.dispose();
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

  /// Inicializar formulário (edição ou novo)
  void _initializeForm() {
    if (widget.treinoParaEditar != null) {
      final treino = widget.treinoParaEditar!;
      _nomeController.text = treino.nomeTreino;
      _descricaoController.text = treino.descricao ?? '';
      _tipoTreino = treino.tipoTreino;
      _dificuldade = treino.dificuldade ?? 'iniciante';
      _exercicios = List.from(treino.exercicios);
    }
  }

  /// Validar formulário
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (_exercicios.isEmpty) {
      _showSnackBar(
        'Adicione pelo menos um exercício ao treino',
        isError: true,
      );
      return false;
    }

    return true;
  }

  /// Salvar treino
  Future<void> _salvarTreino() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final treino = TreinoModel.novo(
        nomeTreino: _nomeController.text.trim(),
        tipoTreino: _tipoTreino,
        descricao: _descricaoController.text.trim().isNotEmpty 
            ? _descricaoController.text.trim() 
            : null,
        dificuldade: _dificuldade,
        exercicios: _exercicios,
      );

      print('🚀 Salvando treino: ${treino.nomeTreino}');
      print('📊 Total de exercícios: ${treino.exercicios.length}');

      // ✅ Chamada real para a API
      final result = await TreinoService.criarTreino(treino);
      
      if (result.success) {
        _showSnackBar(result.message ?? 'Treino criado com sucesso!');
        
        // Voltar para tela anterior com o treino criado
        Navigator.of(context).pop(result.data);
      } else {
        _showSnackBar(
          result.message ?? 'Erro ao criar treino',
          isError: true,
        );
      }

    } catch (e) {
      print('❌ Erro ao salvar treino: $e');
      _showSnackBar(
        'Erro ao salvar treino: $e',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  /// Adicionar exercício
  void _adicionarExercicio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdicionarExercicioSheet(
        onExercicioAdicionado: (exercicio) {
          setState(() {
            _exercicios.add(exercicio.copyWith(ordem: _exercicios.length + 1));
          });
        },
      ),
    );
  }

  /// Remover exercício
  void _removerExercicio(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover Exercício'),
        content: Text('Tem certeza que deseja remover "${_exercicios[index].nomeExercicio}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _exercicios.removeAt(index);
                // Reordenar exercícios
                for (int i = 0; i < _exercicios.length; i++) {
                  _exercicios[i] = _exercicios[i].copyWith(ordem: i + 1);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  /// Mostrar SnackBar
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Widget do formulário principal
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do treino
          TextFormField(
            controller: _nomeController,
            decoration: InputDecoration(
              labelText: 'Nome do Treino *',
              hintText: 'Ex: Treino Push, Cardio Intenso...',
              prefixIcon: const Icon(Icons.fitness_center),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nome do treino é obrigatório';
              }
              if (value.trim().length < 3) {
                return 'Nome deve ter pelo menos 3 caracteres';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 16),
          
          // Tipo de treino
          DropdownButtonFormField<String>(
            value: _tipoTreino,
            decoration: InputDecoration(
              labelText: 'Tipo de Treino',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _tiposTreino.map<DropdownMenuItem<String>>((String tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Text(tipo),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _tipoTreino = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Dificuldade
          DropdownButtonFormField<String>(
            value: _dificuldade,
            decoration: InputDecoration(
              labelText: 'Dificuldade',
              prefixIcon: const Icon(Icons.trending_up),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _dificuldades.map<DropdownMenuItem<String>>((dif) {
              return DropdownMenuItem<String>(
                value: dif['value'] as String,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: dif['color'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(dif['label'] as String),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _dificuldade = value!;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Descrição
          TextFormField(
            controller: _descricaoController,
            decoration: InputDecoration(
              labelText: 'Descrição (Opcional)',
              hintText: 'Descreva os objetivos do treino...',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
    );
  }

  /// Widget da lista de exercícios
  Widget _buildExerciciosList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.list, color: Color(0xFF667eea)),
            const SizedBox(width: 8),
            Text(
              'Exercícios (${_exercicios.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _adicionarExercicio,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF667eea),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        if (_exercicios.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum exercício adicionado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Toque em "Adicionar" para incluir exercícios',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_exercicios.length, (index) {
            final exercicio = _exercicios[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF667eea).withOpacity(0.1),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF667eea),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  exercicio.nomeExercicio,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (exercicio.grupoMuscular != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        exercicio.grupoMuscular!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      exercicio.textoExecucaoCalculado,
                      style: const TextStyle(
                        color: Color(0xFF667eea),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  onPressed: () => _removerExercicio(index),
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red,
                ),
              ),
            );
          }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdicao = widget.treinoParaEditar != null;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isEdicao ? 'Editar Treino' : 'Criar Treino',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _salvarTreino,
              child: const Text(
                'Salvar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header colorido
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 24,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isEdicao ? 'Edite seu treino' : 'Monte seu treino personalizado',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Conteúdo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Formulário
                    _buildForm(),
                    
                    const SizedBox(height: 32),
                    
                    // Lista de exercícios
                    _buildExerciciosList(),
                    
                    const SizedBox(height: 100), // Espaço para FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _exercicios.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _isSaving ? null : _salvarTreino,
              backgroundColor: const Color(0xFF667eea),
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isSaving ? 'Salvando...' : 'Salvar Treino'),
            )
          : FloatingActionButton(
              onPressed: _adicionarExercicio,
              backgroundColor: const Color(0xFF667eea),
              child: const Icon(Icons.add),
            ),
    );
  }
}

/// Sheet para adicionar exercício
class _AdicionarExercicioSheet extends StatefulWidget {
  final Function(ExercicioModel) onExercicioAdicionado;

  const _AdicionarExercicioSheet({
    required this.onExercicioAdicionado,
  });

  @override
  State<_AdicionarExercicioSheet> createState() => _AdicionarExercicioSheetState();
}

class _AdicionarExercicioSheetState extends State<_AdicionarExercicioSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _observacoesController = TextEditingController();
  
  String _tipoExecucao = 'repeticao';
  String? _grupoMuscular;
  int _series = 3;
  int _repeticoes = 12;
  int _tempoExecucao = 30; // segundos
  int _tempoDescanso = 60; // segundos
  double _peso = 0.0;
  String _unidadePeso = 'kg';

  final List<String> _gruposMusculares = [
    'Peito',
    'Costas',
    'Ombros',
    'Braços',
    'Pernas',
    'Glúteos',
    'Abdômen',
    'Cardio',
    'Funcional',
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _adicionarExercicio() {
    if (!_formKey.currentState!.validate()) return;

    final exercicio = ExercicioModel.novo(
      nomeExercicio: _nomeController.text.trim(),
      descricao: _descricaoController.text.trim().isNotEmpty 
          ? _descricaoController.text.trim() 
          : null,
      grupoMuscular: _grupoMuscular,
      tipoExecucao: _tipoExecucao,
      series: _series,
      repeticoes: _tipoExecucao == 'repeticao' ? _repeticoes : null,
      tempoExecucao: _tipoExecucao == 'tempo' ? _tempoExecucao : null,
      tempoDescanso: _tempoDescanso,
      peso: _peso > 0 ? _peso : null,
      unidadePeso: _unidadePeso,
      observacoes: _observacoesController.text.trim().isNotEmpty 
          ? _observacoesController.text.trim() 
          : null,
    );

    widget.onExercicioAdicionado(exercicio);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.add_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text(
                      'Adicionar Exercício',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              
              // Formulário
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nome do exercício
                        TextFormField(
                          controller: _nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome do Exercício *',
                            hintText: 'Ex: Supino Reto, Agachamento...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nome é obrigatório';
                            }
                            return null;
                          },
                          textCapitalization: TextCapitalization.words,
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Grupo muscular
                        DropdownButtonFormField<String>(
                          value: _grupoMuscular,
                          decoration: InputDecoration(
                            labelText: 'Grupo Muscular',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _gruposMusculares.map<DropdownMenuItem<String>>((String grupo) {
                            return DropdownMenuItem<String>(
                              value: grupo,
                              child: Text(grupo),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _grupoMuscular = value;
                            });
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Tipo de execução
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Repetições'),
                                value: 'repeticao',
                                groupValue: _tipoExecucao,
                                onChanged: (value) {
                                  setState(() {
                                    _tipoExecucao = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Tempo'),
                                value: 'tempo',
                                groupValue: _tipoExecucao,
                                onChanged: (value) {
                                  setState(() {
                                    _tipoExecucao = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Configurações específicas
                        if (_tipoExecucao == 'repeticao') ...[
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _series.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Séries',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _series = int.tryParse(value) ?? _series;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  initialValue: _repeticoes.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Repetições',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _repeticoes = int.tryParse(value) ?? _repeticoes;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          TextFormField(
                            initialValue: _tempoExecucao.toString(),
                            decoration: InputDecoration(
                              labelText: 'Tempo de Execução (segundos)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              _tempoExecucao = int.tryParse(value) ?? _tempoExecucao;
                            },
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Tempo de descanso
                        TextFormField(
                          initialValue: _tempoDescanso.toString(),
                          decoration: InputDecoration(
                            labelText: 'Descanso (segundos)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            _tempoDescanso = int.tryParse(value) ?? _tempoDescanso;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Peso
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: _peso.toString(),
                                decoration: InputDecoration(
                                  labelText: 'Peso (opcional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  _peso = double.tryParse(value) ?? _peso;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _unidadePeso,
                                decoration: InputDecoration(
                                  labelText: 'Unidade',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: ['kg', 'lbs'].map((unidade) {
                                  return DropdownMenuItem(
                                    value: unidade,
                                    child: Text(unidade),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _unidadePeso = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Observações
                        TextFormField(
                          controller: _observacoesController,
                          decoration: InputDecoration(
                            labelText: 'Observações (opcional)',
                            hintText: 'Dicas de execução, variações...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botão adicionar
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _adicionarExercicio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              padding: const EdgeInsets.all(16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Adicionar Exercício',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
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
}