import '../../domain/entities/document_entity.dart';

/// Modelo de Documento Clínico para serialización
class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.clinicalRecordId,
    required super.patientName,
    required super.documentType,
    required super.title,
    super.description,
    required super.documentDate,
    super.specialty,
    super.doctorName,
    super.doctorLicense,
    super.content,
    super.filePath,
    super.fileName,
    super.fileSizeBytes,
    super.mimeType,
    super.fileUrl,
    super.ocrText,
    super.ocrConfidence,
    super.ocrProcessed = false,
    super.isSigned = false,
    super.signedAt,
    super.signedByName,
    super.isLocked = false,
    super.tags = const [],
    super.createdByName,
    required super.createdAt,
    required super.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      // clinical_record puede no venir en el list serializer
      clinicalRecordId: json['clinical_record'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      documentType: json['document_type'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      documentDate: DateTime.parse(json['document_date'] as String),
      specialty: json['specialty'] as String?,
      doctorName: json['doctor_name'] as String?,
      doctorLicense: json['doctor_license'] as String?,
      content: json['content'] as Map<String, dynamic>?,
      filePath: json['file_path'] as String?,
      fileName: json['file_name'] as String?,
      fileSizeBytes: json['file_size_bytes'] as int?,
      mimeType: json['mime_type'] as String?,
      fileUrl: json['file_url'] as String?,
      ocrText: json['ocr_text'] as String?,
      ocrConfidence: json['ocr_confidence'] != null
          ? (json['ocr_confidence'] as num).toDouble()
          : null,
      ocrProcessed: json['ocr_processed'] as bool? ?? false,
      isSigned: json['is_signed'] as bool? ?? false,
      signedAt: json['signed_at'] != null
          ? DateTime.parse(json['signed_at'] as String)
          : null,
      signedByName: json['signed_by_name'] as String?,
      isLocked: json['is_locked'] as bool? ?? false,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      createdByName: json['created_by_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      // updated_at puede no venir en el list serializer, usar created_at como fallback
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinical_record': clinicalRecordId,
      'patient_name': patientName,
      'document_type': documentType,
      'title': title,
      'description': description,
      'document_date': documentDate.toIso8601String(),
      'specialty': specialty,
      'doctor_name': doctorName,
      'doctor_license': doctorLicense,
      'content': content,
      'file_path': filePath,
      'file_name': fileName,
      'file_size_bytes': fileSizeBytes,
      'mime_type': mimeType,
      'file_url': fileUrl,
      'ocr_text': ocrText,
      'ocr_confidence': ocrConfidence,
      'ocr_processed': ocrProcessed,
      'is_signed': isSigned,
      'signed_at': signedAt?.toIso8601String(),
      'signed_by_name': signedByName,
      'is_locked': isLocked,
      'tags': tags,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convierte a formato para creación/actualización
  Map<String, dynamic> toCreateJson() {
    return {
      'clinical_record': clinicalRecordId,
      'document_type': documentType,
      'title': title,
      'description': description,
      'document_date': documentDate.toIso8601String(),
      'specialty': specialty,
      'doctor_name': doctorName,
      'doctor_license': doctorLicense,
      'content': content,
      'tags': tags,
    };
  }
}
