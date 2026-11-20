import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Modelo para los ítems de navegación en el menú del sistema.
class NavigationMenuItem {
  final String id;
  final String title;
  final IconData icon;
  final String section;

  const NavigationMenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.section,
  });
}

/// Definición de grupos y opciones del menú jerárquico.
class NavigationStructure {
  static const List<Map<String, dynamic>> groups = [
    {
      'title': 'SEGURIDAD Y ACCESOS',
      'items': [
        NavigationMenuItem(
          id: 'sec_modulo',
          title: 'Módulo Integral (Tabs)',
          icon: Icons.shield_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_dashboard',
          title: 'Dashboard Telemetría',
          icon: Icons.dashboard_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_usuarios',
          title: '1. Usuarios y Personal',
          icon: Icons.people_alt_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_rbac',
          title: '2. Control RBAC',
          icon: Icons.admin_panel_settings_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_politicas',
          title: '3. Políticas & Bloqueo',
          icon: Icons.lock_clock_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_sesiones',
          title: '4. Sesiones & Geo',
          icon: Icons.devices_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_worm',
          title: '5. Bitácora WORM',
          icon: Icons.history_edu_outlined,
          section: 'Seguridad y Accesos',
        ),
        NavigationMenuItem(
          id: 'sec_respaldos',
          title: '6. Respaldos & Recovery',
          icon: Icons.backup_outlined,
          section: 'Seguridad y Accesos',
        ),
      ],
    },
    {
      'title': 'ADMINISTRACIÓN',
      'items': [
        NavigationMenuItem(
          id: 'adm_dashboard',
          title: 'Dashboard',
          icon: Icons.space_dashboard_outlined,
          section: 'Administración',
        ),
        NavigationMenuItem(
          id: 'adm_sucursales',
          title: 'Sucursales',
          icon: Icons.store_mall_directory_outlined,
          section: 'Administración',
        ),
        NavigationMenuItem(
          id: 'adm_catalogo',
          title: 'Catálogo SKU',
          icon: Icons.inventory_2_outlined,
          section: 'Administración',
        ),
        NavigationMenuItem(
          id: 'adm_siat',
          title: 'Parametrización Fiscal SIAT',
          icon: Icons.receipt_long_outlined,
          section: 'Administración',
        ),
      ],
    },
    {
      'title': 'COMPRA Y VENTA',
      'items': [
        NavigationMenuItem(
          id: 'cv_dashboard',
          title: 'Dashboard',
          icon: Icons.analytics_outlined,
          section: 'Compra y Venta',
        ),
        NavigationMenuItem(
          id: 'cv_pos',
          title: 'Punto de Venta (POS)',
          icon: Icons.point_of_sale_outlined,
          section: 'Compra y Venta',
        ),
        NavigationMenuItem(
          id: 'cv_kardex',
          title: 'Inventario Kárdex PEPS',
          icon: Icons.table_chart_outlined,
          section: 'Compra y Venta',
        ),
        NavigationMenuItem(
          id: 'cv_cif',
          title: 'Órdenes CIF',
          icon: Icons.local_shipping_outlined,
          section: 'Compra y Venta',
        ),
        NavigationMenuItem(
          id: 'cv_proveedores',
          title: 'Proveedores',
          icon: Icons.business_outlined,
          section: 'Compra y Venta',
        ),
      ],
    },
    {
      'title': 'REPORTES',
      'items': [
        NavigationMenuItem(
          id: 'rep_dashboard',
          title: 'Dashboard',
          icon: Icons.insert_chart_outlined,
          section: 'Reportes',
        ),
        NavigationMenuItem(
          id: 'rep_ventas',
          title: 'Reporte Ventas',
          icon: Icons.trending_up_outlined,
          section: 'Reportes',
        ),
        NavigationMenuItem(
          id: 'rep_compras',
          title: 'Reporte Compras',
          icon: Icons.shopping_cart_outlined,
          section: 'Reportes',
        ),
        NavigationMenuItem(
          id: 'rep_stock',
          title: 'Stock Semafórico',
          icon: Icons.traffic_outlined,
          section: 'Reportes',
        ),
      ],
    },
  ];

  static List<NavigationMenuItem> get allItems {
    final List<NavigationMenuItem> list = [];
    for (final group in groups) {
      list.addAll(group['items'] as List<NavigationMenuItem>);
    }
    return list;
  }
}

/// AppShell Maestro Reutilizable para la aplicación web y de escritorio.
class AppShellScreen extends StatefulWidget {
  final Widget? customBody;
  final Map<String, WidgetBuilder>? viewRegistry;
  final String? initialItemId;

  const AppShellScreen({
    super.key,
    this.customBody,
    this.viewRegistry,
    this.initialItemId,
  });

  static AppShellScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppShellScreenState>();
  }

  @override
  AppShellScreenState createState() => AppShellScreenState();
}

class AppShellScreenState extends State<AppShellScreen> {
  // Estado de navegación
  late String _activeItemId;
  bool _sidebarExpanded = true;

  void navigateTo(String itemId) {
    if (NavigationStructure.allItems.any((item) => item.id == itemId)) {
      setState(() {
        _activeItemId = itemId;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _activeItemId = widget.initialItemId ?? 'sec_dashboard';
  }

  // Estado de Top App Bar
  String _selectedBranch = 'Sede Central Santa Cruz';
  final List<String> _branches = const [
    'Sede Central Santa Cruz',
    'Agencia La Guardia',
  ];

  // Estado de grupos de menú expandidos en el sidebar
  final Map<String, bool> _groupExpansion = {
    'SEGURIDAD Y ACCESOS': true,
    'ADMINISTRACIÓN': true,
    'COMPRA Y VENTA': true,
    'REPORTES': true,
  };

  NavigationMenuItem get _activeItem {
    return NavigationStructure.allItems.firstWhere(
      (item) => item.id == _activeItemId,
      orElse: () => NavigationStructure.allItems.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          // A) PERSISTENT NAVIGATION RAIL / SIDEBAR (Izquierda)
          _buildSidebar(context),

          // Contenedor Principal (Top Bar + Body)
          Expanded(
            child: Column(
              children: [
                // B) TOP APP BAR CUSTOM
                _buildTopAppBar(context, isDesktop),

                // C) BODY DINÁMICO (IndexedStack o Custom View)
                Expanded(
                  child: Container(
                    color: AppColors.background,
                    padding: const EdgeInsets.all(24.0),
                    child: widget.customBody ?? _buildDynamicBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // A) SIDEBAR (Navigation Rail Extendido)
  // ===========================================================================
  Widget _buildSidebar(BuildContext context) {
    final width = _sidebarExpanded ? 280.0 : 76.0;

    return ClipRect(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        decoration: const BoxDecoration(
          color: AppColors.sidebarBackground,
          border: Border(
            right: BorderSide(color: Color(0xFF1E293B), width: 1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header del Sidebar
            _buildSidebarHeader(),

            const Divider(color: Color(0xFF1E293B), height: 1),

            // Menú Jerárquico Agrupado
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                children: [
                  for (final group in NavigationStructure.groups)
                    _buildMenuGroup(group),
                ],
              ),
            ),

            const Divider(color: Color(0xFF1E293B), height: 1),

            // Footer del Sidebar
            _buildSidebarFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 180;
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 8 : 16,
            vertical: 18,
          ),
          child: Row(
            mainAxisAlignment:
                isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu_book,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              if (!isCompact) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'LIBRERÍA SAN MARTÍN',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.sidebarText,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'ERP Integral & Criptografía',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.sidebarTextMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuGroup(Map<String, dynamic> group) {
    final title = group['title'] as String;
    final items = group['items'] as List<NavigationMenuItem>;
    final isExpanded = _groupExpansion[title] ?? true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 180;
        if (isCompact) {
          // Vista colapsada: iconos centrados
          return Column(
            children: [
              const SizedBox(height: 8),
              for (final item in items) _buildCollapsedMenuItem(item),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () {
                  setState(() {
                    _groupExpansion[title] = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.sidebarTextMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 14,
                        color: AppColors.sidebarTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded)
                for (final item in items) _buildExpandedMenuItem(item),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpandedMenuItem(NavigationMenuItem item) {
    final isSelected = item.id == _activeItemId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () {
            setState(() => _activeItemId = item.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sidebarItemActive : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.sidebarTextMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : AppColors.sidebarText,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedMenuItem(NavigationMenuItem item) {
    final isSelected = item.id == _activeItemId;

    return Tooltip(
      message: '${item.section}: ${item.title}',
      preferBelow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => setState(() => _activeItemId = item.id),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.sidebarItemActive : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              item.icon,
              size: 20,
              color: isSelected ? Colors.white : AppColors.sidebarTextMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 180;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: isCompact
              ? const Center(
                  child: Text(
                    'v1.4.2',
                    style: TextStyle(
                      color: AppColors.sidebarTextMuted,
                      fontSize: 10,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Chip RLS Supabase Activo
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14532D).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.optimal.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '●',
                              style: TextStyle(
                                color: AppColors.optimal,
                                fontSize: 7,
                              ),
                            ),
                            SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                'RLS Supabase Activo',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Color(0xFF86EFAC),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Versión del ERP
                    const Text(
                      'v1.4.2',
                      style: TextStyle(
                        color: AppColors.sidebarTextMuted,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  // ===========================================================================
  // B) TOP APP BAR CUSTOM
  // ===========================================================================
  Widget _buildTopAppBar(BuildContext context, bool isDesktop) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Botón Colapsar/Expandir Sidebar
          IconButton(
            icon: Icon(
              _sidebarExpanded ? Icons.menu_open : Icons.menu,
              size: 20,
              color: AppColors.textSecondary,
            ),
            tooltip: _sidebarExpanded ? 'Colapsar barra' : 'Expandir barra',
            onPressed: () {
              setState(() => _sidebarExpanded = !_sidebarExpanded);
            },
          ),
          const SizedBox(width: 8),

          // Breadcrumbs activos
          if (isDesktop) ...[
            Text(
              _activeItem.section,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '/',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            Text(
              _activeItem.title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],

          const Spacer(),

          // Controles del lado derecho con Scroll Horizontal protegido
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Dropdown Interactivo de Sucursal Activa
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedBranch,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                        items: _branches.map((branch) {
                          return DropdownMenuItem<String>(
                            value: branch,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.storefront_outlined,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(branch),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newBranch) {
                          if (newBranch != null) {
                            setState(() => _selectedBranch = newBranch);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 2. Chip Indicador de Caja
                  if (isDesktop) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Caja 01 - Turno Mañana | Bs 350.00',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // 3. Badge en Vivo: '● Supabase Realtime • TLS 1.3'
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.optimalBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '●',
                          style: TextStyle(
                            color: AppColors.optimal,
                            fontSize: 8,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Supabase Realtime • TLS 1.3',
                          style: TextStyle(
                            color: AppColors.optimalText,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Separador vertical
                  Container(
                    height: 28,
                    width: 1,
                    color: AppColors.borderLight,
                  ),
                  const SizedBox(width: 16),

                  // 4. Perfil de Usuario
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 17,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          'GG',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      if (isDesktop) ...[
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Lic. G. Guachalla',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Admin TI',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // C) BODY DINÁMICO
  // ===========================================================================
  Widget _buildDynamicBody() {
    final item = _activeItem;

    return IndexedStack(
      index: NavigationStructure.allItems.indexOf(item),
      children: [
        for (final navItem in NavigationStructure.allItems)
          widget.viewRegistry != null && widget.viewRegistry!.containsKey(navItem.id)
              ? Builder(
                  builder: (itemContext) =>
                      widget.viewRegistry![navItem.id]!(itemContext),
                )
              : _buildModulePlaceholder(navItem),
      ],
    );
  }

  Widget _buildModulePlaceholder(NavigationMenuItem item) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del Módulo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Módulo de ${item.section} | Sucursal: $_selectedBranch',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Sincronizar'),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tarjetas métricas de estado (KPIs del sistema)
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Estado del Servicio',
                  value: 'Operativo 100%',
                  badgeText: 'ÓPTIMO',
                  badgeColor: AppColors.optimal,
                  badgeBg: AppColors.optimalBg,
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Criptografía & WORM',
                  value: 'SHA-256 Inmutable',
                  badgeText: 'VERIFICADO',
                  badgeColor: AppColors.primary,
                  badgeBg: const Color(0xFFEFF6FF),
                  icon: Icons.security_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  title: 'Almacenamiento Local',
                  value: 'IndexedDB / Cache',
                  badgeText: 'SINCRONIZADO',
                  badgeColor: AppColors.warning,
                  badgeBg: AppColors.warningBg,
                  icon: Icons.cloud_sync_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Contenedor principal de contenido del módulo
          Card(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.icon, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Panel de Control: ${item.title}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Gestión bajo arquitectura desacoplada (Clean Architecture + EDA) para la Librería San Martín.',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppColors.borderLight),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.borderLight,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 48,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Área de trabajo para "${item.title}"',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Listo para conectar con los casos de uso y repositorios de su feature correspondiente.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Icon(icon, size: 18, color: AppColors.textMuted),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
