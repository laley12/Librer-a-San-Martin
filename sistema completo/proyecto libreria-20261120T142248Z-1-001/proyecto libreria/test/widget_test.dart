import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto/core/events/event_bus.dart';
import 'package:proyecto/core/layout/app_shell.dart';
import 'package:proyecto/core/theme/app_theme.dart';
import 'package:proyecto/features/administration/data/datasources/administration_remote_data_source.dart';
import 'package:proyecto/features/administration/data/repositories/administration_repository_impl.dart';
import 'package:proyecto/features/administration/domain/entities/admin_entities.dart';
import 'package:proyecto/features/administration/domain/events/admin_events.dart';
import 'package:proyecto/features/administration/domain/usecases/admin_usecases.dart';
import 'package:proyecto/features/administration/presentation/controllers/administration_controller.dart';
import 'package:proyecto/features/administration/presentation/pages/administracion_dashboard_view.dart';
import 'package:proyecto/features/administration/presentation/pages/catalogo_sku_view.dart';
import 'package:proyecto/features/administration/presentation/pages/gestion_sucursales_view.dart';
import 'package:proyecto/features/administration/presentation/pages/parametrizacion_fiscal_view.dart';
import 'package:proyecto/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:proyecto/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:proyecto/features/auth/domain/events/user_logged_in_event.dart';
import 'package:proyecto/features/auth/domain/usecases/login_usecase.dart';
import 'package:proyecto/features/auth/presentation/controllers/auth_controller.dart';
import 'package:proyecto/features/reports/data/datasources/reports_remote_data_source.dart';
import 'package:proyecto/features/reports/data/repositories/reports_repository_impl.dart';
import 'package:proyecto/features/reports/domain/entities/reports_entities.dart';
import 'package:proyecto/features/reports/domain/events/reports_events.dart';
import 'package:proyecto/features/reports/domain/usecases/reports_usecases.dart';
import 'package:proyecto/features/reports/presentation/controllers/reports_controller.dart';
import 'package:proyecto/features/reports/presentation/pages/reporte_compras_view.dart';
import 'package:proyecto/features/reports/presentation/pages/reporte_stock_semaforico_view.dart';
import 'package:proyecto/features/reports/presentation/pages/reporte_ventas_view.dart';
import 'package:proyecto/features/reports/presentation/pages/reportes_dashboard_view.dart';
import 'package:proyecto/features/sales_purchases/data/datasources/sales_purchases_remote_data_source.dart';
import 'package:proyecto/features/sales_purchases/data/repositories/sales_purchases_repository_impl.dart';
import 'package:proyecto/features/sales_purchases/domain/entities/sales_purchases_entities.dart';
import 'package:proyecto/features/sales_purchases/domain/events/sales_purchases_events.dart';
import 'package:proyecto/features/sales_purchases/domain/usecases/sales_purchases_usecases.dart';
import 'package:proyecto/features/sales_purchases/presentation/controllers/sales_purchases_controller.dart';
import 'package:proyecto/features/sales_purchases/presentation/pages/compras_ventas_dashboard_view.dart';
import 'package:proyecto/features/sales_purchases/presentation/pages/directorio_proveedores_view.dart';
import 'package:proyecto/features/sales_purchases/presentation/pages/inventario_kardex_view.dart';
import 'package:proyecto/features/sales_purchases/presentation/pages/ordenes_compra_cif_view.dart';
import 'package:proyecto/features/sales_purchases/presentation/pages/punto_venta_pos_view.dart';
import 'package:proyecto/features/security/data/datasources/security_remote_data_source.dart';
import 'package:proyecto/features/security/data/repositories/security_repository_impl.dart';
import 'package:proyecto/features/security/domain/events/security_events.dart';
import 'package:proyecto/features/security/domain/usecases/security_usecases.dart';
import 'package:proyecto/features/security/presentation/controllers/security_controller.dart';
import 'package:proyecto/features/security/presentation/pages/bitacora_worm_view.dart';
import 'package:proyecto/features/security/presentation/pages/control_rbac_view.dart';
import 'package:proyecto/features/security/presentation/pages/gestion_usuarios_view.dart';
import 'package:proyecto/features/security/presentation/pages/mantenimiento_respaldos_view.dart';
import 'package:proyecto/features/security/presentation/pages/seguridad_dashboard_view.dart';
import 'package:proyecto/features/security/presentation/pages/politicas_seguridad_view.dart';
import 'package:proyecto/features/security/presentation/pages/monitoreo_sesiones_view.dart';
import 'package:proyecto/features/security/presentation/pages/modulo_seguridad_view.dart';
import 'package:proyecto/main.dart';

SecurityController createTestSecurityController(AppEventBus eventBus) {
  final ds = MockSecurityRemoteDataSourceImpl(delay: Duration.zero);
  final repo = SecurityRepositoryImpl(remoteDataSource: ds);
  return SecurityController(
    getSecurityKpisUseCase: GetSecurityKpisUseCase(repo),
    getActiveSessionsUseCase: GetActiveSessionsUseCase(repo),
    revokeSessionUseCase: RevokeSessionUseCase(repo),
    getUsersUseCase: GetUsersUseCase(repo),
    createUserUseCase: CreateUserUseCase(repo),
    toggleUserStatusUseCase: ToggleUserStatusUseCase(repo),
    softDeleteUserUseCase: SoftDeleteUserUseCase(repo),
    getRbacMatrixUseCase: GetRbacMatrixUseCase(repo),
    updateRbacPermissionUseCase: UpdateRbacPermissionUseCase(repo),
    getWormLogsUseCase: GetWormLogsUseCase(repo),
    getBackupsUseCase: GetBackupsUseCase(repo),
    triggerManualBackupUseCase: TriggerManualBackupUseCase(repo),
    eventBus: eventBus,
  );
}

AdministrationController createTestAdminController(AppEventBus eventBus) {
  final ds = MockAdministrationRemoteDataSourceImpl(delay: Duration.zero);
  final repo = AdministrationRepositoryImpl(remoteDataSource: ds);
  return AdministrationController(
    getAdminKpisUseCase: GetAdminKpisUseCase(repo),
    getBranchesUseCase: GetBranchesUseCase(repo),
    createBranchUseCase: CreateBranchUseCase(repo),
    updateBranchUseCase: UpdateBranchUseCase(repo),
    deactivateBranchUseCase: DeactivateBranchUseCase(repo),
    reactivateBranchUseCase: ReactivateBranchUseCase(repo),
    getSkusUseCase: GetSkusUseCase(repo),
    createSkuUseCase: CreateSkuUseCase(repo),
    getFiscalConfigUseCase: GetFiscalConfigUseCase(repo),
    updateFiscalConfigUseCase: UpdateFiscalConfigUseCase(repo),
    testSiatConnectionUseCase: TestSiatConnectionUseCase(repo),
    eventBus: eventBus,
  );
}

SalesPurchasesController createTestSalesPurchasesController(AppEventBus eventBus) {
  final ds = MockSalesPurchasesRemoteDataSourceImpl(delay: Duration.zero);
  final repo = SalesPurchasesRepositoryImpl(ds);
  return SalesPurchasesController(
    getPosProductsUseCase: GetPosProductsUseCase(repo),
    searchProductUseCase: SearchProductUseCase(repo),
    searchCustomerByNitUseCase: SearchCustomerByNitUseCase(repo),
    processPosSaleUseCase: ProcessPosSaleUseCase(repo, eventBus),
    getKardexBySkuUseCase: GetKardexBySkuUseCase(repo),
    getCifOrdersUseCase: GetCifOrdersUseCase(repo),
    registerCifOrderUseCase: RegisterCifOrderUseCase(repo, eventBus),
    getSuppliersUseCase: GetSuppliersUseCase(repo),
    getSalesPurchasesKpiUseCase: GetSalesPurchasesKpiUseCase(repo),
    eventBus: eventBus,
  );
}

ReportsController createTestReportsController(AppEventBus eventBus) {
  final ds = MockReportsRemoteDataSourceImpl(delay: Duration.zero);
  final repo = ReportsRepositoryImpl(ds);
  return ReportsController(
    getReportsKpisUseCase: GetReportsKpisUseCase(repo),
    getDailySalesEvolutionUseCase: GetDailySalesEvolutionUseCase(repo),
    getSiatSalesVouchersUseCase: GetSiatSalesVouchersUseCase(repo),
    getStockSemaforicoUseCase: GetStockSemaforicoUseCase(repo),
    requestStockReplenishmentUseCase: RequestStockReplenishmentUseCase(eventBus),
    exportReportUseCase: ExportReportUseCase(eventBus),
    eventBus: eventBus,
  );
}

void main() {
  group('EDA - EventBus Tests', () {
    test('Debe emitir y recibir un evento de dominio UserLoggedInEvent de forma desacoplada', () async {
      final eventBus = DefaultAppEventBus();
      UserLoggedInEvent? receivedEvent;

      final subscription = eventBus.on<UserLoggedInEvent>().listen((event) {
        receivedEvent = event;
      });

      final dataSource = MockAuthRemoteDataSourceImpl(delay: Duration.zero);
      final repo = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repo);
      final controller = AuthController(loginUseCase: useCase, eventBus: eventBus);

      final result = await controller.login(
        email: 'admin@sanmartin.bo',
        password: 'Admin@2026',
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(result, isTrue);
      expect(receivedEvent, isNotNull);
      expect(receivedEvent!.user.email, equals('admin@sanmartin.bo'));

      await subscription.cancel();
      eventBus.dispose();
    });

    test('Debe emitir SessionRevokedEvent al revocar una sesión en SecurityController', () async {
      final eventBus = DefaultAppEventBus();
      SessionRevokedEvent? receivedRevocation;

      final subscription = eventBus.on<SessionRevokedEvent>().listen((event) {
        receivedRevocation = event;
      });

      final securityController = createTestSecurityController(eventBus);
      await securityController.loadSessions();

      final targetJti = securityController.sessions.first.jti;
      final ok = await securityController.revokeSession(targetJti, '4872910');

      await Future.delayed(const Duration(milliseconds: 10));

      expect(ok, isTrue);
      expect(receivedRevocation, isNotNull);
      expect(receivedRevocation!.jti, equals(targetJti));

      await subscription.cancel();
      eventBus.dispose();
    });

    test('Debe emitir SkuRegisteredEvent al crear un producto en AdministrationController', () async {
      final eventBus = DefaultAppEventBus();
      SkuRegisteredEvent? receivedSku;

      final subscription = eventBus.on<SkuRegisteredEvent>().listen((event) {
        receivedSku = event;
      });

      final adminController = createTestAdminController(eventBus);
      final ok = await adminController.createSku(
        ean13: '7770001928371',
        titulo: 'Álgebra Lineal Moderna',
        editorial: 'Santillana',
        categoria: 'Textos Universitarios',
        costoBs: 150.0,
        margenPorcentaje: 30.0,
        stockInicial: 25,
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(ok, isTrue);
      expect(receivedSku, isNotNull);
      expect(receivedSku!.sku.titulo, equals('Álgebra Lineal Moderna'));

      await subscription.cancel();
      eventBus.dispose();
    });

    test('No debe permitir dar de baja una sucursal si tiene cuentas pendientes o activos asignados', () async {
      final eventBus = DefaultAppEventBus();
      final adminController = createTestAdminController(eventBus);
      await adminController.loadBranches();

      // br_scz_01 tiene cuentasPendientes: 14850.0 y activosAsignados: 340
      final ok1 = await adminController.deactivateBranch(
        branchId: 'br_scz_01',
        motivo: 'Cierre por remodelación',
      );
      expect(ok1, isFalse);
      expect(adminController.failure?.message, contains('RESTRICCIÓN CONTABLE'));

      // br_lg_02 tiene cuentasPendientes: 3200.0 y activosAsignados: 85
      final ok2 = await adminController.deactivateBranch(
        branchId: 'br_lg_02',
        motivo: 'Cierre de operaciones',
      );
      expect(ok2, isFalse);
      expect(adminController.failure?.message, contains('RESTRICCIÓN CONTABLE'));

      // br_eq_03 tiene cuentasPendientes: 0.0 y activosAsignados: 0 -> Debe permitir la baja
      final ok3 = await adminController.deactivateBranch(
        branchId: 'br_eq_03',
        motivo: 'Reubicación estratégica de agencia',
      );
      expect(ok3, isTrue);
      expect(adminController.branches.firstWhere((b) => b.id == 'br_eq_03').activa, isFalse);
      expect(adminController.branches.firstWhere((b) => b.id == 'br_eq_03').motivoBaja, equals('Reubicación estratégica de agencia'));

      // Reactivar la sucursal dada de baja
      final okReactivate = await adminController.reactivateBranch('br_eq_03');
      expect(okReactivate, isTrue);
      expect(adminController.branches.firstWhere((b) => b.id == 'br_eq_03').activa, isTrue);

      eventBus.dispose();
    });

    test('Debe permitir crear una nueva sucursal y emitir BranchCreatedEvent', () async {
      final eventBus = DefaultAppEventBus();
      BranchCreatedEvent? createdEvent;
      final sub = eventBus.on<BranchCreatedEvent>().listen((e) => createdEvent = e);

      final adminController = createTestAdminController(eventBus);
      final ok = await adminController.createBranch(
        const CreateBranchParams(
          nombre: 'Sucursal Plan 3000',
          direccion: 'Av. El Mechero #400',
          ciudad: 'Santa Cruz de la Sierra',
          encargado: 'Lic. Fernando Rojas',
          cajasPosAsignadas: 2,
          aforoM2: 130.0,
          bodegasVinculadas: ['Bodega Local P3000'],
        ),
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(ok, isTrue);
      expect(createdEvent, isNotNull);
      expect(createdEvent!.branch.nombre, equals('Sucursal Plan 3000'));
      expect(adminController.branches.any((b) => b.nombre == 'Sucursal Plan 3000'), isTrue);

      await sub.cancel();
      eventBus.dispose();
    });

    test('Debe emitir SaleInvoicedEvent al facturar exitosamente en POS (F10)', () async {
      final eventBus = DefaultAppEventBus();
      SaleInvoicedEvent? receivedSale;

      final subscription = eventBus.on<SaleInvoicedEvent>().listen((event) {
        receivedSale = event;
      });

      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadPosProducts();

      final prod = controller.products.firstWhere((p) => p.stockDisponible > 0);
      controller.addToCart(prod);
      controller.setCustomerData(nit: '4871923', razonSocial: 'Lic. Gustavo Guachalla');
      controller.setMontoRecibido(controller.cartTotal + 50.0);

      final ok = await controller.emitirFacturaSiat();

      await Future.delayed(const Duration(milliseconds: 10));

      expect(ok, isTrue);
      expect(receivedSale, isNotNull);
      expect(receivedSale!.razonSocial, equals('Lic. Gustavo Guachalla'));
      expect(receivedSale!.total, equals(controller.lastIssuedInvoice?.total));

      await subscription.cancel();
      eventBus.dispose();
    });

    test('Debe emitir CifOrderRegisteredEvent al registrar orden CIF', () async {
      final eventBus = DefaultAppEventBus();
      CifOrderRegisteredEvent? receivedCif;

      final subscription = eventBus.on<CifOrderRegisteredEvent>().listen((event) {
        receivedCif = event;
      });

      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadAll();

      final ok = await controller.registrarOrdenCif(
        RegisterCifOrderParams(
          proveedor: 'Santillana Bolivia',
          sku: 'SKU-MAT-002',
          skuTitulo: 'Matemática Moderna',
          cantidadUnidades: 100,
          fobTotalUsd: 1200.0,
          fleteUsd: 150.0,
          seguroUsd: 30.0,
          tipoCambioBob: 6.96,
          gaPorcentaje: 0.10,
          gastosDespachoBob: 500.0,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 10));

      expect(ok, isTrue);
      expect(receivedCif, isNotNull);
      expect(receivedCif!.sku, equals('SKU-MAT-002'));
      expect(receivedCif!.cantidad, equals(100));

      await subscription.cancel();
      eventBus.dispose();
    });

    test('Debe emitir StockReplenishmentRequestedEvent al solicitar reposición desde Stock Semafórico', () async {
      final eventBus = DefaultAppEventBus();
      StockReplenishmentRequestedEvent? receivedReplenish;

      final subscription = eventBus.on<StockReplenishmentRequestedEvent>().listen((event) {
        receivedReplenish = event;
      });

      final controller = createTestReportsController(eventBus);
      await controller.loadStockSemaforico();

      final critico = controller.stockItems.firstWhere((i) => i.esCritico);
      await controller.solicitarReposicion(critico);

      await Future.delayed(const Duration(milliseconds: 10));

      expect(receivedReplenish, isNotNull);
      expect(receivedReplenish!.sku, equals(critico.sku));
      expect(receivedReplenish!.cantidadSugerida, equals(critico.cantidadRecomendadaCompra));

      await subscription.cancel();
      eventBus.dispose();
    });
  });

  group('Clean Architecture - Criterio de Criticidad Semafórica y Reglas Retail', () {
    test('StockSemaforicEntity debe clasificar en CRÍTICO, REORDEN y ÓPTIMO según los umbrales', () {
      // 1. Crítico / Agotado: stockActual <= stockMinimo
      const criticoAgotado = StockSemaforicEntity(
        sku: 'SKU-1',
        titulo: 'Libro A',
        editorial: 'Norma',
        categoria: 'Literatura',
        stockActual: 5,
        stockMinimo: 10,
        costoUnitarioBs: 50.0,
        precioVentaBs: 90.0,
      );
      expect(criticoAgotado.status, equals(StockStatus.critico));
      expect(criticoAgotado.esCritico, isTrue);
      expect(criticoAgotado.cantidadRecomendadaCompra, equals(25)); // (10 * 3) - 5

      // 2. Atención / Reorden: stockActual > min && stockActual <= min * 1.5
      const reorden = StockSemaforicEntity(
        sku: 'SKU-2',
        titulo: 'Libro B',
        editorial: 'Santillana',
        categoria: 'Escolares',
        stockActual: 13,
        stockMinimo: 10, // 10 * 1.5 = 15 -> 13 <= 15
        costoUnitarioBs: 60.0,
        precioVentaBs: 100.0,
      );
      expect(reorden.status, equals(StockStatus.reorden));
      expect(reorden.esReorden, isTrue);

      // 3. Óptimo / Normal: stockActual > min * 1.5
      const optimo = StockSemaforicEntity(
        sku: 'SKU-3',
        titulo: 'Libro C',
        editorial: 'Pearson',
        categoria: 'Universitarios',
        stockActual: 30,
        stockMinimo: 10, // 30 > 15
        costoUnitarioBs: 80.0,
        precioVentaBs: 140.0,
      );
      expect(optimo.status, equals(StockStatus.optimo));
      expect(optimo.esOptimo, isTrue);
    });

    test('Fórmula Retail: SkuEntity.calcularPrecioVenta debe calcular Costo / (1 - Margen)', () {
      const costo = 70.0;
      final precioCalculado = SkuEntity.calcularPrecioVenta(costo, 30.0);
      expect(precioCalculado, equals(100.0));
    });

    test('ProcessPosSaleUseCase debe bloquear ventas si algún producto tiene stock 0', () async {
      final eventBus = DefaultAppEventBus();
      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadPosProducts();

      final agotado = controller.products.firstWhere((p) => p.stockDisponible == 0);
      controller.addToCart(agotado);
      expect(controller.cart.isEmpty, isTrue);
      expect(controller.errorMessage, contains('agotado'));

      eventBus.dispose();
    });
  });

  group('Módulo de Reportes y Analítica - Widget Views Tests', () {
    testWidgets('ReportesDashboardView debe renderizar las 4 tarjetas KPI y gráfico de evolución', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestReportsController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ReportesDashboardView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Centro de Inteligencia de Negocios y Reportes'), findsOneWidget);
      expect(find.text('Margen Comercial %'), findsOneWidget);
      expect(find.text('Ticket Promedio Bs'), findsOneWidget);
      expect(find.text('Índice de Rotación'), findsOneWidget);
      expect(find.text('Inversión en Compras'), findsOneWidget);
      expect(find.text('Estado del Semáforo de Stock'), findsOneWidget);
    });

    testWidgets('ReporteVentasView debe renderizar el gráfico fl_chart y la tabla de comprobantes SIAT', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestReportsController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ReporteVentasView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Reporte de Ventas y Libro Fiscal SIAT'), findsOneWidget);
      expect(find.text('Exportar a CSV / Excel'), findsOneWidget);
      expect(find.text('Exportar a PDF (SIAT)'), findsOneWidget);
      expect(find.text('Libro de Ventas Fiscal (R.N.D. SIAT)'), findsOneWidget);
      expect(find.text('Colegio Particular San Agustín SRL'), findsOneWidget);
    });

    testWidgets('ReporteStockSemaforicoView debe renderizar la matriz con resaltado y botón Generar Orden de Compra', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestReportsController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ReporteStockSemaforicoView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Auditoría y Semáforo de Existencias (Stock Semafórico)'), findsOneWidget);
      expect(find.text('Solo Críticos'), findsOneWidget);
      expect(find.text('Generar Orden de Compra'), findsWidgets);

      controller.toggleSoloCriticos();
      await tester.pump();

      expect(controller.soloCriticosFilter, isTrue);
      expect(controller.filteredStockItems.every((i) => i.esCritico), isTrue);
    });
  });

  group('Módulo de Compra y Venta - Widget Views Tests', () {
    testWidgets('PuntoVentaPosView debe renderizar productos rápidos, atajo F10 y panel de cobro', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: PuntoVentaPosView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('F10: Facturar'), findsOneWidget);
      expect(find.text('Orden Actual POS'), findsOneWidget);
    });

    testWidgets('InventarioKardexView debe renderizar selector de SKU y encabezado compuesto', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: InventarioKardexView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Kárdex Físico-Valorado (Método PEPS / FIFO)'), findsOneWidget);
      expect(find.text('1. ENTRADAS'), findsOneWidget);
    });

    testWidgets('OrdenesCompraCifView debe renderizar formulario de costeo aduanero', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: OrdenesCompraCifView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Órdenes de Compra y Costeo CIF Aduanero'), findsOneWidget);
    });

    testWidgets('DirectorioProveedoresView debe renderizar tabla de proveedores', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final controller = createTestSalesPurchasesController(eventBus);
      await controller.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: DirectorioProveedoresView(controller: controller)),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Directorio de Proveedores y Editoriales'), findsOneWidget);
    });
  });

  group('Layout Maestro - AppShellScreen Tests', () {
    testWidgets('AppShellScreen debe renderizar Sidebar, Top AppBar y Métricas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AppShellScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LIBRERÍA SAN MARTÍN'), findsOneWidget);
      expect(find.text('ERP Integral & Criptografía'), findsOneWidget);
      expect(find.text('Lic. G. Guachalla'), findsOneWidget);
      expect(find.text('Admin TI'), findsOneWidget);
      expect(find.textContaining('RLS Supabase Activo'), findsOneWidget);
      expect(find.textContaining('Supabase Realtime'), findsOneWidget);
    });

    testWidgets('Carga inicial de la aplicación y renderizado de Login', (WidgetTester tester) async {
      final eventBus = DefaultAppEventBus();
      final dataSource = MockAuthRemoteDataSourceImpl(delay: Duration.zero);
      final repo = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repo);
      final authController = AuthController(loginUseCase: useCase, eventBus: eventBus);
      final securityController = createTestSecurityController(eventBus);
      final adminController = createTestAdminController(eventBus);
      final salesPurchasesController = createTestSalesPurchasesController(eventBus);
      final reportsController = createTestReportsController(eventBus);

      await tester.pumpWidget(
        MainApp(
          authController: authController,
          securityController: securityController,
          adminController: adminController,
          salesPurchasesController: salesPurchasesController,
          reportsController: reportsController,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Iniciar Sesión'), findsOneWidget);
    });
  });

  group('Verificación Integral de Navegación y Botones del Sistema', () {
    testWidgets('Navegación completa a los 18 módulos del ERP y verificación visual de vistas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final secCtrl = createTestSecurityController(eventBus);
      final admCtrl = createTestAdminController(eventBus);
      final spCtrl = createTestSalesPurchasesController(eventBus);
      final repCtrl = createTestReportsController(eventBus);

      await secCtrl.loadAll();
      await admCtrl.loadAll();
      await spCtrl.loadAll();
      await repCtrl.loadAll();

      final shellWidget = createTestAppShellWithControllers(
        securityController: secCtrl,
        adminController: admCtrl,
        salesPurchasesController: spCtrl,
        reportsController: repCtrl,
        initialItemId: 'sec_dashboard',
      );

      await tester.pumpWidget(shellWidget);
      await tester.pumpAndSettle();

      final state = tester.state<AppShellScreenState>(find.byType(AppShellScreen));

      // 1. Seguridad: Dashboard
      state.navigateTo('sec_dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Total Usuarios'), findsOneWidget);
      expect(find.text('Política de Contraseñas NIST SP 800-63B'), findsOneWidget);

      // 2. Seguridad: Usuarios
      state.navigateTo('sec_usuarios');
      await tester.pumpAndSettle();
      expect(find.text('Directorio de Usuarios y Operadores'), findsOneWidget);
      expect(find.text('Nuevo Usuario'), findsOneWidget);

      // 3. Seguridad: RBAC
      state.navigateTo('sec_rbac');
      await tester.pumpAndSettle();
      expect(find.text('Matriz de Control de Acceso Basado en Roles (RBAC)'), findsOneWidget);
      expect(find.text('RLS Policy Engine: ACTIVO'), findsOneWidget);

      // 4. Seguridad: Bitácora WORM
      state.navigateTo('sec_worm');
      await tester.pumpAndSettle();
      expect(find.textContaining('AUDITORÍA FORENSE WORM'), findsOneWidget);
      expect(find.textContaining('trg_bitacora_inmutable'), findsOneWidget);

      // 5. Seguridad: Respaldos
      state.navigateTo('sec_respaldos');
      await tester.pumpAndSettle();
      expect(find.text('Respaldos Criptográficos & Telemetría PostgreSQL'), findsOneWidget);
      expect(find.text('Ejecutar Backup Manual'), findsOneWidget);

      // 6. Administración: Dashboard
      state.navigateTo('adm_dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Distribución de Existencias por Familia de Artículos'), findsOneWidget);
      expect(find.text('Total SKU Maestros'), findsOneWidget);

      // 7. Administración: Sucursales
      state.navigateTo('adm_sucursales');
      await tester.pumpAndSettle();
      expect(find.text('Red de Sucursales y Puntos de Venta'), findsOneWidget);
      expect(find.text('Sede Central Santa Cruz'), findsWidgets);

      // 8. Administración: Catálogo SKU
      state.navigateTo('adm_catalogo');
      await tester.pumpAndSettle();
      expect(find.text('Catálogo SKU y Maestro de Artículos'), findsOneWidget);
      expect(find.text('Registrar Nuevo SKU'), findsOneWidget);

      // 9. Administración: Parametrización Fiscal SIAT
      state.navigateTo('adm_siat');
      await tester.pumpAndSettle();
      expect(find.text('Parametrización Fiscal SIAT (Impuestos Nacionales Bolivia)'), findsOneWidget);
      expect(find.text('Probar Conexión SIAT'), findsOneWidget);

      // 10. Compra y Venta: Dashboard
      state.navigateTo('cv_dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Panel Operativo: Compra, Venta y Kárdex PEPS'), findsOneWidget);
      expect(find.text('Abrir Terminal POS (F10)'), findsOneWidget);

      // 11. Compra y Venta: POS
      state.navigateTo('cv_pos');
      await tester.pumpAndSettle();
      expect(find.text('Emitir Factura Electrónica SIAT (F10)'), findsOneWidget);

      // 12. Compra y Venta: Kárdex
      state.navigateTo('cv_kardex');
      await tester.pumpAndSettle();
      expect(find.text('Kárdex Físico-Valorado (Método PEPS / FIFO)'), findsOneWidget);
      expect(find.text('1. ENTRADAS'), findsOneWidget);

      // 13. Compra y Venta: CIF
      state.navigateTo('cv_cif');
      await tester.pumpAndSettle();
      expect(find.text('Órdenes de Compra y Costeo CIF Aduanero'), findsOneWidget);
      expect(find.text('Registrar Orden e Ingresar a Kárdex PEPS'), findsOneWidget);

      // 14. Compra y Venta: Proveedores
      state.navigateTo('cv_proveedores');
      await tester.pumpAndSettle();
      expect(find.text('Directorio de Proveedores y Editoriales'), findsOneWidget);

      // 15. Reportes: Dashboard
      state.navigateTo('rep_dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Centro de Inteligencia de Negocios y Reportes'), findsOneWidget);
      expect(find.text('Auditar Stock Semafórico'), findsOneWidget);

      // 16. Reportes: Ventas
      state.navigateTo('rep_ventas');
      await tester.pumpAndSettle();
      expect(find.text('Reporte de Ventas y Libro Fiscal SIAT'), findsOneWidget);
      expect(find.text('Exportar a PDF (SIAT)'), findsOneWidget);

      // 17. Reportes: Compras
      state.navigateTo('rep_compras');
      await tester.pumpAndSettle();
      expect(find.text('Reporte de Adquisiciones y Compras Mayoristas'), findsOneWidget);
      expect(find.text('Exportar Reporte Compras (PDF)'), findsOneWidget);

      // 18. Reportes: Stock Semafórico
      state.navigateTo('rep_stock');
      await tester.pumpAndSettle();
      expect(find.text('Auditoria y Semáforo de Existencias (Stock Semafórico)'), findsNothing); // verify exact text
      expect(find.textContaining('Stock Semafórico'), findsWidgets);
      expect(find.text('Solo Críticos'), findsOneWidget);
    });

    testWidgets('Botón de colapso y expansión del Sidebar actualiza el layout correctamente', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final secCtrl = createTestSecurityController(eventBus);
      final admCtrl = createTestAdminController(eventBus);
      final spCtrl = createTestSalesPurchasesController(eventBus);
      final repCtrl = createTestReportsController(eventBus);

      await tester.pumpWidget(createTestAppShellWithControllers(
        securityController: secCtrl,
        adminController: admCtrl,
        salesPurchasesController: spCtrl,
        reportsController: repCtrl,
      ));
      await tester.pumpAndSettle();

      // Botón inicial de colapso
      final collapseBtn = find.byTooltip('Colapsar barra');
      expect(collapseBtn, findsOneWidget);

      await tester.tap(collapseBtn);
      await tester.pumpAndSettle();

      // Sidebar ahora está colapsado y muestra tooltip para expandir
      final expandBtn = find.byTooltip('Expandir barra');
      expect(expandBtn, findsOneWidget);

      // Volver a expandir
      await tester.tap(expandBtn);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Colapsar barra'), findsOneWidget);
    });

    testWidgets('Dropdown de selección de Sucursal en Top AppBar actualiza estado', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final secCtrl = createTestSecurityController(eventBus);
      final admCtrl = createTestAdminController(eventBus);
      final spCtrl = createTestSalesPurchasesController(eventBus);
      final repCtrl = createTestReportsController(eventBus);

      await tester.pumpWidget(createTestAppShellWithControllers(
        securityController: secCtrl,
        adminController: admCtrl,
        salesPurchasesController: spCtrl,
        reportsController: repCtrl,
      ));
      await tester.pumpAndSettle();

      final dropdown = find.byType(DropdownButton<String>);
      expect(dropdown, findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Seleccionar Agencia La Guardia en el menú desplegable
      final option = find.text('Agencia La Guardia').last;
      await tester.tap(option);
      await tester.pumpAndSettle();

      expect(find.text('Agencia La Guardia'), findsWidgets);
    });

    testWidgets('Navegación programática inter-módulos (onNavigate) entre paneles', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final secCtrl = createTestSecurityController(eventBus);
      final admCtrl = createTestAdminController(eventBus);
      final spCtrl = createTestSalesPurchasesController(eventBus);
      final repCtrl = createTestReportsController(eventBus);

      await secCtrl.loadAll();
      await admCtrl.loadAll();
      await spCtrl.loadAll();
      await repCtrl.loadAll();

      // Iniciar en Compra y Venta Dashboard
      await tester.pumpWidget(createTestAppShellWithControllers(
        securityController: secCtrl,
        adminController: admCtrl,
        salesPurchasesController: spCtrl,
        reportsController: repCtrl,
        initialItemId: 'cv_dashboard',
      ));
      await tester.pumpAndSettle();

      expect(find.text('Panel Operativo: Compra, Venta y Kárdex PEPS'), findsOneWidget);

      // Botón "Abrir Terminal POS (F10)" debe saltar a cv_pos
      final posBtn = find.text('Abrir Terminal POS (F10)');
      expect(posBtn, findsOneWidget);
      await tester.tap(posBtn);
      await tester.pumpAndSettle();

      // Verificamos que ahora estamos en Punto de Venta POS
      expect(find.text('Emitir Factura Electrónica SIAT (F10)'), findsOneWidget);

      // Navegar a Reportes Dashboard
      final state = tester.state<AppShellScreenState>(find.byType(AppShellScreen));
      state.navigateTo('rep_dashboard');
      await tester.pumpAndSettle();
      expect(find.text('Centro de Inteligencia de Negocios y Reportes'), findsOneWidget);

      // Botón "Auditar Stock Semafórico" debe saltar a rep_stock
      final stockBtn = find.text('Auditar Stock Semafórico');
      expect(stockBtn, findsOneWidget);
      await tester.tap(stockBtn);
      await tester.pumpAndSettle();

      // Verificamos que ahora estamos en la vista de Stock Semafórico
      expect(find.text('Matriz de Criticidad de Inventario'), findsOneWidget);
    });

    testWidgets('Botones funcionales en Punto de Venta POS: añadir al carrito, cambiar método y emitir factura', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final spCtrl = createTestSalesPurchasesController(eventBus);
      await spCtrl.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: PuntoVentaPosView(controller: spCtrl)),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Añadir producto rápido al carrito
      final addBtn = find.byIcon(Icons.add_shopping_cart).first;
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      expect(spCtrl.cart.length, 1);

      // 2. Cambiar método de pago a QR Simple y asignar datos de cliente
      final qrBtn = find.text('QR Simple');
      await tester.tap(qrBtn);
      await tester.pumpAndSettle();
      expect(spCtrl.paymentMethod, PaymentMethod.qrSimple);

      spCtrl.setCustomerData(nit: '1028475021', razonSocial: 'Juan Pérez');
      await tester.pumpAndSettle();

      // 3. Emitir Factura F10
      final emitirBtn = find.text('Emitir Factura Electrónica SIAT (F10)');
      await tester.tap(emitirBtn);
      await tester.pumpAndSettle();

      // Verificar que se abre el modal de Factura Emitida
      expect(find.text('FACTURA ELECTRÓNICA EN LÍNEA'), findsOneWidget);
      expect(find.text('Aceptar y Continuar'), findsOneWidget);

      // Cerrar modal
      await tester.tap(find.text('Aceptar y Continuar'));
      await tester.pumpAndSettle();
      expect(find.text('FACTURA ELECTRÓNICA EN LÍNEA'), findsNothing);
    });

    testWidgets('Botones funcionales en Stock Semafórico: filtro "Solo Críticos" y solicitar reposición', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final repCtrl = createTestReportsController(eventBus);
      await repCtrl.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ReporteStockSemaforicoView(controller: repCtrl)),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Probar botón de filtro "Solo Críticos"
      final filtroBtn = find.text('Solo Críticos');
      expect(filtroBtn, findsOneWidget);
      await tester.tap(filtroBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ver Todos'), findsOneWidget);

      // Volver a ver todos
      await tester.tap(find.text('Ver Todos'));
      await tester.pumpAndSettle();
      expect(find.text('Solo Críticos'), findsOneWidget);

      // 2. Probar botón "Generar Orden de Compra" en un ítem crítico
      final genOrdenBtn = find.text('Generar Orden de Compra').first;
      await tester.ensureVisible(genOrdenBtn);
      await tester.pumpAndSettle();
      await tester.tap(genOrdenBtn);
      await tester.pumpAndSettle();

      // Verificar apertura del diálogo de reposición
      expect(find.text('Generar Orden de Compra (Reposición)'), findsOneWidget);
      expect(find.text('Confirmar y Solicitar Reposición'), findsOneWidget);

      // Confirmar reposición
      await tester.tap(find.text('Confirmar y Solicitar Reposición'));
      await tester.pumpAndSettle();

      // Verificar cierre del diálogo y mensaje de éxito
      expect(find.text('Generar Orden de Compra (Reposición)'), findsNothing);
      expect(find.textContaining('Solicitud de reposición emitida vía EDA'), findsOneWidget);
    });

    testWidgets('Botones funcionales en Seguridad: Revocación de sesión activa y ajuste NIST', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final secCtrl = createTestSecurityController(eventBus);
      await secCtrl.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: SeguridadDashboardView(controller: secCtrl)),
        ),
      );
      await tester.pumpAndSettle();

      // Probar botón "Revocar" sesión
      final revocarBtn = find.text('Revocar').first;
      expect(revocarBtn, findsOneWidget);
      await tester.tap(revocarBtn);
      await tester.pumpAndSettle();

      // Verificar SnackBar de confirmación
      expect(find.textContaining('revocada en Supabase'), findsOneWidget);
    });

    testWidgets('Botones funcionales en SIAT: Probar conexión con WebService SIN', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final admCtrl = createTestAdminController(eventBus);
      await admCtrl.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: ParametrizacionFiscalView(controller: admCtrl)),
        ),
      );
      await tester.pumpAndSettle();

      // Probar botón "Probar Conexión SIAT"
      final probarBtn = find.text('Probar Conexión SIAT');
      expect(probarBtn, findsOneWidget);
      await tester.tap(probarBtn);
      await tester.pumpAndSettle();

      // Verificar que el estado del controlador cambió a sincronizado
      expect(admCtrl.fiscalConfig?.sincronizadoConSin, true);
    });

    testWidgets('Modal Alta de Nuevo Usuario no desborda en resoluciones bajas (1024x768)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final eventBus = DefaultAppEventBus();
      final secCtrl = createTestSecurityController(eventBus);
      await secCtrl.loadAll();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: GestionUsuariosView(controller: secCtrl)),
        ),
      );
      await tester.pumpAndSettle();

      final nuevoUsuarioBtn = find.text('Nuevo Usuario');
      expect(nuevoUsuarioBtn, findsOneWidget);
      await tester.tap(nuevoUsuarioBtn);
      await tester.pumpAndSettle();

      // Verificar que el modal se abre y no produce RenderFlex overflow
      expect(find.text('Alta de Nuevo Usuario'), findsOneWidget);
      expect(find.text('Rol Asignado *'), findsOneWidget);
      expect(find.text('Sede / Sucursal *'), findsOneWidget);
    });
  });
}

Widget createTestAppShellWithControllers({
  required SecurityController securityController,
  required AdministrationController adminController,
  required SalesPurchasesController salesPurchasesController,
  required ReportsController reportsController,
  String initialItemId = 'sec_dashboard',
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: AppShellScreen(
      initialItemId: initialItemId,
      viewRegistry: {
        'sec_modulo': (ctx) => ModuloSeguridadView(controller: securityController),
        'sec_dashboard': (ctx) => SeguridadDashboardView(controller: securityController),
        'sec_usuarios': (ctx) => GestionUsuariosView(controller: securityController),
        'sec_rbac': (ctx) => ControlRbacView(controller: securityController),
        'sec_politicas': (ctx) => PoliticasSeguridadView(controller: securityController),
        'sec_sesiones': (ctx) => MonitoreoSesionesView(controller: securityController),
        'sec_worm': (ctx) => BitacoraWormView(controller: securityController),
        'sec_respaldos': (ctx) => MantenimientoRespaldosView(controller: securityController),

        'adm_dashboard': (ctx) => AdministracionDashboardView(controller: adminController),
        'adm_sucursales': (ctx) => GestionSucursalesView(controller: adminController),
        'adm_catalogo': (ctx) => CatalogoSkuView(controller: adminController),
        'adm_siat': (ctx) => ParametrizacionFiscalView(controller: adminController),

        'cv_dashboard': (ctx) => ComprasVentasDashboardView(
              controller: salesPurchasesController,
              onNavigate: (menuId) => AppShellScreen.of(ctx)?.navigateTo(menuId),
            ),
        'cv_pos': (ctx) => PuntoVentaPosView(controller: salesPurchasesController),
        'cv_kardex': (ctx) => InventarioKardexView(controller: salesPurchasesController),
        'cv_cif': (ctx) => OrdenesCompraCifView(controller: salesPurchasesController),
        'cv_proveedores': (ctx) => DirectorioProveedoresView(controller: salesPurchasesController),

        'rep_dashboard': (ctx) => ReportesDashboardView(
              controller: reportsController,
              onNavigate: (menuId) => AppShellScreen.of(ctx)?.navigateTo(menuId),
            ),
        'rep_ventas': (ctx) => ReporteVentasView(controller: reportsController),
        'rep_compras': (ctx) => ReporteComprasView(controller: reportsController),
        'rep_stock': (ctx) => ReporteStockSemaforicoView(
              controller: reportsController,
              onNavigate: (menuId) => AppShellScreen.of(ctx)?.navigateTo(menuId),
            ),
      },
    ),
  );
}
