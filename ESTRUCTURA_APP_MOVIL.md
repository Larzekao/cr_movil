# CliniDocs Mobile - Análisis de Estructura

## 📱 Descripción General

**CliniDocs Mobile** es una aplicación Flutter para la gestión de historias clínicas digitales. La app implementa una arquitectura limpia con separación de capas (Data, Domain, Presentation) y utiliza BLoC para la gestión de estado.

**Versión:** 1.0.0  
**SDK Flutter:** ^3.9.2  
**Plataformas:** Android & iOS

---

## 🏗️ Arquitectura General

La aplicación sigue una **Clean Architecture** con 3 capas principales:

```
lib/
├── config/              ← Configuración e inyección de dependencias
├── core/                ← Utilidades, widgets y constantes compartidas
├── features/            ← Características principales (Auth, Pacientes, Historias, Documentos)
└── main.dart            ← Punto de entrada
```

### Capas de Arquitectura

| Capa | Responsabilidad |
|------|-----------------|
| **Presentation** | UI, BLoCs, páginas y widgets específicos de la feature |
| **Domain** | Lógica de negocio, entidades y casos de uso |
| **Data** | Acceso a datos, modelos, data sources y repositorios |

---

## 📁 Estructura Detallada

### 1. **config/** - Configuración Central

```
config/
├── dependency_injection/
│   └── injection_container.dart    ← Inyección de dependencias con get_it e injectable
└── environment/
    └── .env                        ← Variables de entorno
```

**Responsabilidad:**
- Configurar todas las dependencias (Repos, BLoCs, UseCases)
- Gestionar variables de entorno
- Inicializar servicios externos

---

### 2. **core/** - Núcleo Compartido

```
core/
├── constants/                      ← Constantes de la app
├── error/                          ← Clases de manejo de errores
│   └── failures.dart               ← Fallas personalizadas
├── errors/                         ← Excepciones personalizadas
├── network/
│   ├── dio_client.dart             ← Cliente HTTP con Dio
│   └── network_info.dart           ← Verificación de conectividad
├── theme/
│   └── app_theme.dart              ← Tema light/dark de Material Design
├── usecases/
│   └── usecase.dart                ← Clase base para todos los casos de uso
└── widgets/
    ├── app_drawer.dart             ← Drawer de navegación
    ├── custom_button.dart          ← Botones personalizados
    ├── custom_text_field.dart      ← Campos de texto personalizados
    ├── error_widget.dart           ← Widget de error
    └── loading_widget.dart         ← Widget de carga
```

**Responsabilidad:**
- Proporcionar componentes reutilizables
- Centralizar temas y estilos
- Gestionar errores globales
- Manejar conectividad de red

---

### 3. **features/** - Características Principales

Cada feature sigue la arquitectura Clean Architecture con 3 capas:

#### **3.1 AUTH (Autenticación)**

```
features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_data_source.dart      ← Almacenamiento local (tokens)
│   │   └── auth_remote_data_source.dart     ← API remota
│   ├── models/
│   │   ├── auth_model.dart                  ← Modelos con JSON serialization
│   │   └── user_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart        ← Implementación del repositorio
├── domain/
│   ├── entities/
│   │   ├── auth_entity.dart
│   │   └── user_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart             ← Interfaz del repositorio
│   └── usecases/
│       ├── login_usecase.dart
│       ├── logout_usecase.dart
│       └── get_current_user_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart                   ← Gestor de estado
    │   ├── auth_event.dart                  ← Eventos
    │   └── auth_state.dart                  ← Estados
    └── pages/
        ├── splash_page.dart                 ← Pantalla de inicio
        ├── login_page.dart                  ← Pantalla de login
        └── home_page.dart                   ← Pantalla principal
```

**Responsabilidad:**
- Gestionar autenticación de usuarios
- Almacenar tokens de sesión
- Validar credenciales con backend

---

#### **3.2 CLINICAL_RECORDS (Historias Clínicas)**

```
features/clinical_records/
├── data/
│   ├── datasources/
│   │   ├── clinical_record_local_data_source.dart   ← Cache local
│   │   └── clinical_record_remote_data_source.dart  ← API
│   ├── models/
│   │   └── clinical_record_model.dart
│   └── repositories/
│       └── clinical_record_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── clinical_record_entity.dart
│   ├── repositories/
│   │   └── clinical_record_repository.dart
│   └── usecases/
│       ├── get_clinical_records_usecase.dart
│       ├── create_clinical_record_usecase.dart
│       ├── update_clinical_record_usecase.dart
│       └── get_clinical_record_detail_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── clinical_record_bloc.dart
    │   ├── clinical_record_event.dart
    │   └── clinical_record_state.dart
    └── pages/
        ├── clinical_records_list_page.dart  ← Listado de historias
        ├── clinical_record_detail_page.dart ← Detalle de una historia
        └── clinical_record_form_page.dart   ← Formulario para crear/editar
```

**Responsabilidad:**
- Gestionar historias clínicas de pacientes
- Sincronizar con backend
- Cachear datos localmente
- CRUD de historias clínicas

---

#### **3.3 PATIENTS (Pacientes)**

```
features/patients/
├── data/
│   ├── datasources/
│   │   ├── patient_local_data_source.dart
│   │   └── patient_remote_data_source.dart
│   ├── models/
│   │   └── patient_model.dart
│   └── repositories/
│       └── patient_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── patient_entity.dart
│   ├── repositories/
│   │   └── patient_repository.dart
│   └── usecases/
│       ├── get_patients_usecase.dart
│       ├── get_patient_detail_usecase.dart
│       └── create_patient_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── patient_bloc.dart
    │   ├── patient_event.dart
    │   └── patient_state.dart
    └── pages/
        └── patients_list_page.dart         ← Listado de pacientes
```

**Responsabilidad:**
- Gestionar datos de pacientes
- Listar pacientes
- Ver detalles de pacientes
- CRUD de pacientes

---

#### **3.4 DOCUMENTS (Documentos)**

```
features/documents/
├── data/
│   ├── datasources/
│   │   ├── document_local_data_source.dart
│   │   └── document_remote_data_source.dart
│   ├── models/
│   │   └── document_model.dart
│   └── repositories/
│       └── document_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── document_entity.dart
│   ├── repositories/
│   │   └── document_repository.dart
│   └── usecases/
│       ├── get_documents_usecase.dart
│       ├── upload_document_usecase.dart
│       └── download_document_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── document_bloc.dart
    │   ├── document_event.dart
    │   └── document_state.dart
    └── pages/
        └── documents_list_page.dart        ← Listado de documentos
```

**Responsabilidad:**
- Gestionar documentos clínicos
- Subir documentos a servidor
- Descargar documentos
- Visualizar documentos

---

## 🔌 Dependencias Principales

### State Management
- **flutter_bloc** (8.1.6) - Gestión de estado reactiva
- **equatable** (2.0.5) - Comparación de objetos

### Network & API
- **dio** (5.7.0) - Cliente HTTP avanzado
- **connectivity_plus** (6.1.1) - Verificar conectividad

### Local Storage
- **hive** (2.2.3) - Base de datos local NoSQL
- **hive_flutter** (1.1.0) - Integración con Flutter
- **flutter_secure_storage** (9.2.2) - Almacenamiento seguro
- **shared_preferences** (2.3.3) - Preferencias simples

### Navigation
- **go_router** (14.6.2) - Enrutador declarativo

### Dependency Injection
- **get_it** (8.0.2) - Service Locator
- **injectable** (2.5.0) - Generación de código para DI

### UI & Media
- **cached_network_image** (3.4.1) - Imágenes en caché
- **flutter_svg** (2.0.10) - Soporte SVG
- **image_picker** (1.1.2) - Seleccionar imágenes
- **camera** (0.11.0) - Acceso a cámara
- **permission_handler** (11.3.1) - Permisos

### Authentication
- **local_auth** (2.3.0) - Biometría (huella dactilar)

### Utilities
- **flutter_dotenv** (5.2.1) - Variables de entorno
- **logger** (2.5.0) - Logging
- **intl** (0.19.0) - Internacionalización
- **dartz** (0.10.1) - Functional programming utilities

---

## 🔄 Flujo de Datos

### Ejemplo: Obtener lista de pacientes

```
1. UI (PatientsListPage)
   ↓
2. Dispara evento → PatientBloc (PatientEvent.GetPatients)
   ↓
3. BLoC llama a UseCase → GetPatientsUseCase()
   ↓
4. UseCase llama al Repo → PatientRepository.getPatients()
   ↓
5. Repo elige fuente:
   a) Si está online → PatientRemoteDataSource (API)
   b) Si está offline → PatientLocalDataSource (Hive)
   ↓
6. Datos retornan transformados en Entities
   ↓
7. BLoC emite estado → PatientState.Success
   ↓
8. UI reconstruye con BlocBuilder y muestra datos
```

---

## 🎨 Temas y Estilos

**Ubicación:** `core/theme/app_theme.dart`

- **Tema Light:** Colores claros para modo claro
- **Tema Dark:** Colores oscuros para modo oscuro
- Tipografía y espaciados consistentes
- Paleta de colores corporativa

---

## 🔐 Seguridad

### Almacenamiento de Tokens
- **flutter_secure_storage** para tokens de autenticación
- Encriptación del almacenamiento local

### API Security
- Headers de autenticación en cada request
- Validación de SSL/TLS
- Manejo de errores de autorización

### Permisos
- Permisos de cámara
- Permisos de almacenamiento
- Permisos de contactos

---

## 📊 BLoC Pattern

Cada feature implementa el patrón BLoC:

```dart
// Estructura de un BLoC
class PatientBloc extends Bloc<PatientEvent, PatientState> {
  PatientBloc(this._getPatients) : super(PatientInitial()) {
    on<GetPatients>(_onGetPatients);
  }

  Future<void> _onGetPatients(GetPatients event, Emitter emit) async {
    emit(PatientLoading());
    final result = await _getPatients.call();
    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patients) => emit(PatientSuccess(patients)),
    );
  }
}
```

**Estados genéricos por feature:**
- `Initial` - Estado inicial
- `Loading` - Cargando datos
- `Success` - Datos obtenidos exitosamente
- `Error` - Error en la operación

---

## 📱 Rutas de Navegación

**Configurado en:** `main.dart`

```dart
routes: {
  '/splash': SplashPage(),
  '/login': LoginPage(),
  '/home': HomePage(),
  '/patients': PatientsListPage(),
  '/clinical-records': ClinicalRecordsListPage(),
  '/clinical-records/:id': ClinicalRecordDetailPage(),
  '/documents': DocumentsListPage(),
}
```

---

## 🔄 Ciclo de Desarrollo

### Agregar Nueva Feature

1. **Crear estructura de carpetas:** `data/`, `domain/`, `presentation/`
2. **Definir Entity** en `domain/entities/`
3. **Crear Model** en `data/models/` (con JSON serialization)
4. **Implementar DataSources** en `data/datasources/`
5. **Crear Repository** (interface y implementación)
6. **Definir UseCase** en `domain/usecases/`
7. **Crear BLoC** con Events y States
8. **Construir UI** en `presentation/pages/`

---

## 📦 Compilación y Distribución

### Build Android APK
```bash
flutter build apk --release
```

### Build iOS IPA
```bash
flutter build ios --release
```

### Build Web
```bash
flutter build web --release
```

---

## 🚀 Características Implementadas

- ✅ Autenticación de usuarios
- ✅ Gestión de pacientes
- ✅ CRUD de historias clínicas
- ✅ Gestión de documentos
- ✅ Sincronización online/offline
- ✅ Almacenamiento local en caché
- ✅ Tema light/dark
- ✅ Logging y debugging
- ⏳ Firebase (comentado, pendiente configurar)
- ⏳ Autenticación biométrica (pendiente integración)

---

## ⚙️ Variables de Entorno

**Archivo:** `.env`

```env
# API Configuration
API_BASE_URL=http://tu-backend.com/api

# Environment
ENVIRONMENT=development

# Timeouts
API_TIMEOUT=30000
```

---

## 🧪 Pruebas

**Ubicación:** `test/`

Para ejecutar pruebas:
```bash
flutter test
```

---

## 📝 Convenciones de Código

- **Nombres de archivos:** `snake_case`
- **Nombres de clases:** `PascalCase`
- **Nombres de variables:** `camelCase`
- **Nombres de constantes:** `SCREAMING_SNAKE_CASE`
- **Comentarios:** Documentar lógica compleja
- **Organización:** Una clase principal por archivo

---

## 🛠️ Herramientas de Desarrollo

### Code Generation
```bash
flutter pub run build_runner build
flutter pub run build_runner watch
```

### Linting
```bash
flutter analyze
dart fix --dry-run
```

### Formatting
```bash
dart format .
```

---

## 🔗 Integración Backend

- **Base URL:** Configurada en `.env`
- **Cliente HTTP:** Dio con interceptores
- **Autenticación:** Token Bearer en headers
- **Serialización:** JSON

### Endpoints Principales
- `POST /auth/login` - Autenticación
- `GET /patients` - Listar pacientes
- `POST /clinical-records` - Crear historia clínica
- `GET /clinical-records/{id}` - Obtener historia
- `POST /documents/upload` - Subir documento

---

## 📊 Estadísticas del Proyecto

- **Total de Features:** 4 (Auth, Patients, Clinical Records, Documents)
- **Patrón Arquitectónico:** Clean Architecture
- **State Management:** BLoC
- **Target Flutter Version:** 3.9.2+
- **Min SDK Android:** API 21
- **Min iOS:** 12.0

---

## 🎯 Próximos Pasos

1. ✅ Terminar integración de historias clínicas
2. ⏳ Configurar Firebase Messaging
3. ⏳ Implementar autenticación biométrica
4. ⏳ Agregar unit tests
5. ⏳ Optimizar rendimiento de imágenes
6. ⏳ Implementar sync offline mejorado

---

## 📞 Contacto & Soporte

**Proyecto:** CliniDocs Mobile  
**Desarrollador:** Larzekao  
**Repositorio:** cr_movil  
**Estado:** En desarrollo activo

---

*Documento generado automáticamente. Última actualización: 16 de noviembre de 2025*
