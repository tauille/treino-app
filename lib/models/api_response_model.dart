// lib/models/api_response_model.dart

/// Modelo padrão para respostas da API Laravel
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  // ✅ ADICIONANDO OS CONSTRUCTORS QUE ESTAVAM FALTANDO

  /// Constructor para resposta de sucesso
  factory ApiResponse.success({
    T? data,
    required String message,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Constructor para resposta de erro
  factory ApiResponse.error({
    required String message,
    Map<String, dynamic>? errors,
    int? statusCode,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      errors: errors,
      statusCode: statusCode,
    );
  }

  // ✅ MANTENDO TODA A FUNCIONALIDADE EXISTENTE

  /// Cria ApiResponse a partir do JSON da API Laravel
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromJsonT
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null 
          ? fromJsonT(json['data']) 
          : json['data'],
      errors: json['errors']?.cast<String, dynamic>(),
      statusCode: json['status_code'],
    );
  }

  /// Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'status_code': statusCode,
    };
  }

  /// Verifica se é uma resposta de sucesso
  bool get isSuccess => success == true;

  /// Verifica se é uma resposta de erro
  bool get isError => success == false;

  /// Retorna a primeira mensagem de erro, se houver
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    
    final firstKey = errors!.keys.first;
    final firstValue = errors![firstKey];
    
    if (firstValue is List && firstValue.isNotEmpty) {
      return firstValue.first.toString();
    }
    
    return firstValue.toString();
  }

  /// Retorna todas as mensagens de erro em uma string
  String get allErrors {
    if (errors == null || errors!.isEmpty) return message;
    
    final errorMessages = <String>[];
    
    errors!.forEach((key, value) {
      if (value is List) {
        errorMessages.addAll(value.map((e) => e.toString()));
      } else {
        errorMessages.add(value.toString());
      }
    });
    
    return errorMessages.join('\n');
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, message: $message, hasData: ${data != null}, hasErrors: ${errors != null})';
  }
}

/// Modelo para resposta paginada da API Laravel
class PaginatedApiResponse<T> {
  final bool success;
  final String message;
  final List<T> data;
  final PaginationMeta? meta;
  final Map<String, dynamic>? errors;

  PaginatedApiResponse({
    required this.success,
    required this.message,
    required this.data,
    this.meta,
    this.errors,
  });

  factory PaginatedApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final responseData = json['data'];
    
    // Se data for um objeto com 'data' interno (paginação Laravel)
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      final items = (responseData['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList();
          
      return PaginatedApiResponse<T>(
        success: json['success'] ?? true,
        message: json['message'] ?? '',
        data: items,
        meta: PaginationMeta.fromJson(responseData),
        errors: json['errors']?.cast<String, dynamic>(),
      );
    }
    
    // Se data for uma lista direta
    if (responseData is List) {
      final items = responseData
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList();
          
      return PaginatedApiResponse<T>(
        success: json['success'] ?? true,
        message: json['message'] ?? '',
        data: items,
        errors: json['errors']?.cast<String, dynamic>(),
      );
    }
    
    // Fallback
    return PaginatedApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Erro ao processar dados',
      data: [],
      errors: json['errors']?.cast<String, dynamic>(),
    );
  }

  bool get isSuccess => success == true;
  bool get hasMore => meta?.hasNextPage ?? false;
  int get totalItems => meta?.total ?? data.length;
}

/// Metadados de paginação
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final int from;
  final int to;
  final String? nextPageUrl;
  final String? prevPageUrl;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
    required this.from,
    required this.to,
    this.nextPageUrl,
    this.prevPageUrl,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  bool get hasNextPage => nextPageUrl != null;
  bool get hasPrevPage => prevPageUrl != null;
  bool get isFirstPage => currentPage == 1;
  bool get isLastPage => currentPage == lastPage;
}