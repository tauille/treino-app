import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/treino_provider.dart';
import '../../models/treino_model.dart';
import '../../widgets/common/loading_button.dart';
import '../../widgets/common/custom_card.dart';

class CriarTreinoScreen extends StatefulWidget {
  const CriarTreinoScreen({Key? key}) : super(key: key);

  @override
  State<CriarTreinoScreen> createState() => _CriarTreinoScreenState();
}

class _CriarTreinoScreenState extends State<CriarTreinoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  
  String _tipoTreino = 'Musculação';
  String _dificuldade = 'iniciante';

  final List<String> _tiposTreino = [
    'Musculação',
    'Cardio',
    'Funcional',
    'Yoga',
    'Pilates',
    'Crossfit',
    'Calistenia',
    'Natação',
  ];

  final List<Map<String, dynamic>> _dificuldades = [
    {
      'value': 'iniciante',
      'label': 'Iniciante',
      'color': Colors.green,
      'icon': Icons.accessibility_new,
      'description': 'Para quem está começando'
    },
    {
      'value': 'intermediario',
      'label': 'Intermediário',
      'color': Colors.orange,
      'icon': Icons.fitness_center,
      'description': 'Já tem experiência'
    },
    {
      'value': 'avancado',
      'label': 'Avançado',
      'color': Colors.red,
      'icon': Icons.local_fire_department,
      'description': 'Atleta experiente'
    },
  ];

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _criarTreino() async {
    if (!_formKey.currentState!.validate()) return;

    final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);

    try {
      // Criar modelo do treino
      final novoTreino = TreinoModel(
        id: 0, // Será definido pelo backend
        nomeTreino: _nomeController.text.trim(),
        tipoTreino: _tipoTreino,
        descricao: _descricaoController.text.trim().isEmpty 
            ? null 
            : _descricaoController.text.trim(),
        dificuldade: _dificuldade,
        status: 'ativo',
        totalExercicios: 0,
        createdAt: DateTime.now(),
      );

      print('🚀 Criando treino: ${novoTreino.nomeTreino}');

      final treinoCriado = await treinoProvider.criarTreino(novoTreino);
      
      if (treinoCriado != null && mounted) {
        _mostrarSucesso(treinoCriado);
      } else if (mounted && treinoProvider.hasError) {
        _mostrarErro(treinoProvider.errorMessage ?? 'Erro desconhecido');
      }
    } catch (e) {
      print('❌ Erro ao criar treino: $e');
      if (mounted) {
        _mostrarErro(e.toString());
      }
    }
  }

  void _mostrarSucesso(TreinoModel treino) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        title: const Text('Treino Criado!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${treino.nomeTreino} foi criado com sucesso!'),
            const SizedBox(height: 8),
            Text(
              'ID: ${treino.id}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.green[700],
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Agora você pode adicionar exercícios ao seu treino!',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha dialog
              Navigator.of(context).pop(treino); // Volta com resultado
            },
            child: const Text('Continuar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fecha dialog
              // TODO: Navegar para tela de adicionar exercícios
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Adicionar exercícios - Em breve!'),
                  backgroundColor: Colors.orange,
                ),
              );
              Navigator.of(context).pop(treino); // Volta com resultado
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
            ),
            child: const Text('Adicionar Exercícios'),
          ),
        ],
      ),
    );
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tentar Novamente',
          textColor: Colors.white,
          onPressed: () => _criarTreino(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Criar Novo Treino'),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header com ícone
              CustomCard.hero(
                child: const Column(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.white, size: 48),
                    SizedBox(height: 12),
                    Text(
                      'Vamos criar seu treino!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Preencha as informações abaixo',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Nome do Treino
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Nome do Treino', Icons.edit),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nomeController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Treino Push, Legs, Pull...',
                        prefixIcon: const Icon(Icons.title, color: Color(0xFF667eea)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nome é obrigatório';
                        }
                        if (value.trim().length < 3) {
                          return 'Nome deve ter pelo menos 3 caracteres';
                        }
                        return null;
                      },
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tipo de Treino
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Tipo de Treino', Icons.category),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _tipoTreino,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.sports_gymnastics, color: Color(0xFF667eea)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _tiposTreino.map((tipo) {
                        return DropdownMenuItem(
                          value: tipo,
                          child: Text(tipo),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _tipoTreino = value!);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Dificuldade
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Nível de Dificuldade', Icons.trending_up),
                    const SizedBox(height: 16),
                    ...(_dificuldades.map((dif) {
                      final isSelected = _dificuldade == dif['value'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: CustomCard.selectable(
                          isSelected: isSelected,
                          selectedColor: (dif['color'] as Color).withOpacity(0.1),
                          onTap: () => setState(() => _dificuldade = dif['value']),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? dif['color'] 
                                      : (dif['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  dif['icon'],
                                  color: isSelected 
                                      ? Colors.white 
                                      : dif['color'],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      dif['label'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? dif['color'] : Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      dif['description'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: dif['color'],
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList()),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Descrição
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Descrição (Opcional)', Icons.description),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descricaoController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Descreva o objetivo do treino...',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 40),
                          child: Icon(Icons.notes, color: Color(0xFF667eea)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Botão Criar
              Consumer<TreinoProvider>(
                builder: (context, treinoProvider, child) {
                  return LoadingButton.primary(
                    onPressed: treinoProvider.isLoadingCreate ? null : _criarTreino,
                    isLoading: treinoProvider.isLoadingCreate,
                    loadingText: 'Criando treino...',
                    fullWidth: true,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle),
                        SizedBox(width: 8),
                        Text('Criar Treino', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Botão Preview
              OutlineLoadingButton(
                onPressed: _mostrarPreview,
                borderColor: const Color(0xFF667eea),
                fullWidth: true,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.preview),
                    SizedBox(width: 8),
                    Text('Visualizar Preview'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Dicas
              CustomCard.flat(
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Dicas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Use nomes descritivos como "Push", "Pull", "Legs"\n'
                      '• A descrição ajuda a lembrar do objetivo do treino\n'
                      '• Você pode editar essas informações depois',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  void _mostrarPreview() {
    final dificuldadeSelecionada = _dificuldades.firstWhere((d) => d['value'] == _dificuldade);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle do modal
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Título
            const Text(
              'Preview do Treino',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Card do preview
            Expanded(
              child: CustomCard.hero(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.fitness_center, color: Colors.white, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _nomeController.text.trim().isEmpty 
                                ? 'Nome do treino' 
                                : _nomeController.text.trim(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildPreviewRow(Icons.category, 'Tipo', _tipoTreino),
                    const SizedBox(height: 12),
                    
                    _buildPreviewRow(
                      dificuldadeSelecionada['icon'],
                      'Dificuldade',
                      dificuldadeSelecionada['label'],
                    ),
                    
                    if (_descricaoController.text.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildPreviewRow(Icons.description, 'Descrição', _descricaoController.text.trim()),
                    ],

                    const Spacer(),
                    
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.white70, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Pronto para adicionar exercícios!',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}