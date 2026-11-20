import '../../domain/entities/reports_entities.dart';

/// DTO para Ítem de Stock Semafórico
class StockSemaforicModel extends StockSemaforicEntity {
  const StockSemaforicModel({
    required super.sku,
    required super.titulo,
    required super.editorial,
    required super.categoria,
    required super.stockActual,
    required super.stockMinimo,
    required super.costoUnitarioBs,
    required super.precioVentaBs,
  });

  factory StockSemaforicModel.fromJson(Map<String, dynamic> json) {
    return StockSemaforicModel(
      sku: json['sku'] as String,
      titulo: json['titulo'] as String,
      editorial: json['editorial'] as String,
      categoria: json['categoria'] as String,
      stockActual: json['stock_actual'] as int,
      stockMinimo: json['stock_minimo'] as int,
      costoUnitarioBs: (json['costo_unitario_bs'] as num).toDouble(),
      precioVentaBs: (json['precio_venta_bs'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sku': sku,
      'titulo': titulo,
      'editorial': editorial,
      'categoria': categoria,
      'stock_actual': stockActual,
      'stock_minimo': stockMinimo,
      'costo_unitario_bs': costoUnitarioBs,
      'precio_venta_bs': precioVentaBs,
    };
  }
}

/// DTO para Punto de Evolución de Ventas
class DailySalesDataPointModel extends DailySalesDataPoint {
  const DailySalesDataPointModel({
    required super.fecha,
    required super.diaLabel,
    required super.totalVentasBs,
    required super.totalFacturas,
  });

  factory DailySalesDataPointModel.fromJson(Map<String, dynamic> json) {
    return DailySalesDataPointModel(
      fecha: DateTime.parse(json['fecha'] as String),
      diaLabel: json['dia_label'] as String,
      totalVentasBs: (json['total_ventas_bs'] as num).toDouble(),
      totalFacturas: json['total_facturas'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fecha': fecha.toIso8601String(),
      'dia_label': diaLabel,
      'total_ventas_bs': totalVentasBs,
      'total_facturas': totalFacturas,
    };
  }
}

/// DTO para Comprobante de Venta SIAT
class SiatSalesVoucherModel extends SiatSalesVoucherEntity {
  const SiatSalesVoucherModel({
    required super.numeroFactura,
    required super.cuf,
    required super.fecha,
    required super.nitCliente,
    required super.razonSocial,
    required super.montoTotalBs,
    required super.debitoFiscalIvaBs,
    required super.codigoControl,
    required super.estado,
  });

  factory SiatSalesVoucherModel.fromJson(Map<String, dynamic> json) {
    return SiatSalesVoucherModel(
      numeroFactura: json['numero_factura'] as int,
      cuf: json['cuf'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      nitCliente: json['nit_cliente'] as String,
      razonSocial: json['razon_social'] as String,
      montoTotalBs: (json['monto_total_bs'] as num).toDouble(),
      debitoFiscalIvaBs: (json['debito_fiscal_iva_bs'] as num).toDouble(),
      codigoControl: json['codigo_control'] as String,
      estado: json['estado'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero_factura': numeroFactura,
      'cuf': cuf,
      'fecha': fecha.toIso8601String(),
      'nit_cliente': nitCliente,
      'razon_social': razonSocial,
      'monto_total_bs': montoTotalBs,
      'debito_fiscal_iva_bs': debitoFiscalIvaBs,
      'codigo_control': codigoControl,
      'estado': estado,
    };
  }
}
