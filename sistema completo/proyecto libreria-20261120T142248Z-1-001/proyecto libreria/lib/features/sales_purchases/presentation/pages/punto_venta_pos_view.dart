import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/sales_purchases_controller.dart';
import '../widgets/factura_emitida_dialog.dart';
import '../widgets/pos_cart_panel.dart';
import '../widgets/pos_product_card.dart';

/// Intent para capturar la tecla F10
class F10EmitirFacturaIntent extends Intent {
  const F10EmitirFacturaIntent();
}

class PuntoVentaPosView extends StatefulWidget {
  final SalesPurchasesController controller;

  const PuntoVentaPosView({super.key, required this.controller});

  @override
  State<PuntoVentaPosView> createState() => _PuntoVentaPosViewState();
}

class _PuntoVentaPosViewState extends State<PuntoVentaPosView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  String _selectedCategoriaFiltro = 'Todas';

  @override
  void initState() {
    super.initState();
    // Enfocar el buscador al entrar a la pantalla para escaneo inmediato con pistola USB
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleF10() async {
    if (!widget.controller.puedeEmitirFactura) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Atajo F10: Complete el cliente o resuelva los ítems con stock 0 antes de facturar.'),
          backgroundColor: AppColors.critical,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final success = await widget.controller.emitirFacturaSiat();
    if (success && mounted && widget.controller.lastIssuedInvoice != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => FacturaEmitidaDialog(invoice: widget.controller.lastIssuedInvoice!),
      );
    }
  }

  void _onBarcodeSubmitted(String code) {
    if (code.trim().isEmpty) return;

    // Buscar coincidencia exacta por código de barra o SKU
    final match = widget.controller.products.where((p) {
      return p.codigoBarra == code.trim() || p.sku.toLowerCase() == code.trim().toLowerCase();
    });

    if (match.isNotEmpty) {
      final product = match.first;
      widget.controller.addToCart(product);
      _searchController.clear();
      _searchFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Escaneado: ${product.titulo} (+1 al carrito)'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      // Si no es coincidencia exacta, filtrar la grilla
      widget.controller.searchProducts(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.f10): const F10EmitirFacturaIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          F10EmitirFacturaIntent: CallbackAction<F10EmitirFacturaIntent>(
            onInvoke: (intent) {
              _handleF10();
              return null;
            },
          ),
        },
        child: FocusScope(
          autofocus: true,
          child: AnimatedBuilder(
            animation: widget.controller,
            builder: (context, _) {
              final controller = widget.controller;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner de Notificaciones de Error o Éxito
                  if (controller.errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.criticalBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.critical.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.critical, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.errorMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.criticalText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.critical),
                            onPressed: () => controller.clearMessages(),
                          ),
                        ],
                      ),
                    ),

                  if (controller.successMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.optimalBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.optimal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, color: AppColors.optimal, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              controller.successMessage!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.optimalText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: AppColors.optimal),
                            onPressed: () => controller.clearMessages(),
                          ),
                        ],
                      ),
                    ),

                  // Layout Principal Dividido en 2 Paneles (Flex 6 : Flex 4)
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // PANEL IZQUIERDO: Buscador, Filtros y Catálogo Rápido (Flex: 6)
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Barra Superior con Buscador USB y Atajo F10 visible
                              Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: AppColors.borderLight),
                                ),
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      // Input con autofocus y listener para lector USB
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText: 'Escanear código de barra USB o buscar por título / SKU...',
                                            prefixIcon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                                            suffixIcon: _searchController.text.isNotEmpty
                                                ? IconButton(
                                                    icon: const Icon(Icons.clear, size: 18),
                                                    onPressed: () {
                                                      _searchController.clear();
                                                      controller.searchProducts('');
                                                    },
                                                  )
                                                : null,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          onChanged: (val) => controller.searchProducts(val),
                                          onSubmitted: _onBarcodeSubmitted,
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Badge de atajo F10
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(Icons.keyboard, size: 16, color: AppColors.primary),
                                            SizedBox(width: 6),
                                            Text(
                                              'F10: Facturar',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
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
                              const SizedBox(height: 10),

                              // Filtros Rápidos de Categoría
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    _buildCategoryChip('Todas'),
                                    _buildCategoryChip('Textos Escolares'),
                                    _buildCategoryChip('Textos Universitarios'),
                                    _buildCategoryChip('Literatura y Ficción'),
                                    _buildCategoryChip('Criptografía e Informática'),
                                    _buildCategoryChip('Papelería y Oficina'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Grilla de Productos Rápidos
                              Expanded(
                                child: _buildProductsGrid(controller),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),

                        // PANEL DERECHO: Carrito, Cliente SIAT, Pago y Cobro (Flex: 4)
                        Expanded(
                          flex: 4,
                          child: PosCartPanel(controller: controller),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String categoria) {
    final isSelected = _selectedCategoriaFiltro == categoria;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(categoria),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategoriaFiltro = categoria;
          });
        },
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
      ),
    );
  }

  Widget _buildProductsGrid(SalesPurchasesController controller) {
    var displayList = controller.filteredProducts;

    if (_selectedCategoriaFiltro != 'Todas') {
      displayList = displayList
          .where((p) => p.categoria == _selectedCategoriaFiltro)
          .toList();
    }

    if (displayList.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            const Text(
              'No se encontraron productos coincidentes',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth >= 900 ? 3 : 2;

        return GridView.builder(
          itemCount: displayList.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 200,
          ),
          itemBuilder: (context, index) {
            final product = displayList[index];
            return PosProductCard(
              product: product,
              onAdd: () => controller.addToCart(product),
            );
          },
        );
      },
    );
  }
}
