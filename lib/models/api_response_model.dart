/// Modelo para padronizar respostas da API Laravel
class ApiResponseModel<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final Map<String, dynamic>? meta;

  ApiResponseModel({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.meta,
  });

  /// Criar ApiResponseModel a partir do JSON da API
  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? dataParser,
  }) {
    return ApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && dataParser != null 
          ? dataParser(json['data']) 
          : json['data'],
      errors: json['errors'],
      meta: json['meta'],
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
      'meta': meta,
    };
  }

  /// Se a resposta é um sucesso
  bool get isSuccess => success;

  /// Se a resposta é um erro
  bool get isError => !success;

  /// Se tem dados
  bool get hasData => data != null;

  /// Se tem erros de validação
  bool get hasValidationErrors => errors != null && errors!.isNotEmpty;

  /// Obter primeira mensagem de erro de validação
  String? get firstValidationError {
    if (!hasValidationErrors) return null;
    
    for (final fieldErrors in errors!.values) {
      if (fieldErrors is List && fieldErrors.isNotEmpty) {
        return fieldErrors.first.toString();
      }
    }
    return null;
  }

  /// Obter todos os erros de validação como lista
  List<String> get allValidationErrors {
    if (!hasValidationErrors) return [];
    
    final allErrors = <String>[];
    for (final fieldErrors in errors!.values) {
      if (fieldErrors is List) {
        allErrors.addAll(fieldErrors.map((e) => e.toString()));
      }
    }
    return allErrors;
  }

  /// Obter erros por campo
  Map<String, List<String>> get validationErrorsByField {
    if (!hasValidationErrors) return {};
    
    final errorsByField = <String, List<String>>{};
    errors!.forEach((field, fieldErrors) {
      if (fieldErrors is List) {
        errorsByField[field] = fieldErrors.map((e) => e.toString()).toList();
      }
    });
    return errorsByField;
  }

  @override
  String toString() {
    return 'ApiResponseModel{success: $success, message: $message, hasData: $hasData}';
  }
}

/// Modelo para respostas paginadas
class PaginatedApiResponseModel<T> extends ApiResponseModel<List<T>> {
  final PaginationMeta? pagination;

  PaginatedApiResponseModel({
    required bool success,
    required String message,
    List<T>? data,
    Map<String, dynamic>? errors,
    this.pagination,
  }) : super(
          success: success,
          message: message,
          data: data,
          errors: errors,
          meta: pagination?.toJson(),
        );

  /// Criar PaginatedApiResponseModel a partir do JSON da API
  factory PaginatedApiResponseModel.fromJson(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) itemParser,
  }) {
    List<T>? items;
    PaginationMeta? pagination;

    if (json['data'] != null) {
      if (json['data'] is Map && json['data']['data'] is List) {
        // Formato Laravel com paginação
        final dataSection = json['data'];
        items = (dataSection['data'] as List)
            .map((item) => itemParser(item))
            .toList();
        
        pagination = PaginationMeta.fromJson(dataSection);
      } else if (json['data'] is List) {
        // Lista simples
        items = (json['data'] as List)
            .map((item) => itemParser(item))
            .toList();
      }
    }

    return PaginatedApiResponseModel<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: items,
      errors: json['errors'],
      pagination: pagination,
    );
  }

  /// Se tem próxima página
  bool get hasNextPage => pagination?.hasNextPage ?? false;

  /// Se tem página anterior
  bool get hasPreviousPage => pagination?.hasPreviousPage ?? false;

  /// Página atual
  int get currentPage => pagination?.currentPage ?? 1;

  /// Total de páginas
  int get totalPages => pagination?.lastPage ?? 1;

  /// Total de itens
  int get totalItems => pagination?.total ?? (data?.length ?? 0);

  /// Itens por página
  int get perPage => pagination?.perPage ?? (data?.length ?? 0);
}

/// Modelo para metadados de paginação
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

  /// Criar PaginationMeta a partir do JSON da API Laravel
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 0,
      total: json['total'] ?? 0,
      from: json['from'] ?? 0,
      to: json['to'] ?? 0,
      nextPageUrl: json['next_page_url'],
      prevPageUrl: json['prev_page_url'],
    );
  }

  /// Converter para JSON
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'last_page': lastPage,
      'per_page': perPage,
      'total': total,
      'from': from,
      'to': to,
      'next_page_url': nextPageUrl,
      'prev_page_url': prevPageUrl,
    };
  }

  /// Se tem próxima página
  bool get hasNextPage => nextPageUrl != null;

  /// Se tem página anterior
  bool get hasPreviousPage => prevPageUrl != null;

  /// Se é a primeira página
  bool get isFirstPage => currentPage == 1;

  /// Se é a última página
  bool get isLastPage => currentPage == lastPage;

  /// Porcentagem de progresso nas páginas
  double get pageProgress {
    if (lastPage <= 1) return 1.0;
    return currentPage / lastPage;
  }

  @override
  String toString() {
    return 'PaginationMeta{currentPage: $currentPage, lastPage: $lastPage, total: $total}';
  }
}

/// Modelo para respostas de erro específicas
class ApiErrorResponseModel {
  final String message;
  final int? statusCode;
  final String? errorCode;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  ApiErrorResponseModel({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Criar ApiErrorResponseModel a partir de exceção
  factory ApiErrorResponseModel.fromException(
    dynamic exception, {
    int? statusCode,
    String? errorCode,
  }) {
    return ApiErrorResponseModel(
      message: exception.toString(),
      statusCode: statusCode,
      errorCode: errorCode,
      details: {
        'exception_type': exception.runtimeType.toString(),
      },
    );
  }

  /// Criar ApiErrorResponseModel a partir de resposta HTTP
  factory ApiErrorResponseModel.fromHttpResponse(
    int statusCode,
    String? body,
  ) {
    String message;
    String? errorCode;
    Map<String, dynamic>? details;

    try {
      if (body != null && body.isNotEmpty) {
        final json = Map<String, dynamic>.from(
          // Assumindo que o body já é um Map ou pode ser parseado
          body is String ? {} : body,
        );
        
        message = json['message'] ?? 'Erro HTTP $statusCode';
        errorCode = json['error_code'];
        details = json['details'];
      } else {
        message = 'Erro HTTP $statusCode';
      }
    } catch (e) {
      message = 'Erro HTTP $statusCode';
      details = {'parse_error': e.toString()};
    }

    return ApiErrorResponseModel(
      message: message,
      statusCode: statusCode,
      errorCode: errorCode,
      details: details,
    );
  }

  /// Se é erro de autenticação
  bool get isAuthError => statusCode == 401;

  /// Se é erro de permissão
  bool get isPermissionError => statusCode == 403;

  /// Se é erro de validação
  bool get isValidationError => statusCode == 422;

  /// Se é erro de servidor
  bool get isServerError => statusCode != null && statusCode! >= 500;

  /// Se é erro de rede/cliente
  bool get isClientError => statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() {
    return 'ApiErrorResponseModel{message: $message, statusCode: $statusCode, errorCode: $errorCode}';
  }
}