import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/security_controller.dart';

/// Vista: Dashboard de Seguridad y Accesos
class SeguridadDashboardView extends StatelessWidget {
  final SecurityController controller;

  const SeguridadDashboardView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final kpis = controller.kpis;
        final policy = controller.nistPolicy;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FILA DE 4 TARJETAS KPI
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Total Usuarios',
                      value: '${kpis?.totalUsuarios ?? 11}',
                      subtitle: 'Usuarios activos en BD',
                      icon: Icons.people_outline,
                      color: AppColors.primary,
                      badge: 'OPERATIVO',
                      badgeBg: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Bloqueos 24h',
                      value: '${kpis?.bloqueos24h ?? 3}',
                      subtitle: 'Ataques fuerza bruta prevenidos',
                      icon: Icons.gpp_bad_outlined,
                      color: AppColors.critical,
                      badge: 'CRÍTICO',
                      badgeBg: AppColors.criticalBg,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Sesiones JWT',
                      value: '${kpis?.sesionesJwtActivas ?? 4}',
                      subtitle: 'Tokens activos con RLS',
                      icon: Icons.token_outlined,
                      color: AppColors.warning,
                      badge: 'EN VIVO',
                      badgeBg: AppColors.warningBg,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Integridad WORM',
                      value: '${kpis?.integridadWormPorcentaje ?? 100.0}%',
                      subtitle: 'ISO 27001 Sin Alteraciones',
                      icon: Icons.verified_user_outlined,
                      color: AppColors.optimal,
                      badge: 'ÓPTIMO',
                      badgeBg: AppColors.optimalBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. PANEL DE POLÍTICA DE CONTRASEÑAS NIST SP 800-63B
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Política de Contraseñas NIST SP 800-63B',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.optimalBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'POLÍTICA ACTIVA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.optimalText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ajusta los parámetros exigidos a todos los operadores del sistema para cumplimiento de auditoría.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.borderLight),
                      const SizedBox(height: 16),

                      // Slider interactivo de longitud
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Expanded(
                                      child: Text(
                                        'Longitud Mínima de Caracteres:',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${policy.minLength} caracteres',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: policy.minLength.toDouble(),
                                  min: 8,
                                  max: 24,
                                  divisions: 16,
                                  label: '${policy.minLength}',
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    controller.updateNistPolicy(minLength: val.toInt());
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 32),

                          // Switches de complejidad
                          Expanded(
                            flex: 6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildSwitchOption(
                                  label: 'Mayúsculas (A-Z)',
                                  value: policy.requireUppercase,
                                  onChanged: (v) =>
                                      controller.updateNistPolicy(requireUppercase: v),
                                ),
                                _buildSwitchOption(
                                  label: 'Números (0-9)',
                                  value: policy.requireNumbers,
                                  onChanged: (v) =>
                                      controller.updateNistPolicy(requireNumbers: v),
                                ),
                                _buildSwitchOption(
                                  label: r'Símbolos (@$#)',
                                  value: policy.requireSymbols,
                                  onChanged: (v) =>
                                      controller.updateNistPolicy(requireSymbols: v),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. DATA TABLE DE SESIONES ACTIVAS
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.devices_outlined, color: AppColors.primary, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'Sesiones Activas en Tiempo Real (JWT)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Actualizar'),
                            onPressed: () => controller.loadSessions(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Control forense de accesos concurrentes. Permite revocar credenciales comprometidas.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 16),

                      // Tabla de Sesiones
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          horizontalMargin: 16,
                          columnSpacing: 24,
                          headingRowColor: WidgetStateProperty.all(AppColors.background),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'IP ORIGEN',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'USUARIO / CI',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'NAVEGADOR / SO',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'IDENTIFICADOR JTI',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'INICIO',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'ACCIÓN',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                          rows: controller.sessions.map((session) {
                            return DataRow(
                              cells: [
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.wifi, size: 15, color: AppColors.optimal),
                                      const SizedBox(width: 6),
                                      Text(
                                        session.ipAddress,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        session.usuarioNombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                      Text(
                                        'CI: ${session.usuarioCi}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.public, size: 16, color: AppColors.textSecondary),
                                      const SizedBox(width: 6),
                                      Text(session.navegador, style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    session.jti,
                                    style: const TextStyle(
                                      fontFamily: 'Consolas',
                                      fontSize: 11.5,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${session.fechaInicio.hour}:${session.fechaInicio.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.critical,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                    ),
                                    icon: const Icon(Icons.block, size: 14),
                                    label: const Text('Revocar'),
                                    onPressed: () {
                                      controller.revokeSession(session.jti, session.usuarioCi);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppColors.critical,
                                          content: Text('Sesión ${session.jti} revocada en Supabase.'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
    required Color badgeBg,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchOption({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
