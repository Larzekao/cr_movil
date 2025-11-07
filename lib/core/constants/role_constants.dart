/// Constantes de roles del sistema
class RoleConstants {
  // Roles fijos del sistema
  static const String asu = 'ASU';
  static const String adminTI = 'Administrador TI';

  // Roles personalizados comunes (creados por Admin TI)
  static const String doctor = 'Doctor';
  static const String enfermera = 'Enfermera';
  static const String recepcionista = 'Recepcionista';
  static const String administrativo = 'Administrativo';

  /// Verifica si un rol es administrador del sistema
  static bool isSystemAdmin(String? roleName) {
    return roleName == asu;
  }

  /// Verifica si un rol es administrador del tenant
  static bool isTenantAdmin(String? roleName) {
    return roleName == adminTI;
  }

  /// Verifica si un rol tiene privilegios administrativos
  static bool isAdmin(String? roleName) {
    return isSystemAdmin(roleName) || isTenantAdmin(roleName);
  }

  /// Verifica si un rol es personal médico
  static bool isMedicalStaff(String? roleName) {
    return roleName == doctor || roleName == enfermera;
  }
}
