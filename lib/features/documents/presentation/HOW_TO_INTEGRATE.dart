import 'package:flutter/material.dart';

/// EJEMPLO SIMPLIFICADO DE CÓMO INTEGRAR EN patient_detail_page.dart
/// 
/// Este archivo muestra exactamente dónde agregar el código en tu
/// patient_detail_page.dart existente.
///
/// PASOS:
/// 1. Copia los imports de abajo
/// 2. Agrega el botón en AppBar.actions
/// 3. Copia el método _startDocumentUploadFlow() al State
/// 4. Listo!

// ============================================================================
// PASO 1: AGREGAR ESTOS IMPORTS AL INICIO
// ============================================================================

/*
// Agregar al inicio de patient_detail_page.dart:

import 'package:image_picker/image_picker.dart';
import '../bloc/document_bloc.dart';
import '../pages/document_camera_page.dart';
import '../pages/document_upload_page.dart';
*/

// ============================================================================
// PASO 2: AGREGAR BOTÓN EN AppBar.actions
// ============================================================================

/*
// En tu PatientDetailPage build() method, modifica AppBar así:

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Detalle del Paciente'),
      elevation: 0,
      actions: [
        // Tu botón de editar (si existe)
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Tu código de editar
          },
        ),
        
        // ✅ NUEVO: Botón para subir documentos
        IconButton(
          icon: const Icon(Icons.upload_file),
          tooltip: 'Subir Documentos',
          onPressed: () => _startDocumentUploadFlow(),
        ),
        
        // Tu botón de eliminar (si existe)
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Tu código de eliminar
          },
        ),
      ],
    ),
    body: // ... tu código existente
  );
}
*/

// ============================================================================
// PASO 3: AGREGAR ESTE MÉTODO AL STATE
// ============================================================================

/*
// Agrega este método completo a la clase _PatientDetailPageState:

/// Inicia el flujo completo: Cámara → Confirmación → Upload
Future<void> _startDocumentUploadFlow() async {
  try {
    // STEP 1: Abrir cámara y capturar fotos
    final capturedFiles = await Navigator.push<List<XFile>>(
      context,
      MaterialPageRoute(
        builder: (context) => const DocumentCameraPage(),
      ),
    );

    // Si el usuario canceló en la cámara
    if (capturedFiles == null || capturedFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se capturaron documentos'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    // STEP 2: Abrir pantalla de confirmación y upload
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentUploadPage(
          // ⚠️ IMPORTANTE: El ID de la historia clínica
          clinicalRecordId: widget.patient.id,
          // Los archivos capturados
          capturedFiles: capturedFiles,
          // Info del paciente (para mostrar en UI)
          patientName: widget.patient.fullName,
          patientIdentity: widget.patient.identityDocument,
        ),
      ),
    );

    // STEP 3: Manejar el resultado
    if (result == true && mounted) {
      // Éxito: mostrar mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Documento(s) subido(s) exitosamente'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      // Opcional: Refrescar lista de documentos
      // if (mounted) {
      //   context.read<DocumentBloc>().add(
      //     GetDocuments(widget.patient.id),
      //   );
      // }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
*/

// ============================================================================
// ¡ESO ES TODO! 
// ============================================================================
// 
// Con esos 3 pasos, ya tendrás el flujo completo funcionando:
// 
// 1. Usuario presiona botón de cámara
// 2. Se abre DocumentCameraPage
// 3. Captura fotos y presiona "Continuar"
// 4. Se abre DocumentUploadPage
// 5. Llena el formulario y presiona "Subir Documentos"
// 6. Los archivos se suben al backend
// 7. Vuelve al detalle del paciente
//
// Tiempo total: ~5 minutos
// Complejidad: Copiar y pegar
//
