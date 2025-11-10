import 'package:flutter_bloc/flutter_bloc.dart';
import 'patient_event.dart';
import 'patient_state.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/get_patient_detail_usecase.dart';
import '../../domain/usecases/create_patient_usecase.dart';
import '../../domain/usecases/update_patient_usecase.dart';
import '../../domain/usecases/delete_patient_usecase.dart';

class PatientBloc extends Bloc<PatientEvent, PatientState> {
  final GetPatientsUseCase getPatientsUseCase;
  final GetPatientDetailUseCase getPatientDetailUseCase;
  final CreatePatientUseCase createPatientUseCase;
  final UpdatePatientUseCase updatePatientUseCase;
  final DeletePatientUseCase deletePatientUseCase;

  PatientBloc({
    required this.getPatientsUseCase,
    required this.getPatientDetailUseCase,
    required this.createPatientUseCase,
    required this.updatePatientUseCase,
    required this.deletePatientUseCase,
  }) : super(PatientInitial()) {
    on<GetPatientsRequested>(_onGetPatientsRequested);
    on<GetPatientDetailRequested>(_onGetPatientDetailRequested);
    on<CreatePatientRequested>(_onCreatePatientRequested);
    on<UpdatePatientRequested>(_onUpdatePatientRequested);
    on<DeletePatientRequested>(_onDeletePatientRequested);
    on<SearchPatientsRequested>(_onSearchPatientsRequested);
    on<ClearPatientState>(_onClearPatientState);
  }

  Future<void> _onGetPatientsRequested(
    GetPatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getPatientsUseCase(
      page: event.page,
      pageSize: event.pageSize,
      search: event.search,
      ordering: event.ordering,
    );

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (paginatedPatients) => emit(
        PatientsLoaded(
          patients: paginatedPatients.results,
          totalCount: paginatedPatients.count,
          hasNext: paginatedPatients.hasNext,
          hasPrevious: paginatedPatients.hasPrevious,
          currentPage: event.page,
          searchQuery: event.search,
          ordering: event.ordering,
        ),
      ),
    );
  }

  Future<void> _onGetPatientDetailRequested(
    GetPatientDetailRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getPatientDetailUseCase(event.patientId);

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (patient) => emit(PatientDetailLoaded(patient)),
    );
  }

  Future<void> _onCreatePatientRequested(
    CreatePatientRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await createPatientUseCase(event.patientData);

    result.fold((failure) {
      if (failure is DuplicateFailure) {
        emit(PatientDuplicateError(failure.message));
      } else if (failure is ValidationFailure) {
        emit(PatientError(failure.message));
      } else {
        emit(PatientError(failure.message));
      }
    }, (patient) => emit(PatientCreated(patient)));
  }

  Future<void> _onUpdatePatientRequested(
    UpdatePatientRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await updatePatientUseCase(
      event.patientId,
      event.patientData,
    );

    result.fold((failure) {
      if (failure is DuplicateFailure) {
        emit(PatientDuplicateError(failure.message));
      } else if (failure is ValidationFailure) {
        emit(PatientError(failure.message));
      } else {
        emit(PatientError(failure.message));
      }
    }, (patient) => emit(PatientUpdated(patient)));
  }

  Future<void> _onDeletePatientRequested(
    DeletePatientRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await deletePatientUseCase(event.patientId);

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (_) => emit(PatientDeleted(event.patientId)),
    );
  }

  Future<void> _onSearchPatientsRequested(
    SearchPatientsRequested event,
    Emitter<PatientState> emit,
  ) async {
    emit(PatientLoading());

    final result = await getPatientsUseCase(
      page: 1,
      pageSize: 20,
      search: event.query,
    );

    result.fold(
      (failure) => emit(PatientError(failure.message)),
      (paginatedPatients) => emit(
        PatientsLoaded(
          patients: paginatedPatients.results,
          totalCount: paginatedPatients.count,
          hasNext: paginatedPatients.hasNext,
          hasPrevious: paginatedPatients.hasPrevious,
          currentPage: 1,
          searchQuery: event.query,
        ),
      ),
    );
  }

  void _onClearPatientState(
    ClearPatientState event,
    Emitter<PatientState> emit,
  ) {
    emit(PatientInitial());
  }
}
