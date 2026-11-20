import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_entities.dart';

/// Gráfico vectorial Donut interactivo para la distribución de existencias.
/// Implementado con [CustomPainter] de alto rendimiento para Flutter Web y Desktop.
class StockDistributionChart extends StatelessWidget {
  final List<CategoryStockDistribution> distribution;

  const StockDistributionChart({super.key, required this.distribution});

  static const List<Color> _palette = [
    AppColors.primary,
    Color(0xFF0D9488), // Teal
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEA580C), // Orange
    Color(0xFF0284C7), // Sky blue
  ];

  @override
  Widget build(BuildContext context) {
    if (distribution.isEmpty) {
      return const Center(child: Text('Sin datos de existencias'));
    }

    final totalUnidades = distribution.fold<int>(0, (acc, item) => acc + item.totalUnidades);

    return Row(
      children: [
        // Donut Chart Vectorial
        SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(190, 190),
                painter: _DonutChartPainter(
                  distribution: distribution,
                  colors: _palette,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$totalUnidades',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'Unidades',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),

        // Leyenda responsiva
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < distribution.length; i++) ...[
                _buildLegendItem(
                  color: _palette[i % _palette.length],
                  item: distribution[i],
                ),
                if (i < distribution.length - 1) const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required CategoryStockDistribution item,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.categoria,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Text(
          '${item.totalUnidades} u.',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${item.porcentaje.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryStockDistribution> distribution;
  final List<Color> colors;

  _DonutChartPainter({required this.distribution, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 28.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (int i = 0; i < distribution.length; i++) {
      final item = distribution[i];
      final sweepAngle = (item.porcentaje / 100.0) * (2 * math.pi);

      paint.color = colors[i % colors.length];

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle - 0.03, // Separación sutil entre segmentos
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.distribution != distribution;
  }
}
