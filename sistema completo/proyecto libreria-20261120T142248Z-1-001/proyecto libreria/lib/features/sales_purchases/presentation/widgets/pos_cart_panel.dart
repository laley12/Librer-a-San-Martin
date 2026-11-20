import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sales_purchases_entities.dart';
import '../controllers/sales_purchases_controller.dart';
import 'factura_emitida_dialog.dart';

class PosCartPanel extends StatefulWidget {
  final SalesPurchasesController controller;

  const PosCartPanel({super.key, required this.controller});

  @override
  State<PosCartPanel> createState() => _PosCartPanelState();
}

class _PosCartPanelState extends State<PosCartPanel> {
  final _nitController = TextEditingController();
  final _razonSocialController = TextEditingController();
  final _efectivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nitController.text = widget.controller.customerNit;
    _razonSocialController.text = widget.controller.customerRazonSocial;
    if (widget.controller.montoRecibido > 0) {
      _efectivoController.text = widget.controller.montoRecibido.toStringAsFixed(2);
    }
  }

  @override
  void didUpdateWidget(covariant PosCartPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.customerNit != _nitController.text) {
      _nitController.text = widget.controller.customerNit;
    }
    if (widget.controller.customerRazonSocial != _razonSocialController.text) {
      _razonSocialController.text = widget.controller.customerRazonSocial;
    }
    if (widget.controller.paymentMethod == PaymentMethod.efectivo &&
        widget.controller.montoRecibido > 0 &&
        _efectivoController.text.isEmpty) {
      _efectivoController.text = widget.controller.montoRecibido.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nitController.dispose();
    _razonSocialController.dispose();
    _efectivoController.dispose();
    super.dispose();
  }

  Future<void> _ejecutarEmision() async {
    final success = await widget.controller.emitirFacturaSiat();
    if (success && mounted && widget.controller.lastIssuedInvoice != null) {
      _nitController.clear();
      _razonSocialController.clear();
      _efectivoController.clear();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => FacturaEmitidaDialog(invoice: widget.controller.lastIssuedInvoice!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final cart = controller.cart;
    final total = controller.cartTotal;
    final cambio = controller.cambioCalculado;
    final tieneAgotados = cart.any((item) => item.product.stockDisponible <= 0);
    final puedeEmitir = controller.puedeEmitirFactura && !controller.isLoading;

    return Card(
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
            // Cabecera del Carrito
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    const Text(
                      'Orden Actual POS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${controller.cartTotalItems} ítems',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                if (cart.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.delete_outline, size: 16, color: AppColors.critical),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(fontSize: 12, color: AppColors.critical),
                    ),
                    onPressed: () {
                      controller.clearCart();
                      _nitController.clear();
                      _razonSocialController.clear();
                      _efectivoController.clear();
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.borderLight, height: 1),
            const SizedBox(height: 8),

            // Lista de Ítems en el Carrito
            Expanded(
              child: cart.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add_shopping_cart, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          const Text(
                            'Carrito vacío',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Haga clic en los productos o escanee un código de barras para comenzar la venta.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: cart.length,
                      separatorBuilder: (context, index) => const Divider(color: AppColors.borderLight, height: 1),
                      itemBuilder: (context, index) {
                        final item = cart[index];
                        final agotado = item.product.stockDisponible <= 0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              // Detalle de producto
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.titulo,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: agotado ? AppColors.critical : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'SKU: ${item.product.sku} • Stock: ${item.product.stockDisponible}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: agotado ? AppColors.critical : AppColors.textSecondary,
                                        fontWeight: agotado ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      'Bs ${item.product.precioVenta.toStringAsFixed(2)} c/u',
                                      style: const TextStyle(fontSize: 11, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),

                              // Selector de Cantidad (+ / -)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    onPressed: () => controller.updateCartItemQuantity(
                                      item.product.sku,
                                      item.cantidad - 1,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: AppColors.borderLight),
                                    ),
                                    child: Text(
                                      '${item.cantidad}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 16),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                    onPressed: () => controller.updateCartItemQuantity(
                                      item.product.sku,
                                      item.cantidad + 1,
                                    ),
                                  ),
                                ],
                              ),

                              // Subtotal
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Bs ${item.subtotal.toStringAsFixed(2)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),

                              // Eliminar
                              IconButton(
                                icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                onPressed: () => controller.removeFromCart(item.product.sku),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            const Divider(color: AppColors.borderLight, height: 16),

            // Panel de Datos del Cliente SIAT
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DATOS TRIBUTARIOS DEL CLIENTE (SIAT)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      // NIT/CI con autocompletado
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _nitController,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: const InputDecoration(
                            labelText: 'NIT / CI',
                            isDense: true,
                            hintText: 'Ej. 4871923 o 0',
                            prefixIcon: Icon(Icons.badge_outlined, size: 16),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            controller.lookupCustomerByNit(val);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Razón Social
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _razonSocialController,
                          style: const TextStyle(fontSize: 12.5),
                          decoration: const InputDecoration(
                            labelText: 'Razón Social / Nombre',
                            isDense: true,
                            hintText: 'Nombre del cliente',
                            prefixIcon: Icon(Icons.person_outline, size: 16),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (val) {
                            controller.setCustomerData(
                              nit: _nitController.text,
                              razonSocial: val,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Selector de Método de Pago y Calculador de Cambio
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MÉTODO DE PAGO Y COBRO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildPaymentMethodButton(
                        label: 'Efectivo',
                        icon: Icons.payments_outlined,
                        method: PaymentMethod.efectivo,
                      ),
                      const SizedBox(width: 6),
                      _buildPaymentMethodButton(
                        label: 'QR Simple',
                        icon: Icons.qr_code_2,
                        method: PaymentMethod.qrSimple,
                      ),
                      const SizedBox(width: 6),
                      _buildPaymentMethodButton(
                        label: 'Tarjeta',
                        icon: Icons.credit_card,
                        method: PaymentMethod.tarjeta,
                      ),
                    ],
                  ),

                  // Si es efectivo: Calculador interactivo de cambio
                  if (controller.paymentMethod == PaymentMethod.efectivo) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _efectivoController,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              labelText: 'Monto Recibido (Bs)',
                              isDense: true,
                              prefixIcon: Icon(Icons.attach_money, size: 16),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (val) {
                              final parsed = double.tryParse(val) ?? 0.0;
                              controller.setMontoRecibido(parsed);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Cambio / Vuelto:',
                              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            Text(
                              'Bs ${cambio.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: controller.montoRecibido < total
                                    ? AppColors.critical
                                    : AppColors.optimal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Banner de Alerta si hay productos agotados
            if (tieneAgotados) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.criticalBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'BLOQUEO: Existen productos con Stock 0 en el carrito. Debe eliminarlos para emitir la factura.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.criticalText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Total General a Cobrar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL A COBRAR:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Bs ${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Botón Grande F10
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long, size: 20),
                label: const Text(
                  'Emitir Factura Electrónica SIAT (F10)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: puedeEmitir ? AppColors.primary : AppColors.borderLight,
                  foregroundColor: puedeEmitir ? Colors.white : AppColors.textMuted,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: puedeEmitir ? _ejecutarEmision : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String label,
    required IconData icon,
    required PaymentMethod method,
  }) {
    final isSelected = widget.controller.paymentMethod == method;
    return Expanded(
      child: InkWell(
        onTap: () {
          widget.controller.setPaymentMethod(method);
          if (method == PaymentMethod.efectivo) {
            _efectivoController.text = widget.controller.cartTotal.toStringAsFixed(2);
            widget.controller.setMontoRecibido(widget.controller.cartTotal);
          }
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
