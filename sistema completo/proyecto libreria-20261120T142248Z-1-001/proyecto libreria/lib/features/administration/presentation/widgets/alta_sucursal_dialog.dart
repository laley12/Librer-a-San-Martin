import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/admin_usecases.dart';
import '../controllers/administration_controller.dart';

/// Modal responsivo para el alta de nuevas sucursales y puntos de venta.
class AltaSucursalDialog extends StatefulWidget {
  final AdministrationController controller;

  const AltaSucursalDialog({super.key, required this.controller});

  @override
  State<AltaSucursalDialog> createState() => _AltaSucursalDialogState();
}

class _AltaSucursalDialogState extends State<AltaSucursalDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController(text: 'Santa Cruz de la Sierra');
  final _encargadoController = TextEditingController();
  final _cajasController = TextEditingController(text: '2');
  final _aforoController = TextEditingController(text: '120');
  final _nuevaBodegaController = TextEditingController();

  final List<String> _bodegas = ['Bodega Local'];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _encargadoController.dispose();
    _cajasController.dispose();
    _aforoController.dispose();
    _nuevaBodegaController.dispose();
    super.dispose();
  }

  void _agregarBodega() {
    final text = _nuevaBodegaController.text.trim();
    if (text.isNotEmpty && !_bodegas.contains(text)) {
      setState(() {
        _bodegas.add(text);
        _nuevaBodegaController.clear();
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final params = CreateBranchParams(
      nombre: _nombreController.text.trim(),
      direccion: _direccionController.text.trim(),
      ciudad: _ciudadController.text.trim(),
      encargado: _encargadoController.text.trim(),
      cajasPosAsignadas: int.tryParse(_cajasController.text) ?? 1,
      aforoM2: double.tryParse(_aforoController.text) ?? 100.0,
      bodegasVinculadas: _bodegas.isNotEmpty ? _bodegas : ['Bodega General'],
    );

    final ok = await widget.controller.createBranch(params);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.optimal,
            content: Text('Sucursal "${params.nombre}" dada de alta correctamente.'),
          ),
        );
      } else {
        final err = widget.controller.failure?.message ?? 'Error al registrar la sucursal.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.critical,
            content: Text(err),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.sizeOf(context).width < 640;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: AppColors.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título y cierre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.add_business_outlined, color: AppColors.primary, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Alta de Nueva Sucursal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
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
                    'Registro físico de agencia y vinculación con la red operativa de la librería.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: 16),

                  // Nombre de la Sucursal
                  const Text(
                    'Nombre de la Sucursal *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      hintText: 'Ej. Sucursal Plan 3000, Agencia Montero',
                      prefixIcon: Icon(Icons.storefront, size: 18),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese el nombre de la sucursal' : null,
                  ),
                  const SizedBox(height: 14),

                  // Ciudad y Dirección
                  if (isCompact) ...[
                    const Text('Ciudad / Localidad *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _ciudadController,
                      decoration: const InputDecoration(
                        hintText: 'Santa Cruz de la Sierra',
                        prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 14),
                    const Text('Dirección Física *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        hintText: 'Ej. Av. Che Guevara #520, Zona Plan 3000',
                        prefixIcon: Icon(Icons.map_outlined, size: 18),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ciudad / Localidad *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _ciudadController,
                                decoration: const InputDecoration(
                                  hintText: 'Santa Cruz',
                                  prefixIcon: Icon(Icons.location_city_outlined, size: 18),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dirección Física *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _direccionController,
                                decoration: const InputDecoration(
                                  hintText: 'Av. Che Guevara #520',
                                  prefixIcon: Icon(Icons.map_outlined, size: 18),
                                ),
                                validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  // Encargado
                  const Text(
                    'Encargado de Sucursal *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _encargadoController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre del responsable administrativo',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 14),

                  // Cajas POS y Aforo
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cajas POS Asignadas *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _cajasController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '1',
                                prefixIcon: Icon(Icons.point_of_sale_outlined, size: 18),
                              ),
                              validator: (v) {
                                final val = int.tryParse(v ?? '');
                                if (val == null || val < 1) return 'Mínimo 1';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aforo Total (m²) *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _aforoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '100',
                                prefixIcon: Icon(Icons.aspect_ratio_outlined, size: 18),
                              ),
                              validator: (v) {
                                final val = double.tryParse(v ?? '');
                                if (val == null || val <= 0) return 'Mayor a 0';
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Bodegas Vinculadas
                  const Text(
                    'Bodegas Vinculadas',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _bodegas.map((bodega) {
                      return Chip(
                        label: Text(bodega, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primaryContainer,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: _bodegas.length > 1
                            ? () => setState(() => _bodegas.remove(bodega))
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nuevaBodegaController,
                          decoration: const InputDecoration(
                            hintText: 'Nombre de bodega adicional...',
                            prefixIcon: Icon(Icons.warehouse_outlined, size: 18),
                          ),
                          onSubmitted: (_) => _agregarBodega(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Añadir'),
                        onPressed: _agregarBodega,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Acciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check, size: 18),
                        label: const Text('Dar de Alta Sucursal'),
                        onPressed: _isSubmitting ? null : _handleSubmit,
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
