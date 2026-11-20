import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/admin_entities.dart';
import '../repositories/administration_repository.dart';

/// Caso de Uso: Obtener KPIs de Administración y distribución de existencias.
class GetAdminKpisUseCase implements UseCase<AdminKpiEntity, NoParams> {
  final AdministrationRepository _repository;
  GetAdminKpisUseCase(this._repository);

  @override
  Future<Result<AdminKpiEntity>> call(NoParams params) {
    return _repository.getAdminKpis();
  }
}

/// Caso de Uso: Obtener sucursales.
class GetBranchesUseCase implements UseCase<List<BranchEntity>, NoParams> {
  final AdministrationRepository _repository;
  GetBranchesUseCase(this._repository);

  @override
  Future<Result<List<BranchEntity>>> call(NoParams params) {
    return _repository.getBranches();
  }
}

/// Caso de Uso: Actualizar sucursal.
class UpdateBranchUseCase implements UseCase<BranchEntity, BranchEntity> {
  final AdministrationRepository _repository;
  UpdateBranchUseCase(this._repository);

  @override
  Future<Result<BranchEntity>> call(BranchEntity branch) {
    return _repository.updateBranch(branch);
  }
}

/// Parámetros para registrar una nueva sucursal.
class CreateBranchParams {
  final String nombre;
  final String direccion;
  final String ciudad;
  final String encargado;
  final int cajasPosAsignadas;
  final double aforoM2;
  final List<String> bodegasVinculadas;

  const CreateBranchParams({
    required this.nombre,
    required this.direccion,
    required this.ciudad,
    required this.encargado,
    required this.cajasPosAsignadas,
    required this.aforoM2,
    required this.bodegasVinculadas,
  });
}

/// Caso de Uso: Crear nueva sucursal con validaciones.
class CreateBranchUseCase implements UseCase<BranchEntity, CreateBranchParams> {
  final AdministrationRepository _repository;
  CreateBranchUseCase(this._repository);

  @override
  Future<Result<BranchEntity>> call(CreateBranchParams params) async {
    if (params.nombre.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'El nombre de la sucursal es obligatorio.'));
    }
    if (params.direccion.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'La dirección física es obligatoria.'));
    }
    if (params.ciudad.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'La ciudad o localidad es obligatoria.'));
    }
    if (params.encargado.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'El nombre del encargado es obligatorio.'));
    }
    if (params.cajasPosAsignadas < 1) {
      return Result.failure(const ValidationFailure(message: 'Debe asignar al menos 1 terminal de caja POS.'));
    }
    if (params.aforoM2 <= 0) {
      return Result.failure(const ValidationFailure(message: 'El aforo total en m² debe ser mayor a 0.'));
    }

    final newBranch = BranchEntity(
      id: 'br_${DateTime.now().millisecondsSinceEpoch}',
      nombre: params.nombre.trim(),
      direccion: params.direccion.trim(),
      ciudad: params.ciudad.trim(),
      encargado: params.encargado.trim(),
      cajasPosAsignadas: params.cajasPosAsignadas,
      aforoM2: params.aforoM2,
      ocupacionPorcentaje: 0.15,
      bodegasVinculadas: params.bodegasVinculadas.isNotEmpty
          ? params.bodegasVinculadas
          : ['Bodega General'],
      activa: true,
      cuentasPendientes: 0.0,
      activosAsignados: 0,
    );

    return _repository.createBranch(newBranch);
  }
}

/// Parámetros para procesar la baja de una sucursal.
class DeactivateBranchParams {
  final String branchId;
  final String motivo;

  const DeactivateBranchParams({
    required this.branchId,
    required this.motivo,
  });
}

/// Caso de Uso: Dar de baja sucursal con control estricto de restricciones.
/// REGLA DE NEGOCIO: No se puede dar de baja una sucursal si tiene cuentas pendientes (> 0) o activos asignados (> 0).
class DeactivateBranchUseCase implements UseCase<BranchEntity, DeactivateBranchParams> {
  final AdministrationRepository _repository;
  DeactivateBranchUseCase(this._repository);

  @override
  Future<Result<BranchEntity>> call(DeactivateBranchParams params) async {
    if (params.motivo.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'Debe especificar un motivo formal para la baja de la sucursal.'));
    }

    // 1. Obtener la sucursal actual para auditar sus cuentas y activos
    final branchesResult = await _repository.getBranches();
    final branches = branchesResult.fold(
      onSuccess: (list) => list,
      onFailure: (_) => <BranchEntity>[],
    );

    final targetBranch = branches.where((b) => b.id == params.branchId).firstOrNull;
    if (targetBranch == null) {
      return Result.failure(const ServerFailure(message: 'La sucursal especificada no existe en el sistema.'));
    }

    // 2. Control de Restricción 1: Cuentas pendientes
    if (targetBranch.tieneCuentasPendientes) {
      return Result.failure(ValidationFailure(
        message: 'RESTRICCIÓN CONTABLE: La sucursal "${targetBranch.nombre}" tiene Bs ${targetBranch.cuentasPendientes.toStringAsFixed(2)} en cuentas pendientes por conciliar. '
            'Por directriz de auditoría, no se permite dar de baja una sucursal con pasivos o cobranzas en curso.',
      ));
    }

    // 3. Control de Restricción 2: Activos asignados
    if (targetBranch.tieneActivosAsignados) {
      return Result.failure(ValidationFailure(
        message: 'RESTRICCIÓN DE ACTIVOS: La sucursal "${targetBranch.nombre}" tiene ${targetBranch.activosAsignados} activos/ítems de inventario asignados a sus bodegas. '
            'Debe reubicar o transferir la totalidad de los activos antes de proceder con el cierre definitivo.',
      ));
    }

    // 4. Ejecutar la baja si se cumplen las condiciones
    return _repository.deactivateBranch(
      branchId: params.branchId,
      motivo: params.motivo.trim(),
    );
  }
}

/// Caso de Uso: Reactivar una sucursal dada de baja.
class ReactivateBranchUseCase implements UseCase<BranchEntity, String> {
  final AdministrationRepository _repository;
  ReactivateBranchUseCase(this._repository);

  @override
  Future<Result<BranchEntity>> call(String branchId) {
    return _repository.reactivateBranch(branchId);
  }
}

/// Parámetros para consulta de SKUs.
class GetSkusParams {
  final String? queryOrBarcode;
  final String? editorial;
  final String? categoria;

  const GetSkusParams({this.queryOrBarcode, this.editorial, this.categoria});
}

/// Caso de Uso: Listar SKUs con filtros y lector de código de barras USB.
class GetSkusUseCase implements UseCase<List<SkuEntity>, GetSkusParams> {
  final AdministrationRepository _repository;
  GetSkusUseCase(this._repository);

  @override
  Future<Result<List<SkuEntity>>> call(GetSkusParams params) {
    return _repository.getSkus(
      queryOrBarcode: params.queryOrBarcode,
      editorial: params.editorial,
      categoria: params.categoria,
    );
  }
}

/// Parámetros para registrar un nuevo SKU con validación de márgenes.
class CreateSkuParams {
  final String ean13;
  final String titulo;
  final String editorial;
  final String categoria;
  final double costoBs;
  final double margenPorcentaje;
  final int stockInicial;

  const CreateSkuParams({
    required this.ean13,
    required this.titulo,
    required this.editorial,
    required this.categoria,
    required this.costoBs,
    required this.margenPorcentaje,
    required this.stockInicial,
  });
}

/// Caso de Uso: Registrar producto / SKU maestro.
class CreateSkuUseCase implements UseCase<SkuEntity, CreateSkuParams> {
  final AdministrationRepository _repository;
  CreateSkuUseCase(this._repository);

  @override
  Future<Result<SkuEntity>> call(CreateSkuParams params) async {
    // 1. Validación de código EAN-13 o SKU
    if (params.ean13.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure(message: 'El código de barras / EAN-13 es obligatorio.'),
      );
    }

    // 2. Validación de título
    if (params.titulo.trim().length < 3) {
      return Result.failure(
        const ValidationFailure(message: 'El título debe tener al menos 3 caracteres.'),
      );
    }

    // 3. Validación de costos y margen
    if (params.costoBs <= 0) {
      return Result.failure(
        const ValidationFailure(message: 'El costo en Bolivianos debe ser mayor a 0.'),
      );
    }

    if (params.margenPorcentaje <= 0 || params.margenPorcentaje >= 100) {
      return Result.failure(
        const ValidationFailure(message: 'El margen comercial debe estar entre 1% y 99%.'),
      );
    }

    return await _repository.createSku(
      ean13: params.ean13.trim(),
      titulo: params.titulo.trim(),
      editorial: params.editorial,
      categoria: params.categoria,
      costoBs: params.costoBs,
      margenPorcentaje: params.margenPorcentaje,
      stockInicial: params.stockInicial,
    );
  }
}

/// Caso de Uso: Obtener configuración tributaria SIAT.
class GetFiscalConfigUseCase implements UseCase<FiscalConfigEntity, NoParams> {
  final AdministrationRepository _repository;
  GetFiscalConfigUseCase(this._repository);

  @override
  Future<Result<FiscalConfigEntity>> call(NoParams params) {
    return _repository.getFiscalConfig();
  }
}

/// Caso de Uso: Actualizar parametrización fiscal SIAT.
class UpdateFiscalConfigUseCase implements UseCase<FiscalConfigEntity, FiscalConfigEntity> {
  final AdministrationRepository _repository;
  UpdateFiscalConfigUseCase(this._repository);

  @override
  Future<Result<FiscalConfigEntity>> call(FiscalConfigEntity config) {
    if (config.nit.trim().isEmpty || config.cufdActual.trim().isEmpty) {
      return Future.value(
        Result.failure(const ValidationFailure(message: 'NIT y CUFD son datos obligatorios.')),
      );
    }
    return _repository.updateFiscalConfig(config);
  }
}

/// Caso de Uso: Probar conexión con WebService del SIN.
class TestSiatConnectionUseCase implements UseCase<bool, NoParams> {
  final AdministrationRepository _repository;
  TestSiatConnectionUseCase(this._repository);

  @override
  Future<Result<bool>> call(NoParams params) {
    return _repository.testSiatConnection();
  }
}
