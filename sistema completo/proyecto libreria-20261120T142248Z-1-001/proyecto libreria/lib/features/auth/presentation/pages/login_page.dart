import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';

/// Vista responsiva de Inicio de Sesión para Flutter Web.
class LoginPage extends StatelessWidget {
  final AuthController controller;

  const LoginPage({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          if (controller.status == AuthStatus.authenticated &&
              controller.currentUser != null) {
            return _buildAuthenticatedState(context);
          }

          return ResponsiveLayout(
            desktop: (context) => _buildDesktopView(context),
            mobile: (context) => _buildMobileView(context),
          );
        },
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 620),
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Panel lateral de información y marca (Desktop)
              Expanded(
                flex: 5,
                child: Container(
                  padding: const EdgeInsets.all(48),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, Color(0xFF172554)],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.cloud_done_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'SISTEMA WEB',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Plataforma Empresarial Segura',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Desarrollada con Clean Architecture, Feature-First y Arquitectura Basada en Eventos (EDA).',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 16,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '© 2026 Todos los derechos reservados',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Formulario de Inicio de Sesión
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Center(
                    child: SingleChildScrollView(
                      child: LoginForm(controller: controller),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: LoginForm(controller: controller),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticatedState(BuildContext context) {
    final user = controller.currentUser!;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.optimal,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  '¡Autenticación Exitosa!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Bienvenido, ${user.name}',
                  style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rol: ${user.role} | Email: ${user.email}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Text(
                    'Evento DomainEvent "UserLoggedInEvent" emitido con éxito al AppEventBus.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
