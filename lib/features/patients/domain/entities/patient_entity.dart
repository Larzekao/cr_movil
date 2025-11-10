import 'package:equatable/equatable.dart';

class PatientEntity extends Equatable {
  final String id;
  final String identityDocumentType; // CI, Pasaporte, DNI, RUT
  final String identityDocument;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime dateOfBirth;
  final int age;
  final String gender; // M, F, O
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final Map<String, dynamic>? emergencyContact; // {name, relationship, phone}
  final String? createdByName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PatientEntity({
    required this.id,
    required this.identityDocumentType,
    required this.identityDocument,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.dateOfBirth,
    required this.age,
    required this.gender,
    required this.phone,
    this.email,
    this.address,
    this.city,
    this.emergencyContact,
    this.createdByName,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    identityDocumentType,
    identityDocument,
    firstName,
    lastName,
    fullName,
    dateOfBirth,
    age,
    gender,
    phone,
    email,
    address,
    city,
    emergencyContact,
    createdByName,
    createdAt,
    updatedAt,
  ];
}
