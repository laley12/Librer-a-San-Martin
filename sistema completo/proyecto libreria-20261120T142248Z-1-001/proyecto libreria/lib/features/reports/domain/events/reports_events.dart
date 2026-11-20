import 'package:flutter/foundation.dart';
import '../../../../core/events/domain_event.dart';

/// Evento emitido cuando se solicita reposición inmediata de almacén para un ítem crítico
@immutable
class StockReplenishmentRequestedEvent extends DomainEvent {
  final String sku;
  final String titulo;
  final String editorial;
  final int stockActual;
  final int cantidadSugerida;

  StockReplenishmentRequestedEvent({
    required this.sku,
    required this.titulo,
    required this.editorial,
    required this.stockActual,
    required this.cantidadSugerida,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'reports.stock_replenishment_requested');

  @override
  String toString() =>
      'StockReplenishmentRequestedEvent(SKU: $sku, Título: "$titulo", Cantidad Sugerida: $cantidadSugerida un.)';
}

/// Evento emitido al exportar un reporte tributario o analítico
@immutable
class ReportExportedEvent extends DomainEvent {
  final String tipoReporte; // 'Libro de Ventas SIAT', 'Stock Semafórico', etc.
  final String formato;     // 'CSV', 'Excel', 'PDF'
  final int totalRegistros;

  ReportExportedEvent({
    required this.tipoReporte,
    required this.formato,
    required this.totalRegistros,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'reports.report_exported');

  @override
  String toString() =>
      'ReportExportedEvent(Tipo: $tipoReporte, Formato: $formato, Registros: $totalRegistros)';
}
