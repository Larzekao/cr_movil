import '../../domain/entities/clinical_form_entity.dart';

/// Modelo de Formulario Clínico alineado con el backend
class ClinicalFormModel {
  final String id;
  final String clinicalRecordId;
  final String? recordNumber;
  final String? patientName;
  final String formType;
  final String? formTypeDisplay;
  final String? formTemplateId;
  final Map<String, dynamic> formData;
  final String filledById;
  final String? filledByName;
  final String? doctorName;
  final String? doctorSpecialty;
  final DateTime formDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicalFormModel({
    required this.id,
    required this.clinicalRecordId,
    this.recordNumber,
    this.patientName,
    required this.formType,
    this.formTypeDisplay,
    this.formTemplateId,
    required this.formData,
    required this.filledById,
    this.filledByName,
    this.doctorName,
    this.doctorSpecialty,
    required this.formDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicalFormModel.fromJson(Map<String, dynamic> json) {
    // Parsear form_data como Map
    Map<String, dynamic> formDataMap = {};
    if (json['form_data'] != null) {
      if (json['form_data'] is Map) {
        formDataMap = Map<String, dynamic>.from(json['form_data']);
      }
    }

    return ClinicalFormModel(
      id: json['id']?.toString() ?? '',
      clinicalRecordId: json['clinical_record']?.toString() ?? '',
      recordNumber: json['record_number']?.toString(),
      patientName: json['patient_name']?.toString(),
      formType: json['form_type']?.toString() ?? 'other',
      formTypeDisplay: json['form_type_display']?.toString(),
      formTemplateId: json['form_template_id']?.toString(),
      formData: formDataMap,
      filledById: json['filled_by']?.toString() ?? '',
      filledByName: json['filled_by_name']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      doctorSpecialty: json['doctor_specialty']?.toString(),
      formDate:
          DateTime.tryParse(json['form_date']?.toString() ?? '') ??
          DateTime.now(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ClinicalFormEntity toEntity() {
    return ClinicalFormEntity(
      id: id,
      clinicalRecordId: clinicalRecordId,
      recordNumber: recordNumber,
      patientName: patientName,
      formType: ClinicalFormTypeExtension.fromString(formType),
      formTypeDisplay: formTypeDisplay,
      formTemplateId: formTemplateId,
      formData: formData,
      filledById: filledById,
      filledByName: filledByName,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      formDate: formDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Serializa para crear un nuevo formulario
  Map<String, dynamic> toJson() {
    return {
      'clinical_record': clinicalRecordId,
      'form_type': formType,
      if (formTemplateId != null) 'form_template_id': formTemplateId,
      'form_data': formData,
      if (doctorName != null) 'doctor_name': doctorName,
      if (doctorSpecialty != null) 'doctor_specialty': doctorSpecialty,
      'form_date': formDate.toIso8601String(),
    };
  }

  /// Serializa para actualizar un formulario existente
  Map<String, dynamic> toUpdateJson() {
    return {
      if (formTemplateId != null) 'form_template_id': formTemplateId,
      'form_data': formData,
      if (doctorName != null) 'doctor_name': doctorName,
      if (doctorSpecialty != null) 'doctor_specialty': doctorSpecialty,
      'form_date': formDate.toIso8601String(),
    };
  }

  /// Factory para crear un modelo desde una entidad
  factory ClinicalFormModel.fromEntity(ClinicalFormEntity entity) {
    return ClinicalFormModel(
      id: entity.id,
      clinicalRecordId: entity.clinicalRecordId,
      recordNumber: entity.recordNumber,
      patientName: entity.patientName,
      formType: entity.formType.value,
      formTypeDisplay: entity.formTypeDisplay,
      formTemplateId: entity.formTemplateId,
      formData: entity.formData,
      filledById: entity.filledById,
      filledByName: entity.filledByName,
      doctorName: entity.doctorName,
      doctorSpecialty: entity.doctorSpecialty,
      formDate: entity.formDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
