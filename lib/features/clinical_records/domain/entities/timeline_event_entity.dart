import 'package:equatable/equatable.dart';

/// Tipos de eventos en el timeline
enum TimelineEventType { document, form, other }

/// Entidad que representa un evento en el timeline de una historia clínica
class TimelineEventEntity extends Equatable {
  final TimelineEventType type;
  final DateTime date;
  final String title;
  final String? documentType;
  final String? specialty;
  final String? doctorName;
  final String id;

  const TimelineEventEntity({
    required this.type,
    required this.date,
    required this.title,
    this.documentType,
    this.specialty,
    this.doctorName,
    required this.id,
  });

  @override
  List<Object?> get props => [
    type,
    date,
    title,
    documentType,
    specialty,
    doctorName,
    id,
  ];
}
