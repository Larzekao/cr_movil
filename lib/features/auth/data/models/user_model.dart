import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class UserModel extends UserEntity {
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final RoleModel? role;

  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.fullName,
    this.role,
    required super.isActive,
  }) : super(
         role: role,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse role de forma muy defensiva
    RoleModel? role;

    try {
      final roleValue = json['role'];
      final roleNameValue = json['role_name'];

      // Caso 1: role es null - mantener como null
      if (roleValue == null) {
        role = null;
      }
      // Caso 2: role es un Map completo con id y name
      else if (roleValue is Map<String, dynamic>) {
        // Verificar que tenga los campos necesarios antes de parsear
        if (roleValue.containsKey('id') && roleValue.containsKey('name')) {
          role = RoleModel.fromJson(roleValue);
        } else {
          role = null;
        }
      }
      // Caso 3: role es String (UUID) y role_name existe
      else if (roleValue is String && roleNameValue is String) {
        role = RoleModel(id: roleValue, name: roleNameValue);
      }
      // Caso 4: Cualquier otro caso, role = null
      else {
        role = null;
      }
    } catch (e) {
      // Si hay error parseando el role, continuar con role null
      // ignore: avoid_print
      // print('Error parsing role: $e');
      role = null;
    }

    try {
      return UserModel(
        id: json['id'] as String? ?? '',
        email: json['email'] as String? ?? '',
        firstName: json['first_name'] as String? ?? '',
        lastName: json['last_name'] as String? ?? '',
        fullName: json['full_name'] as String? ?? 'Usuario',
        role: role,
        isActive: json['is_active'] as bool? ?? true,
      );
    } catch (e) {
      // ignore: avoid_print
      // print('Error creating UserModel: $e');
      // print('JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = _$UserModelToJson(this);
    // Agregar role como string ID y role_name
    if (role != null) {
      json['role'] = role!.id;
      json['role_name'] = role!.name;
    }
    return json;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RoleModel extends RoleEntity {
  const RoleModel({required super.id, required super.name});

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
