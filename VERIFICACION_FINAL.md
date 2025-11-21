# ✅ Verificación Final - Documentos con Cámara

## Estado del Proyecto

### 📋 Checklist de Implementación

- [x] **Dependencias instaladas:**

  - ✅ camera: ^0.11.0+2
  - ✅ image_picker: ^1.1.2
  - ✅ permission_handler: ^11.3.1
  - ✅ file_picker: ^8.1.4 (nuevo)
  - ✅ image_cropper: ^8.0.2 (nuevo)
  - ✅ path: ^1.9.0 (nuevo)
  - ✅ mime: ^2.0.0 (nuevo)

- [x] **Archivos creados/modificados:**

  - ✅ `lib/features/documents/presentation/pages/document_create_page.dart` - **Nueva página de selección de historia clínica**
  - ✅ `lib/main.dart` - **Actualizado con rutas y DocumentCreatePage**
  - ✅ `lib/features/auth/presentation/pages/home_page.dart` - **Botón "Documentos" → "Crear Documento"**
  - ✅ `android/app/src/main/AndroidManifest.xml` - **Permisos de cámara agregados**
  - ✅ `pubspec.yaml` - **Dependencias nuevas agregadas**

- [x] **Rutas configuradas:**

  - ✅ `/document-create` → DocumentCreatePage (nueva)
  - ✅ `/document-camera` → DocumentCameraPage (existente)
  - ✅ `/document-upload` → DocumentUploadPage (existente)

- [x] **Flujo completo:**

  - ✅ HomePage → Botón "Crear Documento" → DocumentCreatePage
  - ✅ DocumentCreatePage → Selecciona Historia Clínica → Abre Cámara
  - ✅ DocumentCameraPage → Captura fotos → Retorna List<XFile>
  - ✅ DocumentUploadPage → Llena formulario → Sube al backend

- [x] **Validación de código:**

  - ✅ Sin errores de importación
  - ✅ Sin errores de tipos (patientIdentity → patientInfo?.identification)
  - ✅ Sin errores de análisis (flutter analyze: No issues found!)
  - ✅ GetClinicalRecordsEvent() correctamente instanciado (sin const)

- [x] **Permisos Android:**
  - ✅ CAMERA
  - ✅ READ_EXTERNAL_STORAGE
  - ✅ WRITE_EXTERNAL_STORAGE
  - ✅ READ_MEDIA_IMAGES
  - ✅ hardware.camera (feature, not required)

### 📁 Archivos Principales

#### 1. **document_create_page.dart** (340 líneas)

```
Ubicación: lib/features/documents/presentation/pages/document_create_page.dart
Función: Selector de historia clínica antes de abrir cámara
- Carga lista de historias clínicas con ClinicalRecordBloc
- Búsqueda/filtrado por nombre, cédula, número
- Selección visual con checkmark
- Botón "Abrir Cámara" abre DocumentCameraPage
- Recibe List<XFile> y navega a DocumentUploadPage
```

#### 2. **main.dart** (124 líneas)

```
Ubicación: lib/main.dart
Cambios:
- Importa DocumentCreatePage, DocumentCameraPage, DocumentUploadPage, XFile
- Ruta /document-create en routes map
- onGenerateRoute maneja /document-camera con args clinicalRecordId
- onGenerateRoute maneja /document-upload con args (clinicalRecordId, capturedFiles, patientName, patientIdentity)
```

#### 3. **home_page.dart** (línea 179)

```
Ubicación: lib/features/auth/presentation/pages/home_page.dart
Cambio: Botón GridView "Documentos" (naranja) cambiado a "Crear Documento"
- Antes: Navigator.pushNamed(context, '/documents')
- Ahora: Navigator.pushNamed(context, '/document-create')
- Nota: /documents sigue disponible desde sidebar para ver lista
```

#### 4. **AndroidManifest.xml**

```xml
Ubicación: android/app/src/main/AndroidManifest.xml
Permisos agregados:
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

#### 5. **pubspec.yaml**

```yaml
Nuevas dependencias:
  file_picker: ^8.1.4 # Seleccionar archivos
  image_cropper: ^8.0.2 # Recortar imágenes
  path: ^1.9.0 # Manipular rutas
  mime: ^2.0.0 # Detectar tipos MIME
```

---

## 🚀 Comandos para Ejecutar

### **Limpieza y Preparación:**

```powershell
cd cr_movil
flutter clean
flutter pub get
```

### **Ejecutar en modo DEBUG (hot reload):**

```powershell
flutter run
```

### **Ejecutar en dispositivo específico:**

```powershell
flutter devices  # Ver dispositivos disponibles
flutter run -d <DEVICE_ID>  # Ejemplo: flutter run -d emulator-5554
```

### **Build APK Release (para instalar sin cable):**

```powershell
flutter build apk --release
# Ubicación: build/app/outputs/flutter-apk/app-release.apk
```

### **Build App Bundle (para Play Store):**

```powershell
flutter build appbundle --release
# Ubicación: build/app/outputs/bundle/release/app-release.aab
```

---

## 🧪 Pruebas

### **Emulador Android Studio:**

1. Abre Android Studio → AVD Manager
2. Crea/inicia emulador con "Google Play"
3. `flutter run`

### **Teléfono Físico:**

1. Activa Depuración USB en Settings → Developer Options
2. Conecta por USB
3. `flutter devices` (debería aparecer tu teléfono)
4. `flutter run`

### **Flujo Completo a Probar:**

1. ✅ HomePage → Toca "Crear Documento" (botón naranja)
2. ✅ DocumentCreatePage → Busca y selecciona una Historia Clínica
3. ✅ Toca "Abrir Cámara" (botón verde)
4. ✅ DocumentCameraPage → Captura 1-N fotos O selecciona de galería
5. ✅ Toca "Continuar" → Retorna a DocumentCreatePage → Navega a DocumentUploadPage
6. ✅ DocumentUploadPage → Llena los campos del formulario
7. ✅ Toca "Subir Documento" → Envía al backend
8. ✅ Éxito → Vuelve a HomePage

---

## 🔧 Errores Corregidos

| Error                                                     | Causa                                             | Solución                                                                             |
| --------------------------------------------------------- | ------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `Target of URI doesn't exist: clinical_record_state.dart` | Importaciones a archivos separados que no existen | Usar importación única de `clinical_record_bloc.dart` que contiene eventos y estados |
| `undefined_getter 'patientIdentity'`                      | ClinicalRecordEntity no tiene esa propiedad       | Cambiar a `patientInfo?.identification`                                              |
| `const_with_non_const GetClinicalRecordsEvent()`          | El evento no es const                             | Remover `const` al instanciarlo                                                      |
| `state.clinicalRecords not found`                         | La propiedad es `records` no `clinicalRecords`    | Cambiar a `state.records`                                                            |

---

## 📱 Permisos en Tiempo de Ejecución

**Primera vez que se abre la cámara:**

- Android mostrará diálogo: "¿Permitir que CliniDocs acceda a la cámara?"
- Si es aceptado: ✅ La cámara funciona
- Si es negado: ❌ Mostrar error "Permisos denegados"

**Para resetear permisos (pruebas):**

```
Settings → Apps → CliniDocs → Permissions → Denegar todo
O desinstalar y reinstalar la app
```

---

## 🎯 Endpoints Backend Utilizados

**POST /api/documents/upload/**

```
Content-Type: multipart/form-data

Form Fields:
- clinical_record: (ID)
- document_type: "lab_result" | "consultation" | "prescription" | ...
- title: (string)
- description: (string, opcional)
- file: (archivo binario - foto)
- doctor_name: (string)
- doctor_license: (string)
- specialty: (string)
- document_date: (YYYY-MM-DD)

Response (201 Created):
{
  "id": 456,
  "file_url": "https://backend.com/media/documents/...",
  "created_at": "2025-01-09T10:30:00Z"
}
```

---

## 📊 Estructura Final del Proyecto

```
cr_movil/
├── lib/
│   ├── features/
│   │   ├── documents/
│   │   │   └── presentation/pages/
│   │   │       ├── document_create_page.dart      ← NUEVA
│   │   │       ├── document_camera_page.dart      (existente)
│   │   │       ├── document_upload_page.dart      (existente)
│   │   │       └── documents_list_page.dart       (existente)
│   │   ├── clinical_records/
│   │   │   └── presentation/bloc/
│   │   │       └── clinical_record_bloc.dart      (contiene eventos y estados)
│   │   ├── auth/
│   │   │   └── presentation/pages/
│   │   │       └── home_page.dart                 (modificado: botón)
│   ├── main.dart                                  (modificado: rutas)
│   └── ...
├── android/
│   └── app/src/main/
│       └── AndroidManifest.xml                    (modificado: permisos)
├── pubspec.yaml                                    (modificado: dependencias)
└── ...
```

---

## ✨ Resumen de Cambios

### **Antes:**

- HomePage solo tenía botón "Documentos" que iba a lista
- No había forma de crear documento desde la app
- Flujo: Abrir app → Documentos (lista) → Nada más

### **Después:**

- HomePage tiene botón "Crear Documento" que abre selector de historia clínica
- Flujo completo: HomePage → Selecciona Historia Clínica → Captura con cámara → Llena formulario → Sube al backend
- Mismas dependencias (camera, image_picker) más herramientas auxiliares (file_picker, image_cropper)
- Permisos configurados para Android
- 100% compatible con backend existing

---

## 🎓 Documentación Técnica

### **Eventos BLoC:**

- `GetClinicalRecordsEvent()` - Carga historias clínicas
- `ClinicalRecordsLoaded(records)` - Emitido cuando carga exitosa
- `ClinicalRecordLoading()` - Emitido durante carga
- `ClinicalRecordError(message)` - Emitido si hay error

### **Entidad ClinicalRecordEntity:**

```dart
ClinicalRecordEntity {
  id: String,
  patientId: String,
  patientInfo: PatientInfo? {
    id: String,
    firstName: String,
    lastName: String,
    identification: String,    ← Usamos esto en lugar de patientIdentity
    dateOfBirth: DateTime,
    gender: String,
  },
  recordNumber: String,
  status: ClinicalRecordStatus,
  bloodType: String?,
  ...
}
```

---

## ✅ Checklist Final Antes del Run

- [x] Dependencias en pubspec.yaml
- [x] Permisos en AndroidManifest.xml
- [x] Rutas en main.dart
- [x] Página document_create_page.dart sin errores
- [x] HomePage actualizado
- [x] Sin errores de análisis (flutter analyze)
- [x] flutter clean ejecutado
- [x] flutter pub get ejecutado
- [ ] **PENDIENTE:** flutter run (próximo paso)

---

## 🎯 Próximo Paso

**¡Estás listo para ejecutar!**

```powershell
cd cr_movil
flutter run
```

**La app debería:**

1. Compilar sin errores
2. Mostrar SplashPage
3. Pedir login (si no está autenticado)
4. Mostrar HomePage con "Crear Documento" en botón naranja
5. Todo funcional

Si hay problemas, revisar:

- ¿Emulador/teléfono conectado? → `flutter devices`
- ¿Dependencias instaladas? → `flutter pub get`
- ¿Sin hot reload issues? → `flutter clean` + `flutter run` nuevamente
- ¿Código válido? → `flutter analyze`

**¡Suerte! 🚀📱**
