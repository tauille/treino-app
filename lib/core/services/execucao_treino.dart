import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/execucao_treino.dart';
import '../models/api_response.dart';

class ExecucaoTreinoService {
  final String baseUrl;
  final String? token;

  ExecucaoTreinoService({
    required this.baseUrl,
    this.token,
  });

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  /// Iniciar novo treino
  Future<ApiResponse<ExecucaoTreino>> iniciarTreino(int treinoId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/execucao/treinos/$treinoId/iniciar'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return ApiResponse.success(
          data: ExecucaoTreino.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao iniciar treino',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Buscar execução atual em andamento
  Future<ApiResponse<ExecucaoTreino>> buscarExecucaoAtual() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/execucao/atual'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ExecucaoTreino.fromJson(data['data']),
          message: data['message'],
        );
      } else if (response.statusCode == 404) {
        return ApiResponse.notFound(
          message: data['message'] ?? 'Nenhum treino em andamento',
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao buscar execução',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Pausar treino
  Future<ApiResponse<void>> pausarTreino(int execucaoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/pausar'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao pausar treino',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Retomar treino pausado
  Future<ApiResponse<void>> retomarTreino(int execucaoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/retomar'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao retomar treino',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Avançar para próximo exercício
  Future<ApiResponse<ExecucaoTreino>> proximoExercicio(int execucaoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/proximo-exercicio'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ExecucaoTreino.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao avançar exercício',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Voltar para exercício anterior
  Future<ApiResponse<ExecucaoTreino>> exercicioAnterior(int execucaoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/exercicio-anterior'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ExecucaoTreino.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao voltar exercício',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Atualizar progresso do exercício atual
  Future<ApiResponse<void>> atualizarExercicio(
    int execucaoId,
    AtualizacaoExercicio atualizacao,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/atualizar-exercicio'),
        headers: _headers,
        body: json.encode(atualizacao.toJson()),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao atualizar exercício',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Finalizar treino
  Future<ApiResponse<ExecucaoTreino>> finalizarTreino(
    int execucaoId, {
    String? observacoes,
    int? tempoTotalSegundos,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (observacoes != null) body['observacoes'] = observacoes;
      if (tempoTotalSegundos != null) body['tempo_total_segundos'] = tempoTotalSegundos;

      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/finalizar'),
        headers: _headers,
        body: body.isNotEmpty ? json.encode(body) : null,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ExecucaoTreino.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao finalizar treino',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Cancelar treino
  Future<ApiResponse<void>> cancelarTreino(int execucaoId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/execucao/$execucaoId/cancelar'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao cancelar treino',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Buscar histórico de execuções
  Future<ApiResponse<List<ExecucaoTreino>>> buscarHistorico({
    String? status,
    int? treinoId,
    String? dataInicio,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (treinoId != null) queryParams['treino_id'] = treinoId.toString();
      if (dataInicio != null) queryParams['data_inicio'] = dataInicio;

      final uri = Uri.parse('$baseUrl/api/execucao/historico')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: _headers);
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final execucoes = (data['data']['data'] as List)
            .map((item) => ExecucaoTreino.fromJson(item))
            .toList();

        return ApiResponse.success(
          data: execucoes,
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao buscar histórico',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }

  /// Buscar execução específica
  Future<ApiResponse<ExecucaoTreino>> buscarExecucao(int execucaoId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/execucao/$execucaoId'),
        headers: _headers,
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: ExecucaoTreino.fromJson(data['data']),
          message: data['message'],
        );
      } else {
        return ApiResponse.error(
          message: data['message'] ?? 'Erro ao buscar execução',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Erro de conexão: $e',
      );
    }
  }
}

/// Classe para estruturar dados de atualização do exercício
class AtualizacaoExercicio {
  final int? seriesRealizadas;
  final int? repeticoesRealizadas;
  final double? pesoUtilizado;
  final int? tempoExecutadoSegundos;
  final int? tempoDescansoRealizado;
  final String? observacoes;

  AtualizacaoExercicio({
    this.seriesRealizadas,
    this.repeticoesRealizadas,
    this.pesoUtilizado,
    this.tempoExecutadoSegundos,
    this.tempoDescansoRealizado,
    this.observacoes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (seriesRealizadas != null) data['series_realizadas'] = seriesRealizadas;
    if (repeticoesRealizadas != null) data['repeticoes_realizadas'] = repeticoesRealizadas;
    if (pesoUtilizado != null) data['peso_utilizado'] = pesoUtilizado;
    if (tempoExecutadoSegundos != null) data['tempo_executado_segundos'] = tempoExecutadoSegundos;
    if (tempoDescansoRealizado != null) data['tempo_descanso_realizado'] = tempoDescansoRealizado;
    if (observacoes != null) data['observacoes'] = observacoes;
    
    return data;
  }
}

/// Classe para padronizar respostas da API
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
    this.errors,
  });

  factory ApiResponse.success({
    T? data,
    required String message,
  }) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error({
    required String message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  factory ApiResponse.notFound({
    required String message,
  }) {
    return ApiResponse(
      success: false,
      message: message,
      statusCode: 404,
    );
  }

  bool get isSuccess => success;
  bool get isError => !success;
  bool get isNotFound => statusCode == 404;
  bool get isUnauthorized => statusCode == 401;
  bool get isValidationError => statusCode == 422;
}