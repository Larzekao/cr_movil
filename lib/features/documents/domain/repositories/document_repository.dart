import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  /// Obtiene la lista de documentos con filtros opcionales
  Future<Either<Failure, List<DocumentEntity>>> getDocuments({
    String? clinicalRecordId,
    String? documentType,
    String? search,
  });

  /// Obtiene un documento por ID
  Future<Either<Failure, DocumentEntity>> getDocumentById(String id);

  /// Crea un nuevo documento
  Future<Either<Failure, DocumentEntity>> createDocument({
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
  });

  /// Actualiza un documento existente
  Future<Either<Failure, DocumentEntity>> updateDocument({
    required String id,
    String? title,
    String? description,
    DateTime? documentDate,
    String? specialty,
    String? doctorName,
    String? doctorLicense,
    Map<String, dynamic>? content,
    List<String>? tags,
  });

  /// Elimina un documento
  Future<Either<Failure, void>> deleteDocument(String id);

  /// Sube un archivo para un documento
  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String clinicalRecordId,
    required String documentType,
    required String title,
    required DateTime documentDate,
    required String filePath,
    String? description,
    String? specialty,
    String? doctorName,
    String? doctorLicense,
  });

  /// Descarga un documento
  Future<Either<Failure, String>> downloadDocument(String documentId);
}
