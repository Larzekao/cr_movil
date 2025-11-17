/// GUÍA DE NAVEGACIÓN: Pantallas de Documentos
///
/// Este archivo muestra cómo navegar entre:
/// 1. DocumentCameraPage - Capturar fotos
/// 2. DocumentConfirmationPage - Completar metadata y subir
/// 3. Pantalla anterior (ej: lista de documentos)

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'presentation/pages/document_camera_page.dart';
import 'presentation/pages/document_confirmation_page.dart';

/// ==============================================================================
/// OPCIÓN 1: Navegación con Navigator (más control)
/// ==============================================================================

class DocumentManagementExample {
  /// Navegar a la pantalla de cámara y esperar archivos capturados
  static Future<void> openCameraAndUpload(
    BuildContext context, {
    required String clinicalRecordId,
  }) async {
    // Ir a DocumentCameraPage y esperar que retorne List<XFile>
    final List<XFile>? capturedFiles = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentCameraPage(clinicalRecordId: clinicalRecordId),
      ),
    );

    // Si el usuario capturó archivos
    if (capturedFiles != null && capturedFiles.isNotEmpty) {
      // Ir a la pantalla de confirmación
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DocumentConfirmationPage(
              clinicalRecordId: clinicalRecordId,
              capturedFiles: capturedFiles,
            ),
          ),
        );
      }
    }
  }

  /// Navegar directamente a confirmación (si ya tienes archivos)
  static Future<void> openConfirmation(
    BuildContext context, {
    required String clinicalRecordId,
    required List<XFile> files,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentConfirmationPage(
          clinicalRecordId: clinicalRecordId,
          capturedFiles: files,
        ),
      ),
    );
  }
}

/// ==============================================================================
/// OPCIÓN 2: Usar GoRouter (si tienes configurado en el proyecto)
/// ==============================================================================

/*
// En tu config de GoRouter (main.dart o router.dart):

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/documents/camera/:recordId',
      name: 'camera',
      builder: (context, state) => DocumentCameraPage(
        clinicalRecordId: state.pathParameters['recordId'],
      ),
    ),
    GoRoute(
      path: '/documents/confirm/:recordId',
      name: 'confirm',
      builder: (context, state) {
        final files = state.extra as List<XFile>?;
        return DocumentConfirmationPage(
          clinicalRecordId: state.pathParameters['recordId']!,
          capturedFiles: files ?? [],
        );
      },
    ),
  ],
);

// Uso desde cualquier página:
context.goNamed(
  'camera',
  pathParameters: {'recordId': patientRecord.id},
);

// Y en DocumentCameraPage, al finalizar:
context.goNamed(
  'confirm',
  pathParameters: {'recordId': widget.clinicalRecordId},
  extra: capturedFiles,
);
*/

/// ==============================================================================
/// EJEMPLO COMPLETO: Botón en una pantalla de paciente
/// ==============================================================================

class PatientDetailPageExample extends StatelessWidget {
  final String clinicalRecordId;

  const PatientDetailPageExample({required this.clinicalRecordId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Paciente')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Información del Paciente'),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Opción 1: Usar el método helper
                DocumentManagementExample.openCameraAndUpload(
                  context,
                  clinicalRecordId: clinicalRecordId,
                );

                // Opción 2: Manual con Navigator.push
                // _navigateToCamera(context);

                // Opción 3: Si usas GoRouter
                // context.goNamed('camera', pathParameters: {'recordId': clinicalRecordId});
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Subir Documento'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Método alternativo sin helper class
  Future<void> _navigateToCamera(BuildContext context) async {
    final List<XFile>? capturedFiles = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentCameraPage(clinicalRecordId: clinicalRecordId),
      ),
    );

    if (capturedFiles != null && capturedFiles.isNotEmpty && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentConfirmationPage(
            clinicalRecordId: clinicalRecordId,
            capturedFiles: capturedFiles,
          ),
        ),
      );
    }
  }
}

/// ==============================================================================
/// FLUJO COMPLETO DE NAVEGACIÓN
/// ==============================================================================

/*
1. PANTALLA DE DETALLE DE PACIENTE (ej: clinical_records_detail_page.dart)
   └─ Usuario toca botón "Subir Documento"
      
      └─ PANTALLA DE CÁMARA (DocumentCameraPage)
         └─ Usuario captura 1+ fotos
         └─ Usuario toca "X fotos - Continuar"
         └─ Retorna List<XFile> a través de Navigator.pop(context, files)
         
            └─ PANTALLA DE CONFIRMACIÓN (DocumentConfirmationPage)
               └─ Usuario ve previsualizaciones de fotos
               └─ Completa formulario (tipo, título, doctor, etc.)
               └─ Usuario toca "Subir Documentos"
               
                  └─ BLoC: DocumentBloc recibe evento UploadDocument
                  └─ UseCase: llama a UploadDocumentUseCase
                  └─ Repository + DataSource: POST /api/documents/
                  └─ Backend: almacena en S3
                  
                     └─ Si éxito: DocumentUploaded state
                     └─ Si error: DocumentError state
                     
                        └─ UI muestra confirmación o error
                        └─ Usuario puede volver o subir más

2. FLUJO DE RETORNO DE DATOS

   DocumentCameraPage
   │
   ├─ Captura N fotos → List<XFile>
   │
   └─ Navigator.pop(context, capturedFiles)
      │
      ├─ Retorna a PatientDetailPageExample
      │
      └─ DocumentManagementExample.openCameraAndUpload()
         │
         └─ Navigator.push(DocumentConfirmationPage)
            │
            ├─ Recibe List<XFile>
            │
            └─ Subida a través de DocumentBloc
*/

/// ==============================================================================
/// CÓMO OBTENER DATOS RETORNADOS
/// ==============================================================================

class ExampleGettingReturnedData {
  /// Ejemplo 1: Obtener archivos de la cámara
  Future<void> getFilesFromCamera(BuildContext context) async {
    final List<XFile>? files = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentCameraPage(clinicalRecordId: 'some-record-id'),
      ),
    );

    if (files != null) {
      print('Archivos capturados: ${files.length}');
      for (var file in files) {
        print('Archivo: ${file.name}, Tamaño: ${file.path}');
      }
    } else {
      print('Usuario canceló');
    }
  }

  /// Ejemplo 2: Manejo con try-catch
  Future<void> getFilesWithErrorHandling(BuildContext context) async {
    try {
      final List<XFile>? files = await Navigator.push<List<XFile>>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DocumentCameraPage(clinicalRecordId: 'some-record-id'),
        ),
      );

      if (files == null) {
        print('Usuario canceló la captura');
        return;
      }

      if (files.isEmpty) {
        print('No hay archivos capturados');
        return;
      }

      print('Listo para confirmar ${files.length} documentos');
    } catch (e) {
      print('Error: $e');
    }
  }

  /// Ejemplo 3: Verificar si el contexto sigue siendo válido
  Future<void> getFilesWithMountedCheck(BuildContext context) async {
    final List<XFile>? files = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentCameraPage(clinicalRecordId: 'some-record-id'),
      ),
    );

    // Verificar que el widget sigue en el árbol (mounted)
    if (!context.mounted) return;

    if (files != null && files.isNotEmpty) {
      print('Proceeding with ${files.length} files');
    }
  }
}

/// ==============================================================================
/// PERMISOS REQUERIDOS (AndroidManifest.xml y Info.plist)
/// ==============================================================================

/*
ANDROID (android/app/src/main/AndroidManifest.xml):
────────────────────────────────────────────────
<manifest>
  <uses-permission android:name="android.permission.CAMERA" />
  <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
  <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
  
  <application>
    ...
  </application>
</manifest>

iOS (ios/Runner/Info.plist):
─────────────────────────────
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para capturar documentos médicos</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a la galería para seleccionar documentos</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>Necesitamos guardar fotos capturadas</string>
*/

/// ==============================================================================
/// RESUMEN DE FLUJO CON CÓDIGO
/// ==============================================================================

class CompleteWorkflowExample {
  /// Flujo completo en una sola función
  static Future<void> completeDocumentUploadFlow(
    BuildContext context, {
    required String clinicalRecordId,
  }) async {
    // 1. Abrir cámara
    final List<XFile>? files = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DocumentCameraPage(clinicalRecordId: clinicalRecordId),
      ),
    );

    // 2. Validar retorno
    if (files == null || files.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se capturaron documentos')),
        );
      }
      return;
    }

    // 3. Abrir confirmación
    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DocumentConfirmationPage(
            clinicalRecordId: clinicalRecordId,
            capturedFiles: files,
          ),
        ),
      );
    }

    // 4. Al volver de confirmación, el BLoC habrá manejado la subida
    // Los estados DocumentLoading, DocumentUploaded, DocumentError
    // están siendo escuchados en DocumentConfirmationPage
  }
}
