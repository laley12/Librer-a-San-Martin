import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reports_entities.dart';

class SalesChartWidget extends StatelessWidget {
  final List<DailySalesDataPoint> dataPoints;

  const SalesChartWidget({super.key, required this.dataPoints});

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(
          child: Text(
            'No hay datos de ventas disponibles para el período',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final maxVal = dataPoints
        .map((e) => e.totalVentasBs)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxVal * 1.25).clamp(1000.0, 100000.0);

    final spots = <FlSpot>[];
    for (int i = 0; i < dataPoints.length; i++) {
      spots.add(FlSpot(i.toDouble(), dataPoints[i].totalVentasBs));
    }

    return SizedBox(
      height: 260,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => const FlLine(
              color: AppColors.borderLight,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 55,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Text(
                    'Bs ${(value / 1000).toStringAsFixed(1)}k',
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < dataPoints.length) {
                    final point = dataPoints[index];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        point.diaLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (dataPoints.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xFF0F172A),
              tooltipBorder: BorderSide.none,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  final point = dataPoints[index];
                  return LineTooltipItem(
                    '${point.diaLabel} - Bs ${point.totalVentasBs.toStringAsFixed(2)}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '${point.totalFacturas} facturas emitidas',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 10.5,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: Colors.white,
                    strokeWidth: 2.5,
                    strokeColor: AppColors.primary,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.25),
                    AppColors.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
