import '../../domain/entities/clinical_record_entity.dart';

/// Modelo de alergia para serialización
class AllergyModel {
  final String allergen;
  final String severity;
  final String reaction;

  AllergyModel({
    required this.allergen,
    required this.severity,
    required this.reaction,
  });

  factory AllergyModel.fromJson(Map<String, dynamic> json) {
    return AllergyModel(
      allergen: json['allergen']?.toString() ?? '',
      severity: json['severity']?.toString() ?? '',
      reaction: json['reaction']?.toString() ?? '',
    );
  }

  Allergy toEntity() {
    return Allergy(allergen: allergen, severity: severity, reaction: reaction);
  }

  Map<String, dynamic> toJson() {
    return {'allergen': allergen, 'severity': severity, 'reaction': reaction};
  }
}

/// Modelo de medicamento para serialización
class MedicationModel {
  final String name;
  final String dose;
  final String frequency;

  MedicationModel({
    required this.name,
    required this.dose,
    required this.frequency,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      name: json['name']?.toString() ?? '',
      dose: json['dose']?.toString() ?? '',
      frequency: json['frequency']?.toString() ?? '',
    );
  }

  Medication toEntity() {
    return Medication(name: name, dose: dose, frequency: frequency);
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'dose': dose, 'frequency': frequency};
  }
}

/// Modelo de información del paciente para serialización
class PatientInfoModel {
  final String id;
  final String firstName;
  final String lastName;
  final String identification;
  final DateTime dateOfBirth;
  final String gender;

  PatientInfoModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.identification,
    required this.dateOfBirth,
    required this.gender,
  });

  factory PatientInfoModel.fromJson(Map<String, dynamic> json) {
    // El backend puede enviar full_name o first_name/last_name
    String firstName = '';
    String lastName = '';

    if (json['full_name'] != null) {
      // Si viene full_name, dividirlo
      final fullName = json['full_name'].toString();
      final parts = fullName.split(' ');
      if (parts.isNotEmpty) {
        firstName = parts.first;
        if (parts.length > 1) {
          lastName = parts.sublist(1).join(' ');
        }
      }
    } else {
      // Si vienen separados
      firstName = json['first_name']?.toString() ?? '';
      lastName = json['last_name']?.toString() ?? '';
    }

    // El backend puede enviar identity_document o identification
    final identification = json['identity_document']?.toString() ??
                          json['identification']?.toString() ?? '';

    // date_of_birth puede venir o calcularse desde age
    DateTime dateOfBirth = DateTime.now();
    if (json['date_of_birth'] != null) {
      dateOfBirth = DateTime.tryParse(json['date_of_birth'].toString()) ?? DateTime.now();
    } else if (json['age'] != null) {
      final age = int.tryParse(json['age'].toString()) ?? 0;
      dateOfBirth = DateTime.now().subtract(Duration(days: age * 365));
    }

    return PatientInfoModel(
      id: json['id']?.toString() ?? '',
      firstName: firstName,
      lastName: lastName,
      identification: identification,
      dateOfBirth: dateOfBirth,
      gender: json['gender']?.toString() ?? '',
    );
  }

  PatientInfo toEntity() {
    return PatientInfo(
      id: id,
      firstName: firstName,
      lastName: lastName,
      identification: identification,
      dateOfBirth: dateOfBirth,
      gender: gender,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'identification': identification,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'gender': gender,
    };
  }
}

/// Modelo de Historia Clínica alineado con el backend
class ClinicalRecordModel {
  final String id;
  final String patientId;
  final PatientInfoModel? patientInfo;
  final String recordNumber;
  final String status;
  final String? bloodType;
  final List<AllergyModel> allergies;
  final List<String> chronicConditions;
  final List<MedicationModel> medications;
  final String? familyHistory;
  final String? socialHistory;
  final int documentsCount;
  final String? createdById;
  final String? createdByName;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicalRecordModel({
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

  factory ClinicalRecordModel.fromJson(Map<String, dynamic> json) {
    // Parsear alergias - puede ser lista de strings o lista de objetos
    List<AllergyModel> allergiesList = [];
    if (json['allergies'] != null && json['allergies'] is List) {
      allergiesList = (json['allergies'] as List).map((item) {
        if (item is String) {
          // Si es string, crear un objeto simple
          return AllergyModel(
            allergen: item,
            severity: 'Unknown',
            reaction: '',
          );
        } else if (item is Map<String, dynamic>) {
          return AllergyModel.fromJson(item);
        }
        return AllergyModel(
          allergen: item.toString(),
          severity: 'Unknown',
          reaction: '',
        );
      }).toList();
    }

    // Parsear condiciones crónicas
    List<String> chronicList = [];
    if (json['chronic_conditions'] != null &&
        json['chronic_conditions'] is List) {
      chronicList = (json['chronic_conditions'] as List)
          .map((item) => item.toString())
          .toList();
    }

    // Parsear medicamentos - puede ser lista de strings o lista de objetos
    List<MedicationModel> medicationsList = [];
    if (json['medications'] != null && json['medications'] is List) {
      medicationsList = (json['medications'] as List).map((item) {
        if (item is String) {
          // Si es string, crear un objeto simple
          return MedicationModel(
            name: item,
            dose: 'Unknown',
            frequency: '',
          );
        } else if (item is Map<String, dynamic>) {
          return MedicationModel.fromJson(item);
        }
        return MedicationModel(
          name: item.toString(),
          dose: 'Unknown',
          frequency: '',
        );
      }).toList();
    }

    // Parsear información del paciente
    PatientInfoModel? patientInfoModel;
    if (json['patient_info'] != null) {
      patientInfoModel = PatientInfoModel.fromJson(
        json['patient_info'] as Map<String, dynamic>,
      );
    }

    return ClinicalRecordModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient']?.toString() ?? '',
      patientInfo: patientInfoModel,
      recordNumber: json['record_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      bloodType: json['blood_type']?.toString(),
      allergies: allergiesList,
      chronicConditions: chronicList,
      medications: medicationsList,
      familyHistory: json['family_history']?.toString(),
      socialHistory: json['social_history']?.toString(),
      documentsCount: json['documents_count'] ?? 0,
      createdById: json['created_by']?.toString(),
      createdByName: json['created_by_name']?.toString(),
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  ClinicalRecordEntity toEntity() {
    // Convertir status string a enum
    ClinicalRecordStatus statusEnum;
    switch (status.toLowerCase()) {
      case 'archived':
        statusEnum = ClinicalRecordStatus.archived;
        break;
      case 'closed':
        statusEnum = ClinicalRecordStatus.closed;
        break;
      case 'active':
      default:
        statusEnum = ClinicalRecordStatus.active;
        break;
    }

    return ClinicalRecordEntity(
      id: id,
      patientId: patientId,
      patientInfo: patientInfo?.toEntity(),
      recordNumber: recordNumber,
      status: statusEnum,
      bloodType: bloodType,
      allergies: allergies.map((a) => a.toEntity()).toList(),
      chronicConditions: chronicConditions,
      medications: medications.map((m) => m.toEntity()).toList(),
      familyHistory: familyHistory,
      socialHistory: socialHistory,
      documentsCount: documentsCount,
      createdById: createdById,
      createdByName: createdByName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patientId,
      if (bloodType != null) 'blood_type': bloodType,
      'allergies': allergies.map((a) => a.toJson()).toList(),
      'chronic_conditions': chronicConditions,
      'medications': medications.map((m) => m.toJson()).toList(),
      if (familyHistory != null) 'family_history': familyHistory,
      if (socialHistory != null) 'social_history': socialHistory,
    };
  }

  /// Crea un modelo para actualización (incluye ID)
  Map<String, dynamic> toUpdateJson() {
    return {'id': id, ...toJson()};
  }
}
