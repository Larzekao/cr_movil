import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? profileImage;
  final RoleEntity role;
  final String tenantId;
  final bool isActive;
  final DateTime? lastLogin;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.profileImage,
    required this.role,
    required this.tenantId,
    required this.isActive,
    this.lastLogin,
  });

  String get fullName => '$firstName $lastName';

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    phone,
    profileImage,
    role,
    tenantId,
    isActive,
    lastLogin,
  ];
}

class RoleEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final List<String> permissions;

  const RoleEntity({
    required this.id,
    required this.name,
    this.description,
    required this.permissions,
  });

  @override
  List<Object?> get props => [id, name, description, permissions];
}
