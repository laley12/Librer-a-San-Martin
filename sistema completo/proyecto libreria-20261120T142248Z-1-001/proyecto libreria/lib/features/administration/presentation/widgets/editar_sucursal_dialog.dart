import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../controllers/administration_controller.dart';

/// Modal para editar la información operativa de una sucursal y asignar bodegas secundarias.
class EditarSucursalDialog extends StatefulWidget {
  final BranchEntity branch;
  final AdministrationController controller;

  const EditarSucursalDialog({
    super.key,
    required this.branch,
    required this.controller,
  });

  @override
  State<EditarSucursalDialog> createState() => _EditarSucursalDialogState();
}

class _EditarSucursalDialogState extends State<EditarSucursalDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _encargadoController;
  late TextEditingController _cajasController;
  late TextEditingController _aforoController;
  late TextEditingController _nuevaBodegaController;

  late List<String> _bodegas;

  @override
  void initState() {
    super.initState();
    _encargadoController = TextEditingController(text: widget.branch.encargado);
    _cajasController = TextEditingController(text: '${widget.branch.cajasPosAsignadas}');
    _aforoController = TextEditingController(text: '${widget.branch.aforoM2.toInt()}');
    _nuevaBodegaController = TextEditingController();
    _bodegas = List.from(widget.branch.bodegasVinculadas);
  }

  @override
  void dispose() {
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
    if (_formKey.currentState?.validate() ?? false) {
      final updated = widget.branch.copyWith(
        encargado: _encargadoController.text.trim(),
        cajasPosAsignadas: int.tryParse(_cajasController.text) ?? widget.branch.cajasPosAsignadas,
        aforoM2: double.tryParse(_aforoController.text) ?? widget.branch.aforoM2,
        bodegasVinculadas: _bodegas,
      );

      final ok = await widget.controller.updateBranch(updated);
      if (ok && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.optimal,
            content: Text('Sucursal "${updated.nombre}" actualizada con éxito.'),
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
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 24),
                          const SizedBox(width: 10),
                          Text(
                            'Editar ${widget.branch.nombre}',
                            style: const TextStyle(
                              fontSize: 17,
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
                  Text(
                    'Ubicación: ${widget.branch.direccion} (${widget.branch.ciudad})',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: 16),

                  // Encargado
                  const Text(
                    'Encargado de Sucursal *',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _encargadoController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre del responsable',
                      prefixIcon: Icon(Icons.person_outline, size: 18),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 14),

                  // Fila Cajas y Aforo
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
                                prefixIcon: Icon(Icons.point_of_sale, size: 18),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
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
                              'Aforo en m² *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _aforoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.square_foot, size: 18),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Bodegas Secundarias Vinculadas
                  const Text(
                    'Bodegas y Almacenes Vinculados:',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _bodegas.map((b) {
                      return Chip(
                        label: Text(b, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.primaryContainer,
                        deleteIcon: const Icon(Icons.close, size: 14),
                        onDeleted: () {
                          setState(() => _bodegas.remove(b));
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nuevaBodegaController,
                          decoration: const InputDecoration(
                            hintText: 'Nombre de bodega a vincular...',
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onSubmitted: (_) => _agregarBodega(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _agregarBodega,
                        child: const Text('Agregar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: widget.controller.isLoading ? null : _handleSubmit,
                        child: const Text('Guardar Cambios'),
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
