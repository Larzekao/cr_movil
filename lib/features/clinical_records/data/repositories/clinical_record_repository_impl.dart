import 'package:dartz/dartz.dart';
import '../../domain/entities/clinical_record_entity.dart';
import '../../domain/entities/clinical_form_entity.dart';
import '../../domain/entities/timeline_event_entity.dart';
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

  // ===== CLINICAL RECORDS IMPLEMENTATION =====

  @override
  Future<Either<Failure, List<ClinicalRecordEntity>>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? status,
    String? patientId,
  }) async {
    try {
      final records = await remoteDataSource.getClinicalRecords(
        page: page,
        pageSize: pageSize,
        search: search,
        status: status,
        patientId: patientId,
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

  @override
  Future<Either<Failure, ClinicalRecordEntity>> archiveClinicalRecord(
    String id,
  ) async {
    try {
      final record = await remoteDataSource.archiveClinicalRecord(id);
      return Right(record.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al archivar historia clínica: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ClinicalRecordEntity>> closeClinicalRecord(
    String id,
  ) async {
    try {
      final record = await remoteDataSource.closeClinicalRecord(id);
      return Right(record.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al cerrar historia clínica: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<TimelineEventEntity>>> getTimeline(
    String clinicalRecordId,
  ) async {
    try {
      final events = await remoteDataSource.getTimeline(clinicalRecordId);
      return Right(events.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al cargar timeline: ${e.toString()}'));
    }
  }

  // ===== CLINICAL FORMS IMPLEMENTATION =====

  @override
  Future<Either<Failure, List<ClinicalFormEntity>>> getForms({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? formType,
    String? clinicalRecordId,
  }) async {
    try {
      final forms = await remoteDataSource.getForms(
        page: page,
        pageSize: pageSize,
        search: search,
        formType: formType,
        clinicalRecordId: clinicalRecordId,
      );
      return Right(forms.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al cargar formularios: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, ClinicalFormEntity>> getFormById(String id) async {
    try {
      final form = await remoteDataSource.getFormById(id);
      return Right(form.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al cargar formulario: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ClinicalFormEntity>> createForm(
    Map<String, dynamic> data,
  ) async {
    try {
      final form = await remoteDataSource.createForm(data);
      return Right(form.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error al crear formulario: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ClinicalFormEntity>> updateForm(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final form = await remoteDataSource.updateForm(id, data);
      return Right(form.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al actualizar formulario: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteForm(String id) async {
    try {
      await remoteDataSource.deleteForm(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al eliminar formulario: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<ClinicalFormEntity>>> getFormsByRecord(
    String clinicalRecordId,
  ) async {
    try {
      final forms = await remoteDataSource.getFormsByRecord(clinicalRecordId);
      return Right(forms.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          'Error al cargar formularios de la historia: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Map<String, String>>>> getFormTypes() async {
    try {
      final types = await remoteDataSource.getFormTypes();
      return Right(types);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(
        ServerFailure('Error al cargar tipos de formularios: ${e.toString()}'),
      );
    }
  }
}
