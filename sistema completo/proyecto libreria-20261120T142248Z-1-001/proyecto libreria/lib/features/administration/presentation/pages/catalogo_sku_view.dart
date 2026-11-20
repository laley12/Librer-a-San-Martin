import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/administration_controller.dart';
import '../widgets/alta_sku_dialog.dart';

/// Vista: Catálogo Maestro de SKUs con Lector USB de Código de Barras
class CatalogoSkuView extends StatefulWidget {
  final AdministrationController controller;

  const CatalogoSkuView({super.key, required this.controller});

  @override
  State<CatalogoSkuView> createState() => _CatalogoSkuViewState();
}

class _CatalogoSkuViewState extends State<CatalogoSkuView> {
  final _barcodeSearchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _barcodeSearchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _ejecutarBusqueda(String query) {
    widget.controller.filterSkus(queryOrBarcode: query);
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final skus = controller.skus;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera y Botón Nuevo SKU
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catálogo SKU y Maestro de Artículos',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Escaneo por código de barras USB (EAN-13), pricing comercial y existencias.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Registrar Nuevo SKU'),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AltaSkuDialog(controller: controller),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Barra de Búsqueda y Listener Lector USB
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      // Input con listener de Lector de Código de Barras USB
                      Expanded(
                        flex: 5,
                        child: TextField(
                          controller: _barcodeSearchController,
                          focusNode: _searchFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Escanear código de barras EAN-13 o escribir título...',
                            prefixIcon: const Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 22),
                            suffixIcon: _barcodeSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _barcodeSearchController.clear();
                                      _ejecutarBusqueda('');
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (val) {
                            // Búsqueda en tiempo real conforme escribe
                            _ejecutarBusqueda(val);
                          },
                          onSubmitted: (val) {
                            // Cuando el lector USB emite el caracter de Enter al final del escaneo
                            _ejecutarBusqueda(val);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Código escaneado: $val'),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Filtro Editorial
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: controller.skuEditorial,
                          decoration: const InputDecoration(
                            labelText: 'Editorial',
                            prefixIcon: Icon(Icons.business_outlined, size: 18),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Todas', child: Text('Todas las Editoriales', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Santillana', child: Text('Santillana', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Norma', child: Text('Norma', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Don Bosco', child: Text('Don Bosco', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'McGraw-Hill', child: Text('McGraw-Hill', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Pearson', child: Text('Pearson', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Papelería y Oficina', child: Text('Papelería y Oficina', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.filterSkus(editorial: val);
                          },
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Filtro Categoría
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: controller.skuCategoria,
                          decoration: const InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category_outlined, size: 18),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Todas', child: Text('Todas las Categorías', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Textos Escolares', child: Text('Textos Escolares', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Textos Universitarios', child: Text('Textos Universitarios', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Literatura y Ficción', child: Text('Literatura y Ficción', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Papelería y Oficina', child: Text('Papelería y Oficina', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'Criptografía e Informática', child: Text('Criptografía e Informática', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) {
                            if (val != null) controller.filterSkus(categoria: val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tabla de SKUs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Títulos encontrados: ${skus.length} productos',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(
                            'Lector USB activo (Protocolo HID)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.optimal,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 8),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          horizontalMargin: 16,
                          columnSpacing: 22,
                          headingRowColor: WidgetStateProperty.all(AppColors.background),
                          columns: const [
                            DataColumn(
                              label: Text(
                                'MINIATURA',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'SKU / EAN-13',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'TÍTULO DEL ARTÍCULO',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'EDITORIAL',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'COSTO BS',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'MARGEN %',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'PRECIO VENTA BS',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'STOCK',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                          rows: skus.map((sku) {
                            return DataRow(
                              cells: [
                                // Foto Miniatura / Icono
                                DataCell(
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Icon(
                                      Icons.menu_book,
                                      size: 18,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                // SKU / EAN-13
                                DataCell(
                                  Text(
                                    sku.ean13,
                                    style: const TextStyle(
                                      fontFamily: 'Consolas',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                // Título
                                DataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        sku.titulo,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                      Text(
                                        sku.categoria,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                // Editorial
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      sku.editorial,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                // Costo Bs
                                DataCell(
                                  Text(
                                    'Bs ${sku.costoBs.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                ),
                                // Margen %
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${sku.margenPorcentaje.toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                // Precio Venta Bs
                                DataCell(
                                  Text(
                                    'Bs ${sku.precioVentaBs.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.optimalText,
                                    ),
                                  ),
                                ),
                                // Stock
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: sku.stockActual < 30 ? AppColors.warningBg : AppColors.optimalBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${sku.stockActual} u.',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: sku.stockActual < 30 ? AppColors.warningText : AppColors.optimalText,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
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
}
