import 'package:flutter/material.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../constants/role_constants.dart';

/// Drawer (menú lateral) adaptativo según el rol del usuario
class AppDrawer extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onLogout;

  const AppDrawer({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final roleName = user.role?.name;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildHeader(context),
          const Divider(),
          ..._buildMenuItems(context, roleName),
          const Divider(),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  /// Header del drawer con información del usuario
  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        child: Text(
          _getInitials(user.fullName),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
      accountName: Text(
        user.fullName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      accountEmail: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(user.email),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.role?.name ?? 'Sin rol',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los items del menú según el rol
  List<Widget> _buildMenuItems(BuildContext context, String? roleName) {
    final List<Widget> items = [];

    // Panel de Control - disponible para todos
    items.add(
      _buildMenuItem(
        context,
        icon: Icons.dashboard_outlined,
        title: 'Panel de Control',
        onTap: () => Navigator.pop(context),
      ),
    );

    // Usuarios - solo para administradores
    if (RoleConstants.isAdmin(roleName)) {
      items.add(
        _buildMenuItem(
          context,
          icon: Icons.people_outline,
          title: 'Usuarios',
          onTap: () {
            Navigator.pop(context);
            _showComingSoon(context, 'Usuarios');
          },
        ),
      );
    }

    // Roles y Permisos - solo para administradores
    if (RoleConstants.isAdmin(roleName)) {
      items.add(
        _buildMenuItem(
          context,
          icon: Icons.admin_panel_settings_outlined,
          title: 'Roles y Permisos',
          onTap: () {
            Navigator.pop(context);
            _showComingSoon(context, 'Roles y Permisos');
          },
        ),
      );
    }

    // Pacientes - disponible para médicos, recepcionistas y administradores
    if (RoleConstants.isMedicalStaff(roleName) ||
        roleName == RoleConstants.recepcionista ||
        RoleConstants.isAdmin(roleName)) {
      items.add(
        _buildMenuItem(
          context,
          icon: Icons.people_alt_outlined,
          title: 'Pacientes',
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/patients');
          },
        ),
      );
    }

    // Documentos - disponible para médicos y administradores
    if (RoleConstants.isMedicalStaff(roleName) ||
        RoleConstants.isAdmin(roleName)) {
      items.add(
        _buildMenuItem(
          context,
          icon: Icons.description_outlined,
          title: 'Documentos',
          onTap: () {
            Navigator.pop(context);
            _showComingSoon(context, 'Documentos');
          },
        ),
      );
    }

    // Reportes - solo para administradores
    if (RoleConstants.isAdmin(roleName)) {
      items.add(
        _buildMenuItem(
          context,
          icon: Icons.assessment_outlined,
          title: 'Reportes',
          onTap: () {
            Navigator.pop(context);
            _showComingSoon(context, 'Reportes');
          },
        ),
      );
    }

    // Configuración - disponible para todos
    items.add(
      _buildMenuItem(
        context,
        icon: Icons.settings_outlined,
        title: 'Configuración',
        onTap: () {
          Navigator.pop(context);
          _showComingSoon(context, 'Configuración');
        },
      ),
    );

    return items;
  }

  /// Item individual del menú
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  /// Item de cerrar sesión
  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.red),
      title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
      onTap: () {
        Navigator.pop(context);
        _showLogoutConfirmation(context);
      },
    );
  }

  /// Obtiene las iniciales del nombre
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  /// Muestra confirmación de logout
  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onLogout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  /// Muestra mensaje de "próximamente"
  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
