import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/sales_purchases_entities.dart';
import '../../domain/repositories/sales_purchases_repository.dart';
import '../datasources/sales_purchases_remote_data_source.dart';

class SalesPurchasesRepositoryImpl implements SalesPurchasesRepository {
  final SalesPurchasesRemoteDataSource remoteDataSource;

  SalesPurchasesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Result<List<PosProductEntity>>> getPosProducts() async {
    try {
      final list = await remoteDataSource.getPosProducts();
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al cargar productos POS: $e'));
    }
  }

  @override
  Future<Result<List<PosProductEntity>>> searchProduct(String query) async {
    try {
      final list = await remoteDataSource.searchProduct(query);
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al buscar productos: $e'));
    }
  }

  @override
  Future<Result<CustomerEntity?>> searchCustomerByNit(String nitCi) async {
    try {
      final customer = await remoteDataSource.searchCustomerByNit(nitCi);
      return Result.success(customer);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al buscar cliente por NIT/CI: $e'));
    }
  }

  @override
  Future<Result<InvoiceSaleEntity>> emitirFacturaPos(InvoiceSaleEntity invoice) async {
    try {
      final saved = await remoteDataSource.emitirFacturaPos(invoice);
      return Result.success(saved);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al emitir factura POS: $e'));
    }
  }

  @override
  Future<Result<List<KardexEntryEntity>>> getKardexBySku(String sku) async {
    try {
      final list = await remoteDataSource.getKardexBySku(sku);
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al cargar kárdex para $sku: $e'));
    }
  }

  @override
  Future<Result<List<CifOrderEntity>>> getCifOrders() async {
    try {
      final list = await remoteDataSource.getCifOrders();
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al listar órdenes CIF: $e'));
    }
  }

  @override
  Future<Result<CifOrderEntity>> registrarOrdenCif(CifOrderEntity order) async {
    try {
      final saved = await remoteDataSource.registrarOrdenCif(order);
      return Result.success(saved);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al registrar orden CIF: $e'));
    }
  }

  @override
  Future<Result<List<SupplierEntity>>> getSuppliers() async {
    try {
      final list = await remoteDataSource.getSuppliers();
      return Result.success(list);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al cargar proveedores: $e'));
    }
  }

  @override
  Future<Result<SalesPurchasesKpiEntity>> getKpis() async {
    try {
      final kpi = await remoteDataSource.getKpis();
      return Result.success(kpi);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(ServerFailure(message: 'Error al obtener KPIs: $e'));
    }
  }
}
