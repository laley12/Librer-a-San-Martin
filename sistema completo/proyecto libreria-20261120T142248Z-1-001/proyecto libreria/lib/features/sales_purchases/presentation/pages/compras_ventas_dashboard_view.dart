import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/sales_purchases_controller.dart';

class ComprasVentasDashboardView extends StatelessWidget {
  final SalesPurchasesController controller;
  final Function(String menuId)? onNavigate;

  const ComprasVentasDashboardView({
    super.key,
    required this.controller,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final kpis = controller.kpis;

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
                          'Panel Operativo: Compra, Venta y Kárdex PEPS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Monitoreo en tiempo real de facturación POS, costeo aduanero CIF y rotación de inventarios.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.point_of_sale, size: 18),
                    label: const Text('Abrir Terminal POS (F10)'),
                    onPressed: () {
                      if (onNavigate != null) onNavigate!('cv_pos');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fila de 4 Tarjetas KPI
              Row(
                children: [
                  _buildKpiCard(
                    title: 'Ventas del Día (POS)',
                    value: 'Bs ${(kpis?.ventasHoyBs ?? 14820.50).toStringAsFixed(2)}',
                    subtitle: '${kpis?.facturasEmitidasHoy ?? 38} Facturas SIAT',
                    icon: Icons.monetization_on_outlined,
                    color: AppColors.optimal,
                    bgColor: AppColors.optimalBg,
                  ),
                  const SizedBox(width: 14),
                  _buildKpiCard(
                    title: 'Compras CIF en Tránsito',
                    value: 'Bs ${(kpis?.comprasCifMesBs ?? 84320.00).toStringAsFixed(2)}',
                    subtitle: '${controller.cifOrders.length} Órdenes Nacionalizadas',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 14),
                  _buildKpiCard(
                    title: 'Alertas de Stock',
                    value: '${kpis?.skusBajoStock ?? 2} SKUs',
                    subtitle: 'Agotados o Nivel Crítico (<= 5)',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    bgColor: AppColors.warningBg,
                  ),
                  const SizedBox(width: 14),
                  _buildKpiCard(
                    title: 'Margen Promedio PEPS',
                    value: '${kpis?.margenPromedioPeps ?? 38.6}%',
                    subtitle: 'Utilidad Bruta Valorada',
                    icon: Icons.trending_up,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Accesos Rápidos Operativos
              Row(
                children: [
                  _buildQuickActionCard(
                    title: 'Punto de Venta POS (F10)',
                    description: 'Facturación rápida con lectura USB de código de barras y cobro QR Simple / Efectivo.',
                    icon: Icons.point_of_sale,
                    buttonLabel: 'Ir al POS',
                    onTap: () => onNavigate?.call('cv_pos'),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActionCard(
                    title: 'Kárdex Físico-Valorado PEPS',
                    description: 'Auditoría contable y salidas valoradas según el lote más antiguo en bodega.',
                    icon: Icons.table_chart_outlined,
                    buttonLabel: 'Consultar Kárdex',
                    onTap: () => onNavigate?.call('cv_kardex'),
                  ),
                  const SizedBox(width: 16),
                  _buildQuickActionCard(
                    title: 'Órdenes de Compra CIF',
                    description: 'Costeo de importación internacional (FOB + Flete + Seguro + GA 10% + Desaduanización).',
                    icon: Icons.local_shipping_outlined,
                    buttonLabel: 'Costear CIF',
                    onTap: () => onNavigate?.call('cv_cif'),
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

  Widget _buildQuickActionCard({
    required String title,
    required String description,
    required IconData icon,
    required String buttonLabel,
    required VoidCallback onTap,
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
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_forward, size: 16),
                label: Text(buttonLabel),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
