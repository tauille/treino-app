/// Extensões para conversões seguras de dados
/// Substitui funções de debug por conversões confiáveis

extension SafeString on dynamic {
  /// Converte para String de forma segura
  String toSafeString([String defaultValue = '']) {
    try {
      if (this == null) return defaultValue;
      return toString();
    } catch (e) {
      return defaultValue;
    }
  }

  /// Converte para int de forma segura
  int toSafeInt([int defaultValue = 0]) {
    try {
      if (this == null) return defaultValue;
      if (this is int) return this as int;
      if (this is double) return (this as double).round();
      if (this is String) {
        final parsed = int.tryParse(this as String);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Converte para double de forma segura
  double toSafeDouble([double defaultValue = 0.0]) {
    try {
      if (this == null) return defaultValue;
      if (this is double) return this as double;
      if (this is int) return (this as int).toDouble();
      if (this is String) {
        final parsed = double.tryParse(this as String);
        return parsed ?? defaultValue;
      }
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  /// Converte para bool de forma segura
  bool toSafeBool([bool defaultValue = false]) {
    try {
      if (this == null) return defaultValue;
      if (this is bool) return this as bool;
      if (this is String) {
        final str = (this as String).toLowerCase().trim();
        if (str == 'true' || str == '1' || str == 'yes') return true;
        if (str == 'false' || str == '0' || str == 'no') return false;
        return defaultValue;
      }
      if (this is int) return (this as int) != 0;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }
}

extension SafeDateTime on dynamic {
  /// Converte para DateTime de forma segura
  DateTime? toSafeDateTime() {
    try {
      if (this == null) return null;
      if (this is DateTime) return this as DateTime;
      if (this is String) {
        final str = this as String;
        if (str.isEmpty) return null;
        return DateTime.tryParse(str);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Converte para DateTime com valor padrão
  DateTime toSafeDateTimeOrDefault([DateTime? defaultValue]) {
    final parsed = toSafeDateTime();
    return parsed ?? defaultValue ?? DateTime.now();
  }
}

extension SafeList<T> on List<T>? {
  /// Verifica se a lista é nula ou vazia
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Verifica se a lista tem conteúdo
  bool get hasContent => !isNullOrEmpty;
  
  /// Retorna o primeiro item ou nulo se não existir
  T? get firstOrNull {
    if (isNullOrEmpty) return null;
    return this!.first;
  }
  
  /// Retorna o último item ou nulo se não existir
  T? get lastOrNull {
    if (isNullOrEmpty) return null;
    return this!.last;
  }

  /// Retorna uma cópia segura da lista (nunca nula)
  List<T> get safe => this ?? <T>[];
}

extension SafeMap<K, V> on Map<K, V>? {
  /// Verifica se o mapa é nulo ou vazio
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Verifica se o mapa tem conteúdo
  bool get hasContent => !isNullOrEmpty;

  /// Retorna uma cópia segura do mapa (nunca nula)
  Map<K, V> get safe => this ?? <K, V>{};

  /// Obtém valor de forma segura com fallback
  V? safeGet(K key, [V? defaultValue]) {
    if (this == null || !this!.containsKey(key)) return defaultValue;
    return this![key];
  }
}

extension SafeString on String? {
  /// Verifica se a string é nula ou vazia
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Verifica se a string é nula, vazia ou só espaços
  bool get isNullOrWhiteSpace => 
      this == null || this!.trim().isEmpty;
  
  /// Verifica se a string tem conteúdo
  bool get hasContent => !isNullOrEmpty;
  
  /// Retorna a string ou um valor padrão se for nula/vazia
  String orDefault([String defaultValue = '']) => 
      isNullOrEmpty ? defaultValue : this!;
  
  /// Capitaliza a primeira letra
  String get capitalize {
    if (isNullOrEmpty) return '';
    if (this!.length == 1) return this!.toUpperCase();
    return this![0].toUpperCase() + this!.substring(1).toLowerCase();
  }

  /// Remove acentos e caracteres especiais
  String get normalized {
    if (isNullOrEmpty) return '';
    
    const withAccents = 'áàâãäéèêëíìîïóòôõöúùûüçñÁÀÂÃÄÉÈÊËÍÌÎÏÓÒÔÕÖÚÙÛÜÇÑ';
    const withoutAccents = 'aaaaaeeeeiiiioooouuuucnAAAAAEEEEIIIIOOOOUUUUCN';
    
    String result = this!;
    for (int i = 0; i < withAccents.length; i++) {
      result = result.replaceAll(withAccents[i], withoutAccents[i]);
    }
    
    return result;
  }
}

extension SafeIterable<T> on Iterable<T> {
  /// Encontra o primeiro elemento que satisfaz a condição ou retorna nulo
  T? firstWhereOrNull(bool Function(T) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
  
  /// Mapeia com tratamento de erro
  Iterable<R> safeMap<R>(R Function(T) transform, [R? defaultValue]) {
    return map((item) {
      try {
        return transform(item);
      } catch (e) {
        return defaultValue ?? (null as R);
      }
    }).where((item) => item != null);
  }
}