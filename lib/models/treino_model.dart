import '../core/extensions/safe_conversions.dart';
import 'package:flutter/material.dart';

class TreinoModel {
  final int? id;
  final String nomeTreino;
  final String tipoTreino;
  final String? descricao;
  final String? dificuldade;
  final String? status;
  final List<ExercicioModel> exercicios;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos calculados do backend
  final String? dificuldadeTexto;
  final String? corDificuldade;
  final int? totalExercicios;
  final int? duracaoEstimada;
  final String? duracaoFormatada;
  final String? gruposMusculares;

  TreinoModel({
    this.id,
    required this.nomeTreino,
    required this.tipoTreino,
    this.descricao,
    this.dificuldade,
    this.status = 'ativo',
    this.exercicios = const [],
    this.createdAt,
    this.updatedAt,
    this.dificuldadeTexto,
    this.corDificuldade,
    this.totalExercicios,
    this.duracaoEstimada,
    this.duracaoFormatada,
    this.gruposMusculares,
  });

  // Construtor para criar novo treino (sem ID)
  TreinoModel.novo({
    required this.nomeTreino,
    required this.tipoTreino,
    this.descricao,
    this.dificuldade = 'iniciante',
    this.exercicios = const [],
  }) : id = null,
       status = 'ativo',
       createdAt = null,
       updatedAt = null,
       dificuldadeTexto = null,
       corDificuldade = null,
       totalExercicios = null,
       duracaoEstimada = null,
       duracaoFormatada = null,
       gruposMusculares = null;

  // Converter de JSON (resposta da API)
  factory TreinoModel.fromJson(Map<String, dynamic> json) {
    return TreinoModel(
      id: json['id'],
      nomeTreino: json['nome_treino'] ?? '',
      tipoTreino: json['tipo_treino'] ?? '',
      descricao: json['descricao'],
      dificuldade: json['dificuldade'],
      status: json['status'] ?? 'ativo',
      exercicios: json['exercicios'] != null
          ? (json['exercicios'] as List)
              .map((e) => ExercicioModel.fromJson(e))
              .toList()
          : [],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      dificuldadeTexto: json['dificuldade_texto'],
      corDificuldade: json['cor_dificuldade'],
      totalExercicios: json['total_exercicios'],
      duracaoEstimada: json['duracao_estimada'],
      duracaoFormatada: json['duracao_formatada'],
      gruposMusculares: json['grupos_musculares'],
    );
  }

  // Converter para JSON (envio para API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome_treino': nomeTreino,
      'tipo_treino': tipoTreino,
      'descricao': descricao,
      'dificuldade': dificuldade,
      'status': status,
    };
  }

  // Converter para JSON com exercícios
  Map<String, dynamic> toJsonWithExercicios() {
    final json = toJson();
    json['exercicios'] = exercicios.map((e) => e.toJson()).toList();
    return json;
  }

  // Copiar com modificações
  TreinoModel copyWith({
    int? id,
    String? nomeTreino,
    String? tipoTreino,
    String? descricao,
    String? dificuldade,
    String? status,
    List<ExercicioModel>? exercicios,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TreinoModel(
      id: id ?? this.id,
      nomeTreino: nomeTreino ?? this.nomeTreino,
      tipoTreino: tipoTreino ?? this.tipoTreino,
      descricao: descricao ?? this.descricao,
      dificuldade: dificuldade ?? this.dificuldade,
      status: status ?? this.status,
      exercicios: exercicios ?? this.exercicios,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Adicionar exercício
  TreinoModel adicionarExercicio(ExercicioModel exercicio) {
    final novosExercicios = List<ExercicioModel>.from(exercicios);
    novosExercicios.add(exercicio.copyWith(ordem: novosExercicios.length + 1));
    return copyWith(exercicios: novosExercicios);
  }

  // Remover exercício
  TreinoModel removerExercicio(int index) {
    final novosExercicios = List<ExercicioModel>.from(exercicios);
    novosExercicios.removeAt(index);
    
    // Reordenar exercícios
    for (int i = 0; i < novosExercicios.length; i++) {
      novosExercicios[i] = novosExercicios[i].copyWith(ordem: i + 1);
    }
    
    return copyWith(exercicios: novosExercicios);
  }

  // ===== GETTERS BÁSICOS =====
  bool get isNovo => id == null;
  bool get isAtivo => status == 'ativo';
  bool get isInativo => status == 'inativo';
  int get totalExerciciosAtivos => exercicios.where((e) => e.isAtivo).length;
  
  // Usar o campo totalExercicios se disponível, senão calcular
  int get totalExerciciosCalculado => totalExercicios ?? totalExerciciosAtivos;

  // ===== CORES E DIFICULDADES =====
  
  static const Map<String, Color> coresDificuldadeColor = {
    'iniciante': Color(0xFF4CAF50),     // Verde
    'intermediario': Color(0xFFFF9800), // Laranja
    'avancado': Color(0xFFF44336),      // Vermelho
  };

  static const Map<String, String> coresDificuldadeHex = {
    'iniciante': '#4CAF50',
    'intermediario': '#FF9800',
    'avancado': '#F44336',
  };

  /// Converter string hex para Color
  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return const Color(0xFF9E9E9E); // Cinza padrão
    }
  }

  /// ===== GETTER PRINCIPAL PARA CORES (RESOLVE ERRO DE TIPO) =====
  Color get corDificuldadeColor {
    // Se tem cor do backend, usar ela
    if (corDificuldade != null && corDificuldade!.isNotEmpty) {
      return _hexToColor(corDificuldade!);
    }
    
    // Senão, usar cor padrão baseada na dificuldade
    return coresDificuldadeColor[dificuldade] ?? const Color(0xFF9E9E9E);
  }

  String get corDificuldadeCalculada {
    return corDificuldade ?? coresDificuldadeHex[dificuldade] ?? '#9E9E9E';
  }

  // ===== GETTERS SEGUROS (RESOLVE ERROS DE NULL) =====
  
  /// Getter seguro para dificuldadeTexto
  String get dificuldadeTextoSeguro {
    if (dificuldadeTexto != null && dificuldadeTexto!.isNotEmpty) {
      return dificuldadeTexto!;
    }
    
    switch (dificuldade) {
      case 'iniciante':
        return 'Iniciante';
      case 'intermediario':
        return 'Intermediário';
      case 'avancado':
        return 'Avançado';
      default:
        return 'Não definido';
    }
  }

  /// Getter seguro para duracaoFormatada
  String get duracaoFormatadaSegura {
    if (duracaoFormatada != null && duracaoFormatada!.isNotEmpty) {
      return duracaoFormatada!;
    }
    
    // Calcular com base na duração estimada
    if (duracaoEstimada != null && duracaoEstimada! > 0) {
      final minutos = duracaoEstimada! ~/ 60;
      final segundos = duracaoEstimada! % 60;
      
      if (minutos > 0) {
        return segundos > 0 ? '${minutos}min ${segundos}s' : '${minutos}min';
      } else {
        return '${segundos}s';
      }
    }
    
    // Calcular com base nos exercícios se não tiver duração estimada
    final duracaoCalculada = _calcularDuracaoExercicios();
    if (duracaoCalculada > 0) {
      final minutos = duracaoCalculada ~/ 60;
      final segundos = duracaoCalculada % 60;
      
      if (minutos > 0) {
        return segundos > 0 ? '${minutos}min ${segundos}s' : '${minutos}min';
      } else {
        return '${segundos}s';
      }
    }
    
    return 'Não informado';
  }

  /// Getter seguro para gruposMusculares
  String get gruposMuscularesSeguro {
    if (gruposMusculares != null && gruposMusculares!.isNotEmpty) {
      return gruposMusculares!;
    }
    
    // Calcular com base nos exercícios
    final grupos = exercicios
        .where((e) => e.grupoMuscular != null && e.grupoMuscular!.isNotEmpty)
        .map((e) => e.grupoMuscular!)
        .toSet()
        .toList();
    
    if (grupos.isEmpty) return 'Não informado';
    if (grupos.length == 1) return grupos.first;
    if (grupos.length <= 3) return grupos.join(', ');
    
    return '${grupos.take(2).join(', ')} e mais ${grupos.length - 2}';
  }

  // ===== MÉTODOS AUXILIARES =====
  
  /// Calcular duração baseada nos exercícios
  int _calcularDuracaoExercicios() {
    int duracaoTotal = 0;
    
    for (final exercicio in exercicios) {
      if (exercicio.series != null) {
        final series = exercicio.series!;
        
        if (exercicio.isRepeticao && exercicio.repeticoes != null) {
          // Estimar tempo para repetições (2 segundos por repetição + tempo de descanso)
          final tempoExecucao = exercicio.repeticoes! * 2; // 2s por repetição
          final tempoDescanso = exercicio.tempoDescanso ?? 60; // 60s padrão
          duracaoTotal += (tempoExecucao + tempoDescanso) * series;
        } else if (exercicio.isTempo && exercicio.tempoExecucao != null) {
          // Tempo direto de execução + tempo de descanso
          final tempoExecucao = exercicio.tempoExecucao!;
          final tempoDescanso = exercicio.tempoDescanso ?? 30; // 30s padrão
          duracaoTotal += (tempoExecucao + tempoDescanso) * series;
        }
      }
    }
    
    return duracaoTotal;
  }

  // ===== GETTERS PARA COMPATIBILIDADE =====
  
  /// Para compatibilidade com código existente
  String get dificuldadeTextoCalculado => dificuldadeTextoSeguro;

  /// Verificar se tem exercícios
  bool get temExercicios => exercicios.isNotEmpty;

  /// Verificar se está completo (tem nome, tipo e pelo menos 1 exercício)
  bool get isCompleto => nomeTreino.isNotEmpty && tipoTreino.isNotEmpty && temExercicios;

  @override
  String toString() {
    return 'TreinoModel(id: $id, nomeTreino: $nomeTreino, tipoTreino: $tipoTreino, exercicios: ${exercicios.length})';
  }
}

class ExercicioModel {
  final int? id;
  final int? treinoId;
  final String nomeExercicio;
  final String? descricao;
  final String? grupoMuscular;
  final String tipoExecucao; // 'repeticao' ou 'tempo'
  final int? repeticoes;
  final int? series;
  final int? tempoExecucao; // em segundos
  final int? tempoDescanso; // em segundos
  final double? peso;
  final String? unidadePeso; // 'kg', 'lbs'
  final int? ordem;
  final String? observacoes;
  final String? status;
  final String? imagemPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Campos calculados do backend
  final String? textoExecucao;
  final String? textoDescanso;
  final int? tempoTotalEstimado;
  final String? imagemUrl;

  ExercicioModel({
    this.id,
    this.treinoId,
    required this.nomeExercicio,
    this.descricao,
    this.grupoMuscular,
    required this.tipoExecucao,
    this.repeticoes,
    this.series,
    this.tempoExecucao,
    this.tempoDescanso,
    this.peso,
    this.unidadePeso,
    this.ordem,
    this.observacoes,
    this.status = 'ativo',
    this.imagemPath,
    this.createdAt,
    this.updatedAt,
    this.textoExecucao,
    this.textoDescanso,
    this.tempoTotalEstimado,
    this.imagemUrl,
  });

  // Construtor para novo exercício
  ExercicioModel.novo({
    required this.nomeExercicio,
    this.descricao,
    this.grupoMuscular,
    required this.tipoExecucao,
    this.repeticoes,
    this.series,
    this.tempoExecucao,
    this.tempoDescanso,
    this.peso,
    this.unidadePeso = 'kg',
    this.observacoes,
  }) : id = null,
       treinoId = null,
       ordem = null,
       status = 'ativo',
       imagemPath = null,
       createdAt = null,
       updatedAt = null,
       textoExecucao = null,
       textoDescanso = null,
       tempoTotalEstimado = null,
       imagemUrl = null;

  // ===== SISTEMA DE ASSETS LOCAIS =====
  
  // Mapeamento direto para exercícios conhecidos
  static final Map<String, String> _mapeamentoExercicios = {
    // Exercícios do log
    'prancha': 'assets/images/exercicios/prancha.gif',
    'mais um': 'assets/images/exercicios/mais_um.jpg',
    
    // Exercícios comuns de musculação
    'supino reto': 'assets/images/exercicios/supino_reto.gif',
    'supino inclinado': 'assets/images/exercicios/supino_inclinado.gif',
    'flexão': 'assets/images/exercicios/flexao.gif',
    'flexão de braço': 'assets/images/exercicios/flexao.gif',
    'agachamento': 'assets/images/exercicios/agachamento.gif',
    'leg press': 'assets/images/exercicios/leg_press.gif',
    'rosca direta': 'assets/images/exercicios/rosca_direta.gif',
    'tríceps testa': 'assets/images/exercicios/triceps_testa.gif',
    'abdominal': 'assets/images/exercicios/abdominal.gif',
    'barra fixa': 'assets/images/exercicios/barra_fixa.gif',
    'remada': 'assets/images/exercicios/remada.gif',
    'desenvolvimento': 'assets/images/exercicios/desenvolvimento.gif',
    'elevação lateral': 'assets/images/exercicios/elevacao_lateral.gif',
    'cadeira extensora': 'assets/images/exercicios/cadeira_extensora.gif',
    'mesa flexora': 'assets/images/exercicios/mesa_flexora.gif',
    'panturrilha': 'assets/images/exercicios/panturrilha.gif',
    'rosca martelo': 'assets/images/exercicios/rosca_martelo.gif',
    'tríceps pulley': 'assets/images/exercicios/triceps_pulley.gif',
    'crucifixo': 'assets/images/exercicios/crucifixo.gif',
  };

  static String? _obterAssetPorMapeamento(String nomeExercicio) {
    final nomeNormalizado = nomeExercicio.toLowerCase().trim();
    
    print('MAPEAMENTO DIRETO:');
    print('   Procurando: "$nomeNormalizado"');
    
    // Busca exata primeiro
    if (_mapeamentoExercicios.containsKey(nomeNormalizado)) {
      final asset = _mapeamentoExercicios[nomeNormalizado]!;
      print('   Encontrado exato: $asset');
      return asset;
    }
    
    // Busca parcial (se o nome do exercício contém alguma palavra chave)
    for (final entrada in _mapeamentoExercicios.entries) {
      if (nomeNormalizado.contains(entrada.key) || entrada.key.contains(nomeNormalizado)) {
        final asset = entrada.value;
        print('   Encontrado similar: $asset (chave: "${entrada.key}")');
        return asset;
      }
    }
    
    print('   Não encontrado no mapeamento');
    return null;
  }

  static String? _obterAssetImagem(String nomeExercicio) {
    if (nomeExercicio.isEmpty) {
      print('Nome do exercício está vazio');
      return null;
    }

    // Converter nome do exercício para nome de arquivo válido
    String nomeArquivo = nomeExercicio
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('ã', 'a')
        .replaceAll('á', 'a')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('é', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ô', 'o')
        .replaceAll('õ', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9_]'), ''); // Remove caracteres especiais

    print('MAPEANDO EXERCÍCIO:');
    print('   Original: "$nomeExercicio"');
    print('   Arquivo: "$nomeArquivo"');

    // Lista de extensões possíveis (ordem de prioridade)
    const extensoes = ['gif', 'jpg', 'jpeg', 'png', 'webp'];
    
    for (final ext in extensoes) {
      final assetPath = 'assets/images/exercicios/$nomeArquivo.$ext';
      print('   Tentando: $assetPath');
      
      // Retorna o primeiro asset encontrado
      return assetPath;
    }

    // Se não encontrar, retornar null (sem imagem)
    print('   Sem imagem - retornando null');
    return null;
  }

  // Converter de JSON - COM SISTEMA DE ASSETS LOCAIS
  factory ExercicioModel.fromJson(Map<String, dynamic> json) {
    // ===== DEBUG DE IMAGEM - INÍCIO =====
    print('EXERCICIO JSON DEBUG - Nome: ${json['nome_exercicio']}');
    print('JSON COMPLETO: $json');
    print('CAMPOS DE IMAGEM:');
    print('  - imagem_path: ${json['imagem_path']}');
    print('  - imagem_url: ${json['imagem_url']}');
    print('TODAS AS CHAVES DO JSON: ${json.keys.toList()}');
    // ===== DEBUG DE IMAGEM - FIM =====

    // ===== SOLUÇÃO TEMPORÁRIA - SEM IMAGENS =====
    String? assetImagem = null; // Sempre retorna null - sem imagens por enquanto
    final nomeExercicio = json['nome_exercicio'] ?? '';
    
    print('SISTEMA DE IMAGENS DESABILITADO - usando ícones genéricos');
    print('ASSET FINAL SELECIONADO: null (sem imagem)');

    print('===== FIM DEBUG EXERCICIO =====');

    return ExercicioModel(
      id: json['id'],
      treinoId: json['treino_id'],
      nomeExercicio: json['nome_exercicio'] ?? '',
      descricao: json['descricao'],
      grupoMuscular: json['grupo_muscular'],
      tipoExecucao: json['tipo_execucao'] ?? 'repeticao',
      repeticoes: json['repeticoes'],
      series: json['series'],
      tempoExecucao: json['tempo_execucao'],
      tempoDescanso: json['tempo_descanso'],
      peso: json['peso'] != null ? double.tryParse(json['peso'].toString()) ?? 0.0 : 0.0,
      unidadePeso: json['unidade_peso'],
      ordem: json['ordem'],
      observacoes: json['observacoes'],
      status: json['status'] ?? 'ativo',
      imagemPath: assetImagem,  // USAR ASSET LOCAL
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      textoExecucao: json['texto_execucao'],
      textoDescanso: json['texto_descanso'],
      tempoTotalEstimado: json['tempo_total_estimado'],
      imagemUrl: json['imagem_url'],
    );
  }

  // Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (treinoId != null) 'treino_id': treinoId,
      'nome_exercicio': nomeExercicio,
      'descricao': descricao,
      'grupo_muscular': grupoMuscular,
      'tipo_execucao': tipoExecucao,
      'repeticoes': repeticoes,
      'series': series,
      'tempo_execucao': tempoExecucao,
      'tempo_descanso': tempoDescanso,
      'peso': peso,
      'unidade_peso': unidadePeso,
      'ordem': ordem,
      'observacoes': observacoes,
      'status': status,
      'imagem_path': imagemPath,
    };
  }

  // Copiar com modificações
  ExercicioModel copyWith({
    int? id,
    int? treinoId,
    String? nomeExercicio,
    String? descricao,
    String? grupoMuscular,
    String? tipoExecucao,
    int? repeticoes,
    int? series,
    int? tempoExecucao,
    int? tempoDescanso,
    double? peso,
    String? unidadePeso,
    int? ordem,
    String? observacoes,
    String? status,
    String? imagemPath,
  }) {
    return ExercicioModel(
      id: id ?? this.id,
      treinoId: treinoId ?? this.treinoId,
      nomeExercicio: nomeExercicio ?? this.nomeExercicio,
      descricao: descricao ?? this.descricao,
      grupoMuscular: grupoMuscular ?? this.grupoMuscular,
      tipoExecucao: tipoExecucao ?? this.tipoExecucao,
      repeticoes: repeticoes ?? this.repeticoes,
      series: series ?? this.series,
      tempoExecucao: tempoExecucao ?? this.tempoExecucao,
      tempoDescanso: tempoDescanso ?? this.tempoDescanso,
      peso: peso ?? this.peso,
      unidadePeso: unidadePeso ?? this.unidadePeso,
      ordem: ordem ?? this.ordem,
      observacoes: observacoes ?? this.observacoes,
      status: status ?? this.status,
      imagemPath: imagemPath ?? this.imagemPath,
    );
  }

  // ===== GETTERS ÚTEIS =====
  bool get isAtivo => status == 'ativo';
  bool get isNovo => id == null;
  bool get isRepeticao => tipoExecucao == 'repeticao';
  bool get isTempo => tipoExecucao == 'tempo';

  /// Getter seguro para imagemPath (URL da imagem para exibição)
  String? get urlImagem => imagemPath;

  String get textoExecucaoCalculado {
    if (textoExecucao != null) return textoExecucao!;
    
    if (isRepeticao) {
      return '${series ?? 1}x ${repeticoes ?? 1} repetições';
    } else {
      final minutos = (tempoExecucao ?? 0) ~/ 60;
      final segundos = (tempoExecucao ?? 0) % 60;
      if (minutos > 0) {
        return '${minutos}min ${segundos}s';
      } else {
        return '${segundos}s';
      }
    }
  }

  String get textoDescansoCalculado {
    if (textoDescanso != null) return textoDescanso!;
    
    final descanso = tempoDescanso ?? 0;
    if (descanso == 0) return 'Sem descanso';
    
    final minutos = descanso ~/ 60;
    final segundos = descanso % 60;
    if (minutos > 0) {
      return 'Descanso: ${minutos}min ${segundos}s';
    } else {
      return 'Descanso: ${segundos}s';
    }
  }

  @override
  String toString() {
    return 'ExercicioModel(id: $id, nomeExercicio: $nomeExercicio, tipoExecucao: $tipoExecucao)';
  }
}