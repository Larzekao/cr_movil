import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';

/// Pantalla de confirmación y metadata de documentos
///
/// Permite al usuario:
/// - Ver preview de fotos capturadas
/// - Completar información del documento (tipo, descripción, doctor, etc.)
/// - Iniciar subida de documentos
class DocumentConfirmationPage extends StatefulWidget {
  final String clinicalRecordId;
  final List<XFile> capturedFiles;

  const DocumentConfirmationPage({
    required this.clinicalRecordId,
    required this.capturedFiles,
  });

  @override
  State<DocumentConfirmationPage> createState() =>
      _DocumentConfirmationPageState();
}

class _DocumentConfirmationPageState extends State<DocumentConfirmationPage> {
  late PageController _pageController;
  int _currentPhotoIndex = 0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _doctorNameController = TextEditingController();
  final TextEditingController _doctorLicenseController =
      TextEditingController();
  final TextEditingController _specialtyController = TextEditingController();

  String _selectedDocumentType = 'lab_result';

  final List<Map<String, String>> documentTypes = [
    {'value': 'consultation', 'label': 'Consulta Médica'},
    {'value': 'lab_result', 'label': 'Resultado Lab'},
    {'value': 'imaging_report', 'label': 'Informe Imagen'},
    {'value': 'prescription', 'label': 'Receta Médica'},
    {'value': 'surgical_note', 'label': 'Nota Quirúrgica'},
    {'value': 'discharge_summary', 'label': 'Resumen Alta'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _titleController.text =
        'Documento ${DateTime.now().day}/${DateTime.now().month}';
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _doctorNameController.dispose();
    _doctorLicenseController.dispose();
    _specialtyController.dispose();
    super.dispose();
  }

  /// Subir todos los documentos capturados
  void _uploadDocuments() {
    // Validar que hay título
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un título para el documento')),
      );
      return;
    }

    // Subir cada foto como un documento separado
    for (int i = 0; i < widget.capturedFiles.length; i++) {
      final file = widget.capturedFiles[i];

      // Crear título único para cada foto si hay múltiples
      final docTitle = widget.capturedFiles.length > 1
          ? '${_titleController.text} - Parte ${i + 1}'
          : _titleController.text;

      // Disparar evento de upload
      context.read<DocumentBloc>().add(
        UploadDocument(
          clinicalRecordId: widget.clinicalRecordId,
          documentType: _selectedDocumentType,
          title: docTitle,
          documentDate: DateTime.now(),
          filePath: file.path,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          specialty: _specialtyController.text.isNotEmpty
              ? _specialtyController.text
              : null,
          doctorName: _doctorNameController.text.isNotEmpty
              ? _doctorNameController.text
              : null,
          doctorLicense: _doctorLicenseController.text.isNotEmpty
              ? _doctorLicenseController.text
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar Documentos'), elevation: 0),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Documento: ${state.document.title} subido'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DocumentError) {
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
            return SingleChildScrollView(
              child: Column(
                children: [
                  // ========== GALERÍA DE FOTOS ==========
                  Container(
                    color: AppColors.surfaceVariant,
                    height: 300,
                    child: Stack(
                      children: [
                        // Carousel de fotos
                        PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() => _currentPhotoIndex = index);
                          },
                          itemCount: widget.capturedFiles.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.black,
                              child: Image.file(
                                File(widget.capturedFiles[index].path),
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),

                        // Indicadores de página
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_currentPhotoIndex + 1}/${widget.capturedFiles.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Botón para retomar fotos
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warning,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ========== FORMULARIO ==========
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tipo de documento
                        const Text(
                          'Tipo de Documento',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedDocumentType,
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: documentTypes.map((type) {
                              return DropdownMenuItem<String>(
                                value: type['value'],
                                child: Text(type['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedDocumentType = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Título
                        const Text(
                          'Título del Documento *',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Título',
                          hint: 'Ej: Análisis de Sangre',
                          controller: _titleController,
                          prefixIcon: Icons.title,
                        ),
                        const SizedBox(height: 20),

                        // Descripción
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Descripción',
                          hint: 'Detalles adicionales...',
                          controller: _descriptionController,
                          prefixIcon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Especialidad
                        const Text(
                          'Especialidad',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Especialidad',
                          hint: 'Ej: Cardiología',
                          controller: _specialtyController,
                          prefixIcon: Icons.local_hospital,
                        ),
                        const SizedBox(height: 20),

                        // Nombre del médico
                        const Text(
                          'Nombre del Médico',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Nombre del Médico',
                          hint: 'Ej: Dr. Juan Pérez',
                          controller: _doctorNameController,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: 20),

                        // Licencia del médico
                        const Text(
                          'Licencia del Médico',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Licencia del Médico',
                          hint: 'Ej: LIC-12345',
                          controller: _doctorLicenseController,
                          prefixIcon: Icons.badge,
                        ),
                        const SizedBox(height: 32),

                        // Botones de acción
                        if (state is DocumentLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (state is DocumentUploadInProgress)
                          Column(
                            children: [
                              LinearProgressIndicator(value: state.progress),
                              const SizedBox(height: 8),
                              Text(
                                '${(state.progress * 100).toInt()}% completado',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        else ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _uploadDocuments,
                                  child: const Text('Subir Documentos'),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                      ],
                    ),
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
