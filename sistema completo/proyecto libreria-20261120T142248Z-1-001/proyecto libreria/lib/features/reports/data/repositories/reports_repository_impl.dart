import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_data_source.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<ReportsKpiEntity>> getReportsKpis({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final kpi = await remoteDataSource.getReportsKpis(
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success(kpi);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al obtener KPIs analíticos: $e'));
    }
  }

  @override
  Future<Result<List<DailySalesDataPoint>>> getDailySalesEvolution({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final list = await remoteDataSource.getDailySalesEvolution(
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al obtener evolución de ventas: $e'));
    }
  }

  @override
  Future<Result<List<SiatSalesVoucherEntity>>> getSiatSalesVouchers({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final vouchers = await remoteDataSource.getSiatSalesVouchers(
        startDate: startDate,
        endDate: endDate,
      );
      return Result.success(vouchers);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al obtener comprobantes SIAT: $e'));
    }
  }

  @override
  Future<Result<List<StockSemaforicEntity>>> getStockSemaforico() async {
    try {
      final items = await remoteDataSource.getStockSemaforico();
      return Result.success(items);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al obtener stock semafórico: $e'));
    }
  }
}
