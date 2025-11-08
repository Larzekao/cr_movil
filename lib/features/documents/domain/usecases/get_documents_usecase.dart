import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

class GetDocumentsUseCase {
  final DocumentRepository repository;

  GetDocumentsUseCase(this.repository);

  Future<Either<Failure, List<DocumentEntity>>> call({
    String? clinicalRecordId,
    String? documentType,
    String? search,
  }) async {
    return await repository.getDocuments(
      clinicalRecordId: clinicalRecordId,
      documentType: documentType,
      search: search,
    );
  }
}
