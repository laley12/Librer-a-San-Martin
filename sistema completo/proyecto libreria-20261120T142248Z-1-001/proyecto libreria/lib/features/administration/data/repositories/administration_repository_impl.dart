import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/repositories/administration_repository.dart';
import '../datasources/administration_remote_data_source.dart';

class AdministrationRepositoryImpl implements AdministrationRepository {
  final AdministrationRemoteDataSource remoteDataSource;

  AdministrationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<AdminKpiEntity>> getAdminKpis() async {
    try {
      final kpis = await remoteDataSource.getAdminKpis();
      return Result.success(kpis);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al consultar KPIs de administración: $e'));
    }
  }

  @override
  Future<Result<List<BranchEntity>>> getBranches() async {
    try {
      final branches = await remoteDataSource.getBranches();
      return Result.success(branches);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al listar sucursales: $e'));
    }
  }

  @override
  Future<Result<BranchEntity>> createBranch(BranchEntity branch) async {
    try {
      final created = await remoteDataSource.createBranch(branch);
      return Result.success(created);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al crear sucursal: $e'));
    }
  }

  @override
  Future<Result<BranchEntity>> updateBranch(BranchEntity branch) async {
    try {
      final updated = await remoteDataSource.updateBranch(branch);
      return Result.success(updated);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al actualizar sucursal: $e'));
    }
  }

  @override
  Future<Result<BranchEntity>> deactivateBranch({
    required String branchId,
    required String motivo,
  }) async {
    try {
      final deactivated = await remoteDataSource.deactivateBranch(branchId, motivo);
      return Result.success(deactivated);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al dar de baja la sucursal: $e'));
    }
  }

  @override
  Future<Result<BranchEntity>> reactivateBranch(String branchId) async {
    try {
      final reactivated = await remoteDataSource.reactivateBranch(branchId);
      return Result.success(reactivated);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al reactivar la sucursal: $e'));
    }
  }

  @override
  Future<Result<List<SkuEntity>>> getSkus({
    String? queryOrBarcode,
    String? editorial,
    String? categoria,
  }) async {
    try {
      final skus = await remoteDataSource.getSkus(
        queryOrBarcode: queryOrBarcode,
        editorial: editorial,
        categoria: categoria,
      );
      return Result.success(skus);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al consultar catálogo SKU: $e'));
    }
  }

  @override
  Future<Result<SkuEntity>> createSku({
    required String ean13,
    required String titulo,
    required String editorial,
    required String categoria,
    required double costoBs,
    required double margenPorcentaje,
    required int stockInicial,
  }) async {
    try {
      final sku = await remoteDataSource.createSku(
        ean13: ean13,
        titulo: titulo,
        editorial: editorial,
        categoria: categoria,
        costoBs: costoBs,
        margenPorcentaje: margenPorcentaje,
        stockInicial: stockInicial,
      );
      return Result.success(sku);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al registrar SKU: $e'));
    }
  }

  @override
  Future<Result<FiscalConfigEntity>> getFiscalConfig() async {
    try {
      final config = await remoteDataSource.getFiscalConfig();
      return Result.success(config);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al obtener parametrización SIAT: $e'));
    }
  }

  @override
  Future<Result<FiscalConfigEntity>> updateFiscalConfig(FiscalConfigEntity config) async {
    try {
      final updated = await remoteDataSource.updateFiscalConfig(config);
      return Result.success(updated);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al actualizar configuración fiscal: $e'));
    }
  }

  @override
  Future<Result<bool>> testSiatConnection() async {
    try {
      final connected = await remoteDataSource.testSiatConnection();
      return Result.success(connected);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Fallo al conectar con el SIAT de Impuestos: $e'));
    }
  }
}
