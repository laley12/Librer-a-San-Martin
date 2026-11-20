import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reports_entities.dart';
import '../controllers/reports_controller.dart';
import '../widgets/stock_status_badge.dart';

class ReporteStockSemaforicoView extends StatelessWidget {
  final ReportsController controller;
  final Function(String menuId)? onNavigate;

  const ReporteStockSemaforicoView({
    super.key,
    required this.controller,
    this.onNavigate,
  });

  void _mostrarDialogoGenerarOrden(BuildContext context, StockSemaforicEntity item) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.criticalBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.shopping_cart_checkout, color: AppColors.critical, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Generar Orden de Compra (Reposición)'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Producto: ${item.titulo}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
            const SizedBox(height: 4),
            Text('SKU: ${item.sku} • Editorial: ${item.editorial}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Stock Actual en Almacén:', style: TextStyle(fontSize: 12)),
                      Text('${item.stockActual} un.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.critical)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Stock Mínimo de Seguridad:', style: TextStyle(fontSize: 12)),
                      Text('${item.stockMinimo} un.', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Divider(color: AppColors.borderLight, height: 1),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Cantidad Sugerida de Compra:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      Text(
                        '${item.cantidadRecomendadaCompra} un.',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Al confirmar, se emitirá un evento desacoplado (EDA) para alimentar la bandeja de Órdenes de Compra CIF.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Confirmar y Solicitar Reposición'),
            onPressed: () {
              controller.solicitarReposicion(item);
              Navigator.of(context).pop();
            },
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
        final items = controller.filteredStockItems;

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
                          'Auditoría y Semáforo de Existencias (Stock Semafórico)',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Criterio estricto de criticidad: Rojo (Crítico <= Mínimo), Amarillo (Reorden <= 1.5x) y Verde (Saludable).',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      // Botón Filtro Rápido "Solo Críticos"
                      ElevatedButton.icon(
                        icon: Icon(
                          controller.soloCriticosFilter ? Icons.filter_alt : Icons.filter_alt_outlined,
                          size: 16,
                        ),
                        label: Text(
                          controller.soloCriticosFilter ? 'Ver Todos' : 'Solo Críticos',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: controller.soloCriticosFilter ? AppColors.critical : AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => controller.toggleSoloCriticos(),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Actualizar'),
                        onPressed: () => controller.loadStockSemaforico(),
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

              // Tarjetas Resumen del Semáforo
              Row(
                children: [
                  _buildSummaryBadge(
                    title: '🔴 CRÍTICO / AGOTADO',
                    count: controller.totalCriticos,
                    subtitle: 'Stock <= Stock Mínimo',
                    color: AppColors.critical,
                    bgColor: AppColors.criticalBg,
                  ),
                  const SizedBox(width: 14),
                  _buildSummaryBadge(
                    title: '🟡 ATENCIÓN / REORDEN',
                    count: controller.totalReorden,
                    subtitle: 'Stock <= 1.5x Mínimo',
                    color: AppColors.warningText,
                    bgColor: AppColors.warningBg,
                  ),
                  const SizedBox(width: 14),
                  _buildSummaryBadge(
                    title: '🟢 ÓPTIMO / NORMAL',
                    count: controller.totalOptimos,
                    subtitle: 'Stock Saludable',
                    color: AppColors.optimal,
                    bgColor: AppColors.optimalBg,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tabla Especializada con Filas Resaltadas en Rojo Suave
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
                          Row(
                            children: [
                              const Icon(Icons.traffic, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Matriz de Criticidad de Inventario',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Mostrando ${items.length} títulos',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.background),
                          columns: const [
                            DataColumn(label: Text('SKU', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Título del Producto', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Editorial', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Stock Actual', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Stock Mín.', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Estado Semafórico', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Compra Sugerida', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Acción Operativa', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: items.map((item) {
                            final isCritico = item.esCritico;

                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>((states) {
                                // Fila resaltada en rojo suave para críticos
                                if (isCritico) return const Color(0xFFFFF1F2);
                                return null;
                              }),
                              cells: [
                                DataCell(Text(item.sku, style: TextStyle(fontWeight: FontWeight.bold, color: isCritico ? AppColors.critical : AppColors.primary))),
                                DataCell(Text(
                                  item.titulo,
                                  style: TextStyle(
                                    fontWeight: isCritico ? FontWeight.bold : FontWeight.w600,
                                    color: isCritico ? AppColors.criticalText : AppColors.textPrimary,
                                  ),
                                )),
                                DataCell(Text(item.editorial)),
                                DataCell(Text(item.categoria)),
                                DataCell(Text(
                                  '${item.stockActual}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: isCritico
                                        ? AppColors.critical
                                        : item.esReorden
                                            ? AppColors.warningText
                                            : AppColors.optimal,
                                  ),
                                )),
                                DataCell(Text('${item.stockMinimo}')),
                                DataCell(StockStatusBadge(status: item.status)),
                                DataCell(Text(
                                  isCritico ? '${item.cantidadRecomendadaCompra} un.' : '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isCritico ? AppColors.critical : AppColors.textSecondary,
                                  ),
                                )),
                                DataCell(
                                  isCritico
                                      ? ElevatedButton.icon(
                                          icon: const Icon(Icons.add_shopping_cart, size: 14),
                                          label: const Text('Generar Orden de Compra', style: TextStyle(fontSize: 11)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.critical,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                          ),
                                          onPressed: () => _mostrarDialogoGenerarOrden(context, item),
                                        )
                                      : const Text('-', style: TextStyle(color: AppColors.textMuted)),
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

  Widget _buildSummaryBadge({
    required String title,
    required int count,
    required String subtitle,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text(
              '$count',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
