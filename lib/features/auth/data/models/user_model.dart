import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.phone,
    super.profileImage,
    required super.role,
    required super.tenantId,
    required super.isActive,
    super.lastLogin,
  });

  /// Crea un UserModel desde JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Manejar role como String o Map
    RoleEntity role;
    final roleData = json['role'];

    if (roleData is String) {
      // Si role viene como String, crear un RoleModel básico
      role = RoleModel(
        id: '', // ID vacío ya que no viene en el JSON
        name: roleData,
        description: null,
        permissions: [],
      );
    } else if (roleData is Map<String, dynamic>) {
      // Si role viene como objeto completo
      role = RoleModel.fromJson(roleData);
    } else {
      // Fallback: rol desconocido
      role = const RoleModel(
        id: '',
        name: 'Usuario',
        description: null,
        permissions: [],
      );
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      profileImage: json['profile_image']?.toString(),
      role: role,
      tenantId: json['tenant_id']?.toString() ?? '',
      isActive: json['is_active'] as bool? ?? true,
      lastLogin: json['last_login'] != null
          ? DateTime.tryParse(json['last_login'].toString())
          : null,
    );
  }

  /// Convierte el UserModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'profile_image': profileImage,
      'role': (role as RoleModel).toJson(),
      'tenant_id': tenantId,
      'is_active': isActive,
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  /// Crea una copia con campos actualizados
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phone,
    String? profileImage,
    RoleEntity? role,
    String? tenantId,
    bool? isActive,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      tenantId: tenantId ?? this.tenantId,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    super.description,
    required super.permissions,
  });

  /// Crea un RoleModel desde JSON
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convierte el RoleModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'permissions': permissions,
    };
  }
}
