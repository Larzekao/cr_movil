import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String identityDocument;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime dateOfBirth;
  final String gender; // M or F
  final String phone;
  final String? email;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? bloodType;
  final String? allergies;
  final String? chronicConditions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PatientEntity({
    required this.id,
    required this.identityDocument,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.dateOfBirth,
    required this.gender,
    required this.phone,
    this.email,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodType,
    this.allergies,
    this.chronicConditions,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    identityDocument,
    firstName,
    lastName,
    fullName,
    dateOfBirth,
    gender,
    phone,
    email,
    address,
    emergencyContactName,
    emergencyContactPhone,
    bloodType,
    allergies,
    chronicConditions,
    createdAt,
    updatedAt,
  ];
}
