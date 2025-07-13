/// Modelo para padronizar respostas da API Laravel
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
    this.meta,
  });

  /// Criar ApiResponse de sucesso
  factory ApiResponse.success({
    required T data,
    String? message,
    Map<String, dynamic>? meta,
  }) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      meta: meta,
    );
  }

  /// Criar ApiResponse de erro
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
    );
  }

  /// Converter de JSON (resposta da API Laravel)
  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (data != null) 'data': data,
      if (message != null) 'message': message,
      if (errors != null) 'errors': errors,
      if (meta != null) 'meta': meta,
    };
  }

  /// Verificar se a resposta contém dados
  bool get hasData => data != null;

  /// Verificar se a resposta contém erros
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Obter primeira mensagem de erro
  String? get firstError {
    if (!hasErrors) return null;
    
    final firstErrorList = errors!.values.first;
    if (firstErrorList is List && firstErrorList.isNotEmpty) {
      return firstErrorList.first.toString();
    }
    
    return firstErrorList.toString();
  }

  /// Obter todas as mensagens de erro como string
  String get allErrorsAsString {
    if (!hasErrors) return '';
    
    final errorMessages = <String>[];
    
    errors!.forEach((key, value) {
      if (value is List) {
        errorMessages.addAll(value.map((e) => e.toString()));
      } else {
        errorMessages.add(value.toString());
      }
    });
    
    return errorMessages.join(', ');
  }

  /// Mapear dados para outro tipo
  ApiResponse<R> mapData<R>(R Function(T data) mapper) {
    if (!success || data == null) {
      return ApiResponse<R>(
        success: success,
        message: message,
        errors: errors,
        meta: meta,
      );
    }
    
    return ApiResponse<R>(
      success: success,
      data: mapper(data!),
      message: message,
      errors: errors,
      meta: meta,
    );
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: $hasData, hasErrors: $hasErrors)';
  }
}

/// Modelo específico para respostas paginadas do Laravel
class PaginatedResponse<T> {
  final List<T> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  /// Converter de JSON do Laravel
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final List<dynamic> dataJson = json['data'] ?? [];
    final data = dataJson.map((item) => fromJsonT(item)).toList();

    return PaginatedResponse<T>(
      data: data,
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  /// Verificar se tem próxima página
  bool get hasNextPage => nextPageUrl != null;

  /// Verificar se tem página anterior
  bool get hasPrevPage => prevPageUrl != null;

  /// Verificar se é a primeira página
  bool get isFirstPage => currentPage == 1;

  /// Verificar se é a última página
  bool get isLastPage => currentPage == lastPage;

  /// Calcular número de páginas restantes
  int get remainingPages => lastPage - currentPage;

  @override
  String toString() {
    return 'PaginatedResponse(total: $total, currentPage: $currentPage/$lastPage, data: ${data.length} items)';
  }
}