# Plan de Implementación - CliniDocs Mobile App

## Arquitectura Limpia (Clean Architecture)

Este documento define la implementación completa de la aplicación móvil CliniDocs en Flutter, utilizando Clean Architecture para garantizar escalabilidad, mantenibilidad y testabilidad.

### Estructura de Arquitectura

```
lib/
├── core/                          # Núcleo de la aplicación
│   ├── constants/                 # Constantes globales
│   ├── network/                   # Configuración de red
│   ├── theme/                     # Temas y estilos
│   ├── utils/                     # Utilidades
│   ├── widgets/                   # Widgets reutilizables
│   └── errors/                    # Manejo de errores
├── features/                      # Características/Módulos
│   ├── auth/                      # Autenticación
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── patients/
│   ├── clinical_records/
│   ├── documents/
│   ├── dashboard/
│   ├── notifications/
│   ├── reports/
│   ├── users/
│   └── settings/
└── config/
    ├── routes/
    └── dependency_injection/
```

---

## SPRINT 1: Fundamentos y Autenticación (2 semanas)

### Objetivos
- Configurar la base del proyecto con arquitectura limpia
- Implementar autenticación completa (login, logout, refresh token)
- Configurar navegación y manejo de estado
- Implementar almacenamiento local seguro

### 1.1 Setup Inicial del Proyecto

#### Dependencias (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter

  # Estado
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Networking
  dio: ^5.4.0
  retrofit: ^4.0.3
  json_annotation: ^4.8.1

  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2

  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2

  # Utils
  intl: ^0.18.1
  logger: ^2.0.2+1
  dartz: ^0.10.1

  # UI
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
  retrofit_generator: ^8.0.4
  json_serializable: ^6.7.1
  injectable_generator: ^2.4.1
  mockito: ^5.4.4
```

#### 1.2 Core - Configuración de Red

**lib/core/network/dio_client.dart**
```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  DioClient(this._secureStorage) : _dio = Dio() {
    _dio.options = BaseOptions(
      baseURL: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectionTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Agregar token de autenticación
          final token = await _secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Manejo de refresh token en error 401
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Reintentar request original
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Logger interceptor para desarrollo
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      await _secureStorage.write(key: 'access_token', value: newAccessToken);
      return true;
    } catch (e) {
      await _secureStorage.deleteAll();
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Dio get dio => _dio;
}
```

#### 1.3 Core - Manejo de Errores

**lib/core/errors/failures.dart**
```dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}
```

**lib/core/errors/exceptions.dart**
```dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);
}
```

#### 1.4 Feature Auth - Domain Layer

**lib/features/auth/domain/entities/user_entity.dart**
```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final TenantEntity tenant;
  final RoleEntity? role;
  final bool isActive;
  final bool isTenantOwner;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.tenant,
    this.role,
    required this.isActive,
    required this.isTenantOwner,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        fullName,
        tenant,
        role,
        isActive,
        isTenantOwner,
      ];
}

class TenantEntity extends Equatable {
  final String id;
  final String name;
  final String subdomain;
  final String status;

  const TenantEntity({
    required this.id,
    required this.name,
    required this.subdomain,
    required this.status,
  });

  @override
  List<Object> get props => [id, name, subdomain, status];
}

class RoleEntity extends Equatable {
  final String id;
  final String name;
  final String slug;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.slug,
  });

  @override
  List<Object> get props => [id, name, slug];
}
```

**lib/features/auth/domain/repositories/auth_repository.dart**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<Either<Failure, bool>> isLoggedIn();
}
```

**lib/features/auth/domain/usecases/login_usecase.dart**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}
```

**lib/features/auth/domain/usecases/logout_usecase.dart**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}
```

**lib/features/auth/domain/usecases/get_current_user_usecase.dart**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getCurrentUser();
  }
}
```

#### 1.5 Feature Auth - Data Layer

**lib/features/auth/data/models/user_model.dart**
```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String fullName,
    required TenantModel tenant,
    RoleModel? role,
    required bool isActive,
    required bool isTenantOwner,
  }) : super(
          id: id,
          email: email,
          firstName: firstName,
          lastName: lastName,
          fullName: fullName,
          tenant: tenant,
          role: role,
          isActive: isActive,
          isTenantOwner: isTenantOwner,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class TenantModel extends TenantEntity {
  const TenantModel({
    required String id,
    required String name,
    required String subdomain,
    required String status,
  }) : super(
          id: id,
          name: name,
          subdomain: subdomain,
          status: status,
        );

  factory TenantModel.fromJson(Map<String, dynamic> json) =>
      _$TenantModelFromJson(json);

  Map<String, dynamic> toJson() => _$TenantModelToJson(this);
}

@JsonSerializable()
class RoleModel extends RoleEntity {
  const RoleModel({
    required String id,
    required String name,
    required String slug,
  }) : super(
          id: id,
          name: name,
          slug: slug,
        );

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
```

**lib/features/auth/data/datasources/auth_remote_datasource.dart**
```dart
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio) = _AuthRemoteDataSource;

  @POST(ApiConstants.login)
  Future<LoginResponse> login(@Body() Map<String, dynamic> credentials);

  @POST(ApiConstants.logout)
  Future<void> logout();

  @GET(ApiConstants.currentUser)
  Future<UserModel> getCurrentUser();
}

class LoginResponse {
  final String access;
  final String refresh;
  final UserModel user;

  LoginResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
```

**lib/features/auth/data/datasources/auth_local_datasource.dart**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  });

  Future<void> cacheUser(UserModel user);

  Future<UserModel?> getCachedUser();

  Future<String?> getAccessToken();

  Future<String?> getRefreshToken();

  Future<void> clearCache();

  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  static const String cachedUserKey = 'CACHED_USER';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await secureStorage.write(key: accessTokenKey, value: accessToken);
      await secureStorage.write(key: refreshTokenKey, value: refreshToken);
    } catch (e) {
      throw CacheException('Error caching tokens');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await sharedPreferences.setString(cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException('Error caching user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString != null) {
        return UserModel.fromJson(jsonDecode(jsonString));
      }
      return null;
    } catch (e) {
      throw CacheException('Error getting cached user');
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: refreshTokenKey);
  }

  @override
  Future<void> clearCache() async {
    try {
      await secureStorage.deleteAll();
      await sharedPreferences.remove(cachedUserKey);
    } catch (e) {
      throw CacheException('Error clearing cache');
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}
```

**lib/features/auth/data/repositories/auth_repository_impl.dart**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.login({
        'email': email,
        'password': password,
      });

      await localDataSource.cacheTokens(
        accessToken: response.access,
        refreshToken: response.refresh,
      );

      await localDataSource.cacheUser(response.user);

      return Right(response.user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado al iniciar sesión'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearCache();
      return const Right(null);
    } catch (e) {
      await localDataSource.clearCache();
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }

      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.cacheUser(user);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(CacheFailure('Error obteniendo usuario'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLogged = await localDataSource.isLoggedIn();
      return Right(isLogged);
    } catch (e) {
      return const Right(false);
    }
  }
}
```

#### 1.6 Feature Auth - Presentation Layer (BLoC)

**lib/features/auth/presentation/bloc/auth_event.dart**
```dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class GetCurrentUserRequested extends AuthEvent {}
```

**lib/features/auth/presentation/bloc/auth_state.dart**
```dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
```

**lib/features/auth/presentation/bloc/auth_bloc.dart**
```dart
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
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<GetCurrentUserRequested>(_onGetCurrentUserRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await loginUseCase(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await logoutUseCase();

    result.fold(
      (failure) => emit(Unauthenticated()),
      (_) => emit(Unauthenticated()),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onGetCurrentUserRequested(
    GetCurrentUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await getCurrentUserUseCase();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }
}
```

#### 1.7 Feature Auth - UI Pages

**lib/features/auth/presentation/pages/login_page.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            LoginRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    const Icon(
                      Icons.medical_services,
                      size: 80,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      'CliniDocs',
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sistema de Gestión Clínica',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su email';
                        }
                        if (!value.contains('@')) {
                          return 'Ingrese un email válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: state is AuthLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: state is AuthLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Iniciar Sesión'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
```

**lib/features/auth/presentation/pages/splash_page.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuthStatus());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        } else if (state is Unauthenticated) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.medical_services,
                size: 100,
                color: Colors.blue,
              ),
              SizedBox(height: 24),
              Text(
                'CliniDocs',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 1.8 Dependency Injection

**lib/config/dependency_injection/injection_container.dart**
```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/dio_client.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // Core
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => sl<DioClient>().dio);

  // Auth Feature
  _initAuth();
}

void _initAuth() {
  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );
}
```

### 1.9 Routing

**lib/config/routes/app_routes.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/dependency_injection/injection_container.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const SplashPage(),
          ),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => sl<AuthBloc>(),
            child: const LoginPage(),
          ),
        );

      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Dashboard - Sprint 2'),
            ),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Ruta no encontrada'),
            ),
          ),
        );
    }
  }
}
```

### 1.10 Main App

**lib/main.dart**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/dependency_injection/injection_container.dart' as di;
import 'config/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CliniDocs',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

**lib/core/theme/app_theme.dart**
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    textTheme: GoogleFonts.interTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
    ),
  );
}
```

### Entregables Sprint 1
- ✅ Login funcional con JWT
- ✅ Refresh token automático
- ✅ Persistencia de sesión
- ✅ Navegación básica
- ✅ Manejo de errores
- ✅ Arquitectura limpia base

---

## SPRINT 2: Dashboard y Pacientes (2 semanas)

### Objetivos
- Implementar dashboard principal con estadísticas
- Módulo completo de pacientes (CRUD)
- Búsqueda y paginación
- Widgets reutilizables

### 2.1 Dashboard Feature

**lib/features/dashboard/domain/entities/dashboard_stats_entity.dart**
```dart
import 'package:equatable/equatable.dart';

class DashboardStatsEntity extends Equatable {
  final int totalPatients;
  final int totalDocuments;
  final int totalClinicalRecords;
  final int activeToday;
  final int averageMonthly;
  final List<RecentDocumentEntity> recentDocuments;
  final List<RecentActivityEntity> recentActivity;

  const DashboardStatsEntity({
    required this.totalPatients,
    required this.totalDocuments,
    required this.totalClinicalRecords,
    required this.activeToday,
    required this.averageMonthly,
    required this.recentDocuments,
    required this.recentActivity,
  });

  @override
  List<Object?> get props => [
        totalPatients,
        totalDocuments,
        totalClinicalRecords,
        activeToday,
        averageMonthly,
        recentDocuments,
        recentActivity,
      ];
}

class RecentDocumentEntity extends Equatable {
  final String id;
  final String title;
  final String patientName;
  final DateTime createdAt;

  const RecentDocumentEntity({
    required this.id,
    required this.title,
    required this.patientName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, patientName, createdAt];
}

class RecentActivityEntity extends Equatable {
  final String id;
  final String action;
  final DateTime timestamp;
  final String userName;

  const RecentActivityEntity({
    required this.id,
    required this.action,
    required this.timestamp,
    required this.userName,
  });

  @override
  List<Object?> get props => [id, action, timestamp, userName];
}
```

### 2.2 Patients Feature - Domain Layer

**lib/features/patients/domain/entities/patient_entity.dart**
```dart
import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String identificationNumber;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender;
  final String bloodType;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;
  final String? allergies;
  final String? medicalHistory;
  final String? currentMedications;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientEntity({
    required this.id,
    required this.identificationNumber,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.bloodType,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
    this.allergies,
    this.medicalHistory,
    this.currentMedications,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        id,
        identificationNumber,
        firstName,
        lastName,
        fullName,
        dateOfBirth,
        gender,
        bloodType,
        email,
        phone,
        status,
        createdAt,
        updatedAt,
      ];
}
```

**lib/features/patients/domain/repositories/patients_repository.dart**
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../entities/patient_entity.dart';

abstract class PatientsRepository {
  Future<Either<Failure, PaginatedResponse<PatientEntity>>> getPatients({
    int? page,
    int? pageSize,
    String? search,
    String? ordering,
  });

  Future<Either<Failure, PatientEntity>> getPatientById(String id);

  Future<Either<Failure, PatientEntity>> createPatient(PatientEntity patient);

  Future<Either<Failure, PatientEntity>> updatePatient(
    String id,
    PatientEntity patient,
  );

  Future<Either<Failure, void>> deletePatient(String id);
}
```

### 2.3 Core Widgets Reutilizables

**lib/core/widgets/loading_widget.dart**
```dart
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
```

**lib/core/widgets/error_widget.dart**
```dart
import 'package:flutter/material.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

### Entregables Sprint 2
- ✅ Dashboard con estadísticas en tiempo real
- ✅ CRUD completo de pacientes
- ✅ Búsqueda y filtrado
- ✅ Paginación
- ✅ Widgets reutilizables

---

## SPRINT 3: Historias Clínicas y Documentos (2 semanas)

### Objetivos
- Gestión de historias clínicas
- Subida y gestión de documentos
- Visor de documentos (PDF, imágenes)
- Timeline de eventos

### Entregables Sprint 3
- ✅ CRUD de historias clínicas
- ✅ Subida de documentos con cámara/galería
- ✅ Visor de documentos
- ✅ Timeline de eventos
- ✅ Firma digital de documentos

---

## SPRINT 4: Notificaciones y Reportes (2 semanas)

### Objetivos
- Push notifications
- Notificaciones en tiempo real
- Generación de reportes
- Descarga de reportes en PDF

### Entregables Sprint 4
- ✅ Push notifications configuradas
- ✅ Centro de notificaciones
- ✅ Preferencias de notificaciones
- ✅ Generación de reportes
- ✅ Descarga y compartir reportes

---

## SPRINT 5: Configuración y Permisos (1 semana)

### Objetivos
- Gestión de usuarios
- Roles y permisos
- Configuración de la app
- Preferencias de usuario

### Entregables Sprint 5
- ✅ Gestión de usuarios
- ✅ Sistema de roles y permisos
- ✅ Configuración de perfil
- ✅ Preferencias de la app

---

## SPRINT 6: Analytics y Optimización (1 semana)

### Objetivos
- Dashboard de analytics
- Gráficos y estadísticas
- Optimización de rendimiento
- Testing completo

### Entregables Sprint 6
- ✅ Dashboard de analytics con gráficos
- ✅ Estadísticas avanzadas
- ✅ Optimización de rendimiento
- ✅ Testing unitario y de integración
- ✅ Documentación completa

---

## Comandos Útiles

### Generación de Código
```bash
# Generar modelos JSON
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode para desarrollo
flutter pub run build_runner watch

# Clean
flutter clean
flutter pub get
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/features/auth/auth_bloc_test.dart

# Coverage
flutter test --coverage
```

### Build
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## Conexión con Backend

### Variables de Entorno

**lib/config/environment/environment.dart**
```dart
class Environment {
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://localhost:8000/api',
  );

  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );
}
```

Para ejecutar con diferentes entornos:
```bash
# Development
flutter run --dart-define=API_URL=http://localhost:8000/api

# Production
flutter run --dart-define=API_URL=https://api.clinidocs.com/api --dart-define=DEVELOPMENT=false
```

---

## Notas de Implementación

1. **Arquitectura Limpia**: Cada feature sigue la estructura Domain → Data → Presentation
2. **BLoC Pattern**: Para manejo de estado reactivo
3. **Dependency Injection**: GetIt para inyección de dependencias
4. **Testing**: Tests unitarios para cada capa
5. **Seguridad**: Tokens en secure storage, validación de datos
6. **Optimización**: Lazy loading, paginación, caché

---

## Resumen de Sprints

| Sprint | Duración | Módulos |
|--------|----------|---------|
| Sprint 1 | 2 semanas | Auth + Setup |
| Sprint 2 | 2 semanas | Dashboard + Patients |
| Sprint 3 | 2 semanas | Clinical Records + Documents |
| Sprint 4 | 2 semanas | Notifications + Reports |
| Sprint 5 | 1 semana | Settings + Permissions |
| Sprint 6 | 1 semana | Analytics + Testing |
| **Total** | **10 semanas** | **App Completa** |

---

## Próximos Pasos

Después de completar el Sprint 1:
1. Ejecutar `flutter pub run build_runner build`
2. Configurar variables de entorno
3. Testear login con backend real
4. Proceder con Sprint 2
