import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String fullName;
  final RoleEntity? role;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.role,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    fullName,
    role,
    isActive,
  ];
}

class RoleEntity extends Equatable {
  final String id;
  final String name;

  const RoleEntity({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
