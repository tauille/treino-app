// OPCIONAL: Usar DIO em vez de HTTP (você já tem instalado!)
// core/services/treino_service_dio.dart

import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../../models/treino_model.dart';
import '../../models/api_response_model.dart';

class TreinoServiceDio {
  late final Dio _dio;

  TreinoServiceDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptors para logs e debug
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) => print('🌐 API: $object'),
      ),
    );
  }

  /// Criar treino com DIO
  Future<TreinoModel?> criarTreino(TreinoModel treino) async {
    try {
      final response = await _dio.post(
        '/api/flutter/treinos',
        data: {
          'nome_treino': treino.nomeTreino,
          'tipo_treino': treino.tipoTreino,
          'descricao': treino.descricao,
          'dificuldade': treino.dificuldade,
        },
      );

      if (response.statusCode == 201) {
        final apiResponse = ApiResponseModel.fromJson(response.data);
        
        if (apiResponse.success && apiResponse.data != null) {
          return TreinoModel.fromJson(apiResponse.data);
        }
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Erro ao criar treino',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro HTTP ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  /// Listar treinos com DIO
  Future<List<TreinoModel>> listarTreinos() async {
    try {
      final response = await _dio.get('/api/flutter/treinos');

      if (response.statusCode == 200) {
        final apiResponse = ApiResponseModel.fromJson(response.data);
        
        if (apiResponse.success && apiResponse.data != null) {
          final List<dynamic> treinosData = apiResponse.data is List 
              ? apiResponse.data 
              : [apiResponse.data];
          
          return treinosData
              .map((json) => TreinoModel.fromJson(json))
              .toList();
        }
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Erro ao listar treinos',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Erro HTTP ${e.response!.statusCode}: ${e.response!.data}');
      } else {
        throw Exception('Erro de conexão: ${e.message}');
      }
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }
}