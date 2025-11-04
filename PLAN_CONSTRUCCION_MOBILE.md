# 📱 PLAN DE CONSTRUCCIÓN - APP MÓVIL CLINIDOCS (FLUTTER)

## 📋 INFORMACIÓN GENERAL DEL PROYECTO

**Proyecto:** CliniDocs Mobile - Sistema de Gestión de Historias Clínicas  
**Plataforma:** Android (Flutter)  
**Arquitectura:** Clean Architecture + BLoC Pattern  
**Backend:** Django REST Framework con RBAC y Multi-tenancy  
**Duración Total:** 7 días (Sprint 3 completo)  
**Fecha de Inicio:** Día 11 del proyecto general  
**Fecha de Finalización:** Día 12 del proyecto general + 5 días adicionales  
**Equipo:** 1-2 desarrolladores móviles  

---

## 🎯 OBJETIVOS DE LA APP MÓVIL

### Objetivo Principal
Desarrollar una aplicación móvil nativa para Android que permita a médicos y personal autorizado gestionar historias clínicas y documentos desde dispositivos móviles, manteniendo el mismo nivel de seguridad y funcionalidad que la versión web.

### Objetivos Específicos

1. **Acceso Móvil Completo:** Consultar y gestionar pacientes, historias clínicas y documentos
2. **Funcionalidad Offline:** Caché de datos críticos para consulta sin conexión
3. **Escaneo de Documentos:** Captura y subida de documentos médicos desde la cámara
4. **Notificaciones Push:** Alertas en tiempo real de eventos importantes
5. **Sincronización:** Sincronización automática con el backend cuando hay conexión
6. **Seguridad:** Autenticación biométrica y sesiones seguras

---

## 🏗️ ARQUITECTURA DE LA APP MÓVIL

### Stack Tecnológico

```
Flutter 3.16+
├── Dart 3.2+                      (Lenguaje de programación)
├── BLoC 8.1+                      (Gestión de estado)
├── GetIt 7.6+                     (Inyección de dependencias)
├── Dio 5.4+                       (HTTP Client)
├── Hive 2.2+                      (Base de datos local)
├── Flutter Secure Storage 9.0+    (Almacenamiento seguro)
├── Image Picker 1.0+              (Captura de imágenes)
├── Firebase Cloud Messaging       (Notificaciones Push)
├── Local Auth                     (Autenticación biométrica)
└── Flutter Dotenv                 (Variables de entorno)
```

### Arquitectura Clean Architecture

```
lib/
├── main.dart                      # Punto de entrada
│
├── core/                          # Núcleo de la aplicación
│   ├── constants/                 # Constantes globales
│   │   ├── api_constants.dart
│   │   ├── storage_constants.dart
│   │   └── app_constants.dart
│   │
│   ├── errors/                    # Manejo de errores
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   │
│   ├── network/                   # Cliente HTTP
│   │   ├── dio_client.dart
│   │   ├── api_interceptor.dart
│   │   └── network_info.dart
│   │
│   ├── theme/                     # Tema de la app
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   └── app_text_styles.dart
│   │
│   ├── utils/                     # Utilidades
│   │   ├── date_formatter.dart
│   │   ├── validators.dart
│   │   └── helpers.dart
│   │
│   └── widgets/                   # Widgets reutilizables
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       ├── loading_widget.dart
│       └── error_widget.dart
│
├── config/                        # Configuración
│   ├── routes/                    # Rutas de navegación
│   │   └── app_routes.dart
│   │
│   ├── dependency_injection/      # DI
│   │   └── injection_container.dart
│   │
│   └── environment/               # Variables de entorno
│       └── environment.dart
│
└── features/                      # Módulos por funcionalidad
    ├── auth/                      # Autenticación
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── auth_local_datasource.dart
    │   │   │   └── auth_remote_datasource.dart
    │   │   ├── models/
    │   │   │   ├── user_model.dart
    │   │   │   └── login_request_model.dart
    │   │   └── repositories/
    │   │       └── auth_repository_impl.dart
    │   │
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── user_entity.dart
    │   │   ├── repositories/
    │   │   │   └── auth_repository.dart
    │   │   └── usecases/
    │   │       ├── login_usecase.dart
    │   │       ├── logout_usecase.dart
    │   │       └── get_current_user_usecase.dart
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── auth_bloc.dart
    │       │   ├── auth_event.dart
    │       │   └── auth_state.dart
    │       ├── pages/
    │       │   ├── login_page.dart
    │       │   └── splash_page.dart
    │       └── widgets/
    │           └── login_form.dart
    │
    ├── patients/                  # Gestión de pacientes
    │   ├── data/
    │   │   ├── datasources/
    │   │   │   ├── patient_local_datasource.dart
    │   │   │   └── patient_remote_datasource.dart
    │   │   ├── models/
    │   │   │   └── patient_model.dart
    │   │   └── repositories/
    │   │       └── patient_repository_impl.dart
    │   │
    │   ├── domain/
    │   │   ├── entities/
    │   │   │   └── patient_entity.dart
    │   │   ├── repositories/
    │   │   │   └── patient_repository.dart
    │   │   └── usecases/
    │   │       ├── get_patients_usecase.dart
    │   │       ├── get_patient_detail_usecase.dart
    │   │       └── create_patient_usecase.dart
    │   │
    │   └── presentation/
    │       ├── bloc/
    │       │   ├── patient_bloc.dart
    │       │   ├── patient_event.dart
    │       │   └── patient_state.dart
    │       ├── pages/
    │       │   ├── patients_list_page.dart
    │       │   ├── patient_detail_page.dart
    │       │   └── create_patient_page.dart
    │       └── widgets/
    │           ├── patient_card.dart
    │           └── patient_search_bar.dart
    │
    ├── clinical_records/          # Historias clínicas
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── documents/                 # Documentos clínicos
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    ├── camera/                    # Captura de documentos
    │   ├── data/
    │   ├── domain/
    │   └── presentation/
    │
    └── settings/                  # Configuración
        ├── data/
        ├── domain/
        └── presentation/
```

---

## 📅 PLANIFICACIÓN POR SPRINTS

### SPRINT 0: CONFIGURACIÓN INICIAL (1 DÍA)

**Duración:** Día 1  
**Objetivo:** Configurar el proyecto Flutter y la estructura base

#### Tareas del Sprint 0

##### 0.1 Configuración del Proyecto (4 horas)

**Tareas:**
- [ ] Crear proyecto Flutter: `flutter create clinidocs_mobile`
- [ ] Configurar `pubspec.yaml` con todas las dependencias
- [ ] Configurar Android manifest para permisos (cámara, almacenamiento, internet)
- [ ] Configurar Firebase para notificaciones push
- [ ] Crear estructura de carpetas según Clean Architecture
- [ ] Configurar variables de entorno (`.env` para URLs del backend)

**Dependencias en pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  
  # Dependency Injection
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # Network
  dio: ^5.4.0
  connectivity_plus: ^5.0.2
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # UI & Navigation
  go_router: ^12.1.3
  cached_network_image: ^3.3.0
  flutter_svg: ^2.0.9
  intl: ^0.18.1
  
  # Camera & Image
  image_picker: ^1.0.5
  camera: ^0.10.5
  permission_handler: ^11.1.0
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  
  # Auth
  local_auth: ^2.1.7
  
  # Utils
  flutter_dotenv: ^5.1.0
  logger: ^2.0.2
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.7
  hive_generator: ^2.0.1
  injectable_generator: ^2.4.1
  flutter_lints: ^3.0.1
```

**Archivos a crear:**
- `lib/main.dart`
- `lib/config/environment/environment.dart`
- `lib/config/dependency_injection/injection_container.dart`
- `lib/core/constants/api_constants.dart`
- `.env` (variables de entorno)

##### 0.2 Configuración de Inyección de Dependencias (2 horas)

**Archivo:** `lib/config/dependency_injection/injection_container.dart`

```dart
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  
  // Network
  sl.registerLazySingleton(() => DioClient(sl()));
  sl.registerLazySingleton(() => NetworkInfo());
  
  // Auth
  _initAuth();
  
  // Patients
  _initPatients();
  
  // Clinical Records
  _initClinicalRecords();
  
  // Documents
  _initDocuments();
}

void _initAuth() {
  // DataSources
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl())
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl())
  );
  
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    )
  );
  
  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  
  // BLoC
  sl.registerFactory(() => AuthBloc(
    loginUseCase: sl(),
    logoutUseCase: sl(),
    getCurrentUserUseCase: sl(),
  ));
}

// Similar para otros módulos...
```

##### 0.3 Cliente HTTP con Interceptores (2 horas)

**Archivo:** `lib/core/network/dio_client.dart`

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  DioClient(this._dio, this._storage) {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Agregar token JWT
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Agregar tenant ID
    final tenantId = await _storage.read(key: 'tenant_id');
    if (tenantId != null) {
      options.headers['X-Tenant-ID'] = tenantId;
    }

    print('REQUEST[${options.method}] => PATH: ${options.path}');
    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
    handler.next(response);
  }

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    print('ERROR[${error.response?.statusCode}] => MESSAGE: ${error.message}');
    
    // Refresh token si es 401
    if (error.response?.statusCode == 401) {
      final refreshed = await _refreshToken();
      if (refreshed) {
        // Reintentar request
        return handler.resolve(await _retry(error.requestOptions));
      }
    }
    
    handler.next(error);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '/api/auth/token/refresh/',
        data: {'refresh': refreshToken},
      );

      await _storage.write(
        key: 'access_token',
        value: response.data['access'],
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  // Métodos HTTP
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
```

**Entregables del Sprint 0:**
- [x] Proyecto Flutter configurado y funcionando
- [x] Estructura de carpetas Clean Architecture implementada
- [x] Sistema de inyección de dependencias configurado
- [x] Cliente HTTP con interceptores y refresh token
- [x] Configuración de Firebase para notificaciones
- [x] Variables de entorno configuradas

---

### SPRINT 1: MÓDULO DE AUTENTICACIÓN (1.5 DÍAS)

**Duración:** Día 2 - Mitad del Día 3  
**Objetivo:** Implementar autenticación completa con JWT y biometría

#### Tareas del Sprint 1

##### 1.1 Capa de Dominio - Auth (2 horas)

**Entidad:** `lib/features/auth/domain/entities/user_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImage;
  final RoleEntity role;
  final String tenantId;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profileImage,
    required this.role,
    required this.tenantId,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phone,
        profileImage,
        role,
        tenantId,
        createdAt,
      ];
}

class RoleEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final List<String> permissions;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, code, permissions];
}
```

**Repositorio:** `lib/features/auth/domain/repositories/auth_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> enableBiometricAuth();
  Future<Either<Failure, bool>> authenticateWithBiometric();
}
```

**Casos de Uso:**

`lib/features/auth/domain/usecases/login_usecase.dart`:
```dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String email, String password) {
    return repository.login(email, password);
  }
}
```

##### 1.2 Capa de Datos - Auth (3 horas)

**Modelo:** `lib/features/auth/data/models/user_model.dart`

```dart
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.profileImage,
    required super.role,
    required super.tenantId,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      profileImage: json['profile_image'],
      role: RoleModel.fromJson(json['role']),
      tenantId: json['tenant_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_image': profileImage,
      'role': (role as RoleModel).toJson(),
      'tenant_id': tenantId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    required super.code,
    required super.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'permissions': permissions,
    };
  }
}
```

**DataSource Remoto:** `lib/features/auth/data/datasources/auth_remote_datasource.dart`

```dart
import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await client.post(
        '/api/auth/login/',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ServerException('Error en el login');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthenticationException('Credenciales inválidas');
      }
      throw ServerException(e.message ?? 'Error desconocido');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await client.get('/api/auth/me/');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw ServerException('Error al obtener usuario');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Error desconocido');
    }
  }
}
```

**DataSource Local:** `lib/features/auth/data/datasources/auth_local_datasource.dart`

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearCache();
  Future<void> saveBiometricEnabled(bool enabled);
  Future<bool> isBiometricEnabled();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final Box userBox;

  AuthLocalDataSourceImpl(this.secureStorage, this.userBox);

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await userBox.put('current_user', user.toJson());
    } catch (e) {
      throw CacheException('Error al guardar usuario');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final userData = userBox.get('current_user');
      if (userData == null) {
        throw CacheException('No hay usuario en caché');
      }
      return UserModel.fromJson(Map<String, dynamic>.from(userData));
    } catch (e) {
      throw CacheException('Error al obtener usuario');
    }
  }

  @override
  Future<void> cacheTokens(String accessToken, String refreshToken) async {
    await secureStorage.write(key: 'access_token', value: accessToken);
    await secureStorage.write(key: 'refresh_token', value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return await secureStorage.read(key: 'access_token');
  }

  @override
  Future<String?> getRefreshToken() async {
    return await secureStorage.read(key: 'refresh_token');
  }

  @override
  Future<void> clearCache() async {
    await secureStorage.deleteAll();
    await userBox.clear();
  }

  @override
  Future<void> saveBiometricEnabled(bool enabled) async {
    await secureStorage.write(
      key: 'biometric_enabled',
      value: enabled.toString(),
    );
  }

  @override
  Future<bool> isBiometricEnabled() async {
    final value = await secureStorage.read(key: 'biometric_enabled');
    return value == 'true';
  }
}
```

##### 1.3 Capa de Presentación - Auth (3 horas)

**BLoC:** `lib/features/auth/presentation/bloc/auth_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class BiometricLoginRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserEntity user;

  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
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
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await loginUseCase(event.email, event.password);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await logoutUseCase();
    emit(Unauthenticated());
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

  Future<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Implementar lógica de autenticación biométrica
    emit(AuthLoading());
    // ...
  }
}
```

**Página de Login:** `lib/features/auth/presentation/pages/login_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
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
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/logo.png',
                      height: 120,
                    ),
                    const SizedBox(height: 48),
                    
                    // Título
                    Text(
                      'CliniDocs',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Gestión de Historias Clínicas',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 48),
                    
                    // Email
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
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        prefixIcon: const Icon(Icons.lock),
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
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Botón de Login
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<AuthBloc>().add(
                                        LoginRequested(
                                          _emailController.text,
                                          _passwordController.text,
                                        ),
                                      );
                                }
                              },
                        child: state is AuthLoading
                            ? const CircularProgressIndicator()
                            : const Text('Iniciar Sesión'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botón de Login Biométrico
                    TextButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(BiometricLoginRequested());
                      },
                      icon: const Icon(Icons.fingerprint),
                      label: const Text('Login con Huella'),
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
```

**Entregables del Sprint 1:**
- [x] Módulo de autenticación completo (dominio, datos, presentación)
- [x] Login con email y contraseña
- [x] Autenticación con JWT y refresh token automático
- [x] Autenticación biométrica (huella digital)
- [x] Persistencia de sesión
- [x] Manejo de estados con BLoC
- [x] Validación de formularios
- [x] Manejo de errores

---

### SPRINT 2: MÓDULO DE PACIENTES (1.5 DÍAS)

**Duración:** Mitad del Día 3 - Día 4  
**Objetivo:** Implementar gestión completa de pacientes con búsqueda y caché

#### Tareas del Sprint 2

##### 2.1 Capa de Dominio - Patients (1.5 horas)

**Entidad:** `lib/features/patients/domain/entities/patient_entity.dart`

```dart
import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String documentNumber;
  final String? documentType;
  final DateTime birthDate;
  final String gender;
  final String? email;
  final String? phone;
  final String? address;
  final String? bloodType;
  final List<String>? allergies;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? photoUrl;
  final String tenantId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PatientEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    this.documentType,
    required this.birthDate,
    required this.gender,
    this.email,
    this.phone,
    this.address,
    this.bloodType,
    this.allergies,
    this.emergencyContact,
    this.emergencyPhone,
    this.photoUrl,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        documentNumber,
        birthDate,
        gender,
        tenantId,
      ];
}
```

**Casos de Uso:**

```dart
// get_patients_usecase.dart
class GetPatientsUseCase {
  final PatientRepository repository;

  GetPatientsUseCase(this.repository);

  Future<Either<Failure, List<PatientEntity>>> call({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) {
    return repository.getPatients(
      search: search,
      page: page,
      pageSize: pageSize,
    );
  }
}

// get_patient_detail_usecase.dart
class GetPatientDetailUseCase {
  final PatientRepository repository;

  GetPatientDetailUseCase(this.repository);

  Future<Either<Failure, PatientEntity>> call(String patientId) {
    return repository.getPatientDetail(patientId);
  }
}

// create_patient_usecase.dart
class CreatePatientUseCase {
  final PatientRepository repository;

  CreatePatientUseCase(this.repository);

  Future<Either<Failure, PatientEntity>> call(PatientEntity patient) {
    return repository.createPatient(patient);
  }
}
```

##### 2.2 Capa de Datos - Patients (2 horas)

**Modelo:** `lib/features/patients/data/models/patient_model.dart`

```dart
import 'package:hive/hive.dart';
import '../../domain/entities/patient_entity.dart';

part 'patient_model.g.dart'; // Generado por build_runner

@HiveType(typeId: 1)
class PatientModel extends PatientEntity {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String firstName;

  @HiveField(2)
  final String lastName;

  @HiveField(3)
  final String documentNumber;

  @HiveField(4)
  final String? documentType;

  @HiveField(5)
  final DateTime birthDate;

  @HiveField(6)
  final String gender;

  @HiveField(7)
  final String? email;

  @HiveField(8)
  final String? phone;

  @HiveField(9)
  final String? address;

  @HiveField(10)
  final String? bloodType;

  @HiveField(11)
  final List<String>? allergies;

  @HiveField(12)
  final String? emergencyContact;

  @HiveField(13)
  final String? emergencyPhone;

  @HiveField(14)
  final String? photoUrl;

  @HiveField(15)
  final String tenantId;

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  final DateTime updatedAt;

  const PatientModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.documentNumber,
    this.documentType,
    required this.birthDate,
    required this.gender,
    this.email,
    this.phone,
    this.address,
    this.bloodType,
    this.allergies,
    this.emergencyContact,
    this.emergencyPhone,
    this.photoUrl,
    required this.tenantId,
    required this.createdAt,
    required this.updatedAt,
  }) : super(
          id: id,
          firstName: firstName,
          lastName: lastName,
          documentNumber: documentNumber,
          documentType: documentType,
          birthDate: birthDate,
          gender: gender,
          email: email,
          phone: phone,
          address: address,
          bloodType: bloodType,
          allergies: allergies,
          emergencyContact: emergencyContact,
          emergencyPhone: emergencyPhone,
          photoUrl: photoUrl,
          tenantId: tenantId,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      documentNumber: json['document_number'],
      documentType: json['document_type'],
      birthDate: DateTime.parse(json['birth_date']),
      gender: json['gender'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      bloodType: json['blood_type'],
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      photoUrl: json['photo'],
      tenantId: json['tenant'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'document_number': documentNumber,
      'document_type': documentType,
      'birth_date': birthDate.toIso8601String(),
      'gender': gender,
      'email': email,
      'phone': phone,
      'address': address,
      'blood_type': bloodType,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'photo': photoUrl,
      'tenant': tenantId,
    };
  }
}
```

**DataSource Remoto:** `lib/features/patients/data/datasources/patient_remote_datasource.dart`

```dart
import '../../../../core/network/dio_client.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/patient_model.dart';

abstract class PatientRemoteDataSource {
  Future<List<PatientModel>> getPatients({
    String? search,
    int page = 1,
    int pageSize = 20,
  });
  Future<PatientModel> getPatientDetail(String patientId);
  Future<PatientModel> createPatient(PatientModel patient);
  Future<PatientModel> updatePatient(String patientId, PatientModel patient);
  Future<void> deletePatient(String patientId);
}

class PatientRemoteDataSourceImpl implements PatientRemoteDataSource {
  final DioClient client;

  PatientRemoteDataSourceImpl(this.client);

  @override
  Future<List<PatientModel>> getPatients({
    String? search,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParameters = {
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
      };

      final response = await client.get(
        '/api/patients/',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data['results'];
        return results.map((json) => PatientModel.fromJson(json)).toList();
      } else {
        throw ServerException('Error al obtener pacientes');
      }
    } catch (e) {
      throw ServerException('Error al obtener pacientes: $e');
    }
  }

  @override
  Future<PatientModel> getPatientDetail(String patientId) async {
    try {
      final response = await client.get('/api/patients/$patientId/');

      if (response.statusCode == 200) {
        return PatientModel.fromJson(response.data);
      } else {
        throw ServerException('Error al obtener detalle del paciente');
      }
    } catch (e) {
      throw ServerException('Error al obtener detalle del paciente: $e');
    }
  }

  @override
  Future<PatientModel> createPatient(PatientModel patient) async {
    try {
      final response = await client.post(
        '/api/patients/',
        data: patient.toJson(),
      );

      if (response.statusCode == 201) {
        return PatientModel.fromJson(response.data);
      } else {
        throw ServerException('Error al crear paciente');
      }
    } catch (e) {
      throw ServerException('Error al crear paciente: $e');
    }
  }

  @override
  Future<PatientModel> updatePatient(
    String patientId,
    PatientModel patient,
  ) async {
    try {
      final response = await client.put(
        '/api/patients/$patientId/',
        data: patient.toJson(),
      );

      if (response.statusCode == 200) {
        return PatientModel.fromJson(response.data);
      } else {
        throw ServerException('Error al actualizar paciente');
      }
    } catch (e) {
      throw ServerException('Error al actualizar paciente: $e');
    }
  }

  @override
  Future<void> deletePatient(String patientId) async {
    try {
      final response = await client.delete('/api/patients/$patientId/');

      if (response.statusCode != 204) {
        throw ServerException('Error al eliminar paciente');
      }
    } catch (e) {
      throw ServerException('Error al eliminar paciente: $e');
    }
  }
}
```

**DataSource Local:** `lib/features/patients/data/datasources/patient_local_datasource.dart`

```dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/patient_model.dart';

abstract class PatientLocalDataSource {
  Future<void> cachePatients(List<PatientModel> patients);
  Future<List<PatientModel>> getCachedPatients();
  Future<void> cachePatient(PatientModel patient);
  Future<PatientModel> getCachedPatient(String patientId);
  Future<void> clearCache();
}

class PatientLocalDataSourceImpl implements PatientLocalDataSource {
  final Box<PatientModel> patientBox;

  PatientLocalDataSourceImpl(this.patientBox);

  @override
  Future<void> cachePatients(List<PatientModel> patients) async {
    try {
      await patientBox.clear();
      for (var patient in patients) {
        await patientBox.put(patient.id, patient);
      }
    } catch (e) {
      throw CacheException('Error al guardar pacientes en caché');
    }
  }

  @override
  Future<List<PatientModel>> getCachedPatients() async {
    try {
      return patientBox.values.toList();
    } catch (e) {
      throw CacheException('Error al obtener pacientes del caché');
    }
  }

  @override
  Future<void> cachePatient(PatientModel patient) async {
    try {
      await patientBox.put(patient.id, patient);
    } catch (e) {
      throw CacheException('Error al guardar paciente en caché');
    }
  }

  @override
  Future<PatientModel> getCachedPatient(String patientId) async {
    try {
      final patient = patientBox.get(patientId);
      if (patient == null) {
        throw CacheException('Paciente no encontrado en caché');
      }
      return patient;
    } catch (e) {
      throw CacheException('Error al obtener paciente del caché');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await patientBox.clear();
    } catch (e) {
      throw CacheException('Error al limpiar caché de pacientes');
    }
  }
}
```

##### 2.3 Capa de Presentación - Patients (4 horas)

**BLoC:** `lib/features/patients/presentation/bloc/patient_bloc.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_entity.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/get_patient_detail_usecase.dart';
import '../../domain/usecases/create_patient_usecase.dart';

// Events
abstract class PatientEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetPatientsRequested extends PatientEvent {
  final String? search;
  final int page;
  final bool isRefresh;

  GetPatientsRequested({
    this.search,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [search, page, isRefresh];
}

class GetPatientDetailRequested extends PatientEvent {
  final String patientId;

  GetPatientDetailRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class CreatePatientRequested extends PatientEvent {
  final PatientEntity patient;

  CreatePatientRequested(this.patient);

  @override
  List<Object?> get props => [patient];
}

class SearchPatientsRequested extends PatientEvent {
  final String search;

  SearchPatientsRequested(this.search);

  @override
  List<Object?> get props => [search];
}

// States
abstract class PatientState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PatientInitial extends PatientState {}

class PatientLoading extends PatientState {}

class PatientsLoaded extends PatientState {
  final List<PatientEntity> patients;
  final bool hasMore;
  final int currentPage;

  PatientsLoaded({
    required this.patients,
    required this.hasMore,
    required this.currentPage,
  });

  @override
  List<Object?> get props => [patients, hasMore, currentPage];

  PatientsLoaded copyWith({
    List<PatientEntity>? patients,
    bool? hasMore,
    int? currentPage,
  }) {
    return PatientsLoaded(
      patients: patients ?? this.patients,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class PatientDetailLoaded extends PatientState {
  final PatientEntity patient;

  PatientDetailLoaded(this.patient);

  @override
  List<Object?> get props => [patient];
}

class PatientCreated extends PatientState {
  final PatientEntity patient;

  PatientCreated(this.patient);

  @override
  List<Object?> get props => [patient];
}

class PatientError extends PatientState {
  final String message;

  PatientError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetPatientsUseCase getPatientsUseCase;
  final GetPatientDetailUseCase getPatientDetailUseCase;
  final CreatePatientUseCase createPatientUseCase;

  PatientBloc({
    required this.getPatientsUseCase,
    required this.getPatientDetailUseCase,
    required this.createPatientUseCase,
  }) : super(PatientInitial()) {
    on<GetPatientsRequested>(_onGetPatientsRequested);
    on<GetPatientDetailRequested>(_onGetPatientDetailRequested);
    on<CreatePatientRequested>(_onCreatePatientRequested);
    on<SearchPatientsRequested>(_onSearchPatientsRequested);
  }

  Future<void> _onGetPatientsRequested(
    GetPatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    if (event.isRefresh) {
      emit(PatientLoading());
    }

    final result = await getPatientsUseCase(
      search: event.search,
      page: event.page,
    );

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patients) {
        if (state is PatientsLoaded && !event.isRefresh) {
          final currentState = state as PatientsLoaded;
          emit(currentState.copyWith(
            patients: [...currentState.patients, ...patients],
            currentPage: event.page,
            hasMore: patients.length >= 20,
          ));
        } else {
          emit(PatientsLoaded(
            patients: patients,
            hasMore: patients.length >= 20,
            currentPage: event.page,
          ));
        }
      },
    );
  }

  Future<void> _onGetPatientDetailRequested(
    GetPatientDetailRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getPatientDetailUseCase(event.patientId);

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientDetailLoaded(patient)),
    );
  }

  Future<void> _onCreatePatientRequested(
    CreatePatientRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await createPatientUseCase(event.patient);

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientCreated(patient)),
    );
  }

  Future<void> _onSearchPatientsRequested(
    SearchPatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getPatientsUseCase(search: event.search);

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patients) => emit(PatientsLoaded(
        patients: patients,
        hasMore: patients.length >= 20,
        currentPage: 1,
      )),
    );
  }
}
```

**Página de Lista:** `lib/features/patients/presentation/pages/patients_list_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/patient_bloc.dart';
import '../widgets/patient_card.dart';
import '../widgets/patient_search_bar.dart';

class PatientsListPage extends StatefulWidget {
  const PatientsListPage({Key? key}) : super(key: key);

  @override
  State<PatientsListPage> createState() => _PatientsListPageState();
}

class _PatientsListPageState extends State<PatientsListPage> {
  final _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<PatientBloc>().add(GetPatientsRequested());
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      final state = context.read<PatientBloc>().state;
      if (state is PatientsLoaded && state.hasMore) {
        context.read<PatientBloc>().add(
              GetPatientsRequested(
                page: state.currentPage + 1,
                search: _searchQuery.isNotEmpty ? _searchQuery : null,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pacientes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PatientBloc>().add(
                    GetPatientsRequested(isRefresh: true),
                  );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          PatientSearchBar(
            onSearch: (query) {
              setState(() {
                _searchQuery = query;
              });
              context.read<PatientBloc>().add(
                    SearchPatientsRequested(query),
                  );
            },
          ),
          
          // Lista de pacientes
          Expanded(
            child: BlocBuilder<PatientBloc, PatientState>(
              builder: (context, state) {
                if (state is PatientLoading && state is! PatientsLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is PatientError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<PatientBloc>().add(
                                  GetPatientsRequested(isRefresh: true),
                                );
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is PatientsLoaded) {
                  if (state.patients.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No se encontraron pacientes'),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PatientBloc>().add(
                            GetPatientsRequested(isRefresh: true),
                          );
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.patients.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == state.patients.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final patient = state.patients[index];
                        return PatientCard(
                          patient: patient,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              '/patient-detail',
                              arguments: patient.id,
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed('/create-patient');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

**Widget de Tarjeta de Paciente:** `lib/features/patients/presentation/widgets/patient_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/entities/patient_entity.dart';

class PatientCard extends StatelessWidget {
  final PatientEntity patient;
  final VoidCallback onTap;

  const PatientCard({
    Key? key,
    required this.patient,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: patient.photoUrl != null
              ? CachedNetworkImageProvider(patient.photoUrl!)
              : null,
          child: patient.photoUrl == null
              ? Text(
                  patient.firstName[0].toUpperCase() +
                      patient.lastName[0].toUpperCase(),
                )
              : null,
        ),
        title: Text(
          patient.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${patient.documentType ?? 'DNI'}: ${patient.documentNumber}'),
            Text('Edad: ${patient.age} años'),
            if (patient.bloodType != null)
              Text('Tipo de sangre: ${patient.bloodType}'),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
      ),
    );
  }
}
```

**Entregables del Sprint 2:**
- [x] Módulo de pacientes completo (dominio, datos, presentación)
- [x] Lista de pacientes con scroll infinito
- [x] Búsqueda en tiempo real
- [x] Detalle de paciente
- [x] Creación de paciente
- [x] Caché local con Hive
- [x] Sincronización online/offline
- [x] Pull to refresh

---

### SPRINT 3: MÓDULO DE HISTORIAS CLÍNICAS (1 DÍA)

**Duración:** Día 5  
**Objetivo:** Implementar visualización y gestión de historias clínicas

#### Tareas del Sprint 3

##### 3.1 Implementación Completa del Módulo (8 horas)

Estructura similar a Patients con las siguientes entidades:

**Entidad Principal:**
```dart
class ClinicalRecordEntity {
  final String id;
  final String patientId;
  final String recordNumber;
  final DateTime admissionDate;
  final String chiefComplaint;
  final String clinicalHistory;
  final String physicalExamination;
  final String diagnosis;
  final String treatment;
  final List<VitalSignEntity> vitalSigns;
  final List<String> attachments;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class VitalSignEntity {
  final double? temperature;
  final String? bloodPressure;
  final int? heartRate;
  final int? respiratoryRate;
  final double? weight;
  final double? height;
  final DateTime recordedAt;
}
```

**Características:**
- Visualización de historia clínica completa
- Registro de signos vitales
- Timeline de evolución médica
- Filtros por fecha y médico
- Modo de lectura offline

**Entregables del Sprint 3:**
- [x] Módulo de historias clínicas completo
- [x] Visualización de historia completa
- [x] Registro de signos vitales
- [x] Timeline de evolución
- [x] Modo offline

---

### SPRINT 4: MÓDULO DE DOCUMENTOS Y CÁMARA (1.5 DÍAS)

**Duración:** Día 6 - Mitad del Día 7  
**Objetivo:** Captura, visualización y gestión de documentos médicos

#### Tareas del Sprint 4

##### 4.1 Captura de Documentos con Cámara (4 horas)

**Archivo:** `lib/features/camera/presentation/pages/camera_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraPage extends StatefulWidget {
  final String patientId;
  final String documentType;

  const CameraPage({
    Key? key,
    required this.patientId,
    required this.documentType,
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  List<File> _capturedImages = [];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_controller!.value.isInitialized) return;

    try {
      final XFile image = await _controller!.takePicture();
      setState(() {
        _capturedImages.add(File(image.path));
      });
    } catch (e) {
      print('Error al tomar foto: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _capturedImages.add(File(image.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capturar Documento'),
        actions: [
          if (_capturedImages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.of(context).pop(_capturedImages);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Cámara
          if (_isInitialized)
            Expanded(
              flex: 3,
              child: CameraPreview(_controller!),
            )
          else
            const Expanded(
              flex: 3,
              child: Center(child: CircularProgressIndicator()),
            ),

          // Miniaturas de imágenes capturadas
          if (_capturedImages.isNotEmpty)
            Container(
              height: 120,
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _capturedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.file(
                            _capturedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _capturedImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          // Controles
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Galería
                FloatingActionButton(
                  heroTag: 'gallery',
                  onPressed: _pickFromGallery,
                  child: const Icon(Icons.photo_library),
                ),
                
                // Capturar
                FloatingActionButton.large(
                  heroTag: 'capture',
                  onPressed: _takePicture,
                  child: const Icon(Icons.camera_alt, size: 36),
                ),
                
                // Flash
                FloatingActionButton(
                  heroTag: 'flash',
                  onPressed: () async {
                    if (_controller != null) {
                      final currentFlashMode = _controller!.value.flashMode;
                      await _controller!.setFlashMode(
                        currentFlashMode == FlashMode.off
                            ? FlashMode.torch
                            : FlashMode.off,
                      );
                      setState(() {});
                    }
                  },
                  child: Icon(
                    _controller?.value.flashMode == FlashMode.torch
                        ? Icons.flash_on
                        : Icons.flash_off,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
```

##### 4.2 Visualización y Gestión de Documentos (4 horas)

**Features:**
- Lista de documentos del paciente
- Visor de imágenes con zoom
- Subida de documentos
- Descarga para consulta offline
- Firma digital de documentos (doctores)

**Entregables del Sprint 4:**
- [x] Captura de documentos con cámara
- [x] Selección desde galería
- [x] Vista previa de documentos capturados
- [x] Subida de documentos al servidor
- [x] Visualización de documentos
- [x] Gestión de documentos offline

---

### SPRINT 5: NOTIFICACIONES Y SINCRONIZACIÓN (1 DÍA)

**Duración:** Mitad del Día 7  
**Objetivo:** Implementar notificaciones push y sincronización automática

#### Tareas del Sprint 5

##### 5.1 Notificaciones Push con Firebase (4 horas)

**Configuración:** `lib/core/services/notification_service.dart`

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Solicitar permisos
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Obtener token FCM
    final token = await _fcm.getToken();
    print('FCM Token: $token');
    // Enviar token al backend

    // Configurar notificaciones locales
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(initSettings);

    // Escuchar mensajes en foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Escuchar mensajes cuando la app se abre desde notificación
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Mensaje recibido en foreground: ${message.notification?.title}');
    
    // Mostrar notificación local
    const androidDetails = AndroidNotificationDetails(
      'clinidocs_channel',
      'CliniDocs Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Notificación abierta: ${message.data}');
    // Navegar a la pantalla correspondiente según el tipo de notificación
  }
}
```

**Tipos de Notificaciones:**
1. Nueva historia clínica asignada
2. Documento firmado
3. Resultados de laboratorio disponibles
4. Recordatorio de cita
5. Alertas críticas del paciente

##### 5.2 Servicio de Sincronización (4 horas)

**Archivo:** `lib/core/services/sync_service.dart`

```dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SyncService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _connectivitySubscription;
  bool _isSyncing = false;

  Future<void> initialize() async {
    // Verificar conexión inicial
    await _checkAndSync();

    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        if (result != ConnectivityResult.none) {
          _checkAndSync();
        }
      },
    );
  }

  Future<void> _checkAndSync() async {
    if (_isSyncing) return;
    
    final connectivityResult = await _connectivity.checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) return;

    _isSyncing = true;

    try {
      // Sincronizar datos pendientes
      await _syncPendingData();
      
      // Actualizar caché con datos del servidor
      await _updateCache();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncPendingData() async {
    // Obtener cambios locales pendientes
    final pendingBox = await Hive.openBox('pending_sync');
    final pendingItems = pendingBox.values.toList();

    for (var item in pendingItems) {
      try {
        // Enviar cambio al servidor
        // await _sendToServer(item);
        
        // Si es exitoso, eliminar de pendientes
        await pendingBox.delete(item['id']);
      } catch (e) {
        print('Error al sincronizar item: $e');
        // Mantener en pendientes para reintento
      }
    }
  }

  Future<void> _updateCache() async {
    // Actualizar pacientes
    // await _syncPatients();
    
    // Actualizar historias clínicas
    // await _syncClinicalRecords();
    
    // Actualizar documentos
    // await _syncDocuments();
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }

  Future<void> forceSyncAsync() async {
    await _checkAndSync();
  }
}
```

**Estrategias de Sincronización:**
1. **Sincronización Automática:** Al detectar conexión
2. **Sincronización Manual:** Botón de refresh
3. **Sincronización Programada:** Cada 30 minutos en background
4. **Sincronización Selectiva:** Solo datos modificados

**Entregables del Sprint 5:**
- [x] Sistema de notificaciones push
- [x] Servicio de sincronización automática
- [x] Manejo de conflictos de sincronización
- [x] Indicadores visuales de estado de conexión
- [x] Cola de operaciones pendientes

---

## 📊 RESUMEN DE SPRINTS

| Sprint | Duración | Objetivo Principal | Entregables Clave |
|--------|----------|-------------------|-------------------|
| **Sprint 0** | 1 día | Configuración inicial | Proyecto configurado, DI, HTTP Client |
| **Sprint 1** | 1.5 días | Autenticación | Login, JWT, Biometría |
| **Sprint 2** | 1.5 días | Gestión de pacientes | CRUD pacientes, búsqueda, caché |
| **Sprint 3** | 1 día | Historias clínicas | Visualización, signos vitales |
| **Sprint 4** | 1.5 días | Documentos y cámara | Captura, subida, visualización |
| **Sprint 5** | 1 día | Notificaciones y sync | Push, sincronización automática |

**Total:** 7 días

---

## 🔧 HERRAMIENTAS Y COMANDOS ÚTILES

### Comandos Flutter

```bash
# Crear proyecto
flutter create clinidocs_mobile

# Ejecutar app
flutter run

# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release

# Generar código (Hive, Injectable)
flutter pub run build_runner build --delete-conflicting-outputs

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Análisis de código
flutter analyze

# Tests
flutter test

# Ver dispositivos conectados
flutter devices

# Ver logs
flutter logs
```

### Comandos útiles de desarrollo

```bash
# Ver información del dispositivo
adb devices

# Instalar APK en dispositivo
adb install build/app/outputs/flutter-apk/app-release.apk

# Ver logs de Android
adb logcat

# Limpiar caché de Gradle
cd android && ./gradlew clean

# Abrir emulador
emulator -avd <nombre_emulador>
```

---

## ✅ CHECKLIST DE FINALIZACIÓN

### Funcionalidades Core
- [ ] Login con email y contraseña
- [ ] Autenticación biométrica
- [ ] Gestión de pacientes (CRUD)
- [ ] Búsqueda de pacientes
- [ ] Visualización de historias clínicas
- [ ] Registro de signos vitales
- [ ] Captura de documentos con cámara
- [ ] Visualización de documentos
- [ ] Notificaciones push
- [ ] Sincronización automática

### Características Offline
- [ ] Caché de pacientes
- [ ] Caché de historias clínicas
- [ ] Caché de documentos
- [ ] Cola de sincronización
- [ ] Indicadores de estado de conexión

### Seguridad
- [ ] Autenticación JWT
- [ ] Refresh token automático
- [ ] Almacenamiento seguro de tokens
- [ ] Validación de permisos por rol
- [ ] Encriptación de datos sensibles

### UI/UX
- [ ] Diseño responsive
- [ ] Animaciones fluidas
- [ ] Feedback visual de operaciones
- [ ] Manejo de errores amigable
- [ ] Estados de carga

### Testing
- [ ] Tests unitarios de casos de uso
- [ ] Tests de integración de repositorios
- [ ] Tests de widgets
- [ ] Tests de BLoC

### Deployment
- [ ] Configuración de Firebase
- [ ] Configuración de variables de entorno
- [ ] Icono de la app
- [ ] Splash screen
- [ ] Firma de la app
- [ ] Build de producción

---

## 📝 CONSIDERACIONES TÉCNICAS

### Permisos en Android (AndroidManifest.xml)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permisos necesarios -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    
    <!-- Features de cámara -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
</manifest>
```

### Tamaño del APK

**Meta:** APK < 30 MB

**Estrategias de optimización:**
- Usar ProGuard para ofuscar y minimizar código
- Separar APKs por ABI (armeabi-v7a, arm64-v8a, x86_64)
- Comprimir imágenes
- Usar formato WebP para assets
- Lazy loading de módulos

### Rendimiento

**Objetivos:**
- Tiempo de inicio: < 2 segundos
- Tiempo de respuesta UI: < 100ms
- Consumo de RAM: < 200MB
- Consumo de batería: Bajo

**Optimizaciones:**
- Usar const constructors
- Implementar pagination eficiente
- Caché de imágenes
- Lazy loading de listas
- Optimización de queries a base de datos local

---

## 🚀 PRÓXIMOS PASOS POST-LANZAMIENTO

### Fase 1 (Semana 1-2)
- [ ] Monitoreo de errores con Firebase Crashlytics
- [ ] Analytics con Firebase Analytics
- [ ] Recolección de feedback de usuarios
- [ ] Corrección de bugs críticos

### Fase 2 (Semana 3-4)
- [ ] Optimizaciones de rendimiento
- [ ] Mejoras en UI/UX basadas en feedback
- [ ] Implementación de features faltantes
- [ ] Tests de carga

### Fase 3 (Mes 2)
- [ ] Integración con más servicios del backend
- [ ] Módulo de telemedicina
- [ ] Chat interno para médicos
- [ ] Exportación avanzada de reportes

---

## 📚 RECURSOS Y DOCUMENTACIÓN

### Documentación Oficial
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [Firebase Flutter](https://firebase.google.com/docs/flutter/setup)
- [BLoC Library](https://bloclibrary.dev/)

### APIs del Backend
- Base URL: `https://api.clinidocs.com`
- Documentación: `https://api.clinidocs.com/docs/`
- Swagger: `https://api.clinidocs.com/swagger/`

### Repositorios Relacionados
- Backend: `https://github.com/clinidocs/backend`
- Web App: `https://github.com/clinidocs/frontend-web`
- Mobile App: `https://github.com/clinidocs/mobile-app`

---

## 👥 EQUIPO Y ROLES

### Desarrollador Mobile Lead
- Arquitectura de la app
- Configuración inicial
- Módulos core (Auth, Core)
- Code reviews

### Desarrollador Mobile
- Módulos de funcionalidad (Patients, Clinical Records)
- UI/UX implementation
- Testing
- Documentación

### QA / Tester
- Tests manuales
- Tests automatizados
- Reportes de bugs
- Validación de funcionalidades

---

## 📞 SOPORTE Y CONTACTO

**Proyecto:** CliniDocs Mobile  
**Repositorio:** https://github.com/clinidocs/mobile-app  
**Issues:** https://github.com/clinidocs/mobile-app/issues  
**Slack:** #clinidocs-mobile  
**Email:** dev@clinidocs.com

---

**Última actualización:** Noviembre 2025  
**Versión del documento:** 1.0.0  
**Estado:** ✅ Listo para implementación
