import 'package:flutter/material.dart';
import '../../domain/entities/security_entities.dart';
import '../controllers/security_controller.dart';

/// Submódulo 4: Geolocalización y Monitoreo de Sesiones Activas
/// Cumple con las directrices de ciberseguridad, herencia estricta de Theme.of(context),
/// filas con dataRowMinHeight: 48 y alineación Alignment.centerLeft.
class MonitoreoSesionesView extends StatelessWidget {
  final SecurityController controller;

  const MonitoreoSesionesView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final sessions = controller.sessions;
        final totalSessions = sessions.length;
        final desktopCount = sessions
            .where((s) => s.deviceType == DeviceType.pc || s.deviceType == DeviceType.laptop)
            .length;
        final mobileCount = sessions
            .where((s) => s.deviceType == DeviceType.smartphone || s.deviceType == DeviceType.tablet)
            .length;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CABECERA DEL SUBMÓDULO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Geolocalización y Monitoreo de Sesiones Activas',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Telemetría en tiempo real de tokens JWT emitidos, dispositivos conectados y expulsión remota inmediata.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Actualizar Telemetría'),
                    onPressed: () => controller.loadSessions(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. RESUMEN DE CONECTIVIDAD (4 TARJETAS TELEMÉTRICAS)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  final cards = [
                    _buildKpiCard(
                      context: context,
                      title: 'Sesiones Activas',
                      value: '$totalSessions',
                      subtitle: 'Tokens JWT con validez RLS',
                      icon: Icons.cell_tower,
                      color: colorScheme.primary,
                      badge: 'EN VIVO',
                    ),
                    _buildKpiCard(
                      context: context,
                      title: 'Equipos Escritorio',
                      value: '$desktopCount',
                      subtitle: 'Workstations y Laptops',
                      icon: Icons.computer,
                      color: colorScheme.secondary,
                      badge: 'SEGURO',
                    ),
                    _buildKpiCard(
                      context: context,
                      title: 'Terminales Móviles',
                      value: '$mobileCount',
                      subtitle: 'Smartphones y Tablets POS',
                      icon: Icons.devices_other,
                      color: colorScheme.tertiary,
                      badge: 'MONITOREADO',
                    ),
                    _buildKpiCard(
                      context: context,
                      title: 'Geolocalización IP',
                      value: '100% Bolivia',
                      subtitle: 'Santa Cruz / La Guardia',
                      icon: Icons.location_on_outlined,
                      color: colorScheme.primary,
                      badge: 'GEO-FENCE',
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: cards
                          .map((card) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: card,
                                ),
                              ))
                          .toList(),
                    );
                  } else {
                    return Column(
                      children: cards
                          .map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: card,
                              ))
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // 3. TABLA EXHAUSTIVA DE MONITOREO Y EXPULSIÓN REMOTA
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.radar, color: colorScheme.primary, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                'Inventario Forense de Terminales Conectadas',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 8, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'WebSocket Synced',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 900),
                          child: DataTable(
                            horizontalMargin: 16,
                            columnSpacing: 24,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 56,
                            headingRowHeight: 48,
                            headingRowColor: WidgetStateProperty.all(
                              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            ),
                            columns: const [
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('DISPOSITIVO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('OPERADOR CONECTADO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('DIRECCIÓN IP / RED', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('SISTEMA / NAVEGADOR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('UBICACIÓN APROX.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('INICIO SESIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('ACCIÓN REMOTA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ],
                            rows: sessions.map((session) {
                              return DataRow(
                                cells: [
                                  // 1. Icono dinámico según tipo de dispositivo
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: colorScheme.surfaceContainerHighest,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Icon(
                                              _getDeviceIcon(session.deviceType),
                                              size: 18,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _getDeviceLabel(session.deviceType),
                                            style: textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 2. Operador conectado
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            session.usuarioNombre,
                                            style: textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          Text(
                                            'CI: ${session.usuarioCi}',
                                            style: textTheme.labelSmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 3. Dirección IP
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.language, size: 14, color: colorScheme.onSurfaceVariant),
                                          const SizedBox(width: 6),
                                          Text(
                                            session.ipAddress,
                                            style: textTheme.bodySmall?.copyWith(
                                              fontFamily: 'Consolas',
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 4. Sistema Operativo y Navegador
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '${session.sistemaOperativo} • ${session.navegador}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 5. Ubicación aproximada
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.pin_drop, size: 14, color: colorScheme.error),
                                          const SizedBox(width: 4),
                                          Text(
                                            session.ubicacionAproximada,
                                            style: textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 6. Hora de inicio
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        session.fechaInicio.toString().substring(11, 19),
                                        style: textTheme.bodySmall?.copyWith(fontFamily: 'Consolas'),
                                      ),
                                    ),
                                  ),
                                  // 7. Acción: Matar Sesión
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: colorScheme.errorContainer,
                                          foregroundColor: colorScheme.onErrorContainer,
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          elevation: 0,
                                        ),
                                        icon: const Icon(Icons.power_settings_new, size: 15),
                                        label: const Text('Matar Sesión', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                        onPressed: () => _confirmKillSession(context, session),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
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

  static IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.pc:
        return Icons.desktop_windows_outlined;
      case DeviceType.laptop:
        return Icons.laptop_chromebook_outlined;
      case DeviceType.tablet:
        return Icons.tablet_mac_outlined;
      case DeviceType.smartphone:
        return Icons.smartphone_outlined;
    }
  }

  static String _getDeviceLabel(DeviceType type) {
    switch (type) {
      case DeviceType.pc:
        return 'PC Escritorio';
      case DeviceType.laptop:
        return 'Laptop';
      case DeviceType.tablet:
        return 'Tablet POS';
      case DeviceType.smartphone:
        return 'Smartphone';
    }
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              subtitle,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmKillSession(BuildContext context, SessionEntity session) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, size: 36, color: colorScheme.error),
        title: const Text('¿Revocar Sesión Remota?'),
        content: Text(
          'Se expulsará al usuario "${session.usuarioNombre}" (IP: ${session.ipAddress}) y su token JWT será invalidado en Supabase de forma inmediata.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Confirmar Expulsión'),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ok = await controller.killSession(session.jti);
      if (ok && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colorScheme.error,
            content: Text('Sesión de ${session.usuarioNombre} revocada exitosamente. Usuario expulsado al login.'),
          ),
        );
      }
    }
  }
}
