library;

/// Entidades de Dominio para el Módulo de Administración y Parametrización Fiscal.
/// Cero dependencias de Flutter o librerías externas.

/// Entidad que representa una Sucursal de la Librería San Martín.
class BranchEntity {
  final String id;
  final String nombre;
  final String direccion;
  final String ciudad;
  final String encargado;
  final int cajasPosAsignadas;
  final double aforoM2;
  final double ocupacionPorcentaje; // 0.0 a 1.0
  final List<String> bodegasVinculadas;
  final bool activa;
  final double cuentasPendientes; // Cuentas por cobrar o pagar pendientes en Bs.
  final int activosAsignados; // Cantidad de ítems/activos de inventario asignados a la sucursal
  final String? motivoBaja;
  final DateTime? fechaBaja;

  const BranchEntity({
    required this.id,
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.encargado,
    required this.cajasPosAsignadas,
    required this.aforoM2,
    required this.ocupacionPorcentaje,
    required this.bodegasVinculadas,
    this.activa = true,
    this.cuentasPendientes = 0.0,
    this.activosAsignados = 0,
    this.motivoBaja,
    this.fechaBaja,
  });

  /// Reglas de Cierre y Baja de Sucursal:
  /// No es posible dar de baja si existen cuentas pendientes (> 0) o activos asignados (> 0).
  bool get tieneCuentasPendientes => cuentasPendientes > 0.0;
  bool get tieneActivosAsignados => activosAsignados > 0;
  bool get puedeDarseDeBaja => cuentasPendientes <= 0.0 && activosAsignados <= 0;

  BranchEntity copyWith({
    String? id,
    String? nombre,
    String? direccion,
    String? ciudad,
    String? encargado,
    int? cajasPosAsignadas,
    double? aforoM2,
    double? ocupacionPorcentaje,
    List<String>? bodegasVinculadas,
    bool? activa,
    double? cuentasPendientes,
    int? activosAsignados,
    String? motivoBaja,
    DateTime? fechaBaja,
  }) {
    return BranchEntity(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      ciudad: ciudad ?? this.ciudad,
      encargado: encargado ?? this.encargado,
      cajasPosAsignadas: cajasPosAsignadas ?? this.cajasPosAsignadas,
      aforoM2: aforoM2 ?? this.aforoM2,
      ocupacionPorcentaje: ocupacionPorcentaje ?? this.ocupacionPorcentaje,
      bodegasVinculadas: bodegasVinculadas ?? this.bodegasVinculadas,
      activa: activa ?? this.activa,
      cuentasPendientes: cuentasPendientes ?? this.cuentasPendientes,
      activosAsignados: activosAsignados ?? this.activosAsignados,
      motivoBaja: motivoBaja ?? this.motivoBaja,
      fechaBaja: fechaBaja ?? this.fechaBaja,
    );
  }
}

/// Entidad que representa un ítem de Catálogo SKU / Libro / Producto.
class SkuEntity {
  final String id;
  final String ean13;
  final String titulo;
  final String editorial;
  final String categoria;
  final double costoBs;
  final double margenPorcentaje; // ej. 30.0 para 30%
  final double precioVentaBs;
  final int stockActual;
  final String? imagenUrl;

  const SkuEntity({
    required this.id,
    required this.ean13,
    required this.titulo,
    required this.editorial,
    required this.categoria,
    required this.costoBs,
    required this.margenPorcentaje,
    required this.precioVentaBs,
    required this.stockActual,
    this.imagenUrl,
  });

  /// Fórmula canónica de fijación de precios retail:
  /// Precio Venta = Costo / (1 - (Margen / 100))
  static double calcularPrecioVenta(double costo, double margenPorcentaje) {
    if (margenPorcentaje >= 100.0) return costo * 2;
    final margenDecimal = margenPorcentaje / 100.0;
    if (margenDecimal >= 1.0) return costo;
    final precio = costo / (1.0 - margenDecimal);
    return double.parse(precio.toStringAsFixed(2));
  }
}

/// Entidad para Parametrización Fiscal del SIAT (Impuestos Nacionales Bolivia).
class FiscalConfigEntity {
  final String nit;
  final String razonSocial;
  final String cufdActual;
  final String cuisActual;
  final DateTime fechaVencimientoCufd;
  final double porcentajeIva; // 13.0%
  final double porcentajeIt; // 3.0%
  final bool sincronizadoConSin;
  final DateTime ultimoPingWebService;

  const FiscalConfigEntity({
    required this.nit,
    required this.razonSocial,
    required this.cufdActual,
    required this.cuisActual,
    required this.fechaVencimientoCufd,
    this.porcentajeIva = 13.0,
    this.porcentajeIt = 3.0,
    this.sincronizadoConSin = true,
    required this.ultimoPingWebService,
  });

  FiscalConfigEntity copyWith({
    String? nit,
    String? razonSocial,
    String? cufdActual,
    String? cuisActual,
    DateTime? fechaVencimientoCufd,
    double? porcentajeIva,
    double? porcentajeIt,
    bool? sincronizadoConSin,
    DateTime? ultimoPingWebService,
  }) {
    return FiscalConfigEntity(
      nit: nit ?? this.nit,
      razonSocial: razonSocial ?? this.razonSocial,
      cufdActual: cufdActual ?? this.cufdActual,
      cuisActual: cuisActual ?? this.cuisActual,
      fechaVencimientoCufd: fechaVencimientoCufd ?? this.fechaVencimientoCufd,
      porcentajeIva: porcentajeIva ?? this.porcentajeIva,
      porcentajeIt: porcentajeIt ?? this.porcentajeIt,
      sincronizadoConSin: sincronizadoConSin ?? this.sincronizadoConSin,
      ultimoPingWebService: ultimoPingWebService ?? this.ultimoPingWebService,
    );
  }
}

/// Entidad para KPIs del módulo de Administración.
class AdminKpiEntity {
  final int sedesActivas;
  final int totalSkuMaestros;
  final int totalCategorias;
  final String estadoCufdSiat;
  final List<CategoryStockDistribution> distribucionExistencias;

  const AdminKpiEntity({
    required this.sedesActivas,
    required this.totalSkuMaestros,
    required this.totalCategorias,
    required this.estadoCufdSiat,
    required this.distribucionExistencias,
  });
}

/// Distribución de existencias por familia para gráficos.
class CategoryStockDistribution {
  final String categoria;
  final int totalUnidades;
  final double porcentaje;

  const CategoryStockDistribution({
    required this.categoria,
    required this.totalUnidades,
    required this.porcentaje,
  });
}
