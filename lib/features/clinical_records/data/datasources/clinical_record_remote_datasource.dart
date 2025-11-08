import 'package:dio/dio.dart';
import '../models/clinical_record_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';

abstract class ClinicalRecordRemoteDataSource {
  Future<List<ClinicalRecordModel>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
  });

  Future<ClinicalRecordModel> getClinicalRecordById(String id);

  Future<ClinicalRecordModel> createClinicalRecord(Map<String, dynamic> data);

  Future<ClinicalRecordModel> updateClinicalRecord(
    String id,
    Map<String, dynamic> data,
  );

  Future<void> deleteClinicalRecord(String id);
}

class ClinicalRecordRemoteDataSourceImpl
    implements ClinicalRecordRemoteDataSource {
  final DioClient dioClient;

  ClinicalRecordRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<List<ClinicalRecordModel>> getClinicalRecords({
    int page = 1,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'page_size': pageSize.toString(),
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await dioClient.get(
        'clinical-records/',
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
      final response = await dioClient.get('clinical-records/$id/');
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
      final response = await dioClient.post('clinical-records/', data: data);
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
        'clinical-records/$id/',
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
      await dioClient.delete('clinical-records/$id/');
    } on DioException catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
