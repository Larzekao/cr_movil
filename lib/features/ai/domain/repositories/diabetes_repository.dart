import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/diabetes_prediction_entity.dart';

abstract class DiabetesRepository {
  Future<Either<Failure, DiabetesPredictionEntity>> predictDiabetes(
    String patientId,
  );

  Future<Either<Failure, List<DiabetesPredictionEntity>>> getPredictionHistory(
    String patientId,
  );
}
