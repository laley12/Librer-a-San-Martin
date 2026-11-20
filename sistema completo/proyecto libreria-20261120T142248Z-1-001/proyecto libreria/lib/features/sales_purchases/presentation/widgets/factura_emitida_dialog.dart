import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/sales_purchases_entities.dart';

class FacturaEmitidaDialog extends StatelessWidget {
  final InvoiceSaleEntity invoice;

  const FacturaEmitidaDialog({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado Fiscal SIAT
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.optimalBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle, color: AppColors.optimal, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'FACTURA ELECTRÓNICA EN LÍNEA',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'LIBRERÍA SAN MARTÍN • NIT: 1029485028',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 10),

              // Datos Técnicos de Facturación
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Factura N°:', invoice.numeroFactura.toString().padLeft(6, '0')),
                      _buildInfoRow('Sucursal:', invoice.sucursal),
                      _buildInfoRow('Fecha Emisión:', '${invoice.fecha.day}/${invoice.fecha.month}/${invoice.fecha.year} ${invoice.fecha.hour.toString().padLeft(2, '0')}:${invoice.fecha.minute.toString().padLeft(2, '0')}'),
                      _buildInfoRow('Cliente / Razón Social:', invoice.cliente.razonSocial),
                      _buildInfoRow('NIT / CI:', invoice.cliente.nitCi),
                      _buildInfoRow('Método de Pago:', invoice.metodoPago.label),
                      const SizedBox(height: 10),

                      // CUF Inmutable
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CÓDIGO ÚNICO DE FACTURACIÓN (CUF):',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              invoice.cuf,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Color(0xFF38BDF8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Detalle de Ítems
                      const Text(
                        'DETALLE DE PRODUCTOS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...invoice.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Text(
                                    '${item.cantidad}x ${item.product.titulo}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Bs ${item.product.precioVenta.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    'Bs ${item.subtotal.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Divider(color: AppColors.borderLight, height: 20),

                      // Totales y Cambio
                      _buildTotalRow('TOTAL BS:', 'Bs ${invoice.total.toStringAsFixed(2)}', isHighlight: true),
                      if (invoice.metodoPago == PaymentMethod.efectivo) ...[
                        _buildTotalRow('Efectivo Recibido:', 'Bs ${invoice.montoRecibido.toStringAsFixed(2)}'),
                        _buildTotalRow('Cambio a Devolver:', 'Bs ${invoice.cambio.toStringAsFixed(2)}', isChange: true),
                      ],
                      const SizedBox(height: 16),

                      // Banner SIAT
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.optimalBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.optimal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: AppColors.optimal, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Documento Fiscal emitido conforme a la R.N.D. SIAT Impuestos Nacionales de Bolivia.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.optimalText,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Botones de Acción
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Imprimir Ticket'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enviando factura a impresora térmica POS...')),
                        );
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Aceptar y Continuar'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isHighlight = false, bool isChange = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              fontWeight: isHighlight || isChange ? FontWeight.w800 : FontWeight.w600,
              color: isChange ? AppColors.optimal : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 17 : 13,
              fontWeight: FontWeight.w800,
              color: isHighlight
                  ? AppColors.primary
                  : isChange
                      ? AppColors.optimal
                      : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
