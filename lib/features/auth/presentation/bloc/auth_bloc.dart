import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../notifications/data/datasources/notification_remote_datasource.dart';
import '../../../../core/services/notification_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final NotificationRemoteDataSource? notificationDataSource;
  final NotificationService? notificationService;
  final Logger _logger = Logger();

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
    this.notificationDataSource,
    this.notificationService,
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

    result.fold((failure) => emit(AuthError(failure.message)), (user) {
      // Login exitoso - enviar token FCM al backend
      _sendFcmTokenAfterLogin();
      emit(AuthAuthenticated(user));
    });
  }

  /// Envía el token FCM al backend después del login
  Future<void> _sendFcmTokenAfterLogin() async {
    try {
      _logger.i('📤 Enviando token FCM después del login...');

      if (notificationService == null) {
        _logger.e('❌ NotificationService es null');
        return;
      }

      // Intentar obtener token con retry (máximo 3 intentos)
      String? token;
      for (int i = 0; i < 3; i++) {
        _logger.i('🔍 Intento ${i + 1}/3: Obteniendo token FCM...');
        token = await notificationService!.getToken();

        if (token != null && token.isNotEmpty) {
          _logger.i('✅ Token FCM obtenido: ${token.substring(0, 20)}...');
          break;
        }

        // Esperar 1 segundo antes del siguiente intento
        if (i < 2) {
          _logger.w('⚠️ Token null, esperando 1 segundo...');
          await Future.delayed(const Duration(seconds: 1));
        }
      }

      if (token == null || token.isEmpty) {
        _logger.e('❌ No se pudo obtener token FCM después de 3 intentos');
        return;
      }

      // Enviar token al backend
      if (notificationDataSource == null) {
        _logger.e('❌ notificationDataSource es null');
        return;
      }

      await notificationDataSource!.updateFcmToken(token);
      _logger.i('✅ Token FCM enviado al backend correctamente');
    } catch (e, stackTrace) {
      _logger.e('❌ Error enviando token FCM: $e');
      _logger.d('StackTrace: $stackTrace');
      // No fallar el login si hay problema con el token
    }
  }

  /// Procesa el logout
  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // Eliminar token FCM antes del logout
    try {
      if (notificationDataSource != null && notificationService != null) {
        await notificationDataSource!.deleteFcmToken();
        await notificationService!.deleteToken();
      }
    } catch (e) {
      // Continuar con logout aunque falle la eliminación del token
      print('⚠️ Error eliminando token FCM en logout: $e');
    }

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
