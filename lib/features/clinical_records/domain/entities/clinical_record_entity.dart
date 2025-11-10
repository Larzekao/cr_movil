import 'package:equatable/equatable.dart';

/// Estados posibles de una historia clínica
enum ClinicalRecordStatus { active, archived, closed }

/// Entidad que representa una alergia del paciente
class Allergy extends Equatable {
  final String allergen;
  final String severity;
  final String reaction;

  const Allergy({
    required this.allergen,
    required this.severity,
    required this.reaction,
  });

  @override
  List<Object?> get props => [allergen, severity, reaction];
}

/// Entidad que representa un medicamento actual del paciente
class Medication extends Equatable {
  final String name;
  final String dose;
  final String frequency;

  const Medication({
    required this.name,
    required this.dose,
    required this.frequency,
  });

  @override
  List<Object?> get props => [name, dose, frequency];
}

/// Información básica del paciente (nested en ClinicalRecord)
class PatientInfo extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String identification;
  final DateTime dateOfBirth;
  final String gender;

  const PatientInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.identification,
    required this.dateOfBirth,
    required this.gender,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    identification,
    dateOfBirth,
    gender,
  ];
}

/// Entidad de Historia Clínica alineada con el backend
class ClinicalRecordEntity extends Equatable {
  final String id;
  final String patientId;
  final PatientInfo? patientInfo;
  final String recordNumber;
  final ClinicalRecordStatus status;
  final String? bloodType;
  final List<Allergy> allergies;
  final List<String> chronicConditions;
  final List<Medication> medications;
  final String? familyHistory;
  final String? socialHistory;
  final int documentsCount;
  final String? createdById;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClinicalRecordEntity({
    required this.id,
    required this.patientId,
    this.patientInfo,
    required this.recordNumber,
    required this.status,
    this.bloodType,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.medications = const [],
    this.familyHistory,
    this.socialHistory,
    this.documentsCount = 0,
    this.createdById,
    this.createdByName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica si la historia está activa
  bool get isActive => status == ClinicalRecordStatus.active;

  /// Verifica si la historia está cerrada
  bool get isClosed => status == ClinicalRecordStatus.closed;

  /// Verifica si la historia está archivada
  bool get isArchived => status == ClinicalRecordStatus.archived;

  /// Verifica si se pueden agregar documentos/formularios
  bool get canAddContent => !isClosed;

  /// Nombre completo del paciente
  String get patientName => patientInfo?.fullName ?? 'Sin información';

  @override
  List<Object?> get props => [
    id,
    patientId,
    patientInfo,
    recordNumber,
    status,
    bloodType,
    allergies,
    chronicConditions,
    medications,
    familyHistory,
    socialHistory,
    documentsCount,
    createdById,
    createdByName,
    createdAt,
    updatedAt,
  ];
}
