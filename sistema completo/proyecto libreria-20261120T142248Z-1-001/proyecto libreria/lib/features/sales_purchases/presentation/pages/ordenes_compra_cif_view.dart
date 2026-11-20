import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/usecases/sales_purchases_usecases.dart';
import '../controllers/sales_purchases_controller.dart';

class OrdenesCompraCifView extends StatefulWidget {
  final SalesPurchasesController controller;

  const OrdenesCompraCifView({super.key, required this.controller});

  @override
  State<OrdenesCompraCifView> createState() => _OrdenesCompraCifViewState();
}

class _OrdenesCompraCifViewState extends State<OrdenesCompraCifView> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedProveedor;
  String? _selectedSku;
  final _cantidadController = TextEditingController(text: '100');
  final _fobController = TextEditingController(text: '2500.00');
  final _fleteController = TextEditingController(text: '350.00');
  final _seguroController = TextEditingController(text: '75.00');
  final _tipoCambioController = TextEditingController(text: '6.96');
  final _gaPorcentajeController = TextEditingController(text: '10.0');
  final _despachoController = TextEditingController(text: '950.00');

  @override
  void initState() {
    super.initState();
    if (widget.controller.suppliers.isNotEmpty) {
      _selectedProveedor = widget.controller.suppliers.first.razonSocial;
    }
    if (widget.controller.products.isNotEmpty) {
      _selectedSku = widget.controller.products.first.sku;
    }
  }

  @override
  void dispose() {
    _cantidadController.dispose();
    _fobController.dispose();
    _fleteController.dispose();
    _seguroController.dispose();
    _tipoCambioController.dispose();
    _gaPorcentajeController.dispose();
    _despachoController.dispose();
    super.dispose();
  }

  // Cálculos Reactivos del Costeo Aduanero
  double get _fobUsd => double.tryParse(_fobController.text) ?? 0.0;
  double get _fleteUsd => double.tryParse(_fleteController.text) ?? 0.0;
  double get _seguroUsd => double.tryParse(_seguroController.text) ?? 0.0;
  double get _cifUsd => _fobUsd + _fleteUsd + _seguroUsd;

  double get _tipoCambio => double.tryParse(_tipoCambioController.text) ?? 6.96;
  double get _cifBob => _cifUsd * _tipoCambio;

  double get _gaPorcentaje => (double.tryParse(_gaPorcentajeController.text) ?? 10.0) / 100.0;
  double get _gaBob => _cifBob * _gaPorcentaje;

  double get _despachoBob => double.tryParse(_despachoController.text) ?? 0.0;

  double get _costoTotalNacionalizadoBob => _cifBob + _gaBob + _despachoBob;

  int get _cantidad => int.tryParse(_cantidadController.text) ?? 1;
  double get _costoUnitarioNacionalizadoBob =>
      _cantidad > 0 ? _costoTotalNacionalizadoBob / _cantidad : 0.0;

  Future<void> _registrarOrden() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProveedor == null || _selectedSku == null) return;

    final product = widget.controller.products.firstWhere((p) => p.sku == _selectedSku);

    final params = RegisterCifOrderParams(
      proveedor: _selectedProveedor!,
      sku: _selectedSku!,
      skuTitulo: product.titulo,
      cantidadUnidades: _cantidad,
      fobTotalUsd: _fobUsd,
      fleteUsd: _fleteUsd,
      seguroUsd: _seguroUsd,
      tipoCambioBob: _tipoCambio,
      gaPorcentaje: _gaPorcentaje,
      gastosDespachoBob: _despachoBob,
    );

    final success = await widget.controller.registrarOrdenCif(params);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Orden CIF Registrada! Ingresaron $_cantidad unidades a Kárdex con Costo Unitario de Bs ${_costoUnitarioNacionalizadoBob.toStringAsFixed(2)}.',
          ),
          backgroundColor: AppColors.optimal,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final orders = controller.cifOrders;

        if (_selectedProveedor == null && controller.suppliers.isNotEmpty) {
          _selectedProveedor = controller.suppliers.first.razonSocial;
        }
        if (_selectedSku == null && controller.products.isNotEmpty) {
          _selectedSku = controller.products.first.sku;
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Órdenes de Compra y Costeo CIF Aduanero',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Nacionalización de importaciones: FOB + Flete + Seguro + GA (10%) + Gastos de Desaduanización.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Actualizar'),
                    onPressed: () => controller.loadCifOrders(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Layout Principal: Formulario de Costeo + Desglose Reactivo
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulario de Parámetros de Importación (Flex: 6)
                  Expanded(
                    flex: 6,
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 22),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Parámetros de Importación y Costeo',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Proveedor y SKU
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedProveedor,
                                      decoration: const InputDecoration(
                                        labelText: 'Proveedor / Editorial Internacional',
                                        prefixIcon: Icon(Icons.business_outlined, size: 18),
                                      ),
                                      items: controller.suppliers.map((s) {
                                        return DropdownMenuItem<String>(
                                          value: s.razonSocial,
                                          child: Text('${s.razonSocial} (${s.pais})', overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedProveedor = val),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      initialValue: _selectedSku,
                                      decoration: const InputDecoration(
                                        labelText: 'SKU Destino para Almacén',
                                        prefixIcon: Icon(Icons.inventory_2_outlined, size: 18),
                                      ),
                                      items: controller.products.map((p) {
                                        return DropdownMenuItem<String>(
                                          value: p.sku,
                                          child: Text('${p.sku} - ${p.titulo}', overflow: TextOverflow.ellipsis),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(() => _selectedSku = val),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Cantidad y FOB USD
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _cantidadController,
                                      decoration: const InputDecoration(
                                        labelText: 'Cantidad de Unidades',
                                        prefixIcon: Icon(Icons.numbers, size: 18),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => setState(() {}),
                                      validator: (val) {
                                        final num = int.tryParse(val ?? '');
                                        if (num == null || num <= 0) return 'Ingrese un entero > 0';
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fobController,
                                      decoration: const InputDecoration(
                                        labelText: 'FOB Total (USD)',
                                        prefixIcon: Icon(Icons.attach_money, size: 18),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                      validator: (val) {
                                        final num = double.tryParse(val ?? '');
                                        if (num == null || num <= 0) return 'Ingrese monto > 0';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Flete USD y Seguro USD
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _fleteController,
                                      decoration: const InputDecoration(
                                        labelText: 'Flete Internacional (USD)',
                                        prefixIcon: Icon(Icons.directions_boat_outlined, size: 18),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _seguroController,
                                      decoration: const InputDecoration(
                                        labelText: 'Seguro Internacional (USD)',
                                        prefixIcon: Icon(Icons.security_outlined, size: 18),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Tipo Cambio BOB, Gravamen Arancelario GA% y Gastos Despacho
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _tipoCambioController,
                                      decoration: const InputDecoration(
                                        labelText: 'Tipo Cambio (Bs/USD)',
                                        prefixIcon: Icon(Icons.currency_exchange, size: 18),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _gaPorcentajeController,
                                      decoration: const InputDecoration(
                                        labelText: 'GA Arancel (%)',
                                        prefixIcon: Icon(Icons.percent, size: 18),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _despachoController,
                                      decoration: const InputDecoration(
                                        labelText: 'Desaduanización (Bs)',
                                        prefixIcon: Icon(Icons.local_shipping_outlined, size: 18),
                                      ),
                                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              // Botón de Registro
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.save_outlined, size: 18),
                                  label: const Text(
                                    'Registrar Orden e Ingresar a Kárdex PEPS',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: controller.isLoading ? null : _registrarOrden,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Resumen y Desglose de Liquidación Aduanera (Flex: 5)
                  Expanded(
                    flex: 5,
                    child: Card(
                      elevation: 0,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderLight),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.receipt_long, color: AppColors.primary, size: 22),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'Liquidación Arancelaria y Costo PEPS',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Desglose de Cálculo
                            _buildCifCostRow('Valor FOB Total:', '\$ ${_fobUsd.toStringAsFixed(2)} USD'),
                            _buildCifCostRow('+ Flete Internacional:', '\$ ${_fleteUsd.toStringAsFixed(2)} USD'),
                            _buildCifCostRow('+ Seguro Internacional:', '\$ ${_seguroUsd.toStringAsFixed(2)} USD'),
                            const Divider(color: AppColors.borderLight, height: 16),
                            _buildCifCostRow(
                              '= VALOR CIF ADUANERO (USD):',
                              '\$ ${_cifUsd.toStringAsFixed(2)} USD',
                              isBold: true,
                              color: AppColors.primary,
                            ),
                            _buildCifCostRow(
                              'Valor CIF en Moneda Nacional (Bs):',
                              'Bs ${_cifBob.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                            const SizedBox(height: 8),

                            _buildCifCostRow(
                              '+ Gravamen Arancelario GA (${(_gaPorcentaje * 100).toStringAsFixed(0)}%):',
                              'Bs ${_gaBob.toStringAsFixed(2)}',
                            ),
                            _buildCifCostRow(
                              '+ Gastos Desaduanización / Despacho:',
                              'Bs ${_despachoBob.toStringAsFixed(2)}',
                            ),
                            const Divider(color: AppColors.borderLight, height: 16),

                            // Total Nacionalizado
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.borderLight),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'COSTO TOTAL NACIONALIZADO:',
                                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Bs ${_costoTotalNacionalizadoBob.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Text(
                                          'Cantidad de Unidades a Bodega:',
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$_cantidad un.',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // COSTO UNITARIO NACIONALIZADO (DESTACADO)
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'COSTO UNITARIO NACIONALIZADO',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        Text(
                                          '(Valor que ingresa a Kárdex PEPS)',
                                          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Bs ${_costoUnitarioNacionalizadoBob.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Historial de Órdenes CIF Registradas
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Historial de Órdenes CIF Nacionalizadas',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${orders.length} órdenes registradas',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.all(AppColors.background),
                          columns: const [
                            DataColumn(label: Text('Código Orden', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Proveedor', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('SKU / Título', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Unidades', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('CIF (USD)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('GA 10% (Bs)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Costo Total (Bs)', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Costo Unit. Nac.', style: TextStyle(fontWeight: FontWeight.bold)), numeric: true),
                            DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: orders.map((order) {
                            return DataRow(
                              cells: [
                                DataCell(Text(order.codigoOrden, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary))),
                                DataCell(Text(order.proveedor)),
                                DataCell(Text('${order.sku} - ${order.skuTitulo}')),
                                DataCell(Text('${order.cantidadUnidades}')),
                                DataCell(Text('\$ ${order.valorCifUsd.toStringAsFixed(2)}')),
                                DataCell(Text('Bs ${order.gravamenArancelarioBob.toStringAsFixed(2)}')),
                                DataCell(Text('Bs ${order.costoTotalNacionalizadoBob.toStringAsFixed(2)}')),
                                DataCell(Text(
                                  'Bs ${order.costoUnitarioNacionalizadoBob.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.optimal),
                                )),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.optimalBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    order.estado,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.optimalText,
                                    ),
                                  ),
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCifCostRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color ?? AppColors.textPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
