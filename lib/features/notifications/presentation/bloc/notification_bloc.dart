import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import 'notification_event.dart';
import 'notification_state.dart';

/// BLoC para gestionar el estado de las notificaciones push
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;
  final NotificationRemoteDataSource remoteDataSource;
  final Logger _logger = Logger();

  NotificationBloc({
    required this.notificationService,
    required this.remoteDataSource,
  }) : super(const NotificationInitial()) {
    on<InitializeNotifications>(_onInitializeNotifications);
    on<UpdateFcmToken>(_onUpdateFcmToken);
    on<DeleteFcmToken>(_onDeleteFcmToken);

    // Configurar callback para cuando se recibe un token
    notificationService.onTokenReceived = (token) {
      add(UpdateFcmToken(token));
    };
  }

  /// Handler para inicializar notificaciones
  Future<void> _onInitializeNotifications(
    InitializeNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationInitializing());
      _logger.i('🔧 Inicializando notificaciones...');

      // Inicializar el servicio de notificaciones
      await notificationService.initialize();

      // Obtener el token FCM
      final token = await notificationService.getToken();

      if (token != null) {
        _logger.i('✅ Token FCM obtenido: ${token.substring(0, 20)}...');
        emit(NotificationReady(fcmToken: token));

        // Enviar el token al backend automáticamente
        add(UpdateFcmToken(token));
      } else {
        _logger.w('⚠️ No se pudo obtener el token FCM');
        emit(const NotificationReady(fcmToken: null));
      }
    } catch (e) {
      _logger.e('❌ Error inicializando notificaciones', error: e);
      emit(NotificationError('Error inicializando notificaciones: $e'));
    }
  }

  /// Handler para actualizar el token FCM en el backend
  Future<void> _onUpdateFcmToken(
    UpdateFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationTokenUpdating());
      _logger.i('📤 Enviando token FCM al backend...');

      // Enviar token al backend
      await remoteDataSource.updateFcmToken(event.token);

      _logger.i('✅ Token FCM enviado al backend correctamente');
      emit(NotificationTokenUpdated(event.token));

      // Volver al estado ready
      emit(NotificationReady(fcmToken: event.token));
    } catch (e) {
      _logger.e('❌ Error enviando token FCM al backend', error: e);
      emit(NotificationError('Error actualizando token: $e'));

      // Volver al estado ready aunque haya fallado
      emit(NotificationReady(fcmToken: event.token));
    }
  }

  /// Handler para eliminar el token FCM del backend
  Future<void> _onDeleteFcmToken(
    DeleteFcmToken event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.i('🗑️ Eliminando token FCM del backend...');

      // Eliminar del backend
      await remoteDataSource.deleteFcmToken();

      // Eliminar del dispositivo
      await notificationService.deleteToken();

      _logger.i('✅ Token FCM eliminado correctamente');
      emit(const NotificationTokenDeleted());
    } catch (e) {
      _logger.e('❌ Error eliminando token FCM', error: e);
      emit(NotificationError('Error eliminando token: $e'));
    }
  }
}
