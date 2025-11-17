import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../config/dependency_injection/injection_container.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart' as custom;
import '../../domain/entities/document_entity.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';

class DocumentDetailPage extends StatelessWidget {
  final String documentId;

  const DocumentDetailPage({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DocumentBloc>()..add(LoadDocumentById(documentId)),
      child: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
          if (state is DocumentLoading) {
            return const Scaffold(body: Center(child: LoadingWidget()));
          }

          if (state is DocumentError) {
            return Scaffold(
              appBar: AppBar(title: const Text('Documento')),
              body: Center(
                child: custom.ErrorWidget(
                  message: state.message,
                  onRetry: () {
                    context.read<DocumentBloc>().add(
                      LoadDocumentById(documentId),
                    );
                  },
                ),
              ),
            );
          }

          if (state is DocumentLoaded) {
            final document = state.document;
            return _DocumentDetailView(document: document);
          }

          return Scaffold(
            appBar: AppBar(title: const Text('Documento')),
            body: const Center(child: Text('No se encontró el documento')),
          );
        },
      ),
    );
  }
}

class _DocumentDetailView extends StatefulWidget {
  final DocumentEntity document;

  const _DocumentDetailView({required this.document});

  @override
  State<_DocumentDetailView> createState() => _DocumentDetailViewState();
}

class _DocumentDetailViewState extends State<_DocumentDetailView> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getDocumentTypeLabel(String type) {
    final labels = {
      'consultation': 'Consulta Médica',
      'lab_result': 'Resultado de Laboratorio',
      'imaging_report': 'Informe de Imagen',
      'prescription': 'Receta Médica',
      'surgical_note': 'Nota Quirúrgica',
      'discharge_summary': 'Resumen de Alta',
      'consent_form': 'Consentimiento Informado',
      'progress_note': 'Nota de Evolución',
      'referral': 'Referencia',
    };
    return labels[type] ?? type;
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Documento'),
        content: Text(
          '¿Está seguro de que desea eliminar "${widget.document.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<DocumentBloc>().add(
                DeleteDocument(widget.document.id),
              );
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _downloadDocument(BuildContext context) async {
    if (widget.document.fileUrl == null || widget.document.fileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este documento no tiene archivo para descargar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      // Obtener directorio de descargas
      final directory = await getDownloadsDirectory();
      if (directory == null) {
        throw Exception('No se puede acceder al directorio de descargas');
      }

      final fileName =
          widget.document.fileName ??
          '${widget.document.title.replaceAll(' ', '_')}.pdf';
      final filePath = '${directory.path}/$fileName';

      // Mostrar diálogo de descarga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  'Descargando: $fileName',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Por favor espere...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );

      // Descargar archivo
      final dio = Dio();
      await dio.download(
        widget.document.fileUrl!,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            debugPrint('Descarga: $progress%');
          }
        },
      );

      // Cerrar diálogo de progreso
      Navigator.of(context).pop();

      // Mostrar éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Descargado en: $filePath'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Cerrar diálogo de progreso si está abierto
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Mostrar error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al descargar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documento'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Descargar',
            onPressed: () => _downloadDocument(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Eliminar',
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Header con tipo de documento - MEJORADO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.blue.shade500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getDocumentTypeLabel(widget.document.documentType),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.document.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        widget.document.patientName,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Información del documento
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // PRIMERO: Contenido JSON si existe (CONTENIDO PRINCIPAL)
                  if (widget.document.content != null &&
                      widget.document.content!.isNotEmpty)
                    _ContentCard(
                      title: 'Contenido',
                      content: widget.document.content!,
                      documentType: widget.document.documentType,
                    ),

                  if (widget.document.content != null &&
                      widget.document.content!.isNotEmpty)
                    const SizedBox(height: 24),

                  // Descripción si existe
                  if (widget.document.description != null &&
                      widget.document.description!.isNotEmpty)
                    _InfoCard(
                      title: 'Descripción',
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            widget.document.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),

                  if (widget.document.description != null &&
                      widget.document.description!.isNotEmpty)
                    const SizedBox(height: 16),

                  // OCR información si existe
                  if (widget.document.ocrProcessed)
                    _InfoCard(
                      title: 'Información OCR',
                      children: [
                        _InfoItem(
                          label: 'Estado',
                          value: widget.document.ocrProcessed
                              ? 'Procesado'
                              : 'Pendiente',
                          icon: Icons.check_circle,
                        ),
                        if (widget.document.ocrConfidence != null)
                          _InfoItem(
                            label: 'Confianza',
                            value:
                                '${(widget.document.ocrConfidence! * 100).toStringAsFixed(1)}%',
                            icon: Icons.trending_up,
                          ),
                        if (widget.document.ocrText != null &&
                            widget.document.ocrText!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Texto Extraído',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.document.ocrText!,
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                  if (widget.document.ocrProcessed) const SizedBox(height: 16),

                  // Firma digital si existe
                  if (widget.document.isSigned)
                    _InfoCard(
                      title: 'Firma Digital',
                      children: [
                        _InfoItem(
                          label: 'Firmado por',
                          value: widget.document.signedByName ?? 'Desconocido',
                          icon: Icons.verified_user,
                        ),
                        if (widget.document.signedAt != null)
                          _InfoItem(
                            label: 'Fecha de firma',
                            value: _formatDate(widget.document.signedAt!),
                            icon: Icons.calendar_today,
                          ),
                      ],
                    ),

                  if (widget.document.isSigned) const SizedBox(height: 24),

                  // DESPUÉS: Información general
                  _InfoCard(
                    title: 'Información General',
                    children: [
                      _InfoItem(
                        label: 'Paciente',
                        value: widget.document.patientName,
                        icon: Icons.person,
                      ),
                      _InfoItem(
                        label: 'Doctor',
                        value: widget.document.doctorName ?? 'No especificado',
                        icon: Icons.local_hospital,
                      ),
                      _InfoItem(
                        label: 'Fecha del Documento',
                        value: _formatDate(widget.document.documentDate),
                        icon: Icons.calendar_today,
                      ),
                      _InfoItem(
                        label: 'Creado',
                        value: _formatDate(widget.document.createdAt),
                        icon: Icons.access_time,
                      ),
                      if (widget.document.specialty != null)
                        _InfoItem(
                          label: 'Especialidad',
                          value: widget.document.specialty!,
                          icon: Icons.medical_services,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Información de archivo si existe
                  if (widget.document.fileName != null)
                    _InfoCard(
                      title: 'Información del Archivo',
                      children: [
                        _InfoItem(
                          label: 'Nombre',
                          value: widget.document.fileName!,
                          icon: Icons.description,
                        ),
                        if (widget.document.fileSizeBytes != null)
                          _InfoItem(
                            label: 'Tamaño',
                            value: _formatFileSize(
                              widget.document.fileSizeBytes!,
                            ),
                            icon: Icons.storage,
                          ),
                        if (widget.document.mimeType != null)
                          _InfoItem(
                            label: 'Tipo',
                            value: widget.document.mimeType!,
                            icon: Icons.file_present,
                          ),
                      ],
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final String title;
  final Map<String, dynamic> content;
  final String documentType;

  const _ContentCard({
    required this.title,
    required this.content,
    required this.documentType,
  });

  String _formatKey(String key) {
    // Convierte: chief_complaint → Chief Complaint
    return key
        .split('_')
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join(' ');
  }

  Widget _buildConsultationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Motivo de Consulta
        if (content['chief_complaint'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.indigo.shade50],
                ),
                border: Border(
                  left: BorderSide(color: Colors.blue.shade500, width: 4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Motivo de Consulta',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['chief_complaint'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Historia de Enfermedad Actual
        if (content['history_of_current_illness'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historia de Enfermedad Actual',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content['history_of_current_illness'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

        // Signos Vitales
        if (content['vital_signs'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signos Vitales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                _buildVitalSignsGrid(
                  content['vital_signs'] as Map<String, dynamic>,
                ),
              ],
            ),
          ),

        // Examen Físico
        if (content['physical_exam'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examen Físico',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    content['physical_exam'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Diagnóstico
        if (content['diagnosis'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.cyan.shade100],
                ),
                border: Border(
                  left: BorderSide(color: Colors.blue.shade600, width: 4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnóstico',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['diagnosis'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Plan de Tratamiento
        if (content['treatment_plan'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan de Tratamiento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    content['treatment_plan'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVitalSignsGrid(Map<String, dynamic> vitalSigns) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        if (vitalSigns['blood_pressure'] != null)
          _buildVitalSignCard(
            'Presión Arterial',
            vitalSigns['blood_pressure'] as String,
            'mmHg',
            Colors.green,
          ),
        if (vitalSigns['heart_rate'] != null)
          _buildVitalSignCard(
            'Frecuencia Cardíaca',
            vitalSigns['heart_rate'] as String,
            'lpm',
            Colors.red,
          ),
        if (vitalSigns['temperature'] != null)
          _buildVitalSignCard(
            'Temperatura',
            vitalSigns['temperature'] as String,
            '°C',
            Colors.orange,
          ),
        if (vitalSigns['respiratory_rate'] != null)
          _buildVitalSignCard(
            'Frecuencia Respiratoria',
            vitalSigns['respiratory_rate'] as String,
            'rpm',
            Colors.blue,
          ),
        if (vitalSigns['oxygen_saturation'] != null)
          _buildVitalSignCard(
            'Saturación O₂',
            vitalSigns['oxygen_saturation'] as String,
            '%',
            Colors.indigo,
          ),
      ],
    );
  }

  Widget _buildVitalSignCard(
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: color, width: 4)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre del test
        if (content['test_name'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Examen',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content['test_name'] as String,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

        // Fecha del examen
        if (content['test_date'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha del Examen',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content['test_date'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Resultados en tabla
        if (content['results'] != null &&
            (content['results'] as Map<String, dynamic>).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Resultados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                _buildLabResultsTable(
                  content['results'] as Map<String, dynamic>,
                ),
              ],
            ),
          ),

        // Interpretación
        if (content['interpretation'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.cyan.shade50],
                ),
                border: Border(
                  left: BorderSide(color: Colors.blue.shade600, width: 4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interpretación',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['interpretation'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLabResultsTable(Map<String, dynamic> results) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    child: Text(
                      'PARÁMETRO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'VALOR',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: Text(
                      'UNIDAD',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Text(
                      'REFERENCIA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Rows
            ...results.entries.map((entry) {
              final value = entry.value;
              final valueStr = value is Map
                  ? value['value']?.toString() ?? 'N/A'
                  : value.toString();
              final unitStr = value is Map
                  ? value['unit']?.toString() ?? ''
                  : '';
              final refStr = value is Map
                  ? value['reference']?.toString() ?? ''
                  : '';

              return Container(
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey.shade200)),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        valueStr,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        unitStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: Text(
                        refStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Diagnóstico
        if (content['diagnosis'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.pink.shade50],
                ),
                border: Border(
                  left: BorderSide(color: Colors.purple.shade500, width: 4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diagnóstico',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['diagnosis'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Medicamentos Prescritos
        if (content['medications'] != null &&
            (content['medications'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Medicamentos Prescritos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                ...(content['medications'] as List).map((med) {
                  if (med is! Map<String, dynamic>) return SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            med['name'] ?? 'Medicamento',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 2.5,
                            children: [
                              if (med['dose'] != null)
                                _buildMedAttribute(
                                  'Dosis',
                                  med['dose'] as String,
                                ),
                              if (med['frequency'] != null)
                                _buildMedAttribute(
                                  'Frecuencia',
                                  med['frequency'] as String,
                                ),
                              if (med['duration'] != null)
                                _buildMedAttribute(
                                  'Duración',
                                  med['duration'] as String,
                                ),
                              if (med['via'] != null)
                                _buildMedAttribute('Vía', med['via'] as String),
                            ],
                          ),
                          if (med['instructions'] != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                'Instrucciones: ${med['instructions']}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

        // Instrucciones Generales
        if (content['instructions'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                border: Border(
                  left: BorderSide(color: Colors.yellow.shade600, width: 4),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instrucciones Generales',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content['instructions'] as String,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Duración del tratamiento
        if (content['duration'] != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Duración del tratamiento: ${content['duration']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMedAttribute(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildContentField(String label, dynamic value) {
    if (value == null) return const SizedBox.shrink();

    if (value is List && value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (value is String)
            Text(value, style: const TextStyle(fontSize: 15, height: 1.6))
          else if (value is List)
            ..._buildListContent(value),
          if (value is Map) ..._buildMapContent(value as Map<String, dynamic>),
        ],
      ),
    );
  }

  List<Widget> _buildListContent(List<dynamic> items) {
    return items.map((item) {
      if (item is Map<String, dynamic>) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.entries.map((e) {
                final key = _formatKey(e.key);
                final value = e.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          value.toString(),
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      }
      return Text(item.toString(), style: const TextStyle(fontSize: 15));
    }).toList();
  }

  List<Widget> _buildMapContent(Map<String, dynamic> map) {
    return map.entries.map((e) {
      final key = _formatKey(e.key);
      final value = e.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value.toString(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Si es una consulta o receta, usar los renderizadores especializados
    if (documentType == 'consultation' &&
        content.containsKey('chief_complaint')) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildConsultationContent(),
            ],
          ),
        ),
      );
    }

    if (documentType == 'prescription' && content.containsKey('medications')) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildPrescriptionContent(),
            ],
          ),
        ),
      );
    }

    if (documentType == 'lab_result' && content.containsKey('results')) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              _buildLabResultContent(),
            ],
          ),
        ),
      );
    }

    // Renderizador genérico para otros tipos
    final children = <Widget>[];

    // Orden preferido de campos según tipo de documento
    final List<String> fieldOrder;

    if (documentType == 'consultation') {
      fieldOrder = [
        'chief_complaint',
        'history_of_current_illness',
        'vital_signs',
        'physical_exam',
        'diagnosis',
        'treatment_plan',
        'additional_notes',
      ];
    } else if (documentType == 'prescription') {
      fieldOrder = [
        'diagnosis',
        'medications',
        'instructions',
        'additional_notes',
      ];
    } else {
      fieldOrder = [];
    }

    // Agregar campos en orden preferido
    for (final field in fieldOrder) {
      if (content.containsKey(field)) {
        children.add(_buildContentField(_formatKey(field), content[field]));
      }
    }

    // Agregar campos restantes que no están en el orden preferido
    for (final entry in content.entries) {
      if (!fieldOrder.contains(entry.key)) {
        children.add(_buildContentField(_formatKey(entry.key), entry.value));
      }
    }

    if (children.isEmpty) {
      children.add(
        const Text(
          'No hay contenido adicional disponible',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
