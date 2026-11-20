import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/reports_controller.dart';
import '../widgets/sales_chart_widget.dart';

class ReporteVentasView extends StatelessWidget {
  final ReportsController controller;

  const ReporteVentasView({super.key, required this.controller});

  void _exportarCsv(BuildContext context) {
    controller.exportarReporte(
      tipoReporte: 'Libro de Ventas Fiscal SIAT',
      formato: 'CSV / Excel',
      totalRegistros: controller.siatVouchers.length,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Generando Libro_Ventas_SIAT_${DateTime.now().year}.csv (${controller.siatVouchers.length} comprobantes)...',
        ),
        backgroundColor: AppColors.optimal,
      ),
    );
  }

  void _exportarPdf(BuildContext context) {
    controller.exportarReporte(
      tipoReporte: 'Libro de Ventas Fiscal SIAT',
      formato: 'PDF',
      totalRegistros: controller.siatVouchers.length,
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.picture_as_pdf, color: AppColors.critical),
            SizedBox(width: 8),
            Text('Exportación Oficial SIAT (PDF)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Documento generado bajo el estándar de la Resolución Normativa de Directorio del Servicio de Impuestos Nacionales (SIN).',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Razón Social: LIBRERÍA SAN MARTÍN', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('NIT: 1029485028', style: const TextStyle(fontSize: 12)),
                  Text('Período: Noviembre 2026', style: const TextStyle(fontSize: 12)),
                  Text('Total Comprobantes: ${controller.siatVouchers.length}', style: const TextStyle(fontSize: 12)),
                  Text(
                    'Total Débito Fiscal IVA: Bs ${controller.siatVouchers.fold<double>(0.0, (s, v) => s + v.debitoFiscalIvaBs).toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Descargar PDF'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final vouchers = controller.siatVouchers;
        final totalVentas = vouchers.fold<double>(0.0, (sum, v) => sum + v.montoTotalBs);
        final totalDebitoIva = vouchers.fold<double>(0.0, (sum, v) => sum + v.debitoFiscalIvaBs);

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
                          'Reporte de Ventas y Libro Fiscal SIAT',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Análisis analítico de facturación con fl_chart y registro para Impuestos Nacionales de Bolivia.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.table_view_outlined, size: 16),
                        label: const Text('Exportar a CSV / Excel'),
                        onPressed: () => _exportarCsv(context),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        label: const Text('Exportar a PDF (SIAT)'),
                        onPressed: () => _exportarPdf(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Banner de Mensaje de Éxito
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

              // Card del Gráfico con fl_chart
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.show_chart, color: AppColors.primary, size: 20),
                                ),
                                const SizedBox(width: 10),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Evolución Diaria de Ingresos (fl_chart)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Comportamiento cronológico de ventas brutas facturadas en Bolivianos (Bs).',
                                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.optimalBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '● SINCRONIZADO SIAT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.optimalText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SalesChartWidget(dataPoints: controller.dailySales),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Tabla del Libro de Ventas SIAT
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Libro de Ventas Fiscal (R.N.D. SIAT)',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              Text(
                                'Total Facturado: Bs ${totalVentas.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 14),
                              Text(
                                'Débito Fiscal IVA (13%): Bs ${totalDebitoIva.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.background),
                          columns: const [
                            DataColumn(label: Text('N° Fac.', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Fecha y Hora', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('NIT / CI Cliente', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Razón Social', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Monto Total (Bs)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Débito IVA 13%', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Código Control', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('CUF Fiscal', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Estado SIAT', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: vouchers.map((v) {
                            return DataRow(
                              cells: [
                                DataCell(Text('${v.numeroFactura}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary))),
                                DataCell(Text('${v.fecha.day.toString().padLeft(2, '0')}/${v.fecha.month.toString().padLeft(2, '0')}/${v.fecha.year} ${v.fecha.hour.toString().padLeft(2, '0')}:${v.fecha.minute.toString().padLeft(2, '0')}')),
                                DataCell(Text(v.nitCliente, style: const TextStyle(fontFamily: 'monospace'))),
                                DataCell(Text(v.razonSocial, style: const TextStyle(fontWeight: FontWeight.w600))),
                                DataCell(Text('Bs ${v.montoTotalBs.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                DataCell(Text('Bs ${v.debitoFiscalIvaBs.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.primary))),
                                DataCell(Text(v.codigoControl, style: const TextStyle(fontFamily: 'monospace'))),
                                DataCell(Text(
                                  '${v.cuf.substring(0, 16)}...',
                                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.optimalBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    v.estado,
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
}
