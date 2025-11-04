import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../presentation/bloc/auth_bloc.dart';
import '../../presentation/bloc/auth_event.dart';
import '../../presentation/bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            // Navegar al home
            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingWidget(message: 'Iniciando sesión...');
          }

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.medical_services,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Título
                      Text(
                        'CliniDocs',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Inicia sesión en tu cuenta',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      CustomTextField(
                        label: 'Email',
                        hint: 'ejemplo@hospital.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 20),

                      // Password Field
                      CustomTextField(
                        label: 'Contraseña',
                        hint: '••••••••',
                        controller: _passwordController,
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 12),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implementar recuperación de contraseña
                          },
                          child: Text(
                            '¿Olvidaste tu contraseña?',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      CustomButton(
                        text: 'Iniciar Sesión',
                        onPressed: _handleLogin,
                        icon: Icons.login,
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text('o', style: AppTextStyles.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Demo Credentials
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: AppColors.info,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Credenciales de prueba',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.info,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: doctor1@hospital-santacruz.com',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Contraseña: Doctor123!',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
