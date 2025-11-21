# 📷 Configuración Completa - Documentos con Cámara

## ✅ **Cambios Implementados**

### 1. **Nueva Página: DocumentCreatePage**

- **Ubicación:** `lib/features/documents/presentation/pages/document_create_page.dart`
- **Función:** Seleccionar Historia Clínica antes de abrir la cámara
- **Características:**
  - Búsqueda y filtrado de historias clínicas
  - Vista de pacientes con identidad y nombre
  - Botón "Abrir Cámara" que navega a la cámara con el contexto correcto

### 2. **Rutas Actualizadas**

- **main.dart:** Agregada ruta `/document-create`
- **HomePage:** Botón cambiado de "Documentos" a "Crear Documento"
- **Flujo:** HomePage → DocumentCreatePage → DocumentCameraPage → DocumentUploadPage

### 3. **Dependencias Agregadas (pubspec.yaml)**

```yaml
dependencies:
  # Existentes (ya estaban)
  camera: ^0.11.0+2
  image_picker: ^1.1.2
  permission_handler: ^11.3.1

  # NUEVAS (agregadas ahora)
  file_picker: ^8.1.4 # Para seleccionar archivos del sistema
  image_cropper: ^8.0.2 # Para recortar imágenes
  path: ^1.9.0 # Para manipulación de rutas
  mime: ^2.0.0 # Para detectar tipos MIME
```

---

## 🔧 **Permisos Configurados**

### **Android (AndroidManifest.xml)**

Ya configuré los siguientes permisos:

```xml
<!-- Cámara -->
<uses-permission android:name="android.permission.CAMERA" />

<!-- Galería y almacenamiento -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />

<!-- Features opcionales -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
```

**¿Qué significa esto?**

- La app puede usar la cámara del teléfono
- Puede leer imágenes de la galería
- Puede guardar fotos temporalmente
- No falla en dispositivos sin cámara (tablets, emuladores)

### **iOS (Info.plist)**

Si necesitas iOS, debes agregar estas claves en `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>CliniDocs necesita acceso a la cámara para capturar documentos médicos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>CliniDocs necesita acceso a tu galería para seleccionar documentos</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>CliniDocs necesita guardar las fotos capturadas</string>
```

---

## 🚀 **Comandos para Ejecutar**

### **1. Limpiar build anterior**

```powershell
cd cr_movil
flutter clean
```

**¿Qué hace?** Elimina archivos compilados viejos para evitar conflictos.

### **2. Descargar dependencias**

```powershell
flutter pub get
```

**¿Qué hace?** Descarga todas las librerías en pubspec.yaml (camera, image_picker, etc.)

### **3. Ver dispositivos conectados**

```powershell
flutter devices
```

**¿Qué muestra?** Lista de teléfonos conectados por USB, emuladores, etc.

### **4. Ejecutar en modo DEBUG**

```powershell
flutter run
```

**¿Qué hace?** Compila y ejecuta la app en modo desarrollo (hot reload disponible).

### **5. Ejecutar en dispositivo específico**

```powershell
flutter run -d <DEVICE_ID>
```

**Ejemplo:**

```powershell
flutter run -d emulator-5554
flutter run -d SM-G960F  # Samsung físico
```

### **6. Build APK de prueba (RELEASE)**

```powershell
flutter build apk --release
```

**Ubicación:** `build/app/outputs/flutter-apk/app-release.apk`
**¿Cuándo usar?** Para instalar en teléfonos sin cable USB.

### **7. Build App Bundle (para Play Store)**

```powershell
flutter build appbundle --release
```

**Ubicación:** `build/app/outputs/bundle/release/app-release.aab`
**¿Cuándo usar?** Para subir a Google Play Store.

---

## 📱 **Permisos en Tiempo de Ejecución**

### **¿Qué pasará cuando uses la cámara?**

1. La primera vez que toques "Abrir Cámara", Android pedirá:

   - ✅ "Permitir que CliniDocs acceda a la cámara"
   - ✅ "Permitir que CliniDocs acceda a tus fotos"

2. Si niegas los permisos, la app mostrará un mensaje de error.

3. **Para resetear permisos (si quieres probar de nuevo):**
   - Configuración del teléfono → Apps → CliniDocs → Permisos → Denegar todo
   - O desinstalar y reinstalar la app

---

## 🔄 **Flujo Completo de Usuario**

```
1. HomePage
   └── Toca "Crear Documento" (botón naranja)

2. DocumentCreatePage
   └── Busca y selecciona una Historia Clínica
       └── Toca "Abrir Cámara"

3. DocumentCameraPage
   └── Captura 1 o más fotos
   └── O selecciona de la galería
       └── Toca "Continuar"

4. DocumentUploadPage
   └── Llena el formulario:
       - Tipo de documento (Resultado de laboratorio, Receta, etc.)
       - Título
       - Descripción (opcional)
       - Nombre del doctor
       - Licencia del doctor
       - Especialidad
       - Fecha del documento
   └── Toca "Subir Documento"

5. Backend API
   └── POST /api/documents/upload/
   └── multipart/form-data con:
       - clinical_record: ID
       - document_type: "lab_result"
       - title: "Radiografía de tórax"
       - file: imagen.jpg
       - doctor_name, doctor_license, etc.
```

---

## 🧪 **Cómo Probar**

### **Test en Emulador Android Studio:**

1. Abre Android Studio → AVD Manager
2. Crea un emulador con **Google Play** (necesario para camera2 API)
3. Inicia el emulador
4. Ejecuta: `flutter run`
5. En el emulador, usa la cámara virtual (simula fotos)

### **Test en Teléfono Físico:**

1. Activa "Opciones de desarrollador" en tu Android:
   - Configuración → Acerca del teléfono → Toca 7 veces "Número de compilación"
2. Activa "Depuración USB"
3. Conecta el teléfono por USB
4. Ejecuta: `flutter devices` (debería aparecer tu teléfono)
5. Ejecuta: `flutter run`

### **Test de APK Release (sin cable):**

1. Build: `flutter build apk --release`
2. Copia `build/app/outputs/flutter-apk/app-release.apk` a tu teléfono
3. Instala el APK (permite instalación de "Fuentes desconocidas")
4. Abre CliniDocs y prueba la cámara

---

## 🐛 **Solución de Problemas Comunes**

### **Error: "Camera permission denied"**

**Causa:** Permisos no configurados en AndroidManifest.xml
**Solución:** Ya están configurados, pero si persiste:

```powershell
flutter clean
flutter pub get
flutter run
```

### **Error: "No camera found"**

**Causa:** Emulador sin cámara virtual
**Solución:** En AVD Manager → Editar emulador → Advanced Settings → Camera → Habilitar "Webcam" o "Emulated"

### **Error: "Platform exception"**

**Causa:** Plugin de cámara no inicializado
**Solución:**

```powershell
flutter pub cache repair
flutter clean
flutter pub get
```

### **Error: "MissingPluginException"**

**Causa:** Hot reload no carga plugins nativos
**Solución:** Stop la app y ejecuta `flutter run` de nuevo (no hot reload)

### **Fotos salen rotadas o con orientación incorrecta**

**Causa:** EXIF metadata de la cámara
**Solución:** Ya implementado en DocumentCameraPage con `image_picker`

---

## 📊 **Backend API - Endpoint Esperado**

**URL:** `POST /api/documents/upload/`

**Headers:**

```
Authorization: Bearer <TOKEN>
Content-Type: multipart/form-data
```

**Body (FormData):**

```
clinical_record: 123            (ID de la historia clínica)
document_type: "lab_result"     (lab_result, consultation, prescription, etc.)
title: "Radiografía de tórax"
description: "Estudio de control"  (opcional)
file: imagen.jpg                (archivo binario)
doctor_name: "Dr. Juan Pérez"
doctor_license: "12345"
specialty: "Radiología"
document_date: "2025-01-09"
```

**Respuesta exitosa (201 Created):**

```json
{
  "id": 456,
  "clinical_record": 123,
  "document_type": "lab_result",
  "title": "Radiografía de tórax",
  "file_url": "https://backend.com/media/documents/imagen.jpg",
  "created_at": "2025-01-09T10:30:00Z"
}
```

---

## 📝 **Notas Importantes**

1. **Tamaño de Imágenes:**

   - DocumentCameraPage ya comprime las fotos automáticamente
   - Resolución máxima: `ResolutionPreset.high` (~720p)
   - Si necesitas más compresión, edita `document_camera_page.dart` línea ~180

2. **Formatos Soportados:**

   - Imágenes: JPG, PNG, HEIC
   - La app detecta el tipo MIME automáticamente con el paquete `mime`

3. **Cantidad de Fotos:**

   - Puedes capturar múltiples fotos en DocumentCameraPage
   - Pero DocumentUploadPage sube **UNA SOLA** foto por documento
   - Si necesitas múltiples archivos por documento, hay que modificar el backend

4. **Conexión al Backend:**

   - Asegúrate de que `lib/core/constants/api_constants.dart` tenga la URL correcta
   - En desarrollo local: `http://10.0.2.2:8000` (emulador) o `http://192.168.X.X:8000` (teléfono físico)
   - En producción: `https://tu-dominio.com`

5. **Tokens de Autenticación:**
   - El AuthBloc ya maneja el token automáticamente
   - Si ves error 401, revisa que el token esté vigente

---

## ✅ **Checklist Final**

- [x] Dependencias agregadas en pubspec.yaml
- [x] Permisos configurados en AndroidManifest.xml
- [x] DocumentCreatePage creada
- [x] Rutas agregadas en main.dart
- [x] HomePage actualizado con "Crear Documento"
- [ ] Ejecutar `flutter clean` y `flutter pub get`
- [ ] Probar en emulador/teléfono
- [ ] Verificar que el backend esté corriendo
- [ ] Probar captura de foto
- [ ] Probar selección de galería
- [ ] Probar formulario de subida
- [ ] Verificar que el documento aparezca en /documents

---

## 🎯 **Próximos Pasos Opcionales**

1. **Recortar Imágenes:** El paquete `image_cropper` está instalado pero no integrado. Si quieres permitir recortar las fotos antes de subirlas, puedo mostrarte cómo.

2. **Vista Previa:** Agregar una pantalla intermedia entre cámara y formulario para revisar las fotos capturadas.

3. **Múltiples Archivos:** Modificar el backend y frontend para permitir subir varios archivos en un solo documento.

4. **OCR (Reconocimiento de Texto):** Integrar Firebase ML Kit o Tesseract para extraer texto de las fotos (útil para resultados de laboratorio).

---

¡Listo! Todo configurado. Solo ejecuta:

```powershell
cd cr_movil
flutter clean
flutter pub get
flutter run
```

Y prueba el flujo completo desde HomePage → Crear Documento → Selecciona Historia Clínica → Abrir Cámara → Captura Foto → Sube Documento.
