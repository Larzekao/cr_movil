import 'package:equatable/equatable.dart';

class ClinicalRecordEntity extends Equatable {
  final String id;
  final String patientId;
  final String notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ClinicalRecordEntity({
    required this.id,
    required this.patientId,
    required this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [id, patientId, notes, createdAt, updatedAt];
}
