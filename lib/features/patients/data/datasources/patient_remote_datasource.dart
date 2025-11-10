import 'package:dio/dio.dart';
import '../models/patient_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';

abstract class PatientRemoteDataSource {
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
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
  Future<Map<String, dynamic>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (ordering != null && ordering.isNotEmpty) 'ordering': ordering,
      };

      final response = await dioClient.get(
        ApiConstants.patients,
        queryParameters: queryParams,
      );

      // Retornar toda la respuesta paginada: {count, next, previous, results}
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw UnauthorizedException();
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Pacientes no encontrados');
      } else if (e.response?.statusCode == 500) {
        throw ServerException(
          message: 'Error del servidor al cargar pacientes',
        );
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al cargar pacientes: $e',
      );
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
      } else if (e.response?.statusCode == 409) {
        // Manejar error de duplicado (PATIENT_DUPLICATE)
        final data = e.response?.data as Map<String, dynamic>?;
        final code = data?['code'] as String?;
        final message = data?['message'] as String?;

        if (code == 'PATIENT_DUPLICATE') {
          throw DuplicateException(
            message:
                message ??
                'Ya existe un paciente con este documento de identidad',
          );
        }
        throw ValidationException(
          message: message ?? 'Conflicto al crear paciente',
        );
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: 'Datos inválidos: ${e.response?.data}',
        );
      } else if (e.response?.statusCode == 500) {
        throw ServerException(message: 'Error del servidor al crear paciente');
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      if (e is DuplicateException) rethrow;
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
      } else if (e.response?.statusCode == 409) {
        // Manejar error de duplicado (PATIENT_DUPLICATE)
        final data = e.response?.data as Map<String, dynamic>?;
        final code = data?['code'] as String?;
        final message = data?['message'] as String?;

        if (code == 'PATIENT_DUPLICATE') {
          throw DuplicateException(
            message:
                message ??
                'Ya existe un paciente con este documento de identidad',
          );
        }
        throw ValidationException(
          message: message ?? 'Conflicto al actualizar paciente',
        );
      } else if (e.response?.statusCode == 404) {
        throw NotFoundException(message: 'Paciente no encontrado');
      } else if (e.response?.statusCode == 400) {
        throw ValidationException(
          message: 'Datos inválidos: ${e.response?.data}',
        );
      } else if (e.response?.statusCode == 500) {
        throw ServerException(
          message: 'Error del servidor al actualizar paciente',
        );
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      if (e is DuplicateException) rethrow;
      throw ServerException(
        message: 'Error inesperado al actualizar paciente: $e',
      );
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
        throw ServerException(
          message: 'Error del servidor al eliminar paciente',
        );
      }
      throw NetworkException(message: 'Error de red: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Error inesperado al eliminar paciente: $e',
      );
    }
  }
}
