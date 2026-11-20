import 'package:flutter/foundation.dart';

/// Métodos de Pago disponibles en el POS
enum PaymentMethod {
  efectivo('Efectivo'),
  qrSimple('QR Simple'),
  tarjeta('Tarjeta Débito/Crédito');

  final String label;
  const PaymentMethod(this.label);
}

/// Producto disponible para venta rápida en el POS
@immutable
class PosProductEntity {
  final String sku;
  final String titulo;
  final String editorial;
  final String categoria;
  final double precioVenta;
  final int stockDisponible;
  final String codigoBarra;
  final String? imagenUrl;

  const PosProductEntity({
    required this.sku,
    required this.titulo,
    required this.editorial,
    required this.categoria,
    required this.precioVenta,
    required this.stockDisponible,
    required this.codigoBarra,
    this.imagenUrl,
  });

  bool get estaAgotado => stockDisponible <= 0;
  bool get stockCritico => stockDisponible > 0 && stockDisponible <= 5;

  PosProductEntity copyWith({
    String? sku,
    String? titulo,
    String? editorial,
    String? categoria,
    double? precioVenta,
    int? stockDisponible,
    String? codigoBarra,
    String? imagenUrl,
  }) {
    return PosProductEntity(
      sku: sku ?? this.sku,
      titulo: titulo ?? this.titulo,
      editorial: editorial ?? this.editorial,
      categoria: categoria ?? this.categoria,
      precioVenta: precioVenta ?? this.precioVenta,
      stockDisponible: stockDisponible ?? this.stockDisponible,
      codigoBarra: codigoBarra ?? this.codigoBarra,
      imagenUrl: imagenUrl ?? this.imagenUrl,
    );
  }
}

/// Ítem agregado al carrito POS
@immutable
class PosCartItemEntity {
  final PosProductEntity product;
  final int cantidad;

  const PosCartItemEntity({
    required this.product,
    required this.cantidad,
  });

  double get subtotal => product.precioVenta * cantidad;

  PosCartItemEntity copyWith({
    PosProductEntity? product,
    int? cantidad,
  }) {
    return PosCartItemEntity(
      product: product ?? this.product,
      cantidad: cantidad ?? this.cantidad,
    );
  }
}

/// Datos del Cliente para Facturación SIAT
@immutable
class CustomerEntity {
  final String nitCi;
  final String razonSocial;
  final String? email;
  final String? telefono;

  const CustomerEntity({
    required this.nitCi,
    required this.razonSocial,
    this.email,
    this.telefono,
  });

  CustomerEntity copyWith({
    String? nitCi,
    String? razonSocial,
    String? email,
    String? telefono,
  }) {
    return CustomerEntity(
      nitCi: nitCi ?? this.nitCi,
      razonSocial: razonSocial ?? this.razonSocial,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
    );
  }
}

/// Factura Electrónica emitido por el POS (SIAT Bolivia)
@immutable
class InvoiceSaleEntity {
  final String id;
  final String cuf;
  final int numeroFactura;
  final DateTime fecha;
  final CustomerEntity cliente;
  final List<PosCartItemEntity> items;
  final double total;
  final PaymentMethod metodoPago;
  final double montoRecibido;
  final double cambio;
  final String sucursal;
  final String estadoSiat;

  const InvoiceSaleEntity({
    required this.id,
    required this.cuf,
    required this.numeroFactura,
    required this.fecha,
    required this.cliente,
    required this.items,
    required this.total,
    required this.metodoPago,
    required this.montoRecibido,
    required this.cambio,
    required this.sucursal,
    required this.estadoSiat,
  });
}

/// Tipo de Movimiento en Kárdex
enum KardexEntryType {
  saldoInicial('SALDO INICIAL'),
  compraCif('COMPRA / ENTRADA CIF'),
  ventaPos('VENTA POS (PEPS)'),
  ajusteInventario('AJUSTE INVENTARIO');

  final String label;
  const KardexEntryType(this.label);
}

/// Fila del Kárdex Físico-Valorado bajo Método PEPS (FIFO)
@immutable
class KardexEntryEntity {
  final String id;
  final String sku;
  final DateTime fecha;
  final String comprobante;
  final String detalle;
  final KardexEntryType tipo;

  // 1. ENTRADAS
  final int cantidadEntrada;
  final double costoUnitarioEntrada;
  final double totalEntrada;

  // 2. SALIDAS (Valoradas al lote más antiguo disponible - PEPS)
  final int cantidadSalida;
  final double costoUnitarioPepsSalida;
  final double totalSalida;

  // 3. SALDOS
  final int saldoCantidad;
  final double costoPromedioSaldo;
  final double saldoValorTotal;

  const KardexEntryEntity({
    required this.id,
    required this.sku,
    required this.fecha,
    required this.comprobante,
    required this.detalle,
    required this.tipo,
    required this.cantidadEntrada,
    required this.costoUnitarioEntrada,
    required this.totalEntrada,
    required this.cantidadSalida,
    required this.costoUnitarioPepsSalida,
    required this.totalSalida,
    required this.saldoCantidad,
    required this.costoPromedioSaldo,
    required this.saldoValorTotal,
  });
}

/// Orden de Compra Internacional con Costeo CIF y Nacionalización
@immutable
class CifOrderEntity {
  final String id;
  final String codigoOrden;
  final String proveedor;
  final String sku;
  final String skuTitulo;
  final int cantidadUnidades;

  // Componentes de Costeo Aduanero
  final double fobTotalUsd;
  final double fleteUsd;
  final double seguroUsd;
  final double tipoCambioBob; // Ej. 6.96 Bs/USD
  final double gaPorcentaje;  // Gravamen Arancelario: 10% (0.10)
  final double gastosDespachoBob; // Desaduanización, almacén aduanero y comisiones
  final DateTime fechaRegistro;
  final String estado;

  const CifOrderEntity({
    required this.id,
    required this.codigoOrden,
    required this.proveedor,
    required this.sku,
    required this.skuTitulo,
    required this.cantidadUnidades,
    required this.fobTotalUsd,
    required this.fleteUsd,
    required this.seguroUsd,
    this.tipoCambioBob = 6.96,
    this.gaPorcentaje = 0.10,
    required this.gastosDespachoBob,
    required this.fechaRegistro,
    this.estado = 'Nacionalizado en Bodega',
  });

  /// CIF USD = FOB + Flete + Seguro
  double get valorCifUsd => fobTotalUsd + fleteUsd + seguroUsd;

  /// CIF BOB = CIF USD * Tipo de Cambio
  double get valorCifBob => valorCifUsd * tipoCambioBob;

  /// Gravamen Arancelario (GA 10%) en BOB
  double get gravamenArancelarioBob => valorCifBob * gaPorcentaje;

  /// Costo Total Nacionalizado BOB = CIF BOB + GA BOB + Gastos Desaduanización
  double get costoTotalNacionalizadoBob =>
      valorCifBob + gravamenArancelarioBob + gastosDespachoBob;

  /// Costo Unitario Nacionalizado BOB (que alimenta Kárdex PEPS)
  double get costoUnitarioNacionalizadoBob =>
      cantidadUnidades > 0 ? costoTotalNacionalizadoBob / cantidadUnidades : 0.0;
}

/// Proveedor y Editorial
@immutable
class SupplierEntity {
  final String id;
  final String nit;
  final String razonSocial;
  final String contacto;
  final String telefono;
  final String email;
  final String pais;
  final List<String> categorias;
  final int plazoCreditoDias; // 0 = Contado, 30, 60, 90 días
  final String estado;

  const SupplierEntity({
    required this.id,
    required this.nit,
    required this.razonSocial,
    required this.contacto,
    required this.telefono,
    required this.email,
    required this.pais,
    required this.categorias,
    required this.plazoCreditoDias,
    this.estado = 'Activo',
  });
}

/// Métricas KPI para el Dashboard de Compra y Venta
@immutable
class SalesPurchasesKpiEntity {
  final double ventasHoyBs;
  final int facturasEmitidasHoy;
  final double comprasCifMesBs;
  final int skusBajoStock;
  final double margenPromedioPeps;

  const SalesPurchasesKpiEntity({
    required this.ventasHoyBs,
    required this.facturasEmitidasHoy,
    required this.comprasCifMesBs,
    required this.skusBajoStock,
    required this.margenPromedioPeps,
  });
}
