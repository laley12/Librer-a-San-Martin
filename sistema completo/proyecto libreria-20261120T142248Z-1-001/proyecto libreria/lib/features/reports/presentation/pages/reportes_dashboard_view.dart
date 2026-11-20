import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/reports_controller.dart';
import '../widgets/sales_chart_widget.dart';

class ReportesDashboardView extends StatelessWidget {
  final ReportsController controller;
  final Function(String menuId)? onNavigate;

  const ReportesDashboardView({
    super.key,
    required this.controller,
    this.onNavigate,
  });

  Future<void> _seleccionarRangoFechas(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: controller.dateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.setDateRange(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final kpis = controller.kpis;
        final range = controller.dateRange;
        final rangeLabel =
            '${range.start.day}/${range.start.month}/${range.start.year} - ${range.end.day}/${range.end.month}/${range.end.year}';

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado con Selector de Fechas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Centro de Inteligencia de Negocios y Reportes',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Métricas financieras consolidadas, rentabilidad retail y criticidad de existencias.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.date_range, size: 18, color: AppColors.primary),
                    label: Text(
                      rangeLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderLight),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onPressed: () => _seleccionarRangoFechas(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fila de 4 Tarjetas KPI Solicitadas:
              // Margen Comercial %, Ticket Promedio Bs, Índice de Rotación, Inversión en Compras
              Row(
                children: [
                  _buildKpiCard(
                    title: 'Margen Comercial %',
                    value: '${(kpis?.margenComercialPorcentaje ?? 38.4).toStringAsFixed(1)}%',
                    subtitle: 'Utilidad Bruta sobre Ventas',
                    icon: Icons.percent,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 14),
                  _buildKpiCard(
                    title: 'Ticket Promedio Bs',
                    value: 'Bs ${(kpis?.ticketPromedioBs ?? 186.50).toStringAsFixed(2)}',
                    subtitle: 'Por Comprobante Emitido',
                    icon: Icons.receipt_outlined,
                    color: AppColors.optimal,
                    bgColor: AppColors.optimalBg,
                  ),
                  const SizedBox(width: 14),
                  _buildKpiCard(
                    title: 'Índice de Rotación',
                    value: '${(kpis?.indiceRotacion ?? 4.2).toStringAsFixed(1)}x',
                    subtitle: 'Ciclos anuales de stock',
                    icon: Icons.sync,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                  ),
                  const SizedBox(width: 14),
                  _buildKpiCard(
                    title: 'Inversión en Compras',
                    value: 'Bs ${(kpis?.inversionComprasBs ?? 84320.00).toStringAsFixed(2)}',
                    subtitle: 'Capital invertido en CIF/PEPS',
                    icon: Icons.account_balance_wallet_outlined,
                    color: AppColors.warningText,
                    bgColor: AppColors.warningBg,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Gráfico y Accesos Rápidos
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gráfico de Ventas
                  Expanded(
                    flex: 7,
                    child: Card(
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
                                const Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.trending_up, color: AppColors.primary, size: 22),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Evolución Diaria de Ingresos (fl_chart)',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.fullscreen, size: 16),
                                  label: const Text('Ver Detalle'),
                                  onPressed: () => onNavigate?.call('rep_ventas'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SalesChartWidget(dataPoints: controller.dailySales),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Resumen de Stock Semafórico
                  Expanded(
                    flex: 5,
                    child: Card(
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
                              children: [
                                const Icon(Icons.traffic, color: AppColors.primary, size: 22),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Estado del Semáforo de Stock',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            _buildStatusSummaryTile(
                              title: '🔴 CRÍTICO / AGOTADO',
                              count: controller.totalCriticos,
                              description: 'Existencias menores o iguales al Stock Mínimo. Requieren reabastecimiento urgente.',
                              color: AppColors.critical,
                              bgColor: AppColors.criticalBg,
                            ),
                            const SizedBox(height: 10),
                            _buildStatusSummaryTile(
                              title: '🟡 ATENCIÓN / REORDEN',
                              count: controller.totalReorden,
                              description: 'Stock menor a 1.5x del Stock Mínimo. Próximo al punto de reposición.',
                              color: AppColors.warningText,
                              bgColor: AppColors.warningBg,
                            ),
                            const SizedBox(height: 10),
                            _buildStatusSummaryTile(
                              title: '🟢 ÓPTIMO / NORMAL',
                              count: controller.totalOptimos,
                              description: 'Stock saludable con cobertura adecuada de ventas.',
                              color: AppColors.optimal,
                              bgColor: AppColors.optimalBg,
                            ),
                            const SizedBox(height: 16),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 16),
                                label: const Text('Auditar Stock Semafórico'),
                                onPressed: () => onNavigate?.call('rep_stock'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Expanded(
      child: Card(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                    child: Icon(icon, color: color, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSummaryTile({
    required String title,
    required int count,
    required String description,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
