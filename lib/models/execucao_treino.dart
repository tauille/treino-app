
import 'execucao_exercicio.dart';

class ExecucaoTreino {
  final int id;
  final String status;
  final TreinoBasico treino;
  final ProgressoExecucao progresso;
  final TemposExecucao tempos;
  final ExercicioAtual? exercicioAtual;
  final List<ExecucaoExercicio> exercicios;

  ExecucaoTreino({
    required this.id,
    required this.status,
    required this.treino,
    required this.progresso,
    required this.tempos,
    this.exercicioAtual,
    required this.exercicios,
  });

  factory ExecucaoTreino.fromJson(Map<String, dynamic> json) {
    return ExecucaoTreino(
      id: json['id'],
      status: json['status'],
      treino: TreinoBasico.fromJson(json['treino']),
      progresso: ProgressoExecucao.fromJson(json['progresso']),
      tempos: TemposExecucao.fromJson(json['tempos']),
      exercicioAtual: json['exercicio_atual'] != null
          ? ExercicioAtual.fromJson(json['exercicio_atual'])
          : null,
      exercicios: (json['exercicios'] as List)
          .map((item) => ExecucaoExercicio.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'treino': treino.toJson(),
      'progresso': progresso.toJson(),
      'tempos': tempos.toJson(),
      'exercicio_atual': exercicioAtual?.toJson(),
      'exercicios': exercicios.map((e) => e.toJson()).toList(),
    };
  }

  // Métodos auxiliares
  bool get isIniciado => status == 'iniciado';
  bool get isPausado => status == 'pausado';
  bool get isFinalizado => status == 'finalizado';
  bool get isCancelado => status == 'cancelado';
  bool get isEmAndamento => isIniciado || isPausado;

  double get progressoPercentual => progresso.percentual;
  
  String get statusText {
    switch (status) {
      case 'iniciado':
        return 'Em andamento';
      case 'pausado':
        return 'Pausado';
      case 'finalizado':
        return 'Finalizado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return 'Desconhecido';
    }
  }

  ExecucaoExercicio? get exercicioAtualExecucao {
    if (exercicioAtual == null) return null;
    
    return exercicios.firstWhere(
      (exe) => exe.exercicioId == exercicioAtual!.id,
      orElse: () => exercicios.first,
    );
  }

  ExecucaoExercicio? proximoExercicio() {
    final atual = exercicioAtualExecucao;
    if (atual == null) return null;

    final proximaOrdem = atual.ordemExecucao + 1;
    try {
      return exercicios.firstWhere(
        (exe) => exe.ordemExecucao == proximaOrdem,
      );
    } catch (e) {
      return null; // Não há próximo exercício
    }
  }

  ExecucaoExercicio? exercicioAnterior() {
    final atual = exercicioAtualExecucao;
    if (atual == null) return null;

    final ordemAnterior = atual.ordemExecucao - 1;
    if (ordemAnterior < 1) return null;

    try {
      return exercicios.firstWhere(
        (exe) => exe.ordemExecucao == ordemAnterior,
      );
    } catch (e) {
      return null;
    }
  }
}

class TreinoBasico {
  final int id;
  final String nome;
  final String tipo;
  final String? dificuldade;

  TreinoBasico({
    required this.id,
    required this.nome,
    required this.tipo,
    this.dificuldade,
  });

  factory TreinoBasico.fromJson(Map<String, dynamic> json) {
    return TreinoBasico(
      id: json['id'],
      nome: json['nome'],
      tipo: json['tipo'],
      dificuldade: json['dificuldade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
      'dificuldade': dificuldade,
    };
  }
}

class ProgressoExecucao {
  final int exercicioAtualOrdem;
  final int totalExercicios;
  final int exerciciosCompletados;
  final double percentual;

  ProgressoExecucao({
    required this.exercicioAtualOrdem,
    required this.totalExercicios,
    required this.exerciciosCompletados,
    required this.percentual,
  });

  factory ProgressoExecucao.fromJson(Map<String, dynamic> json) {
    return ProgressoExecucao(
      exercicioAtualOrdem: json['exercicio_atual_ordem'],
      totalExercicios: json['total_exercicios'],
      exerciciosCompletados: json['exercicios_completados'],
      percentual: (json['percentual'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercicio_atual_ordem': exercicioAtualOrdem,
      'total_exercicios': totalExercicios,
      'exercicios_completados': exerciciosCompletados,
      'percentual': percentual,
    };
  }

  String get progressoTexto => '$exerciciosCompletados/$totalExercicios';
}

class TemposExecucao {
  final DateTime dataInicio;
  final DateTime? dataFim;
  final int tempoTotalSegundos;
  final String tempoTotalFormatado;

  TemposExecucao({
    required this.dataInicio,
    this.dataFim,
    required this.tempoTotalSegundos,
    required this.tempoTotalFormatado,
  });

  factory TemposExecucao.fromJson(Map<String, dynamic> json) {
    return TemposExecucao(
      dataInicio: DateTime.parse(json['data_inicio']),
      dataFim: json['data_fim'] != null ? DateTime.parse(json['data_fim']) : null,
      tempoTotalSegundos: json['tempo_total_segundos'],
      tempoTotalFormatado: json['tempo_total_formatado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_inicio': dataInicio.toIso8601String(),
      'data_fim': dataFim?.toIso8601String(),
      'tempo_total_segundos': tempoTotalSegundos,
      'tempo_total_formatado': tempoTotalFormatado,
    };
  }

  Duration get duracaoTotal => Duration(seconds: tempoTotalSegundos);
}

class ExercicioAtual {
  final int id;
  final String nome;
  final String? grupoMuscular;
  final String tipoExecucao;
  final int? series;
  final int? repeticoes;
  final int? tempoExecucao;
  final int? tempoDescanso;
  final double? peso;
  final String? unidadePeso;
  final String? descricao;
  final String? observacoes;

  ExercicioAtual({
    required this.id,
    required this.nome,
    this.grupoMuscular,
    required this.tipoExecucao,
    this.series,
    this.repeticoes,
    this.tempoExecucao,
    this.tempoDescanso,
    this.peso,
    this.unidadePeso,
    this.descricao,
    this.observacoes,
  });

  factory ExercicioAtual.fromJson(Map<String, dynamic> json) {
    return ExercicioAtual(
      id: json['id'],
      nome: json['nome'],
      grupoMuscular: json['grupo_muscular'],
      tipoExecucao: json['tipo_execucao'],
      series: json['series'],
      repeticoes: json['repeticoes'],
      tempoExecucao: json['tempo_execucao'],
      tempoDescanso: json['tempo_descanso'],
      peso: json['peso']?.toDouble(),
      unidadePeso: json['unidade_peso'],
      descricao: json['descricao'],
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'grupo_muscular': grupoMuscular,
      'tipo_execucao': tipoExecucao,
      'series': series,
      'repeticoes': repeticoes,
      'tempo_execucao': tempoExecucao,
      'tempo_descanso': tempoDescanso,
      'peso': peso,
      'unidade_peso': unidadePeso,
      'descricao': descricao,
      'observacoes': observacoes,
    };
  }

  bool get isPorTempo => tipoExecucao == 'tempo';
  bool get isPorRepeticao => tipoExecucao == 'repeticao';

  String get tipoExecucaoTexto {
    if (isPorTempo && tempoExecucao != null) {
      final minutos = tempoExecucao! ~/ 60;
      final segundos = tempoExecucao! % 60;
      return '${minutos}:${segundos.toString().padLeft(2, '0')}';
    }
    
    if (isPorRepeticao && repeticoes != null && series != null) {
      return '$series x $repeticoes reps';
    }
    
    return 'N/A';
  }

  String get pesoTexto {
    if (peso != null && unidadePeso != null) {
      return '${peso!.toStringAsFixed(1)} $unidadePeso';
    }
    return '';
  }

  String get tempoDescansoTexto {
    if (tempoDescanso != null && tempoDescanso! > 0) {
      final minutos = tempoDescanso! ~/ 60;
      final segundos = tempoDescanso! % 60;
      if (minutos > 0) {
        return '${minutos}min ${segundos}s';
      }
      return '${segundos}s';
    }
    return 'Sem descanso';
  }
}