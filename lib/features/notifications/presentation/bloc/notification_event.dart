import 'package:equatable/equatable.dart';

/// Eventos del BLoC de notificaciones
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar el servicio de notificaciones
class InitializeNotifications extends NotificationEvent {
  const InitializeNotifications();
}

/// Evento para enviar el token FCM al backend
class UpdateFcmToken extends NotificationEvent {
  final String token;

  const UpdateFcmToken(this.token);

  @override
  List<Object?> get props => [token];
}

/// Evento para eliminar el token FCM del backend
class DeleteFcmToken extends NotificationEvent {
  const DeleteFcmToken();
}
