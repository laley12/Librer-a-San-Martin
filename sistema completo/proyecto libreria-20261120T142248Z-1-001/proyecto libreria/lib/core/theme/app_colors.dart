import 'package:flutter/material.dart';

/// Paleta de colores corporativos del sistema ERP "Librería San Martín".
class AppColors {
  // Primario y Acentos
  static const Color primary = Color(0xFF2563EB); // Azul corporativo
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryContainer = Color(0xFFEFF6FF);

  // Fondos y Superficies
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);

  // Bordes y Divisores
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderMedium = Color(0xFFCBD5E1);

  // Textos
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400

  // Colores de Estado Semafórico
  static const Color optimal = Color(0xFF16A34A); // Verde
  static const Color optimalBg = Color(0xFFDCFCE7); // Verde claro para badges
  static const Color optimalText = Color(0xFF14532D);

  static const Color warning = Color(0xFFEA580C); // Ámbar / Naranja
  static const Color warningBg = Color(0xFFFFEDD5);
  static const Color warningText = Color(0xFF7C2D12);

  static const Color critical = Color(0xFFDC2626); // Rojo
  static const Color criticalBg = Color(0xFFFEE2E2);
  static const Color criticalText = Color(0xFF7F1D1D);

  // Sidebar oscuro / profesional
  static const Color sidebarBackground = Color(0xFF0F172A); // Slate 900
  static const Color sidebarItemHover = Color(0xFF1E293B); // Slate 800
  static const Color sidebarItemActive = Color(0xFF2563EB); // Azul corporativo
  static const Color sidebarText = Color(0xFFE2E8F0);
  static const Color sidebarTextMuted = Color(0xFF94A3B8);
}

/// Extensión de tema para acceder a los colores semafóricos mediante `Theme.of(context)`.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color optimal;
  final Color optimalBg;
  final Color optimalText;

  final Color warning;
  final Color warningBg;
  final Color warningText;

  final Color critical;
  final Color criticalBg;
  final Color criticalText;

  final Color borderLight;

  const AppSemanticColors({
    required this.optimal,
    required this.optimalBg,
    required this.optimalText,
    required this.warning,
    required this.warningBg,
    required this.warningText,
    required this.critical,
    required this.criticalBg,
    required this.criticalText,
    required this.borderLight,
  });

  factory AppSemanticColors.standard() => const AppSemanticColors(
        optimal: AppColors.optimal,
        optimalBg: AppColors.optimalBg,
        optimalText: AppColors.optimalText,
        warning: AppColors.warning,
        warningBg: AppColors.warningBg,
        warningText: AppColors.warningText,
        critical: AppColors.critical,
        criticalBg: AppColors.criticalBg,
        criticalText: AppColors.criticalText,
        borderLight: AppColors.borderLight,
      );

  @override
  AppSemanticColors copyWith({
    Color? optimal,
    Color? optimalBg,
    Color? optimalText,
    Color? warning,
    Color? warningBg,
    Color? warningText,
    Color? critical,
    Color? criticalBg,
    Color? criticalText,
    Color? borderLight,
  }) {
    return AppSemanticColors(
      optimal: optimal ?? this.optimal,
      optimalBg: optimalBg ?? this.optimalBg,
      optimalText: optimalText ?? this.optimalText,
      warning: warning ?? this.warning,
      warningBg: warningBg ?? this.warningBg,
      warningText: warningText ?? this.warningText,
      critical: critical ?? this.critical,
      criticalBg: criticalBg ?? this.criticalBg,
      criticalText: criticalText ?? this.criticalText,
      borderLight: borderLight ?? this.borderLight,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      optimal: Color.lerp(optimal, other.optimal, t)!,
      optimalBg: Color.lerp(optimalBg, other.optimalBg, t)!,
      optimalText: Color.lerp(optimalText, other.optimalText, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      critical: Color.lerp(critical, other.critical, t)!,
      criticalBg: Color.lerp(criticalBg, other.criticalBg, t)!,
      criticalText: Color.lerp(criticalText, other.criticalText, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
    );
  }
}
