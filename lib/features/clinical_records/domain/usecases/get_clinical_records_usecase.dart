import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/clinical_record_entity.dart';
import '../repositories/clinical_record_repository.dart';

class GetClinicalRecordsParams {
  final int page;
  final int pageSize;
  final String? search;

  GetClinicalRecordsParams({this.page = 1, this.pageSize = 10, this.search});
}

class GetClinicalRecordsUseCase {
  final ClinicalRecordRepository repository;

  GetClinicalRecordsUseCase(this.repository);

  Future<Either<Failure, List<ClinicalRecordEntity>>> call(
    GetClinicalRecordsParams params,
  ) async {
    return await repository.getClinicalRecords(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
    );
  }
}
