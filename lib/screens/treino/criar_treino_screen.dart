import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
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

  // CORRIGIDO: Sistema robusto de imagens
  final Map<String, String> _exercicioImagens = {};
  final ImagePicker _imagePicker = ImagePicker();

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

  void _initializeForm() {
    if (widget.treinoParaEditar != null) {
      final treino = widget.treinoParaEditar!;
      
      setState(() {
        _nomeController.text = treino.nomeTreino;
        _descricaoController.text = treino.descricao ?? '';
        _tipoTreino = treino.tipoTreino;
        _dificuldade = _normalizarDificuldade(treino.dificuldade ?? 'iniciante');
        _exercicios = List.from(treino.exercicios);
      });
      
      // CORRIGIDO: Carregar imagens com backup local
      _carregarImagensCompleto();
      
      print('INIT: Editando treino: ${treino.nomeTreino}');
      print('INIT: Exercícios: ${_exercicios.length}');
    }
  }

  // NOVO: Sistema completo de carregamento de imagens
  void _carregarImagensCompleto() async {
    print('=== CARREGANDO IMAGENS (SISTEMA COMPLETO) ===');
    
    for (final exercicio in _exercicios) {
      print('CARREGANDO: ${exercicio.nomeExercicio}');
      print('   imagemPath do modelo: ${exercicio.imagemPath}');
      
      String? caminhoImagem;
      
      // Método 1: Tentar carregar do modelo
      if (exercicio.imagemPath != null && exercicio.imagemPath!.isNotEmpty) {
        final file = File(exercicio.imagemPath!);
        if (await file.exists()) {
          caminhoImagem = exercicio.imagemPath!;
          print('   ✅ Carregado do modelo');
        } else {
          print('   ❌ Arquivo do modelo não existe');
        }
      }
      
      // Método 2: Tentar carregar backup local
      if (caminhoImagem == null) {
        caminhoImagem = await _recuperarImagemLocal(exercicio.nomeExercicio);
        if (caminhoImagem != null) {
          print('   ✅ Carregado do backup local');
        }
      }
      
      // Método 3: Tentar procurar no diretório de exercícios
      if (caminhoImagem == null) {
        caminhoImagem = await _procurarImagemDiretorio(exercicio.nomeExercicio);
        if (caminhoImagem != null) {
          print('   ✅ Encontrado no diretório');
        }
      }
      
      if (caminhoImagem != null) {
        setState(() {
          _exercicioImagens[exercicio.nomeExercicio] = caminhoImagem!;
        });
        
        // Salvar backup
        await _salvarImagemLocal(exercicio.nomeExercicio, caminhoImagem);
        print('   ✅ Imagem carregada e backup salvo');
      } else {
        print('   ❌ Nenhuma imagem encontrada');
      }
    }
    
    print('RESULTADO: ${_exercicioImagens.length} imagens carregadas');
    print('=== FIM CARREGAMENTO ===');
  }

  // NOVO: Backup local de imagens
  Future<void> _salvarImagemLocal(String nomeExercicio, String caminhoImagem) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('backup_img_$nomeExercicio', caminhoImagem);
    } catch (e) {
      print('Erro ao salvar backup: $e');
    }
  }

  Future<String?> _recuperarImagemLocal(String nomeExercicio) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final caminho = prefs.getString('backup_img_$nomeExercicio');
      if (caminho != null && await File(caminho).exists()) {
        return caminho;
      }
    } catch (e) {
      print('Erro ao recuperar backup: $e');
    }
    return null;
  }

  // NOVO: Procurar imagem no diretório
  Future<String?> _procurarImagemDiretorio(String nomeExercicio) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final exerciciosDir = Directory('${appDir.path}/exercicios');
      
      if (await exerciciosDir.exists()) {
        final files = exerciciosDir.listSync();
        final nomeNormalizado = nomeExercicio.replaceAll(' ', '_').toLowerCase();
        
        for (final file in files) {
          if (file is File && file.path.toLowerCase().contains(nomeNormalizado)) {
            return file.path;
          }
        }
      }
    } catch (e) {
      print('Erro ao procurar no diretório: $e');
    }
    return null;
  }

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

  Future<void> _salvarTreino() async {
    if (!_validateForm()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final treinoProvider = Provider.of<TreinoProvider>(context, listen: false);
      
      final isEdicao = widget.treinoParaEditar != null;
      
      print('${isEdicao ? "EDITANDO" : "CRIANDO"} treino: ${_nomeController.text}');
      print('Total de exercícios locais: ${_exercicios.length}');
      print('Total de imagens no mapa: ${_exercicioImagens.length}');

      if (isEdicao) {
        await _editarTreino(treinoProvider);
      } else {
        await _criarNovoTreino(treinoProvider);
      }

    } catch (e) {
      final acao = widget.treinoParaEditar != null ? 'editar' : 'criar';
      print('Erro ao $acao treino: $e');
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

  Future<void> _criarNovoTreino(TreinoProvider treinoProvider) async {
    print('=== CRIAÇÃO DE NOVO TREINO ===');
    
    final treinoSemExercicios = TreinoModel(
      nomeTreino: _nomeController.text.trim(),
      tipoTreino: _tipoTreino,
      descricao: _descricaoController.text.trim().isNotEmpty 
          ? _descricaoController.text.trim() 
          : null,
      dificuldade: _dificuldade,
      exercicios: [],
    );

    print('PASSO 1: Criando treino básico...');
    final resultTreino = await treinoProvider.criarTreino(treinoSemExercicios);
    
    if (!resultTreino.success || resultTreino.data == null) {
      throw Exception(resultTreino.message ?? 'Erro ao criar treino');
    }

    final treinoCriado = resultTreino.data!;
    print('PASSO 1 OK: Treino criado com ID ${treinoCriado.id}');

    if (_exercicios.isNotEmpty) {
      print('PASSO 2: Criando ${_exercicios.length} exercícios...');
      
      // DEBUG: Status do mapa antes de criar
      print('MAPA DE IMAGENS:');
      _exercicioImagens.forEach((key, value) {
        final exists = File(value).existsSync();
        print('  $key: $value (existe: $exists)');
      });
      
      for (int i = 0; i < _exercicios.length; i++) {
        final exercicio = _exercicios[i];
        
        try {
          print('CRIANDO EXERCÍCIO ${i + 1}: ${exercicio.nomeExercicio}');
          
          // CORRIGIDO: Garantir que imagem está sendo passada
          final imagemPath = _exercicioImagens[exercicio.nomeExercicio];
          print('  Caminho da imagem: $imagemPath');
          
          if (imagemPath != null) {
            final exists = await File(imagemPath).exists();
            print('  Arquivo existe: $exists');
            if (exists) {
              final size = await File(imagemPath).length();
              print('  Tamanho: $size bytes');
            }
          }
          
          // CORRIGIDO: Usar copyWith para garantir que imagemPath seja incluído
          final exercicioComDados = ExercicioModel(
            nomeExercicio: exercicio.nomeExercicio,
            descricao: exercicio.descricao,
            grupoMuscular: exercicio.grupoMuscular,
            tipoExecucao: exercicio.tipoExecucao,
            series: exercicio.series,
            repeticoes: exercicio.repeticoes,
            tempoExecucao: exercicio.tempoExecucao,
            tempoDescanso: exercicio.tempoDescanso,
            peso: exercicio.peso,
            unidadePeso: exercicio.unidadePeso,
            observacoes: exercicio.observacoes,
            ordem: i + 1,
            imagemPath: imagemPath, // CRITICAL: Garantir que está sendo passado
          );
          
          print('  Dados sendo enviados:');
          print('    Nome: ${exercicioComDados.nomeExercicio}');
          print('    ImagemPath: ${exercicioComDados.imagemPath}');
          print('    Ordem: ${exercicioComDados.ordem}');
          
          final resultExercicio = await treinoProvider.criarExercicio(
            treinoCriado.id!,
            exercicioComDados,
          );
          
          print('  Resposta API: ${resultExercicio.success}');
          if (!resultExercicio.success) {
            print('  Erro: ${resultExercicio.message}');
          } else {
            print('  Sucesso! Exercício criado');
            
            // Salvar backup da imagem
            if (imagemPath != null) {
              await _salvarImagemLocal(exercicio.nomeExercicio, imagemPath);
            }
          }
          
        } catch (e) {
          print('  ERRO: $e');
        }
      }
    }

    print('TREINO CRIADO COM SUCESSO!');
    _showSnackBar('Treino "${treinoCriado.nomeTreino}" criado com sucesso!');
    
    await treinoProvider.recarregar();
    Navigator.of(context).pop(treinoCriado);
  }

  Future<void> _editarTreino(TreinoProvider treinoProvider) async {
    print('=== EDIÇÃO DE TREINO ===');
    
    final treinoOriginal = widget.treinoParaEditar!;
    final exerciciosOriginais = treinoOriginal.exercicios;
    final exerciciosAtuais = _exercicios;
    
    print('Exercícios originais: ${exerciciosOriginais.length}');
    print('Exercícios atuais: ${exerciciosAtuais.length}');

    final treinoParaAtualizar = TreinoModel(
      id: treinoOriginal.id,
      nomeTreino: _nomeController.text.trim(),
      tipoTreino: _tipoTreino,
      descricao: _descricaoController.text.trim().isNotEmpty 
          ? _descricaoController.text.trim() 
          : null,
      dificuldade: _dificuldade,
      exercicios: exerciciosOriginais,
      duracaoEstimada: treinoOriginal.duracaoEstimada,
      totalExercicios: treinoOriginal.totalExercicios,
    );

    print('PASSO 1: Atualizando dados básicos...');
    final resultTreino = await treinoProvider.atualizarTreino(treinoParaAtualizar);
    
    if (!resultTreino.success) {
      throw Exception(resultTreino.message ?? 'Erro ao atualizar treino');
    }
    print('PASSO 1 OK');

    await _sincronizarExercicios(treinoProvider, treinoOriginal.id!, exerciciosOriginais, exerciciosAtuais);

    print('EDIÇÃO CONCLUÍDA!');
    _showSnackBar('Treino atualizado com sucesso!');
    
    await treinoProvider.recarregar();
    Navigator.of(context).pop(resultTreino.data);
  }

  Future<void> _sincronizarExercicios(
    TreinoProvider treinoProvider,
    int treinoId,
    List<ExercicioModel> exerciciosOriginais,
    List<ExercicioModel> exerciciosAtuais,
  ) async {
    print('PASSO 2: Sincronizando exercícios...');
    
    final exerciciosParaExcluir = exerciciosOriginais.where((original) {
      return !exerciciosAtuais.any((atual) => 
          atual.id != null && atual.id == original.id);
    }).toList();

    final exerciciosParaCriar = exerciciosAtuais.where((atual) {
      return atual.id == null;
    }).toList();

    final exerciciosParaAtualizar = exerciciosAtuais.where((atual) {
      if (atual.id == null) return false;
      
      final original = exerciciosOriginais.firstWhere(
        (orig) => orig.id == atual.id,
        orElse: () => ExercicioModel(nomeExercicio: '', tipoExecucao: 'repeticao'),
      );
      
      return original.nomeExercicio != atual.nomeExercicio ||
             original.series != atual.series ||
             original.repeticoes != atual.repeticoes ||
             original.tempoExecucao != atual.tempoExecucao ||
             original.peso != atual.peso ||
             original.grupoMuscular != atual.grupoMuscular ||
             original.imagemPath != _exercicioImagens[atual.nomeExercicio];
    }).toList();

    print('Operações:');
    print('  Excluir: ${exerciciosParaExcluir.length}');
    print('  Criar: ${exerciciosParaCriar.length}');  
    print('  Atualizar: ${exerciciosParaAtualizar.length}');

    // Excluir exercícios
    for (final exercicio in exerciciosParaExcluir) {
      try {
        print('Excluindo: ${exercicio.nomeExercicio}');
        await treinoProvider.deletarExercicio(treinoId, exercicio.id!);
      } catch (e) {
        print('Erro ao excluir: $e');
      }
    }

    // Criar exercícios
    for (int i = 0; i < exerciciosParaCriar.length; i++) {
      final exercicio = exerciciosParaCriar[i];
      try {
        print('Criando: ${exercicio.nomeExercicio}');
        
        final imagemPath = _exercicioImagens[exercicio.nomeExercicio];
        final exercicioComImagem = ExercicioModel(
          nomeExercicio: exercicio.nomeExercicio,
          descricao: exercicio.descricao,
          grupoMuscular: exercicio.grupoMuscular,
          tipoExecucao: exercicio.tipoExecucao,
          series: exercicio.series,
          repeticoes: exercicio.repeticoes,
          tempoExecucao: exercicio.tempoExecucao,
          tempoDescanso: exercicio.tempoDescanso,
          peso: exercicio.peso,
          unidadePeso: exercicio.unidadePeso,
          observacoes: exercicio.observacoes,
          ordem: exerciciosOriginais.length + i + 1,
          imagemPath: imagemPath,
        );
        
        await treinoProvider.criarExercicio(treinoId, exercicioComImagem);
        
        if (imagemPath != null) {
          await _salvarImagemLocal(exercicio.nomeExercicio, imagemPath);
        }
      } catch (e) {
        print('Erro ao criar: $e');
      }
    }

    // Atualizar exercícios
    for (final exercicio in exerciciosParaAtualizar) {
      try {
        print('Atualizando: ${exercicio.nomeExercicio}');
        
        final imagemPath = _exercicioImagens[exercicio.nomeExercicio];
        final exercicioComImagem = ExercicioModel(
          id: exercicio.id,
          nomeExercicio: exercicio.nomeExercicio,
          descricao: exercicio.descricao,
          grupoMuscular: exercicio.grupoMuscular,
          tipoExecucao: exercicio.tipoExecucao,
          series: exercicio.series,
          repeticoes: exercicio.repeticoes,
          tempoExecucao: exercicio.tempoExecucao,
          tempoDescanso: exercicio.tempoDescanso,
          peso: exercicio.peso,
          unidadePeso: exercicio.unidadePeso,
          observacoes: exercicio.observacoes,
          ordem: exercicio.ordem,
          imagemPath: imagemPath,
        );
        
        await treinoProvider.atualizarExercicio(treinoId, exercicio.id!, exercicioComImagem);
        
        if (imagemPath != null) {
          await _salvarImagemLocal(exercicio.nomeExercicio, imagemPath);
        }
      } catch (e) {
        print('Erro ao atualizar: $e');
      }
    }

    print('Sincronização concluída');
  }

  /// CORRIGIDO: Adicionar imagem com sistema robusto
  Future<void> _adicionarImagemExercicio(String nomeExercicio) async {
    try {
      print('=== ADICIONANDO IMAGEM PARA: $nomeExercicio ===');
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 800,
      );

      if (image == null) {
        print('❌ Usuário cancelou seleção');
        return;
      }
      
      print('✅ Imagem selecionada: ${image.path}');

      // Verificar arquivo original
      final originalFile = File(image.path);
      final originalSize = await originalFile.length();
      print('📏 Tamanho original: $originalSize bytes');

      // Criar diretório
      final appDir = await getApplicationDocumentsDirectory();
      final exerciciosDir = Directory('${appDir.path}/exercicios');
      
      if (!await exerciciosDir.exists()) {
        await exerciciosDir.create(recursive: true);
        print('📂 Diretório criado: ${exerciciosDir.path}');
      }

      // Gerar nome único
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(image.path);
      final fileName = '${nomeExercicio.replaceAll(' ', '_').toLowerCase()}_$timestamp$extension';
      final newPath = '${exerciciosDir.path}/$fileName';
      
      print('💾 Salvando em: $newPath');

      // Copiar arquivo
      await originalFile.copy(newPath);
      
      // Verificar se foi criado
      final newFile = File(newPath);
      final exists = await newFile.exists();
      final newSize = exists ? await newFile.length() : 0;
      
      print('✅ Arquivo criado: $exists');
      print('📏 Novo tamanho: $newSize bytes');

      if (!exists || newSize == 0) {
        throw Exception('Arquivo não foi criado corretamente');
      }

      // Salvar no mapa
      setState(() {
        _exercicioImagens[nomeExercicio] = newPath;
      });

      // Salvar backup
      await _salvarImagemLocal(nomeExercicio, newPath);

      print('✅ Imagem salva com sucesso!');
      print('🗂️ Total imagens no mapa: ${_exercicioImagens.length}');
      
      _showSnackBar('Imagem adicionada com sucesso!');
      
    } catch (e) {
      print('❌ ERRO: $e');
      _showSnackBar('Erro ao adicionar imagem: $e', isError: true);
    }
  }

  /// Remover imagem do exercício
  Future<void> _removerImagemExercicio(String nomeExercicio) async {
    try {
      final imagemPath = _exercicioImagens[nomeExercicio];
      if (imagemPath != null) {
        // Deletar arquivo físico
        final file = File(imagemPath);
        if (await file.exists()) {
          await file.delete();
        }
        
        // Remover do mapa
        setState(() {
          _exercicioImagens.remove(nomeExercicio);
        });
        
        // Remover backup
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('backup_img_$nomeExercicio');
        
        _showSnackBar('Imagem removida com sucesso!');
        print('🗑️ Imagem removida: $imagemPath');
      }
    } catch (e) {
      print('❌ Erro ao remover imagem: $e');
      _showSnackBar('Erro ao remover imagem: $e', isError: true);
    }
  }

  /// Verificar se arquivo existe assíncronamente
  Future<bool> _verificarSeArquivoExiste(String? caminho) async {
    if (caminho == null || caminho.isEmpty) return false;
    
    try {
      final file = File(caminho);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// MÉTODO DE DIAGNÓSTICO INTEGRADO
  void _diagnosticarSistema() async {
    print('=== DIAGNÓSTICO COMPLETO ===');
    
    // 1. Mapa de imagens local
    print('1. MAPA DE IMAGENS LOCAL (${_exercicioImagens.length}):');
    for (final entry in _exercicioImagens.entries) {
      final existe = await File(entry.value).exists();
      print('   ${entry.key}: ${entry.value} (existe: $existe)');
    }
    
    // 2. Exercícios locais
    print('2. EXERCÍCIOS LOCAIS (${_exercicios.length}):');
    for (int i = 0; i < _exercicios.length; i++) {
      final ex = _exercicios[i];
      print('   ${i+1}. ${ex.nomeExercicio}');
      print('      ID: ${ex.id}');
      print('      imagemPath: ${ex.imagemPath}');
      if (ex.imagemPath != null) {
        final existe = await File(ex.imagemPath!).exists();
        print('      arquivo existe: $existe');
      }
    }
    
    // 3. Treinos salvos no provider
    print('3. TREINOS NO PROVIDER:');
    final provider = Provider.of<TreinoProvider>(context, listen: false);
    await provider.recarregar();
    
    for (final treino in provider.treinos) {
      print('   Treino: ${treino.nomeTreino} (${treino.exercicios.length} exercícios)');
      for (final ex in treino.exercicios) {
        print('      ${ex.nomeExercicio}: imagemPath = ${ex.imagemPath}');
        if (ex.imagemPath != null) {
          final existe = await File(ex.imagemPath!).exists();
          print('         arquivo existe: $existe');
        }
      }
    }
    
    // 4. Backups locais
    print('4. BACKUPS LOCAIS:');
    final prefs = await SharedPreferences.getInstance();
    final backupKeys = prefs.getKeys().where((key) => key.startsWith('backup_img_')).toList();
    print('   Total backups: ${backupKeys.length}');
    for (final key in backupKeys) {
      final path = prefs.getString(key);
      final existe = path != null ? await File(path).exists() : false;
      print('   $key: $path (existe: $existe)');
    }
    
    print('=== FIM DIAGNÓSTICO ===');
    
    _showSnackBar('Diagnóstico executado - veja logs no terminal', isError: false);
  }

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
          print('Exercício adicionado: ${exercicio.nomeExercicio}');
        },
      ),
    );
  }

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
          'Tem certeza que deseja remover "${_exercicios[index].nomeExercicio}"?\n\nA imagem associada também será removida.',
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
            onPressed: () async {
              final exercicioRemovido = _exercicios[index];
              
              await _removerImagemExercicio(exercicioRemovido.nomeExercicio);
              
              setState(() {
                _exercicios.removeAt(index);
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

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildTreinoImage() {
    final Map<String, Map<String, dynamic>> iconsPorTipo = {
      'Musculação': {
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFF3B82F6),
        'label': 'Musculação'
      },
      'Cardio': {
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFFEF4444),
        'label': 'Exercícios Cardiovasculares'
      },
      'Funcional': {
        'icon': Icons.sports_gymnastics_rounded,
        'color': const Color(0xFF10B981),
        'label': 'Treinamento Funcional'
      },
      'Yoga': {
        'icon': Icons.self_improvement_rounded,
        'color': const Color(0xFF8B5CF6),
        'label': 'Yoga e Meditação'
      },
      'Pilates': {
        'icon': Icons.accessibility_new_rounded,
        'color': const Color(0xFFEC4899),
        'label': 'Pilates'
      },
      'CrossFit': {
        'icon': Icons.sports_mma_rounded,
        'color': const Color(0xFFF97316),
        'label': 'CrossFit'
      },
      'Corrida': {
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFF06B6D4),
        'label': 'Corrida'
      },
      'Natação': {
        'icon': Icons.pool_rounded,
        'color': const Color(0xFF0EA5E9),
        'label': 'Natação'
      },
      'Calistenia': {
        'icon': Icons.sports_gymnastics_rounded,
        'color': const Color(0xFF10B981),
        'label': 'Calistenia'
      },
      'Ciclismo': {
        'icon': Icons.directions_bike_rounded,
        'color': const Color(0xFF84CC16),
        'label': 'Ciclismo'
      },
    };
    
    final tipoInfo = iconsPorTipo[_tipoTreino] ?? {
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFF94A3B8),
      'label': 'Visualização do Treino'
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: (tipoInfo['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            tipoInfo['icon'],
            size: 40,
            color: tipoInfo['color'],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          tipoInfo['label'],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: tipoInfo['color'],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Widget para exibir imagem do exercício
  Widget _buildExercicioImage(ExercicioModel exercicio, int index) {
    final imagemPath = _exercicioImagens[exercicio.nomeExercicio];
    
    return FutureBuilder<bool>(
      future: _verificarSeArquivoExiste(imagemPath),
      builder: (context, snapshot) {
        final temImagem = snapshot.data == true;
        
        return Stack(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: temImagem 
                      ? const Color(0xFF10B981).withOpacity(0.3)
                      : const Color(0xFF6366F1).withOpacity(0.3),
                  width: temImagem ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: temImagem && imagemPath != null
                    ? Image.file(
                        File(imagemPath),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildExercicioFallback(exercicio);
                        },
                      )
                    : _buildExercicioFallback(exercicio),
              ),
            ),
            
            // Número da ordem
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            // Botão para adicionar/trocar imagem
            Positioned(
              bottom: -5,
              left: -5,
              child: GestureDetector(
                onTap: () => _adicionarImagemExercicio(exercicio.nomeExercicio),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    temImagem ? Icons.edit : Icons.add_a_photo,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExercicioFallback(ExercicioModel exercicio) {
    final Map<String, Color> coresPorGrupo = {
      'Peito': const Color(0xFF3B82F6),
      'Costas': const Color(0xFF10B981),
      'Ombros': const Color(0xFFF59E0B),
      'Braços': const Color(0xFF8B5CF6),
      'Pernas': const Color(0xFFEF4444),
      'Glúteos': const Color(0xFFEC4899),
      'Abdômen': const Color(0xFF06B6D4),
      'Cardio': const Color(0xFFEF4444),
      'Funcional': const Color(0xFF84CC16),
    };

    final cor = coresPorGrupo[exercicio.grupoMuscular] ?? const Color(0xFF94A3B8);

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: cor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            color: cor,
            size: 20,
          ),
          const SizedBox(height: 2),
          Text(
            'Sem\nImagem',
            style: TextStyle(
              color: cor,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: _buildTreinoImage(),
          ),
          
          const SizedBox(height: 16),
          
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
                  'Toque em "Adicionar" para incluir exercícios\nVocê poderá adicionar imagens/GIFs para cada exercício!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Column(
            children: List.generate(_exercicios.length, (index) {
              final exercicio = _exercicios[index];
              final imagemPath = _exercicioImagens[exercicio.nomeExercicio];
              final temImagem = imagemPath != null;
              
              return Container(
                key: ValueKey(exercicio.nomeExercicio + index.toString()),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: temImagem ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                    width: temImagem ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (temImagem ? const Color(0xFF10B981) : const Color(0xFF6366F1))
                          .withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: _buildExercicioImage(exercicio, index),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercicio.nomeExercicio,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      if (temImagem)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(
                                Icons.image,
                                size: 12,
                                color: Color(0xFF10B981),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'COM IMAGEM',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exercicio.grupoMuscular != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.category_rounded,
                              size: 12,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              exercicio.grupoMuscular!,
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.fitness_center_rounded,
                            size: 12,
                            color: const Color(0xFF6366F1),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              exercicio.textoExecucaoCalculado,
                              style: const TextStyle(
                                color: Color(0xFF6366F1),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (temImagem) ...[
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => _removerImagemExercicio(exercicio.nomeExercicio),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.delete_outline,
                                size: 12,
                                color: Color(0xFFEF4444),
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Remover imagem',
                                style: TextStyle(
                                  color: Color(0xFFEF4444),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E40AF),
                Color(0xFF3B82F6),
                Color(0xFFF97316),
              ],
            ),
          ),
        ),
        actions: [
          if (!_isSaving)
            IconButton(
              onPressed: _salvarTreino,
              icon: const Icon(
                Icons.check_rounded,
                color: Colors.white,
              ),
              tooltip: 'Salvar',
            ),
          // Botão de diagnóstico (remover após teste)
          IconButton(
            onPressed: _diagnosticarSistema,
            icon: const Icon(
              Icons.bug_report,
              color: Colors.orange,
            ),
            tooltip: 'Diagnóstico',
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
                    _buildForm(),
                    const SizedBox(height: 32),
                    _buildExerciciosList(),
                    const SizedBox(height: 100),
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
  int _tempoExecucao = 30;
  int _tempoDescanso = 60;
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
              
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF10B981),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Após criar o exercício, você poderá adicionar uma imagem ou GIF para demonstrar a execução correta!',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
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