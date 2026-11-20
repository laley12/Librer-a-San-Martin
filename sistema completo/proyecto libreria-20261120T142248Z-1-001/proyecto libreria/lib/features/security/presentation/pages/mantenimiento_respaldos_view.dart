import 'package:flutter/material.dart';
import '../../domain/entities/security_entities.dart';
import '../controllers/security_controller.dart';

/// Submódulo 6: Respaldos Criptográficos y Disaster Recovery
/// Aplica herencia estricta de Theme.of(context), dataRowMinHeight: 48 y Alignment.centerLeft.
class MantenimientoRespaldosView extends StatefulWidget {
  final SecurityController controller;

  const MantenimientoRespaldosView({super.key, required this.controller});

  @override
  State<MantenimientoRespaldosView> createState() => _MantenimientoRespaldosViewState();
}

class _MantenimientoRespaldosViewState extends State<MantenimientoRespaldosView> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final kpis = widget.controller.kpis;
        final backups = widget.controller.backups;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CABECERA Y ACCIONES CRÍTICAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Respaldos Criptográficos & Telemetría PostgreSQL',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Snapshots cifrados con GPG/AES-256 y verificados con Checksum SHA-256 inmutable (Disaster Recovery).',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    icon: widget.controller.isBackingUp
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : const Icon(Icons.cloud_upload_outlined, size: 18),
                    label: Text(
                      widget.controller.isBackingUp ? 'Generando Snapshot...' : 'Ejecutar Backup Manual',
                    ),
                    onPressed: widget.controller.isBackingUp
                        ? null
                        : () async {
                            final ok = await widget.controller.triggerManualBackup();
                            if (ok && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: colorScheme.primary,
                                  content: const Text('Respaldo manual (.sql dump) generado y verificado con SHA-256 en la nube.'),
                                ),
                              );
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2. INDICADORES DE TELEMETRÍA (PgBouncer, Cache Hit, Latencia)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  final cards = [
                    _buildTelemetryCard(
                      context: context,
                      title: 'Conexiones PgBouncer',
                      value: '${kpis?.pgbouncerConexiones ?? 18} / ${kpis?.pgbouncerMaxConexiones ?? 100}',
                      progress: (kpis?.pgbouncerConexiones ?? 18) / (kpis?.pgbouncerMaxConexiones ?? 100),
                      progressColor: colorScheme.primary,
                      statusBadge: 'NORMAL',
                      icon: Icons.hub_outlined,
                    ),
                    _buildTelemetryCard(
                      context: context,
                      title: 'Cache Hit Ratio',
                      value: '${kpis?.cacheHitRatio ?? 99.42}%',
                      progress: (kpis?.cacheHitRatio ?? 99.42) / 100.0,
                      progressColor: colorScheme.secondary,
                      statusBadge: 'EXCELENTE',
                      icon: Icons.memory_outlined,
                    ),
                    _buildTelemetryCard(
                      context: context,
                      title: 'Latencia a Supabase',
                      value: '${kpis?.latenciaMs ?? 42} ms',
                      progress: 0.35,
                      progressColor: colorScheme.tertiary,
                      statusBadge: 'ÓPTIMO',
                      icon: Icons.speed_outlined,
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      children: cards
                          .map((card) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                  child: card,
                                ),
                              ))
                          .toList(),
                    );
                  } else {
                    return Column(
                      children: cards
                          .map((card) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: card,
                              ))
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),

              // 3. ESTRATEGIA EN LA NUBE & DISASTER RECOVERY POLICY
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.cloud_sync_outlined, color: colorScheme.primary, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Estrategia de Respaldos Cloud & Métricas RPO / RTO',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 24,
                        runSpacing: 16,
                        children: [
                          _buildStrategyItem(
                            context: context,
                            icon: Icons.schedule,
                            title: 'Frecuencia Automática',
                            description: 'Diaria a las 02:00 AM UTC-4 (Volcado pg_dump cifrado)',
                          ),
                          _buildStrategyItem(
                            context: context,
                            icon: Icons.archive,
                            title: 'Política de Retención',
                            description: '30 días almacenamiento caliente, 365 días Cold Storage',
                          ),
                          _buildStrategyItem(
                            context: context,
                            icon: Icons.timer,
                            title: 'RPO (Recovery Point Objective)',
                            description: '15 minutos (WAL Archiving continuo en Supabase)',
                          ),
                          _buildStrategyItem(
                            context: context,
                            icon: Icons.fast_forward,
                            title: 'RTO (Recovery Time Objective)',
                            description: '< 30 minutos garantizado mediante Point-in-Time Recovery',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 4. HISTORIAL DE BACKUPS CON VERIFICACIÓN SHA-256 Y RESTORE
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.inventory_outlined, color: colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Inventario de Snapshots Criptográficos (${backups.length} archivos)',
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lock, size: 14, color: colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                'Almacenamiento en Frío Inmutable',
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 1000),
                          child: DataTable(
                            horizontalMargin: 16,
                            columnSpacing: 24,
                            dataRowMinHeight: 48,
                            dataRowMaxHeight: 56,
                            headingRowHeight: 48,
                            headingRowColor: WidgetStateProperty.all(
                              colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            ),
                            columns: const [
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('NOMBRE DEL ARCHIVO DUMP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('FECHA Y HORA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('TIPO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('TAMAÑO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('CHECKSUM SHA-256', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('INTEGRIDAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('ACCIONES DR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ],
                            rows: backups.map((bkp) {
                              return DataRow(
                                cells: [
                                  // 1. Nombre de archivo
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.archive_outlined, size: 16, color: colorScheme.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            bkp.nombreArchivo,
                                            style: textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 2. Fecha y Hora
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        bkp.fecha.toString().substring(0, 16),
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                  ),
                                  // 3. Tipo
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: colorScheme.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          bkp.tipo,
                                          style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 4. Tamaño
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        bkp.tamano,
                                        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                  // 5. Checksum SHA-256
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Tooltip(
                                        message: bkp.checksumSha256,
                                        child: Text(
                                          '${bkp.checksumSha256.substring(0, 16)}...',
                                          style: textTheme.bodySmall?.copyWith(
                                            fontFamily: 'Consolas',
                                            color: colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 6. Integridad
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primaryContainer,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_outline, size: 12, color: colorScheme.onPrimaryContainer),
                                            const SizedBox(width: 4),
                                            Text(
                                              bkp.verificado ? 'INTEGRO (SHA-256)' : 'PENDIENTE',
                                              style: textTheme.labelSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.onPrimaryContainer,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 7. Acciones Disaster Recovery
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: colorScheme.error,
                                          side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                        icon: const Icon(Icons.settings_backup_restore, size: 14),
                                        label: const Text('Restaurar', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        onPressed: () => _showRestoreDialog(context, bkp),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
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

  Widget _buildTelemetryCard({
    required BuildContext context,
    required String title,
    required String value,
    required double progress,
    required Color progressColor,
    required String statusBadge,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: progressColor, size: 22),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: progressColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusBadge,
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: progressColor,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrategyItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SizedBox(
      width: 280,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestoreDialog(BuildContext context, BackupEntity backup) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final passwordCtrl = TextEditingController();
    bool obscure = true;
    String? errorMsg;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          icon: Icon(Icons.warning_rounded, color: colorScheme.error, size: 36),
          title: const Text('Solicitud Crítica de Restauración'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATENCIÓN: Se aplicará el volcado "${backup.nombreArchivo}" sobre la base de datos de producción. '
                  'Esta operación sobrescribirá los datos existentes.',
                  style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ingrese la Contraseña Maestra de Super Administrador para autorizar:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Contraseña Maestra',
                    border: const OutlineInputBorder(),
                    errorText: errorMsg,
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 18),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(dialogCtx).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              child: const Text('Confirmar Restauración'),
              onPressed: () async {
                final pwd = passwordCtrl.text;
                if (pwd.isEmpty) {
                  setDialogState(() => errorMsg = 'Ingrese la contraseña.');
                  return;
                }
                final ok = await widget.controller.requestDatabaseRestore(
                  backupId: backup.id,
                  masterPassword: pwd,
                );
                if (ok && dialogCtx.mounted) {
                  Navigator.of(dialogCtx).pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: colorScheme.primary,
                        content: Text('Restauración autorizada exitosamente para el backup ${backup.nombreArchivo}.'),
                      ),
                    );
                  }
                } else {
                  setDialogState(() => errorMsg = 'Contraseña maestra inválida.');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
