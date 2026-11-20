import '../../../../core/errors/result.dart';
import '../entities/sales_purchases_entities.dart';

/// Contrato abstracto del repositorio de Compra y Venta (Clean Architecture)
abstract class SalesPurchasesRepository {
  /// Obtiene los productos del catálogo rápido POS
  Future<Result<List<PosProductEntity>>> getPosProducts();

  /// Búsqueda por código de barras o texto
  Future<Result<List<PosProductEntity>>> searchProduct(String query);

  /// Búsqueda de cliente por NIT o CI para autocompletado en facturación
  Future<Result<CustomerEntity?>> searchCustomerByNit(String nitCi);

  /// Procesa y emite una Factura Electrónica SIAT
  Future<Result<InvoiceSaleEntity>> emitirFacturaPos(InvoiceSaleEntity invoice);

  /// Obtiene el Kárdex Físico-Valorado PEPS para un SKU específico
  Future<Result<List<KardexEntryEntity>>> getKardexBySku(String sku);

  /// Obtiene el historial de órdenes de compra con costeo CIF
  Future<Result<List<CifOrderEntity>>> getCifOrders();

  /// Registra una nueva Orden de Compra Internacional CIF
  Future<Result<CifOrderEntity>> registrarOrdenCif(CifOrderEntity order);

  /// Directorio de Proveedores y Editoriales
  Future<Result<List<SupplierEntity>>> getSuppliers();

  /// Métricas e indicadores de Compra y Venta
  Future<Result<SalesPurchasesKpiEntity>> getKpis();
}
