import 'package:flutter/material.dart';
import '../controllers/security_controller.dart';
import 'gestion_usuarios_view.dart';
import 'control_rbac_view.dart';
import 'politicas_seguridad_view.dart';
import 'monitoreo_sesiones_view.dart';
import 'bitacora_worm_view.dart';
import 'mantenimiento_respaldos_view.dart';

/// Vista Contenedora Principal: Módulo de Seguridad y Accesos
/// Unifica los 6 submódulos de Ciberseguridad mediante una navegación limpia por Tabs horizontales.
/// Respeta rigurosamente:
/// - Herencia estricta de Theme.of(context) (sin colores hardcodeados)
/// - Desacoplamiento arquitectónico
/// - Estándar de tablas (dataRowMinHeight: 48, Alignment.centerLeft)
class ModuloSeguridadView extends StatefulWidget {
  final SecurityController controller;
  final int initialTabIndex;

  const ModuloSeguridadView({
    super.key,
    required this.controller,
    this.initialTabIndex = 0,
  });

  @override
  State<ModuloSeguridadView> createState() => _ModuloSeguridadViewState();
}

class _ModuloSeguridadViewState extends State<ModuloSeguridadView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<({String title, IconData icon, String subtitle})> _tabs = [
    (
      title: '1. Usuarios y Personal',
      icon: Icons.people_alt_outlined,
      subtitle: 'CRUD, validaciones y purga maestra'
    ),
    (
      title: '2. Control RBAC',
      icon: Icons.admin_panel_settings_outlined,
      subtitle: 'Matriz granular y roles'
    ),
    (
      title: '3. Políticas y Concurrencia',
      icon: Icons.security_outlined,
      subtitle: 'NIST SP 800-63B y bloqueos'
    ),
    (
      title: '4. Sesiones y Geolocalización',
      icon: Icons.devices_outlined,
      subtitle: 'Telemetría y matar sesión'
    ),
    (
      title: '5. Bitácora WORM',
      icon: Icons.history_edu_outlined,
      subtitle: 'ISO 27001 forense e inmutable'
    ),
    (
      title: '6. Respaldos y Recovery',
      icon: Icons.backup_outlined,
      subtitle: 'Snapshots y Disaster Recovery'
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, _tabs.length - 1),
    );
  }

  @override
  void didUpdateWidget(covariant ModuloSeguridadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabController.animateTo(widget.initialTabIndex.clamp(0, _tabs.length - 1));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. HEADER DEL MÓDULO CON NAVEGACIÓN POR TABS HORIZONTALES
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
          ),
          elevation: 0,
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.shield_outlined, color: colorScheme.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Módulo de Ciberseguridad y Control de Accesos',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Arquitectura Defensiva • NIST SP 800-63B • ISO/IEC 27001 • RLS Engine',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, size: 12, color: colorScheme.primary),
                          const SizedBox(width: 6),
                          Text(
                            'SuperAdmin Verified',
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
              ),
              const Divider(height: 1),

              // TAB BAR HORIZONTAL
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                tabs: _tabs.map((tab) {
                  return Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(tab.icon, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          tab.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. CONTENIDO DEL SUBMÓDULO SELECCIONADO
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Submódulo 1: Gestión de Usuarios y Personal
              GestionUsuariosView(controller: widget.controller),

              // Submódulo 2: Control de Acceso Basado en Roles (RBAC)
              ControlRbacView(controller: widget.controller),

              // Submódulo 3: Políticas de Contraseñas, Bloqueo y Concurrencia
              PoliticasSeguridadView(controller: widget.controller),

              // Submódulo 4: Geolocalización y Monitoreo de Sesiones Activas
              MonitoreoSesionesView(controller: widget.controller),

              // Submódulo 5: Bitácora Forense Inmutable (WORM) y Auditoría
              BitacoraWormView(controller: widget.controller),

              // Submódulo 6: Respaldos y Disaster Recovery
              MantenimientoRespaldosView(controller: widget.controller),
            ],
          ),
        ),
      ],
    );
  }
}
