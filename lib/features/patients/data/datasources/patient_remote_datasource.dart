import 'package:dio/dio.dart';
import '../models/patient_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
  });

  Future<PatientModel> getPatientById(String id);

  Future<PatientModel> createPatient(Map<String, dynamic> patientData);

  Future<PatientModel> updatePatient(
    String id,
    Map<String, dynamic> patientData,
  );

  Future<void> deletePatient(String id);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient dioClient;

  PatientRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<PatientModel>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await dioClient.get(
        ApiConstants.patients,
        queryParameters: queryParams,
      );

      if (response.data['results'] != null) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => PatientModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Pacientes no encontrados');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Error del servidor al cargar pacientes');
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al cargar pacientes: $e');
    }
  }

  @override
  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await dioClient.get('${ApiConstants.patients}$id/');
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Paciente no encontrado');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Error del servidor al cargar paciente');
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al cargar paciente: $e');
    }
  }

  @override
  Future<PatientModel> createPatient(Map<String, dynamic> patientData) async {
    try {
      final response = await dioClient.post(
        ApiConstants.patients,
        data: patientData,
      );
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(message: 'Datos inválidos: ${e.response?.data}');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Error del servidor al crear paciente');
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al crear paciente: $e');
    }
  }

  @override
  Future<PatientModel> updatePatient(
    String id,
    Map<String, dynamic> patientData,
  ) async {
    try {
      final response = await dioClient.patch(
        '${ApiConstants.patients}$id/',
        data: patientData,
      );
      return PatientModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Paciente no encontrado');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(message: 'Datos inválidos: ${e.response?.data}');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Error del servidor al actualizar paciente');
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al actualizar paciente: $e');
    }
  }

  @override
  Future<void> deletePatient(String id) async {
    try {
      await dioClient.delete('${ApiConstants.patients}$id/');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Paciente no encontrado');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Error del servidor al eliminar paciente');
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Error inesperado al eliminar paciente: $e');
    }
  }
}
