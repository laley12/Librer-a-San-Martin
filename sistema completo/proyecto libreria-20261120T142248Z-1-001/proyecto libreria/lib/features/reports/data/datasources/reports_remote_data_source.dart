import '../../domain/entities/reports_entities.dart';

/// Contrato para la fuente de datos remota de Reportes
abstract class ReportsRemoteDataSource {
  Future<ReportsKpiEntity> getReportsKpis({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<DailySalesDataPoint>> getDailySalesEvolution({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<SiatSalesVoucherEntity>> getSiatSalesVouchers({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<StockSemaforicEntity>> getStockSemaforico();
}

/// Implementación simulada con latencia configurable
class MockReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final Duration delay;

  MockReportsRemoteDataSourceImpl({this.delay = const Duration(milliseconds: 300)});

  // Datos de inventario semafórico
  final List<StockSemaforicEntity> _stockItems = [
    // 🔴 CRÍTICO / AGOTADO (stock <= min)
    const StockSemaforicEntity(
      sku: 'SKU-AGOT-007',
      titulo: 'Atlas Geográfico de Bolivia (Edición Lujo)',
      editorial: 'Gisbert',
      categoria: 'Literatura y Ficción',
      stockActual: 0,
      stockMinimo: 10,
      costoUnitarioBs: 140.00,
      precioVentaBs: 240.00,
    ),
    const StockSemaforicEntity(
      sku: 'SKU-ESC-006',
      titulo: 'Lenguaje y Comunicación 3ro Primaria',
      editorial: 'Don Bosco',
      categoria: 'Textos Escolares',
      stockActual: 3,
      stockMinimo: 15,
      costoUnitarioBs: 65.00,
      precioVentaBs: 115.00,
    ),
    const StockSemaforicEntity(
      sku: 'SKU-INF-004',
      titulo: 'Applied Cryptography & Security Protocols',
      editorial: 'McGraw-Hill',
      categoria: 'Criptografía e Informática',
      stockActual: 8,
      stockMinimo: 10,
      costoUnitarioBs: 210.00,
      precioVentaBs: 350.00,
    ),

    // 🟡 ATENCIÓN / REORDEN (stock <= min * 1.5)
    const StockSemaforicEntity(
      sku: 'SKU-UNI-003',
      titulo: 'Física Universitaria Vol. 1 - Sears Zemansky',
      editorial: 'Pearson',
      categoria: 'Textos Universitarios',
      stockActual: 12,
      stockMinimo: 10, // 12 <= 15
      costoUnitarioBs: 185.00,
      precioVentaBs: 310.00,
    ),
    const StockSemaforicEntity(
      sku: 'SKU-MAT-002',
      titulo: 'Matemática Moderna 5to Secundaria',
      editorial: 'Santillana',
      categoria: 'Textos Escolares',
      stockActual: 32,
      stockMinimo: 25, // 32 <= 38
      costoUnitarioBs: 105.00,
      precioVentaBs: 180.00,
    ),

    // 🟢 ÓPTIMO / NORMAL (stock > min * 1.5)
    const StockSemaforicEntity(
      sku: 'SKU-LIT-001',
      titulo: 'Cien Años de Soledad - G. García Márquez',
      editorial: 'Norma',
      categoria: 'Literatura y Ficción',
      stockActual: 45,
      stockMinimo: 15, // 45 > 23
      costoUnitarioBs: 68.00,
      precioVentaBs: 125.00,
    ),
    const StockSemaforicEntity(
      sku: 'SKU-PAP-005',
      titulo: 'Cuaderno Espiral Tamaño Carta 100 Hojas',
      editorial: 'Papelería y Oficina',
      categoria: 'Papelería y Oficina',
      stockActual: 140,
      stockMinimo: 30, // 140 > 45
      costoUnitarioBs: 9.50,
      precioVentaBs: 18.50,
    ),
  ];

  @override
  Future<ReportsKpiEntity> getReportsKpis({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    return const ReportsKpiEntity(
      margenComercialPorcentaje: 38.4,
      ticketPromedioBs: 186.50,
      indiceRotacion: 4.2,
      inversionComprasBs: 84320.00,
      totalVentasPeriodoBs: 36710.00,
      totalComprobantesEmitidos: 195,
    );
  }

  @override
  Future<List<DailySalesDataPoint>> getDailySalesEvolution({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    final now = DateTime.now();
    return [
      DailySalesDataPoint(
        fecha: now.subtract(const Duration(days: 6)),
        diaLabel: 'Lun',
        totalVentasBs: 3450.00,
        totalFacturas: 18,
      ),
      DailySalesDataPoint(
        fecha: now.subtract(const Duration(days: 5)),
        diaLabel: 'Mar',
        totalVentasBs: 4120.00,
        totalFacturas: 22,
      ),
      DailySalesDataPoint(
        fecha: now.subtract(const Duration(days: 4)),
        diaLabel: 'Mié',
        totalVentasBs: 3890.00,
        totalFacturas: 19,
      ),
      DailySalesDataPoint(
        fecha: now.subtract(const Duration(days: 3)),
        diaLabel: 'Jue',
        totalVentasBs: 5240.00,
        totalFacturas: 28,
      ),
      DailySalesDataPoint(
        fecha: now.subtract(const Duration(days: 2)),
        diaLabel: 'Vie',
        totalVentasBs: 6780.00,
        totalFacturas: 36,
      ),
      DailySalesDataPoint(
        fecha: now.subtract(const Duration(days: 1)),
        diaLabel: 'Sáb',
        totalVentasBs: 8920.00,
        totalFacturas: 48,
      ),
      DailySalesDataPoint(
        fecha: now,
        diaLabel: 'Dom',
        totalVentasBs: 4310.00,
        totalFacturas: 24,
      ),
    ];
  }

  @override
  Future<List<SiatSalesVoucherEntity>> getSiatSalesVouchers({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    final now = DateTime.now();
    return [
      SiatSalesVoucherEntity(
        numeroFactura: 812,
        cuf: 'CUF-202611-F812-7A9B3F4E1D2C',
        fecha: now.subtract(const Duration(days: 5, hours: 3)),
        nitCliente: '1020304050',
        razonSocial: 'Colegio Particular San Agustín SRL',
        montoTotalBs: 2700.00,
        debitoFiscalIvaBs: 351.00, // 13%
        codigoControl: '9A-B2-7C-D4',
        estado: 'VALIDADA EN LÍNEA',
      ),
      SiatSalesVoucherEntity(
        numeroFactura: 813,
        cuf: 'CUF-202611-F813-8C1D4E2F3A4B',
        fecha: now.subtract(const Duration(days: 4, hours: 2)),
        nitCliente: '4871923',
        razonSocial: 'Lic. Gustavo Guachalla',
        montoTotalBs: 530.00,
        debitoFiscalIvaBs: 68.90,
        codigoControl: '4E-F3-A4-B2',
        estado: 'VALIDADA EN LÍNEA',
      ),
      SiatSalesVoucherEntity(
        numeroFactura: 814,
        cuf: 'CUF-202611-F814-1D2C3B4A5E6F',
        fecha: now.subtract(const Duration(days: 3, hours: 5)),
        nitCliente: '3049581019',
        razonSocial: 'Universidad Privada de Santa Cruz (UPSA)',
        montoTotalBs: 3720.00,
        debitoFiscalIvaBs: 483.60,
        codigoControl: '5E-6F-1D-2C',
        estado: 'VALIDADA EN LÍNEA',
      ),
      SiatSalesVoucherEntity(
        numeroFactura: 815,
        cuf: 'CUF-202611-F815-3B4A5E6F7A8B',
        fecha: now.subtract(const Duration(days: 2, hours: 1)),
        nitCliente: '12345678',
        razonSocial: 'Maria Rene Justiniano Vaca',
        montoTotalBs: 250.00,
        debitoFiscalIvaBs: 32.50,
        codigoControl: '7A-8B-3B-4A',
        estado: 'VALIDADA EN LÍNEA',
      ),
      SiatSalesVoucherEntity(
        numeroFactura: 816,
        cuf: 'CUF-202611-F816-5E6F7A8B9C0D',
        fecha: now.subtract(const Duration(hours: 4)),
        nitCliente: '0',
        razonSocial: 'Control Tributario / Venta Menor',
        montoTotalBs: 185.00,
        debitoFiscalIvaBs: 24.05,
        codigoControl: '9C-0D-5E-6F',
        estado: 'VALIDADA EN LÍNEA',
      ),
    ];
  }

  @override
  Future<List<StockSemaforicEntity>> getStockSemaforico() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return List.unmodifiable(_stockItems);
  }
}
