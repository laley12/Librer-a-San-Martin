import '../../domain/entities/admin_entities.dart';
import '../models/admin_models.dart';

abstract interface class AdministrationRemoteDataSource {
  Future<AdminKpiEntity> getAdminKpis();
  Future<List<BranchModel>> getBranches();
  Future<BranchModel> createBranch(BranchEntity branch);
  Future<BranchModel> updateBranch(BranchEntity branch);
  Future<BranchModel> deactivateBranch(String branchId, String motivo);
  Future<BranchModel> reactivateBranch(String branchId);
  Future<BranchModel> liquidarCuentasYActivos(String branchId);
  Future<List<SkuModel>> getSkus({String? queryOrBarcode, String? editorial, String? categoria});
  Future<SkuModel> createSku({
    required String ean13,
    required String titulo,
    required String editorial,
    required String categoria,
    required double costoBs,
    required double margenPorcentaje,
    required int stockInicial,
  });
  Future<FiscalConfigModel> getFiscalConfig();
  Future<FiscalConfigModel> updateFiscalConfig(FiscalConfigEntity config);
  Future<bool> testSiatConnection();
}

class MockAdministrationRemoteDataSourceImpl implements AdministrationRemoteDataSource {
  final Duration delay;

  MockAdministrationRemoteDataSourceImpl({this.delay = Duration.zero});

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
  }

  final List<BranchModel> _branches = [
    const BranchModel(
      id: 'br_scz_01',
      nombre: 'Sede Central Santa Cruz',
      direccion: 'Av. Monseñor Rivero #340, Zona Norte',
      ciudad: 'Santa Cruz de la Sierra',
      encargado: 'Lic. Gustavo Guachalla',
      cajasPosAsignadas: 3,
      aforoM2: 280.0,
      ocupacionPorcentaje: 0.74,
      bodegasVinculadas: ['Bodega Principal A', 'Depósito Técnico B'],
      activa: true,
      cuentasPendientes: 14850.0,
      activosAsignados: 340,
    ),
    const BranchModel(
      id: 'br_lg_02',
      nombre: 'Agencia La Guardia',
      direccion: 'Km 14 Doble Vía a La Guardia #105',
      ciudad: 'La Guardia - Santa Cruz',
      encargado: 'Roberto Carlos Pinto',
      cajasPosAsignadas: 2,
      aforoM2: 120.0,
      ocupacionPorcentaje: 0.58,
      bodegasVinculadas: ['Bodega Almacén C'],
      activa: true,
      cuentasPendientes: 3200.0,
      activosAsignados: 85,
    ),
    const BranchModel(
      id: 'br_eq_03',
      nombre: 'Agencia Equipetrol',
      direccion: 'Calle 7 Este esq. Canal Isuto #45',
      ciudad: 'Santa Cruz de la Sierra',
      encargado: 'Mariana Suarez Vaca',
      cajasPosAsignadas: 2,
      aforoM2: 150.0,
      ocupacionPorcentaje: 0.20,
      bodegasVinculadas: ['Bodega Muestrarios E'],
      activa: true,
      cuentasPendientes: 0.0,
      activosAsignados: 0,
    ),
  ];

  final List<SkuModel> _skus = [
    const SkuModel(
      id: 'sku_001',
      ean13: '9789990518291',
      titulo: 'Matemáticas Avanzadas 6to Primaria',
      editorial: 'Santillana',
      categoria: 'Textos Escolares',
      costoBs: 110.0,
      margenPorcentaje: 30.0,
      precioVentaBs: 157.14,
      stockActual: 142,
    ),
    const SkuModel(
      id: 'sku_002',
      ean13: '9789990529182',
      titulo: 'Ciencias Naturales e Integradas 5to',
      editorial: 'Norma',
      categoria: 'Textos Escolares',
      costoBs: 95.0,
      margenPorcentaje: 32.0,
      precioVentaBs: 139.71,
      stockActual: 98,
    ),
    const SkuModel(
      id: 'sku_003',
      ean13: '9789990530193',
      titulo: 'Lenguaje y Comunicación Secundaria 3',
      editorial: 'Don Bosco',
      categoria: 'Textos Escolares',
      costoBs: 85.0,
      margenPorcentaje: 35.0,
      precioVentaBs: 130.77,
      stockActual: 210,
    ),
    const SkuModel(
      id: 'sku_004',
      ean13: '9786073241038',
      titulo: 'Cálculo de una Variable (Stewart 8va Ed.)',
      editorial: 'Cengage / Pearson',
      categoria: 'Textos Universitarios',
      costoBs: 240.0,
      margenPorcentaje: 25.0,
      precioVentaBs: 320.00,
      stockActual: 35,
    ),
    const SkuModel(
      id: 'sku_005',
      ean13: '9788448198442',
      titulo: 'Química General Universitaria',
      editorial: 'McGraw-Hill',
      categoria: 'Textos Universitarios',
      costoBs: 215.0,
      margenPorcentaje: 28.0,
      precioVentaBs: 298.61,
      stockActual: 42,
    ),
    const SkuModel(
      id: 'sku_006',
      ean13: '9788420471839',
      titulo: 'Cien Años de Soledad (Ed. Ilustrada)',
      editorial: 'Norma',
      categoria: 'Literatura y Ficción',
      costoBs: 70.0,
      margenPorcentaje: 40.0,
      precioVentaBs: 116.67,
      stockActual: 84,
    ),
    const SkuModel(
      id: 'sku_007',
      ean13: '9789995410928',
      titulo: 'Raza de Bronce (Alcides Arguedas)',
      editorial: 'Don Bosco',
      categoria: 'Literatura y Ficción',
      costoBs: 45.0,
      margenPorcentaje: 45.0,
      precioVentaBs: 81.82,
      stockActual: 115,
    ),
    const SkuModel(
      id: 'sku_008',
      ean13: '9780134093413',
      titulo: 'Cryptography and Network Security',
      editorial: 'Pearson',
      categoria: 'Criptografía e Informática',
      costoBs: 320.0,
      margenPorcentaje: 25.0,
      precioVentaBs: 426.67,
      stockActual: 24,
    ),
    const SkuModel(
      id: 'sku_009',
      ean13: '7771234500912',
      titulo: 'Resma de Papel Bond A4 75g (Caja x 5)',
      editorial: 'Papelería y Oficina',
      categoria: 'Papelería y Oficina',
      costoBs: 135.0,
      margenPorcentaje: 22.0,
      precioVentaBs: 173.08,
      stockActual: 320,
    ),
  ];

  FiscalConfigModel _fiscalConfig = FiscalConfigModel(
    nit: '1028374029',
    razonSocial: 'LIBRERÍA Y PAPELERÍA SAN MARTÍN S.R.L.',
    cufdActual: 'B1C2D3E4F5A6B7C8D9E0F1A2B3C4D5E6F7A8B9C0',
    cuisActual: 'CUIS-SCZ-CENTRAL-00192',
    fechaVencimientoCufd: DateTime(2026, 11, 18, 23, 59),
    porcentajeIva: 13.0,
    porcentajeIt: 3.0,
    sincronizadoConSin: true,
    ultimoPingWebService: DateTime.now().subtract(const Duration(minutes: 8)),
  );

  @override
  Future<AdminKpiEntity> getAdminKpis() async {
    await _wait();
    return const AdminKpiEntity(
      sedesActivas: 2,
      totalSkuMaestros: 1248,
      totalCategorias: 14,
      estadoCufdSiat: 'Vigente',
      distribucionExistencias: [
        CategoryStockDistribution(
          categoria: 'Textos Escolares',
          totalUnidades: 450,
          porcentaje: 36.0,
        ),
        CategoryStockDistribution(
          categoria: 'Textos Universitarios',
          totalUnidades: 280,
          porcentaje: 22.5,
        ),
        CategoryStockDistribution(
          categoria: 'Literatura y Ficción',
          totalUnidades: 220,
          porcentaje: 17.6,
        ),
        CategoryStockDistribution(
          categoria: 'Papelería y Oficina',
          totalUnidades: 198,
          porcentaje: 15.9,
        ),
        CategoryStockDistribution(
          categoria: 'Criptografía e Informática',
          totalUnidades: 100,
          porcentaje: 8.0,
        ),
      ],
    );
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    await _wait();
    return List.from(_branches);
  }

  @override
  Future<BranchModel> createBranch(BranchEntity branch) async {
    await _wait();
    final newModel = BranchModel(
      id: branch.id,
      nombre: branch.nombre,
      direccion: branch.direccion,
      ciudad: branch.ciudad,
      encargado: branch.encargado,
      cajasPosAsignadas: branch.cajasPosAsignadas,
      aforoM2: branch.aforoM2,
      ocupacionPorcentaje: branch.ocupacionPorcentaje,
      bodegasVinculadas: branch.bodegasVinculadas,
      activa: true,
      cuentasPendientes: 0.0,
      activosAsignados: 0,
    );
    _branches.add(newModel);
    return newModel;
  }

  @override
  Future<BranchModel> updateBranch(BranchEntity branch) async {
    await _wait();
    final index = _branches.indexWhere((b) => b.id == branch.id);
    if (index != -1) {
      _branches[index] = BranchModel(
        id: branch.id,
        nombre: branch.nombre,
        direccion: branch.direccion,
        ciudad: branch.ciudad,
        encargado: branch.encargado,
        cajasPosAsignadas: branch.cajasPosAsignadas,
        aforoM2: branch.aforoM2,
        ocupacionPorcentaje: branch.ocupacionPorcentaje,
        bodegasVinculadas: branch.bodegasVinculadas,
        activa: branch.activa,
        cuentasPendientes: branch.cuentasPendientes,
        activosAsignados: branch.activosAsignados,
        motivoBaja: branch.motivoBaja,
        fechaBaja: branch.fechaBaja,
      );
      return _branches[index];
    }
    throw Exception('Sucursal no encontrada');
  }

  @override
  Future<BranchModel> deactivateBranch(String branchId, String motivo) async {
    await _wait();
    final index = _branches.indexWhere((b) => b.id == branchId);
    if (index != -1) {
      final current = _branches[index];
      _branches[index] = BranchModel(
        id: current.id,
        nombre: current.nombre,
        direccion: current.direccion,
        ciudad: current.ciudad,
        encargado: current.encargado,
        cajasPosAsignadas: current.cajasPosAsignadas,
        aforoM2: current.aforoM2,
        ocupacionPorcentaje: 0.0,
        bodegasVinculadas: current.bodegasVinculadas,
        activa: false,
        cuentasPendientes: current.cuentasPendientes,
        activosAsignados: current.activosAsignados,
        motivoBaja: motivo,
        fechaBaja: DateTime.now(),
      );
      return _branches[index];
    }
    throw Exception('Sucursal no encontrada');
  }

  @override
  Future<BranchModel> reactivateBranch(String branchId) async {
    await _wait();
    final index = _branches.indexWhere((b) => b.id == branchId);
    if (index != -1) {
      final current = _branches[index];
      _branches[index] = BranchModel(
        id: current.id,
        nombre: current.nombre,
        direccion: current.direccion,
        ciudad: current.ciudad,
        encargado: current.encargado,
        cajasPosAsignadas: current.cajasPosAsignadas,
        aforoM2: current.aforoM2,
        ocupacionPorcentaje: 0.10,
        bodegasVinculadas: current.bodegasVinculadas,
        activa: true,
        cuentasPendientes: current.cuentasPendientes,
        activosAsignados: current.activosAsignados,
        motivoBaja: null,
        fechaBaja: null,
      );
      return _branches[index];
    }
    throw Exception('Sucursal no encontrada');
  }

  @override
  Future<BranchModel> liquidarCuentasYActivos(String branchId) async {
    await _wait();
    final index = _branches.indexWhere((b) => b.id == branchId);
    if (index != -1) {
      final current = _branches[index];
      _branches[index] = BranchModel(
        id: current.id,
        nombre: current.nombre,
        direccion: current.direccion,
        ciudad: current.ciudad,
        encargado: current.encargado,
        cajasPosAsignadas: current.cajasPosAsignadas,
        aforoM2: current.aforoM2,
        ocupacionPorcentaje: 0.0,
        bodegasVinculadas: current.bodegasVinculadas,
        activa: current.activa,
        cuentasPendientes: 0.0,
        activosAsignados: 0,
        motivoBaja: current.motivoBaja,
        fechaBaja: current.fechaBaja,
      );
      return _branches[index];
    }
    throw Exception('Sucursal no encontrada');
  }

  @override
  Future<List<SkuModel>> getSkus({
    String? queryOrBarcode,
    String? editorial,
    String? categoria,
  }) async {
    await _wait();
    var list = List<SkuModel>.from(_skus);
    if (queryOrBarcode != null && queryOrBarcode.trim().isNotEmpty) {
      final q = queryOrBarcode.trim().toLowerCase();
      list = list
          .where(
            (s) =>
                s.ean13.contains(q) ||
                s.titulo.toLowerCase().contains(q) ||
                s.editorial.toLowerCase().contains(q),
          )
          .toList();
    }
    if (editorial != null && editorial != 'Todas') {
      list = list.where((s) => s.editorial == editorial).toList();
    }
    if (categoria != null && categoria != 'Todas') {
      list = list.where((s) => s.categoria == categoria).toList();
    }
    return list;
  }

  @override
  Future<SkuModel> createSku({
    required String ean13,
    required String titulo,
    required String editorial,
    required String categoria,
    required double costoBs,
    required double margenPorcentaje,
    required int stockInicial,
  }) async {
    await _wait();
    final precioVenta = SkuEntity.calcularPrecioVenta(costoBs, margenPorcentaje);
    final newSku = SkuModel(
      id: 'sku_${DateTime.now().millisecondsSinceEpoch}',
      ean13: ean13,
      titulo: titulo,
      editorial: editorial,
      categoria: categoria,
      costoBs: costoBs,
      margenPorcentaje: margenPorcentaje,
      precioVentaBs: precioVenta,
      stockActual: stockInicial,
    );
    _skus.insert(0, newSku);
    return newSku;
  }

  @override
  Future<FiscalConfigModel> getFiscalConfig() async {
    await _wait();
    return _fiscalConfig;
  }

  @override
  Future<FiscalConfigModel> updateFiscalConfig(FiscalConfigEntity config) async {
    await _wait();
    _fiscalConfig = FiscalConfigModel(
      nit: config.nit,
      razonSocial: config.razonSocial,
      cufdActual: config.cufdActual,
      cuisActual: config.cuisActual,
      fechaVencimientoCufd: config.fechaVencimientoCufd,
      porcentajeIva: config.porcentajeIva,
      porcentajeIt: config.porcentajeIt,
      sincronizadoConSin: config.sincronizadoConSin,
      ultimoPingWebService: DateTime.now(),
    );
    return _fiscalConfig;
  }

  @override
  Future<bool> testSiatConnection() async {
    await _wait();
    _fiscalConfig = FiscalConfigModel(
      nit: _fiscalConfig.nit,
      razonSocial: _fiscalConfig.razonSocial,
      cufdActual: _fiscalConfig.cufdActual,
      cuisActual: _fiscalConfig.cuisActual,
      fechaVencimientoCufd: _fiscalConfig.fechaVencimientoCufd,
      porcentajeIva: _fiscalConfig.porcentajeIva,
      porcentajeIt: _fiscalConfig.porcentajeIt,
      sincronizadoConSin: true,
      ultimoPingWebService: DateTime.now(),
    );
    return true;
  }
}
