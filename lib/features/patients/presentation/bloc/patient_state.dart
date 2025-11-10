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
  final int totalCount;
  final bool hasNext;
  final bool hasPrevious;
  final int currentPage;
  final String? searchQuery;
  final String? ordering;

  const PatientsLoaded({
    required this.patients,
    required this.totalCount,
    this.hasNext = false,
    this.hasPrevious = false,
    this.currentPage = 1,
    this.searchQuery,
    this.ordering,
  });

  @override
  List<Object?> get props => [
    patients,
    totalCount,
    hasNext,
    hasPrevious,
    currentPage,
    searchQuery,
    ordering,
  ];

  PatientsLoaded copyWith({
    List<PatientEntity>? patients,
    int? totalCount,
    bool? hasNext,
    bool? hasPrevious,
    int? currentPage,
    String? searchQuery,
    String? ordering,
  }) {
    return PatientsLoaded(
      patients: patients ?? this.patients,
      totalCount: totalCount ?? this.totalCount,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
      currentPage: currentPage ?? this.currentPage,
      searchQuery: searchQuery ?? this.searchQuery,
      ordering: ordering ?? this.ordering,
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

// Error de duplicado (409)
class PatientDuplicateError extends PatientState {
  final String message;

  const PatientDuplicateError(this.message);

  @override
  List<Object> get props => [message];
}
