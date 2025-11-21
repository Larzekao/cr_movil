import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/diabetes_prediction_entity.dart';
import '../../domain/repositories/diabetes_repository.dart';
import '../datasources/diabetes_remote_datasource.dart';

class DiabetesRepositoryImpl implements DiabetesRepository {
  final DiabetesRemoteDataSource remoteDataSource;

  DiabetesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, DiabetesPredictionEntity>> predictDiabetes(
    String patientId,
  ) async {
    try {
      final prediction = await remoteDataSource.predictDiabetes(patientId);
      return Right(prediction);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DiabetesPredictionEntity>>> getPredictionHistory(
    String patientId,
  ) async {
    try {
      final history = await remoteDataSource.getPredictionHistory(patientId);
      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
