import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/diabetes_repository.dart';
import 'diabetes_event.dart';
import 'diabetes_state.dart';

class DiabetesBloc extends Bloc<DiabetesEvent, DiabetesState> {
  final DiabetesRepository repository;

  DiabetesBloc({required this.repository}) : super(DiabetesInitial()) {
    on<PredictDiabetesRequested>(_onPredictDiabetesRequested);
    on<GetPredictionHistoryRequested>(_onGetPredictionHistoryRequested);
  }

  Future<void> _onPredictDiabetesRequested(
    PredictDiabetesRequested event,
    Emitter<DiabetesState> emit,
  ) async {
    emit(DiabetesLoading());

    final result = await repository.predictDiabetes(event.patientId);

    result.fold(
      (failure) => emit(DiabetesError(failure.toString())),
      (prediction) => emit(DiabetesPredictionLoaded(prediction)),
    );
  }

  Future<void> _onGetPredictionHistoryRequested(
    GetPredictionHistoryRequested event,
    Emitter<DiabetesState> emit,
  ) async {
    emit(DiabetesLoading());

    final result = await repository.getPredictionHistory(event.patientId);

    result.fold(
      (failure) => emit(DiabetesError(failure.toString())),
      (predictions) => emit(DiabetesPredictionHistoryLoaded(predictions)),
    );
  }
}
