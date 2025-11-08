import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

class UploadDocumentUseCase {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  Future<Either<Failure, DocumentEntity>> call({
    required String clinicalRecordId,
    required String documentType,
    required String title,
    required DateTime documentDate,
    required String filePath,
    String? description,
    String? specialty,
    String? doctorName,
    String? doctorLicense,
  }) async {
    return await repository.uploadDocument(
      clinicalRecordId: clinicalRecordId,
      documentType: documentType,
      title: title,
      documentDate: documentDate,
      filePath: filePath,
      description: description,
      specialty: specialty,
      doctorName: doctorName,
      doctorLicense: doctorLicense,
    );
  }
}
