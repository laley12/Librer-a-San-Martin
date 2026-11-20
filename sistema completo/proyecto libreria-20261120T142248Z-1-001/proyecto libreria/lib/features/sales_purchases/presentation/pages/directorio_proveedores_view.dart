import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/sales_purchases_controller.dart';

class DirectorioProveedoresView extends StatefulWidget {
  final SalesPurchasesController controller;

  const DirectorioProveedoresView({super.key, required this.controller});

  @override
  State<DirectorioProveedoresView> createState() => _DirectorioProveedoresViewState();
}

class _DirectorioProveedoresViewState extends State<DirectorioProveedoresView> {
  String _searchFilter = '';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final suppliers = widget.controller.suppliers;
        final filtered = suppliers.where((s) {
          final query = _searchFilter.toLowerCase().trim();
          if (query.isEmpty) return true;
          return s.razonSocial.toLowerCase().contains(query) ||
              s.nit.contains(query) ||
              s.contacto.toLowerCase().contains(query) ||
              s.pais.toLowerCase().contains(query);
        }).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Directorio de Proveedores y Editoriales',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gestión de cuentas comerciales, NIT, contactos y condiciones de crédito mayorista.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Actualizar'),
                        onPressed: () => widget.controller.loadSuppliers(),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Nuevo Proveedor'),
                        onPressed: () => _mostrarDialogoNuevoProveedor(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buscador y Tabla de Proveedores
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Barra de búsqueda rápida
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: 'Buscar proveedor por Razón Social, NIT, contacto o país...',
                                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.primary),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onChanged: (val) {
                                setState(() {
                                  _searchFilter = val;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${filtered.length} Proveedores',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tabla de Proveedores
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.background),
                          columns: const [
                            DataColumn(label: Text('Editorial / Razón Social', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('NIT / Código Fiscal', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Contacto Directo', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Teléfono & Correo', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Origen', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Categorías Suministradas', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Plazo Crédito', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: filtered.map((supplier) {
                            final esContado = supplier.plazoCreditoDias == 0;

                            return DataRow(
                              cells: [
                                DataCell(Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(Icons.business, color: AppColors.primary, size: 16),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      supplier.razonSocial,
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                  ],
                                )),
                                DataCell(Text(supplier.nit, style: const TextStyle(fontFamily: 'monospace'))),
                                DataCell(Text(supplier.contacto)),
                                DataCell(Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(supplier.telefono, style: const TextStyle(fontSize: 12)),
                                    Text(supplier.email, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                  ],
                                )),
                                DataCell(Text(supplier.pais)),
                                DataCell(Wrap(
                                  spacing: 4,
                                  children: supplier.categorias.map((c) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.borderLight),
                                      ),
                                      child: Text(c, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                                    );
                                  }).toList(),
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: esContado ? AppColors.warningBg : AppColors.optimalBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    esContado ? 'CONTADO (0 Días)' : '${supplier.plazoCreditoDias} DÍAS CRÉDITO',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: esContado ? AppColors.warningText : AppColors.optimalText,
                                    ),
                                  ),
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.optimalBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    supplier.estado,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.optimalText,
                                    ),
                                  ),
                                )),
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

  void _mostrarDialogoNuevoProveedor(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.business, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Registrar Proveedor / Editorial'),
          ],
        ),
        content: const Text(
          'El formulario de alta permite ingresar NIT verificado por SIAT, país de origen, plazos de crédito (30, 60, 90 días) y contacto comercial.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
