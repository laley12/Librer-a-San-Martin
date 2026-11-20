import '../../domain/entities/sales_purchases_entities.dart';

/// Contrato para la fuente de datos remota de Compra y Venta
abstract class SalesPurchasesRemoteDataSource {
  Future<List<PosProductEntity>> getPosProducts();
  Future<List<PosProductEntity>> searchProduct(String query);
  Future<CustomerEntity?> searchCustomerByNit(String nitCi);
  Future<InvoiceSaleEntity> emitirFacturaPos(InvoiceSaleEntity invoice);
  Future<List<KardexEntryEntity>> getKardexBySku(String sku);
  Future<List<CifOrderEntity>> getCifOrders();
  Future<CifOrderEntity> registrarOrdenCif(CifOrderEntity order);
  Future<List<SupplierEntity>> getSuppliers();
  Future<SalesPurchasesKpiEntity> getKpis();
}

/// Implementación en memoria / simulada con delay configurable
class MockSalesPurchasesRemoteDataSourceImpl implements SalesPurchasesRemoteDataSource {
  final Duration delay;

  MockSalesPurchasesRemoteDataSourceImpl({this.delay = const Duration(milliseconds: 300)});

  // Catálogo de productos POS
  final List<PosProductEntity> _products = [
    const PosProductEntity(
      sku: 'SKU-LIT-001',
      titulo: 'Cien Años de Soledad - G. García Márquez',
      editorial: 'Norma',
      categoria: 'Literatura y Ficción',
      precioVenta: 125.00,
      stockDisponible: 45,
      codigoBarra: '9789580464228',
    ),
    const PosProductEntity(
      sku: 'SKU-MAT-002',
      titulo: 'Matemática Moderna 5to Secundaria',
      editorial: 'Santillana',
      categoria: 'Textos Escolares',
      precioVenta: 180.00,
      stockDisponible: 32,
      codigoBarra: '9789990518231',
    ),
    const PosProductEntity(
      sku: 'SKU-UNI-003',
      titulo: 'Física Universitaria Vol. 1 - Sears Zemansky',
      editorial: 'Pearson',
      categoria: 'Textos Universitarios',
      precioVenta: 310.00,
      stockDisponible: 12,
      codigoBarra: '9786073221900',
    ),
    const PosProductEntity(
      sku: 'SKU-INF-004',
      titulo: 'Applied Cryptography & Security Protocols',
      editorial: 'McGraw-Hill',
      categoria: 'Criptografía e Informática',
      precioVenta: 350.00,
      stockDisponible: 8,
      codigoBarra: '9780471117094',
    ),
    const PosProductEntity(
      sku: 'SKU-PAP-005',
      titulo: 'Cuaderno Espiral Tamaño Carta 100 Hojas',
      editorial: 'Papelería y Oficina',
      categoria: 'Papelería y Oficina',
      precioVenta: 18.50,
      stockDisponible: 140,
      codigoBarra: '7771234000055',
    ),
    const PosProductEntity(
      sku: 'SKU-ESC-006',
      titulo: 'Lenguaje y Comunicación 3ro Primaria',
      editorial: 'Don Bosco',
      categoria: 'Textos Escolares',
      precioVenta: 115.00,
      stockDisponible: 3, // Stock Crítico
      codigoBarra: '9789990598813',
    ),
    const PosProductEntity(
      sku: 'SKU-AGOT-007',
      titulo: 'Atlas Geográfico de Bolivia (Edición Lujo)',
      editorial: 'Gisbert',
      categoria: 'Literatura y Ficción',
      precioVenta: 240.00,
      stockDisponible: 0, // Stock Agotado (para verificar bloqueo estricto)
      codigoBarra: '9789990520005',
    ),
  ];

  // Base de datos de clientes conocidos
  final List<CustomerEntity> _customers = [
    const CustomerEntity(
      nitCi: '0',
      razonSocial: 'Control Tributario / Venta Menor',
    ),
    const CustomerEntity(
      nitCi: '4871923',
      razonSocial: 'Gustavo Guachalla',
      email: 'lic.guachalla@sanmartin.bo',
      telefono: '76012345',
    ),
    const CustomerEntity(
      nitCi: '1020304050',
      razonSocial: 'Colegio Particular San Agustín SRL',
      email: 'administracion@sanagustin.edu.bo',
      telefono: '33445566',
    ),
    const CustomerEntity(
      nitCi: '3049581019',
      razonSocial: 'Universidad Privada de Santa Cruz (UPSA)',
      email: 'compras@upsa.edu.bo',
      telefono: '3464000',
    ),
    const CustomerEntity(
      nitCi: '12345678',
      razonSocial: 'Maria Rene Justiniano Vaca',
      email: 'mjustiniano@gmail.com',
      telefono: '70899221',
    ),
  ];

  // Directorio de Proveedores
  final List<SupplierEntity> _suppliers = [
    const SupplierEntity(
      id: 'SUP-001',
      nit: '1028374021',
      razonSocial: 'Santillana de Ediciones S.A. (Bolivia)',
      contacto: 'Lic. Fernando Morales (Gerente de Cuentas)',
      telefono: '+591 3 342-8800',
      email: 'pedidos.bolivia@santillana.com',
      pais: 'Bolivia',
      categorias: ['Textos Escolares', 'Pedagogía'],
      plazoCreditoDias: 60,
      estado: 'Activo',
    ),
    const SupplierEntity(
      id: 'SUP-002',
      nit: '1019283015',
      razonSocial: 'Editorial Gisbert y Cía. S.A.',
      contacto: 'Ing. Carmen Gisbert',
      telefono: '+591 2 240-8000',
      email: 'ventas@editorialgisbert.com',
      pais: 'Bolivia',
      categorias: ['Literatura y Ficción', 'Historia Nacional', 'Atlas'],
      plazoCreditoDias: 45,
      estado: 'Activo',
    ),
    const SupplierEntity(
      id: 'SUP-003',
      nit: '1004859029',
      razonSocial: 'Editorial Don Bosco Bolivia',
      contacto: 'Hno. Javier Valdivia',
      telefono: '+591 3 336-1212',
      email: 'distribucion@editorialdonbosco.bo',
      pais: 'Bolivia',
      categorias: ['Textos Escolares', 'Valores y Religión'],
      plazoCreditoDias: 30,
      estado: 'Activo',
    ),
    const SupplierEntity(
      id: 'SUP-004',
      nit: 'EX-99201920',
      razonSocial: 'McGraw-Hill Interamericana de México S.A.',
      contacto: 'Lic. Rodrigo Quintana (Comercio Exterior)',
      telefono: '+52 55 5281-9000',
      email: 'cif.latam@mheducation.com',
      pais: 'México',
      categorias: ['Textos Universitarios', 'Criptografía e Informática'],
      plazoCreditoDias: 90,
      estado: 'Activo',
    ),
    const SupplierEntity(
      id: 'SUP-005',
      nit: '1015542028',
      razonSocial: 'Industrias Papeleras del Oriente SRL',
      contacto: 'Ramiro Justiniano',
      telefono: '+591 3 355-7788',
      email: 'ventas@papeleradeloriente.com',
      pais: 'Bolivia',
      categorias: ['Papelería y Oficina', 'Material Didáctico'],
      plazoCreditoDias: 30,
      estado: 'Activo',
    ),
  ];

  // Órdenes CIF registradas
  final List<CifOrderEntity> _cifOrders = [
    CifOrderEntity(
      id: 'ORD-2026-001',
      codigoOrden: 'CIF-2026-0182',
      proveedor: 'Santillana de Ediciones S.A.',
      sku: 'SKU-MAT-002',
      skuTitulo: 'Matemática Moderna 5to Secundaria',
      cantidadUnidades: 500,
      fobTotalUsd: 5500.00,
      fleteUsd: 650.00,
      seguroUsd: 120.00,
      tipoCambioBob: 6.96,
      gaPorcentaje: 0.10,
      gastosDespachoBob: 1850.00,
      fechaRegistro: DateTime.now().subtract(const Duration(days: 12)),
      estado: 'Nacionalizado en Bodega Central',
    ),
    CifOrderEntity(
      id: 'ORD-2026-002',
      codigoOrden: 'CIF-2026-0240',
      proveedor: 'McGraw-Hill Interamericana de México',
      sku: 'SKU-INF-004',
      skuTitulo: 'Applied Cryptography & Security Protocols',
      cantidadUnidades: 150,
      fobTotalUsd: 3600.00,
      fleteUsd: 480.00,
      seguroUsd: 90.00,
      tipoCambioBob: 6.96,
      gaPorcentaje: 0.10,
      gastosDespachoBob: 1200.00,
      fechaRegistro: DateTime.now().subtract(const Duration(days: 5)),
      estado: 'Nacionalizado en Bodega Central',
    ),
  ];

  // Base Kárdex PEPS / FIFO
  final Map<String, List<KardexEntryEntity>> _kardexDb = {
    'SKU-MAT-002': [
      KardexEntryEntity(
        id: 'KDX-001',
        sku: 'SKU-MAT-002',
        fecha: DateTime.now().subtract(const Duration(days: 40)),
        comprobante: 'INV-INI-2026',
        detalle: 'Inventario Físico Inicial Gestión 2026',
        tipo: KardexEntryType.saldoInicial,
        cantidadEntrada: 40,
        costoUnitarioEntrada: 105.00,
        totalEntrada: 4200.00,
        cantidadSalida: 0,
        costoUnitarioPepsSalida: 0.0,
        totalSalida: 0.0,
        saldoCantidad: 40,
        costoPromedioSaldo: 105.00,
        saldoValorTotal: 4200.00,
      ),
      KardexEntryEntity(
        id: 'KDX-002',
        sku: 'SKU-MAT-002',
        fecha: DateTime.now().subtract(const Duration(days: 12)),
        comprobante: 'DIM-0182-A',
        detalle: 'Ingreso Nacionalización CIF Arica-Santa Cruz',
        tipo: KardexEntryType.compraCif,
        cantidadEntrada: 20,
        costoUnitarioEntrada: 98.40,
        totalEntrada: 1968.00,
        cantidadSalida: 0,
        costoUnitarioPepsSalida: 0.0,
        totalSalida: 0.0,
        saldoCantidad: 60,
        costoPromedioSaldo: 102.80,
        saldoValorTotal: 6168.00,
      ),
      KardexEntryEntity(
        id: 'KDX-003',
        sku: 'SKU-MAT-002',
        fecha: DateTime.now().subtract(const Duration(days: 6)),
        comprobante: 'FAC-00812',
        detalle: 'Venta Mostrador POS (Lote Antiguo PEPS)',
        tipo: KardexEntryType.ventaPos,
        cantidadEntrada: 0,
        costoUnitarioEntrada: 0.0,
        totalEntrada: 0.0,
        cantidadSalida: 15,
        costoUnitarioPepsSalida: 105.00, // Valorado estrictamente al costo del lote inicial (105.00)
        totalSalida: 1575.00,
        saldoCantidad: 45,
        costoPromedioSaldo: 102.07,
        saldoValorTotal: 4593.00,
      ),
      KardexEntryEntity(
        id: 'KDX-004',
        sku: 'SKU-MAT-002',
        fecha: DateTime.now().subtract(const Duration(days: 1)),
        comprobante: 'FAC-00940',
        detalle: 'Venta Institucional Colegio San Agustín (PEPS)',
        tipo: KardexEntryType.ventaPos,
        cantidadEntrada: 0,
        costoUnitarioEntrada: 0.0,
        totalEntrada: 0.0,
        cantidadSalida: 13,
        costoUnitarioPepsSalida: 105.00,
        totalSalida: 1365.00,
        saldoCantidad: 32,
        costoPromedioSaldo: 100.88,
        saldoValorTotal: 3228.00,
      ),
    ],
    'SKU-LIT-001': [
      KardexEntryEntity(
        id: 'KDX-101',
        sku: 'SKU-LIT-001',
        fecha: DateTime.now().subtract(const Duration(days: 30)),
        comprobante: 'INV-INI-2026',
        detalle: 'Inventario Físico Inicial Gestión 2026',
        tipo: KardexEntryType.saldoInicial,
        cantidadEntrada: 50,
        costoUnitarioEntrada: 68.00,
        totalEntrada: 3400.00,
        cantidadSalida: 0,
        costoUnitarioPepsSalida: 0.0,
        totalSalida: 0.0,
        saldoCantidad: 50,
        costoPromedioSaldo: 68.00,
        saldoValorTotal: 3400.00,
      ),
      KardexEntryEntity(
        id: 'KDX-102',
        sku: 'SKU-LIT-001',
        fecha: DateTime.now().subtract(const Duration(days: 2)),
        comprobante: 'FAC-00922',
        detalle: 'Venta POS Mostrador (PEPS)',
        tipo: KardexEntryType.ventaPos,
        cantidadEntrada: 0,
        costoUnitarioEntrada: 0.0,
        totalEntrada: 0.0,
        cantidadSalida: 5,
        costoUnitarioPepsSalida: 68.00,
        totalSalida: 340.00,
        saldoCantidad: 45,
        costoPromedioSaldo: 68.00,
        saldoValorTotal: 3060.00,
      ),
    ],
  };

  final List<InvoiceSaleEntity> _invoices = [];

  @override
  Future<List<PosProductEntity>> getPosProducts() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return List.unmodifiable(_products);
  }

  @override
  Future<List<PosProductEntity>> searchProduct(String query) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return List.unmodifiable(_products);

    return _products.where((p) {
      return p.codigoBarra.contains(clean) ||
          p.sku.toLowerCase().contains(clean) ||
          p.titulo.toLowerCase().contains(clean) ||
          p.editorial.toLowerCase().contains(clean) ||
          p.categoria.toLowerCase().contains(clean);
    }).toList();
  }

  @override
  Future<CustomerEntity?> searchCustomerByNit(String nitCi) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final clean = nitCi.trim();
    final match = _customers.where((c) => c.nitCi == clean);
    return match.isNotEmpty ? match.first : null;
  }

  @override
  Future<InvoiceSaleEntity> emitirFacturaPos(InvoiceSaleEntity invoice) async {
    if (delay > Duration.zero) await Future.delayed(delay);

    // Descontar inventario localmente
    for (final item in invoice.items) {
      final index = _products.indexWhere((p) => p.sku == item.product.sku);
      if (index != -1) {
        final current = _products[index];
        final nuevoStock = (current.stockDisponible - item.cantidad).clamp(0, 99999);
        _products[index] = current.copyWith(stockDisponible: nuevoStock);
      }
    }

    _invoices.add(invoice);
    return invoice;
  }

  @override
  Future<List<KardexEntryEntity>> getKardexBySku(String sku) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    if (_kardexDb.containsKey(sku)) {
      return List.unmodifiable(_kardexDb[sku]!);
    }
    // Si no tiene registros específicos, generar registro inicial por defecto
    return [
      KardexEntryEntity(
        id: 'KDX-GEN-${DateTime.now().millisecondsSinceEpoch}',
        sku: sku,
        fecha: DateTime.now().subtract(const Duration(days: 15)),
        comprobante: 'INV-INI-2026',
        detalle: 'Inventario Inicial de Apertura',
        tipo: KardexEntryType.saldoInicial,
        cantidadEntrada: 15,
        costoUnitarioEntrada: 90.00,
        totalEntrada: 1350.00,
        cantidadSalida: 0,
        costoUnitarioPepsSalida: 0.0,
        totalSalida: 0.0,
        saldoCantidad: 15,
        costoPromedioSaldo: 90.00,
        saldoValorTotal: 1350.00,
      ),
    ];
  }

  @override
  Future<List<CifOrderEntity>> getCifOrders() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return List.unmodifiable(_cifOrders);
  }

  @override
  Future<CifOrderEntity> registrarOrdenCif(CifOrderEntity order) async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _cifOrders.insert(0, order);

    // Incrementar stock en el producto correspondiente
    final index = _products.indexWhere((p) => p.sku == order.sku);
    if (index != -1) {
      final current = _products[index];
      _products[index] = current.copyWith(
        stockDisponible: current.stockDisponible + order.cantidadUnidades,
      );
    }

    // Registrar asiento en Kárdex
    final entries = _kardexDb[order.sku] ?? [];
    final int saldoAnterior = entries.isNotEmpty ? entries.last.saldoCantidad : 0;
    final double saldoValorAnterior = entries.isNotEmpty ? entries.last.saldoValorTotal : 0.0;

    final nuevoSaldoCantidad = saldoAnterior + order.cantidadUnidades;
    final nuevoSaldoValor = saldoValorAnterior + order.costoTotalNacionalizadoBob;
    final double nuevoCostoPromedio = nuevoSaldoCantidad > 0 ? nuevoSaldoValor / nuevoSaldoCantidad : 0.0;

    final newKardex = KardexEntryEntity(
      id: 'KDX-${DateTime.now().millisecondsSinceEpoch}',
      sku: order.sku,
      fecha: DateTime.now(),
      comprobante: order.codigoOrden,
      detalle: 'Ingreso Aduanero CIF - Proveedor ${order.proveedor}',
      tipo: KardexEntryType.compraCif,
      cantidadEntrada: order.cantidadUnidades,
      costoUnitarioEntrada: double.parse(order.costoUnitarioNacionalizadoBob.toStringAsFixed(2)),
      totalEntrada: double.parse(order.costoTotalNacionalizadoBob.toStringAsFixed(2)),
      cantidadSalida: 0,
      costoUnitarioPepsSalida: 0.0,
      totalSalida: 0.0,
      saldoCantidad: nuevoSaldoCantidad,
      costoPromedioSaldo: double.parse(nuevoCostoPromedio.toStringAsFixed(2)),
      saldoValorTotal: double.parse(nuevoSaldoValor.toStringAsFixed(2)),
    );

    entries.add(newKardex);
    _kardexDb[order.sku] = entries;

    return order;
  }

  @override
  Future<List<SupplierEntity>> getSuppliers() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    return List.unmodifiable(_suppliers);
  }

  @override
  Future<SalesPurchasesKpiEntity> getKpis() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    final totalVentasHoy = _invoices.fold<double>(0.0, (sum, i) => sum + i.total) + 14820.50;
    final totalFacHoy = _invoices.length + 38;
    return SalesPurchasesKpiEntity(
      ventasHoyBs: totalVentasHoy,
      facturasEmitidasHoy: totalFacHoy,
      comprasCifMesBs: 84320.00,
      skusBajoStock: _products.where((p) => p.estaAgotado || p.stockCritico).length,
      margenPromedioPeps: 38.6,
    );
  }
}
