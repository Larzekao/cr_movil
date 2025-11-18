import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

/// Fuente de datos remota para notificaciones y tokens FCM
abstract class NotificationRemoteDataSource {
  /// Envía el token FCM al backend
  Future<void> updateFcmToken(String fcmToken);

  /// Elimina el token FCM del backend
  Future<void> deleteFcmToken();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final DioClient client;

  NotificationRemoteDataSourceImpl({required this.client});

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await client.post(
        '/users/update_fcm_token/',
        data: {'fcm_token': fcmToken},
      );
    } on DioException catch (e) {
      throw Exception('Error actualizando token FCM: ${e.message}');
    }
  }

  @override
  Future<void> deleteFcmToken() async {
    try {
      await client.post('/users/delete_fcm_token/');
    } on DioException catch (e) {
      throw Exception('Error eliminando token FCM: ${e.message}');
    }
  }
}
