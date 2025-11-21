import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/diabetes_prediction_model.dart';

abstract class DiabetesRemoteDataSource {
  Future<DiabetesPredictionModel> predictDiabetes(String patientId);
  Future<List<DiabetesPredictionModel>> getPredictionHistory(String patientId);
}

class DiabetesRemoteDataSourceImpl implements DiabetesRemoteDataSource {
  final DioClient dioClient;

  DiabetesRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<DiabetesPredictionModel> predictDiabetes(String patientId) async {
    try {
      final response = await dioClient.post(
        '/api/ai/diabetes/predict/',
        data: {'patient_id': patientId},
      );

      if (response.data['success'] == true) {
        return DiabetesPredictionModel.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Error al realizar predicción');
      }
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  @override
  Future<List<DiabetesPredictionModel>> getPredictionHistory(
    String patientId,
  ) async {
    try {
      final response = await dioClient.get(
        '/api/ai/diabetes/patient/$patientId/',
      );

      if (response.data is List) {
        return (response.data as List)
            .map((json) => DiabetesPredictionModel.fromJson(json))
            .toList();
      } else if (response.data['results'] != null) {
        return (response.data['results'] as List)
            .map((json) => DiabetesPredictionModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data != null) {
      if (error.response!.data is Map) {
        return error.response!.data['error'] ??
            error.response!.data['message'] ??
            'Error al conectar con el servidor';
      }
    }
    return error.message ?? 'Error de conexión';
  }
}
