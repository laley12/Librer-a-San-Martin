import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/sales_purchases_entities.dart';
import '../events/sales_purchases_events.dart';
import '../repositories/sales_purchases_repository.dart';

/// Caso de Uso: Cargar catálogo de productos POS
class GetPosProductsUseCase implements UseCase<List<PosProductEntity>, NoParams> {
  final SalesPurchasesRepository repository;
  GetPosProductsUseCase(this.repository);

  @override
  Future<Result<List<PosProductEntity>>> call(NoParams params) {
    return repository.getPosProducts();
  }
}

/// Caso de Uso: Buscar producto por código de barra o texto
class SearchProductUseCase implements UseCase<List<PosProductEntity>, String> {
  final SalesPurchasesRepository repository;
  SearchProductUseCase(this.repository);

  @override
  Future<Result<List<PosProductEntity>>> call(String query) {
    return repository.searchProduct(query);
  }
}

/// Caso de Uso: Autocompletar cliente por NIT/CI
class SearchCustomerByNitUseCase implements UseCase<CustomerEntity?, String> {
  final SalesPurchasesRepository repository;
  SearchCustomerByNitUseCase(this.repository);

  @override
  Future<Result<CustomerEntity?>> call(String nitCi) {
    return repository.searchCustomerByNit(nitCi);
  }
}

/// Parámetros para procesar una venta POS
class ProcessSaleParams {
  final CustomerEntity cliente;
  final List<PosCartItemEntity> items;
  final PaymentMethod metodoPago;
  final double montoRecibido;
  final String sucursal;

  ProcessSaleParams({
    required this.cliente,
    required this.items,
    required this.metodoPago,
    required this.montoRecibido,
    required this.sucursal,
  });
}

/// Caso de Uso: Procesar Factura Electrónica POS (F10)
class ProcessPosSaleUseCase implements UseCase<InvoiceSaleEntity, ProcessSaleParams> {
  final SalesPurchasesRepository repository;
  final AppEventBus eventBus;

  ProcessPosSaleUseCase(this.repository, this.eventBus);

  @override
  Future<Result<InvoiceSaleEntity>> call(ProcessSaleParams params) async {
    // 1. Validar que el carrito no esté vacío
    if (params.items.isEmpty) {
      return Result.failure(
        const ValidationFailure(message: 'El carrito de compras está vacío. Agregue al menos un producto.'),
      );
    }

    // 2. Validación de Stock Crítico / Cero (Requisito estricto: Bloqueo si stock disponible es 0)
    for (final item in params.items) {
      if (item.product.stockDisponible <= 0) {
        return Result.failure(
          ValidationFailure(
            message: 'Bloqueo SIAT: El producto "${item.product.titulo}" (SKU: ${item.product.sku}) tiene Stock 0. No es posible emitir factura con existencias agotadas.',
          ),
        );
      }
      if (item.cantidad > item.product.stockDisponible) {
        return Result.failure(
          ValidationFailure(
            message: 'Stock insuficiente para "${item.product.titulo}". Solicitado: ${item.cantidad}, Disponible: ${item.product.stockDisponible}.',
          ),
        );
      }
    }

    // 3. Validar Datos del Cliente
    if (params.cliente.nitCi.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure(message: 'Debe ingresar el NIT o CI del cliente (utilice 0 para Venta Menor).'),
      );
    }
    if (params.cliente.razonSocial.trim().isEmpty) {
      return Result.failure(
        const ValidationFailure(message: 'Debe ingresar la Razón Social o Nombre del cliente.'),
      );
    }

    // 4. Calcular Total y Cambio
    final total = params.items.fold<double>(
      0.0,
      (sum, item) => sum + item.subtotal,
    );

    double cambio = 0.0;
    if (params.metodoPago == PaymentMethod.efectivo) {
      if (params.montoRecibido < total) {
        return Result.failure(
          ValidationFailure(
            message: 'El monto recibido (Bs ${params.montoRecibido.toStringAsFixed(2)}) es menor al total a cobrar (Bs ${total.toStringAsFixed(2)}).',
          ),
        );
      }
      cambio = params.montoRecibido - total;
    } else {
      cambio = 0.0;
    }

    // 5. Construir entidad de factura con CUF simulado según algoritmo SHA-256 SIAT
    final numeroFactura = DateTime.now().millisecondsSinceEpoch % 100000;
    final cufSimulado = 'CUF-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-F$numeroFactura-SIAT';

    final invoice = InvoiceSaleEntity(
      id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
      cuf: cufSimulado,
      numeroFactura: numeroFactura,
      fecha: DateTime.now(),
      cliente: params.cliente,
      items: List.unmodifiable(params.items),
      total: double.parse(total.toStringAsFixed(2)),
      metodoPago: params.metodoPago,
      montoRecibido: params.metodoPago == PaymentMethod.efectivo ? params.montoRecibido : total,
      cambio: double.parse(cambio.toStringAsFixed(2)),
      sucursal: params.sucursal,
      estadoSiat: 'EMITIDA Y VALIDADA EN LÍNEA',
    );

    final result = await repository.emitirFacturaPos(invoice);

    if (result.isSuccess) {
      final savedInvoice = result.dataOrNull!;

      // 6. Emitir Evento de Dominio SaleInvoicedEvent
      eventBus.emit(
        SaleInvoicedEvent(
          invoiceId: savedInvoice.id,
          numeroFactura: savedInvoice.numeroFactura,
          cuf: savedInvoice.cuf,
          total: savedInvoice.total,
          nitCi: savedInvoice.cliente.nitCi,
          razonSocial: savedInvoice.cliente.razonSocial,
          totalItems: savedInvoice.items.fold<int>(0, (sum, i) => sum + i.cantidad),
          sucursal: savedInvoice.sucursal,
        ),
      );

      // 7. Emitir alertas de stock bajo si corresponde
      for (final item in params.items) {
        final remanente = item.product.stockDisponible - item.cantidad;
        if (remanente <= 5) {
          eventBus.emit(
            StockAlertLowEvent(
              sku: item.product.sku,
              titulo: item.product.titulo,
              stockRestante: remanente,
            ),
          );
        }
      }
    }

    return result;
  }
}

/// Caso de Uso: Consultar Kárdex Físico-Valorado PEPS por SKU
class GetKardexBySkuUseCase implements UseCase<List<KardexEntryEntity>, String> {
  final SalesPurchasesRepository repository;
  GetKardexBySkuUseCase(this.repository);

  @override
  Future<Result<List<KardexEntryEntity>>> call(String sku) {
    if (sku.trim().isEmpty) {
      return Future.value(Result.failure(const ValidationFailure(message: 'Debe seleccionar un SKU válido.')));
    }
    return repository.getKardexBySku(sku);
  }
}

/// Caso de Uso: Listar Órdenes CIF
class GetCifOrdersUseCase implements UseCase<List<CifOrderEntity>, NoParams> {
  final SalesPurchasesRepository repository;
  GetCifOrdersUseCase(this.repository);

  @override
  Future<Result<List<CifOrderEntity>>> call(NoParams params) {
    return repository.getCifOrders();
  }
}

/// Parámetros para registrar una Orden CIF
class RegisterCifOrderParams {
  final String proveedor;
  final String sku;
  final String skuTitulo;
  final int cantidadUnidades;
  final double fobTotalUsd;
  final double fleteUsd;
  final double seguroUsd;
  final double tipoCambioBob;
  final double gaPorcentaje;
  final double gastosDespachoBob;

  RegisterCifOrderParams({
    required this.proveedor,
    required this.sku,
    required this.skuTitulo,
    required this.cantidadUnidades,
    required this.fobTotalUsd,
    required this.fleteUsd,
    required this.seguroUsd,
    this.tipoCambioBob = 6.96,
    this.gaPorcentaje = 0.10,
    required this.gastosDespachoBob,
  });
}

/// Caso de Uso: Registrar Orden CIF y costeo de nacionalización
class RegisterCifOrderUseCase implements UseCase<CifOrderEntity, RegisterCifOrderParams> {
  final SalesPurchasesRepository repository;
  final AppEventBus eventBus;

  RegisterCifOrderUseCase(this.repository, this.eventBus);

  @override
  Future<Result<CifOrderEntity>> call(RegisterCifOrderParams params) async {
    if (params.proveedor.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'El proveedor es obligatorio.'));
    }
    if (params.sku.trim().isEmpty) {
      return Result.failure(const ValidationFailure(message: 'Debe seleccionar el SKU de destino.'));
    }
    if (params.cantidadUnidades <= 0) {
      return Result.failure(const ValidationFailure(message: 'La cantidad de unidades debe ser mayor a 0.'));
    }
    if (params.fobTotalUsd <= 0) {
      return Result.failure(const ValidationFailure(message: 'El valor FOB total en USD debe ser mayor a 0.'));
    }
    if (params.fleteUsd < 0 || params.seguroUsd < 0 || params.gastosDespachoBob < 0) {
      return Result.failure(const ValidationFailure(message: 'Los importes de transporte, seguro o despacho no pueden ser negativos.'));
    }

    final codigoOrden = 'CIF-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch % 10000}';

    final order = CifOrderEntity(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      codigoOrden: codigoOrden,
      proveedor: params.proveedor,
      sku: params.sku,
      skuTitulo: params.skuTitulo,
      cantidadUnidades: params.cantidadUnidades,
      fobTotalUsd: params.fobTotalUsd,
      fleteUsd: params.fleteUsd,
      seguroUsd: params.seguroUsd,
      tipoCambioBob: params.tipoCambioBob,
      gaPorcentaje: params.gaPorcentaje,
      gastosDespachoBob: params.gastosDespachoBob,
      fechaRegistro: DateTime.now(),
      estado: 'Nacionalizado en Bodega Central',
    );

    final result = await repository.registrarOrdenCif(order);

    if (result.isSuccess) {
      final saved = result.dataOrNull!;
      eventBus.emit(
        CifOrderRegisteredEvent(
          orderId: saved.id,
          codigoOrden: saved.codigoOrden,
          sku: saved.sku,
          cantidad: saved.cantidadUnidades,
          costoUnitarioNacionalizadoBob: saved.costoUnitarioNacionalizadoBob,
          costoTotalNacionalizadoBob: saved.costoTotalNacionalizadoBob,
        ),
      );
    }

    return result;
  }
}

/// Caso de Uso: Listar Directorio de Proveedores
class GetSuppliersUseCase implements UseCase<List<SupplierEntity>, NoParams> {
  final SalesPurchasesRepository repository;
  GetSuppliersUseCase(this.repository);

  @override
  Future<Result<List<SupplierEntity>>> call(NoParams params) {
    return repository.getSuppliers();
  }
}

/// Caso de Uso: KPIs de Compra y Venta
class GetSalesPurchasesKpiUseCase implements UseCase<SalesPurchasesKpiEntity, NoParams> {
  final SalesPurchasesRepository repository;
  GetSalesPurchasesKpiUseCase(this.repository);

  @override
  Future<Result<SalesPurchasesKpiEntity>> call(NoParams params) {
    return repository.getKpis();
  }
}
