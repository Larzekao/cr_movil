import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    required super.identityDocument,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.dateOfBirth,
    required super.gender,
    required super.phone,
    super.email,
    super.address,
    super.emergencyContactName,
    super.emergencyContactPhone,
    super.bloodType,
    super.allergies,
    super.chronicConditions,
    required super.createdAt,
    super.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString() ?? '',
      identityDocument: json['identity_document']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : DateTime.now(),
      gender: json['gender']?.toString() ?? 'M',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      emergencyContactName: json['emergency_contact_name']?.toString(),
      emergencyContactPhone: json['emergency_contact_phone']?.toString(),
      bloodType: json['blood_type']?.toString(),
      allergies: json['allergies']?.toString(),
      chronicConditions: json['chronic_conditions']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'identity_document': identityDocument,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'phone': phone,
      'email': email,
      'address': address,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'blood_type': bloodType,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PatientEntity toEntity() {
    return PatientEntity(
      id: id,
      identityDocument: identityDocument,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      gender: gender,
      phone: phone,
      email: email,
      address: address,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      bloodType: bloodType,
      allergies: allergies,
      chronicConditions: chronicConditions,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
