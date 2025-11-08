import 'package:dartz/dartz.dart';
import '../../domain/entities/clinical_record_entity.dart';
import '../../domain/repositories/clinical_record_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../datasources/clinical_record_remote_datasource.dart';

class ClinicalRecordRepositoryImpl implements ClinicalRecordRepository {
  final ClinicalRecordRemoteDataSource remoteDataSource;
  final dynamic networkInfo; // keep loose to avoid strong coupling

  ClinicalRecordRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<ClinicalRecordEntity>>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      final records = await remoteDataSource.getClinicalRecords(
        page: page,
        pageSize: pageSize,
        search: search,
      );
      return Right(records.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al cargar historias clínicas: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ClinicalRecordEntity>> getClinicalRecordById(
    String id,
  ) async {
    try {
      final record = await remoteDataSource.getClinicalRecordById(id);
      return Right(record.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al cargar historia clínica: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ClinicalRecordEntity>> createClinicalRecord(
    Map<String, dynamic> data,
  ) async {
    try {
      final record = await remoteDataSource.createClinicalRecord(data);
      return Right(record.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al crear historia clínica: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ClinicalRecordEntity>> updateClinicalRecord(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final record = await remoteDataSource.updateClinicalRecord(id, data);
      return Right(record.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al actualizar historia clínica: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteClinicalRecord(String id) async {
    try {
      await remoteDataSource.deleteClinicalRecord(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al eliminar historia clínica: ${e.toString()}'),
      );
    }
  }
}
