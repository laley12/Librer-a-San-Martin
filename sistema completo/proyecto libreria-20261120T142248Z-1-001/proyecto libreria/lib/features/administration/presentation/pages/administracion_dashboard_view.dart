import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/administration_controller.dart';
import '../widgets/stock_distribution_chart.dart';

/// Vista: Dashboard de Administración y Parametrización
class AdministracionDashboardView extends StatelessWidget {
  final AdministrationController controller;

  const AdministracionDashboardView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final kpis = controller.kpis;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. FILA DE 4 TARJETAS KPI
              Row(
                children: [
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Sedes Operativas',
                      value: '${kpis?.sedesActivas ?? 2}',
                      subtitle: 'Santa Cruz & La Guardia',
                      icon: Icons.storefront_outlined,
                      color: AppColors.primary,
                      badge: 'ACTIVAS',
                      badgeBg: AppColors.primaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Total SKU Maestros',
                      value: '${kpis?.totalSkuMaestros ?? 1248}',
                      subtitle: 'Títulos y artículos en catálogo',
                      icon: Icons.auto_stories_outlined,
                      color: const Color(0xFF0D9488), // Teal
                      badge: 'CATÁLOGO',
                      badgeBg: const Color(0xFFCCFBF1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Categorías / Familias',
                      value: '${kpis?.totalCategorias ?? 14}',
                      subtitle: 'Estructura departamental',
                      icon: Icons.category_outlined,
                      color: const Color(0xFF8B5CF6), // Purple
                      badge: 'ESTRUCTURA',
                      badgeBg: const Color(0xFFEDE9FE),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildKpiCard(
                      title: 'Estado CUFD SIAT',
                      value: kpis?.estadoCufdSiat ?? 'Vigente',
                      subtitle: 'Sincronizado con SIN Bolivia',
                      icon: Icons.verified_outlined,
                      color: AppColors.optimal,
                      badge: '23:59 VENCE',
                      badgeBg: AppColors.optimalBg,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. GRÁFICO DE DISTRIBUCIÓN DE EXISTENCIAS Y RESUMEN
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.pie_chart_outline, color: AppColors.primary, size: 22),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Distribución de Existencias por Familia de Artículos',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Actualizar Inventario'),
                            onPressed: () => controller.loadKpis(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Desglose porcentual y balance de existencias físicas entre almacenes centrales y sucursales.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: AppColors.borderLight, height: 1),
                      const SizedBox(height: 20),

                      // Gráfico Vectorial
                      StockDistributionChart(
                        distribution: kpis?.distribucionExistencias ?? const [],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 3. ESTADO OPERATIVO DE SERVICIOS
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Servicios Tributarios SIAT',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Conectado al WebService de Facturación Electrónica en Línea (SIN). '
                              'Llaves criptográficas de firma digital vigentes.',
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.optimalBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: AppColors.optimal),
                                  SizedBox(width: 6),
                                  Text(
                                    'WebService SIAT: OK (42 ms)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.optimalText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.qr_code_scanner, color: AppColors.primary, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Hardware Periférico USB',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Lector de código de barras USB configurado con protocolo HID estándar. '
                              'Captura automática de códigos EAN-13.',
                              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.usb, size: 14, color: AppColors.primary),
                                  SizedBox(width: 6),
                                  Text(
                                    'Driver HID USB: Activo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
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
    required String badge,
    required Color badgeBg,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
