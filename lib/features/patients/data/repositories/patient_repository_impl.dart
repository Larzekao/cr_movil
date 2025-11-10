import 'package:dartz/dartz.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/patient_remote_datasource.dart';
import '../models/patient_model.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, PaginatedPatients>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering,
  }) async {
    try {
      final response = await remoteDataSource.getPatients(
        page: page,
        pageSize: pageSize,
        search: search,
        ordering: ordering,
      );

      final count = response['count'] as int? ?? 0;
      final next = response['next'] as String?;
      final previous = response['previous'] as String?;
      final results =
          (response['results'] as List<dynamic>?)
              ?.map(
                (json) => PatientModel.fromJson(json as Map<String, dynamic>),
              )
              .map((model) => model.toEntity())
              .toList() ??
          [];

      return Right(
        PaginatedPatients(
          count: count,
          next: next,
          previous: previous,
          results: results,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al cargar pacientes: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> getPatientById(String id) async {
    try {
      final patient = await remoteDataSource.getPatientById(id);
      return Right(patient.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al cargar paciente: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> createPatient(
    Map<String, dynamic> patientData,
  ) async {
    try {
      final patient = await remoteDataSource.createPatient(patientData);
      return Right(patient.toEntity());
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors ?? {}));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al crear paciente: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PatientEntity>> updatePatient(
    String id,
    Map<String, dynamic> patientData,
  ) async {
    try {
      final patient = await remoteDataSource.updatePatient(id, patientData);
      return Right(patient.toEntity());
    } on DuplicateException catch (e) {
      return Left(DuplicateFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.errors ?? {}));
    } on NotFoundException catch (e) {
      return Left(ServerFailure(e.message, statusCode: 404));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al actualizar paciente: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deletePatient(String id) async {
    try {
      await remoteDataSource.deletePatient(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al eliminar paciente: ${e.toString()}'));
    }
  }
}
