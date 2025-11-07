import 'package:dartz/dartz.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/repositories/patient_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/patient_remote_datasource.dart';

class PatientRepositoryImpl implements PatientRepository {
  final PatientRemoteDataSource remoteDataSource;

  PatientRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PatientEntity>>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      final patients = await remoteDataSource.getPatients(
        page: page,
        pageSize: pageSize,
        search: search,
      );
      return Right(patients.map((model) => model.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
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
