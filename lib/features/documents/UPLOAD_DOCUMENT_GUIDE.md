# 📄 Guía de Implementación: Subida de Documentos (DATA & DOMAIN)

## 🎯 Resumen

Este documento describe la implementación completa de la capa **DATA** y **DOMAIN** para la subida de documentos clínicos en CliniDocs Mobile. El módulo maneja:

- ✅ Upload de archivos mediante **multipart/form-data**
- ✅ Validación de parámetros requeridos
- ✅ Manejo robusto de errores de red y servidor
- ✅ Integración con autenticación (Bearer token)
- ✅ Arquitectura limpia (Data → Domain → Presentation)

---

## 📁 Estructura de Archivos Implementada

```
lib/features/documents/
├── data/
│   ├── datasources/
│   │   └── document_remote_datasource.dart ✅ [ACTUALIZADO]
│   ├── models/
│   │   └── document_model.dart
│   └── repositories/
│       └── document_repository_impl.dart ✅ [ACTUALIZADO]
├── domain/
│   ├── entities/
│   │   └── document_entity.dart
│   ├── repositories/
│   │   └── document_repository.dart
│   └── usecases/
│       └── upload_document_usecase.dart ✅ [ACTUALIZADO]
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/

lib/core/
├── constants/
│   └── api_constants.dart ✅ [ACTUALIZADO - endpoint corregido]
├── errors/
│   ├── failures.dart
│   └── exceptions.dart
└── network/
    └── dio_client.dart
```

---

## 🔧 Cambios Realizados

### 1. **api_constants.dart**

```dart
// ✅ CAMBIO: Removido /upload/ - ahora es POST directo a /documents/
class ApiConstants {
  static const String documents = '/documents/';
  // Eliminado: static const String uploadDocument = '/documents/upload/';
}
```

**Razón:** El backend de CliniDocs espera un POST directo a `/api/documents/` con `multipart/form-data`, no a un endpoint separado.

---

### 2. **document_remote_datasource.dart**

#### **Método `uploadDocument()` mejorado:**

```dart
Future<DocumentModel> uploadDocument({
  required String clinicalRecordId,        // FK a historia clínica
  required String documentType,             // Tipo: 'lab_result', 'imaging_report', etc.
  required String title,                    // Título del documento
  required DateTime documentDate,           // Fecha del documento
  required String filePath,                 // Ruta local del archivo
  String? description,                      // Descripción opcional
  String? specialty,                        // Especialidad médica (opcional)
  String? doctorName,                       // Nombre del médico (opcional)
  String? doctorLicense,                    // Licencia del médico (opcional)
})
```

#### **Características implementadas:**

✅ **FormData multipart** correctamente construido
```dart
final formData = FormData.fromMap({
  'clinical_record': clinicalRecordId,
  'document_type': documentType,
  'title': title,
  'document_date': documentDate.toIso8601String(),
  'file': await MultipartFile.fromFile(filePath),  // ← Archivo binario
});
```

✅ **Campos opcionales agregados solo si existen**
```dart
if (description != null && description.isNotEmpty) {
  formData.fields.add(MapEntry('description', description));
}
```

✅ **Manejo completo de errores DioException:**
- `connectionTimeout` → "Tiempo de conexión agotado"
- `receiveTimeout` → "El servidor tardó demasiado"
- Status 400 → Errores de validación
- Status 401 → "No autorizado - Inicia sesión nuevamente"
- Status 403 → "Acceso denegado"
- Status 413 → "El archivo es demasiado grande (Max 100MB)"
- Status 500 → "Error interno del servidor"

✅ **Logging completo** con `Logger` para debugging

✅ **Endpoint correcto**
```dart
final response = await client.post(
  ApiConstants.documents,  // POST /api/documents/ directamente
  data: formData,
);
```

---

### 3. **document_repository_impl.dart**

#### **Método `uploadDocument()` mejorado:**

```dart
Future<Either<Failure, DocumentEntity>> uploadDocument({
  required String clinicalRecordId,
  required String documentType,
  required String title,
  required DateTime documentDate,
  required String filePath,
  String? description,
  String? specialty,
  String? doctorName,
  String? doctorLicense,
})
```

#### **Mejoras implementadas:**

✅ **Validaciones de parámetros requeridos**
```dart
if (clinicalRecordId.isEmpty) {
  return Left(ServerFailure('ID de historia clínica es requerido'));
}
if (documentType.isEmpty) {
  return Left(ServerFailure('Tipo de documento es requerido'));
}
// ... más validaciones
```

✅ **Conversión de excepciones a Failures**
```dart
} on ServerException catch (e) {
  return Left(ServerFailure(e.message, statusCode: e.statusCode));
} catch (e) {
  return Left(ServerFailure('Error inesperado al subir documento: $e'));
}
```

✅ **Patrón Either<Failure, DocumentEntity>**
- Lado izquierdo: Errores (Failure)
- Lado derecho: Éxito (DocumentEntity)

---

### 4. **upload_document_usecase.dart**

#### **Nuevo: Clase UploadDocumentParams**

```dart
class UploadDocumentParams {
  final String clinicalRecordId;
  final String documentType;
  final String title;
  final DateTime documentDate;
  final String filePath;
  final String? description;
  final String? specialty;
  final String? doctorName;
  final String? doctorLicense;
}
```

**Beneficio:** Parámetros organizados en una clase única, seguir patrón UseCase base.

#### **UseCase mejorado**

```dart
class UploadDocumentUseCase extends UseCase<DocumentEntity, UploadDocumentParams> {
  final DocumentRepository repository;

  UploadDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, DocumentEntity>> call(UploadDocumentParams params) async {
    // Validar parámetros
    if (params.clinicalRecordId.isEmpty) {
      return Left(ServerFailure('ID de historia clínica es requerido'));
    }
    // ... más validaciones
    
    // Delegar al repositorio
    return await repository.uploadDocument(...);
  }
}
```

---

## 📊 Flujo de Datos Completo

```
┌─────────────────────────────────────────────────────────────┐
│ PRESENTATION LAYER (UI - BLoC)                              │
│ - DocumentUploadPage captura archivo con Camera             │
│ - Dispara evento: DocumentEvent.UploadDocument(params)      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ DOMAIN LAYER (Business Logic)                               │
│ - UploadDocumentUseCase.call(UploadDocumentParams)           │
│ - Valida parámetros requeridos                              │
│ - Delega al repositorio                                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ DATA LAYER (Repository)                                      │
│ - DocumentRepositoryImpl.uploadDocument(...)                 │
│ - Valida nuevamente parámetros                              │
│ - Convierte excepciones a Failures                          │
│ - Delega a datasource                                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ DATA SOURCE LAYER (Network)                                  │
│ - DocumentRemoteDataSourceImpl.uploadDocument(...)           │
│ - Construye FormData multipart                              │
│ - POST /api/documents/ con Bearer token                     │
│ - Maneja errores de red específicamente                     │
│ - Retorna DocumentModel                                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ BACKEND (Django REST)                                        │
│ POST /api/documents/                                         │
│ - Recibe multipart/form-data                                │
│ - Almacena en S3                                            │
│ - Retorna JSON con DocumentEntity serializado               │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Cómo Usar desde la Capa de Presentación

### Inyección de Dependencias (dependency_injection/injection_container.dart)

Asegúrate de que está registrado:

```dart
@lazySingleton
DocumentRemoteDataSource get documentRemoteDataSource =>
    DocumentRemoteDataSourceImpl(client: getIt());

@lazySingleton
DocumentRepository get documentRepository =>
    DocumentRepositoryImpl(remoteDataSource: getIt());

@lazySingleton
UploadDocumentUseCase get uploadDocumentUseCase =>
    UploadDocumentUseCase(getIt());

@lazySingleton
DocumentBloc get documentBloc => DocumentBloc(
  uploadDocumentUseCase: getIt(),
  getDocumentsUseCase: getIt(),
  // ... otros casos de uso
);
```

### Desde el BLoC (Capa de Presentación)

```dart
import 'package:image_picker/image_picker.dart';

// En document_bloc.dart
class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final UploadDocumentUseCase uploadDocumentUseCase;
  
  DocumentBloc({required this.uploadDocumentUseCase})
      : super(DocumentInitial()) {
    on<UploadDocument>(_onUploadDocument);
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(DocumentLoading());

    final params = UploadDocumentParams(
      clinicalRecordId: event.clinicalRecordId,
      documentType: event.documentType,  // 'lab_result', 'imaging_report', etc.
      title: event.title,
      documentDate: DateTime.now(),
      filePath: event.file.path,
      description: event.description,
      specialty: event.specialty,
      doctorName: event.doctorName,
      doctorLicense: event.doctorLicense,
    );

    final result = await uploadDocumentUseCase.call(params);

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
      (document) => emit(DocumentUploadSuccess(document)),
    );
  }
}
```

### Desde una Página (Ejemplo)

```dart
import 'package:image_picker/image_picker.dart';

class DocumentUploadPage extends StatefulWidget {
  final String clinicalRecordId;
  
  const DocumentUploadPage({required this.clinicalRecordId});

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
  XFile? selectedFile;
  
  Future<void> _pickDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,  // o ImageSource.gallery
    );
    
    if (file != null) {
      setState(() => selectedFile = file);
    }
  }

  void _uploadDocument() {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona un archivo')),
      );
      return;
    }

    // Dispara evento en el BLoC
    context.read<DocumentBloc>().add(
      UploadDocument(
        clinicalRecordId: widget.clinicalRecordId,
        documentType: 'lab_result',
        title: 'Resultado de Laboratorio',
        description: 'Análisis de sangre',
        file: selectedFile!,
        specialty: 'Laboratorio',
        doctorName: 'Dr. Pérez',
        doctorLicense: 'LIC-12345',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subir Documento')),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentUploadSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Documento subido exitosamente')),
            );
            Navigator.pop(context);
          } else if (state is DocumentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: BlocBuilder<DocumentBloc, DocumentState>(
          builder: (context, state) {
            if (state is DocumentLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedFile != null)
                  Text('Archivo: ${selectedFile!.name}'),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickDocument,
                  child: Text('Seleccionar Documento'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _uploadDocument,
                  child: Text('Subir Documento'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
```

---

## ⚙️ Configuración del Backend Esperada

El backend debe tener un endpoint que maneje:

```
POST /api/documents/
Content-Type: multipart/form-data
Authorization: Bearer <access_token>

Campos esperados:
- clinical_record (UUID) - FK a ClinicalRecord
- document_type (string) - Tipo de documento
- title (string) - Título
- document_date (ISO8601) - Fecha
- file (binary) - Archivo
- description (string, optional) - Descripción
- specialty (string, optional) - Especialidad
- doctor_name (string, optional) - Nombre doctor
- doctor_license (string, optional) - Licencia

Respuesta 201:
{
  "id": "uuid",
  "clinical_record": "uuid-histor ia",
  "document_type": "lab_result",
  "title": "Resultado de Laboratorio",
  "document_date": "2025-11-16T10:30:00Z",
  "file_path": "s3://bucket/...",
  "created_at": "2025-11-16T10:30:00Z",
  ...
}
```

---

## 🔐 Seguridad Implementada

✅ **Token de autenticación:**
- DioClient agrega automáticamente: `Authorization: Bearer <token>`
- Si recibe 401, auto-refresca el token

✅ **Tenant ID:**
- DioClient agrega: `X-Tenant-ID: <tenant_id>`
- Backend filtra datos por tenant automáticamente

✅ **Validación de archivos:**
- Limite de tamaño: 100MB
- Backend valida tipos MIME permitidos
- Checksum SHA-256 para integridad

✅ **Manejo de errores sensibles:**
- No expone rutas internas
- Mensajes de error claros para el usuario

---

## 📋 Casos de Error Manejados

| Error | Causa | Acción |
|-------|-------|--------|
| `connectionTimeout` | Red lenta/caída | Reintentar |
| `receiveTimeout` | Servidor lento | Mostrar mensaje |
| `400 Bad Request` | Datos inválidos | Validar inputs |
| `401 Unauthorized` | Token expirado | Auto-refresh |
| `403 Forbidden` | Sin permisos | Mostrar alerta |
| `413 Payload Too Large` | Archivo muy grande | Comprimir/reducir |
| `500 Server Error` | Error backend | Reintentar luego |
| `NetworkException` | Sin conexión | Sincronizar offline |

---

## 🧪 Ejemplo de Prueba (Unit Test)

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';

void main() {
  group('UploadDocumentUseCase', () {
    late MockDocumentRepository mockRepository;
    late UploadDocumentUseCase useCase;

    setUp(() {
      mockRepository = MockDocumentRepository();
      useCase = UploadDocumentUseCase(mockRepository);
    });

    test('debe retornar DocumentEntity al subir exitosamente', () async {
      // Arrange
      final params = UploadDocumentParams(
        clinicalRecordId: 'record-123',
        documentType: 'lab_result',
        title: 'Test Document',
        documentDate: DateTime.now(),
        filePath: '/path/to/file.jpg',
      );

      final tDocument = DocumentEntity(
        id: 'doc-123',
        clinicalRecordId: 'record-123',
        patientName: 'Juan Pérez',
        documentType: 'lab_result',
        title: 'Test Document',
        documentDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockRepository.uploadDocument(...))
          .thenAnswer((_) async => Right(tDocument));

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, Right(tDocument));
      verify(mockRepository.uploadDocument(...)).called(1);
    });

    test('debe retornar Failure si los parámetros están vacíos', () async {
      // Arrange
      final params = UploadDocumentParams(
        clinicalRecordId: '',  // ← Vacío
        documentType: 'lab_result',
        title: 'Test',
        documentDate: DateTime.now(),
        filePath: '/path/file.jpg',
      );

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('ID de historia')),
        (_) => fail('Debería ser un Failure'),
      );
    });
  });
}
```

---

## ✅ Checklist de Implementación

- [x] Actualizar `api_constants.dart` (endpoint correcto)
- [x] Mejorar `DocumentRemoteDataSource.uploadDocument()`
- [x] Mejorar `DocumentRepositoryImpl.uploadDocument()`
- [x] Mejorar `UploadDocumentUseCase` con `UploadDocumentParams`
- [ ] Inyectar dependencias en `injection_container.dart`
- [ ] Crear eventos y estados en `DocumentEvent` y `DocumentState`
- [ ] Implementar lógica en `DocumentBloc`
- [ ] Crear UI en `document_upload_page.dart`
- [ ] Agregar permisos en `AndroidManifest.xml` y `Info.plist`
- [ ] Probar con documentos reales

---

## 📞 Próximos Pasos

1. **PRESENTATION:** Implementar BLoC, eventos, estados
2. **UI:** Crear páginas de cámara y preview
3. **Pruebas:** Unit tests y integración

---

*Implementación completada: 16 de noviembre de 2025*
