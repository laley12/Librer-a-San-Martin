import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/admin_entities.dart';
import '../../domain/events/admin_events.dart';
import '../../domain/usecases/admin_usecases.dart';

class AdministrationController extends ChangeNotifier {
  final GetAdminKpisUseCase getAdminKpisUseCase;
  final GetBranchesUseCase getBranchesUseCase;
  final CreateBranchUseCase createBranchUseCase;
  final UpdateBranchUseCase updateBranchUseCase;
  final DeactivateBranchUseCase deactivateBranchUseCase;
  final ReactivateBranchUseCase reactivateBranchUseCase;
  final GetSkusUseCase getSkusUseCase;
  final CreateSkuUseCase createSkuUseCase;
  final GetFiscalConfigUseCase getFiscalConfigUseCase;
  final UpdateFiscalConfigUseCase updateFiscalConfigUseCase;
  final TestSiatConnectionUseCase testSiatConnectionUseCase;
  final AppEventBus eventBus;

  AdministrationController({
    required this.getAdminKpisUseCase,
    required this.getBranchesUseCase,
    required this.createBranchUseCase,
    required this.updateBranchUseCase,
    required this.deactivateBranchUseCase,
    required this.reactivateBranchUseCase,
    required this.getSkusUseCase,
    required this.createSkuUseCase,
    required this.getFiscalConfigUseCase,
    required this.updateFiscalConfigUseCase,
    required this.testSiatConnectionUseCase,
    required this.eventBus,
  });

  // Datos
  AdminKpiEntity? _kpis;
  List<BranchEntity> _branches = [];
  List<SkuEntity> _skus = [];
  FiscalConfigEntity? _fiscalConfig;

  // Filtros de SKU
  String _skuQuery = '';
  String _skuEditorial = 'Todas';
  String _skuCategoria = 'Todas';

  // Estados de carga y feedback
  bool _isLoading = false;
  bool _isTestingSiat = false;
  Failure? _failure;
  String? _successMessage;

  // Getters
  AdminKpiEntity? get kpis => _kpis;
  List<BranchEntity> get branches => _branches;
  List<SkuEntity> get skus => _skus;
  FiscalConfigEntity? get fiscalConfig => _fiscalConfig;

  String get skuQuery => _skuQuery;
  String get skuEditorial => _skuEditorial;
  String get skuCategoria => _skuCategoria;

  bool get isLoading => _isLoading;
  bool get isTestingSiat => _isTestingSiat;
  Failure? get failure => _failure;
  String? get successMessage => _successMessage;

  // ===========================================================================
  // CARGA INICIAL
  // ===========================================================================
  Future<void> loadAll() async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    await Future.wait([
      loadKpis(),
      loadBranches(),
      loadSkus(),
      loadFiscalConfig(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadKpis() async {
    final result = await getAdminKpisUseCase(const NoParams());
    result.fold(
      onSuccess: (data) => _kpis = data,
      onFailure: (f) => _failure = f,
    );
  }

  Future<void> loadBranches() async {
    final result = await getBranchesUseCase(const NoParams());
    result.fold(
      onSuccess: (data) => _branches = data,
      onFailure: (f) => _failure = f,
    );
  }

  Future<void> loadSkus() async {
    final result = await getSkusUseCase(
      GetSkusParams(
        queryOrBarcode: _skuQuery,
        editorial: _skuEditorial,
        categoria: _skuCategoria,
      ),
    );
    result.fold(
      onSuccess: (data) => _skus = data,
      onFailure: (f) => _failure = f,
    );
  }

  Future<void> loadFiscalConfig() async {
    final result = await getFiscalConfigUseCase(const NoParams());
    result.fold(
      onSuccess: (data) => _fiscalConfig = data,
      onFailure: (f) => _failure = f,
    );
  }

  // ===========================================================================
  // GESTIÓN DE SUCURSALES (ALTA, EDICIÓN, BAJA CON RESTRICCIONES Y REACTIVACIÓN)
  // ===========================================================================
  Future<bool> createBranch(CreateBranchParams params) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await createBranchUseCase(params);

    _isLoading = false;
    return result.fold(
      onSuccess: (newBranch) {
        _branches.add(newBranch);
        _successMessage = 'Sucursal "${newBranch.nombre}" creada y dada de alta correctamente.';
        eventBus.emit(BranchCreatedEvent(branch: newBranch));
        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> updateBranch(BranchEntity branch) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await updateBranchUseCase(branch);

    _isLoading = false;
    return result.fold(
      onSuccess: (updated) {
        final index = _branches.indexWhere((b) => b.id == updated.id);
        if (index != -1) {
          _branches[index] = updated;
          _successMessage = 'Sucursal ${updated.nombre} actualizada correctamente.';
          notifyListeners();
        }
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> deactivateBranch({required String branchId, required String motivo}) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await deactivateBranchUseCase(
      DeactivateBranchParams(branchId: branchId, motivo: motivo),
    );

    _isLoading = false;
    return result.fold(
      onSuccess: (deactivated) {
        final index = _branches.indexWhere((b) => b.id == deactivated.id);
        if (index != -1) {
          _branches[index] = deactivated;
        }
        _successMessage = 'Sucursal "${deactivated.nombre}" dada de baja con éxito.';
        eventBus.emit(BranchDeactivatedEvent(
          branch: deactivated,
          motivo: motivo,
        ));
        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> reactivateBranch(String branchId) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await reactivateBranchUseCase(branchId);

    _isLoading = false;
    return result.fold(
      onSuccess: (reactivated) {
        final index = _branches.indexWhere((b) => b.id == reactivated.id);
        if (index != -1) {
          _branches[index] = reactivated;
        }
        _successMessage = 'Sucursal "${reactivated.nombre}" reactivada con éxito.';
        eventBus.emit(BranchReactivatedEvent(
          branch: reactivated,
        ));
        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> transferirActivosYConciliar(String branchId) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final branch = _branches.where((b) => b.id == branchId).firstOrNull;
    if (branch == null) {
      _isLoading = false;
      _failure = const ValidationFailure(message: 'Sucursal no encontrada.');
      notifyListeners();
      return false;
    }

    final updated = branch.copyWith(
      cuentasPendientes: 0.0,
      activosAsignados: 0,
      ocupacionPorcentaje: 0.0,
    );
    final result = await updateBranchUseCase(updated);

    _isLoading = false;
    return result.fold(
      onSuccess: (res) {
        final index = _branches.indexWhere((b) => b.id == res.id);
        if (index != -1) {
          _branches[index] = res;
        }
        _successMessage = 'Cuentas conciliadas (Bs 0.00) y activos transferidos a Casa Matriz. La sucursal ahora está lista para ser dada de baja.';
        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  // ===========================================================================
  // CATÁLOGO SKU Y LECTOR DE CÓDIGO DE BARRAS USB
  // ===========================================================================
  void filterSkus({String? queryOrBarcode, String? editorial, String? categoria}) {
    if (queryOrBarcode != null) _skuQuery = queryOrBarcode;
    if (editorial != null) _skuEditorial = editorial;
    if (categoria != null) _skuCategoria = categoria;
    loadSkus().then((_) => notifyListeners());
  }

  Future<bool> createSku({
    required String ean13,
    required String titulo,
    required String editorial,
    required String categoria,
    required double costoBs,
    required double margenPorcentaje,
    required int stockInicial,
  }) async {
    _isLoading = true;
    notifyListeners();

    final result = await createSkuUseCase(
      CreateSkuParams(
        ean13: ean13,
        titulo: titulo,
        editorial: editorial,
        categoria: categoria,
        costoBs: costoBs,
        margenPorcentaje: margenPorcentaje,
        stockInicial: stockInicial,
      ),
    );

    _isLoading = false;
    return result.fold(
      onSuccess: (sku) {
        _skus.insert(0, sku);
        _successMessage = 'SKU ${sku.ean13} registrado con éxito en el catálogo.';

        // EDA: Publicación de evento de dominio
        eventBus.emit(SkuRegisteredEvent(sku: sku));

        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  // ===========================================================================
  // PARAMETRIZACIÓN FISCAL SIAT BOLIVIA
  // ===========================================================================
  Future<bool> updateFiscalConfig(FiscalConfigEntity config) async {
    _isLoading = true;
    notifyListeners();

    final result = await updateFiscalConfigUseCase(config);

    _isLoading = false;
    return result.fold(
      onSuccess: (updated) {
        _fiscalConfig = updated;
        _successMessage = 'Parametrización tributaria SIAT guardada con éxito.';

        // EDA: Publicación de evento de dominio
        eventBus.emit(FiscalConfigUpdatedEvent(config: updated));

        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  Future<bool> testSiatConnection() async {
    _isTestingSiat = true;
    notifyListeners();

    final result = await testSiatConnectionUseCase(const NoParams());

    _isTestingSiat = false;
    return result.fold(
      onSuccess: (ok) {
        if (_fiscalConfig != null) {
          _fiscalConfig = _fiscalConfig!.copyWith(
            sincronizadoConSin: true,
            ultimoPingWebService: DateTime.now(),
          );
        }
        _successMessage = 'Conexión con el WebService del SIN exitosa (Código 200 OK).';

        // EDA: Publicación de evento de dominio
        eventBus.emit(
          SiatConnectionTestedEvent(
            exitoso: true,
            mensaje: 'Conexión validada con el SIN',
          ),
        );

        notifyListeners();
        return true;
      },
      onFailure: (f) {
        _failure = f;
        notifyListeners();
        return false;
      },
    );
  }

  void clearMessages() {
    _failure = null;
    _successMessage = null;
    notifyListeners();
  }
}
