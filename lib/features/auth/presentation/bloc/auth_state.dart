import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado con usuario
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// Estado no autenticado
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Estado de error
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
