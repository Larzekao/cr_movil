import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthUserRefreshRequested>(_onAuthUserRefreshRequested);
  }

  /// Verifica si hay una sesión activa al iniciar la app
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Procesa el login
  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  /// Procesa el logout
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  /// Refresca los datos del usuario
  Future<void> _onAuthUserRefreshRequested(
    AuthUserRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
