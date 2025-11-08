import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/clinical_record_entity.dart';

abstract class ClinicalRecordRepository {
  Future<Either<Failure, List<ClinicalRecordEntity>>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
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
}
