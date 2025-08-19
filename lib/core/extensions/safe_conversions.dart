/// 🔧 EXTENSÕES PARA CONVERSÕES SEGURAS
/// Este arquivo centraliza todas as conversões seguras para evitar duplicação

extension SafeConversions on dynamic {
  /// Converte qualquer valor para int de forma segura
  int toSafeInt([int defaultValue = 0]) {
    if (this == null) return defaultValue;
    if (this is int) return this as int;
    if (this is double) return (this as double).round();
    if (this is String) {
      final parsed = int.tryParse(this as String);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }
  
  /// Converte qualquer valor para double de forma segura
  double toSafeDouble([double defaultValue = 0.0]) {
    if (this == null) return defaultValue;
    if (this is double) return this as double;
    if (this is int) return (this as int).toDouble();
    if (this is String) {
      final parsed = double.tryParse(this as String);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }
}

/// Extensão para int? (nullable int)
extension SafeIntConversions on int? {
  int toSafeInt([int defaultValue = 0]) {
    return this ?? defaultValue;
  }
}

/// Extensão para double? (nullable double)
extension SafeDoubleConversions on double? {
  double toSafeDouble([double defaultValue = 0.0]) {
    return this ?? defaultValue;
  }
}