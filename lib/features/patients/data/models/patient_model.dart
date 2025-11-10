import '../../domain/entities/patient_entity.dart';

class PatientModel extends PatientEntity {
  const PatientModel({
    required super.id,
    required super.identityDocumentType,
    required super.identityDocument,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    required super.dateOfBirth,
    required super.age,
    required super.gender,
    required super.phone,
    super.email,
    super.address,
    super.city,
    super.emergencyContact,
    super.createdByName,
    required super.createdAt,
    super.updatedAt,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString() ?? '',
      identityDocumentType: json['identity_document_type']?.toString() ?? 'CI',
      identityDocument: json['identity_document']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : DateTime.now(),
      age: json['age'] ?? 0,
      gender: json['gender']?.toString() ?? 'M',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      city: json['city']?.toString(),
      emergencyContact: json['emergency_contact'] as Map<String, dynamic>?,
      createdByName: json['created_by_name']?.toString(),
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
      'identity_document_type': identityDocumentType,
      'identity_document': identityDocument,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
      'gender': gender,
      'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (emergencyContact != null) 'emergency_contact': emergencyContact,
    };
  }

  PatientEntity toEntity() {
    return PatientEntity(
      id: id,
      identityDocumentType: identityDocumentType,
      identityDocument: identityDocument,
      firstName: firstName,
      lastName: lastName,
      fullName: fullName,
      dateOfBirth: dateOfBirth,
      age: age,
      gender: gender,
      phone: phone,
      email: email,
      address: address,
      city: city,
      emergencyContact: emergencyContact,
      createdByName: createdByName,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
