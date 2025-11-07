import 'package:equatable/equatable.dart';
import '../../domain/entities/patient_entity.dart';

abstract class PatientState extends Equatable {
  const PatientState();

  @override
  List<Object?> get props => [];
}

// Estado inicial
class PatientInitial extends PatientState {}

// Cargando
class PatientLoading extends PatientState {}

// Lista de pacientes cargada
class PatientsLoaded extends PatientState {
  final List<PatientEntity> patients;
  final bool hasMore;
  final int currentPage;
  final String? searchQuery;

  const PatientsLoaded({
    required this.patients,
    this.hasMore = false,
    this.currentPage = 1,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [patients, hasMore, currentPage, searchQuery];

  PatientsLoaded copyWith({
    List<PatientEntity>? patients,
    bool? hasMore,
    int? currentPage,
    String? searchQuery,
  }) {
    return PatientsLoaded(
      patients: patients ?? this.patients,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Detalle de paciente cargado
class PatientDetailLoaded extends PatientState {
  final PatientEntity patient;

  const PatientDetailLoaded(this.patient);

  @override
  List<Object> get props => [patient];
}

// Paciente creado exitosamente
class PatientCreated extends PatientState {
  final PatientEntity patient;

  const PatientCreated(this.patient);

  @override
  List<Object> get props => [patient];
}

// Paciente actualizado exitosamente
class PatientUpdated extends PatientState {
  final PatientEntity patient;

  const PatientUpdated(this.patient);

  @override
  List<Object> get props => [patient];
}

// Paciente eliminado exitosamente
class PatientDeleted extends PatientState {
  final String patientId;

  const PatientDeleted(this.patientId);

  @override
  List<Object> get props => [patientId];
}

// Error
class PatientError extends PatientState {
  final String message;

  const PatientError(this.message);

  @override
  List<Object> get props => [message];
}
