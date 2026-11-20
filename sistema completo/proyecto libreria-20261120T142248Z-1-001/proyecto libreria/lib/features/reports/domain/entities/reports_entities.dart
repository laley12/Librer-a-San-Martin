import 'package:flutter/foundation.dart';

/// Estado Semafórico de Criticidad de Inventario
enum StockStatus {
  critico('🔴 CRÍTICO / AGOTADO'),
  reorden('🟡 ATENCIÓN / REORDEN'),
  optimo('🟢 ÓPTIMO / NORMAL');

  final String label;
  const StockStatus(this.label);
}

/// Entidad de Ítem con Criterio de Stock Semafórico
@immutable
class StockSemaforicEntity {
  final String sku;
  final String titulo;
  final String editorial;
  final String categoria;
  final int stockActual;
  final int stockMinimo;
  final double costoUnitarioBs;
  final double precioVentaBs;

  const StockSemaforicEntity({
    required this.sku,
    required this.titulo,
    required this.editorial,
    required this.categoria,
    required this.stockActual,
    required this.stockMinimo,
    required this.costoUnitarioBs,
    required this.precioVentaBs,
  });

  /// Criterio de Criticidad:
  /// - CRÍTICO / AGOTADO: Stock <= Stock Mínimo
  /// - ATENCIÓN / REORDEN: Stock <= Stock Mínimo * 1.5
  /// - ÓPTIMO / NORMAL: Stock > Stock Mínimo * 1.5
  StockStatus get status {
    if (stockActual <= stockMinimo) {
      return StockStatus.critico;
    } else if (stockActual <= (stockMinimo * 1.5).ceil()) {
      return StockStatus.reorden;
    } else {
      return StockStatus.optimo;
    }
  }

  bool get esCritico => status == StockStatus.critico;
  bool get esReorden => status == StockStatus.reorden;
  bool get esOptimo => status == StockStatus.optimo;

  /// Cantidad recomendada para reabastecimiento hasta el nivel de seguridad
  int get cantidadRecomendadaCompra {
    final meta = stockMinimo * 3;
    final deficit = meta - stockActual;
    return deficit > 0 ? deficit : 0;
  }
}

/// Punto de Datos para el Gráfico de Evolución Diaria de Ventas
@immutable
class DailySalesDataPoint {
  final DateTime fecha;
  final String diaLabel; // Lun, Mar, Mié, etc.
  final double totalVentasBs;
  final int totalFacturas;

  const DailySalesDataPoint({
    required this.fecha,
    required this.diaLabel,
    required this.totalVentasBs,
    required this.totalFacturas,
  });
}

/// Comprobante de Venta para el Libro de Ventas Fiscal SIAT (Bolivia)
@immutable
class SiatSalesVoucherEntity {
  final int numeroFactura;
  final String cuf;
  final DateTime fecha;
  final String nitCliente;
  final String razonSocial;
  final double montoTotalBs;
  final double debitoFiscalIvaBs; // 13% IVA
  final String codigoControl;
  final String estado;

  const SiatSalesVoucherEntity({
    required this.numeroFactura,
    required this.cuf,
    required this.fecha,
    required this.nitCliente,
    required this.razonSocial,
    required this.montoTotalBs,
    required this.debitoFiscalIvaBs,
    required this.codigoControl,
    required this.estado,
  });
}

/// Indicadores KPI del Dashboard de Reportes
@immutable
class ReportsKpiEntity {
  final double margenComercialPorcentaje; // Margen Comercial %
  final double ticketPromedioBs;          // Ticket Promedio Bs
  final double indiceRotacion;            // Índice de Rotación (veces / período)
  final double inversionComprasBs;        // Inversión en Compras Bs
  final double totalVentasPeriodoBs;
  final int totalComprobantesEmitidos;

  const ReportsKpiEntity({
    required this.margenComercialPorcentaje,
    required this.ticketPromedioBs,
    required this.indiceRotacion,
    required this.inversionComprasBs,
    required this.totalVentasPeriodoBs,
    required this.totalComprobantesEmitidos,
  });
}
