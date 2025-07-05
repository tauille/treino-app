// lib/models/treino_model.dart
class Treino {
  final int id;
  final String nomeTreino;
  final String tipoTreino;
  final String? descricao;
  final String? dificuldade;
  final String status;
  final int totalExercicios;
  final int duracaoEstimada; // em segundos
  final String duracaoFormatada;
  final String gruposMusculares;
  final String? dificuldadeTexto;
  final String? corDificuldade;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Exercicio>? exercicios;

  Treino({
    required this.id,
    required this.nomeTreino,
    required this.tipoTreino,
    this.descricao,
    this.dificuldade,
    required this.status,
    required this.totalExercicios,
    required this.duracaoEstimada,
    required this.duracaoFormatada,
    required this.gruposMusculares,
    this.dificuldadeTexto,
    this.corDificuldade,
    required this.createdAt,
    required this.updatedAt,
    this.exercicios,
  });

  factory Treino.fromJson(Map<String, dynamic> json) {
    return Treino(
      id: json['id'],
      nomeTreino: json['nome_treino'],
      tipoTreino: json['tipo_treino'],
      descricao: json['descricao'],
      dificuldade: json['dificuldade'],
      status: json['status'],
      totalExercicios: json['total_exercicios'] ?? 0,
      duracaoEstimada: json['duracao_estimada'] ?? 0,
      duracaoFormatada: json['duracao_formatada'] ?? '0 min',
      gruposMusculares: json['grupos_musculares'] ?? '',
      dificuldadeTexto: json['dificuldade_texto'],
      corDificuldade: json['cor_dificuldade'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      exercicios: json['exercicios'] != null
          ? (json['exercicios'] as List)
              .map((e) => Exercicio.fromJson(e))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_treino': nomeTreino,
      'tipo_treino': tipoTreino,
      'descricao': descricao,
      'dificuldade': dificuldade,
      'status': status,
    };
  }

  // 🎯 Getters úteis para UI
  bool get isAtivo => status == 'ativo';

  String get dificuldadeBadgeColor {
    switch (dificuldade) {
      case 'iniciante':
        return '#4CAF50'; // Verde
      case 'intermediario':
        return '#FF9800'; // Laranja
      case 'avancado':
        return '#F44336'; // Vermelho
      default:
        return '#9E9E9E'; // Cinza
    }
  }

  String get dificuldadeText {
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

  String get duracaoTexto {
    if (duracaoEstimada < 60) {
      return '${duracaoEstimada}s';
    } else if (duracaoEstimada < 3600) {
      final minutos = (duracaoEstimada / 60).floor();
      final segundos = duracaoEstimada % 60;
      return segundos > 0 ? '${minutos}m ${segundos}s' : '${minutos}m';
    } else {
      final horas = (duracaoEstimada / 3600).floor();
      final minutos = ((duracaoEstimada % 3600) / 60).floor();
      return minutos > 0 ? '${horas}h ${minutos}m' : '${horas}h';
    }
  }

  String get resumoExercicios {
    if (totalExercicios == 0) return 'Nenhum exercício';
    if (totalExercicios == 1) return '1 exercício';
    return '$totalExercicios exercícios';
  }

  // 🏷️ Para chips de grupos musculares
  List<String> get gruposMuscularesLista {
    if (gruposMusculares.isEmpty) return [];
    return gruposMusculares
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
  }

  // 📊 Para ordenação e filtros
  int get dificuldadeNivel {
    switch (dificuldade) {
      case 'iniciante':
        return 1;
      case 'intermediario':
        return 2;
      case 'avancado':
        return 3;
      default:
        return 0;
    }
  }

  // 🔄 copyWith para atualizações
  Treino copyWith({
    int? id,
    String? nomeTreino,
    String? tipoTreino,
    String? descricao,
    String? dificuldade,
    String? status,
    int? totalExercicios,
    int? duracaoEstimada,
    String? duracaoFormatada,
    String? gruposMusculares,
    String? dificuldadeTexto,
    String? corDificuldade,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Exercicio>? exercicios,
  }) {
    return Treino(
      id: id ?? this.id,
      nomeTreino: nomeTreino ?? this.nomeTreino,
      tipoTreino: tipoTreino ?? this.tipoTreino,
      descricao: descricao ?? this.descricao,
      dificuldade: dificuldade ?? this.dificuldade,
      status: status ?? this.status,
      totalExercicios: totalExercicios ?? this.totalExercicios,
      duracaoEstimada: duracaoEstimada ?? this.duracaoEstimada,
      duracaoFormatada: duracaoFormatada ?? this.duracaoFormatada,
      gruposMusculares: gruposMusculares ?? this.gruposMusculares,
      dificuldadeTexto: dificuldadeTexto ?? this.dificuldadeTexto,
      corDificuldade: corDificuldade ?? this.corDificuldade,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      exercicios: exercicios ?? this.exercicios,
    );
  }

  @override
  String toString() {
    return 'Treino(id: $id, nome: $nomeTreino, tipo: $tipoTreino, dificuldade: $dificuldade)';
  }
}

// lib/models/exercicio_model.dart
class Exercicio {
  final int id;
  final int treinoId;
  final String nomeExercicio;
  final String? descricao;
  final String? grupoMuscular;
  final String tipoExecucao;
  final int? repeticoes;
  final int? series;
  final int? tempoExecucao;
  final int? tempoDescanso;
  final double? peso;
  final String unidadePeso;
  final int ordem;
  final String? observacoes;
  final String status;
  final String textoExecucao;
  final String? textoDescanso;
  final int tempoTotalEstimado;
  final String? imagemUrl;

  Exercicio({
    required this.id,
    required this.treinoId,
    required this.nomeExercicio,
    this.descricao,
    this.grupoMuscular,
    required this.tipoExecucao,
    this.repeticoes,
    this.series,
    this.tempoExecucao,
    this.tempoDescanso,
    this.peso,
    required this.unidadePeso,
    required this.ordem,
    this.observacoes,
    required this.status,
    required this.textoExecucao,
    this.textoDescanso,
    required this.tempoTotalEstimado,
    this.imagemUrl,
  });

  factory Exercicio.fromJson(Map<String, dynamic> json) {
    return Exercicio(
      id: json['id'],
      treinoId: json['treino_id'],
      nomeExercicio: json['nome_exercicio'],
      descricao: json['descricao'],
      grupoMuscular: json['grupo_muscular'],
      tipoExecucao: json['tipo_execucao'],
      repeticoes: json['repeticoes'],
      series: json['series'],
      tempoExecucao: json['tempo_execucao'],
      tempoDescanso: json['tempo_descanso'],
      peso: json['peso'] != null ? double.parse(json['peso'].toString()) : null,
      unidadePeso: json['unidade_peso'] ?? 'kg',
      ordem: json['ordem'],
      observacoes: json['observacoes'],
      status: json['status'],
      textoExecucao: json['texto_execucao'],
      textoDescanso: json['texto_descanso'],
      tempoTotalEstimado: json['tempo_total_estimado'] ?? 0,
      imagemUrl: json['imagem_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'treino_id': treinoId,
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
    };
  }

  // 🎯 Getters úteis para UI
  bool get isAtivo => status == 'ativo';
  bool get isRepeticao => tipoExecucao == 'repeticao';
  bool get isTempo => tipoExecucao == 'tempo';

  String get pesoFormatado {
    if (peso == null) return '';
    return '${peso!.toStringAsFixed(peso! % 1 == 0 ? 0 : 1)} $unidadePeso';
  }

  String get tempoExecucaoFormatado {
    if (tempoExecucao == null) return '';
    if (tempoExecucao! < 60) {
      return '${tempoExecucao}s';
    } else {
      final minutos = (tempoExecucao! / 60).floor();
      final segundos = tempoExecucao! % 60;
      return segundos > 0 ? '${minutos}m ${segundos}s' : '${minutos}m';
    }
  }

  String get tempoDescansoFormatado {
    if (tempoDescanso == null) return '';
    if (tempoDescanso! < 60) {
      return '${tempoDescanso}s';
    } else {
      final minutos = (tempoDescanso! / 60).floor();
      final segundos = tempoDescanso! % 60;
      return segundos > 0 ? '${minutos}m ${segundos}s' : '${minutos}m';
    }
  }

  // 🔄 copyWith para atualizações
  Exercicio copyWith({
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
    String? textoExecucao,
    String? textoDescanso,
    int? tempoTotalEstimado,
    String? imagemUrl,
  }) {
    return Exercicio(
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
      textoExecucao: textoExecucao ?? this.textoExecucao,
      textoDescanso: textoDescanso ?? this.textoDescanso,
      tempoTotalEstimado: tempoTotalEstimado ?? this.tempoTotalEstimado,
      imagemUrl: imagemUrl ?? this.imagemUrl,
    );
  }

  @override
  String toString() {
    return 'Exercicio(id: $id, nome: $nomeExercicio, grupo: $grupoMuscular)';
  }
}