class ExecucaoExercicio {
  final int id;
  final int exercicioId;
  final String nome;
  final String? grupoMuscular;
  final String status;
  final int ordemExecucao;
  final String tipoExecucao;
  final DadosExercicioPlanejado planejado;
  final DadosExercicioRealizado realizado;
  final TemposExercicio tempos;
  final String performance;
  final String? observacoes;

  ExecucaoExercicio({
    required this.id,
    required this.exercicioId,
    required this.nome,
    this.grupoMuscular,
    required this.status,
    required this.ordemExecucao,
    required this.tipoExecucao,
    required this.planejado,
    required this.realizado,
    required this.tempos,
    required this.performance,
    this.observacoes,
  });

  factory ExecucaoExercicio.fromJson(Map<String, dynamic> json) {
    return ExecucaoExercicio(
      id: json['id'],
      exercicioId: json['exercicio_id'],
      nome: json['nome'],
      grupoMuscular: json['grupo_muscular'],
      status: json['status'],
      ordemExecucao: json['ordem_execucao'],
      tipoExecucao: json['tipo_execucao'],
      planejado: DadosExercicioPlanejado.fromJson(json['planejado']),
      realizado: DadosExercicioRealizado.fromJson(json['realizado']),
      tempos: TemposExercicio.fromJson(json['tempos']),
      performance: json['performance'] ?? 'N/A',
      observacoes: json['observacoes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exercicio_id': exercicioId,
      'nome': nome,
      'grupo_muscular': grupoMuscular,
      'status': status,
      'ordem_execucao': ordemExecucao,
      'tipo_execucao': tipoExecucao,
      'planejado': planejado.toJson(),
      'realizado': realizado.toJson(),
      'tempos': tempos.toJson(),
      'performance': performance,
      'observacoes': observacoes,
    };
  }

  // Status do exercício
  bool get isNaoIniciado => status == 'nao_iniciado';
  bool get isEmAndamento => status == 'em_andamento';
  bool get isCompletado => status == 'completado';
  bool get isPulado => status == 'pulado';

  // Tipo de execução
  bool get isPorTempo => tipoExecucao == 'tempo';
  bool get isPorRepeticao => tipoExecucao == 'repeticao';

  // Status em português
  String get statusTexto {
    switch (status) {
      case 'nao_iniciado':
        return 'Não iniciado';
      case 'em_andamento':
        return 'Em andamento';
      case 'completado':
        return 'Completado';
      case 'pulado':
        return 'Pulado';
      default:
        return 'Desconhecido';
    }
  }

  // Progresso do exercício
  String get progressoTexto {
    if (isPorRepeticao) {
      final realizadas = realizado.series ?? 0;
      final planejadas = planejado.series ?? 0;
      return '$realizadas/$planejadas séries';
    }
    
    if (isPorTempo) {
      return tempos.tempoFormatado;
    }
    
    return 'N/A';
  }

  // Texto resumido do exercício
  String get resumoExecucao {
    if (isPorRepeticao && planejado.series != null && planejado.repeticoes != null) {
      String base = '${planejado.series} x ${planejado.repeticoes} reps';
      if (planejado.peso != null) {
        base += ' - ${planejado.peso}kg';
      }
      return base;
    }
    
    if (isPorTempo && planejado.tempoExecucao != null) {
      final minutos = planejado.tempoExecucao! ~/ 60;
      final segundos = planejado.tempoExecucao! % 60;
      return '${minutos}:${segundos.toString().padLeft(2, '0')}';
    }
    
    return 'Configuração indefinida';
  }

  // Indicador de performance por cor
  PerformanceLevel get performanceLevel {
    switch (performance.toLowerCase()) {
      case 'excelente':
        return PerformanceLevel.excelente;
      case 'bom':
        return PerformanceLevel.bom;
      case 'regular':
        return PerformanceLevel.regular;
      case 'abaixo do esperado':
        return PerformanceLevel.ruim;
      default:
        return PerformanceLevel.indefinido;
    }
  }

  // Verificar se pode ser iniciado
  bool get podeIniciar => isNaoIniciado;

  // Verificar se pode ser completado
  bool get podeCompletar => isEmAndamento;

  // Verificar se pode ser pulado
  bool get podePular => !isCompletado;

  // Criar cópia com novos dados realizados
  ExecucaoExercicio copyWithRealizado({
    int? seriesRealizadas,
    int? repeticoesRealizadas,
    double? pesoUtilizado,
    int? tempoExecutadoSegundos,
    int? tempoDescansoRealizado,
    String? observacoes,
  }) {
    return ExecucaoExercicio(
      id: id,
      exercicioId: exercicioId,
      nome: nome,
      grupoMuscular: grupoMuscular,
      status: status,
      ordemExecucao: ordemExecucao,
      tipoExecucao: tipoExecucao,
      planejado: planejado,
      realizado: DadosExercicioRealizado(
        series: seriesRealizadas ?? realizado.series,
        repeticoes: repeticoesRealizadas ?? realizado.repeticoes,
        peso: pesoUtilizado ?? realizado.peso,
        tempoExecutado: tempoExecutadoSegundos ?? realizado.tempoExecutado,
        tempoDescanso: tempoDescansoRealizado ?? realizado.tempoDescanso,
      ),
      tempos: tempos,
      performance: performance,
      observacoes: observacoes ?? this.observacoes,
    );
  }
}

class DadosExercicioPlanejado {
  final int? series;
  final int? repeticoes;
  final double? peso;
  final int? tempoExecucao;
  final int? tempoDescanso;

  DadosExercicioPlanejado({
    this.series,
    this.repeticoes,
    this.peso,
    this.tempoExecucao,
    this.tempoDescanso,
  });

  factory DadosExercicioPlanejado.fromJson(Map<String, dynamic> json) {
    return DadosExercicioPlanejado(
      series: json['series'],
      repeticoes: json['repeticoes'],
      peso: json['peso']?.toDouble(),
      tempoExecucao: json['tempo_execucao'],
      tempoDescanso: json['tempo_descanso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'series': series,
      'repeticoes': repeticoes,
      'peso': peso,
      'tempo_execucao': tempoExecucao,
      'tempo_descanso': tempoDescanso,
    };
  }

  String get tempoDescansoFormatado {
    if (tempoDescanso == null || tempoDescanso! <= 0) return 'Sem descanso';
    
    final minutos = tempoDescanso! ~/ 60;
    final segundos = tempoDescanso! % 60;
    
    if (minutos > 0) {
      return '${minutos}min ${segundos}s';
    }
    return '${segundos}s';
  }

  String get tempoExecucaoFormatado {
    if (tempoExecucao == null) return 'N/A';
    
    final minutos = tempoExecucao! ~/ 60;
    final segundos = tempoExecucao! % 60;
    
    return '${minutos}:${segundos.toString().padLeft(2, '0')}';
  }
}

class DadosExercicioRealizado {
  final int? series;
  final int? repeticoes;
  final double? peso;
  final int? tempoExecutado;
  final int? tempoDescanso;

  DadosExercicioRealizado({
    this.series,
    this.repeticoes,
    this.peso,
    this.tempoExecutado,
    this.tempoDescanso,
  });

  factory DadosExercicioRealizado.fromJson(Map<String, dynamic> json) {
    return DadosExercicioRealizado(
      series: json['series'],
      repeticoes: json['repeticoes'],
      peso: json['peso']?.toDouble(),
      tempoExecutado: json['tempo_executado'],
      tempoDescanso: json['tempo_descanso'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'series': series,
      'repeticoes': repeticoes,
      'peso': peso,
      'tempo_executado': tempoExecutado,
      'tempo_descanso': tempoDescanso,
    };
  }

  String get tempoExecutadoFormatado {
    if (tempoExecutado == null) return '00:00';
    
    final minutos = tempoExecutado! ~/ 60;
    final segundos = tempoExecutado! % 60;
    
    return '${minutos}:${segundos.toString().padLeft(2, '0')}';
  }

  bool get temDados {
    return series != null || 
           repeticoes != null || 
           peso != null || 
           tempoExecutado != null;
  }
}

class TemposExercicio {
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final String tempoFormatado;

  TemposExercicio({
    this.dataInicio,
    this.dataFim,
    required this.tempoFormatado,
  });

  factory TemposExercicio.fromJson(Map<String, dynamic> json) {
    return TemposExercicio(
      dataInicio: json['data_inicio'] != null 
          ? DateTime.parse(json['data_inicio']) 
          : null,
      dataFim: json['data_fim'] != null 
          ? DateTime.parse(json['data_fim']) 
          : null,
      tempoFormatado: json['tempo_formatado'] ?? '00:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_inicio': dataInicio?.toIso8601String(),
      'data_fim': dataFim?.toIso8601String(),
      'tempo_formatado': tempoFormatado,
    };
  }

  Duration? get duracao {
    if (dataInicio == null) return null;
    
    final fim = dataFim ?? DateTime.now();
    return fim.difference(dataInicio!);
  }

  bool get foiIniciado => dataInicio != null;
  bool get foiFinalizado => dataFim != null;
}

enum PerformanceLevel {
  excelente,
  bom,
  regular,
  ruim,
  indefinido,
}

extension PerformanceLevelExtension on PerformanceLevel {
  String get texto {
    switch (this) {
      case PerformanceLevel.excelente:
        return 'Excelente';
      case PerformanceLevel.bom:
        return 'Bom';
      case PerformanceLevel.regular:
        return 'Regular';
      case PerformanceLevel.ruim:
        return 'Abaixo do esperado';
      case PerformanceLevel.indefinido:
        return 'N/A';
    }
  }

  // Cores para indicadores visuais
  int get corHex {
    switch (this) {
      case PerformanceLevel.excelente:
        return 0xFF4CAF50; // Verde
      case PerformanceLevel.bom:
        return 0xFF8BC34A; // Verde claro
      case PerformanceLevel.regular:
        return 0xFFFF9800; // Laranja
      case PerformanceLevel.ruim:
        return 0xFFF44336; // Vermelho
      case PerformanceLevel.indefinido:
        return 0xFF9E9E9E; // Cinza
    }
  }
}