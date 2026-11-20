import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/security_controller.dart';

/// Diálogo modal para dar de alta a un nuevo usuario con validación estricta y
/// medidor visual de fortaleza NIST SP 800-63B.
class AltaUsuarioDialog extends StatefulWidget {
  final SecurityController controller;

  const AltaUsuarioDialog({super.key, required this.controller});

  @override
  State<AltaUsuarioDialog> createState() => _AltaUsuarioDialogState();
}

class _AltaUsuarioDialogState extends State<AltaUsuarioDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _ciController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRol = 'Vendedor/Cajero';
  String _selectedSucursal = 'Sede Central Santa Cruz';
  bool _obscurePassword = true;

  double _passwordStrength = 0.0;
  String _strengthLabel = 'Muy débil';
  Color _strengthColor = AppColors.critical;

  final List<String> _roles = const [
    'Admin TI',
    'Administrador',
    'Vendedor/Cajero',
    'Inventariador',
  ];

  final List<String> _sucursales = const [
    'Sede Central Santa Cruz',
    'Agencia La Guardia',
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_evaluarFortalezaClave);
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _ciController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Evalúa la contraseña bajo estándares NIST
  void _evaluarFortalezaClave() {
    final pwd = _passwordController.text;
    if (pwd.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _strengthLabel = 'Ingresa una contraseña';
        _strengthColor = AppColors.textMuted;
      });
      return;
    }

    double score = 0.0;
    if (pwd.length >= 8) score += 0.25;
    if (pwd.length >= 12) score += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(pwd) && RegExp(r'[a-z]').hasMatch(pwd)) {
      score += 0.2;
    }
    if (RegExp(r'[0-9]').hasMatch(pwd)) score += 0.15;
    if (RegExp(r'[@$#!%*?&_\-]').hasMatch(pwd)) score += 0.15;

    setState(() {
      _passwordStrength = score.clamp(0.0, 1.0);
      if (_passwordStrength < 0.4) {
        _strengthLabel = 'Débil (Requiere mín. 8 caracteres)';
        _strengthColor = AppColors.critical;
      } else if (_passwordStrength < 0.75) {
        _strengthLabel = 'Aceptable (Agrega mayúsculas, números o símbolos)';
        _strengthColor = AppColors.warning;
      } else {
        _strengthLabel = 'Fuerte (Conforme a política NIST SP 800-63B)';
        _strengthColor = AppColors.optimal;
      }
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await widget.controller.createUser(
        ci: _ciController.text,
        nombre: _nombreController.text,
        email: _emailController.text,
        rol: _selectedRol,
        sucursal: _selectedSucursal,
        password: _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.optimal,
            content: Text('Usuario registrado y provisionado en el sistema.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera del Diálogo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.person_add_alt_1_outlined, color: AppColors.primary, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Alta de Usuario en Sistema',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Registra un nuevo operador con perfil RBAC asignado y control NIST.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 16),

                  // Campo Nombre Completo (solo letras)
                  const Text(
                    'Nombre Completo *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Juan Carlos Morales',
                      prefixIcon: Icon(Icons.badge_outlined, size: 18),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'El nombre es obligatorio.';
                      }
                      if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(val.trim())) {
                        return 'Solo se permiten caracteres alfabéticos (sin números ni símbolos).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Fila CI y Email
                  Row(
                    children: [
                      // CI (solo números enteros)
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Carnet de Identidad (CI) *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _ciController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'Ej. 7829103',
                                prefixIcon: Icon(Icons.pin_outlined, size: 18),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'El CI es requerido.';
                                }
                                if (!RegExp(r'^\d+$').hasMatch(val.trim())) {
                                  return 'Solo números enteros.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Email
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Correo Corporativo *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                hintText: 'usuario@sanmartin.bo',
                                prefixIcon: Icon(Icons.mail_outline, size: 18),
                              ),
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'El correo es requerido.';
                                }
                                if (!val.contains('@') || !val.contains('.')) {
                                  return 'Correo no válido.';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Fila Rol y Sucursal (Adaptativo según resolución)
                  Builder(
                    builder: (context) {
                      final isCompact = MediaQuery.sizeOf(context).width < 640;

                      final rolColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rol Asignado *',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedRol,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.admin_panel_settings_outlined, size: 18),
                            ),
                            items: _roles.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(r, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedRol = val);
                            },
                          ),
                        ],
                      );

                      final sucursalColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sucursal Asignada *',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedSucursal,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.storefront_outlined, size: 18),
                            ),
                            items: _sucursales.map((s) {
                              return DropdownMenuItem(
                                value: s,
                                child: Text(s, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSucursal = val);
                            },
                          ),
                        ],
                      );

                      if (isCompact) {
                        return Column(
                          children: [
                            rolColumn,
                            const SizedBox(height: 12),
                            sucursalColumn,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: rolColumn),
                          const SizedBox(width: 12),
                          Expanded(child: sucursalColumn),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // Campo Contraseña con Medidor NIST
                  const Text(
                    'Contraseña Inicial *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Mínimo 8 caracteres alfanuméricos',
                      prefixIcon: const Icon(Icons.lock_outline, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          size: 18,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.length < 8) {
                        return 'Debe tener al menos 8 caracteres según política NIST.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Medidor Visual de Contraseña NIST
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _passwordStrength,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _strengthLabel,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: _strengthColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(_passwordStrength * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: _strengthColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botones de Acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Crear Usuario'),
                        onPressed: widget.controller.isLoading ? null : _handleSubmit,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
