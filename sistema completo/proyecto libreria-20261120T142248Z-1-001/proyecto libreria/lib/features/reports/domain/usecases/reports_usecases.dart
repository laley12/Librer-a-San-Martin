import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reports_entities.dart';
import '../events/reports_events.dart';
import '../repositories/reports_repository.dart';

/// Parámetros de rango de fechas para filtrado analítico
class DateRangeParams {
  final DateTime startDate;
  final DateTime endDate;

  const DateRangeParams({
    required this.startDate,
    required this.endDate,
  });
}

/// Caso de Uso: Obtener KPIs del Período
class GetReportsKpisUseCase implements UseCase<ReportsKpiEntity, DateRangeParams> {
  final ReportsRepository repository;
  GetReportsKpisUseCase(this.repository);

  @override
  Future<Result<ReportsKpiEntity>> call(DateRangeParams params) {
    if (params.startDate.isAfter(params.endDate)) {
      return Future.value(
        Result.failure(
          const ValidationFailure(message: 'La fecha inicial no puede ser posterior a la fecha final.'),
        ),
      );
    }
    return repository.getReportsKpis(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Caso de Uso: Evolución diaria de ingresos para fl_chart
class GetDailySalesEvolutionUseCase
    implements UseCase<List<DailySalesDataPoint>, DateRangeParams> {
  final ReportsRepository repository;
  GetDailySalesEvolutionUseCase(this.repository);

  @override
  Future<Result<List<DailySalesDataPoint>>> call(DateRangeParams params) {
    return repository.getDailySalesEvolution(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Caso de Uso: Comprobantes para Libro de Ventas SIAT
class GetSiatSalesVouchersUseCase
    implements UseCase<List<SiatSalesVoucherEntity>, DateRangeParams> {
  final ReportsRepository repository;
  GetSiatSalesVouchersUseCase(this.repository);

  @override
  Future<Result<List<SiatSalesVoucherEntity>>> call(DateRangeParams params) {
    return repository.getSiatSalesVouchers(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

/// Caso de Uso: Listado de Stock con Criterio Semafórico
class GetStockSemaforicoUseCase implements UseCase<List<StockSemaforicEntity>, NoParams> {
  final ReportsRepository repository;
  GetStockSemaforicoUseCase(this.repository);

  @override
  Future<Result<List<StockSemaforicEntity>>> call(NoParams params) {
    return repository.getStockSemaforico();
  }
}

/// Caso de Uso: Solicitar Reposición de Almacén (Generar Orden de Compra desde Semáforo)
class RequestStockReplenishmentUseCase implements UseCase<bool, StockSemaforicEntity> {
  final AppEventBus eventBus;
  RequestStockReplenishmentUseCase(this.eventBus);

  @override
  Future<Result<bool>> call(StockSemaforicEntity item) async {
    eventBus.emit(
      StockReplenishmentRequestedEvent(
        sku: item.sku,
        titulo: item.titulo,
        editorial: item.editorial,
        stockActual: item.stockActual,
        cantidadSugerida: item.cantidadRecomendadaCompra,
      ),
    );
    return Result.success(true);
  }
}

/// Parámetros para exportar reporte
class ExportReportParams {
  final String tipoReporte;
  final String formato;
  final int totalRegistros;

  const ExportReportParams({
    required this.tipoReporte,
    required this.formato,
    required this.totalRegistros,
  });
}

/// Caso de Uso: Registrar exportación de reporte
class ExportReportUseCase implements UseCase<bool, ExportReportParams> {
  final AppEventBus eventBus;
  ExportReportUseCase(this.eventBus);

  @override
  Future<Result<bool>> call(ExportReportParams params) async {
    eventBus.emit(
      ReportExportedEvent(
        tipoReporte: params.tipoReporte,
        formato: params.formato,
        totalRegistros: params.totalRegistros,
      ),
    );
    return Result.success(true);
  }
}
