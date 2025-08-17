import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/treino_model.dart';
import '../../providers/treino_provider.dart';

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
    {'value': 'iniciante', 'label': 'Iniciante', 'color': const Color(0xFF10B981)},
    {'value': 'intermediario', 'label': 'Intermediário', 'color': const Color(0xFF3B82F6)},
    {'value': 'avancado', 'label': 'Avançado', 'color': const Color(0xFFF59E0B)},
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

  /// 🔧 CORRIGIDO: Inicializar formulário (edição ou novo)
  void _initializeForm() {
    if (widget.treinoParaEditar != null) {
      final treino = widget.treinoParaEditar!;
      
      // ✅ GARANTIR que os campos sejam preenchidos
      setState(() {
        _nomeController.text = treino.nomeTreino;
        _descricaoController.text = treino.descricao ?? '';
        _tipoTreino = treino.tipoTreino;
        _dificuldade = _normalizarDificuldade(treino.dificuldade ?? 'iniciante');
        _exercicios = List.from(treino.exercicios);
      });
      
      print('🔧 Editando treino: ${treino.nomeTreino}');
      print('🔧 Tipo: $_tipoTreino');
      print('🔧 Dificuldade: $_dificuldade');
      print('🔧 Exercícios: ${_exercicios.length}');
    }
  }

  /// Normalizar dificuldade para valores consistentes
  String _normalizarDificuldade(String dificuldade) {
    switch (dificuldade.toLowerCase()) {
      case 'iniciante':
        return 'iniciante';
      case 'intermediario':
      case 'intermediário':
        return 'intermediario';
      case 'avancado':
      case 'avançado':
        return 'avancado';
      default:
        return 'iniciante';
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

  /// 🚀 MÉTODO PRINCIPAL CORRIGIDO: Salvar treino usando PROVIDER
  Future<void> _salvarTreino() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // ✅ OBTER PROVIDER
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      
      final isEdicao = widget.treinoParaEditar != null;
      
      print('🚀 ${isEdicao ? "EDITANDO" : "CRIANDO"} treino: ${_nomeController.text}');
      print('📊 Total de exercícios locais: ${_exercicios.length}');

      if (isEdicao) {
        // ========== EDIÇÃO ==========
        await _editarTreino(treinoProvider);
      } else {
        // ========== CRIAÇÃO ==========
        await _criarNovoTreino(treinoProvider);
      }

    } catch (e) {
      final acao = widget.treinoParaEditar != null ? 'editar' : 'criar';
      print('❌ Erro ao $acao treino: $e');
      _showSnackBar(
        'Erro ao $acao treino: $e',
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

  /// 🆕 CRIAR NOVO TREINO - Fluxo correto: Treino → Exercícios
  Future<void> _criarNovoTreino(TreinoProvider treinoProvider) async {
    print('🆕 === INICIANDO CRIAÇÃO DE NOVO TREINO ===');
    
    // 1️⃣ CRIAR TREINO SEM EXERCÍCIOS PRIMEIRO
    final treinoSemExercicios = TreinoModel(
      nomeTreino: _nomeController.text.trim(),
      tipoTreino: _tipoTreino,
      descricao: _descricaoController.text.trim().isNotEmpty 
          ? _descricaoController.text.trim() 
          : null,
      dificuldade: _dificuldade,
      exercicios: [], // ✅ VAZIO - exercícios criados depois
    );

    print('🎯 PASSO 1: Criando treino básico...');
    final resultTreino = await treinoProvider.criarTreino(treinoSemExercicios);
    
    if (!resultTreino.success || resultTreino.data == null) {
      throw Exception(resultTreino.message ?? 'Erro ao criar treino');
    }

    final treinoCriado = resultTreino.data!;
    print('✅ PASSO 1 CONCLUÍDO: Treino criado com ID ${treinoCriado.id}');

    // 2️⃣ CRIAR EXERCÍCIOS UM POR UM
    if (_exercicios.isNotEmpty) {
      print('🎯 PASSO 2: Criando ${_exercicios.length} exercícios...');
      
      int exerciciosOk = 0;
      int exerciciosErro = 0;

      for (int i = 0; i < _exercicios.length; i++) {
        final exercicio = _exercicios[i];
        
        try {
          print('  ➕ Criando exercício ${i + 1}: ${exercicio.nomeExercicio}');
          
          final resultExercicio = await treinoProvider.criarExercicio(
            treinoCriado.id!,
            exercicio.copyWith(ordem: i + 1),
          );
          
          if (resultExercicio.success) {
            exerciciosOk++;
            print('  ✅ Exercício ${i + 1} criado com sucesso');
          } else {
            exerciciosErro++;
            print('  ❌ Erro no exercício ${i + 1}: ${resultExercicio.message}');
          }
        } catch (e) {
          exerciciosErro++;
          print('  ❌ Exceção no exercício ${i + 1}: $e');
        }
      }

      print('📊 RESULTADO: $exerciciosOk sucesso, $exerciciosErro erros');
      
      if (exerciciosErro > 0) {
        _showSnackBar(
          'Treino criado, mas $exerciciosErro exercícios falharam',
          isError: true,
        );
      }
    }

    // 3️⃣ SUCESSO FINAL
    print('🎉 TREINO CRIADO COM SUCESSO!');
    _showSnackBar('Treino "${treinoCriado.nomeTreino}" criado com sucesso!');
    
    // ✅ CORREÇÃO: REFRESH AUTOMÁTICO
    await treinoProvider.recarregar();
    print('🔄 Lista de treinos atualizada automaticamente');
    
    // ✅ VOLTAR COM O TREINO CRIADO
    Navigator.of(context).pop(treinoCriado);
  }

  /// ✏️ EDITAR TREINO EXISTENTE - CORRIGIDO COM SINCRONIZAÇÃO DE EXERCÍCIOS
  Future<void> _editarTreino(TreinoProvider treinoProvider) async {
    print('✏️ === INICIANDO EDIÇÃO COMPLETA DE TREINO ===');
    
    final treinoOriginal = widget.treinoParaEditar!;
    final exerciciosOriginais = treinoOriginal.exercicios;
    final exerciciosAtuais = _exercicios;
    
    print('📊 ANÁLISE DOS EXERCÍCIOS:');
    print('   • Originais: ${exerciciosOriginais.length}');
    print('   • Atuais: ${exerciciosAtuais.length}');

    // 1️⃣ ATUALIZAR DADOS BÁSICOS DO TREINO PRIMEIRO
    final treinoParaAtualizar = TreinoModel(
      id: treinoOriginal.id,
      nomeTreino: _nomeController.text.trim(),
      tipoTreino: _tipoTreino,
      descricao: _descricaoController.text.trim().isNotEmpty 
          ? _descricaoController.text.trim() 
          : null,
      dificuldade: _dificuldade,
      exercicios: exerciciosOriginais, // Manter originais por enquanto
      duracaoEstimada: treinoOriginal.duracaoEstimada,
      totalExercicios: treinoOriginal.totalExercicios,
    );

    print('🎯 PASSO 1: Atualizando dados básicos do treino...');
    final resultTreino = await treinoProvider.atualizarTreino(treinoParaAtualizar);
    
    if (!resultTreino.success) {
      throw Exception(resultTreino.message ?? 'Erro ao atualizar treino');
    }
    print('✅ PASSO 1 CONCLUÍDO: Dados básicos atualizados');

    // 2️⃣ SINCRONIZAR EXERCÍCIOS - IDENTIFICAR MUDANÇAS
    await _sincronizarExercicios(treinoProvider, treinoOriginal.id!, exerciciosOriginais, exerciciosAtuais);

    // 3️⃣ SUCESSO FINAL
    print('🎉 EDIÇÃO COMPLETA CONCLUÍDA!');
    _showSnackBar('Treino atualizado com sucesso!');
    
    // ✅ CORREÇÃO: REFRESH AUTOMÁTICO
    await treinoProvider.recarregar();
    print('🔄 Lista de treinos atualizada automaticamente');
    
    // ✅ VOLTAR COM INDICAÇÃO DE SUCESSO
    Navigator.of(context).pop(resultTreino.data);
  }

  /// 🔄 SINCRONIZAR EXERCÍCIOS - MÉTODO PRINCIPAL PARA CRUD
  Future<void> _sincronizarExercicios(
    TreinoProvider treinoProvider,
    int treinoId,
    List<ExercicioModel> exerciciosOriginais,
    List<ExercicioModel> exerciciosAtuais,
  ) async {
    print('🔄 PASSO 2: Sincronizando exercícios...');
    
    int exerciciosOk = 0;
    int exerciciosErro = 0;

    // 📋 IDENTIFICAR EXERCÍCIOS PARA EXCLUIR
    final exerciciosParaExcluir = exerciciosOriginais.where((original) {
      return !exerciciosAtuais.any((atual) => 
          atual.id != null && atual.id == original.id);
    }).toList();

    // 📋 IDENTIFICAR EXERCÍCIOS PARA CRIAR (novos, sem ID)
    final exerciciosParaCriar = exerciciosAtuais.where((atual) {
      return atual.id == null;
    }).toList();

    // 📋 IDENTIFICAR EXERCÍCIOS PARA ATUALIZAR (existentes com mudanças)
    final exerciciosParaAtualizar = exerciciosAtuais.where((atual) {
      if (atual.id == null) return false; // Novos exercícios já estão na lista de criar
      
      // Encontrar o exercício original correspondente
      final original = exerciciosOriginais.firstWhere(
        (orig) => orig.id == atual.id,
        orElse: () => ExercicioModel(nomeExercicio: '', tipoExecucao: 'repeticao'),
      );
      
      // Verificar se houve mudanças
      return original.nomeExercicio != atual.nomeExercicio ||
             original.series != atual.series ||
             original.repeticoes != atual.repeticoes ||
             original.tempoExecucao != atual.tempoExecucao ||
             original.peso != atual.peso ||
             original.grupoMuscular != atual.grupoMuscular;
    }).toList();

    print('📊 OPERAÇÕES IDENTIFICADAS:');
    print('   🗑️ Excluir: ${exerciciosParaExcluir.length}');
    print('   ➕ Criar: ${exerciciosParaCriar.length}');  
    print('   ✏️ Atualizar: ${exerciciosParaAtualizar.length}');

    // 🗑️ EXCLUIR EXERCÍCIOS REMOVIDOS - ✅ CORRIGIDO
    for (final exercicio in exerciciosParaExcluir) {
      try {
        print('  🗑️ Excluindo: ${exercicio.nomeExercicio} (ID: ${exercicio.id})');
        // ✅ CORREÇÃO: Passar treinoId como primeiro parâmetro
        final result = await treinoProvider.deletarExercicio(treinoId, exercicio.id!);
        
        if (result.success) {
          exerciciosOk++;
          print('    ✅ Exercício excluído com sucesso');
        } else {
          exerciciosErro++;
          print('    ❌ Erro ao excluir: ${result.message}');
        }
      } catch (e) {
        exerciciosErro++;
        print('    ❌ Exceção ao excluir: $e');
      }
    }

    // ➕ CRIAR NOVOS EXERCÍCIOS
    for (int i = 0; i < exerciciosParaCriar.length; i++) {
      final exercicio = exerciciosParaCriar[i];
      try {
        print('  ➕ Criando: ${exercicio.nomeExercicio}');
        final result = await treinoProvider.criarExercicio(
          treinoId,
          exercicio.copyWith(ordem: exerciciosOriginais.length + i + 1),
        );
        
        if (result.success) {
          exerciciosOk++;
          print('    ✅ Exercício criado com sucesso');
        } else {
          exerciciosErro++;
          print('    ❌ Erro ao criar: ${result.message}');
        }
      } catch (e) {
        exerciciosErro++;
        print('    ❌ Exceção ao criar: $e');
      }
    }

    // ✏️ ATUALIZAR EXERCÍCIOS MODIFICADOS - ✅ CORRIGIDO
    for (final exercicio in exerciciosParaAtualizar) {
      try {
        print('  ✏️ Atualizando: ${exercicio.nomeExercicio} (ID: ${exercicio.id})');
        // ✅ CORREÇÃO: Usar método correto para atualizar
        final result = await treinoProvider.atualizarExercicio(treinoId, exercicio.id!, exercicio);
        
        if (result.success) {
          exerciciosOk++;
          print('    ✅ Exercício atualizado com sucesso');
        } else {
          exerciciosErro++;
          print('    ❌ Erro ao atualizar: ${result.message}');
        }
      } catch (e) {
        exerciciosErro++;
        print('    ❌ Exceção ao atualizar: $e');
      }
    }

    print('📊 RESULTADO DA SINCRONIZAÇÃO:');
    print('   ✅ Sucessos: $exerciciosOk');
    print('   ❌ Erros: $exerciciosErro');

    if (exerciciosErro > 0) {
      _showSnackBar(
        'Treino salvo, mas $exerciciosErro exercícios falharam',
        isError: true,
      );
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
          print('➕ Exercício adicionado localmente: ${exercicio.nomeExercicio}');
        },
      ),
    );
  }

  /// Remover exercício
  void _removerExercicio(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Remover Exercício',
          style: TextStyle(color: Color(0xFF0F172A)),
        ),
        content: Text(
          'Tem certeza que deseja remover "${_exercicios[index].nomeExercicio}"?',
          style: const TextStyle(color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final exercicioRemovido = _exercicios.removeAt(index);
                print('🗑️ Exercício removido localmente: ${exercicioRemovido.nomeExercicio}');
                
                // Reordenar exercícios
                for (int i = 0; i < _exercicios.length; i++) {
                  _exercicios[i] = _exercicios[i].copyWith(ordem: i + 1);
                }
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
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
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF6366F1),
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
            style: const TextStyle(color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              labelText: 'Nome do Treino *',
              hintText: 'Ex: Treino Push, Cardio Intenso...',
              prefixIcon: const Icon(Icons.fitness_center, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
            style: const TextStyle(color: Color(0xFF0F172A)),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'Tipo de Treino',
              prefixIcon: const Icon(Icons.category, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            items: _tiposTreino.map<DropdownMenuItem<String>>((String tipo) {
              return DropdownMenuItem<String>(
                value: tipo,
                child: Text(
                  tipo,
                  style: const TextStyle(color: Color(0xFF0F172A)),
                ),
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
            style: const TextStyle(color: Color(0xFF0F172A)),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              labelText: 'Dificuldade',
              prefixIcon: const Icon(Icons.trending_up, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
                    Text(
                      dif['label'] as String,
                      style: const TextStyle(color: Color(0xFF0F172A)),
                    ),
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
            style: const TextStyle(color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              labelText: 'Descrição (Opcional)',
              hintText: 'Descreva os objetivos do treino...',
              prefixIcon: const Icon(Icons.description, color: Color(0xFF6366F1)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
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
            const Icon(Icons.list, color: Color(0xFF6366F1)),
            const SizedBox(width: 8),
            Text(
              'Exercícios (${_exercicios.length})',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _adicionarExercicio,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6366F1),
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
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: Color(0xFF94A3B8),
                ),
                SizedBox(height: 12),
                Text(
                  'Nenhum exercício adicionado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Toque em "Adicionar" para incluir exercícios',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: List.generate(_exercicios.length, (index) {
              final exercicio = _exercicios[index];
              return Container(
                key: ValueKey(exercicio.nomeExercicio + index.toString()),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6366F1).withOpacity(0.2),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    exercicio.nomeExercicio,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exercicio.grupoMuscular != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          exercicio.grupoMuscular!,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        exercicio.textoExecucaoCalculado,
                        style: const TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    onPressed: () => _removerExercicio(index),
                    icon: const Icon(Icons.delete_outline),
                    color: const Color(0xFFEF4444),
                  ),
                ),
              );
            }),
          ),
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
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isSaving)
            IconButton(
              onPressed: _salvarTreino,
              icon: const Icon(
                Icons.check_rounded,
                color: Color(0xFF6366F1),
              ),
              tooltip: 'Salvar',
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
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
          ? FloatingActionButton(
              onPressed: _isSaving ? null : _salvarTreino,
              backgroundColor: const Color(0xFF6366F1),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.check_rounded),
            )
          : FloatingActionButton(
              onPressed: _adicionarExercicio,
              backgroundColor: const Color(0xFF6366F1),
              child: const Icon(Icons.add_rounded),
            ),
    );
  }
}

/// Sheet para adicionar exercício - SIMPLIFICADO
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

    final exercicio = ExercicioModel(
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
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  borderRadius: BorderRadius.only(
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
                          style: const TextStyle(color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            labelText: 'Nome do Exercício *',
                            hintText: 'Ex: Supino Reto, Agachamento...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
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
                          style: const TextStyle(color: Color(0xFF0F172A)),
                          dropdownColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: 'Grupo Muscular',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          items: _gruposMusculares.map<DropdownMenuItem<String>>((String grupo) {
                            return DropdownMenuItem<String>(
                              value: grupo,
                              child: Text(
                                grupo,
                                style: const TextStyle(color: Color(0xFF0F172A)),
                              ),
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
                                title: const Text(
                                  'Repetições',
                                  style: TextStyle(color: Color(0xFF0F172A)),
                                ),
                                value: 'repeticao',
                                groupValue: _tipoExecucao,
                                activeColor: const Color(0xFF6366F1),
                                onChanged: (value) {
                                  setState(() {
                                    _tipoExecucao = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text(
                                  'Tempo',
                                  style: TextStyle(color: Color(0xFF0F172A)),
                                ),
                                value: 'tempo',
                                groupValue: _tipoExecucao,
                                activeColor: const Color(0xFF6366F1),
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
                                  style: const TextStyle(color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Séries',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
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
                                  style: const TextStyle(color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Repetições',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: _series.toString(),
                                  style: const TextStyle(color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Séries',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
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
                                  initialValue: _tempoExecucao.toString(),
                                  style: const TextStyle(color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Tempo (seg)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    _tempoExecucao = int.tryParse(value) ?? _tempoExecucao;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Tempo de descanso
                        TextFormField(
                          initialValue: _tempoDescanso.toString(),
                          style: const TextStyle(color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            labelText: 'Descanso (segundos)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
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
                                style: const TextStyle(color: Color(0xFF0F172A)),
                                decoration: InputDecoration(
                                  labelText: 'Peso (opcional)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (value) {
                                  _peso = double.tryParse(value) ?? _peso;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _unidadePeso,
                                style: const TextStyle(color: Color(0xFF0F172A)),
                                dropdownColor: Colors.white,
                                decoration: InputDecoration(
                                  labelText: 'Unidade',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                ),
                                items: ['kg', 'lbs'].map((unidade) {
                                  return DropdownMenuItem(
                                    value: unidade,
                                    child: Text(
                                      unidade,
                                      style: const TextStyle(color: Color(0xFF0F172A)),
                                    ),
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
                          style: const TextStyle(color: Color(0xFF0F172A)),
                          decoration: InputDecoration(
                            labelText: 'Observações (opcional)',
                            hintText: 'Dicas de execução, variações...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          maxLines: 3,
                          textCapitalization: TextCapitalization.sentences,
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Botão adicionar
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _adicionarExercicio,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Adicionar Exercício',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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