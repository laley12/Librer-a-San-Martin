import 'package:flutter/foundation.dart';
import '../../../../core/events/domain_event.dart';

/// Evento emitido al facturar exitosamente en POS (F10)
@immutable
class SaleInvoicedEvent extends DomainEvent {
  final String invoiceId;
  final int numeroFactura;
  final String cuf;
  final double total;
  final String nitCi;
  final String razonSocial;
  final int totalItems;
  final String sucursal;

  SaleInvoicedEvent({
    required this.invoiceId,
    required this.numeroFactura,
    required this.cuf,
    required this.total,
    required this.nitCi,
    required this.razonSocial,
    required this.totalItems,
    required this.sucursal,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'sales.sale_invoiced');

  @override
  String toString() =>
      'SaleInvoicedEvent(Fac: $numeroFactura, Total: Bs $total, Cliente: $razonSocial, Sucursal: $sucursal)';
}

/// Evento emitido al registrar una Orden de Compra Internacional CIF
@immutable
class CifOrderRegisteredEvent extends DomainEvent {
  final String orderId;
  final String codigoOrden;
  final String sku;
  final int cantidad;
  final double costoUnitarioNacionalizadoBob;
  final double costoTotalNacionalizadoBob;

  CifOrderRegisteredEvent({
    required this.orderId,
    required this.codigoOrden,
    required this.sku,
    required this.cantidad,
    required this.costoUnitarioNacionalizadoBob,
    required this.costoTotalNacionalizadoBob,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'purchases.cif_order_registered');

  @override
  String toString() =>
      'CifOrderRegisteredEvent($codigoOrden, SKU: $sku, Cant: $cantidad, CU Nac: Bs $costoUnitarioNacionalizadoBob)';
}

/// Evento emitido cuando un producto se agota o cae por debajo del umbral mínimo
@immutable
class StockAlertLowEvent extends DomainEvent {
  final String sku;
  final String titulo;
  final int stockRestante;

  StockAlertLowEvent({
    required this.sku,
    required this.titulo,
    required this.stockRestante,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'inventory.stock_alert_low');

  @override
  String toString() =>
      'StockAlertLowEvent(SKU: $sku, Título: "$titulo", Stock Restante: $stockRestante)';
}
