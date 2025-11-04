import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para verificar si hay sesión activa
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Evento para iniciar sesión
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Evento para cerrar sesión
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

/// Evento para refrescar el usuario
class AuthUserRefreshRequested extends AuthEvent {
  const AuthUserRefreshRequested();
}
