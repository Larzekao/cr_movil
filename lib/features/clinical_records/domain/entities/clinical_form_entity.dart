import 'package:equatable/equatable.dart';

/// Tipos de formularios clínicos disponibles
enum ClinicalFormType {
  triage,
  consultation,
  evolution,
  prescription,
  labOrder,
  imagingOrder,
  procedure,
  discharge,
  referral,
  other,
}

/// Extensión para obtener el valor de string del enum
extension ClinicalFormTypeExtension on ClinicalFormType {
  String get value {
    switch (this) {
      case ClinicalFormType.triage:
        return 'triage';
      case ClinicalFormType.consultation:
        return 'consultation';
      case ClinicalFormType.evolution:
        return 'evolution';
      case ClinicalFormType.prescription:
        return 'prescription';
      case ClinicalFormType.labOrder:
        return 'lab_order';
      case ClinicalFormType.imagingOrder:
        return 'imaging_order';
      case ClinicalFormType.procedure:
        return 'procedure';
      case ClinicalFormType.discharge:
        return 'discharge';
      case ClinicalFormType.referral:
        return 'referral';
      case ClinicalFormType.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case ClinicalFormType.triage:
        return 'Triaje';
      case ClinicalFormType.consultation:
        return 'Consulta Médica';
      case ClinicalFormType.evolution:
        return 'Nota de Evolución';
      case ClinicalFormType.prescription:
        return 'Receta Médica';
      case ClinicalFormType.labOrder:
        return 'Orden de Laboratorio';
      case ClinicalFormType.imagingOrder:
        return 'Orden de Imagenología';
      case ClinicalFormType.procedure:
        return 'Procedimiento';
      case ClinicalFormType.discharge:
        return 'Alta Médica';
      case ClinicalFormType.referral:
        return 'Referencia';
      case ClinicalFormType.other:
        return 'Otro';
    }
  }

  /// Convierte un string a ClinicalFormType
  static ClinicalFormType fromString(String value) {
    switch (value) {
      case 'triage':
        return ClinicalFormType.triage;
      case 'consultation':
        return ClinicalFormType.consultation;
      case 'evolution':
        return ClinicalFormType.evolution;
      case 'prescription':
        return ClinicalFormType.prescription;
      case 'lab_order':
        return ClinicalFormType.labOrder;
      case 'imaging_order':
        return ClinicalFormType.imagingOrder;
      case 'procedure':
        return ClinicalFormType.procedure;
      case 'discharge':
        return ClinicalFormType.discharge;
      case 'referral':
        return ClinicalFormType.referral;
      case 'other':
      default:
        return ClinicalFormType.other;
    }
  }
}

/// Entidad de Formulario Clínico alineada con el backend
class ClinicalFormEntity extends Equatable {
  final String id;
  final String clinicalRecordId;
  final String? recordNumber;
  final String? patientName;
  final ClinicalFormType formType;
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

  const ClinicalFormEntity({
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

  /// Nombre del tipo de formulario para mostrar
  String get formTypeName => formTypeDisplay ?? formType.displayName;

  @override
  List<Object?> get props => [
    id,
    clinicalRecordId,
    recordNumber,
    patientName,
    formType,
    formTypeDisplay,
    formTemplateId,
    formData,
    filledById,
    filledByName,
    doctorName,
    doctorSpecialty,
    formDate,
    createdAt,
    updatedAt,
  ];
}
