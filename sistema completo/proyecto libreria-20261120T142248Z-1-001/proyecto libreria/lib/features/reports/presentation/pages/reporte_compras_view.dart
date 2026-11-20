import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/reports_controller.dart';

class ReporteComprasView extends StatelessWidget {
  final ReportsController controller;

  const ReporteComprasView({super.key, required this.controller});

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
                          'Reporte de Adquisiciones y Compras Mayoristas',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Consolidado de costos aduaneros CIF, compras locales y plazos de crédito con editoriales.',
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
                        onPressed: () => controller.loadAnalytics(),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                        label: const Text('Exportar Reporte Compras (PDF)'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Generando Reporte de Adquisiciones y Compras en formato PDF...'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tarjetas de Resumen de Compras
              Row(
                children: [
                  _buildSummaryCard(
                    title: 'Inversión en Compras CIF (Mes)',
                    value: 'Bs ${(kpis?.inversionComprasBs ?? 84320.00).toStringAsFixed(2)}',
                    icon: Icons.local_shipping_outlined,
                    color: AppColors.primary,
                    bgColor: AppColors.primaryContainer,
                  ),
                  const SizedBox(width: 14),
                  _buildSummaryCard(
                    title: 'Rotación de Inventario',
                    value: '${(kpis?.indiceRotacion ?? 4.2).toStringAsFixed(1)}x año',
                    icon: Icons.sync,
                    color: const Color(0xFF7C3AED),
                    bgColor: const Color(0xFFF3E8FF),
                  ),
                  const SizedBox(width: 14),
                  _buildSummaryCard(
                    title: 'Margen Comercial Obtenido',
                    value: '${(kpis?.margenComercialPorcentaje ?? 38.4).toStringAsFixed(1)}%',
                    icon: Icons.percent,
                    color: AppColors.optimal,
                    bgColor: AppColors.optimalBg,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Card Informativa de Criterio de Reabastecimiento
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
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          const Text(
                            'Políticas de Reabastecimiento y Comercio Exterior',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '1. Toda adquisición internacional se costea estrictamente bajo el método CIF (FOB + Flete + Seguro) + Gravamen Arancelario GA (10%) + Gastos de Desaduanización.\n'
                        '2. El ingreso físico a bodegas alimenta el Kárdex Físico-Valorado bajo el método PEPS (FIFO), garantizando que las salidas en el POS descuenten siempre del lote más antiguo.\n'
                        '3. Los pedidos de reposición emitidos desde la vista de Stock Semafórico se sincronizan de manera reactiva mediante la Arquitectura Orientada a Eventos (EDA).',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
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

  Widget _buildSummaryCard({
    required String title,
    required String value,
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
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }
}
