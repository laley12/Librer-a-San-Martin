import 'dart:developer' as developer;
import 'package:flutter/material.dart';

import 'core/database/supabase_client.dart';
import 'core/events/event_bus.dart';
import 'core/layout/app_shell.dart';
import 'core/theme/app_theme.dart';

// Auth Feature
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/events/user_logged_in_event.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';

// Security Feature
import 'features/security/data/datasources/security_remote_data_source.dart';
import 'features/security/data/repositories/security_repository_impl.dart';
import 'features/security/domain/events/security_events.dart';
import 'features/security/domain/usecases/security_usecases.dart';
import 'features/security/presentation/controllers/security_controller.dart';
import 'features/security/presentation/pages/bitacora_worm_view.dart';
import 'features/security/presentation/pages/control_rbac_view.dart';
import 'features/security/presentation/pages/gestion_usuarios_view.dart';
import 'features/security/presentation/pages/mantenimiento_respaldos_view.dart';
import 'features/security/presentation/pages/seguridad_dashboard_view.dart';
import 'features/security/presentation/pages/politicas_seguridad_view.dart';
import 'features/security/presentation/pages/monitoreo_sesiones_view.dart';
import 'features/security/presentation/pages/modulo_seguridad_view.dart';

// Administration Feature
import 'features/administration/data/datasources/administration_remote_data_source.dart';
import 'features/administration/data/repositories/administration_repository_impl.dart';
import 'features/administration/domain/events/admin_events.dart';
import 'features/administration/domain/usecases/admin_usecases.dart';
import 'features/administration/presentation/controllers/administration_controller.dart';
import 'features/administration/presentation/pages/administracion_dashboard_view.dart';
import 'features/administration/presentation/pages/catalogo_sku_view.dart';
import 'features/administration/presentation/pages/gestion_sucursales_view.dart';
import 'features/administration/presentation/pages/parametrizacion_fiscal_view.dart';

// Sales, Purchases & Kárdex Feature
import 'features/sales_purchases/data/datasources/sales_purchases_remote_data_source.dart';
import 'features/sales_purchases/data/repositories/sales_purchases_repository_impl.dart';
import 'features/sales_purchases/domain/events/sales_purchases_events.dart';
import 'features/sales_purchases/domain/usecases/sales_purchases_usecases.dart';
import 'features/sales_purchases/presentation/controllers/sales_purchases_controller.dart';
import 'features/sales_purchases/presentation/pages/compras_ventas_dashboard_view.dart';
import 'features/sales_purchases/presentation/pages/directorio_proveedores_view.dart';
import 'features/sales_purchases/presentation/pages/inventario_kardex_view.dart';
import 'features/sales_purchases/presentation/pages/ordenes_compra_cif_view.dart';
import 'features/sales_purchases/presentation/pages/punto_venta_pos_view.dart';

// Reports & Analytics Feature
import 'features/reports/data/datasources/reports_remote_data_source.dart';
import 'features/reports/data/repositories/reports_repository_impl.dart';
import 'features/reports/domain/events/reports_events.dart';
import 'features/reports/domain/usecases/reports_usecases.dart';
import 'features/reports/presentation/controllers/reports_controller.dart';
import 'features/reports/presentation/pages/reporte_compras_view.dart';
import 'features/reports/presentation/pages/reporte_stock_semaforico_view.dart';
import 'features/reports/presentation/pages/reporte_ventas_view.dart';
import 'features/reports/presentation/pages/reportes_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. CONEXIÓN CLOUD SUPABASE (PostgreSQL + RLS + CDC/WSS)
  await SupabaseConfig.initialize();

  // 1. EVENT BUS GLOBAL (Arquitectura Orientada a Eventos - EDA)
  final eventBus = DefaultAppEventBus();

  // 2. OBSERVABILIDAD & LOGS DE EVENTOS DE DOMINIO
  eventBus.on<UserLoggedInEvent>().listen((event) {
    developer.log(
      '🔔 [EDA]: Usuario autenticado -> ${event.user.name} (${event.user.email})',
      name: 'Auth',
    );
  });

  eventBus.on<SessionRevokedEvent>().listen((event) {
    developer.log(
      '⚠️ [SEGURIDAD]: Sesión revocada. JTI: ${event.jti} | Motivo: ${event.motivo}',
      name: 'Security',
    );
  });

  eventBus.on<UserCreatedEvent>().listen((event) {
    developer.log(
      '✅ [AUDIT]: Nuevo usuario dado de alta: ${event.user.nombre} (${event.user.ciEnmascarado})',
      name: 'Security',
    );
  });

  eventBus.on<BackupCompletedEvent>().listen((event) {
    developer.log(
      '💾 [AUDIT]: Backup completado: ${event.backup.nombreArchivo} SHA-256: ${event.backup.checksumSha256}',
      name: 'Security',
    );
  });

  eventBus.on<SkuRegisteredEvent>().listen((event) {
    developer.log(
      '📦 [INVENTARIO]: Nuevo SKU registrado: ${event.sku.ean13} - ${event.sku.titulo}',
      name: 'Catalog',
    );
  });

  eventBus.on<FiscalConfigUpdatedEvent>().listen((event) {
    developer.log(
      '🏛️ [FISCAL SIAT]: Parámetros actualizados. NIT: ${event.config.nit} CUFD: ${event.config.cufdActual}',
      name: 'Fiscal',
    );
  });

  eventBus.on<SiatConnectionTestedEvent>().listen((event) {
    developer.log(
      '🌐 [FISCAL SIAT]: Conexión testeada. Resultado: ${event.exitoso ? "OK" : "ERROR"}',
      name: 'Fiscal',
    );
  });

  eventBus.on<SaleInvoicedEvent>().listen((event) {
    developer.log(
      '🧾 [POS SIAT F10]: Factura N° ${event.numeroFactura} emitido. Total: Bs ${event.total} | Cliente: ${event.razonSocial}',
      name: 'POS',
    );
  });

  eventBus.on<CifOrderRegisteredEvent>().listen((event) {
    developer.log(
      '🚢 [COMPRAS CIF]: Orden ${event.codigoOrden} registrada. SKU: ${event.sku} | Cant: ${event.cantidad}',
      name: 'Purchases',
    );
  });

  eventBus.on<StockAlertLowEvent>().listen((event) {
    developer.log(
      '⚠️ [STOCK ALERTA]: SKU ${event.sku} ("${event.titulo}") tiene stock crítico o agotado: ${event.stockRestante} un.',
      name: 'Inventory',
    );
  });

  eventBus.on<StockReplenishmentRequestedEvent>().listen((event) {
    developer.log(
      '🚨 [REPOSICIÓN SEMAFÓRICA]: Solicitada orden de compra para "${event.titulo}" (${event.sku}) - Cantidad: ${event.cantidadSugerida} un.',
      name: 'Reports',
    );
  });

  eventBus.on<ReportExportedEvent>().listen((event) {
    developer.log(
      '📄 [REPORTES EXPORT]: ${event.tipoReporte} exportado en formato ${event.formato} (${event.totalRegistros} filas)',
      name: 'Reports',
    );
  });

  // 3. COMPOSITION ROOT - AUTH FEATURE
  final authRemoteDataSource = MockAuthRemoteDataSourceImpl();
  final authRepository = AuthRepositoryImpl(remoteDataSource: authRemoteDataSource);
  final loginUseCase = LoginUseCase(authRepository);
  final authController = AuthController(
    loginUseCase: loginUseCase,
    eventBus: eventBus,
  );

  // 4. COMPOSITION ROOT - SECURITY & AUDIT FEATURE
  final securityDataSource = MockSecurityRemoteDataSourceImpl();
  final securityRepository = SecurityRepositoryImpl(remoteDataSource: securityDataSource);
  final securityController = SecurityController(
    getSecurityKpisUseCase: GetSecurityKpisUseCase(securityRepository),
    getActiveSessionsUseCase: GetActiveSessionsUseCase(securityRepository),
    revokeSessionUseCase: RevokeSessionUseCase(securityRepository),
    getUsersUseCase: GetUsersUseCase(securityRepository),
    createUserUseCase: CreateUserUseCase(securityRepository),
    toggleUserStatusUseCase: ToggleUserStatusUseCase(securityRepository),
    softDeleteUserUseCase: SoftDeleteUserUseCase(securityRepository),
    getRbacMatrixUseCase: GetRbacMatrixUseCase(securityRepository),
    updateRbacPermissionUseCase: UpdateRbacPermissionUseCase(securityRepository),
    getWormLogsUseCase: GetWormLogsUseCase(securityRepository),
    getBackupsUseCase: GetBackupsUseCase(securityRepository),
    triggerManualBackupUseCase: TriggerManualBackupUseCase(securityRepository),
    eventBus: eventBus,
  );
  securityController.loadAll();

  // 5. COMPOSITION ROOT - ADMINISTRATION & SIAT FEATURE
  final adminDataSource = MockAdministrationRemoteDataSourceImpl();
  final adminRepository = AdministrationRepositoryImpl(remoteDataSource: adminDataSource);
  final adminController = AdministrationController(
    getAdminKpisUseCase: GetAdminKpisUseCase(adminRepository),
    getBranchesUseCase: GetBranchesUseCase(adminRepository),
    createBranchUseCase: CreateBranchUseCase(adminRepository),
    updateBranchUseCase: UpdateBranchUseCase(adminRepository),
    deactivateBranchUseCase: DeactivateBranchUseCase(adminRepository),
    reactivateBranchUseCase: ReactivateBranchUseCase(adminRepository),
    getSkusUseCase: GetSkusUseCase(adminRepository),
    createSkuUseCase: CreateSkuUseCase(adminRepository),
    getFiscalConfigUseCase: GetFiscalConfigUseCase(adminRepository),
    updateFiscalConfigUseCase: UpdateFiscalConfigUseCase(adminRepository),
    testSiatConnectionUseCase: TestSiatConnectionUseCase(adminRepository),
    eventBus: eventBus,
  );
  adminController.loadAll();

  // 6. COMPOSITION ROOT - SALES, PURCHASES & KÁRDEX FEATURE
  final salesPurchasesDataSource = MockSalesPurchasesRemoteDataSourceImpl();
  final salesPurchasesRepository = SalesPurchasesRepositoryImpl(salesPurchasesDataSource);
  final salesPurchasesController = SalesPurchasesController(
    getPosProductsUseCase: GetPosProductsUseCase(salesPurchasesRepository),
    searchProductUseCase: SearchProductUseCase(salesPurchasesRepository),
    searchCustomerByNitUseCase: SearchCustomerByNitUseCase(salesPurchasesRepository),
    processPosSaleUseCase: ProcessPosSaleUseCase(salesPurchasesRepository, eventBus),
    getKardexBySkuUseCase: GetKardexBySkuUseCase(salesPurchasesRepository),
    getCifOrdersUseCase: GetCifOrdersUseCase(salesPurchasesRepository),
    registerCifOrderUseCase: RegisterCifOrderUseCase(salesPurchasesRepository, eventBus),
    getSuppliersUseCase: GetSuppliersUseCase(salesPurchasesRepository),
    getSalesPurchasesKpiUseCase: GetSalesPurchasesKpiUseCase(salesPurchasesRepository),
    eventBus: eventBus,
  );
  salesPurchasesController.loadAll();

  // 7. COMPOSITION ROOT - REPORTS & ANALYTICS FEATURE
  final reportsDataSource = MockReportsRemoteDataSourceImpl();
  final reportsRepository = ReportsRepositoryImpl(reportsDataSource);
  final reportsController = ReportsController(
    getReportsKpisUseCase: GetReportsKpisUseCase(reportsRepository),
    getDailySalesEvolutionUseCase: GetDailySalesEvolutionUseCase(reportsRepository),
    getSiatSalesVouchersUseCase: GetSiatSalesVouchersUseCase(reportsRepository),
    getStockSemaforicoUseCase: GetStockSemaforicoUseCase(reportsRepository),
    requestStockReplenishmentUseCase: RequestStockReplenishmentUseCase(eventBus),
    exportReportUseCase: ExportReportUseCase(eventBus),
    eventBus: eventBus,
  );
  reportsController.loadAll();

  runApp(
    MainApp(
      authController: authController,
      securityController: securityController,
      adminController: adminController,
      salesPurchasesController: salesPurchasesController,
      reportsController: reportsController,
    ),
  );
}

class MainApp extends StatelessWidget {
  final AuthController authController;
  final SecurityController securityController;
  final AdministrationController adminController;
  final SalesPurchasesController salesPurchasesController;
  final ReportsController reportsController;

  const MainApp({
    super.key,
    required this.authController,
    required this.securityController,
    required this.adminController,
    required this.salesPurchasesController,
    required this.reportsController,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Librería San Martín - ERP Integral & Criptografía',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: ListenableBuilder(
        listenable: authController,
        builder: (context, _) {
          if (authController.status == AuthStatus.authenticated) {
            return AppShellScreen(
              initialItemId: 'rep_dashboard',
              viewRegistry: {
                // Seguridad y Accesos (Módulo Integral + 6 Submódulos + Dashboard)
                'sec_modulo': (ctx) => ModuloSeguridadView(controller: securityController),
                'sec_dashboard': (ctx) => SeguridadDashboardView(controller: securityController),
                'sec_usuarios': (ctx) => GestionUsuariosView(controller: securityController),
                'sec_rbac': (ctx) => ControlRbacView(controller: securityController),
                'sec_politicas': (ctx) => PoliticasSeguridadView(controller: securityController),
                'sec_sesiones': (ctx) => MonitoreoSesionesView(controller: securityController),
                'sec_worm': (ctx) => BitacoraWormView(controller: securityController),
                'sec_respaldos': (ctx) => MantenimientoRespaldosView(controller: securityController),

                // Administración y SIAT
                'adm_dashboard': (ctx) => AdministracionDashboardView(controller: adminController),
                'adm_sucursales': (ctx) => GestionSucursalesView(controller: adminController),
                'adm_catalogo': (ctx) => CatalogoSkuView(controller: adminController),
                'adm_siat': (ctx) => ParametrizacionFiscalView(controller: adminController),

                // Compra y Venta (POS F10, Kárdex PEPS, CIF, Proveedores)
                'cv_dashboard': (ctx) => ComprasVentasDashboardView(
                      controller: salesPurchasesController,
                      onNavigate: (menuId) => AppShellScreen.of(ctx)?.navigateTo(menuId),
                    ),
                'cv_pos': (ctx) => PuntoVentaPosView(controller: salesPurchasesController),
                'cv_kardex': (ctx) => InventarioKardexView(controller: salesPurchasesController),
                'cv_cif': (ctx) => OrdenesCompraCifView(controller: salesPurchasesController),
                'cv_proveedores': (ctx) => DirectorioProveedoresView(controller: salesPurchasesController),

                // Reportes y Analítica
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
            );
          }
          return LoginPage(controller: authController);
        },
      ),
    );
  }
}
