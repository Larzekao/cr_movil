import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/document_repository.dart';

class DeleteDocumentUseCase {
  final DocumentRepository repository;

  DeleteDocumentUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteDocument(id);
  }
}
