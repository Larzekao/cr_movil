// EJEMPLO DE INTEGRACIÓN - COPIAR Y PEGAR EN patient_detail_page.dart
//
// Este archivo muestra el código exacto que debes agregar a tu
// patient_detail_page.dart para conectar el flujo de cámara + upload
//
// NO INTENTES COMPILAR ESTE ARCHIVO
// SOLO COPIAR LOS MÉTODOS AL patient_detail_page.dart

// ============================================================================
// PASO 1: AGREGAR ESTOS IMPORTS AL INICIO DEL ARCHIVO
// ============================================================================
/*
import 'package:image_picker/image_picker.dart';
import '../pages/document_camera_page.dart';
import '../pages/document_upload_page.dart';
*/

// ============================================================================
// PASO 2: AGREGAR ESTE BOTÓN EN LOS ACTIONS DEL APPBAR
// ============================================================================
/*
AppBar(
  title: const Text('Detalle del Paciente'),
  actions: [
    // Tu botón de editar (ya existe)
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        // ... tu código de editar ...
      },
    ),
    // NUEVO: Botón para subir documentos
    IconButton(
      icon: const Icon(Icons.upload_file),
      tooltip: 'Subir Documentos',
      onPressed: () => _startDocumentUploadFlow(),
    ),
    // Tu botón de eliminar (ya existe)
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () {
        // ... tu código de eliminar ...
      },
    ),
  ],
)
*/

// ============================================================================
// PASO 3: AGREGAR ESTE MÉTODO EN LA CLASE State
// ============================================================================
/*
/// Inicia el flujo completo: Cámara → Upload → Retorno
/// 
/// Flujo:
/// 1. Usuario presiona botón "Subir Documento"
/// 2. Se abre DocumentCameraPage (captura fotos)
/// 3. Usuario retorna con List<XFile>
/// 4. Se abre DocumentUploadPage (formulario)
/// 5. Usuario llena datos y presiona "Subir"
/// 6. DocumentBloc maneja el upload
/// 7. Si es exitoso, vuelve al detalle del paciente
Future<void> _startDocumentUploadFlow() async {
  try {
    // ======= STEP 1: Abrir cámara =======
    final capturedFiles = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentCameraPage(),
      ),
    );

    // Si el usuario canceló en la cámara
    if (capturedFiles == null || capturedFiles.isEmpty) {
      return;
    }

    if (!mounted) return;

    // ======= STEP 2: Abrir pantalla de upload/confirmación =======
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentUploadPage(
          // ⚠️ IMPORTANTE: Pasar el ID de la historia clínica del paciente
          clinicalRecordId: widget.patient.id,
          // Los archivos capturados
          capturedFiles: capturedFiles,
          // Info del paciente para mostrar en la UI
          patientName: widget.patient.fullName,
          patientIdentity: widget.patient.identityDocument,
        ),
      ),
    );

    // ======= STEP 3: Manejar resultado =======
    if (result == true && mounted) {
      // El documento fue subido exitosamente
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Documento(s) subido(s) exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Opcional: Refrescar la lista de documentos del paciente
      // Esto depende de si tienes un BLoC para listar documentos
      // if (mounted) {
      //   context.read<DocumentBloc>().add(
      //     GetPatientDocuments(widget.patient.id),
      //   );
      // }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en el flujo: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
*/

// ============================================================================
// RESUMEN DEL FLUJO DE DATOS
// ============================================================================
/*
┌──────────────────────────────────────────────────────────────────────┐
│ FLUJO COMPLETO DE DATOS Y NAVEGACIÓN                                │
└──────────────────────────────────────────────────────────────────────┘

1. PatientDetailPage (tu pantalla)
   └─ Usuario presiona botón "Subir Documento"
      └─ Llama _startDocumentUploadFlow()
         │
         └─ Navigator.push → DocumentCameraPage
            │  - Sin parámetros
            │  - Retorna: List<XFile> (archivos capturados)
            │
            └─ DocumentCameraPage
               ├─ Muestra cámara en tiempo real
               ├─ Usuario captura fotos
               ├─ Muestra galería de thumbnails
               └─ Presiona "X fotos - Continuar"
                  └─ Navigator.pop(context, capturedFiles)
                     └─ Retorna: List<XFile>
                        │
                        └─ De vuelta en _startDocumentUploadFlow()
                           └─ Navigator.push → DocumentUploadPage
                              │  - Parámetros:
                              │    - clinicalRecordId: "id-del-paciente"
                              │    - capturedFiles: [file1, file2, ...]
                              │    - patientName: "Juan Pérez"
                              │    - patientIdentity: "12345678"
                              │
                              └─ DocumentUploadPage
                                 ├─ Muestra carousel de fotos
                                 ├─ Muestra información del paciente
                                 ├─ Muestra formulario para:
                                 │  - Tipo de documento
                                 │  - Título
                                 │  - Descripción
                                 │  - Especialidad
                                 │  - Doctor
                                 │  - Licencia
                                 ├─ Usuario llena formulario
                                 └─ Usuario presiona "Subir Documentos"
                                    └─ Para cada archivo:
                                       └─ Dispatch UploadDocument event
                                          └─ DocumentBloc
                                             └─ Llama _onUploadDocument()
                                                └─ Crea UploadDocumentParams
                                                   └─ Llama repository.uploadDocument()
                                                      └─ RemoteDataSource
                                                         └─ POST /api/documents/
                                                            ├─ Success
                                                            │  └─ Emite: DocumentUploaded
                                                            │     └─ UI muestra snackbar
                                                            │
                                                            └─ Error
                                                               └─ Emite: DocumentError
                                                                  └─ UI muestra error
                                    └─ Navigator.pop(context, true)
                                       └─ Retorna: bool (true si éxito)
                                          │
                                          └─ De vuelta en _startDocumentUploadFlow()
                                             └─ Muestra snackbar de éxito
                                             └─ Vuelve a PatientDetailPage

PARÁMETROS CLAVE QUE DEBES PASAR:
───────────────────────────────────

clinicalRecordId (OBLIGATORIO)
  ├─ Qué es: El ID único de la historia clínica del paciente
  ├─ Dónde obtenerlo: widget.patient.id
  ├─ Uso: Se envía al backend en cada POST /api/documents/
  └─ Ejemplo: "507f1f77bcf86cd799439011"

patientName (OPCIONAL)
  ├─ Qué es: Nombre completo del paciente
  ├─ Dónde obtenerlo: widget.patient.fullName
  ├─ Uso: Se muestra en la UI de DocumentUploadPage
  └─ Ejemplo: "Juan Pérez García"

patientIdentity (OPCIONAL)
  ├─ Qué es: Número de cédula o DNI
  ├─ Dónde obtenerlo: widget.patient.identityDocument
  ├─ Uso: Se muestra en la UI de DocumentUploadPage
  └─ Ejemplo: "V-12345678"

capturedFiles (OBLIGATORIO)
  ├─ Qué es: Lista de archivos capturados por cámara
  ├─ Dónde obtenerlo: Retorna DocumentCameraPage
  ├─ Uso: Se muestra carousel + se suben al backend
  └─ Tipo: List<XFile>
*/

// ============================================================================
// PREGUNTAS FRECUENTES
// ============================================================================
/*
P: ¿Qué es widget.patient?
R: El objeto PatientEntity que pasaste como parámetro a PatientDetailPage

P: ¿Dónde está patient_detail_page.dart?
R: En lib/features/patients/presentation/pages/patient_detail_page.dart

P: ¿Qué es clinicalRecordId?
R: Es el ID de la historia clínica del paciente. Generalmente es el mismo que patient.id

P: ¿Los campos de doctor y especialidad son obligatorios?
R: No, son opcionales. El usuario puede dejarlos en blanco.

P: ¿Se pueden subir múltiples archivos a la vez?
R: Sí. DocumentUploadPage soporta múltiples archivos. 
   El título se auto-genera como "Título - Parte 1", "Título - Parte 2", etc.

P: ¿Qué pasa si la subida falla?
R: Se muestra un snackbar rojo con el mensaje de error.
   El usuario puede intentar nuevamente.

P: ¿Cómo refrescar la lista de documentos después de subir?
R: Agregar esto después de "result == true && mounted":
   context.read<DocumentBloc>().add(GetPatientDocuments(widget.patient.id));
   (Aunque necesitas haber creado ese evento en document_bloc.dart)

P: ¿El archivo INTEGRATION_EXAMPLE.dart se compila?
R: No. Es solo referencia. Copia el código a patient_detail_page.dart.
*/
