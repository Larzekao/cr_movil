import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

class CreateDocumentUseCase {
  final DocumentRepository repository;

  CreateDocumentUseCase(this.repository);

  Future<Either<Failure, DocumentEntity>> call({
    required String clinicalRecordId,
    required String documentType,
    required String title,
    String? description,
    required DateTime documentDate,
    String? specialty,
    String? doctorName,
    String? doctorLicense,
    Map<String, dynamic>? content,
    List<String>? tags,
  }) async {
    return await repository.createDocument(
      clinicalRecordId: clinicalRecordId,
      documentType: documentType,
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
