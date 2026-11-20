import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/administration_controller.dart';

/// Vista: Parametrización Fiscal y Configuración Tributaria SIAT Bolivia
class ParametrizacionFiscalView extends StatefulWidget {
  final AdministrationController controller;

  const ParametrizacionFiscalView({super.key, required this.controller});

  @override
  State<ParametrizacionFiscalView> createState() => _ParametrizacionFiscalViewState();
}

class _ParametrizacionFiscalViewState extends State<ParametrizacionFiscalView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nitController;
  late TextEditingController _razonSocialController;
  late TextEditingController _cufdController;
  late TextEditingController _cuisController;
  late TextEditingController _ivaController;
  late TextEditingController _itController;

  @override
  void initState() {
    super.initState();
    final cfg = widget.controller.fiscalConfig;
    _nitController = TextEditingController(text: cfg?.nit ?? '1028374029');
    _razonSocialController = TextEditingController(
      text: cfg?.razonSocial ?? 'LIBRERÍA Y PAPELERÍA SAN MARTÍN S.R.L.',
    );
    _cufdController = TextEditingController(
      text: cfg?.cufdActual ?? 'B1C2D3E4F5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0',
    );
    _cuisController = TextEditingController(
      text: cfg?.cuisActual ?? 'CUIS-SCZ-CENTRAL-00192',
    );
    _ivaController = TextEditingController(
      text: '${cfg?.porcentajeIva ?? 13.0}',
    );
    _itController = TextEditingController(
      text: '${cfg?.porcentajeIt ?? 3.0}',
    );
  }

  @override
  void dispose() {
    _nitController.dispose();
    _razonSocialController.dispose();
    _cufdController.dispose();
    _cuisController.dispose();
    _ivaController.dispose();
    _itController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final current = widget.controller.fiscalConfig;
      if (current == null) return;

      final updated = current.copyWith(
        nit: _nitController.text.trim(),
        razonSocial: _razonSocialController.text.trim(),
        cufdActual: _cufdController.text.trim(),
        cuisActual: _cuisController.text.trim(),
        porcentajeIva: double.tryParse(_ivaController.text) ?? 13.0,
        porcentajeIt: double.tryParse(_itController.text) ?? 3.0,
      );

      final ok = await widget.controller.updateFiscalConfig(updated);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.optimal,
            content: Text('Parámetros fiscales SIAT guardados y validados en base de datos.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final cfg = widget.controller.fiscalConfig;
        final isTesting = widget.controller.isTestingSiat;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Parametrización Fiscal SIAT (Impuestos Nacionales Bolivia)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Configuración de Facturación Electrónica en Línea, códigos CUFD/CUIS y alícuotas IVA/IT.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488), // Teal
                    ),
                    icon: isTesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.wifi_tethering, size: 18),
                    label: Text(isTesting ? 'Probando...' : 'Probar Conexión SIAT'),
                    onPressed: isTesting
                        ? null
                        : () async {
                            final ok = await widget.controller.testSiatConnection();
                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: AppColors.optimal,
                                  content: Text('Ping SOAP con SIN exitoso. WebService respondiendo con Código 200.'),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner Estado de Sincronización con el SIN
              Card(
                color: cfg?.sincronizadoConSin ?? true
                    ? AppColors.optimalBg
                    : AppColors.criticalBg,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: cfg?.sincronizadoConSin ?? true
                        ? const Color(0xFFBBF7D0)
                        : const Color(0xFFFECACA),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      Icon(
                        cfg?.sincronizadoConSin ?? true ? Icons.check_circle : Icons.error_outline,
                        color: cfg?.sincronizadoConSin ?? true
                            ? AppColors.optimal
                            : AppColors.critical,
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cfg?.sincronizadoConSin ?? true
                                  ? 'SINCRONIZACIÓN ACTIVA CON EL SERVICIO DE IMPUESTOS NACIONALES (SIN)'
                                  : 'ATENCIÓN: SINCRONIZACIÓN DESCONECTADA',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: cfg?.sincronizadoConSin ?? true
                                    ? AppColors.optimalText
                                    : AppColors.criticalText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Última validación de comunicación SOAP/REST: ${cfg?.ultimoPingWebService.toIso8601String().substring(0, 19) ?? 'Hoy'} | CUFD Vigente hasta las 23:59.',
                              style: TextStyle(
                                fontSize: 12,
                                color: cfg?.sincronizadoConSin ?? true
                                    ? AppColors.optimalText.withValues(alpha: 0.8)
                                    : AppColors.criticalText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Formulario de Configuración
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.tune, color: AppColors.primary, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Identificación Tributaria y Alícuotas Fiscales',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.borderLight, height: 1),
                        const SizedBox(height: 20),

                        // Fila NIT y Razón Social
                        Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'NIT del Emisor *',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _nitController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.badge_outlined, size: 18),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Razón Social Registrada *',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _razonSocialController,
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.business, size: 18),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Fila CUFD y CUIS
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Código CUFD (Vigencia 24h) *',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Renovación Diaria',
                                        style: TextStyle(fontSize: 11, color: AppColors.optimalText, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cufdController,
                                    style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.key, size: 18),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Código CUIS (Sistemas) *',
                                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 6),
                                  TextFormField(
                                    controller: _cuisController,
                                    style: const TextStyle(fontFamily: 'Consolas', fontSize: 12),
                                    decoration: const InputDecoration(
                                      prefixIcon: Icon(Icons.lock_clock, size: 18),
                                    ),
                                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Alícuotas Fiscales (13% IVA y 3% IT)
                        const Text(
                          'Alícuotas Tributarias Nacionales (Ley 843):',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // 13% IVA
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'IVA',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Impuesto al Valor Agregado',
                                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          TextFormField(
                                            controller: _ivaController,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              suffixText: '%',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // 3% IT
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFCCFBF1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'IT',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0D9488),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Impuesto a las Transacciones',
                                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          ),
                                          const SizedBox(height: 4),
                                          TextFormField(
                                            controller: _itController,
                                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                            decoration: const InputDecoration(
                                              suffixText: '%',
                                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Botón Guardar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save_outlined, size: 18),
                              label: const Text('Guardar Parámetros Fiscales'),
                              onPressed: widget.controller.isLoading ? null : _handleSave,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
