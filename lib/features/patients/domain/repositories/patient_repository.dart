import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/patient_entity.dart';

class PaginatedPatients {
  final int count;
  final String? next;
  final String? previous;
  final List<PatientEntity> results;

  PaginatedPatients({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  bool get hasNext => next != null;
  bool get hasPrevious => previous != null;
  int get totalPages => (count / results.length).ceil();
}

abstract class PatientRepository {
  Future<Either<Failure, PaginatedPatients>> getPatients({
    int page = 1,
    int pageSize = 10,
    String? search,
    String? ordering, // e.g., 'first_name', '-created_at'
  });

  Future<Either<Failure, PatientEntity>> getPatientById(String id);

  Future<Either<Failure, PatientEntity>> createPatient(
    Map<String, dynamic> patientData,
  );

  Future<Either<Failure, PatientEntity>> updatePatient(
    String id,
    Map<String, dynamic> patientData,
  );

  Future<Either<Failure, void>> deletePatient(String id);
}
