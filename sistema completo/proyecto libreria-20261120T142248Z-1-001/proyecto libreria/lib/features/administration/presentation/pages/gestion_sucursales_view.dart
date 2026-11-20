import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/admin_entities.dart';
import '../controllers/administration_controller.dart';
import '../widgets/alta_sucursal_dialog.dart';
import '../widgets/editar_sucursal_dialog.dart';

/// Vista: Gestión de Sucursales de la Librería San Martín
/// Incluye alta, edición, auditoría de cuentas/activos, baja condicionada y reactivación.
class GestionSucursalesView extends StatelessWidget {
  final AdministrationController controller;

  const GestionSucursalesView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final branches = controller.branches;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera con Botones de Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Red de Sucursales y Puntos de Venta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Control físico de agencias, aforo en m², cajas POS, auditoría de pasivos/activos y estado operativo.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Actualizar'),
                        onPressed: () => controller.loadBranches(),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_business_outlined, size: 16),
                        label: const Text('Nueva Sucursal'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AltaSucursalDialog(controller: controller),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // GridView Responsivo de Sucursales
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth >= 900 ? 2 : 1;

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: branches.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 18,
                      mainAxisSpacing: 18,
                      mainAxisExtent: 520,
                    ),
                    itemBuilder: (context, index) {
                      return _buildBranchCard(context, branches[index]);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBranchCard(BuildContext context, BranchEntity branch) {
    final isOperativa = branch.activa;
    final ocupacionPorcentaje = branch.ocupacionPorcentaje;
    final colorOcupacion = ocupacionPorcentaje > 0.8
        ? AppColors.critical
        : ocupacionPorcentaje > 0.6
            ? AppColors.warning
            : AppColors.optimal;

    return Card(
      elevation: isOperativa ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isOperativa ? AppColors.borderLight : AppColors.critical.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. Cabecera de la Tarjeta con Estado
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isOperativa ? AppColors.primaryContainer : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.storefront,
                          color: isOperativa ? AppColors.primary : AppColors.textMuted,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              branch.nombre,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isOperativa ? AppColors.textPrimary : AppColors.textMuted,
                                decoration: isOperativa ? null : TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              branch.ciudad,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOperativa ? AppColors.optimalBg : AppColors.criticalBg,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isOperativa ? AppColors.optimal.withValues(alpha: 0.3) : AppColors.critical.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    isOperativa ? 'OPERATIVA' : 'DADA DE BAJA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isOperativa ? AppColors.optimalText : AppColors.criticalText,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: AppColors.borderLight, height: 16),

            // 2. Encargado y Dirección
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    branch.direccion,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.badge_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Encargado: ${branch.encargado}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 3. Métricas Operativas: Cajas POS y Aforo m2
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cajas POS',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${branch.cajasPosAsignadas} terminales',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aforo Total',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${branch.aforoM2.toInt()} m²',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 4. Panel de Auditoría para Directriz de Baja (Cuentas y Activos)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isOperativa
                    ? (branch.puedeDarseDeBaja
                        ? AppColors.optimalBg.withValues(alpha: 0.5)
                        : AppColors.warningBg.withValues(alpha: 0.6))
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isOperativa
                      ? (branch.puedeDarseDeBaja
                          ? AppColors.optimal.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.4))
                      : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        branch.puedeDarseDeBaja ? Icons.check_circle_outline : Icons.shield_outlined,
                        size: 14,
                        color: branch.puedeDarseDeBaja ? AppColors.optimalText : AppColors.warningText,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Auditoría y Directrices de Baja:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: branch.puedeDarseDeBaja ? AppColors.optimalText : AppColors.warningText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      // Cuentas pendientes
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            branch.tieneCuentasPendientes ? Icons.cancel_outlined : Icons.check_circle,
                            size: 13,
                            color: branch.tieneCuentasPendientes ? AppColors.critical : AppColors.optimal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.tieneCuentasPendientes
                                ? 'Cuentas: Bs ${branch.cuentasPendientes.toStringAsFixed(2)}'
                                : 'Cuentas: Bs 0.00 (Al día)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: branch.tieneCuentasPendientes ? AppColors.criticalText : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      // Activos asignados
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            branch.tieneActivosAsignados ? Icons.cancel_outlined : Icons.check_circle,
                            size: 13,
                            color: branch.tieneActivosAsignados ? AppColors.critical : AppColors.optimal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            branch.tieneActivosAsignados
                                ? 'Activos: ${branch.activosAsignados} ítems'
                                : 'Activos: 0 ítems',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: branch.tieneActivosAsignados ? AppColors.criticalText : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 5. Ocupación y Bodegas
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ocupación de Almacén / Sala:',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${(ocupacionPorcentaje * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorOcupacion,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: ocupacionPorcentaje,
                    minHeight: 5,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(colorOcupacion),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.warehouse_outlined, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Bodegas: ${branch.bodegasVinculadas.join(', ')}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),

            // Si está dada de baja, mostrar detalle del cierre
            if (!isOperativa) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.criticalBg.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 14, color: AppColors.critical),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Motivo de baja: ${branch.motivoBaja ?? "Cierre administrativo"}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: AppColors.criticalText),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 10),

            // 6. Botones de Acción
            if (isOperativa) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.edit_outlined, size: 15),
                      label: const Text('Editar', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => EditarSucursalDialog(
                            branch: branch,
                            controller: controller,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: branch.puedeDarseDeBaja ? AppColors.critical : AppColors.surfaceVariant,
                        foregroundColor: branch.puedeDarseDeBaja ? Colors.white : AppColors.textMuted,
                        elevation: 0,
                      ),
                      icon: Icon(
                        branch.puedeDarseDeBaja ? Icons.remove_circle_outline : Icons.lock_outline,
                        size: 15,
                      ),
                      label: const Text('Dar de Baja', style: TextStyle(fontSize: 12)),
                      onPressed: () {
                        if (branch.puedeDarseDeBaja) {
                          _mostrarDialogoConfirmarBaja(context, branch);
                        } else {
                          _mostrarAlertaRestriccionBaja(context, branch);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Reactivar Sucursal'),
                  onPressed: () async {
                    final ok = await controller.reactivateBranch(branch.id);
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.optimal,
                          content: Text('Sucursal "${branch.nombre}" reactivada con éxito.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Muestra el modal de BLOQUEO ESTRICTO cuando la sucursal no cumple las condiciones de baja.
  /// Explica en detalle las cuentas pendientes y los activos que impiden la acción.
  void _mostrarAlertaRestriccionBaja(BuildContext context, BranchEntity branch) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.criticalBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.gavel_rounded, color: AppColors.critical, size: 26),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Acción Denegada: Restricción de Auditoría',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Cierre físico y baja de sucursal bloqueada',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No es posible dar de baja la sucursal "${branch.nombre}" debido a que no cumple con las directrices contables y de custodia de activos de la empresa:',
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 14),

                  // Bloque de Cuentas Pendientes
                  if (branch.tieneCuentasPendientes)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.criticalBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.receipt_long, color: AppColors.critical, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Cuentas y Obligaciones Pendientes',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.criticalText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Registra un balance pendiente de Bs ${branch.cuentasPendientes.toStringAsFixed(2)}. Debe realizar la conciliación contable o el cobro/pago total antes del cierre.',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bloque de Activos Asignados
                  if (branch.tieneActivosAsignados)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.inventory_2_outlined, color: AppColors.warning, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Activos de Inventario en Custodia',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.warningText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tiene ${branch.activosAsignados} ítems/activos asignados en sus bodegas. Debe transferir los ítems a Casa Matriz u otra sucursal activa antes de la baja.',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Acción simulada para facilitar el testeo al usuario
                      TextButton.icon(
                        icon: const Icon(Icons.autorenew, size: 16),
                        label: const Text('Conciliar y Transferir Activos'),
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final ok = await controller.transferirActivosYConciliar(branch.id);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.optimal,
                                content: Text('Cuentas y activos de "${branch.nombre}" conciliados a 0. Ahora es apta para la baja.'),
                              ),
                            );
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Entendido'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Muestra el modal para confirmar la baja formal de la sucursal cuando ya no tiene pasivos ni activos.
  void _mostrarDialogoConfirmarBaja(BuildContext context, BranchEntity branch) {
    final motivoController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AppColors.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.criticalBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.critical, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Baja de ${branch.nombre}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Text(
                                'Directrices contables y de activos verificadas: APTA',
                                style: TextStyle(fontSize: 11.5, color: AppColors.optimalText, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Esta sucursal no tiene cuentas pendientes ni activos asignados. Al confirmarse la baja, pasará a estado inactivo y no podrá facturar ni recibir stock.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Motivo Justificado de la Baja *',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: motivoController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Ej. Vencimiento de contrato de alquiler comercial / Reestructuración.',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Ingrese un motivo justificado' : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.critical),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Confirmar Baja Definitiva'),
                          onPressed: () async {
                            if (formKey.currentState?.validate() ?? false) {
                              Navigator.of(ctx).pop();
                              final ok = await controller.deactivateBranch(
                                branchId: branch.id,
                                motivo: motivoController.text.trim(),
                              );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.optimal,
                                    content: Text('Sucursal "${branch.nombre}" dada de baja correctamente.'),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
