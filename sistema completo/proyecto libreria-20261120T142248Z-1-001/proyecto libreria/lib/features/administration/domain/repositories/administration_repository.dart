import '../../../../core/errors/result.dart';
import '../entities/admin_entities.dart';

/// Contrato de repositorio para el Módulo de Administración y Parametrización.
abstract interface class AdministrationRepository {
  /// Obtiene los KPIs de administración y la distribución de existencias.
  Future<Result<AdminKpiEntity>> getAdminKpis();

  /// Obtiene la lista de sucursales activas o dadas de baja.
  Future<Result<List<BranchEntity>>> getBranches();

  /// Registra una nueva sucursal en el sistema.
  Future<Result<BranchEntity>> createBranch(BranchEntity branch);

  /// Actualiza los datos de una sucursal (encargado, bodegas, aforo).
  Future<Result<BranchEntity>> updateBranch(BranchEntity branch);

  /// Procesa la baja de una sucursal con validación de cuentas y activos.
  Future<Result<BranchEntity>> deactivateBranch({
    required String branchId,
    required String motivo,
  });

  /// Reactiva una sucursal previamente dada de baja.
  Future<Result<BranchEntity>> reactivateBranch(String branchId);

  /// Obtiene el catálogo de SKUs con filtros opcionales.
  Future<Result<List<SkuEntity>>> getSkus({
    String? queryOrBarcode,
    String? editorial,
    String? categoria,
  });

  /// Registra un nuevo producto/SKU en el catálogo maestro.
  Future<Result<SkuEntity>> createSku({
    required String ean13,
    required String titulo,
    required String editorial,
    required String categoria,
    required double costoBs,
    required double margenPorcentaje,
    required int stockInicial,
  });

  /// Obtiene la configuración tributaria activa del SIAT.
  Future<Result<FiscalConfigEntity>> getFiscalConfig();

  /// Actualiza los parámetros fiscales.
  Future<Result<FiscalConfigEntity>> updateFiscalConfig(FiscalConfigEntity config);

  /// Valida la conexión WebService con el SIN (Servicio de Impuestos Nacionales).
  Future<Result<bool>> testSiatConnection();
}
