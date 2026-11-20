import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../administration/domain/events/admin_events.dart';
import '../../domain/entities/sales_purchases_entities.dart';
import '../../domain/events/sales_purchases_events.dart';
import '../../domain/usecases/sales_purchases_usecases.dart';

class SalesPurchasesController extends ChangeNotifier {
  final GetPosProductsUseCase getPosProductsUseCase;
  final SearchProductUseCase searchProductUseCase;
  final SearchCustomerByNitUseCase searchCustomerByNitUseCase;
  final ProcessPosSaleUseCase processPosSaleUseCase;
  final GetKardexBySkuUseCase getKardexBySkuUseCase;
  final GetCifOrdersUseCase getCifOrdersUseCase;
  final RegisterCifOrderUseCase registerCifOrderUseCase;
  final GetSuppliersUseCase getSuppliersUseCase;
  final GetSalesPurchasesKpiUseCase getSalesPurchasesKpiUseCase;
  final AppEventBus eventBus;

  StreamSubscription? _eventSubscription;

  // Estado del Catálogo y POS
  List<PosProductEntity> _products = [];
  List<PosProductEntity> _filteredProducts = [];
  String _posSearchQuery = '';

  // Carrito de Compras POS
  final List<PosCartItemEntity> _cart = [];
  String _customerNit = '';
  String _customerRazonSocial = '';
  String? _customerEmail;
  PaymentMethod _paymentMethod = PaymentMethod.efectivo;
  double _montoRecibido = 0.0;
  String _sucursalActiva = 'Sede Central Santa Cruz';

  // Última Factura Emitida
  InvoiceSaleEntity? _lastIssuedInvoice;

  // Estado Kárdex PEPS
  List<KardexEntryEntity> _kardexEntries = [];
  String _selectedKardexSku = 'SKU-MAT-002';

  // Estado CIF y Proveedores
  List<CifOrderEntity> _cifOrders = [];
  List<SupplierEntity> _suppliers = [];
  SalesPurchasesKpiEntity? _kpis;

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  SalesPurchasesController({
    required this.getPosProductsUseCase,
    required this.searchProductUseCase,
    required this.searchCustomerByNitUseCase,
    required this.processPosSaleUseCase,
    required this.getKardexBySkuUseCase,
    required this.getCifOrdersUseCase,
    required this.registerCifOrderUseCase,
    required this.getSuppliersUseCase,
    required this.getSalesPurchasesKpiUseCase,
    required this.eventBus,
  }) {
    _initEventSubscription();
  }

  void _initEventSubscription() {
    _eventSubscription = eventBus.allEvents.listen((event) {
      if (event is SkuRegisteredEvent) {
        // Un nuevo SKU fue creado en el módulo de Administración
        loadPosProducts();
      } else if (event is CifOrderRegisteredEvent) {
        // Nueva orden CIF registrada: recargar Kárdex y KPIs
        loadPosProducts();
        loadKardex(_selectedKardexSku);
        loadKpis();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  // Getters
  List<PosProductEntity> get products => _products;
  List<PosProductEntity> get filteredProducts => _filteredProducts;
  String get posSearchQuery => _posSearchQuery;
  List<PosCartItemEntity> get cart => List.unmodifiable(_cart);
  String get customerNit => _customerNit;
  String get customerRazonSocial => _customerRazonSocial;
  String? get customerEmail => _customerEmail;
  PaymentMethod get paymentMethod => _paymentMethod;
  double get montoRecibido => _montoRecibido;
  String get sucursalActiva => _sucursalActiva;
  InvoiceSaleEntity? get lastIssuedInvoice => _lastIssuedInvoice;

  List<KardexEntryEntity> get kardexEntries => _kardexEntries;
  String get selectedKardexSku => _selectedKardexSku;
  List<CifOrderEntity> get cifOrders => _cifOrders;
  List<SupplierEntity> get suppliers => _suppliers;
  SalesPurchasesKpiEntity? get kpis => _kpis;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  double get cartTotal => _cart.fold<double>(0.0, (sum, i) => sum + i.subtotal);
  int get cartTotalItems => _cart.fold<int>(0, (sum, i) => sum + i.cantidad);

  double get cambioCalculado {
    if (_paymentMethod != PaymentMethod.efectivo) return 0.0;
    if (_montoRecibido >= cartTotal) {
      return double.parse((_montoRecibido - cartTotal).toStringAsFixed(2));
    }
    return 0.0;
  }

  bool get puedeEmitirFactura {
    if (_cart.isEmpty) return false;
    // Bloqueo total si algún ítem tiene stock 0
    final tieneAgotados = _cart.any((item) => item.product.stockDisponible <= 0);
    if (tieneAgotados) return false;

    if (_customerNit.trim().isEmpty || _customerRazonSocial.trim().isEmpty) return false;

    if (_paymentMethod == PaymentMethod.efectivo && _montoRecibido < cartTotal) {
      return false;
    }
    return true;
  }

  void setSucursalActiva(String sucursal) {
    _sucursalActiva = sucursal;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Carga Masiva Inicial
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.wait([
      loadPosProducts(),
      loadKardex(_selectedKardexSku),
      loadCifOrders(),
      loadSuppliers(),
      loadKpis(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPosProducts() async {
    final result = await getPosProductsUseCase(const NoParams());
    if (result.isSuccess) {
      _products = result.dataOrNull ?? [];
      _filteredProducts = List.from(_products);
    }
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    _posSearchQuery = query;
    if (query.trim().isEmpty) {
      _filteredProducts = List.from(_products);
    } else {
      final result = await searchProductUseCase(query);
      if (result.isSuccess) {
        _filteredProducts = result.dataOrNull ?? [];
      }
    }
    notifyListeners();
  }

  // Lógica del Carrito POS
  void addToCart(PosProductEntity product) {
    clearMessages();

    // Bloqueo estricto: Si el stock disponible es 0, no permite agregar
    if (product.stockDisponible <= 0) {
      _errorMessage = 'Bloqueo: El producto "${product.titulo}" está agotado (Stock: 0).';
      notifyListeners();
      return;
    }

    final index = _cart.indexWhere((item) => item.product.sku == product.sku);
    if (index != -1) {
      final current = _cart[index];
      if (current.cantidad >= product.stockDisponible) {
        _errorMessage = 'No puede agregar más unidades. Stock disponible alcanzado (${product.stockDisponible} un.).';
        notifyListeners();
        return;
      }
      _cart[index] = current.copyWith(cantidad: current.cantidad + 1);
    } else {
      _cart.add(PosCartItemEntity(product: product, cantidad: 1));
    }

    // Si el monto recibido era igual al total anterior, actualizarlo
    if (_paymentMethod == PaymentMethod.efectivo && _montoRecibido < cartTotal) {
      _montoRecibido = cartTotal;
    }

    notifyListeners();
  }

  void updateCartItemQuantity(String sku, int newQty) {
    clearMessages();
    final index = _cart.indexWhere((item) => item.product.sku == sku);
    if (index == -1) return;

    if (newQty <= 0) {
      _cart.removeAt(index);
    } else {
      final current = _cart[index];
      if (newQty > current.product.stockDisponible) {
        _errorMessage = 'Stock insuficiente (${current.product.stockDisponible} un. disponibles).';
        _cart[index] = current.copyWith(cantidad: current.product.stockDisponible);
      } else {
        _cart[index] = current.copyWith(cantidad: newQty);
      }
    }

    if (_paymentMethod == PaymentMethod.efectivo && _montoRecibido < cartTotal) {
      _montoRecibido = cartTotal;
    }

    notifyListeners();
  }

  void removeFromCart(String sku) {
    _cart.removeWhere((item) => item.product.sku == sku);
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    _montoRecibido = 0.0;
    _customerNit = '';
    _customerRazonSocial = '';
    _customerEmail = null;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod method) {
    _paymentMethod = method;
    if (method == PaymentMethod.efectivo && _montoRecibido < cartTotal) {
      _montoRecibido = cartTotal;
    }
    notifyListeners();
  }

  void setMontoRecibido(double monto) {
    _montoRecibido = monto;
    notifyListeners();
  }

  Future<void> lookupCustomerByNit(String nit) async {
    _customerNit = nit;
    final clean = nit.trim();
    if (clean.isEmpty) {
      notifyListeners();
      return;
    }

    final result = await searchCustomerByNitUseCase(clean);
    if (result.isSuccess && result.dataOrNull != null) {
      final customer = result.dataOrNull!;
      _customerRazonSocial = customer.razonSocial;
      _customerEmail = customer.email;
    }
    notifyListeners();
  }

  void setCustomerData({
    required String nit,
    required String razonSocial,
    String? email,
  }) {
    _customerNit = nit;
    _customerRazonSocial = razonSocial;
    _customerEmail = email;
    notifyListeners();
  }

  // Emisión de Factura Electrónica SIAT (F10)
  Future<bool> emitirFacturaSiat() async {
    clearMessages();

    if (_cart.isEmpty) {
      _errorMessage = 'El carrito está vacío. Agregue productos antes de emitir la factura.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    final params = ProcessSaleParams(
      cliente: CustomerEntity(
        nitCi: _customerNit.isEmpty ? '0' : _customerNit,
        razonSocial: _customerRazonSocial.isEmpty ? 'Venta Menor' : _customerRazonSocial,
        email: _customerEmail,
      ),
      items: List.from(_cart),
      metodoPago: _paymentMethod,
      montoRecibido: _paymentMethod == PaymentMethod.efectivo ? _montoRecibido : cartTotal,
      sucursal: _sucursalActiva,
    );

    final result = await processPosSaleUseCase(params);
    _isLoading = false;

    if (result.isSuccess) {
      _lastIssuedInvoice = result.dataOrNull;
      _successMessage = 'Factura N° ${_lastIssuedInvoice!.numeroFactura} emitida y validada exitosamente ante el SIN (CUF: ${_lastIssuedInvoice!.cuf.substring(0, 15)}...).';
      clearCart();
      await loadPosProducts();
      await loadKpis();
      notifyListeners();
      return true;
    } else {
      _errorMessage = (result.failureOrNull as ValidationFailure?)?.message ??
          'Error al emitir factura electrónica.';
      notifyListeners();
      return false;
    }
  }

  // Kárdex
  Future<void> loadKardex(String sku) async {
    _selectedKardexSku = sku;
    final result = await getKardexBySkuUseCase(sku);
    if (result.isSuccess) {
      _kardexEntries = result.dataOrNull ?? [];
    }
    notifyListeners();
  }

  // Órdenes CIF
  Future<void> loadCifOrders() async {
    final result = await getCifOrdersUseCase(const NoParams());
    if (result.isSuccess) {
      _cifOrders = result.dataOrNull ?? [];
    }
    notifyListeners();
  }

  Future<bool> registrarOrdenCif(RegisterCifOrderParams params) async {
    clearMessages();
    _isLoading = true;
    notifyListeners();

    final result = await registerCifOrderUseCase(params);
    _isLoading = false;

    if (result.isSuccess) {
      final saved = result.dataOrNull!;
      _successMessage = 'Orden CIF "${saved.codigoOrden}" registrada exitosamente. Costo Unitario Nacionalizado: Bs ${saved.costoUnitarioNacionalizadoBob.toStringAsFixed(2)}.';
      await loadCifOrders();
      await loadKardex(saved.sku);
      await loadPosProducts();
      await loadKpis();
      notifyListeners();
      return true;
    } else {
      _errorMessage = (result.failureOrNull as ValidationFailure?)?.message ??
          'Error al registrar orden CIF.';
      notifyListeners();
      return false;
    }
  }

  // Proveedores
  Future<void> loadSuppliers() async {
    final result = await getSuppliersUseCase(const NoParams());
    if (result.isSuccess) {
      _suppliers = result.dataOrNull ?? [];
    }
    notifyListeners();
  }

  // KPIs
  Future<void> loadKpis() async {
    final result = await getSalesPurchasesKpiUseCase(const NoParams());
    if (result.isSuccess) {
      _kpis = result.dataOrNull;
    }
    notifyListeners();
  }
}
