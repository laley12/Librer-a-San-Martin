import 'package:flutter/material.dart';

/// Puntos de corte estándar para Flutter Web.
class Breakpoints {
  static const double mobileMax = 599.0;
  static const double tabletMin = 600.0;
  static const double tabletMax = 1023.0;
  static const double desktopMin = 1024.0;
  static const double maxContentWidth = 1280.0;
}

enum ScreenType { mobile, tablet, desktop }

/// Widget contenedor que selecciona la vista adecuada según el ancho de pantalla.
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext context) desktop;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) mobile;

  const ResponsiveLayout({
    super.key,
    required this.desktop,
    this.tablet,
    required this.mobile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.desktopMin) {
          return desktop(context);
        } else if (constraints.maxWidth >= Breakpoints.tabletMin) {
          return (tablet ?? desktop)(context);
        } else {
          return mobile(context);
        }
      },
    );
  }
}

/// Extensiones de conveniencia para consultar el tipo de pantalla desde cualquier BuildContext.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < Breakpoints.tabletMin;
  bool get isTablet =>
      screenWidth >= Breakpoints.tabletMin && screenWidth <= Breakpoints.tabletMax;
  bool get isDesktop => screenWidth >= Breakpoints.desktopMin;

  ScreenType get screenType {
    if (isDesktop) return ScreenType.desktop;
    if (isTablet) return ScreenType.tablet;
    return ScreenType.mobile;
  }
}
