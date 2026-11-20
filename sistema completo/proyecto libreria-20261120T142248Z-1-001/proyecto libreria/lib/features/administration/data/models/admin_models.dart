import '../../domain/entities/admin_entities.dart';

/// DTO para Sucursal con serialización JSON.
class BranchModel extends BranchEntity {
  const BranchModel({
    required super.id,
    required super.nombre,
    required super.direccion,
    required super.ciudad,
    required super.encargado,
    required super.cajasPosAsignadas,
    required super.aforoM2,
    required super.ocupacionPorcentaje,
    required super.bodegasVinculadas,
    super.activa,
    super.cuentasPendientes,
    super.activosAsignados,
    super.motivoBaja,
    super.fechaBaja,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String,
      ciudad: json['ciudad'] as String,
      encargado: json['encargado'] as String,
      cajasPosAsignadas: json['cajas_pos_asignadas'] as int,
      aforoM2: (json['aforo_m2'] as num).toDouble(),
      ocupacionPorcentaje: (json['ocupacion_porcentaje'] as num).toDouble(),
      bodegasVinculadas: List<String>.from(json['bodegas_vinculadas'] as List),
      activa: json['activa'] as bool? ?? true,
      cuentasPendientes: (json['cuentas_pendientes'] as num?)?.toDouble() ?? 0.0,
      activosAsignados: json['activos_asignados'] as int? ?? 0,
      motivoBaja: json['motivo_baja'] as String?,
      fechaBaja: json['fecha_baja'] != null ? DateTime.tryParse(json['fecha_baja'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'ciudad': ciudad,
      'encargado': encargado,
      'cajas_pos_asignadas': cajasPosAsignadas,
      'aforo_m2': aforoM2,
      'ocupacion_porcentaje': ocupacionPorcentaje,
      'bodegas_vinculadas': bodegasVinculadas,
      'activa': activa,
      'cuentas_pendientes': cuentasPendientes,
      'activos_asignados': activosAsignados,
      'motivo_baja': motivoBaja,
      'fecha_baja': fechaBaja?.toIso8601String(),
    };
  }
}

/// DTO para SKU / Libro con serialización JSON.
class SkuModel extends SkuEntity {
  const SkuModel({
    required super.id,
    required super.ean13,
    required super.titulo,
    required super.editorial,
    required super.categoria,
    required super.costoBs,
    required super.margenPorcentaje,
    required super.precioVentaBs,
    required super.stockActual,
    super.imagenUrl,
  });

  factory SkuModel.fromJson(Map<String, dynamic> json) {
    return SkuModel(
      id: json['id'] as String,
      ean13: json['ean13'] as String,
      titulo: json['titulo'] as String,
      editorial: json['editorial'] as String,
      categoria: json['categoria'] as String,
      costoBs: (json['costo_bs'] as num).toDouble(),
      margenPorcentaje: (json['margen_porcentaje'] as num).toDouble(),
      precioVentaBs: (json['precio_venta_bs'] as num).toDouble(),
      stockActual: json['stock_actual'] as int,
      imagenUrl: json['imagen_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ean13': ean13,
      'titulo': titulo,
      'editorial': editorial,
      'categoria': categoria,
      'costo_bs': costoBs,
      'margen_porcentaje': margenPorcentaje,
      'precio_venta_bs': precioVentaBs,
      'stock_actual': stockActual,
      'imagen_url': imagenUrl,
    };
  }
}

/// DTO para Parametrización Fiscal SIAT.
class FiscalConfigModel extends FiscalConfigEntity {
  const FiscalConfigModel({
    required super.nit,
    required super.razonSocial,
    required super.cufdActual,
    required super.cuisActual,
    required super.fechaVencimientoCufd,
    super.porcentajeIva,
    super.porcentajeIt,
    super.sincronizadoConSin,
    required super.ultimoPingWebService,
  });

  factory FiscalConfigModel.fromJson(Map<String, dynamic> json) {
    return FiscalConfigModel(
      nit: json['nit'] as String,
      razonSocial: json['razon_social'] as String,
      cufdActual: json['cufd_actual'] as String,
      cuisActual: json['cuis_actual'] as String,
      fechaVencimientoCufd: DateTime.parse(json['fecha_vencimiento_cufd'] as String),
      porcentajeIva: (json['porcentaje_iva'] as num?)?.toDouble() ?? 13.0,
      porcentajeIt: (json['porcentaje_it'] as num?)?.toDouble() ?? 3.0,
      sincronizadoConSin: json['sincronizado_con_sin'] as bool? ?? true,
      ultimoPingWebService: DateTime.parse(json['ultimo_ping_webservice'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nit': nit,
      'razon_social': razonSocial,
      'cufd_actual': cufdActual,
      'cuis_actual': cuisActual,
      'fecha_vencimiento_cufd': fechaVencimientoCufd.toIso8601String(),
      'porcentaje_iva': porcentajeIva,
      'porcentaje_it': porcentajeIt,
      'sincronizado_con_sin': sincronizadoConSin,
      'ultimo_ping_webservice': ultimoPingWebService.toIso8601String(),
    };
  }
}
