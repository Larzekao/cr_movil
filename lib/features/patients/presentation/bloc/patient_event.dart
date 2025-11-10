import 'package:equatable/equatable.dart';

abstract class PatientEvent extends Equatable {
  const PatientEvent();

  @override
  List<Object?> get props => [];
}

// Cargar lista de pacientes
class GetPatientsRequested extends PatientEvent {
  final int page;
  final int pageSize;
  final String? search;
  final String? ordering; // e.g., 'first_name', '-created_at'

  const GetPatientsRequested({
    this.page = 1,
    this.pageSize = 10,
    this.search,
    this.ordering,
  });

  @override
  List<Object?> get props => [page, pageSize, search, ordering];
}

// Cargar detalle de un paciente
class GetPatientDetailRequested extends PatientEvent {
  final String patientId;

  const GetPatientDetailRequested(this.patientId);

  @override
  List<Object> get props => [patientId];
}

// Crear nuevo paciente
class CreatePatientRequested extends PatientEvent {
  final Map<String, dynamic> patientData;

  const CreatePatientRequested(this.patientData);

  @override
  List<Object> get props => [patientData];
}

// Actualizar paciente
class UpdatePatientRequested extends PatientEvent {
  final String patientId;
  final Map<String, dynamic> patientData;

  const UpdatePatientRequested(this.patientId, this.patientData);

  @override
  List<Object> get props => [patientId, patientData];
}

// Eliminar paciente
class DeletePatientRequested extends PatientEvent {
  final String patientId;

  const DeletePatientRequested(this.patientId);

  @override
  List<Object> get props => [patientId];
}

// Buscar pacientes
class SearchPatientsRequested extends PatientEvent {
  final String query;

  const SearchPatientsRequested(this.query);

  @override
  List<Object> get props => [query];
}

// Limpiar estado
class ClearPatientState extends PatientEvent {
  const ClearPatientState();
}
