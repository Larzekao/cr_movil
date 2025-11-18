import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/document_entity.dart';
import '../repositories/document_repository.dart';

/// Parámetros para el caso de uso de subida de documentos
class UploadDocumentParams {
  final String clinicalRecordId;
  final String documentType;
  final String title;
  final DateTime documentDate;
  final String filePath;
  final String? description;
  final String? specialty;
  final String? doctorName;
  final String? doctorLicense;

  UploadDocumentParams({
    required this.clinicalRecordId,
    required this.documentType,
    required this.title,
    required this.documentDate,
    required this.filePath,
    this.description,
    this.specialty,
    this.doctorName,
    this.doctorLicense,
  });
}

/// UseCase para subir un documento clínico a través de multipart
///
/// Maneja:
/// - Validación de parámetros requeridos
/// - Comunicación con el repositorio
/// - Conversión de errores a Failures
///
/// Flujo:
/// 1. Recibe parámetros de subida (archivo, metadata, paciente, etc.)
/// 2. Valida que los parámetros requeridos no estén vacíos
/// 3. Delega al repositorio que envía al backend
/// 4. Retorna Either<Failure, DocumentEntity>
class UploadDocumentUseCase
    extends UseCase<DocumentEntity, UploadDocumentParams> {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(
    UploadDocumentParams params,
  ) async {
    // Validar parámetros requeridos
    if (params.clinicalRecordId.isEmpty) {
      return Left(ServerFailure('ID de historia clínica es requerido'));
    }
    if (params.documentType.isEmpty) {
      return Left(ServerFailure('Tipo de documento es requerido'));
    }
    if (params.title.isEmpty) {
      return Left(ServerFailure('Título del documento es requerido'));
    }
    if (params.filePath.isEmpty) {
      return Left(ServerFailure('Ruta del archivo es requerida'));
    }

    // Delegar al repositorio
    return repository.uploadDocument(
      clinicalRecordId: params.clinicalRecordId,
      documentType: params.documentType,
      title: params.title,
      documentDate: params.documentDate,
      filePath: params.filePath,
      description: params.description,
      specialty: params.specialty,
      doctorName: params.doctorName,
      doctorLicense: params.doctorLicense,
    );
  }
}
