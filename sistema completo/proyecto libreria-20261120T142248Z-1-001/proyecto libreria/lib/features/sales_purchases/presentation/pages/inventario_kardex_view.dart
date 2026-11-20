import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/sales_purchases_controller.dart';

class InventarioKardexView extends StatelessWidget {
  final SalesPurchasesController controller;

  const InventarioKardexView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final entries = controller.kardexEntries;
        final selectedSku = controller.selectedKardexSku;
        final currentProduct = controller.products.where((p) => p.sku == selectedSku).firstOrNull;

        // Último saldo registrado
        final ultimoSaldo = entries.isNotEmpty ? entries.last : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera Principal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kárdex Físico-Valorado (Método PEPS / FIFO)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Control contable y aduanero de existencias valoradas según los primeros lotes en entrar.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Actualizar Kárdex'),
                    onPressed: () => controller.loadKardex(selectedSku),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Selector de SKU y Tarjetas Resumen de Saldos
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
                    children: [
                      Row(
                        children: [
                          // Dropdown para seleccionar el SKU a auditar
                          Expanded(
                            flex: 5,
                            child: DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: selectedSku,
                              decoration: const InputDecoration(
                                labelText: 'Seleccionar SKU a Auditar en Kárdex',
                                prefixIcon: Icon(Icons.qr_code_2, size: 20, color: AppColors.primary),
                              ),
                              items: controller.products.map((p) {
                                return DropdownMenuItem<String>(
                                  value: p.sku,
                                  child: Text(
                                    '${p.sku} - ${p.titulo} (${p.editorial})',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  controller.loadKardex(val);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Información del Lote Valorado
                          Expanded(
                            flex: 7,
                            child: Row(
                              children: [
                                _buildSummaryBox(
                                  label: 'Stock Físico Actual',
                                  value: '${ultimoSaldo?.saldoCantidad ?? currentProduct?.stockDisponible ?? 0} un.',
                                  color: AppColors.primary,
                                  icon: Icons.inventory_2_outlined,
                                ),
                                const SizedBox(width: 10),
                                _buildSummaryBox(
                                  label: 'Costo Prom. Valorado',
                                  value: 'Bs ${(ultimoSaldo?.costoPromedioSaldo ?? 0.0).toStringAsFixed(2)}',
                                  color: AppColors.warningText,
                                  icon: Icons.calculate_outlined,
                                ),
                                const SizedBox(width: 10),
                                _buildSummaryBox(
                                  label: 'Valor Total Inventario',
                                  value: 'Bs ${(ultimoSaldo?.saldoValorTotal ?? 0.0).toStringAsFixed(2)}',
                                  color: AppColors.optimal,
                                  icon: Icons.monetization_on_outlined,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TABLA KÁRDEX FÍSICO-VALORADO CON ENCABEZADO COMPUESTO DE 3 SECCIONES
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
                      // Subtítulo con Método Contable
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.table_view_outlined, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Libro Mayor de Almacén • Método PEPS (Primeros en Entrar, Primeros en Salir)',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'AUDITORÍA FORENSE BOL-GAAP',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Tabla Compuesta
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 1180,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Nivel 1 del Encabezado: Secciones Superiores
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Row(
                                  children: [
                                    _buildHeaderCell('FECHA Y COMPROBANTE', flex: 4),
                                    _buildHeaderCell('1. ENTRADAS', flex: 3, bgColor: const Color(0xFFDCFCE7), textColor: const Color(0xFF166534)),
                                    _buildHeaderCell('2. SALIDAS (MÉTODO PEPS)', flex: 3, bgColor: const Color(0xFFFEE2E2), textColor: const Color(0xFF991B1B)),
                                    _buildHeaderCell('3. SALDOS FINALES', flex: 3, bgColor: const Color(0xFFDBEAFE), textColor: const Color(0xFF1E40AF)),
                                  ],
                                ),
                              ),

                              // Nivel 2 del Encabezado: Columnas Detalladas
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  border: Border(
                                    left: const BorderSide(color: AppColors.borderLight),
                                    right: const BorderSide(color: AppColors.borderLight),
                                    bottom: const BorderSide(color: AppColors.borderLight, width: 2),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    // Datos Operación (Flex 4: dividido en 4 columnas)
                                    _SubHeaderCell('Fecha', width: 90),
                                    _SubHeaderCell('Comprobante', width: 110),
                                    _SubHeaderCell('Detalle Operación', width: 200),

                                    // Entradas (Flex 3: 3 columnas)
                                    _SubHeaderCell('Cantidad', width: 75, alignRight: true),
                                    _SubHeaderCell('Costo Unit.', width: 85, alignRight: true),
                                    _SubHeaderCell('Total Bs', width: 95, alignRight: true),

                                    // Salidas (Flex 3: 3 columnas)
                                    _SubHeaderCell('Cantidad', width: 75, alignRight: true),
                                    _SubHeaderCell('C.U. PEPS', width: 85, alignRight: true),
                                    _SubHeaderCell('Total Bs', width: 95, alignRight: true),

                                    // Saldos (Flex 3: 3 columnas)
                                    _SubHeaderCell('Stock', width: 75, alignRight: true),
                                    _SubHeaderCell('C. Prom.', width: 85, alignRight: true),
                                    _SubHeaderCell('Valor Total', width: 100, alignRight: true),
                                  ],
                                ),
                              ),

                              // Filas de Datos Kárdex
                              ...entries.map((entry) {
                                final isEntrada = entry.cantidadEntrada > 0;
                                final isSalida = entry.cantidadSalida > 0;

                                return Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(color: AppColors.borderLight),
                                      left: BorderSide(color: AppColors.borderLight),
                                      right: BorderSide(color: AppColors.borderLight),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Fecha
                                      _DataCell('${entry.fecha.day.toString().padLeft(2, '0')}/${entry.fecha.month.toString().padLeft(2, '0')}/${entry.fecha.year}', width: 90),
                                      // Comprobante
                                      _DataCell(entry.comprobante, width: 110, isBold: true),
                                      // Detalle
                                      _DataCell(entry.detalle, width: 200),

                                      // ENTRADAS
                                      _DataCell(
                                        isEntrada ? '${entry.cantidadEntrada}' : '-',
                                        width: 75,
                                        alignRight: true,
                                        bgColor: isEntrada ? const Color(0xFFF0FDF4) : null,
                                      ),
                                      _DataCell(
                                        isEntrada ? 'Bs ${entry.costoUnitarioEntrada.toStringAsFixed(2)}' : '-',
                                        width: 85,
                                        alignRight: true,
                                        bgColor: isEntrada ? const Color(0xFFF0FDF4) : null,
                                      ),
                                      _DataCell(
                                        isEntrada ? 'Bs ${entry.totalEntrada.toStringAsFixed(2)}' : '-',
                                        width: 95,
                                        alignRight: true,
                                        isBold: isEntrada,
                                        bgColor: isEntrada ? const Color(0xFFF0FDF4) : null,
                                      ),

                                      // SALIDAS PEPS
                                      _DataCell(
                                        isSalida ? '${entry.cantidadSalida}' : '-',
                                        width: 75,
                                        alignRight: true,
                                        bgColor: isSalida ? const Color(0xFFFEF2F2) : null,
                                      ),
                                      _DataCell(
                                        isSalida ? 'Bs ${entry.costoUnitarioPepsSalida.toStringAsFixed(2)}' : '-',
                                        width: 85,
                                        alignRight: true,
                                        bgColor: isSalida ? const Color(0xFFFEF2F2) : null,
                                      ),
                                      _DataCell(
                                        isSalida ? 'Bs ${entry.totalSalida.toStringAsFixed(2)}' : '-',
                                        width: 95,
                                        alignRight: true,
                                        isBold: isSalida,
                                        bgColor: isSalida ? const Color(0xFFFEF2F2) : null,
                                      ),

                                      // SALDOS
                                      _DataCell(
                                        '${entry.saldoCantidad}',
                                        width: 75,
                                        alignRight: true,
                                        isBold: true,
                                        bgColor: const Color(0xFFEFF6FF),
                                      ),
                                      _DataCell(
                                        'Bs ${entry.costoPromedioSaldo.toStringAsFixed(2)}',
                                        width: 85,
                                        alignRight: true,
                                        bgColor: const Color(0xFFEFF6FF),
                                      ),
                                      _DataCell(
                                        'Bs ${entry.saldoValorTotal.toStringAsFixed(2)}',
                                        width: 100,
                                        alignRight: true,
                                        isBold: true,
                                        bgColor: const Color(0xFFEFF6FF),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
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

  Widget _buildSummaryBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                  Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex, Color? bgColor, Color? textColor}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          border: const Border(right: BorderSide(color: AppColors.borderLight)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: textColor ?? AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

class _SubHeaderCell extends StatelessWidget {
  final String label;
  final double width;
  final bool alignRight;

  const _SubHeaderCell(this.label, {required this.width, this.alignRight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.borderLight)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DataCell extends StatelessWidget {
  final String value;
  final double width;
  final bool alignRight;
  final bool isBold;
  final Color? bgColor;

  const _DataCell(
    this.value, {
    required this.width,
    this.alignRight = false,
    this.isBold = false,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      color: bgColor ?? Colors.white,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
