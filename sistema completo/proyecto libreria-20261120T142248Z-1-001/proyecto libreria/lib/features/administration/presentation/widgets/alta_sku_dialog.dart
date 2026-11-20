import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../controllers/administration_controller.dart';

/// Diálogo para registrar un nuevo producto / SKU maestro con cálculo reactivo
/// de margen comercial y precio de venta: Precio Venta = Costo / (1 - Margen).
class AltaSkuDialog extends StatefulWidget {
  final AdministrationController controller;

  const AltaSkuDialog({super.key, required this.controller});

  @override
  State<AltaSkuDialog> createState() => _AltaSkuDialogState();
}

class _AltaSkuDialogState extends State<AltaSkuDialog> {
  final _formKey = GlobalKey<FormState>();

  final _ean13Controller = TextEditingController();
  final _tituloController = TextEditingController();
  final _costoController = TextEditingController(text: '100.00');
  final _margenController = TextEditingController(text: '30.0');
  final _stockController = TextEditingController(text: '50');

  String _selectedEditorial = 'Santillana';
  String _selectedCategoria = 'Textos Escolares';

  double _precioVentaCalculado = 142.86;

  final List<String> _editoriales = const [
    'Santillana',
    'Norma',
    'Don Bosco',
    'Panini',
    'McGraw-Hill',
    'Pearson',
    'Papelería y Oficina',
  ];

  final List<String> _categorias = const [
    'Textos Escolares',
    'Textos Universitarios',
    'Literatura y Ficción',
    'Papelería y Oficina',
    'Criptografía e Informática',
  ];

  @override
  void initState() {
    super.initState();
    _costoController.addListener(_recalcularPrecio);
    _margenController.addListener(_recalcularPrecio);
    _recalcularPrecio();
  }

  @override
  void dispose() {
    _ean13Controller.dispose();
    _tituloController.dispose();
    _costoController.dispose();
    _margenController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Cálculo reactivo: Precio Venta = Costo / (1 - Margen)
  void _recalcularPrecio() {
    final costo = double.tryParse(_costoController.text) ?? 0.0;
    final margen = double.tryParse(_margenController.text) ?? 0.0;

    setState(() {
      _precioVentaCalculado = SkuEntity.calcularPrecioVenta(costo, margen);
    });
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final costo = double.tryParse(_costoController.text) ?? 0.0;
      final margen = double.tryParse(_margenController.text) ?? 0.0;
      final stock = int.tryParse(_stockController.text) ?? 0;

      final ok = await widget.controller.createSku(
        ean13: _ean13Controller.text.trim(),
        titulo: _tituloController.text.trim(),
        editorial: _selectedEditorial,
        categoria: _selectedCategoria,
        costoBs: costo,
        margenPorcentaje: margen,
        stockInicial: stock,
      );

      if (ok && mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.optimal,
            content: Text('Nuevo SKU registrado e indexado para el lector de código de barras.'),
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
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(26.0),
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
                      const Row(
                        children: [
                          Icon(Icons.add_shopping_cart, color: AppColors.primary, size: 24),
                          SizedBox(width: 10),
                          Text(
                            'Alta de Producto / SKU Maestro',
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
                    'Registro con pricing reactivo: Precio Venta = Costo / (1 - Margen).',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: 16),

                  // Fila SKU / EAN-13 y Título
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Código EAN-13 / Barra *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _ean13Controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '7770001928371',
                                prefixIcon: Icon(Icons.qr_code, size: 18),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Título del Libro / Artículo *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _tituloController,
                              decoration: const InputDecoration(
                                hintText: 'Ej. Física Cuántica I',
                                prefixIcon: Icon(Icons.book, size: 18),
                              ),
                              validator: (v) => v == null || v.length < 3 ? 'Mín. 3 caracteres' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Fila Editorial y Categoría
                  // Fila Editorial y Categoría (Adaptativo según resolución)
                  Builder(
                    builder: (context) {
                      final isCompact = MediaQuery.sizeOf(context).width < 640;

                      final editorialCol = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Editorial *',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedEditorial,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.business_outlined, size: 18),
                            ),
                            items: _editoriales.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedEditorial = v);
                            },
                          ),
                        ],
                      );

                      final categoriaCol = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Familia / Categoría *',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            isExpanded: true,
                            initialValue: _selectedCategoria,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.category_outlined, size: 18),
                            ),
                            items: _categorias.map((c) {
                              return DropdownMenuItem(
                                value: c,
                                child: Text(c, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedCategoria = v);
                            },
                          ),
                        ],
                      );

                      if (isCompact) {
                        return Column(
                          children: [
                            editorialCol,
                            const SizedBox(height: 12),
                            categoriaCol,
                          ],
                        );
                      }

                      return Row(
                        children: [
                          Expanded(child: editorialCol),
                          const SizedBox(width: 14),
                          Expanded(child: categoriaCol),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Panel Reactivo de Precios y Margen Comercial
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calculate_outlined, color: AppColors.primary, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Cálculo Reactivo de Precios (Fórmula Retail)',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Costo Bs
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Costo (Bs) *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _costoController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      prefixText: 'Bs ',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                            const SizedBox(width: 10),

                            // Margen %
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Margen (%) *',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  TextFormField(
                                    controller: _margenController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      suffixText: '%',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    validator: (v) {
                                      final val = double.tryParse(v ?? '');
                                      if (val == null || val <= 0 || val >= 100) return 'Entre 1 y 99';
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Precio de Venta (Resultado en Tiempo Real)
                            Expanded(
                              flex: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.optimalBg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFBBF7D0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Precio Venta (Bs):',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.optimalText,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Bs ${_precioVentaCalculado.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.optimalText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Stock Inicial
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Stock Inicial (Unidades) *',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: _stockController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.inventory_2, size: 18),
                              ),
                              validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 6,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, size: 18, color: AppColors.textSecondary),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'El stock inicial creará el primer registro en el Kárdex PEPS.',
                                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
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
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Registrar SKU'),
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
