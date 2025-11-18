import 'package:equatable/equatable.dart';

/// Estados del BLoC de notificaciones
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Estado de inicialización
class NotificationInitializing extends NotificationState {
  const NotificationInitializing();
}

/// Estado cuando las notificaciones están listas
class NotificationReady extends NotificationState {
  final String? fcmToken;

  const NotificationReady({this.fcmToken});

  @override
  List<Object?> get props => [fcmToken];
}

/// Estado de actualización de token
class NotificationTokenUpdating extends NotificationState {
  const NotificationTokenUpdating();
}

/// Estado cuando el token se actualizó correctamente
class NotificationTokenUpdated extends NotificationState {
  final String token;

  const NotificationTokenUpdated(this.token);

  @override
  List<Object?> get props => [token];
}

/// Estado cuando el token se eliminó correctamente
class NotificationTokenDeleted extends NotificationState {
  const NotificationTokenDeleted();
}

/// Estado de error
class NotificationError extends NotificationState {
  final String message;

  const NotificationError(this.message);

  @override
  List<Object?> get props => [message];
}
