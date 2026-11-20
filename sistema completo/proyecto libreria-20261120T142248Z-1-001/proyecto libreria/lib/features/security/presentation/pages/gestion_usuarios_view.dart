import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/security_entities.dart';
import '../controllers/security_controller.dart';

/// Submódulo 1: Gestión de Usuarios y Personal
/// Cumple con las reglas de adaptación visual (Theme.of(context)),
/// altura fija por fila (dataRowMinHeight: 48), alineación Alignment.centerLeft,
/// validaciones en tiempo real (toUpperCase, solo letras, solo enteros en CI),
/// detección de duplicados, bloqueo preventivo y purga definitiva con contraseña maestra.
class GestionUsuariosView extends StatelessWidget {
  final SecurityController controller;

  const GestionUsuariosView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final users = controller.users;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera y Botón de Alta
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Directorio de Usuarios y Operadores',
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ) ??
                              const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Control centralizado de identidades, roles RBAC y enmascaramiento de CI.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ) ??
                              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.person_add_alt_1, size: 18),
                    label: const Text('Nuevo Usuario'),
                    onPressed: () => _abrirModalUsuario(context),
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

              // 2. Barra de Búsqueda y Filtros
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          decoration: const InputDecoration(
                            hintText: 'Buscar por CI, Nombre o correo corporativo...',
                            prefixIcon: Icon(Icons.search, size: 20),
                          ),
                          onChanged: (val) => controller.filterUsers(query: val),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: controller.userRoleFilter,
                          decoration: const InputDecoration(
                            labelText: 'Filtrar por Rol',
                            prefixIcon: Icon(Icons.filter_list, size: 20),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Todos', child: Text('Todos los Roles')),
                            DropdownMenuItem(value: 'Superadmin', child: Text('Super Admin')),
                            DropdownMenuItem(value: 'Admin TI', child: Text('Admin TI')),
                            DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                            DropdownMenuItem(value: 'Vendedor/Cajero', child: Text('Vendedor/Cajero')),
                            DropdownMenuItem(value: 'Inventariador', child: Text('Inventariador')),
                          ],
                          onChanged: (val) => controller.filterUsers(rol: val),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. Tabla Estandarizada de Usuarios
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Resultados encontrados: ${users.length} usuarios',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ) ??
                                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Política: CI Enmascarado para privacidad',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 8),

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
                                      child: Text(
                                        'CI ENMASCARADO',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'NOMBRE Y APELLIDO',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'ROL ASIGNADO',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'SUCURSAL',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'ESTADO',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'ACCIONES',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                                      ),
                                    ),
                                  ),
                                ],
                                rows: users.map((user) {
                                  return DataRow(
                                    cells: [
                                      // 1. CI
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            user.ciEnmascarado,
                                            style: const TextStyle(
                                              fontFamily: 'Consolas',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.5,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 2. Nombre y Email
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                user.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12.5,
                                                ),
                                              ),
                                              Text(
                                                user.email,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // 3. Rol
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: _getRoleBgColor(user.rol),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              user.rol,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: _getRoleTextColor(user.rol),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 4. Sucursal
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.storefront, size: 14, color: AppColors.textMuted),
                                              const SizedBox(width: 5),
                                              Text(user.sucursal, style: const TextStyle(fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // 5. Estado (Chip limpio sin desbordamiento)
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: user.activo ? AppColors.optimalBg : AppColors.criticalBg,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              user.activo ? '● ACTIVO' : '● SUSPENDIDO',
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.bold,
                                                color: user.activo ? AppColors.optimalText : AppColors.criticalText,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 6. Acciones (Editar, Bloqueo Switch, Purga Definitiva)
                                      DataCell(
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit_outlined, size: 18),
                                                tooltip: 'Editar datos',
                                                onPressed: () => _abrirModalUsuario(context, usuarioExistente: user),
                                              ),
                                              Tooltip(
                                                message: user.activo ? 'Bloqueo Preventivo (Desactivar)' : 'Habilitar acceso',
                                                child: Switch(
                                                  value: user.activo,
                                                  activeThumbColor: AppColors.optimal,
                                                  inactiveThumbColor: AppColors.critical,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  onChanged: (val) {
                                                    controller.toggleUserStatus(user.id, val);
                                                  },
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete_forever_outlined, size: 18, color: AppColors.critical),
                                                tooltip: 'Eliminar cuenta (Purga Definitiva)',
                                                onPressed: () => _abrirModalPurga(context, user),
                                              ),
                                            ],
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
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // MODAL CREAR / EDITAR USUARIO CON VALIDACIONES EN TIEMPO REAL
  // ===========================================================================
  void _abrirModalUsuario(BuildContext context, {UserSecurityEntity? usuarioExistente}) {
    showDialog(
      context: context,
      builder: (ctx) => _UsuarioFormDialog(
        controller: controller,
        usuarioExistente: usuarioExistente,
      ),
    );
  }

  // ===========================================================================
  // MODAL PURGA DEFINITIVA CON CONTRASEÑA MAESTRA
  // ===========================================================================
  void _abrirModalPurga(BuildContext context, UserSecurityEntity user) {
    showDialog(
      context: context,
      builder: (ctx) => _PurgaUsuarioDialog(
        controller: controller,
        user: user,
      ),
    );
  }

  Color _getRoleBgColor(String rol) {
    switch (rol) {
      case 'Superadmin':
        return const Color(0xFFF3E8FF);
      case 'Admin TI':
        return AppColors.primaryContainer;
      case 'Administrador':
        return const Color(0xFFFEF3C7);
      case 'Vendedor/Cajero':
        return AppColors.optimalBg;
      case 'Inventariador':
        return const Color(0xFFE0E7FF);
      default:
        return AppColors.background;
    }
  }

  Color _getRoleTextColor(String rol) {
    switch (rol) {
      case 'Superadmin':
        return const Color(0xFF6B21A8);
      case 'Admin TI':
        return AppColors.primary;
      case 'Administrador':
        return const Color(0xFFB45309);
      case 'Vendedor/Cajero':
        return AppColors.optimalText;
      case 'Inventariador':
        return const Color(0xFF3730A3);
      default:
        return AppColors.textPrimary;
    }
  }
}

/// Diálogo de Formulario con Validaciones Estrictas (toUpperCase, solo letras, solo enteros en CI, email)
class _UsuarioFormDialog extends StatefulWidget {
  final SecurityController controller;
  final UserSecurityEntity? usuarioExistente;

  const _UsuarioFormDialog({
    required this.controller,
    this.usuarioExistente,
  });

  @override
  State<_UsuarioFormDialog> createState() => _UsuarioFormDialogState();
}

class _UsuarioFormDialogState extends State<_UsuarioFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _ciCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passwordCtrl;
  late String _rolSeleccionado;
  late String _sucursalSeleccionada;

  String? _duplicateError;

  @override
  void initState() {
    super.initState();
    final u = widget.usuarioExistente;
    _nombreCtrl = TextEditingController(text: u?.nombre ?? '');
    _ciCtrl = TextEditingController(text: u?.ci ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _passwordCtrl = TextEditingController(text: u == null ? '' : '********');
    _rolSeleccionado = u?.rol ?? 'Vendedor/Cajero';
    _sucursalSeleccionada = u?.sucursal ?? 'Casa Matriz - La Guardia';
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _guardar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Validación y detección de duplicados contra el controlador
    final duplicate = widget.controller.checkUserDuplicate(
      ci: _ciCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      nombre: _nombreCtrl.text.trim(),
      excludeUserId: widget.usuarioExistente?.id,
    );

    if (duplicate != null) {
      setState(() {
        _duplicateError = 'Conflicto de Duplicidad: $duplicate';
      });
      return;
    }

    if (widget.usuarioExistente != null) {
      // Modo Edición
      widget.controller.updateUser(
        id: widget.usuarioExistente!.id,
        ci: _ciCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim().toUpperCase(),
        email: _emailCtrl.text.trim().toLowerCase(),
        rol: _rolSeleccionado,
        sucursal: _sucursalSeleccionada,
      );
    } else {
      // Modo Creación
      widget.controller.createUser(
        ci: _ciCtrl.text.trim(),
        nombre: _nombreCtrl.text.trim().toUpperCase(),
        email: _emailCtrl.text.trim().toLowerCase(),
        rol: _rolSeleccionado,
        sucursal: _sucursalSeleccionada,
        password: _passwordCtrl.text.trim(),
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.usuarioExistente != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_note : Icons.person_add,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(isEditing ? 'Editar Datos del Personal' : 'Alta de Nuevo Usuario'),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_duplicateError != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.criticalBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _duplicateError!,
                            style: const TextStyle(
                              color: AppColors.criticalText,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 1. Nombre Completo (toUpperCase + solo letras)
                TextFormField(
                  controller: _nombreCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nombre y Apellido Completo *',
                    hintText: 'EJ: HAROLD EASTMAN ROMAY',
                    prefixIcon: Icon(Icons.badge_outlined, size: 18),
                    helperText: 'Solo letras y espacios. Se transforma a MAYÚSCULAS.',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El nombre completo es obligatorio';
                    }
                    if (val.trim().length < 4) {
                      return 'Ingrese al menos 4 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 2. Documento de Identidad (Solo dígitos numéricos 0-9)
                TextFormField(
                  controller: _ciCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Documento de Identidad (CI / DNI) *',
                    hintText: 'EJ: 4625505',
                    prefixIcon: Icon(Icons.fingerprint, size: 18),
                    helperText: 'Solo dígitos enteros (0-9). Prohibido letras o símbolos.',
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El documento de identidad es obligatorio';
                    }
                    if (val.trim().length < 5) {
                      return 'El CI debe tener al menos 5 dígitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 3. Correo Electrónico (Formato estricto)
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo Electrónico Corporativo *',
                    hintText: 'ejemplo@sanmartin.bo',
                    prefixIcon: Icon(Icons.email_outlined, size: 18),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'El correo electrónico es obligatorio';
                    }
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(val.trim())) {
                      return 'Ingrese un formato de correo electrónico válido (ej: usuario@dominio.com)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // 4. Rol RBAC y Sucursal (Adaptativo según resolución de pantalla)
                Builder(
                  builder: (context) {
                    final isCompact = MediaQuery.sizeOf(context).width < 640;

                    final rolDropdown = DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _rolSeleccionado,
                      decoration: const InputDecoration(
                        labelText: 'Rol Asignado *',
                        prefixIcon: Icon(Icons.shield_outlined, size: 18),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Superadmin',
                          child: Text('Super Admin', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Admin TI',
                          child: Text('Admin TI', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Administrador',
                          child: Text('Administrador', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Vendedor/Cajero',
                          child: Text('Vendedor/Cajero', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Inventariador',
                          child: Text('Inventariador', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _rolSeleccionado = val);
                      },
                    );

                    final sucursalDropdown = DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _sucursalSeleccionada,
                      decoration: const InputDecoration(
                        labelText: 'Sede / Sucursal *',
                        prefixIcon: Icon(Icons.storefront, size: 18),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Casa Matriz - La Guardia',
                          child: Text('Casa Matriz - La Guardia', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Agencia Santa Cruz',
                          child: Text('Agencia Santa Cruz', overflow: TextOverflow.ellipsis),
                        ),
                        DropdownMenuItem(
                          value: 'Sede Central Santa Cruz',
                          child: Text('Sede Central Santa Cruz', overflow: TextOverflow.ellipsis),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _sucursalSeleccionada = val);
                      },
                    );

                    if (isCompact) {
                      return Column(
                        children: [
                          rolDropdown,
                          const SizedBox(height: 14),
                          sucursalDropdown,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: rolDropdown),
                        const SizedBox(width: 14),
                        Expanded(child: sucursalDropdown),
                      ],
                    );
                  },
                ),

                if (!isEditing) ...[
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña Provisional *',
                      prefixIcon: Icon(Icons.lock_outline, size: 18),
                      helperText: 'Debe cumplir las directivas de seguridad NIST configuradas.',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().length < 8) {
                        return 'La contraseña debe contener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
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
          child: Text(isEditing ? 'Guardar Cambios' : 'Confirmar Alta'),
        ),
      ],
    );
  }
}

/// Diálogo de Purga Definitiva (Eliminación Crítica) requiriendo Contraseña Maestra
class _PurgaUsuarioDialog extends StatefulWidget {
  final SecurityController controller;
  final UserSecurityEntity user;

  const _PurgaUsuarioDialog({
    required this.controller,
    required this.user,
  });

  @override
  State<_PurgaUsuarioDialog> createState() => _PurgaUsuarioDialogState();
}

class _PurgaUsuarioDialogState extends State<_PurgaUsuarioDialog> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _confirmarPurga() async {
    final password = _passwordCtrl.text.trim();
    if (password.isEmpty) {
      setState(() => _error = 'Ingrese su contraseña maestra para autenticar');
      return;
    }

    final success = await widget.controller.purgeUserDefinitively(
      userId: widget.user.id,
      masterPassword: password,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      setState(() {
        _error = widget.controller.failure?.message ?? 'Contraseña incorrecta';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.critical),
          SizedBox(width: 8),
          Text('Purga Definitiva de Seguridad', style: TextStyle(color: AppColors.critical)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de que desea eliminar permanentemente la cuenta de ${widget.user.nombre} (${widget.user.email})?',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.criticalBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
              ),
              child: const Text(
                'Esta acción es irreversible y purgará los registros de autenticación del usuario. Para continuar, ingrese la contraseña maestra de Superadmin.',
                style: TextStyle(fontSize: 12, color: AppColors.criticalText, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Contraseña Maestra de Superadmin *',
                prefixIcon: const Icon(Icons.key, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                errorText: _error,
              ),
              onSubmitted: (_) => _confirmarPurga(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
          onPressed: _confirmarPurga,
          child: const Text('Confirmar Purga Definitiva'),
        ),
      ],
    );
  }
}
