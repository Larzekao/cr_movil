import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/clinical_record_repository.dart';

class DeleteClinicalRecordUseCase {
  final ClinicalRecordRepository repository;

  DeleteClinicalRecordUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteClinicalRecord(id);
  }
}
