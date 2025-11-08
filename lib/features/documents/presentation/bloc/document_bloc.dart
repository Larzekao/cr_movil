import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_documents_usecase.dart';
import '../../domain/usecases/create_document_usecase.dart';
import '../../domain/usecases/update_document_usecase.dart';
import '../../domain/usecases/delete_document_usecase.dart';
import '../../domain/usecases/upload_document_usecase.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final GetDocumentsUseCase getDocumentsUseCase;
  final CreateDocumentUseCase createDocumentUseCase;
  final UpdateDocumentUseCase updateDocumentUseCase;
  final DeleteDocumentUseCase deleteDocumentUseCase;
  final UploadDocumentUseCase uploadDocumentUseCase;

  DocumentBloc({
    required this.getDocumentsUseCase,
    required this.createDocumentUseCase,
    required this.updateDocumentUseCase,
    required this.deleteDocumentUseCase,
    required this.uploadDocumentUseCase,
  }) : super(const DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<CreateDocument>(_onCreateDocument);
    on<UpdateDocument>(_onUpdateDocument);
    on<DeleteDocument>(_onDeleteDocument);
    on<UploadDocument>(_onUploadDocument);
  }

  Future<void> _onLoadDocuments(
    LoadDocuments event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await getDocumentsUseCase(
      clinicalRecordId: event.clinicalRecordId,
      documentType: event.documentType,
      search: event.search,
    );

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
      (documents) => emit(DocumentsLoaded(documents)),
    );
  }

  Future<void> _onCreateDocument(
    CreateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await createDocumentUseCase(
      clinicalRecordId: event.clinicalRecordId,
      documentType: event.documentType,
      title: event.title,
      description: event.description,
      documentDate: event.documentDate,
      specialty: event.specialty,
      doctorName: event.doctorName,
      doctorLicense: event.doctorLicense,
    );

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
      (document) => emit(DocumentCreated(document)),
    );
  }

  Future<void> _onUpdateDocument(
    UpdateDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await updateDocumentUseCase(
      id: event.id,
      title: event.title,
      description: event.description,
      documentDate: event.documentDate,
      specialty: event.specialty,
      doctorName: event.doctorName,
      doctorLicense: event.doctorLicense,
    );

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
      (document) => emit(DocumentUpdated(document)),
    );
  }

  Future<void> _onDeleteDocument(
    DeleteDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await deleteDocumentUseCase(event.id);

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
      (_) => emit(const DocumentDeleted()),
    );
  }

  Future<void> _onUploadDocument(
    UploadDocument event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());

    final result = await uploadDocumentUseCase(
      clinicalRecordId: event.clinicalRecordId,
      documentType: event.documentType,
      title: event.title,
      documentDate: event.documentDate,
      filePath: event.filePath,
      description: event.description,
      specialty: event.specialty,
      doctorName: event.doctorName,
      doctorLicense: event.doctorLicense,
    );

    result.fold(
      (failure) => emit(DocumentError(failure.message)),
      (document) => emit(DocumentUploaded(document)),
    );
  }
}
