import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/clinical_record_entity.dart';
import '../repositories/clinical_record_repository.dart';

class GetClinicalRecordDetailUseCase {
  final ClinicalRecordRepository repository;

  GetClinicalRecordDetailUseCase(this.repository);

  Future<Either<Failure, ClinicalRecordEntity>> call(String id) async {
    return await repository.getClinicalRecordById(id);
  }
}
