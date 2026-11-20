import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/security_entities.dart';
import '../controllers/security_controller.dart';

/// Submódulo 2: Control de Acceso Basado en Roles (RBAC)
/// - Matriz de roles del sistema, descripción y acceso a módulos (Lectura, Escritura, Eliminación)
/// - Rol 'Super Admin' por defecto con acceso total garantizado
/// - Modal para crear/editar roles con checkboxes por módulo y autenticación con contraseña de Super Admin
/// - Altura fija por fila (dataRowMinHeight: 48) y celdas alineadas a la izquierda (Alignment.centerLeft)
/// - Herencia estricta de Theme.of(context)
class ControlRbacView extends StatelessWidget {
  final SecurityController controller;

  const ControlRbacView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final roles = controller.customRoles;
        final matrix = controller.rbacMatrix;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera y Botón de Creación de Rol
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Matriz de Control de Acceso Basado en Roles (RBAC)',
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ) ??
                              const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Matriz de permisos granulares por módulo (Lectura, Escritura, Eliminación) y gestión de roles.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ) ??
                              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_person, size: 14, color: theme.colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'RLS Policy Engine: ACTIVO',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        icon: const Icon(Icons.add_moderator, size: 18),
                        label: const Text('Crear Rol Personalizado'),
                        onPressed: () => _abrirModalRol(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner de Mensaje / Error
              if (controller.successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.optimalBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.optimal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.optimal, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.successMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.optimalText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.optimal),
                        onPressed: () => controller.clearMessages(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (controller.failure != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.criticalBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.critical, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.failure!.message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.criticalText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.critical),
                        onPressed: () => controller.clearMessages(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Tabla de Roles Base y Personalizados
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Roles del Sistema y Cobertura Operativa',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 10),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                dataRowMinHeight: 48,
                                dataRowMaxHeight: 54,
                                horizontalMargin: 16,
                                columnSpacing: 20,
                                headingRowColor: WidgetStateProperty.all(
                                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('ROL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('DESCRIPCIÓN OPERATIVA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('TIPO DE ROL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('PERMISOS ACTIVOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('ACCIONES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                ],
                                rows: roles.map((role) {
                                  final totalPermisos = role.permisos.values.where((p) => p.lectura || p.escritura || p.eliminacion).length;

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            role.nombre,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            role.descripcion,
                                            style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: role.esSuperAdmin ? const Color(0xFFF3E8FF) : AppColors.primaryContainer,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              role.esSuperAdmin ? '★ Super Admin (Base)' : 'Rol Operativo',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: role.esSuperAdmin ? const Color(0xFF6B21A8) : AppColors.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            '$totalPermisos / ${role.permisos.length} módulos',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              textStyle: const TextStyle(fontSize: 11.5),
                                            ),
                                            icon: const Icon(Icons.security, size: 14),
                                            label: const Text('Gestionar'),
                                            onPressed: () => _abrirModalRol(context, rolExistente: role),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Matriz Granular por Fila (Para inspección detallada)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.grid_view_rounded, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Matriz Comparativa de Privilegios por Perfil',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 10),

                      LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                              child: DataTable(
                                dataRowMinHeight: 48,
                                dataRowMaxHeight: 52,
                                horizontalMargin: 16,
                                columnSpacing: 24,
                                headingRowColor: WidgetStateProperty.all(
                                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                ),
                                columns: const [
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('MÓDULO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('ACCIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Center(
                                      child: Text('Admin TI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Center(
                                      child: Text('Administrador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Center(
                                      child: Text('Vendedor/Cajero', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Center(
                                      child: Text('Inventariador', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                                    ),
                                  ),
                                ],
                                rows: List.generate(matrix.length, (index) {
                                  final item = matrix[index];

                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(item.modulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ),
                                      ),
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(item.permiso, style: const TextStyle(fontSize: 12)),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: item.adminTi,
                                            onChanged: (val) {
                                              if (val != null) {
                                                controller.toggleRbacPermission(
                                                  index: index,
                                                  roleKey: 'adminTi',
                                                  newValue: val,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: item.administrador,
                                            onChanged: (val) {
                                              if (val != null) {
                                                controller.toggleRbacPermission(
                                                  index: index,
                                                  roleKey: 'administrador',
                                                  newValue: val,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: item.vendedorCajero,
                                            onChanged: (val) {
                                              if (val != null) {
                                                controller.toggleRbacPermission(
                                                  index: index,
                                                  roleKey: 'vendedorCajero',
                                                  newValue: val,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Center(
                                          child: Checkbox(
                                            value: item.inventariador,
                                            onChanged: (val) {
                                              if (val != null) {
                                                controller.toggleRbacPermission(
                                                  index: index,
                                                  roleKey: 'inventariador',
                                                  newValue: val,
                                                );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          );
                        },
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

  void _abrirModalRol(BuildContext context, {RoleDefinitionEntity? rolExistente}) {
    showDialog(
      context: context,
      builder: (ctx) => _RolPermisosDialog(
        controller: controller,
        rolExistente: rolExistente,
      ),
    );
  }
}

/// Diálogo para Crear / Editar Roles con Checkboxes de Lectura, Escritura, Eliminación
/// y autenticación con contraseña del Super Admin
class _RolPermisosDialog extends StatefulWidget {
  final SecurityController controller;
  final RoleDefinitionEntity? rolExistente;

  const _RolPermisosDialog({
    required this.controller,
    this.rolExistente,
  });

  @override
  State<_RolPermisosDialog> createState() => _RolPermisosDialogState();
}

class _RolPermisosDialogState extends State<_RolPermisosDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _descCtrl;
  final _passwordSuperAdminCtrl = TextEditingController();

  late Map<String, ModulePermission> _permisos;
  String? _authError;
  bool _obscure = true;

  final List<String> _modulosDisponibles = const [
    'Seguridad y Accesos',
    'Administración',
    'Compras y Almacén',
    'Punto de Venta POS',
    'Kárdex PEPS',
    'Reportes Analíticos',
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.rolExistente;
    _nombreCtrl = TextEditingController(text: r?.nombre ?? '');
    _descCtrl = TextEditingController(text: r?.descripcion ?? '');

    _permisos = {};
    for (final m in _modulosDisponibles) {
      if (r != null && r.permisos.containsKey(m)) {
        _permisos[m] = r.permisos[m]!;
      } else {
        _permisos[m] = ModulePermission(modulo: m);
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    _passwordSuperAdminCtrl.dispose();
    super.dispose();
  }

  void _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final pass = _passwordSuperAdminCtrl.text.trim();
    if (pass.isEmpty) {
      setState(() => _authError = 'Ingrese la contraseña de Super Admin para autorizar');
      return;
    }

    final success = await widget.controller.saveRoleWithSuperAdminPassword(
      roleName: _nombreCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      permissions: _permisos,
      superAdminPassword: pass,
      roleId: widget.rolExistente?.id,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() {
        _authError = widget.controller.failure?.message ?? 'Contraseña de Super Admin incorrecta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.rolExistente != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.admin_panel_settings_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(isEditing ? 'Configurar Permisos del Rol' : 'Crear Nuevo Rol RBAC'),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_authError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _authError!,
                      style: const TextStyle(color: AppColors.criticalText, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Rol *',
                    hintText: 'Ej: Auditor Externo, Supervisor de Caja',
                    prefixIcon: Icon(Icons.badge_outlined, size: 18),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese un nombre de rol' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Descripción del Alcance Operativo',
                    hintText: 'Describe las responsabilidades del rol',
                    prefixIcon: Icon(Icons.description_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Asignación de Privilegios por Módulo (Lectura, Escritura, Eliminación):',
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // Tabla de Permisos por Módulo
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: _modulosDisponibles.map((m) {
                      final p = _permisos[m]!;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(m, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: p.lectura,
                                      onChanged: (val) {
                                        setState(() => _permisos[m] = p.copyWith(lectura: val ?? false));
                                      },
                                    ),
                                    const Text('Lectura', style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: p.escritura,
                                      onChanged: (val) {
                                        setState(() => _permisos[m] = p.copyWith(escritura: val ?? false));
                                      },
                                    ),
                                    const Text('Escritura', style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: p.eliminacion,
                                      onChanged: (val) {
                                        setState(() => _permisos[m] = p.copyWith(eliminacion: val ?? false));
                                      },
                                    ),
                                    const Text('Eliminación', style: TextStyle(fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 18),

                // Autenticación con Contraseña de Super Admin
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.vpn_key, size: 16, color: AppColors.primary),
                          SizedBox(width: 6),
                          Text(
                            'Seguridad: Toda modificación de RBAC exige autenticación Super Admin',
                            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordSuperAdminCtrl,
                        obscureText: _obscure,
                        decoration: InputDecoration(
                          labelText: 'Contraseña de Super Admin *',
                          prefixIcon: const Icon(Icons.lock, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _guardar,
          child: const Text('Guardar y Aplicar Permisos'),
        ),
      ],
    );
  }
}
