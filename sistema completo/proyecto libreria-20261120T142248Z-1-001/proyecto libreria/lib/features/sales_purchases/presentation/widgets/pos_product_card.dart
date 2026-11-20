import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sales_purchases_entities.dart';

class PosProductCard extends StatelessWidget {
  final PosProductEntity product;
  final VoidCallback onAdd;

  const PosProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final estaAgotado = product.estaAgotado;
    final stockCritico = product.stockCritico;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: estaAgotado
              ? AppColors.critical.withValues(alpha: 0.3)
              : stockCritico
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : AppColors.borderLight,
        ),
      ),
      color: estaAgotado ? const Color(0xFFFFF1F2) : Colors.white,
      child: InkWell(
        onTap: estaAgotado ? null : onAdd,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Encabezado con Icono y Badge de Stock
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: estaAgotado
                          ? AppColors.critical.withValues(alpha: 0.1)
                          : AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book_outlined,
                      color: estaAgotado ? AppColors.critical : AppColors.primary,
                      size: 20,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: estaAgotado
                          ? AppColors.criticalBg
                          : stockCritico
                              ? AppColors.warningBg
                              : AppColors.optimalBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      estaAgotado
                          ? 'AGOTADO'
                          : stockCritico
                              ? 'CRÍTICO: ${product.stockDisponible}'
                              : 'STOCK: ${product.stockDisponible}',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: estaAgotado
                            ? AppColors.criticalText
                            : stockCritico
                                ? AppColors.warningText
                                : AppColors.optimalText,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Título y Editorial
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: estaAgotado ? AppColors.textMuted : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.editorial} • ${product.categoria}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Precio y Botón Agregar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Precio Venta',
                        style: TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                      Text(
                        'Bs ${product.precioVenta.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: estaAgotado ? AppColors.textMuted : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      estaAgotado ? Icons.block : Icons.add_shopping_cart,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: estaAgotado
                          ? AppColors.borderLight
                          : AppColors.primary,
                      foregroundColor: estaAgotado
                          ? AppColors.textMuted
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                    ),
                    onPressed: estaAgotado ? null : onAdd,
                    tooltip: estaAgotado ? 'Producto agotado' : 'Agregar al carrito',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
