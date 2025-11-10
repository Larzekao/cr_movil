import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/clinical_record_entity.dart';
import '../entities/clinical_form_entity.dart';
import '../entities/timeline_event_entity.dart';

abstract class ClinicalRecordRepository {
  // ===== CLINICAL RECORDS =====
  Future<Either<Failure, List<ClinicalRecordEntity>>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? status,
    String? patientId,
  });

  Future<Either<Failure, ClinicalRecordEntity>> getClinicalRecordById(
    String id,
  );

  Future<Either<Failure, ClinicalRecordEntity>> createClinicalRecord(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, ClinicalRecordEntity>> updateClinicalRecord(
    String id,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, void>> deleteClinicalRecord(String id);

  Future<Either<Failure, ClinicalRecordEntity>> archiveClinicalRecord(
    String id,
  );

  Future<Either<Failure, ClinicalRecordEntity>> closeClinicalRecord(String id);

  Future<Either<Failure, List<TimelineEventEntity>>> getTimeline(
    String clinicalRecordId,
  );

  // ===== CLINICAL FORMS =====
  Future<Either<Failure, List<ClinicalFormEntity>>> getForms({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? formType,
    String? clinicalRecordId,
  });

  Future<Either<Failure, ClinicalFormEntity>> getFormById(String id);

  Future<Either<Failure, ClinicalFormEntity>> createForm(
    Map<String, dynamic> data,
  );

  Future<Either<Failure, ClinicalFormEntity>> updateForm(
    String id,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, void>> deleteForm(String id);

  Future<Either<Failure, List<ClinicalFormEntity>>> getFormsByRecord(
    String clinicalRecordId,
  );

  Future<Either<Failure, List<Map<String, String>>>> getFormTypes();
}
