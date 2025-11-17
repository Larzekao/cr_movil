import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../datasources/document_remote_datasource.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  final DocumentRemoteDataSource remoteDataSource;

  DocumentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments({
    String? clinicalRecordId,
    String? documentType,
    String? search,
  }) async {
    try {
      final documents = await remoteDataSource.getDocuments(
        clinicalRecordId: clinicalRecordId,
        documentType: documentType,
        search: search,
      );
      return Right(documents);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> getDocumentById(String id) async {
    try {
      final document = await remoteDataSource.getDocumentById(id);
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final document = await remoteDataSource.createDocument(
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
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
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
  }) async {
    try {
      final document = await remoteDataSource.updateDocument(
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
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      await remoteDataSource.deleteDocument(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
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
  }) async {
    try {
      // Validación básica
      if (clinicalRecordId.isEmpty) {
        return Left(ServerFailure('ID de historia clínica es requerido'));
      }
      if (documentType.isEmpty) {
        return Left(ServerFailure('Tipo de documento es requerido'));
      }
      if (title.isEmpty) {
        return Left(ServerFailure('Título del documento es requerido'));
      }
      if (filePath.isEmpty) {
        return Left(ServerFailure('Ruta del archivo es requerida'));
      }

      final document = await remoteDataSource.uploadDocument(
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
      return Right(document);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al subir documento: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadDocument(String documentId) async {
    try {
      final url = await remoteDataSource.downloadDocument(documentId);
      return Right(url);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, statusCode: e.statusCode));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
