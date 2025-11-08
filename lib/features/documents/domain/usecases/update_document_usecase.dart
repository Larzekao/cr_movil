import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

class UpdateDocumentUseCase {
  final DocumentRepository repository;

  UpdateDocumentUseCase(this.repository);

  Future<Either<Failure, DocumentEntity>> call({
    required String id,
    String? title,
    String? description,
    DateTime? documentDate,
    String? specialty,
    String? doctorName,
    String? doctorLicense,
    Map<String, dynamic>? content,
    List<String>? tags,
  }) async {
    return await repository.updateDocument(
      id: id,
      title: title,
      description: description,
      documentDate: documentDate,
      specialty: specialty,
      doctorName: doctorName,
      doctorLicense: doctorLicense,
      content: content,
      tags: tags,
    );
  }
}
