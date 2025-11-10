import 'package:dio/dio.dart';
import '../models/clinical_record_model.dart';
import '../models/clinical_form_model.dart';
import '../models/timeline_event_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ClinicalRecordRemoteDataSource {
  // ===== CLINICAL RECORDS =====
  Future<List<ClinicalRecordModel>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? status,
    String? patientId,
  });

  Future<ClinicalRecordModel> getClinicalRecordById(String id);

  Future<ClinicalRecordModel> createClinicalRecord(Map<String, dynamic> data);

  Future<ClinicalRecordModel> updateClinicalRecord(
    String id,
    Map<String, dynamic> data,
  );

  Future<void> deleteClinicalRecord(String id);

  Future<ClinicalRecordModel> archiveClinicalRecord(String id);

  Future<ClinicalRecordModel> closeClinicalRecord(String id);

  Future<List<TimelineEventModel>> getTimeline(String clinicalRecordId);

  // ===== CLINICAL FORMS =====
  Future<List<ClinicalFormModel>> getForms({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? formType,
    String? clinicalRecordId,
  });

  Future<ClinicalFormModel> getFormById(String id);

  Future<ClinicalFormModel> createForm(Map<String, dynamic> data);

  Future<ClinicalFormModel> updateForm(String id, Map<String, dynamic> data);

  Future<void> deleteForm(String id);

  Future<List<ClinicalFormModel>> getFormsByRecord(String clinicalRecordId);

  Future<List<Map<String, String>>> getFormTypes();
}

class ClinicalRecordRemoteDataSourceImpl
    implements ClinicalRecordRemoteDataSource {
  final DioClient dioClient;

  ClinicalRecordRemoteDataSourceImpl({required this.dioClient});

  // ===== CLINICAL RECORDS IMPLEMENTATION =====

  @override
  Future<List<ClinicalRecordModel>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? status,
    String? patientId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (status != null && status.isNotEmpty) 'status': status,
        if (patientId != null && patientId.isNotEmpty) 'patient': patientId,
      };

      final response = await dioClient.get(
        '/clinical-records/',
        queryParameters: queryParams,
      );

      if (response.data != null && response.data['results'] != null) {
        final List<dynamic> results = response.data['results'];
        return results
            .map((json) => ClinicalRecordModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalRecordModel> getClinicalRecordById(String id) async {
    try {
      final response = await dioClient.get('/clinical-records/$id/');
      return ClinicalRecordModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalRecordModel> createClinicalRecord(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.post('/clinical-records/', data: data);
      return ClinicalRecordModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalRecordModel> updateClinicalRecord(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.patch(
        '/clinical-records/$id/',
        data: data,
      );
      return ClinicalRecordModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteClinicalRecord(String id) async {
    try {
      await dioClient.delete('/clinical-records/$id/');
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalRecordModel> archiveClinicalRecord(String id) async {
    try {
      await dioClient.post('/clinical-records/$id/archive/');
      // El backend devuelve un objeto con message y status
      // Debemos obtener la historia actualizada
      final recordResponse = await dioClient.get('/clinical-records/$id/');
      return ClinicalRecordModel.fromJson(recordResponse.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalRecordModel> closeClinicalRecord(String id) async {
    try {
      await dioClient.post('/clinical-records/$id/close/');
      // El backend devuelve un objeto con message y status
      // Debemos obtener la historia actualizada
      final recordResponse = await dioClient.get('/clinical-records/$id/');
      return ClinicalRecordModel.fromJson(recordResponse.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<TimelineEventModel>> getTimeline(String clinicalRecordId) async {
    try {
      final response = await dioClient.get(
        '/clinical-records/$clinicalRecordId/timeline/',
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> results = response.data;
        return results
            .map((json) => TimelineEventModel.fromJson(json))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  // ===== CLINICAL FORMS IMPLEMENTATION =====

  @override
  Future<List<ClinicalFormModel>> getForms({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? formType,
    String? clinicalRecordId,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
        if (formType != null && formType.isNotEmpty) 'form_type': formType,
        if (clinicalRecordId != null && clinicalRecordId.isNotEmpty)
          'clinical_record': clinicalRecordId,
      };

      final response = await dioClient.get(
        '/clinical-records/forms/',
        queryParameters: queryParams,
      );

      if (response.data != null && response.data['results'] != null) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => ClinicalFormModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalFormModel> getFormById(String id) async {
    try {
      final response = await dioClient.get('/clinical-records/forms/$id/');
      return ClinicalFormModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalFormModel> createForm(Map<String, dynamic> data) async {
    try {
      final response = await dioClient.post(
        '/clinical-records/forms/',
        data: data,
      );
      return ClinicalFormModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ClinicalFormModel> updateForm(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await dioClient.patch(
        '/clinical-records/forms/$id/',
        data: data,
      );
      return ClinicalFormModel.fromJson(response.data);
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteForm(String id) async {
    try {
      await dioClient.delete('/clinical-records/forms/$id/');
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ClinicalFormModel>> getFormsByRecord(
    String clinicalRecordId,
  ) async {
    try {
      final response = await dioClient.get(
        '/clinical-records/forms/by_record/',
        queryParameters: {'clinical_record_id': clinicalRecordId},
      );

      if (response.data != null && response.data is List) {
        final List<dynamic> results = response.data;
        return results.map((json) => ClinicalFormModel.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Map<String, String>>> getFormTypes() async {
    try {
      final response = await dioClient.get(
        '/clinical-records/forms/form_types/',
      );

      if (response.data != null && response.data['form_types'] != null) {
        final List<dynamic> formTypes = response.data['form_types'];
        return formTypes.map<Map<String, String>>((item) {
          return {
            'value': item['value']?.toString() ?? '',
            'label': item['label']?.toString() ?? '',
          };
        }).toList();
      }

      return [];
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
