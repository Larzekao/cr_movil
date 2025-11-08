import 'package:equatable/equatable.dart';

/// Entidad de Documento Clínico
class DocumentEntity extends Equatable {
  final String id;
  final String clinicalRecordId;
  final String patientName;
  final String documentType;
  final String title;
  final String? description;
  final DateTime documentDate;
  final String? specialty;
  final String? doctorName;
  final String? doctorLicense;
  final Map<String, dynamic>? content;
  final String? filePath;
  final String? fileName;
  final int? fileSizeBytes;
  final String? mimeType;
  final String? fileUrl;
  final String? ocrText;
  final double? ocrConfidence;
  final bool ocrProcessed;
  final bool isSigned;
  final DateTime? signedAt;
  final String? signedByName;
  final bool isLocked;
  final List<String> tags;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentEntity({
    required this.id,
    required this.clinicalRecordId,
    required this.patientName,
    required this.documentType,
    required this.title,
    this.description,
    required this.documentDate,
    this.specialty,
    this.doctorName,
    this.doctorLicense,
    this.content,
    this.filePath,
    this.fileName,
    this.fileSizeBytes,
    this.mimeType,
    this.fileUrl,
    this.ocrText,
    this.ocrConfidence,
    this.ocrProcessed = false,
    this.isSigned = false,
    this.signedAt,
    this.signedByName,
    this.isLocked = false,
    this.tags = const [],
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    clinicalRecordId,
    patientName,
    documentType,
    title,
    description,
    documentDate,
    specialty,
    doctorName,
    doctorLicense,
    content,
    filePath,
    fileName,
    fileSizeBytes,
    mimeType,
    fileUrl,
    ocrText,
    ocrConfidence,
    ocrProcessed,
    isSigned,
    signedAt,
    signedByName,
    isLocked,
    tags,
    createdByName,
    createdAt,
    updatedAt,
  ];

  /// Obtiene el tamaño del archivo formateado
  String get formattedFileSize {
    if (fileSizeBytes == null) return 'N/A';

    final kb = fileSizeBytes! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';

    final mb = kb / 1024;
    if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';

    final gb = mb / 1024;
    return '${gb.toStringAsFixed(1)} GB';
  }

  /// Obtiene el tipo de documento traducido
  String get documentTypeLabel {
    const typeLabels = {
      'consultation': 'Consulta',
      'lab_result': 'Resultado de Laboratorio',
      'imaging_report': 'Informe de Imagen',
      'prescription': 'Receta',
      'surgical_note': 'Nota Quirúrgica',
      'discharge_summary': 'Resumen de Alta',
      'consent_form': 'Consentimiento Informado',
      'progress_note': 'Nota de Evolución',
      'referral': 'Referencia',
    };
    return typeLabels[documentType] ?? documentType;
  }
}
