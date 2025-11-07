import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class UserModel extends UserEntity {
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final RoleModel? role;

  const UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String fullName,
    this.role,
    required bool isActive,
  }) : super(
         id: id,
         email: email,
         firstName: firstName,
         lastName: lastName,
         fullName: fullName,
         role: role,
         isActive: isActive,
       );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Parse role de forma muy defensiva
    RoleModel? role;

    try {
      final roleValue = json['role'];
      final roleNameValue = json['role_name'];

      // Caso 1: role es un Map completo con id y name
      if (roleValue is Map<String, dynamic>) {
        role = RoleModel.fromJson(roleValue);
      }
      // Caso 2: role es String (UUID) y role_name existe
      else if (roleValue is String && roleNameValue is String) {
        role = RoleModel(id: roleValue, name: roleNameValue);
      }
      // Caso 3: Cualquier otro caso, role = null
      else {
        role = null;
      }
    } catch (e) {
      // Si hay error parseando el role, continuar con role null
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
  const RoleModel({required String id, required String name})
    : super(id: id, name: name);

  factory RoleModel.fromJson(Map<String, dynamic> json) =>
      _$RoleModelFromJson(json);

  Map<String, dynamic> toJson() => _$RoleModelToJson(this);
}
