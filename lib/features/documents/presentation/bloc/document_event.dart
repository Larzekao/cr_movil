import 'package:equatable/equatable.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();
  @override
  List<Object?> get props => [];
}

class LoadDocuments extends DocumentEvent {
  final String? clinicalRecordId;
  final String? documentType;
  final String? search;

  const LoadDocuments({this.clinicalRecordId, this.documentType, this.search});
  @override
  List<Object?> get props => [clinicalRecordId, documentType, search];
}

class LoadDocumentById extends DocumentEvent {
  final String id;
  const LoadDocumentById(this.id);
  @override
  List<Object?> get props => [id];
}

class CreateDocument extends DocumentEvent {
  final String clinicalRecordId;
  final String documentType;
  final String title;
  final String? description;
  final DateTime documentDate;
  final String? specialty;
  final String? doctorName;
  final String? doctorLicense;

  const CreateDocument({
    required this.clinicalRecordId,
    required this.documentType,
    required this.title,
    this.description,
    required this.documentDate,
    this.specialty,
    this.doctorName,
    this.doctorLicense,
  });

  @override
  List<Object?> get props => [
    clinicalRecordId,
    documentType,
    title,
    description,
    documentDate,
    specialty,
    doctorName,
    doctorLicense,
  ];
}

class UpdateDocument extends DocumentEvent {
  final String id;
  final String? title;
  final String? description;
  final DateTime? documentDate;
  final String? specialty;
  final String? doctorName;
  final String? doctorLicense;

  const UpdateDocument({
    required this.id,
    this.title,
    this.description,
    this.documentDate,
    this.specialty,
    this.doctorName,
    this.doctorLicense,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    documentDate,
    specialty,
    doctorName,
    doctorLicense,
  ];
}

class DeleteDocument extends DocumentEvent {
  final String id;
  const DeleteDocument(this.id);
  @override
  List<Object?> get props => [id];
}

class UploadDocument extends DocumentEvent {
  final String clinicalRecordId;
  final String documentType;
  final String title;
  final DateTime documentDate;
  final String filePath;
  final String? description;
  final String? specialty;
  final String? doctorName;
  final String? doctorLicense;

  const UploadDocument({
    required this.clinicalRecordId,
    required this.documentType,
    required this.title,
    required this.documentDate,
    required this.filePath,
    this.description,
    this.specialty,
    this.doctorName,
    this.doctorLicense,
  });

  @override
  List<Object?> get props => [
    clinicalRecordId,
    documentType,
    title,
    documentDate,
    filePath,
    description,
    specialty,
    doctorName,
    doctorLicense,
  ];
}
