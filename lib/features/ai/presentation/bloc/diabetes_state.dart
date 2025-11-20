import 'package:equatable/equatable.dart';
import '../../domain/entities/diabetes_prediction_entity.dart';

abstract class DiabetesState extends Equatable {
  const DiabetesState();

  @override
  List<Object?> get props => [];
}

class DiabetesInitial extends DiabetesState {}

class DiabetesLoading extends DiabetesState {}

class DiabetesPredictionLoaded extends DiabetesState {
  final DiabetesPredictionEntity prediction;

  const DiabetesPredictionLoaded(this.prediction);

  @override
  List<Object?> get props => [prediction];
}

class DiabetesPredictionHistoryLoaded extends DiabetesState {
  final List<DiabetesPredictionEntity> predictions;

  const DiabetesPredictionHistoryLoaded(this.predictions);

  @override
  List<Object?> get props => [predictions];
}

class DiabetesError extends DiabetesState {
  final String message;

  const DiabetesError(this.message);

  @override
  List<Object?> get props => [message];
}
