import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';

/// Pantalla de carga/subida de documentos
///
/// Recibe:
/// - clinicalRecordId: ID de la historia clínica
/// - capturedFiles: Lista de archivos capturados
/// - patientName: Nombre del paciente (opcional, para mostrar)
/// - patientIdentity: Cédula/DNI del paciente (opcional)
class DocumentUploadPage extends StatefulWidget {
  final String clinicalRecordId;
  final List<XFile> capturedFiles;
  final String? patientName;
  final String? patientIdentity;

  const DocumentUploadPage({
    required this.clinicalRecordId,
    required this.capturedFiles,
    this.patientName,
    this.patientIdentity,
  });

  @override
  State<DocumentUploadPage> createState() => _DocumentUploadPageState();
}

class _DocumentUploadPageState extends State<DocumentUploadPage> {
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
    {'value': 'lab_result', 'label': 'Resultado Laboratorio'},
    {'value': 'imaging_report', 'label': 'Informe de Imagen'},
    {'value': 'prescription', 'label': 'Receta Médica'},
    {'value': 'surgical_note', 'label': 'Nota Quirúrgica'},
    {'value': 'discharge_summary', 'label': 'Resumen Alta'},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Generar título por defecto
    _titleController.text =
        '${_getDocumentTypeLabel(_selectedDocumentType)} - ${DateTime.now().day}/${DateTime.now().month}';
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

  /// Obtener etiqueta del tipo de documento
  String _getDocumentTypeLabel(String value) {
    final type = documentTypes.firstWhere(
      (t) => t['value'] == value,
      orElse: () => {'label': 'Documento'},
    );
    return type['label'] ?? 'Documento';
  }

  /// Cambiar tipo de documento
  void _onDocumentTypeChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedDocumentType = value;
        // Actualizar título con nuevo tipo
        _titleController.text =
            '${_getDocumentTypeLabel(value)} - ${DateTime.now().day}/${DateTime.now().month}';
      });
    }
  }

  /// Validar y subir documentos
  void _uploadDocuments() {
    // Validaciones
    if (widget.capturedFiles.isEmpty) {
      _showErrorSnackBar('No hay archivos para subir');
      return;
    }

    if (_titleController.text.isEmpty) {
      _showErrorSnackBar('Ingresa un título para el documento');
      return;
    }

    // Mostrar diálogo de confirmación
    _showUploadConfirmation();
  }

  /// Mostrar diálogo de confirmación antes de subir
  void _showUploadConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Subida'),
        content: Text(
          'Se subirán ${widget.capturedFiles.length} archivo(s).\n\n'
          'Tipo: ${_getDocumentTypeLabel(_selectedDocumentType)}\n'
          'Título: ${_titleController.text}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cerrar diálogo
              _proceedWithUpload();
            },
            child: const Text('Confirmar Subida'),
          ),
        ],
      ),
    );
  }

  /// Proceder con la subida real
  void _proceedWithUpload() {
    // Subir cada archivo como un documento separado
    for (int i = 0; i < widget.capturedFiles.length; i++) {
      final file = widget.capturedFiles[i];

      // Crear título único para múltiples archivos
      final docTitle = widget.capturedFiles.length > 1
          ? '${_titleController.text} (Parte ${i + 1})'
          : _titleController.text;

      // Disparar evento UploadDocument al BLoC
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

  /// Mostrar error en snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subir Documentos'), elevation: 0),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentUploaded) {
            _showSuccessSnackBar(
              'Documento: ${state.document.title} subido exitosamente',
            );

            // Si fue el último archivo, volver a la pantalla anterior
            if (widget.capturedFiles.length == 1) {
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pop(context, true);
                }
              });
            }
          } else if (state is DocumentError) {
            _showErrorSnackBar('Error: ${state.message}');
          }
        },
        child: BlocBuilder<DocumentBloc, DocumentState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // ========== INFORMACIÓN DEL PACIENTE ==========
                  if (widget.patientName != null ||
                      widget.patientIdentity != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: AppColors.primaryLight.withOpacity(0.1),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                widget.patientName?.isNotEmpty == true
                                    ? widget.patientName![0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.patientName != null)
                                  Text(
                                    widget.patientName!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                if (widget.patientIdentity != null)
                                  Text(
                                    'CI: ${widget.patientIdentity}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ========== GALERÍA DE FOTOS ==========
                  Container(
                    color: AppColors.surfaceVariant,
                    height: 280,
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

                        // Indicador de página
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
                          'Tipo de Documento *',
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
                            onChanged: _onDocumentTypeChanged,
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
                          label: 'Título del Documento',
                          hint: 'Ej: Resultado de Laboratorio',
                          controller: _titleController,
                          prefixIcon: Icons.title,
                        ),
                        const SizedBox(height: 20),

                        // Descripción
                        const Text(
                          'Descripción (Opcional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Descripción',
                          hint: 'Detalles adicionales del documento...',
                          controller: _descriptionController,
                          prefixIcon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),

                        // Especialidad
                        const Text(
                          'Especialidad (Opcional)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          label: 'Especialidad',
                          hint: 'Ej: Cardiología, Laboratorio',
                          controller: _specialtyController,
                          prefixIcon: Icons.local_hospital,
                        ),
                        const SizedBox(height: 20),

                        // Nombre del médico
                        const Text(
                          'Nombre del Médico (Opcional)',
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
                          'Licencia del Médico (Opcional)',
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

                        // ========== ESTADO Y BOTONES ==========
                        if (state is DocumentLoading)
                          const Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text('Inicializando subida...'),
                              ],
                            ),
                          )
                        else if (state is DocumentUploadInProgress)
                          Column(
                            children: [
                              LinearProgressIndicator(value: state.progress),
                              const SizedBox(height: 12),
                              Text(
                                'Subiendo: ${(state.progress * 100).toInt()}%',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: null, // Deshabilitado durante subida
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.textDisabled,
                                ),
                                child: const Text('Subiendo...'),
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
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                  ),
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

  /// Mostrar éxito en snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.success),
    );
  }
}
