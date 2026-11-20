import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/reports_entities.dart';

class StockStatusBadge extends StatelessWidget {
  final StockStatus status;

  const StockStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    switch (status) {
      case StockStatus.critico:
        bgColor = AppColors.criticalBg;
        textColor = AppColors.criticalText;
        icon = Icons.error_outline;
        text = 'CRÍTICO / AGOTADO';
        break;
      case StockStatus.reorden:
        bgColor = AppColors.warningBg;
        textColor = AppColors.warningText;
        icon = Icons.warning_amber_rounded;
        text = 'ATENCIÓN / REORDEN';
        break;
      case StockStatus.optimo:
        bgColor = AppColors.optimalBg;
        textColor = AppColors.optimalText;
        icon = Icons.check_circle_outline;
        text = 'ÓPTIMO / NORMAL';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
