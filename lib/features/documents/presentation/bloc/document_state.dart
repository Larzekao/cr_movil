import 'package:equatable/equatable.dart';
import '../../domain/entities/document_entity.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();
  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

class DocumentsLoaded extends DocumentState {
  final List<DocumentEntity> documents;
  const DocumentsLoaded(this.documents);
  @override
  List<Object?> get props => [documents];
}

class DocumentLoaded extends DocumentState {
  final DocumentEntity document;
  const DocumentLoaded(this.document);
  @override
  List<Object?> get props => [document];
}

class DocumentCreated extends DocumentState {
  final DocumentEntity document;
  const DocumentCreated(this.document);
  @override
  List<Object?> get props => [document];
}

class DocumentUpdated extends DocumentState {
  final DocumentEntity document;
  const DocumentUpdated(this.document);
  @override
  List<Object?> get props => [document];
}

class DocumentDeleted extends DocumentState {
  const DocumentDeleted();
}

class DocumentUploaded extends DocumentState {
  final DocumentEntity document;
  const DocumentUploaded(this.document);
  @override
  List<Object?> get props => [document];
}

class DocumentError extends DocumentState {
  final String message;
  const DocumentError(this.message);
  @override
  List<Object?> get props => [message];
}
