/// EJEMPLO DE USO: DocumentBloc - Subida de Documentos
///
/// Este archivo muestra cómo usar el DocumentBloc desde una página/widget
/// para capturar y subir documentos clínicos.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'presentation/bloc/document_bloc.dart';
import 'presentation/bloc/document_event.dart';
import 'presentation/bloc/document_state.dart';

/// ==============================================================================
/// EJEMPLO 1: Usando BlocListener para reaccionar a cambios de estado
/// ==============================================================================

class DocumentUploadPageExample extends StatefulWidget {
  final String clinicalRecordId;

  const DocumentUploadPageExample({required this.clinicalRecordId});

  @override
  State<DocumentUploadPageExample> createState() =>
      _DocumentUploadPageExampleState();
}

class _DocumentUploadPageExampleState extends State<DocumentUploadPageExample> {
  XFile? selectedFile;
  final ImagePicker _picker = ImagePicker();

  /// Capturar foto desde cámara
  Future<void> _takePicture() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, // Comprimir un poco para acelerar upload
    );

    if (photo != null) {
      setState(() => selectedFile = photo);
    }
  }

  /// Seleccionar archivo desde galería
  Future<void> _pickFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => selectedFile = file);
    }
  }

  /// Iniciar upload del documento
  void _uploadDocument() {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un archivo primero')),
      );
      return;
    }

    // Disparar evento UploadDocument en el BLoC
    context.read<DocumentBloc>().add(
      UploadDocument(
        clinicalRecordId: widget.clinicalRecordId,
        documentType:
            'lab_result', // Tipos: 'lab_result', 'imaging_report', 'prescription', etc.
        title: 'Resultado de Laboratorio',
        documentDate: DateTime.now(),
        filePath: selectedFile!.path, // Ruta del archivo capturado
        description: 'Análisis de sangre - Clínica Central',
        specialty: 'Laboratorio',
        doctorName: 'Dr. Juan Pérez',
        doctorLicense: 'LIC-12345',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Documento')),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          // Escuchar cambios de estado
          if (state is DocumentUploaded) {
            // ✅ Éxito: Documento subido
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Documento subido: ${state.document.title}'),
                backgroundColor: Colors.green,
              ),
            );

            // Opcional: Limpiar y volver
            Future.delayed(const Duration(seconds: 1), () {
              context.read<DocumentBloc>().add(const DocumentUploadReset());
              Navigator.pop(context);
            });
          } else if (state is DocumentError) {
            // ❌ Error: Mostrar mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DocumentBloc, DocumentState>(
          builder: (context, state) {
            // UI reactiva según el estado
            if (state is DocumentLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DocumentUploadInProgress) {
              // Mostrar progreso de upload (0.0 - 1.0)
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(value: state.progress),
                    const SizedBox(height: 20),
                    Text(
                      '${(state.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            // Estado normal: mostrar opciones de carga
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Seleccionar Documento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  if (selectedFile != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Archivo seleccionado:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(selectedFile!.name),
                          const SizedBox(height: 8),
                          Text(
                            'Tamaño: ${(selectedFile!.path.length / 1024).toStringAsFixed(2)} KB',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Tomar Foto'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar de Galería'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: selectedFile != null ? _uploadDocument : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Subir Documento'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() => selectedFile = null);
                    },
                    child: const Text('Limpiar Selección'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ==============================================================================
/// EJEMPLO 2: Usando BlocBuilder solo para UI sin listener
/// ==============================================================================

class DocumentUploadSimpleExample extends StatefulWidget {
  final String clinicalRecordId;

  const DocumentUploadSimpleExample({required this.clinicalRecordId});

  @override
  State<DocumentUploadSimpleExample> createState() =>
      _DocumentUploadSimpleExampleState();
}

class _DocumentUploadSimpleExampleState
    extends State<DocumentUploadSimpleExample> {
  XFile? selectedFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickAndUpload() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo == null) return;

    if (!mounted) return;

    // Disparar upload directamente
    context.read<DocumentBloc>().add(
      UploadDocument(
        clinicalRecordId: widget.clinicalRecordId,
        documentType: 'imaging_report',
        title: 'Reporte de Imagen',
        documentDate: DateTime.now(),
        filePath: photo.path,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        // Manejo simple de estados
        if (state is DocumentLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DocumentUploaded) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text('Documento subido: ${state.document.title}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DocumentBloc>().add(
                      const DocumentUploadReset(),
                    );
                  },
                  child: const Text('Subir Otro'),
                ),
              ],
            ),
          );
        }

        if (state is DocumentError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text('Error: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<DocumentBloc>().add(
                      const DocumentUploadReset(),
                    );
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        // Estado inicial
        return Center(
          child: ElevatedButton(
            onPressed: _pickAndUpload,
            child: const Text('Capturar y Subir Documento'),
          ),
        );
      },
    );
  }
}

/// ==============================================================================
/// EJEMPLO 3: Usando BlocConsumer (combina listener + builder)
/// ==============================================================================

class DocumentUploadConsumerExample extends StatefulWidget {
  final String clinicalRecordId;

  const DocumentUploadConsumerExample({required this.clinicalRecordId});

  @override
  State<DocumentUploadConsumerExample> createState() =>
      _DocumentUploadConsumerExampleState();
}

class _DocumentUploadConsumerExampleState
    extends State<DocumentUploadConsumerExample> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureAndUpload() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);

    if (photo != null && mounted) {
      context.read<DocumentBloc>().add(
        UploadDocument(
          clinicalRecordId: widget.clinicalRecordId,
          documentType: 'lab_result',
          title: 'Análisis de Laboratorio',
          documentDate: DateTime.now(),
          filePath: photo.path,
          description: 'Capturado desde móvil',
          specialty: 'Laboratorio Clínico',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DocumentBloc, DocumentState>(
      // Escuchar cambios y reaccionar
      listener: (context, state) {
        if (state is DocumentUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Documento subido exitosamente!')),
          );
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      // Construir UI según estado
      builder: (context, state) {
        if (state is DocumentLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DocumentUploadInProgress) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(value: state.progress),
                  const SizedBox(height: 16),
                  Text('${(state.progress * 100).toInt()}% completado'),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Subir Documento')),
          body: Center(
            child: ElevatedButton(
              onPressed: _captureAndUpload,
              child: const Text('Capturar Documento'),
            ),
          ),
        );
      },
    );
  }
}

/// ==============================================================================
/// CÓMO INTEGRAR EN LA APLICACIÓN
/// ==============================================================================

/// 1. En main.dart o en tu widget de configuración:
/*
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => getIt<DocumentBloc>(),  // Inyectar desde GetIt
        child: const DocumentUploadPageExample(
          clinicalRecordId: 'patient-123-record-id',
        ),
      ),
    );
  }
*/

/// 2. O usa MultiBlocProvider si tienes varios BLoCs:
/*
  MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => getIt<AuthBloc>()),
      BlocProvider(create: (_) => getIt<DocumentBloc>()),
      BlocProvider(create: (_) => getIt<PatientBloc>()),
    ],
    child: MyApp(),
  )
*/

/// 3. En tu archivo de inyección de dependencias (injection_container.dart):
/*
  @lazySingleton
  DocumentBloc get documentBloc => DocumentBloc(
    getDocumentsUseCase: getIt(),
    createDocumentUseCase: getIt(),
    updateDocumentUseCase: getIt(),
    deleteDocumentUseCase: getIt(),
    uploadDocumentUseCase: getIt(),
  );
*/
