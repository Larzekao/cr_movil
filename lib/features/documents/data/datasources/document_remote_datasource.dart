import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_client.dart';
import '../models/document_model.dart';

abstract class DocumentRemoteDataSource {
  Future<List<DocumentModel>> getDocuments({
    String? clinicalRecordId,
    String? documentType,
    String? search,
  });

  Future<DocumentModel> getDocumentById(String id);

  Future<DocumentModel> createDocument({
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

  Future<DocumentModel> updateDocument({
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

  Future<void> deleteDocument(String id);

  Future<DocumentModel> uploadDocument({
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

  Future<String> downloadDocument(String documentId);
}

class DocumentRemoteDataSourceImpl implements DocumentRemoteDataSource {
  final DioClient client;
  final Logger _logger = Logger();

  DocumentRemoteDataSourceImpl({required this.client});

  @override
  Future<List<DocumentModel>> getDocuments({
    String? clinicalRecordId,
    String? documentType,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (clinicalRecordId != null) {
        queryParams['clinical_record'] = clinicalRecordId;
      }
      if (documentType != null) queryParams['document_type'] = documentType;
      if (search != null) queryParams['search'] = search;

      final response = await client.get(
        ApiConstants.documents,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        // El backend devuelve una respuesta paginada con la estructura:
        // { "count": int, "next": string?, "previous": string?, "results": [...] }
        final responseData = response.data as Map<String, dynamic>;

        // Extraer la lista de resultados
        final List<dynamic> results = responseData['results'] as List<dynamic>;

        return results
            .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw ServerException(
          message: 'Error al obtener documentos',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _logger.e('Error fetching documents', error: e);
      throw ServerException(message: 'Error de conexión: $e');
    }
  }

  @override
  Future<DocumentModel> getDocumentById(String id) async {
    try {
      final response = await client.get('${ApiConstants.documents}$id/');

      if (response.statusCode == 200 && response.data != null) {
        return DocumentModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: 'Error al obtener documento',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _logger.e('Error fetching document by id', error: e);
      throw ServerException(message: 'Error de conexión: $e');
    }
  }

  @override
  Future<DocumentModel> createDocument({
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
      final data = {
        'clinical_record': clinicalRecordId,
        'document_type': documentType,
        'title': title,
        'description': description,
        'document_date': documentDate.toIso8601String(),
        'specialty': specialty,
        'doctor_name': doctorName,
        'doctor_license': doctorLicense,
        'content': content,
        'tags': tags ?? [],
      };

      final response = await client.post(ApiConstants.documents, data: data);

      if (response.statusCode == 201 && response.data != null) {
        return DocumentModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: 'Error al crear documento',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _logger.e('Error creating document', error: e);
      throw ServerException(message: 'Error de conexión: $e');
    }
  }

  @override
  Future<DocumentModel> updateDocument({
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
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (documentDate != null) {
        data['document_date'] = documentDate.toIso8601String();
      }
      if (specialty != null) data['specialty'] = specialty;
      if (doctorName != null) data['doctor_name'] = doctorName;
      if (doctorLicense != null) data['doctor_license'] = doctorLicense;
      if (content != null) data['content'] = content;
      if (tags != null) data['tags'] = tags;

      final response = await client.patch(
        '${ApiConstants.documents}$id/',
        data: data,
      );

      if (response.statusCode == 200 && response.data != null) {
        return DocumentModel.fromJson(response.data as Map<String, dynamic>);
      } else {
        throw ServerException(
          message: 'Error al actualizar documento',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _logger.e('Error updating document', error: e);
      throw ServerException(message: 'Error de conexión: $e');
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      final response = await client.delete('${ApiConstants.documents}$id/');

      if (response.statusCode != 204 && response.statusCode != 200) {
        throw ServerException(
          message: 'Error al eliminar documento',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _logger.e('Error deleting document', error: e);
      throw ServerException(message: 'Error de conexión: $e');
    }
  }

  @override
  Future<DocumentModel> uploadDocument({
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
      _logger.i('Iniciando upload de documento: $title');

      // Construir FormData con campos requeridos
      final formData = FormData.fromMap({
        'clinical_record': clinicalRecordId,
        'document_type': documentType,
        'title': title,
        'document_date': documentDate.toIso8601String(),
        'file': await MultipartFile.fromFile(filePath),
      });

      // Agregar campos opcionales solo si están presentes
      if (description != null && description.isNotEmpty) {
        formData.fields.add(MapEntry('description', description));
      }
      if (specialty != null && specialty.isNotEmpty) {
        formData.fields.add(MapEntry('specialty', specialty));
      }
      if (doctorName != null && doctorName.isNotEmpty) {
        formData.fields.add(MapEntry('doctor_name', doctorName));
      }
      if (doctorLicense != null && doctorLicense.isNotEmpty) {
        formData.fields.add(MapEntry('doctor_license', doctorLicense));
      }

      _logger.d('FormData preparado para upload: $formData');

      // Enviar POST multipart directamente a /api/documents/
      final response = await client.post(
        ApiConstants.documents,
        data: formData,
      );

      _logger.d('Upload response status: ${response.statusCode}');
      _logger.d('Upload response data: ${response.data}');

      if (response.statusCode == 201 && response.data != null) {
        final document = DocumentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        _logger.i('Documento subido exitosamente: ${document.id}');
        return document;
      } else {
        final errorMessage =
            response.data?['detail'] ??
            response.data?['error'] ??
            'Error al subir documento';
        throw ServerException(
          message: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _logger.e(
        'DioException durante upload',
        error: e,
        stackTrace: e.stackTrace,
      );

      // Manejo específico de errores de Dio
      if (e.type == DioExceptionType.connectionTimeout) {
        throw ServerException(
          message: 'Tiempo de conexión agotado. Intente de nuevo.',
          statusCode: e.response?.statusCode,
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw ServerException(
          message: 'Tiempo de espera agotado. El servidor tardó demasiado.',
          statusCode: e.response?.statusCode,
        );
      } else if (e.type == DioExceptionType.unknown) {
        throw ServerException(
          message: 'Error de conexión de red. Verifica tu conexión.',
          statusCode: e.response?.statusCode,
        );
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        final errorMessage = errorData?['detail'] ?? 'Solicitud inválida';
        throw ServerException(message: errorMessage, statusCode: 400);
      } else if (e.response?.statusCode == 401) {
        throw ServerException(
          message: 'No autorizado. Por favor inicia sesión nuevamente.',
          statusCode: 401,
        );
      } else if (e.response?.statusCode == 403) {
        throw ServerException(
          message: 'Acceso denegado. No tienes permiso para subir documentos.',
          statusCode: 403,
        );
      } else if (e.response?.statusCode == 413) {
        throw ServerException(
          message: 'El archivo es demasiado grande. Máximo 100MB.',
          statusCode: 413,
        );
      } else if (e.response?.statusCode == 500) {
        throw ServerException(
          message: 'Error interno del servidor. Intenta más tarde.',
          statusCode: 500,
        );
      }

      throw ServerException(
        message: 'Error al subir documento: ${e.message}',
        statusCode: e.response?.statusCode,
      );
    } on ServerException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e(
        'Error inesperado al subir documento',
        error: e,
        stackTrace: stackTrace,
      );
      throw ServerException(message: 'Error inesperado: ${e.toString()}');
    }
  }

  @override
  Future<String> downloadDocument(String documentId) async {
    try {
      final response = await client.get(
        '${ApiConstants.documents}$documentId/download/',
      );

      if (response.statusCode == 200 && response.data != null) {
        // Retorna la URL de descarga del archivo
        return response.data['download_url'] as String;
      } else {
        throw ServerException(
          message: 'Error al descargar documento',
          statusCode: response.statusCode,
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      _logger.e('Error downloading document', error: e);
      throw ServerException(message: 'Error de conexión: $e');
    }
  }
}
