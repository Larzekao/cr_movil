import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/clinical_record_entity.dart';
import '../../domain/usecases/get_clinical_records_usecase.dart';
import '../../domain/usecases/get_clinical_record_detail_usecase.dart';
import '../../domain/usecases/create_clinical_record_usecase.dart';
import '../../domain/usecases/update_clinical_record_usecase.dart';
import '../../domain/usecases/delete_clinical_record_usecase.dart';

// Events
abstract class ClinicalRecordEvent {}

class GetClinicalRecordsEvent extends ClinicalRecordEvent {
  final int page;
  final int pageSize;
  final String? search;

  GetClinicalRecordsEvent({this.page = 1, this.pageSize = 10, this.search});
}

class GetClinicalRecordDetailEvent extends ClinicalRecordEvent {
  final String id;
  GetClinicalRecordDetailEvent(this.id);
}

class CreateClinicalRecordEvent extends ClinicalRecordEvent {
  final Map<String, dynamic> data;

  CreateClinicalRecordEvent(this.data);
}

class UpdateClinicalRecordEvent extends ClinicalRecordEvent {
  final String id;
  final Map<String, dynamic> data;

  UpdateClinicalRecordEvent({required this.id, required this.data});
}

class DeleteClinicalRecordEvent extends ClinicalRecordEvent {
  final String id;
  DeleteClinicalRecordEvent(this.id);
}

// States
abstract class ClinicalRecordState {}

class ClinicalRecordInitial extends ClinicalRecordState {}

class ClinicalRecordLoading extends ClinicalRecordState {}

class ClinicalRecordsLoaded extends ClinicalRecordState {
  final List<ClinicalRecordEntity> records;
  ClinicalRecordsLoaded(this.records);
}

class ClinicalRecordDetailLoaded extends ClinicalRecordState {
  final ClinicalRecordEntity record;
  ClinicalRecordDetailLoaded(this.record);
}

class ClinicalRecordCreated extends ClinicalRecordState {
  final ClinicalRecordEntity record;
  ClinicalRecordCreated(this.record);
}

class ClinicalRecordUpdated extends ClinicalRecordState {
  final ClinicalRecordEntity record;
  ClinicalRecordUpdated(this.record);
}

class ClinicalRecordDeleted extends ClinicalRecordState {}

class ClinicalRecordError extends ClinicalRecordState {
  final String message;
  ClinicalRecordError(this.message);
}

// BLoC
class ClinicalRecordBloc
    extends Bloc<ClinicalRecordEvent, ClinicalRecordState> {
  final GetClinicalRecordsUseCase getClinicalRecordsUseCase;
  final GetClinicalRecordDetailUseCase getClinicalRecordDetailUseCase;
  final CreateClinicalRecordUseCase createClinicalRecordUseCase;
  final UpdateClinicalRecordUseCase updateClinicalRecordUseCase;
  final DeleteClinicalRecordUseCase deleteClinicalRecordUseCase;

  ClinicalRecordBloc({
    required this.getClinicalRecordsUseCase,
    required this.getClinicalRecordDetailUseCase,
    required this.createClinicalRecordUseCase,
    required this.updateClinicalRecordUseCase,
    required this.deleteClinicalRecordUseCase,
  }) : super(ClinicalRecordInitial()) {
    on<GetClinicalRecordsEvent>(_onGetClinicalRecords);
    on<GetClinicalRecordDetailEvent>(_onGetClinicalRecordDetail);
    on<CreateClinicalRecordEvent>(_onCreateClinicalRecord);
    on<UpdateClinicalRecordEvent>(_onUpdateClinicalRecord);
    on<DeleteClinicalRecordEvent>(_onDeleteClinicalRecord);
  }

  Future<void> _onGetClinicalRecords(
    GetClinicalRecordsEvent event,
    Emitter<ClinicalRecordState> emit,
  ) async {
    emit(ClinicalRecordLoading());
    final result = await getClinicalRecordsUseCase(
      GetClinicalRecordsParams(
        page: event.page,
        pageSize: event.pageSize,
        search: event.search,
      ),
    );
    result.fold(
      (failure) => emit(ClinicalRecordError(failure.message)),
      (records) => emit(ClinicalRecordsLoaded(records)),
    );
  }

  Future<void> _onGetClinicalRecordDetail(
    GetClinicalRecordDetailEvent event,
    Emitter<ClinicalRecordState> emit,
  ) async {
    emit(ClinicalRecordLoading());
    final result = await getClinicalRecordDetailUseCase(event.id);
    result.fold(
      (failure) => emit(ClinicalRecordError(failure.message)),
      (record) => emit(ClinicalRecordDetailLoaded(record)),
    );
  }

  Future<void> _onCreateClinicalRecord(
    CreateClinicalRecordEvent event,
    Emitter<ClinicalRecordState> emit,
  ) async {
    emit(ClinicalRecordLoading());
    final result = await createClinicalRecordUseCase(event.data);
    result.fold(
      (failure) => emit(ClinicalRecordError(failure.message)),
      (record) => emit(ClinicalRecordCreated(record)),
    );
  }

  Future<void> _onUpdateClinicalRecord(
    UpdateClinicalRecordEvent event,
    Emitter<ClinicalRecordState> emit,
  ) async {
    emit(ClinicalRecordLoading());
    final result = await updateClinicalRecordUseCase(
      UpdateClinicalRecordParams(id: event.id, data: event.data),
    );
    result.fold(
      (failure) => emit(ClinicalRecordError(failure.message)),
      (record) => emit(ClinicalRecordUpdated(record)),
    );
  }

  Future<void> _onDeleteClinicalRecord(
    DeleteClinicalRecordEvent event,
    Emitter<ClinicalRecordState> emit,
  ) async {
    emit(ClinicalRecordLoading());
    final result = await deleteClinicalRecordUseCase(event.id);
    result.fold(
      (failure) => emit(ClinicalRecordError(failure.message)),
      (_) => emit(ClinicalRecordDeleted()),
    );
  }
}
