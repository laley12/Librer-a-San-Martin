import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/events/event_bus.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../sales_purchases/domain/events/sales_purchases_events.dart';
import '../../domain/entities/reports_entities.dart';
import '../../domain/usecases/reports_usecases.dart';

class ReportsController extends ChangeNotifier {
  final GetReportsKpisUseCase getReportsKpisUseCase;
  final GetDailySalesEvolutionUseCase getDailySalesEvolutionUseCase;
  final GetSiatSalesVouchersUseCase getSiatSalesVouchersUseCase;
  final GetStockSemaforicoUseCase getStockSemaforicoUseCase;
  final RequestStockReplenishmentUseCase requestStockReplenishmentUseCase;
  final ExportReportUseCase exportReportUseCase;
  final AppEventBus eventBus;

  StreamSubscription? _eventSubscription;

  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );

  ReportsKpiEntity? _kpis;
  List<DailySalesDataPoint> _dailySales = [];
  List<SiatSalesVoucherEntity> _siatVouchers = [];
  List<StockSemaforicEntity> _stockItems = [];

  bool _soloCriticosFilter = false;
  String _selectedEditorial = 'Todas';

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  ReportsController({
    required this.getReportsKpisUseCase,
    required this.getDailySalesEvolutionUseCase,
    required this.getSiatSalesVouchersUseCase,
    required this.getStockSemaforicoUseCase,
    required this.requestStockReplenishmentUseCase,
    required this.exportReportUseCase,
    required this.eventBus,
  }) {
    _initEventSubscription();
  }

  void _initEventSubscription() {
    _eventSubscription = eventBus.allEvents.listen((event) {
      if (event is SaleInvoicedEvent || event is CifOrderRegisteredEvent) {
        // Si se emitió una factura o se registró una compra, refrescar datos
        loadAnalytics();
        loadStockSemaforico();
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  // Getters
  DateTimeRange get dateRange => _dateRange;
  ReportsKpiEntity? get kpis => _kpis;
  List<DailySalesDataPoint> get dailySales => _dailySales;
  List<SiatSalesVoucherEntity> get siatVouchers => _siatVouchers;
  List<StockSemaforicEntity> get stockItems => _stockItems;
  bool get soloCriticosFilter => _soloCriticosFilter;
  String get selectedEditorial => _selectedEditorial;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<StockSemaforicEntity> get filteredStockItems {
    return _stockItems.where((item) {
      if (_soloCriticosFilter && !item.esCritico) return false;
      if (_selectedEditorial != 'Todas' && item.editorial != _selectedEditorial) return false;
      return true;
    }).toList();
  }

  int get totalCriticos => _stockItems.where((i) => i.esCritico).length;
  int get totalReorden => _stockItems.where((i) => i.esReorden).length;
  int get totalOptimos => _stockItems.where((i) => i.esOptimo).length;

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void setDateRange(DateTimeRange newRange) {
    _dateRange = newRange;
    loadAnalytics();
  }

  void toggleSoloCriticos() {
    _soloCriticosFilter = !_soloCriticosFilter;
    notifyListeners();
  }

  void setEditorialFilter(String editorial) {
    _selectedEditorial = editorial;
    notifyListeners();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.wait([
      loadAnalytics(),
      loadStockSemaforico(),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAnalytics() async {
    final params = DateRangeParams(
      startDate: _dateRange.start,
      endDate: _dateRange.end,
    );

    final kpiResult = await getReportsKpisUseCase(params);
    if (kpiResult.isSuccess) {
      _kpis = kpiResult.dataOrNull;
    }

    final salesResult = await getDailySalesEvolutionUseCase(params);
    if (salesResult.isSuccess) {
      _dailySales = salesResult.dataOrNull ?? [];
    }

    final vouchersResult = await getSiatSalesVouchersUseCase(params);
    if (vouchersResult.isSuccess) {
      _siatVouchers = vouchersResult.dataOrNull ?? [];
    }

    notifyListeners();
  }

  Future<void> loadStockSemaforico() async {
    final result = await getStockSemaforicoUseCase(const NoParams());
    if (result.isSuccess) {
      _stockItems = result.dataOrNull ?? [];
    }
    notifyListeners();
  }

  Future<void> solicitarReposicion(StockSemaforicEntity item) async {
    clearMessages();
    final result = await requestStockReplenishmentUseCase(item);
    if (result.isSuccess) {
      _successMessage = 'Solicitud de reposición emitida vía EDA para "${item.titulo}" (${item.cantidadRecomendadaCompra} un. sugeridas).';
      notifyListeners();
    }
  }

  Future<void> exportarReporte({
    required String tipoReporte,
    required String formato,
    required int totalRegistros,
  }) async {
    clearMessages();
    final params = ExportReportParams(
      tipoReporte: tipoReporte,
      formato: formato,
      totalRegistros: totalRegistros,
    );
    final result = await exportReportUseCase(params);
    if (result.isSuccess) {
      _successMessage = '$tipoReporte exportado exitosamente a formato $formato ($totalRegistros registros procesados).';
      notifyListeners();
    }
  }
}
