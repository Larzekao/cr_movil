# SPRINT 1 - Guía de Implementación Paso a Paso

## Estado Actual del Proyecto

✅ **Ya Implementado:**
- Estructura de carpetas con Clean Architecture
- Core (network, errors, theme, widgets)
- Feature Auth completo (domain, data, presentation)
- Dependency Injection configurado
- Dio Client con interceptores y refresh token
- BLoC pattern implementado
- UI básica (Login, Splash, Home)

⚠️ **Falta Completar:**
- Generar código con build_runner
- Configurar environment (.env)
- Corregir imports y dependencias
- Testing funcional
- Ajustes finales de UI

---

## FASE 1: Configuración Inicial (30 min)

### Tarea 1.1: Crear archivo .env

**Ubicación:** `cr_movil/.env`

```env
# API Configuration
API_BASE_URL=http://localhost:8000/api
API_TIMEOUT=30000

# Environment
ENVIRONMENT=development
DEBUG_MODE=true

# App Info
APP_NAME=CliniDocs Mobile
APP_VERSION=1.0.0
```

**Comandos:**
```bash
cd cr_movil
```

Crear el archivo `.env` con el contenido anterior.

---

### Tarea 1.2: Actualizar environment.dart

**Archivo:** `lib/config/environment/environment.dart`

Verificar que contenga:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  static String get environment =>
      dotenv.env['ENVIRONMENT'] ?? 'development';

  static bool get isDevelopment => environment == 'development';

  static bool get isProduction => environment == 'production';

  static String get appName =>
      dotenv.env['APP_NAME'] ?? 'CliniDocs Mobile';

  static String get appVersion =>
      dotenv.env['APP_VERSION'] ?? '1.0.0';
}
```

---

### Tarea 1.3: Verificar pubspec.yaml

Asegurarse que las dependencias estén correctas:

```yaml
dependencies:
  # ... otras dependencias ...

  # Network
  dio: ^5.7.0

  # State Management
  flutter_bloc: ^8.1.6
  equatable: ^2.0.5
  dartz: ^0.10.1

  # Storage
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.3.3

  # Utils
  flutter_dotenv: ^5.2.1
  logger: ^2.5.0

  # Dependency Injection
  get_it: ^8.0.2

dev_dependencies:
  build_runner: ^2.4.13
  flutter_lints: ^5.0.0
```

**Comandos:**
```bash
flutter pub get
```

---

## FASE 2: Generar Modelos (15 min)

### Tarea 2.1: Crear user_model.g.dart

El archivo `lib/features/auth/data/models/user_model.dart` necesita:

**Verificar que tenga las anotaciones:**

```dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
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

**Agregar dependencia en pubspec.yaml:**
```yaml
dependencies:
  json_annotation: ^4.8.1

dev_dependencies:
  json_serializable: ^6.7.1
```

**Comandos:**
```bash
# Instalar dependencias
flutter pub get

# Generar código
flutter pub run build_runner build --delete-conflicting-outputs
```

Esto generará automáticamente `user_model.g.dart`.

---

## FASE 3: Ajustar Injection Container (20 min)

### Tarea 3.1: Actualizar injection_container.dart

**Archivo:** `lib/config/dependency_injection/injection_container.dart`

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
  // ========== Features ==========

  // Auth Feature
  _initAuth();

  // ========== Core ==========

  // Dio
  sl.registerLazySingleton<Dio>(() => Dio());

  // Storage
  const flutterSecureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => flutterSecureStorage);

  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // DioClient
  sl.registerLazySingleton<DioClient>(
    () => DioClient(
      dio: sl(),
      storage: sl(),
    ),
  );
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
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      secureStorage: sl(),
      sharedPreferences: sl(),
    ),
  );
}
```

---

## FASE 4: Corregir Imports y Errores (30 min)

### Tarea 4.1: Verificar todos los imports

Ejecutar para encontrar errores:

```bash
flutter analyze
```

### Tarea 4.2: Errores Comunes a Corregir

#### Error 1: Missing import en auth_repository_impl.dart

Si falta `PaginatedResponse` o similar, crear:

**Archivo:** `lib/core/models/paginated_response.dart`

```dart
class PaginatedResponse<T> {
  final int count;
  final String? next;
  final String? previous;
  final List<T> results;

  PaginatedResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      count: json['count'] as int,
      next: json['next'] as String?,
      previous: json['previous'] as String?,
      results: (json['results'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

#### Error 2: Missing storage_constants.dart

**Archivo:** `lib/core/constants/storage_constants.dart`

Verificar que contenga:

```dart
class StorageConstants {
  // Auth Keys
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String tenantId = 'tenant_id';
  static const String userEmail = 'user_email';

  // Settings Keys
  static const String language = 'language';
  static const String theme = 'theme';
  static const String notificationsEnabled = 'notifications_enabled';

  // Cache Keys
  static const String cachedUser = 'cached_user';
  static const String cacheTimestamp = 'cache_timestamp';
}
```

---

## FASE 5: Testing Manual (30 min)

### Tarea 5.1: Ejecutar la app

```bash
# Limpiar build anterior
flutter clean
flutter pub get

# Ejecutar en Android
flutter run

# O ejecutar en iOS
flutter run -d ios
```

### Tarea 5.2: Verificar Flujo de Autenticación

**Test 1: Splash Screen**
- ✅ La app debe mostrar el splash
- ✅ Debe verificar si hay sesión activa
- ✅ Si NO hay sesión → ir a Login
- ✅ Si HAY sesión → ir a Home

**Test 2: Login**
- ✅ Mostrar formulario de login
- ✅ Validar email (formato correcto)
- ✅ Validar password (no vacío)
- ✅ Mostrar loading al hacer login
- ✅ En caso de error → mostrar mensaje
- ✅ En caso de éxito → ir a Home y guardar tokens

**Test 3: Home**
- ✅ Mostrar información del usuario
- ✅ Botón de logout funcional
- ✅ Al hacer logout → limpiar tokens y volver a Login

---

## FASE 6: Ajustes de UI (45 min)

### Tarea 6.1: Mejorar LoginPage

**Archivo:** `lib/features/auth/presentation/pages/login_page.dart`

Verificar que tenga:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

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
            AuthLoginRequested(
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
          if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Icon(
                        Icons.medical_services_rounded,
                        size: 80,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'CliniDocs',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Sistema de Gestión Clínica',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: 'Correo Electrónico',
                          hintText: 'usuario@ejemplo.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo';
                          }
                          if (!value.contains('@')) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
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
                          if (value.length < 4) {
                            return 'La contraseña debe tener al menos 4 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      FilledButton(
                        onPressed: isLoading ? null : _handleLogin,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),

                      const SizedBox(height: 16),

                      // Version
                      Text(
                        'Versión 1.0.0',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[500],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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

---

### Tarea 6.2: Mejorar HomePage

**Archivo:** `lib/features/auth/presentation/pages/home_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CliniDocs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.of(context).pushReplacementNamed('/login');
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nombre
                    Text(
                      user.fullName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Email
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Info Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              context,
                              'Tenant',
                              user.tenant.name,
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              'Rol',
                              user.role?.name ?? 'Sin rol',
                            ),
                            const Divider(),
                            _buildInfoRow(
                              context,
                              'Estado',
                              user.isActive ? 'Activo' : 'Inactivo',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Logout Button
                    OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context),
                      icon: const Icon(Icons.logout),
                      label: const Text('Cerrar Sesión'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
```

---

## FASE 7: Testing Final (30 min)

### Checklist de Testing

```
[ ] La app compila sin errores
[ ] El splash screen aparece correctamente
[ ] La navegación automática funciona (splash → login o home)
[ ] El formulario de login valida correctamente
[ ] El login con credenciales correctas funciona
[ ] El login con credenciales incorrectas muestra error
[ ] Los tokens se guardan en secure storage
[ ] El refresh token funciona en caso de error 401
[ ] La información del usuario se muestra correctamente en home
[ ] El logout funciona y limpia los tokens
[ ] Después de logout, vuelve al login
[ ] La sesión persiste al cerrar y reabrir la app
```

---

## FASE 8: Optimización (opcional, 20 min)

### Tarea 8.1: Agregar Logging

Ya está configurado con `logger` en DioClient.

### Tarea 8.2: Manejo de Errores Mejorado

Verificar que todos los errores se manejen apropiadamente en:
- `dio_client.dart` → Interceptor de errores
- `auth_repository_impl.dart` → Mapeo de failures
- `auth_bloc.dart` → Emisión de estados de error

---

## Comandos Útiles Durante la Implementación

```bash
# Limpiar proyecto
flutter clean

# Instalar dependencias
flutter pub get

# Generar código (modelos JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Analizar código
flutter analyze

# Formatear código
flutter format lib/

# Ejecutar app (debug)
flutter run

# Ejecutar app (release)
flutter run --release

# Ver logs
flutter logs

# Hot reload (durante desarrollo)
# Presionar 'r' en la terminal

# Hot restart (durante desarrollo)
# Presionar 'R' en la terminal
```

---

## Errores Comunes y Soluciones

### Error 1: "The getter 'dio' isn't defined"
**Solución:** Verificar que DioClient esté correctamente registrado en injection_container.dart

### Error 2: "type 'Null' is not a subtype of type 'String'"
**Solución:** Revisar que el modelo JSON maneje valores nulos correctamente con `?`

### Error 3: "Bad state: No element"
**Solución:** Verificar que GetIt tenga todas las dependencias registradas antes de usarlas

### Error 4: "Cannot find annotation constructors without args"
**Solución:** Ejecutar `flutter pub run build_runner build --delete-conflicting-outputs`

### Error 5: ".env file not found"
**Solución:** Crear el archivo .env en la raíz del proyecto y agregarlo a pubspec.yaml en assets

### Error 6: "Navigator operation requested with a context that does not include a Navigator"
**Solución:** Usar `Navigator.of(context)` dentro de un BlocListener, no en el builder

---

## Resultado Esperado

Al final del Sprint 1, deberías tener:

✅ **App funcional** con login, splash y home
✅ **Autenticación JWT** completa con refresh token
✅ **Persistencia de sesión** usando secure storage
✅ **Navegación** automática basada en estado de autenticación
✅ **UI limpia y moderna** con Material 3
✅ **Arquitectura limpia** con separación de capas
✅ **Manejo de errores** robusto
✅ **Base sólida** para implementar siguientes sprints

---

## Próximos Pasos (Sprint 2)

Una vez completado el Sprint 1, estarás listo para:

1. Implementar Dashboard con estadísticas
2. Crear módulo de Pacientes (CRUD completo)
3. Agregar búsqueda y paginación
4. Implementar widgets reutilizables avanzados

---

## Tiempo Estimado Total

| Fase | Tiempo |
|------|--------|
| Fase 1: Configuración | 30 min |
| Fase 2: Generación de modelos | 15 min |
| Fase 3: Injection Container | 20 min |
| Fase 4: Corrección de errores | 30 min |
| Fase 5: Testing manual | 30 min |
| Fase 6: Ajustes de UI | 45 min |
| Fase 7: Testing final | 30 min |
| Fase 8: Optimización | 20 min |
| **TOTAL** | **~3.5 horas** |

---

## Notas Importantes

1. **No saltarse pasos**: Cada fase construye sobre la anterior
2. **Testear frecuentemente**: Ejecutar `flutter run` después de cada fase mayor
3. **Commit frecuente**: Hacer commits de git después de cada fase completada
4. **Leer errores**: Flutter da mensajes de error muy descriptivos
5. **Hot reload**: Usar 'r' en terminal para ver cambios sin reiniciar

---

## Soporte

Si encuentras errores que no están documentados aquí:

1. Ejecutar `flutter doctor` para verificar instalación
2. Revisar logs con `flutter logs`
3. Verificar versiones de dependencias en pubspec.yaml
4. Limpiar y reinstalar: `flutter clean && flutter pub get`

¡Buena suerte con la implementación! 🚀
