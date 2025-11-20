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
      print('⚠️ Error parsing role: $e');
      role = null;
    }

    try {
      // Parseo robusto con conversión de tipos
      final id = _parseString(json['id']);
      final email = _parseString(json['email']);
      final firstName = _parseString(json['first_name']);
      final lastName = _parseString(json['last_name']);
      final fullName = _parseString(json['full_name']) ?? 'Usuario';
      final isActive = _parseBool(json['is_active']) ?? true;

      print('✅ User parsed - ID: $id, Email: $email, Active: $isActive');

      return UserModel(
        id: id ?? '',
        email: email ?? '',
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        fullName: fullName,
        role: role,
        isActive: isActive,
      );
    } catch (e, stackTrace) {
      print('❌ Error creating UserModel: $e');
      print('📋 JSON: $json');
      print('📍 StackTrace: $stackTrace');
      rethrow;
    }
  }

  // Helpers para parseo robusto
  static String? _parseString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    return value.toString();
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value == 1;
    return null;
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
