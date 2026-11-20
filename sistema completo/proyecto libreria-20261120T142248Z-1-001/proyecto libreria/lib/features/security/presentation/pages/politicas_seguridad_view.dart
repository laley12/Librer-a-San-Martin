import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/security_controller.dart';

/// Submódulo 3: Políticas de Contraseñas, Bloqueo y Concurrencia
/// - Tiempo de desbloqueo automático (minutos) con chips rápidos (15m, 30m, 60m, 120m)
/// - Límite de sesiones concurrentes (1, 2, 3 o Ilimitado)
/// - Slider para longitud mínima de contraseña (8 a 16 caracteres)
/// - Historial de contraseñas (3, 5, 10 claves)
/// - Bloqueo preventivo tras intentos fallidos (3, 5, 10 intentos)
/// - Interruptores para: Mayúsculas, Números y Caracteres Especiales (@#$%&*)
/// - Herencia estricta de Theme.of(context)
class PoliticasSeguridadView extends StatefulWidget {
  final SecurityController controller;

  const PoliticasSeguridadView({super.key, required this.controller});

  @override
  State<PoliticasSeguridadView> createState() => _PoliticasSeguridadViewState();
}

class _PoliticasSeguridadViewState extends State<PoliticasSeguridadView> {
  late int _minLength;
  late bool _requireUppercase;
  late bool _requireNumbers;
  late bool _requireSymbols;
  late int _tiempoDesbloqueo;
  late int _sesionesConcurrentes;
  late int _historialClaves;
  late int _intentosFallidos;

  final _desbloqueoCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final p = widget.controller.policies;
    _minLength = p.minLength;
    _requireUppercase = p.requireUppercase;
    _requireNumbers = p.requireNumbers;
    _requireSymbols = p.requireSymbols;
    _tiempoDesbloqueo = p.tiempoDesbloqueoMinutos;
    _sesionesConcurrentes = p.limiteSesionesConcurrentes;
    _historialClaves = p.historialClaves;
    _intentosFallidos = p.bloqueoIntentosFallidos;
    _desbloqueoCtrl.text = _tiempoDesbloqueo.toString();
  }

  @override
  void dispose() {
    _desbloqueoCtrl.dispose();
    super.dispose();
  }

  void _guardarPoliticas() {
    final minutos = int.tryParse(_desbloqueoCtrl.text.trim()) ?? _tiempoDesbloqueo;

    widget.controller.updateSecurityPolicies(
      minLength: _minLength,
      requireUppercase: _requireUppercase,
      requireNumbers: _requireNumbers,
      requireSymbols: _requireSymbols,
      tiempoDesbloqueoMinutos: minutos,
      limiteSesionesConcurrentes: _sesionesConcurrentes,
      historialClaves: _historialClaves,
      bloqueoIntentosFallidos: _intentosFallidos,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Políticas de Contraseñas, Bloqueo y Concurrencia',
                          style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.onSurface,
                              ) ??
                              const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Directivas de endurecimiento criptográfico NIST SP 800-63B, prevención de fuerza bruta y control de sesiones.',
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
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Aplicar Directivas'),
                    onPressed: _guardarPoliticas,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner de Mensaje
              if (widget.controller.successMessage != null) ...[
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
                          widget.controller.successMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.optimalText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16, color: AppColors.optimal),
                        onPressed: () => widget.controller.clearMessages(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Grid de 2 Columnas: Complejidad vs Bloqueo y Concurrencia
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;

                  return Flex(
                    direction: isWide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Panel 1: Reglas de Complejidad de Claves (NIST)
                      Expanded(
                        flex: isWide ? 6 : 0,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.password, color: theme.colorScheme.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Reglas de Complejidad de Contraseñas',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: AppColors.borderLight, height: 1),
                                const SizedBox(height: 16),

                                // Slider Longitud Mínima (8 a 16 caracteres)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Longitud Mínima Requerida:',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '$_minLength caracteres',
                                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _minLength.toDouble(),
                                  min: 8,
                                  max: 16,
                                  divisions: 8,
                                  label: '$_minLength car.',
                                  onChanged: (val) {
                                    setState(() => _minLength = val.round());
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Switches Independientes
                                SwitchListTile(
                                  title: const Text('Exigir Letras Mayúsculas (A-Z)', style: TextStyle(fontSize: 13)),
                                  subtitle: const Text('Al menos un carácter alfabético en mayúscula', style: TextStyle(fontSize: 11.5)),
                                  value: _requireUppercase,
                                  onChanged: (v) => setState(() => _requireUppercase = v),
                                ),
                                SwitchListTile(
                                  title: const Text('Exigir Dígitos Numéricos (0-9)', style: TextStyle(fontSize: 13)),
                                  subtitle: const Text('Al menos un dígito en la clave', style: TextStyle(fontSize: 11.5)),
                                  value: _requireNumbers,
                                  onChanged: (v) => setState(() => _requireNumbers = v),
                                ),
                                SwitchListTile(
                                  title: const Text('Exigir Caracteres Especiales (@#\$%&*)', style: TextStyle(fontSize: 13)),
                                  subtitle: const Text('Símbolos para protección contra diccionarios', style: TextStyle(fontSize: 11.5)),
                                  value: _requireSymbols,
                                  onChanged: (v) => setState(() => _requireSymbols = v),
                                ),
                                const SizedBox(height: 12),

                                // Historial de Contraseñas (3, 5, 10)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Historial de no reutilización:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    DropdownButton<int>(
                                      value: _historialClaves,
                                      items: const [
                                        DropdownMenuItem(value: 3, child: Text('Últimas 3 claves')),
                                        DropdownMenuItem(value: 5, child: Text('Últimas 5 claves')),
                                        DropdownMenuItem(value: 10, child: Text('Últimas 10 claves')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) setState(() => _historialClaves = v);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),

                      // Panel 2: Bloqueo, Tiempo de Desbloqueo y Concurrencia
                      Expanded(
                        flex: isWide ? 6 : 0,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.timer_outlined, color: theme.colorScheme.primary, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Bloqueo Automático y Límite de Sesiones',
                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Divider(color: AppColors.borderLight, height: 1),
                                const SizedBox(height: 16),

                                // Tiempo de Desbloqueo Automático
                                const Text(
                                  'Tiempo de Desbloqueo Automático de Cuenta:',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _desbloqueoCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Duración del bloqueo (Minutos)',
                                    prefixIcon: Icon(Icons.access_time, size: 18),
                                    suffixText: 'minutos',
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Chips / Sugerencias Rápidas
                                Wrap(
                                  spacing: 8,
                                  children: [15, 30, 60, 120].map((min) {
                                    final isSelected = _tiempoDesbloqueo == min;

                                    return ChoiceChip(
                                      label: Text('${min}m'),
                                      selected: isSelected,
                                      onSelected: (_) {
                                        setState(() {
                                          _tiempoDesbloqueo = min;
                                          _desbloqueoCtrl.text = min.toString();
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 18),

                                // Bloqueo Preventivo tras Intentos Fallidos
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Bloqueo tras intentos fallidos:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    DropdownButton<int>(
                                      value: _intentosFallidos,
                                      items: const [
                                        DropdownMenuItem(value: 3, child: Text('3 intentos')),
                                        DropdownMenuItem(value: 5, child: Text('5 intentos')),
                                        DropdownMenuItem(value: 10, child: Text('10 intentos')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) setState(() => _intentosFallidos = v);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),

                                // Límite de Sesiones Concurrentes
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Límite de sesiones concurrentes:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    DropdownButton<int>(
                                      value: _sesionesConcurrentes,
                                      items: const [
                                        DropdownMenuItem(value: 1, child: Text('1 dispositivo (Estricto)')),
                                        DropdownMenuItem(value: 2, child: Text('2 dispositivos simultáneos')),
                                        DropdownMenuItem(value: 3, child: Text('3 dispositivos simultáneos')),
                                        DropdownMenuItem(value: -1, child: Text('Ilimitado')),
                                      ],
                                      onChanged: (v) {
                                        if (v != null) setState(() => _sesionesConcurrentes = v);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
