import 'package:equatable/equatable.dart';

abstract class DiabetesEvent extends Equatable {
  const DiabetesEvent();

  @override
  List<Object?> get props => [];
}

class PredictDiabetesRequested extends DiabetesEvent {
  final String patientId;

  const PredictDiabetesRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class GetPredictionHistoryRequested extends DiabetesEvent {
  final String patientId;

  const GetPredictionHistoryRequested(this.patientId);

  @override
  List<Object?> get props => [patientId];
}
