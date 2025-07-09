/// Modelo do treino
class TreinoModel {
  final int id;
  final String nomeTreino;
  final String tipoTreino;
  final String? descricao;
  final String? dificuldade;
  final String status;
  final int totalExercicios;
  final int duracaoEstimada; // em minutos
  final String? gruposMusculares;
  final DateTime createdAt;
  final DateTime updatedAt;

  TreinoModel({
    required this.id,
    required this.nomeTreino,
    required this.tipoTreino,
    this.descricao,
    this.dificuldade,
    required this.status,
    required this.totalExercicios,
    required this.duracaoEstimada,
    this.gruposMusculares,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Criar TreinoModel a partir do JSON da API
  factory TreinoModel.fromJson(Map<String, dynamic> json) {
    return TreinoModel(
      id: json['id'],
      nomeTreino: json['nome_treino'],
      tipoTreino: json['tipo_treino'],
      descricao: json['descricao'],
      dificuldade: json['dificuldade'],
      status: json['status'] ?? 'ativo',
      totalExercicios: json['total_exercicios'] ?? 0,
      duracaoEstimada: json['duracao_estimada'] ?? 0,
      gruposMusculares: json['grupos_musculares'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  /// Converter TreinoModel para JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_treino': nomeTreino,
      'tipo_treino': tipoTreino,
      'descricao': descricao,
      'dificuldade': dificuldade,
      'status': status,
      'total_exercicios': totalExercicios,
      'duracao_estimada': duracaoEstimada,
      'grupos_musculares': gruposMusculares,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Duração formatada (ex: "45 min", "1h 15min")
  String get duracaoFormatada {
    if (duracaoEstimada <= 0) return 'N/A';
    
    if (duracaoEstimada < 60) {
      return '${duracaoEstimada}min';
    } else {
      final horas = duracaoEstimada ~/ 60;
      final minutos = duracaoEstimada % 60;
      
      if (minutos == 0) {
        return '${horas}h';
      } else {
        return '${horas}h ${minutos}min';
      }
    }
  }

  /// Texto da dificuldade formatado
  String get dificuldadeTexto {
    switch (dificuldade?.toLowerCase()) {
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

  /// Cor da dificuldade
  String get corDificuldade {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return 'green';
      case 'intermediario':
        return 'orange';
      case 'avancado':
        return 'red';
      default:
        return 'grey';
    }
  }

  /// Ícone da dificuldade
  String get iconeDificuldade {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return 'child_friendly';
      case 'intermediario':
        return 'fitness_center';
      case 'avancado':
        return 'flash_on';
      default:
        return 'help_outline';
    }
  }

  /// Ícone do tipo de treino
  String get iconeTipoTreino {
    switch (tipoTreino.toLowerCase()) {
      case 'musculacao':
      case 'musculação':
        return 'fitness_center';
      case 'cardio':
      case 'cardiovascular':
        return 'directions_run';
      case 'funcional':
        return 'sports_gymnastics';
      case 'yoga':
        return 'self_improvement';
      case 'pilates':
        return 'accessibility';
      case 'crossfit':
        return 'sports_martial_arts';
      default:
        return 'sports';
    }
  }

  /// Se o treino está ativo
  bool get isAtivo => status.toLowerCase() == 'ativo';

  /// Se o treino é novo (criado hoje)
  bool get isNovo {
    final hoje = DateTime.now();
    final criadoHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final criadoEm = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return criadoEm.isAtSameMomentAs(criadoHoje);
  }

  /// Se o treino foi atualizado recentemente (últimas 24h)
  bool get foiAtualizadoRecentemente {
    final agora = DateTime.now();
    final diferenca = agora.difference(updatedAt);
    return diferenca.inHours < 24;
  }

  /// Grupos musculares como lista
  List<String> get gruposMuscularesList {
    if (gruposMusculares == null || gruposMusculares!.isEmpty) {
      return [];
    }
    return gruposMusculares!
        .split(',')
        .map((g) => g.trim())
        .where((g) => g.isNotEmpty)
        .toList();
  }

  /// Primeiro grupo muscular
  String get grupoMuscularPrincipal {
    final grupos = gruposMuscularesList;
    return grupos.isNotEmpty ? grupos.first : 'Geral';
  }

  /// Intensidade baseada na dificuldade
  double get intensidade {
    switch (dificuldade?.toLowerCase()) {
      case 'iniciante':
        return 0.3;
      case 'intermediario':
        return 0.6;
      case 'avancado':
        return 0.9;
      default:
        return 0.5;
    }
  }

  /// Calorias estimadas (baseado na duração)
  int get caloriasEstimadas {
    // Cálculo aproximado: 8-12 calorias por minuto dependendo da intensidade
    final baseCalories = duracaoEstimada * 10;
    final intensityMultiplier = intensidade + 0.5; // 0.8 a 1.4
    return (baseCalories * intensityMultiplier).round();
  }

  /// Resumo do treino para exibição
  String get resumo {
    final partes = <String>[];
    
    if (totalExercicios > 0) {
      partes.add('$totalExercicios exercícios');
    }
    
    if (duracaoEstimada > 0) {
      partes.add(duracaoFormatada);
    }
    
    if (dificuldade != null) {
      partes.add(dificuldadeTexto);
    }
    
    return partes.join(' • ');
  }

  /// Se o treino é adequado para iniciantes
  bool get adequadoParaIniciantes {
    return dificuldade?.toLowerCase() == 'iniciante' || 
           duracaoEstimada <= 30 ||
           totalExercicios <= 5;
  }

  /// Se o treino é um treino rápido (menos de 30 min)
  bool get isTreinoRapido => duracaoEstimada < 30;

  /// Se o treino é longo (mais de 1 hora)
  bool get isTreinoLongo => duracaoEstimada > 60;

  /// Criar cópia do TreinoModel com novos valores
  TreinoModel copyWith({
    int? id,
    String? nomeTreino,
    String? tipoTreino,
    String? descricao,
    String? dificuldade,
    String? status,
    int? totalExercicios,
    int? duracaoEstimada,
    String? gruposMusculares,
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
      totalExercicios: totalExercicios ?? this.totalExercicios,
      duracaoEstimada: duracaoEstimada ?? this.duracaoEstimada,
      gruposMusculares: gruposMusculares ?? this.gruposMusculares,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'TreinoModel{id: $id, nomeTreino: $nomeTreino, tipoTreino: $tipoTreino, dificuldade: $dificuldade}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TreinoModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}