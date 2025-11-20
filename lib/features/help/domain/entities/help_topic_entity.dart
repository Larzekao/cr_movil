import 'package:equatable/equatable.dart';

/// Entidad que representa un tema de ayuda
class HelpTopicEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> tags;
  final List<String> roles; // Roles que pueden ver este tema
  final List<HelpStepEntity> steps;

  const HelpTopicEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.tags,
    required this.roles,
    required this.steps,
  });

  @override
  List<Object?> get props => [id, title, description, category, tags, roles, steps];
}

/// Paso dentro de un tema de ayuda
class HelpStepEntity extends Equatable {
  final String title;
  final String description;
  final String? iconName;

  const HelpStepEntity({
    required this.title,
    required this.description,
    this.iconName,
  });

  @override
  List<Object?> get props => [title, description, iconName];
}

/// Categorías de ayuda
class HelpCategory {
  static const String generalUsage = 'Uso General';
  static const String medicalRecords = 'Historias Clínicas';
  static const String forms = 'Formularios';
  static const String ai = 'IA y Mejora de Imágenes';
  static const String permissions = 'Permisos y Accesos';
  static const String patients = 'Gestión de Pacientes';
  static const String users = 'Gestión de Usuarios';
  static const String system = 'Configuración del Sistema';
}
