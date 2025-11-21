import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          final user = state.user;
          // Guardar referencia al bloc para evitar problemas con contextos desactivados
          final authBloc = context.read<AuthBloc>();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              title: const Text('CliniDocs'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Cerrar Sesión',
                  onPressed: () {
                    // Mostrar confirmación antes de cerrar sesión
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Cerrar Sesión'),
                        content: const Text(
                          '¿Estás seguro que deseas cerrar sesión?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              authBloc.add(const AuthLogoutRequested());
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
                  },
                ),
              ],
            ),
            drawer: AppDrawer(
              user: user,
              onLogout: () {
                authBloc.add(const AuthLogoutRequested());
              },
            ),
            body: _buildDashboard(context, user),
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildDashboard(BuildContext context, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bienvenida
          _buildWelcomeSection(user),
          const SizedBox(height: 24),

          // Cards de acceso rápido
          _buildQuickAccessCards(context),
          const SizedBox(height: 24),

          // Estadísticas
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                _getInitials(user.fullName),
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('¡Hola, ${user.firstName}!', style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(
                    user.role?.name ?? 'Sin rol',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accesos Rápidos', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildQuickAccessCard(
              context,
              icon: Icons.people_alt_outlined,
              title: 'Pacientes',
              color: Colors.blue,
              onTap: () => Navigator.pushNamed(context, '/patients'),
            ),
            _buildQuickAccessCard(
              context,
              icon: Icons.medical_services_outlined,
              title: 'Historias Clínicas',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/clinical-records'),
            ),
            _buildQuickAccessCard(
              context,
              icon: Icons.description_outlined,
              title: 'Crear Documento',
              color: Colors.orange,
              onTap: () => Navigator.pushNamed(context, '/document-create'),
            ),
            _buildQuickAccessCard(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Agenda',
              color: Colors.purple,
              onTap: () => _showComingSoon(context, 'Agenda'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Reducido de 16 a 12
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reducido de 12 a 10
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ), // Reducido de 32 a 28
              ),
              const SizedBox(height: 8), // Reducido de 12 a 8
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Permitir 2 líneas si el texto es largo
                overflow: TextOverflow.ellipsis, // Agregar elipsis si sobrepasa
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Resumen de Hoy', style: AppTextStyles.h3),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Pacientes',
                value: '24',
                icon: Icons.people_outline,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Consultas',
                value: '12',
                icon: Icons.event_note,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: AppTextStyles.h2.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// Código antiguo movido aquí como backup
class _OldHomePage extends StatelessWidget {
  const _OldHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CliniDocs'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: () {})],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        },
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            final user = state.user;

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mensaje de bienvenida
                    Text(
                      '¡Bienvenido!',
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Nombre del usuario
                    Text(
                      user.fullName,
                      style: AppTextStyles.h2.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Email
                    Text(
                      user.email,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Rol
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        user.role?.name ?? 'Sin rol',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Card de información
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 64,
                              color: AppColors.success,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '¡Login Exitoso!',
                              style: AppTextStyles.h3,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Has iniciado sesión correctamente en CliniDocs Mobile.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '🎉 Sprint 1 Completado al 80% 🎉',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de cerrar sesión
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
