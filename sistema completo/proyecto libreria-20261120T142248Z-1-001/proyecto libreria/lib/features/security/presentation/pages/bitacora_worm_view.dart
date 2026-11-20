import 'package:flutter/material.dart';
import '../../domain/entities/security_entities.dart';
import '../controllers/security_controller.dart';
import '../widgets/jsonb_payload_dialog.dart';

/// Submódulo 5: Bitácora Forense Inmutable (WORM) y Auditoría (Norma ISO/IEC 27001)
/// Aplica herencia estricta de Theme.of(context), dataRowMinHeight: 48 y Alignment.centerLeft.
class BitacoraWormView extends StatefulWidget {
  final SecurityController controller;

  const BitacoraWormView({super.key, required this.controller});

  @override
  State<BitacoraWormView> createState() => _BitacoraWormViewState();
}

class _BitacoraWormViewState extends State<BitacoraWormView> {
  String _selectedSeverity = 'Todas';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        var logs = widget.controller.wormLogs;

        // Filtrado local por severidad y búsqueda
        if (_selectedSeverity != 'Todas') {
          logs = logs.where((l) => l.severidad.name.toLowerCase() == _selectedSeverity.toLowerCase()).toList();
        }
        if (_searchQuery.trim().isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          logs = logs.where((l) =>
            l.usuario.toLowerCase().contains(q) ||
            l.modulo.toLowerCase().contains(q) ||
            l.operacion.toLowerCase().contains(q) ||
            l.hashSha256.toLowerCase().contains(q)
          ).toList();
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BANNER SUPERIOR DE ADVERTENCIA TÉCNICA (POSTGRESQL WORM)
              Card(
                color: colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.6)),
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.4)),
                        ),
                        child: Icon(Icons.security, color: colorScheme.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'AUDITORÍA FORENSE WORM (WRITE ONCE, READ MANY)',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '• ISO/IEC 27001 COMPLIANT',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSecondaryContainer,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Esta tabla está protegida por el trigger de base de datos "trg_bitacora_inmutable" en PostgreSQL. '
                              'Cualquier intento de UPDATE, TRUNCATE o DELETE es rechazado a nivel de motor de base de datos con una excepción SQLSTATE 42501 (privilegio insuficiente). '
                              'Todos los registros cuentan con encadenamiento criptográfico SHA-256 inmutable.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 2. BARRA DE HERRAMIENTAS Y FILTROS AVANZADOS
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.4)),
                ),
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Buscador por Operador / Término
                      SizedBox(
                        width: 260,
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Filtrar por operador o acción...',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                          onChanged: (val) => setState(() => _searchQuery = val),
                        ),
                      ),

                      // Filtro por Módulo
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: widget.controller.wormModuleFilter,
                            items: const [
                              DropdownMenuItem(value: 'Todos', child: Text('Todos los Módulos')),
                              DropdownMenuItem(value: 'AUTH_SECURITY', child: Text('AUTH_SECURITY')),
                              DropdownMenuItem(value: 'VENTAS_SIAT', child: Text('VENTAS_SIAT')),
                              DropdownMenuItem(value: 'AUTH_BRUTE_FORCE', child: Text('AUTH_BRUTE_FORCE')),
                              DropdownMenuItem(value: 'INVENTARIO_KARDEX', child: Text('INVENTARIO_KARDEX')),
                            ],
                            onChanged: (val) => widget.controller.filterWormLogs(modulo: val),
                          ),
                        ),
                      ),

                      // Filtro por Severidad
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSeverity,
                            items: const [
                              DropdownMenuItem(value: 'Todas', child: Text('Todas las Severidades')),
                              DropdownMenuItem(value: 'critico', child: Text('CRÍTICO')),
                              DropdownMenuItem(value: 'advertencia', child: Text('ADVERTENCIA')),
                              DropdownMenuItem(value: 'info', child: Text('INFO')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedSeverity = val);
                            },
                          ),
                        ),
                      ),

                      // Botón Recargar Traza
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Actualizar Traza'),
                        onPressed: () => widget.controller.loadWormLogs(),
                      ),

                      // Botón Exportar CSV Forense
                      OutlinedButton.icon(
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Exportar CSV'),
                        onPressed: () {
                          final csvData = widget.controller.exportWormLogsToCsv();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: colorScheme.primary,
                              content: Text('Volcado forense CSV generado con ${csvData.split('\n').length - 1} eventos firmados.'),
                            ),
                          );
                        },
                      ),

                      // Botón Reporte Forense PDF Certificado
                      ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf, size: 16),
                        label: const Text('Reporte Forense PDF'),
                        onPressed: () {
                          widget.controller.exportWormLogsToPdf();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: colorScheme.primary,
                              content: const Text('Reporte Forense Certificado ISO 27001 generado con sellado temporal UTC-4.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. TABLA CRONOLÓGICA FORENSE
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
                                Icon(Icons.history_edu, color: colorScheme.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Secuencia Cronológica de Eventos Auditados (${logs.length} eventos)',
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
                          Text(
                            'Zona Horaria: UTC-4 (Bolivia)',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
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
                                  child: Text('TIMESTAMP (UTC-4)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('OPERADOR / ORIGEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('MÓDULO & OPERACIÓN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('SEVERIDAD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('HASH SHA-256 (INMUTABLE)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                              DataColumn(
                                label: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('INSPECTOR JSONB', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ),
                            ],
                            rows: logs.map((log) {
                              return DataRow(
                                cells: [
                                  // 1. Timestamp UTC-4
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        log.timestamp.toString().substring(0, 19),
                                        style: textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Consolas',
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 2. Operador / Origen
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        log.usuario,
                                        style: textTheme.bodySmall?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 3. Módulo y Operación
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            log.modulo,
                                            style: textTheme.bodySmall?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            log.operacion,
                                            style: textTheme.labelSmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 4. Chip de Severidad
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: _buildSeverityChip(context, log.severidad),
                                    ),
                                  ),
                                  // 5. Hash SHA-256
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Tooltip(
                                        message: log.hashSha256,
                                        child: Text(
                                          '${log.hashSha256.substring(0, 14)}...',
                                          style: textTheme.bodySmall?.copyWith(
                                            fontFamily: 'Consolas',
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 6. Botón Inspector JSONB
                                  DataCell(
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        ),
                                        icon: const Icon(Icons.code, size: 14),
                                        label: const Text('Ver Payload', style: TextStyle(fontSize: 11)),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => JsonbPayloadDialog(log: log),
                                          );
                                        },
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

  Widget _buildSeverityChip(BuildContext context, WormSeverity severidad) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (severidad) {
      case WormSeverity.critico:
        bg = colorScheme.errorContainer;
        fg = colorScheme.onErrorContainer;
        icon = Icons.error_outline;
        label = 'CRÍTICO';
        break;
      case WormSeverity.advertencia:
        bg = colorScheme.tertiaryContainer;
        fg = colorScheme.onTertiaryContainer;
        icon = Icons.warning_amber_rounded;
        label = 'ALERTA';
        break;
      case WormSeverity.info:
        bg = colorScheme.surfaceContainerHighest;
        fg = colorScheme.onSurfaceVariant;
        icon = Icons.info_outline;
        label = 'INFO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
