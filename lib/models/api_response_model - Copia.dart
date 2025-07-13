class ApiResponseModel {
  final bool success;
  final dynamic data;
  final String message;
  final Map<String, dynamic>? errors;

  ApiResponseModel({
    required this.success,
    this.data,
    required this.message,
    this.errors,
  });

  factory ApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ApiResponseModel(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
      errors: json['errors'] != null 
          ? Map<String, dynamic>.from(json['errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
      'errors': errors,
    };
  }

  // ✅ MÉTODOS HELPER ÚTEIS
  
  /// Verifica se a resposta foi bem-sucedida
  bool get isSuccess => success;

  /// Verifica se há erros
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Obtém a primeira mensagem de erro
  String? get firstError {
    if (!hasErrors) return null;
    
    final firstKey = errors!.keys.first;
    final firstValue = errors![firstKey];
    
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    
    return firstValue.toString();
  }

  /// Obtém todos os erros como lista de strings
  List<String> get allErrors {
    if (!hasErrors) return [];
    
    List<String> errorList = [];
    
    errors!.forEach((key, value) {
      if (value is List) {
        errorList.addAll(value.map((e) => e.toString()));
      } else {
        errorList.add(value.toString());
      }
    });
    
    return errorList;
  }

  /// Converte data para Map se possível
  Map<String, dynamic>? get dataAsMap {
    if (data == null) return null;
    
    try {
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Converte data para List se possível
  List<dynamic>? get dataAsList {
    if (data == null) return null;
    
    try {
      if (data is List) {
        return List<dynamic>.from(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Método factory para respostas de sucesso
  factory ApiResponseModel.success({
    required dynamic data,
    String message = 'Operação realizada com sucesso',
  }) {
    return ApiResponseModel(
      success: true,
      data: data,
      message: message,
    );
  }

  /// Método factory para respostas de erro
  factory ApiResponseModel.error({
    required String message,
    Map<String, dynamic>? errors,
    dynamic data,
  }) {
    return ApiResponseModel(
      success: false,
      data: data,
      message: message,
      errors: errors,
    );
  }

  /// Método factory para erro de rede
  factory ApiResponseModel.networkError() {
    return ApiResponseModel(
      success: false,
      message: 'Erro de conexão. Verifique sua internet.',
    );
  }

  /// Método factory para erro de servidor
  factory ApiResponseModel.serverError() {
    return ApiResponseModel(
      success: false,
      message: 'Erro interno do servidor. Tente novamente mais tarde.',
    );
  }

  /// Método factory para erro de autenticação
  factory ApiResponseModel.authError() {
    return ApiResponseModel(
      success: false,
      message: 'Sessão expirada. Faça login novamente.',
    );
  }

  /// Método factory para erro de validação
  factory ApiResponseModel.validationError({
    required Map<String, dynamic> errors,
  }) {
    return ApiResponseModel(
      success: false,
      message: 'Dados inválidos',
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'ApiResponseModel{success: $success, message: $message, data: $data, errors: $errors}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApiResponseModel &&
          runtimeType == other.runtimeType &&
          success == other.success &&
          data == other.data &&
          message == other.message &&
          errors == other.errors;

  @override
  int get hashCode =>
      success.hashCode ^ data.hashCode ^ message.hashCode ^ errors.hashCode;
}

// ✅ EXTENSÃO PARA FACILITAR USO COM HTTP RESPONSES
extension ApiResponseExtension on ApiResponseModel {
  /// Lança exceção se não for sucesso
  ApiResponseModel throwIfError() {
    if (!success) {
      throw ApiException(
        message: message,
        errors: errors,
        data: data,
      );
    }
    return this;
  }
}

// ✅ EXCEPTION CUSTOMIZADA PARA API
class ApiException implements Exception {
  final String message;
  final Map<String, dynamic>? errors;
  final dynamic data;

  ApiException({
    required this.message,
    this.errors,
    this.data,
  });

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      final errorList = <String>[];
      errors!.forEach((key, value) {
        if (value is List) {
          errorList.addAll(value.map((e) => e.toString()));
        } else {
          errorList.add(value.toString());
        }
      });
      return 'ApiException: $message\nErros: ${errorList.join(', ')}';
    }
    return 'ApiException: $message';
  }

  /// Primeira mensagem de erro
  String get firstError {
    if (errors == null || errors!.isEmpty) return message;
    
    final firstKey = errors!.keys.first;
    final firstValue = errors![firstKey];
    
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    
    return firstValue.toString();
  }
}