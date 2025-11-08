import '../../domain/entities/clinical_record_entity.dart';

class ClinicalRecordModel {
  final String id;
  final String patientId;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ClinicalRecordModel({
    required this.id,
    required this.patientId,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory ClinicalRecordModel.fromJson(Map<String, dynamic> json) {
    return ClinicalRecordModel(
      id: json['id'].toString(),
      patientId: json['patient']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  ClinicalRecordEntity toEntity() {
    return ClinicalRecordEntity(
      id: id,
      patientId: patientId,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
