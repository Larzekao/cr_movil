import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/clinical_record_entity.dart';
import '../repositories/clinical_record_repository.dart';

class UpdateClinicalRecordParams {
  final String id;
  final Map<String, dynamic> data;

  UpdateClinicalRecordParams({required this.id, required this.data});
}

class UpdateClinicalRecordUseCase {
  final ClinicalRecordRepository repository;

  UpdateClinicalRecordUseCase(this.repository);

  Future<Either<Failure, ClinicalRecordEntity>> call(
    UpdateClinicalRecordParams params,
  ) async {
    return await repository.updateClinicalRecord(params.id, params.data);
  }
}
