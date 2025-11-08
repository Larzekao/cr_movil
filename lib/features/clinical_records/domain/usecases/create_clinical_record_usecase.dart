import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/clinical_record_entity.dart';
import '../repositories/clinical_record_repository.dart';

class CreateClinicalRecordUseCase {
  final ClinicalRecordRepository repository;

  CreateClinicalRecordUseCase(this.repository);

  Future<Either<Failure, ClinicalRecordEntity>> call(
    Map<String, dynamic> data,
  ) async {
    return await repository.createClinicalRecord(data);
  }
}
