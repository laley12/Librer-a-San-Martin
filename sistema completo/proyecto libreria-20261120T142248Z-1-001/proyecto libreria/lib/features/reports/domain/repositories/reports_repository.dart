import '../../../../core/errors/result.dart';
import '../entities/reports_entities.dart';

/// Contrato abstracto del repositorio de Reportes y Analítica
abstract class ReportsRepository {
  /// Obtiene los indicadores KPI para el período seleccionado
  Future<Result<ReportsKpiEntity>> getReportsKpis({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtiene la serie temporal de evolución diaria de ventas para fl_chart
  Future<Result<List<DailySalesDataPoint>>> getDailySalesEvolution({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtiene la lista de comprobantes para el Libro de Ventas SIAT
  Future<Result<List<SiatSalesVoucherEntity>>> getSiatSalesVouchers({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Obtiene la auditoría de inventario con criterio semafórico
  Future<Result<List<StockSemaforicEntity>>> getStockSemaforico();
}
