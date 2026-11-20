import '../../domain/entities/sales_purchases_entities.dart';

/// DTO para Producto POS
class PosProductModel extends PosProductEntity {
  const PosProductModel({
    required super.sku,
    required super.titulo,
    required super.editorial,
    required super.categoria,
    required super.precioVenta,
    required super.stockDisponible,
    required super.codigoBarra,
    super.imagenUrl,
  });

  factory PosProductModel.fromJson(Map<String, dynamic> json) {
    return PosProductModel(
      sku: json['sku'] as String,
      titulo: json['titulo'] as String,
      editorial: json['editorial'] as String,
      categoria: json['categoria'] as String,
      precioVenta: (json['precio_venta'] as num).toDouble(),
      stockDisponible: json['stock_disponible'] as int,
      codigoBarra: json['codigo_barra'] as String,
      imagenUrl: json['imagen_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'titulo': titulo,
      'editorial': editorial,
      'categoria': categoria,
      'precio_venta': precioVenta,
      'stock_disponible': stockDisponible,
      'codigo_barra': codigoBarra,
      'imagen_url': imagenUrl,
    };
  }
}

/// DTO para Cliente
class CustomerModel extends CustomerEntity {
  const CustomerModel({
    required super.nitCi,
    required super.razonSocial,
    super.email,
    super.telefono,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      nitCi: json['nit_ci'] as String,
      razonSocial: json['razon_social'] as String,
      email: json['email'] as String?,
      telefono: json['telefono'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nit_ci': nitCi,
      'razon_social': razonSocial,
      'email': email,
      'telefono': telefono,
    };
  }
}

/// DTO para Kárdex PEPS
class KardexEntryModel extends KardexEntryEntity {
  const KardexEntryModel({
    required super.id,
    required super.sku,
    required super.fecha,
    required super.comprobante,
    required super.detalle,
    required super.tipo,
    required super.cantidadEntrada,
    required super.costoUnitarioEntrada,
    required super.totalEntrada,
    required super.cantidadSalida,
    required super.costoUnitarioPepsSalida,
    required super.totalSalida,
    required super.saldoCantidad,
    required super.costoPromedioSaldo,
    required super.saldoValorTotal,
  });

  factory KardexEntryModel.fromJson(Map<String, dynamic> json) {
    return KardexEntryModel(
      id: json['id'] as String,
      sku: json['sku'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      comprobante: json['comprobante'] as String,
      detalle: json['detalle'] as String,
      tipo: KardexEntryType.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => KardexEntryType.ventaPos,
      ),
      cantidadEntrada: json['cantidad_entrada'] as int,
      costoUnitarioEntrada: (json['costo_unitario_entrada'] as num).toDouble(),
      totalEntrada: (json['total_entrada'] as num).toDouble(),
      cantidadSalida: json['cantidad_salida'] as int,
      costoUnitarioPepsSalida: (json['costo_unitario_peps_salida'] as num).toDouble(),
      totalSalida: (json['total_salida'] as num).toDouble(),
      saldoCantidad: json['saldo_cantidad'] as int,
      costoPromedioSaldo: (json['costo_promedio_saldo'] as num).toDouble(),
      saldoValorTotal: (json['saldo_valor_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'fecha': fecha.toIso8601String(),
      'comprobante': comprobante,
      'detalle': detalle,
      'tipo': tipo.name,
      'cantidad_entrada': cantidadEntrada,
      'costo_unitario_entrada': costoUnitarioEntrada,
      'total_entrada': totalEntrada,
      'cantidad_salida': cantidadSalida,
      'costo_unitario_peps_salida': costoUnitarioPepsSalida,
      'total_salida': totalSalida,
      'saldo_cantidad': saldoCantidad,
      'costo_promedio_saldo': costoPromedioSaldo,
      'saldo_valor_total': saldoValorTotal,
    };
  }
}

/// DTO para Orden CIF
class CifOrderModel extends CifOrderEntity {
  const CifOrderModel({
    required super.id,
    required super.codigoOrden,
    required super.proveedor,
    required super.sku,
    required super.skuTitulo,
    required super.cantidadUnidades,
    required super.fobTotalUsd,
    required super.fleteUsd,
    required super.seguroUsd,
    super.tipoCambioBob,
    super.gaPorcentaje,
    required super.gastosDespachoBob,
    required super.fechaRegistro,
    super.estado,
  });

  factory CifOrderModel.fromJson(Map<String, dynamic> json) {
    return CifOrderModel(
      id: json['id'] as String,
      codigoOrden: json['codigo_orden'] as String,
      proveedor: json['proveedor'] as String,
      sku: json['sku'] as String,
      skuTitulo: json['sku_titulo'] as String,
      cantidadUnidades: json['cantidad_unidades'] as int,
      fobTotalUsd: (json['fob_total_usd'] as num).toDouble(),
      fleteUsd: (json['flete_usd'] as num).toDouble(),
      seguroUsd: (json['seguro_usd'] as num).toDouble(),
      tipoCambioBob: (json['tipo_cambio_bob'] as num?)?.toDouble() ?? 6.96,
      gaPorcentaje: (json['ga_porcentaje'] as num?)?.toDouble() ?? 0.10,
      gastosDespachoBob: (json['gastos_despacho_bob'] as num).toDouble(),
      fechaRegistro: DateTime.parse(json['fecha_registro'] as String),
      estado: json['estado'] as String? ?? 'Nacionalizado en Bodega',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_orden': codigoOrden,
      'proveedor': proveedor,
      'sku': sku,
      'sku_titulo': skuTitulo,
      'cantidad_unidades': cantidadUnidades,
      'fob_total_usd': fobTotalUsd,
      'flete_usd': fleteUsd,
      'seguro_usd': seguroUsd,
      'tipo_cambio_bob': tipoCambioBob,
      'ga_porcentaje': gaPorcentaje,
      'gastos_despacho_bob': gastosDespachoBob,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'estado': estado,
    };
  }
}

/// DTO para Proveedor
class SupplierModel extends SupplierEntity {
  const SupplierModel({
    required super.id,
    required super.nit,
    required super.razonSocial,
    required super.contacto,
    required super.telefono,
    required super.email,
    required super.pais,
    required super.categorias,
    required super.plazoCreditoDias,
    super.estado,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      nit: json['nit'] as String,
      razonSocial: json['razon_social'] as String,
      contacto: json['contacto'] as String,
      telefono: json['telefono'] as String,
      email: json['email'] as String,
      pais: json['pais'] as String,
      categorias: List<String>.from(json['categorias'] as List),
      plazoCreditoDias: json['plazo_credito_dias'] as int,
      estado: json['estado'] as String? ?? 'Activo',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nit': nit,
      'razon_social': razonSocial,
      'contacto': contacto,
      'telefono': telefono,
      'email': email,
      'pais': pais,
      'categorias': categorias,
      'plazo_credito_dias': plazoCreditoDias,
      'estado': estado,
    };
  }
}
