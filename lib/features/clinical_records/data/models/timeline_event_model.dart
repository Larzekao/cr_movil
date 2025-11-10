import '../../domain/entities/timeline_event_entity.dart';

/// Modelo de evento de timeline para serialización
class TimelineEventModel {
  final String type;
  final DateTime date;
  final String title;
  final String? documentType;
  final String? specialty;
  final String? doctorName;
  final String id;

  TimelineEventModel({
    required this.type,
    required this.date,
    required this.title,
    this.documentType,
    this.specialty,
    this.doctorName,
    required this.id,
  });

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) {
    return TimelineEventModel(
      type: json['type']?.toString() ?? 'other',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      title: json['title']?.toString() ?? '',
      documentType: json['document_type']?.toString(),
      specialty: json['specialty']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      id: json['id']?.toString() ?? '',
    );
  }

  TimelineEventEntity toEntity() {
    // Convertir type string a enum
    TimelineEventType eventType;
    switch (type.toLowerCase()) {
      case 'document':
        eventType = TimelineEventType.document;
        break;
      case 'form':
        eventType = TimelineEventType.form;
        break;
      default:
        eventType = TimelineEventType.other;
        break;
    }

    return TimelineEventEntity(
      type: eventType,
      date: date,
      title: title,
      documentType: documentType,
      specialty: specialty,
      doctorName: doctorName,
      id: id,
    );
  }
}
