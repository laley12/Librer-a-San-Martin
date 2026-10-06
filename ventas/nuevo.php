<?php
date_default_timezone_set('America/La_Paz');
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id_user_venta = intval($_SESSION['id']);

// Verificar caja abierta
$caja_abierta = mysqli_query($conexion, "SELECT id FROM apertura_caja WHERE id_usuario=$id_user_venta AND activo=1 LIMIT 1");
if (!$caja_abierta || mysqli_num_rows($caja_abierta) == 0) {
    header("Location: caja.php?sin_caja=1");
    exit();
}

$productos = mysqli_query($conexion, "SELECT id_producto, nombre_producto, precio, impuesto, stock FROM productos WHERE activo=1 AND stock > 0 ORDER BY nombre_producto ASC");

$venta_ok = isset($_GET['venta_ok']) ? intval($_GET['venta_ok']) : 0;
$venta_data = null;
if ($venta_ok) {
    $r = mysqli_query($conexion, "SELECT v.*, r.numero_recibo FROM ventas v LEFT JOIN recibos r ON v.id_venta = r.venta_id WHERE v.id_venta = $venta_ok LIMIT 1");
    $venta_data = $r ? mysqli_fetch_assoc($r) : null;
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Nueva Venta - Librería San Martín</title>
    <link href="<?php echo BASE_URL; ?>assets/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>assets/css/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
:root {
            --body-bg: #f0f3f8;
            --sidebar-bg: #ffffff;
            --sidebar-text: #1e293b;
            --sidebar-hover-bg: #e2e8f0;
            --sidebar-accent: #1e3c72;
            --sidebar-active-bg: linear-gradient(90deg, rgba(30,60,114,0.12), rgba(42,82,152,0.05));
            --sidebar-brand-bg: linear-gradient(135deg, #1e3c72, #2a5298);
            --topbar-bg: rgba(255,255,255,0.85);
            --panel-bg: #ffffff;
            --panel-header-bg: linear-gradient(135deg, #2a5298, #1e3c72);
            --profile-bg: #f1f5f9;
            --profile-text: #333;
            --sub-item-active-bg: #eef2ff;
            --scrollbar-thumb: rgba(0,0,0,0.12);
            --scrollbar-thumb-hover: rgba(0,0,0,0.25);
            --collapse-line: #cbd5e1;
            --collapse-dash: #94a3b8;
            --border-color: rgba(0,0,0,0.05);
            --form-bg: #fff;
            --form-text: #1e293b;
            --form-border: #d1d5db;
            --form-focus-border: #60a5fa;
            --input-group-bg: #f1f5f9;
            --card-bg: #fff;
        }
[data-theme="dark"] {
            --body-bg: #0f172a;
            --sidebar-bg: #1e293b;
            --sidebar-text: #cbd5e1;
            --sidebar-hover-bg: #334155;
            --sidebar-accent: #60a5fa;
            --sidebar-active-bg: linear-gradient(90deg, rgba(59,130,246,0.15), rgba(37,99,235,0.08));
            --sidebar-brand-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --topbar-bg: rgba(30,41,59,0.95);
            --panel-bg: #1e293b;
            --panel-header-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --profile-bg: #334155;
            --profile-text: #e2e8f0;
            --sub-item-active-bg: #1e3a5f;
            --scrollbar-thumb: rgba(255,255,255,0.15);
            --scrollbar-thumb-hover: rgba(255,255,255,0.25);
            --collapse-line: #475569;
            --collapse-dash: #64748b;
            --border-color: rgba(255,255,255,0.06);
            --form-bg: #1e293b;
            --form-text: #f1f5f9;
            --form-border: #334155;
            --form-focus-border: #60a5fa;
            --input-group-bg: #0f172a;
            --card-bg: #1e293b;
        }
body { background: var(--body-bg); font-family: 'Segoe UI', sans-serif; margin: 0; overflow-x: hidden; }
.sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; transition: all 0.3s ease; }
.sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; }
.sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
.sidebar-menu::-webkit-scrollbar { width: 4px; }
.sidebar-menu::-webkit-scrollbar-track { background: transparent; }
.sidebar-menu::-webkit-scrollbar-thumb { background: var(--scrollbar-thumb); border-radius: 10px; }
.sidebar-menu::-webkit-scrollbar-thumb:hover { background: var(--scrollbar-thumb-hover); }
.sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; cursor: pointer; border-left: 3px solid transparent; }
.sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
.sidebar-menu a:hover { background: var(--sidebar-hover-bg); color: var(--sidebar-accent); border-left-color: var(--sidebar-accent); }
.sidebar-menu a.active { background: var(--sidebar-active-bg); color: var(--sidebar-accent); font-weight: 700; border-left: 4px solid var(--sidebar-accent); box-shadow: inset 0 0 0 1px rgba(30,60,114,0.06); }
.collapse-submenu { position: relative; }
.collapse-submenu::before { content: ''; position: absolute; left: 22px; top: 4px; bottom: 4px; width: 2px; background: var(--collapse-line); border-radius: 2px; }
.collapse-submenu a { padding-left: 45px !important; font-size: 0.9rem !important; position: relative; border-left: none !important; }
.collapse-submenu a::before { content: ''; position: absolute; left: 18px; top: 50%; transform: translateY(-50%); width: 18px; height: 2px; background: var(--collapse-line); border-radius: 1px; }
.collapse-submenu a:hover { background: var(--sidebar-hover-bg); border-left: none !important; }
.collapse-submenu a.sub-item-active { background: var(--sub-item-active-bg); font-weight: 600; color: var(--sidebar-accent); border-radius: 0 8px 8px 0; }
.collapse-submenu-2 { position: relative; }
.collapse-submenu-2::before { content: ''; position: absolute; left: 35px; top: 4px; bottom: 4px; width: 2px; background: repeating-linear-gradient(to bottom, var(--collapse-dash) 0px, var(--collapse-dash) 4px, transparent 4px, transparent 8px); }
.collapse-submenu-2 a { padding-left: 62px !important; font-size: 0.88rem !important; position: relative; }
.collapse-submenu-2 a::before { content: ''; position: absolute; left: 35px; top: 50%; transform: translateY(-50%); width: 20px; height: 0; border-top: 2px dashed var(--collapse-dash); }
.collapse-submenu-2 a:hover { background: var(--sidebar-hover-bg); }
.sub-item-active { color: var(--sidebar-accent) !important; font-weight: 600; background-color: #f8fafc !important; border-left: 3px solid #2a5298; border-radius: 0 8px 8px 0; }
.collapse-toggle { display: flex; justify-content: space-between; align-items: center; }
.collapse-toggle .chevron-icon { font-size: 0.8rem; transition: transform 0.2s ease; }
.collapse-toggle[aria-expanded="true"] .chevron-icon { transform: rotate(180deg); }
.main-content { margin-left: 260px; min-height: 100vh; transition: all 0.3s ease; }
.topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); -webkit-backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 999; }
.topbar-title { font-size: 1.2rem; font-weight: 600; color: var(--sidebar-accent); }
.topbar-widgets { display: flex; align-items: center; gap: 12px; }
.widget-box { padding: 6px 14px; border-radius: 20px; font-size: 0.88rem; font-weight: 600; display: flex; align-items: center; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
.widget-time { background: #e0f2fe; color: #0369a1; }
.widget-date { background: #dcfce7; color: #15803d; }
.widget-weather { background: #fef3c7; color: #d97706; }
.user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: var(--profile-text); }
.profile-avatar-wrap { flex-shrink: 0; margin-right: 10px; display: flex; align-items: center; }
.profile-avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-info { display: flex; flex-direction: column; line-height: 1.2; }
.profile-name { font-size: 0.88rem; white-space: nowrap; }
.profile-role { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; white-space: nowrap; }
.panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; animation: fadeInUp 0.5s ease-in-out; overflow: hidden; }
.panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-radius: 12px 12px 0 0; background: var(--panel-header-bg); display: flex; justify-content: space-between; align-items: center; }
.panel-custom-body { padding: 20px; }
.treeview, .nav-treeview { list-style: none; padding: 0; margin: 0; }
.treeview .treeview-menu { padding-left: 20px; list-style: none; display: none; }
.treeview.menu-open > .treeview-menu { display: block; }
.sidebar.collapsed { width: 70px; }
.sidebar.collapsed .sidebar-brand span.brand-text { display: none; }
.sidebar.collapsed .sidebar-brand { font-size: 1.1rem; padding: 20px 0; text-align: center; }
.sidebar.collapsed .sidebar-menu { padding: 15px 5px; }
.sidebar.collapsed .sidebar-menu a { padding: 12px 10px; justify-content: center; margin-bottom: 8px; position: relative; }
.sidebar.collapsed .sidebar-menu a i.bi { margin-right: 0 !important; font-size: 1.3rem; }
.sidebar.collapsed .sidebar-menu a span.menu-text { display: none; }
.sidebar.collapsed .collapse-toggle .chevron-icon { display: none; }
.sidebar.collapsed .collapse-submenu, .sidebar.collapsed .collapse-submenu-2 { display: none !important; }
.sidebar.collapsed ~ .main-content { margin-left: 70px; }
.submenu-level-1, .submenu-level-2 { overflow: hidden; transition: all 0.15s ease-in-out; margin: 0; padding: 0; list-style: none; }
.submenu-level-1 { border-left: 2px solid #cbd5e1; margin-left: 14px; padding-left: 0; }
.submenu-level-1 > a, .submenu-level-1 > li > a { display: flex; align-items: center; padding-top: 4px !important; padding-bottom: 4px !important; padding-left: 14px; padding-right: 14px; font-size: 0.88rem; font-weight: 500; color: #475569; text-decoration: none; transition: all 0.15s ease-in-out; border-radius: 0 6px 6px 0; }
.submenu-level-1 > a i, .submenu-level-1 > li > a i { font-size: 0.95rem; margin-right: 8px; width: 18px; text-align: center; }
.submenu-level-1 > a:hover, .submenu-level-1 > li > a:hover { background-color: rgba(0, 0, 0, 0.03); color: #1e3c72; }
.submenu-level-1 > a.active, .submenu-level-1 > li > a.active { background-color: rgba(30, 60, 114, 0.05); color: #1e3c72; font-weight: 600; }
.submenu-level-2 { border-left: 1.5px dashed #94a3b8; margin-left: 25px; padding-left: 0; margin-top: 2px; margin-bottom: 2px; }
.submenu-level-2 > a, .submenu-level-2 > li > a { display: flex; align-items: center; padding-top: 4px !important; padding-bottom: 4px !important; padding-left: 16px; padding-right: 14px; font-size: 0.85rem; font-weight: 400; color: #64748b; text-decoration: none; transition: all 0.15s ease-in-out; border-radius: 0 6px 6px 0; }
.submenu-level-2 > a i, .submenu-level-2 > li > a i { font-size: 0.90rem; margin-right: 6px; width: 16px; text-align: center; }
.submenu-level-2 > a:hover, .submenu-level-2 > li > a:hover { background-color: rgba(0, 0, 0, 0.03); color: #2a5298; }
.submenu-level-2 > a.active, .submenu-level-2 > li > a.active { background-color: rgba(42, 82, 152, 0.04); color: #2a5298; font-weight: 500; }
[data-theme="dark"] .form-control, [data-theme="dark"] .form-select { background-color: var(--form-bg); color: var(--form-text); border-color: var(--form-border); }
[data-theme="dark"] .form-control:focus, [data-theme="dark"] .form-select:focus { background-color: var(--form-bg); color: var(--form-text); border-color: var(--form-focus-border); box-shadow: 0 0 0 0.25rem rgba(59,130,246,0.25); }
[data-theme="dark"] .input-group-text { background-color: var(--input-group-bg) !important; color: var(--form-text); border-color: var(--form-border); }
[data-theme="dark"] .bg-light { background-color: #1e293b !important; color: #f1f5f9 !important; }
.content-wrap { max-width: none !important; }
.qr-section { text-align: center; padding: 20px; background: #f8f9fa; border-radius: 12px; border: 2px dashed #dee2e6; }
[data-theme="dark"] .qr-section { background: #0f172a; border-color: #334155; }
.cart-table th { background: #f1f5f9; font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.5px; }
[data-theme="dark"] .cart-table th { background: #334155; color: #e2e8f0; }
.cart-item td { vertical-align: middle; }
.qty-input { width: 70px; text-align: center; }
.product-select { width: 100%; }
.kb-badge { display: inline-block; background: #1e293b; color: #fff; font-size: 0.65rem; padding: 1px 6px; border-radius: 4px; margin-left: 4px; font-weight: 700; }
.kiosk-mode .sidebar { display: none !important; }
.kiosk-mode .main-content { margin-left: 0 !important; width: 100% !important; }
.kiosk-mode .topbar { display: none !important; }
body { overflow-x: hidden; }
.hamburger-btn { background: none; border: none; font-size: 1.6rem; color: var(--sidebar-accent); cursor: pointer; padding: 0 5px; line-height: 1; display: none; align-items: center; }
.hamburger-btn:hover { opacity: 0.7; }
@keyframes fadeInUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
@media (max-width: 991.98px) {
            .sidebar { transform: translateX(-100%); width: 280px !important; }
            .sidebar.mobile-open { transform: translateX(0); }
            .sidebar.collapsed { width: 280px !important; }
            .sidebar.collapsed .brand-text { display: block !important; }
            .sidebar.collapsed .sidebar-menu a span.menu-text { display: inline !important; }
            .sidebar.collapsed .sidebar-menu a { justify-content: flex-start; padding: 12px 15px; }
            .sidebar.collapsed .sidebar-menu a i.bi { margin-right: 12px !important; font-size: 1.1rem !important; }
            .sidebar.collapsed .sidebar-brand { font-size: 1.3rem; padding: 20px; }
            .sidebar.collapsed .sidebar-brand span.brand-text { display: inline !important; }
            .sidebar.collapsed .collapse-toggle .chevron-icon { display: inline; }
            .sidebar.collapsed .collapse-submenu { display: block !important; }
            .sidebar.collapsed ~ .main-content { margin-left: 0; }
            .main-content { margin-left: 0 !important; }
            .sidebar ~ .main-content { margin-left: 0; }
            #sidebarOverlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 999; }
            #sidebarOverlay.show { display: block; }
            .topbar { padding: 12px 15px; flex-wrap: wrap; gap: 8px; }
            .topbar-widgets .widget-box { font-size: 0.7rem; padding: 4px 8px; }
            .topbar-widgets .user-profile { padding: 4px 10px; }
            .topbar-widgets .user-profile .profile-name { font-size: 0.7rem; }
            .topbar-widgets .user-profile .profile-role { display: none; }
            .container-fluid.p-4 { padding: 12px !important; }
            .panel-custom-header { padding: 14px 16px; font-size: 0.95rem; }
            .panel-custom-body { padding: 14px; }
            .table { font-size: 0.78rem; }
            .hamburger-btn { display: flex !important; }
            .topbar-title { font-size: 1rem; }
            .row.g-3 .col-md-6, .row.g-3 .col-md-2, .row.g-3 .col-md-4, .row.g-3 .col-md-8 { width: 100%; }
        }
    </style>
</head>
<body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content">
    <div class="topbar">
        <div style="display:flex;align-items:center;gap:12px;">
            <button class="hamburger-btn" id="sidebarToggleMobile" onclick="document.getElementById('mainSidebar').classList.toggle('mobile-open');document.getElementById('sidebarOverlay').classList.toggle('show');" title="Menú"><i class="bi bi-list"></i></button>
            <div class="topbar-title"><i class="bi bi-cart-plus me-2"></i> Registrar Nueva Venta</div>
        </div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="widget-box widget-weather"><i class="bi bi-sun-fill me-2"></i> <span>17°C</span></div>
            <button id="fullscreenBtn" class="btn btn-sm btn-outline-secondary" title="Pantalla completa (F11)" onclick="toggleFullscreen()"><i class="bi bi-arrows-fullscreen"></i></button>
            <button id="kioskBtn" class="btn btn-sm btn-outline-secondary" title="Modo Quiosco" onclick="toggleKiosk()"><i class="bi bi-tv"></i></button>
            <div class="user-profile shadow-sm">
    <div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div>
    <div class="profile-info">
        <div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div>
        <div class="profile-role"><?php echo $_SESSION["rol"]; ?></div>
    </div>
</div>
        </div>
    </div>

    <div class="container-fluid p-4">
        <form method="POST" action="guardar.php" id="ventaForm">
            <div class="row">
                <div class="col-lg-8">
                    <div class="panel-custom shadow-sm">
                        <div class="panel-custom-header">
                            <i class="bi bi-cart4 me-2"></i> Productos
                            <span class="badge bg-light text-dark ms-2"><span id="cartCount">0</span> items</span>
                        </div>
                        <div class="panel-custom-body p-4">
                            <!-- Búsqueda por código de producto -->
                            <div class="row g-2 mb-3">
                                <div class="col-md-8">
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-upc-scan"></i></span>
                                        <input type="text" id="barcodeInput" class="form-control" placeholder="Buscar por código de producto (ej: 0006)..." autocomplete="off">
                                        <span class="input-group-text bg-light"><small class="text-muted">F1</small></span>
                                    </div>
                                </div>
                                <div class="col-md-4 d-flex align-items-center">
                                    <small class="text-muted"><i class="bi bi-info-circle me-1"></i>Escribe el código y presiona Enter</small>
                                </div>
                            </div>
                            <hr>
                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold">Seleccionar Producto <span class="kb-badge">F2</span></label>
                                    <select id="productoSelect" class="form-select product-select">
                                        <option value="">-- Seleccione --</option>
                                        <?php while($p = mysqli_fetch_assoc($productos)): ?>
                                        <option value="<?php echo $p['id_producto']; ?>" data-precio="<?php echo $p['precio']; ?>" data-stock="<?php echo $p['stock']; ?>" data-nombre="<?php echo $p['nombre_producto']; ?>" data-impuesto="<?php echo $p['impuesto'] ?? 0; ?>">
                                            <?php echo $p['nombre_producto']; ?> - Bs. <?php echo $p['precio']; ?> (Stock: <?php echo $p['stock']; ?>)
                                        </option>
                                        <?php endwhile; ?>
                                    </select>
                                    <div id="productoInfo" class="card card-body py-2 px-3 mt-2 small d-none">
                                        <div class="row g-1">
                                            <div class="col-6"><strong>Stock:</strong> <span id="infoStock">-</span></div>
                                            <div class="col-6"><strong>Precio:</strong> Bs. <span id="infoPrecio">-</span></div>
                                            <div class="col-6"><strong>P. Compra:</strong> Bs. <span id="infoPrecioCompra">-</span></div>
                                            <div class="col-6"><strong>Últ. venta:</strong> <span id="infoUltVenta">-</span></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label fw-bold">Cantidad</label>
                                    <input type="number" id="cantidadInput" class="form-control" value="1" min="1">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label fw-bold">Precio Unit.</label>
                                    <input type="number" id="precioUnitInput" class="form-control" step="0.01" value="0">
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="button" class="btn btn-success w-100" onclick="agregarProducto()">
                                        <i class="bi bi-plus-circle me-1"></i> +
                                    </button>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table table-hover cart-table align-middle mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width:35px;">N°</th>
                                            <th>Producto</th>
                                            <th style="width:80px;">Cant.</th>
                                            <th style="width:100px;">P.Unit.</th>
                                            <th style="width:70px;">IVA</th>
                                            <th style="width:100px;">Subtotal</th>
                                            <th style="width:50px;"></th>
                                        </tr>
                                    </thead>
                                    <tbody id="cartBody"></tbody>
                                    <tfoot>
                                        <tr class="table-light fw-bold">
                                            <td colspan="4" class="text-end">SUBTOTAL:</td>
                                            <td id="ivaDisplay" class="text-primary">Bs. 0.00</td>
                                            <td id="totalDisplay">Bs. 0.00</td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            <input type="hidden" name="productos_json" id="productosJson">
                            <input type="hidden" name="total" id="totalHidden">
                            <input type="hidden" name="csrf_token" value="<?php echo generarCsrf(); ?>">
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="panel-custom shadow-sm">
                        <div class="panel-custom-header">
                            <i class="bi bi-info-circle me-2"></i> Datos de Venta
                        </div>
                        <div class="panel-custom-body p-4">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Fecha</label>
                                <input type="date" name="fecha" class="form-control" value="<?php echo date('Y-m-d'); ?>" required>
                            </div>
                            <div class="mb-3 position-relative">
                                <label class="form-label fw-bold">Buscar Cliente</label>
                                <input type="text" id="clienteBuscar" class="form-control" placeholder="Buscar por nombre o NIT..." autocomplete="off">
                                <input type="hidden" name="id_cliente" id="id_cliente" value="">
                                <div id="clienteResultados" class="list-group position-absolute w-100 shadow" style="z-index:1000;display:none;max-height:200px;overflow-y:auto;"></div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Nombre del Cliente</label>
                                <input type="text" name="cliente_nombre" id="cliente_nombre" class="form-control" placeholder="Nombre del cliente">
                            </div>
                            <div class="row g-2 mb-3">
                                <div class="col-6">
                                    <input type="text" name="cliente_telefono" id="cliente_telefono" class="form-control" placeholder="Teléfono">
                                </div>
                                <div class="col-6">
                                    <input type="text" name="cliente_nit" id="cliente_nit" class="form-control" placeholder="CI/NIT">
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Método de Pago</label>
                                <select name="metodo_pago" class="form-select" id="metodoPago">
                                    <option value="Efectivo">Efectivo</option>
                                    <option value="Transferencia QR">Transferencia QR</option>
                                </select>
                            </div>
                            <div id="qrPaymentSection" style="display:none;">
                                <hr>
                                <div class="qr-section">
                                    <?php if(file_exists('../assets/uploads/qr/qr_pago.png')): ?>
                                    <p class="text-muted small mb-2">Escanee el código QR para pagar</p>
                                    <img src="../assets/uploads/qr/qr_pago.png" style="width:200px;height:200px;border-radius:8px;border:1px solid #dee2e6;cursor:pointer;" class="mb-2" data-bs-toggle="modal" data-bs-target="#qrZoomModal">
                                    <?php else: ?>
                                    <p class="text-muted small mb-2">No hay QR configurado</p>
                                    <i class="bi bi-qr-code" style="font-size:3rem;color:#ccc;"></i>
                                    <?php endif; ?>
                                    <div class="mt-2">
                                        <a href="../configurar_qr.php" class="btn btn-sm btn-outline-secondary" target="_blank">
                                            <i class="bi bi-gear me-1"></i> Configurar QR
                                        </a>
                                    </div>
                                </div>
                            </div>
                            <hr>
                            <div class="d-grid gap-2">
                                <button type="submit" class="btn btn-primary" style="background:#1e3c72;border:none;padding:12px;">
                                    <i class="bi bi-check-circle-fill me-1"></i> Registrar Venta <span class="kb-badge">F8</span>
                                </button>
                                <a href="index.php" class="btn btn-outline-secondary">Cancelar <span class="kb-badge">Esc</span></a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<div class="modal fade" id="qrZoomModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-sm modal-dialog-centered">
        <div class="modal-content" style="border:none;border-radius:12px;background:transparent;box-shadow:none;">
            <div class="text-center position-relative">
                <button type="button" class="btn-close btn-close-white position-absolute top-0 end-0 m-2" data-bs-dismiss="modal" style="background:rgba(0,0,0,0.5);border-radius:50%;padding:8px;z-index:10;"></button>
                <?php if(file_exists('../assets/uploads/qr/qr_pago.png')): ?>
                <img src="../assets/uploads/qr/qr_pago.png" style="width:320px;height:320px;border-radius:12px;border:4px solid #fff;box-shadow:0 8px 40px rgba(0,0,0,0.3);">
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php if ($venta_data): ?>
<div class="modal fade" id="ventaOkModal" tabindex="-1" aria-hidden="true" data-bs-backdrop="static">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:16px;border:none;box-shadow:0 20px 60px rgba(0,0,0,0.15);">
            <div class="modal-body text-center py-5 px-4">
                <div style="width:80px;height:80px;border-radius:50%;background:#d1fae5;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">
                    <i class="bi bi-check-circle-fill text-success" style="font-size:3rem;"></i>
                </div>
                <h4 class="fw-bold mb-1">¡Venta Registrada!</h4>
                <p class="text-muted mb-3">Venta #<?php echo $venta_data['id_venta']; ?> por <strong>Bs. <?php echo number_format($venta_data['total'], 2); ?></strong></p>
                <div class="d-flex justify-content-center gap-2">
                    <a href="imprimir_recibo.php?id=<?php echo $venta_data['id_venta']; ?>" target="_blank" class="btn btn-primary" style="background:#1e3c72;border:none;padding:10px 24px;"><i class="bi bi-printer me-1"></i> Imprimir Recibo</a>
                    <a href="nuevo.php" class="btn btn-outline-secondary" style="padding:10px 24px;"><i class="bi bi-check-lg me-1"></i> OK, Nueva Venta</a>
                </div>
            </div>
        </div>
    </div>
</div>
<script>
document.addEventListener('DOMContentLoaded', function() {
    var el = document.getElementById('ventaOkModal');
    if (el && typeof bootstrap !== 'undefined') {
        new bootstrap.Modal(el).show();
    }
});
</script>
<?php endif; ?>

<script src="<?php echo BASE_PATH; ?>assets/js/bootstrap.bundle.min.js"></script>
<script>
var carrito = [];
var todosProductos = <?php
$todos = mysqli_query($conexion, "SELECT p.id_producto, p.nombre_producto, p.precio, p.impuesto, p.stock, p.codigo_barras,
    (SELECT dc.precio FROM detalle_compras dc WHERE dc.producto_id = p.id_producto ORDER BY dc.id_detalle DESC LIMIT 1) AS precio_compra,
    (SELECT MAX(v.fecha) FROM detalle_ventas dv INNER JOIN ventas v ON dv.venta_id = v.id_venta WHERE dv.producto_id = p.id_producto) AS ult_venta
    FROM productos p WHERE p.activo=1 AND p.stock > 0 ORDER BY p.nombre_producto ASC");
$arr = [];
while($tp = mysqli_fetch_assoc($todos)){
    $arr[] = $tp;
}
echo json_encode($arr);
?>;

function buscarPorBarras(codigo) {
    var encontrado = null;
    var codigoLimpio = codigo.trim();
    for (var i = 0; i < todosProductos.length; i++) {
        var prod = todosProductos[i];
        if (String(prod.id_producto) === codigoLimpio || String(prod.id_producto) === String(parseInt(codigoLimpio, 10))) {
            encontrado = prod;
            break;
        }
        if (prod.codigo_barras && prod.codigo_barras === codigoLimpio) {
            encontrado = prod;
            break;
        }
    }
    if (!encontrado) {
        alert('Producto no encontrado con código: ' + codigo);
        return;
    }
    var id = encontrado.id_producto;
    var nombre = encontrado.nombre_producto;
    var precio = parseFloat(encontrado.precio);
    var stock = parseInt(encontrado.stock);
    var impuesto = parseFloat(encontrado.impuesto) || 0;
    var cantidad = 1;
    if (cantidad > stock) { alert('Stock insuficiente. Disponible: ' + stock); return; }
    var existente = carrito.findIndex(function(p) { return p.id == id; });
    if (existente >= 0) {
        var nuevaCant = carrito[existente].cantidad + cantidad;
        if (nuevaCant > stock) { alert('Stock insuficiente. Disponible: ' + stock); return; }
        carrito[existente].cantidad = nuevaCant;
    } else {
        carrito.push({ id: id, nombre: nombre, cantidad: cantidad, precio: precio, impuesto: impuesto });
    }
    document.getElementById('barcodeInput').value = '';
    renderizarCarrito();
}

function agregarProducto() {
    var select = document.getElementById('productoSelect');
    var cantidad = parseInt(document.getElementById('cantidadInput').value) || 1;
    var precioManual = parseFloat(document.getElementById('precioUnitInput').value);
    if (!select.value) { alert('Seleccione un producto'); return; }
    var opt = select.options[select.selectedIndex];
    var id = select.value;
    var nombre = opt.getAttribute('data-nombre');
    var precioDB = parseFloat(opt.getAttribute('data-precio'));
    var stock = parseInt(opt.getAttribute('data-stock'));
    var impuesto = parseFloat(opt.getAttribute('data-impuesto')) || 0;
    if (cantidad < 1) { alert('Cantidad inválida'); return; }
    if (cantidad > stock) { alert('Stock insuficiente. Disponible: ' + stock); return; }
    var existente = carrito.findIndex(function(p) { return p.id == id; });
    var precio = (precioManual > 0) ? precioManual : precioDB;
    if (existente >= 0) {
        var nuevaCant = carrito[existente].cantidad + cantidad;
        if (nuevaCant > stock) { alert('Stock insuficiente. Disponible: ' + stock); return; }
        carrito[existente].cantidad = nuevaCant;
        carrito[existente].precio = precio;
    } else {
        carrito.push({ id: id, nombre: nombre, cantidad: cantidad, precio: precio, impuesto: impuesto });
    }
    select.value = '';
    document.getElementById('cantidadInput').value = 1;
    document.getElementById('precioUnitInput').value = 0;
    renderizarCarrito();
}

function eliminarProducto(index) {
    showConfirmModal('¿Eliminar ' + carrito[index].nombre + ' del carrito?', function() {
        carrito.splice(index, 1);
        renderizarCarrito();
    });
}

function cambiarCantidad(index, nuevaCant) {
    if (nuevaCant < 1) { eliminarProducto(index); return; }
    carrito[index].cantidad = nuevaCant;
    renderizarCarrito();
}

function renderizarCarrito() {
    var tbody = document.getElementById('cartBody');
    var total = 0;
    var totalIva = 0;
    var html = '';
    for (var i = 0; i < carrito.length; i++) {
        var p = carrito[i];
        var subtotal = p.cantidad * p.precio;
        var iva = subtotal * (p.impuesto || 0) / 100;
        var totalConIva = subtotal + iva;
        total += totalConIva;
        totalIva += iva;
        html += '<tr class="cart-item">' +
            '<td>' + (i+1) + '</td>' +
            '<td>' + p.nombre + '</td>' +
            '<td><input type="number" class="form-control qty-input" value="' + p.cantidad + '" min="1" onchange="cambiarCantidad(' + i + ', this.value)"></td>' +
            '<td>Bs. ' + p.precio.toFixed(2) + '</td>' +
            '<td><small class="text-' + (p.impuesto > 0 ? 'danger' : 'muted') + '">' + (p.impuesto || 0) + '%</small></td>' +
            '<td>Bs. ' + totalConIva.toFixed(2) + '</td>' +
            '<td><button type="button" class="btn btn-sm btn-danger" onclick="eliminarProducto(' + i + ')"><i class="bi bi-trash"></i></button></td>' +
            '</tr>';
    }
    tbody.innerHTML = html;
    document.getElementById('totalDisplay').textContent = 'Bs. ' + total.toFixed(2);
    document.getElementById('ivaDisplay').textContent = 'Bs. ' + totalIva.toFixed(2);
    document.getElementById('totalHidden').value = total.toFixed(2);
    document.getElementById('productosJson').value = JSON.stringify(carrito);
    document.getElementById('cartCount').textContent = carrito.length;
}

document.getElementById('barcodeInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') {
        e.preventDefault();
        buscarPorBarras(this.value.trim());
    }
});

document.getElementById('productoSelect').addEventListener('change', function() {
    if (this.value) {
        var opt = this.options[this.selectedIndex];
        document.getElementById('precioUnitInput').value = opt.getAttribute('data-precio');
    }
});

document.getElementById('cantidadInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter') { e.preventDefault(); agregarProducto(); }
});

var metodoPago = document.getElementById('metodoPago');
if (metodoPago) {
    metodoPago.addEventListener('change', function() {
        var qrSection = document.getElementById('qrPaymentSection');
        if (qrSection) qrSection.style.display = this.value === 'Transferencia QR' ? '' : 'none';
    });
}

var ventaForm = document.getElementById('ventaForm');
if (ventaForm) {
    ventaForm.addEventListener('submit', function(e) {
        if (carrito.length === 0) {
            e.preventDefault();
            alert('Agregue al menos un producto al carrito');
            return;
        }
    });
}

var timeoutBuscar = null;
var clienteBuscar = document.getElementById('clienteBuscar');
if (clienteBuscar) {
clienteBuscar.addEventListener('input', function() {
    clearTimeout(timeoutBuscar);
    var q = this.value.trim();
    var div = document.getElementById('clienteResultados');
    if (q.length < 1) { div.style.display = 'none'; return; }
    timeoutBuscar = setTimeout(function() {
        fetch('ajax_buscar_cliente.php?q=' + encodeURIComponent(q))
            .then(function(r) { return r.json(); })
            .then(function(data) {
                div.innerHTML = '';
                if (!data || data.length === 0) {
                    div.style.display = 'none';
                    return;
                }
                data.forEach(function(cli) {
                    var a = document.createElement('a');
                    a.href = '#';
                    a.className = 'list-group-item list-group-item-action';
                    a.innerHTML = '<strong>' + cli.nombre_cliente + '</strong> <span class="text-muted small">NIT: ' + cli.ci_nit + ' | Tel: ' + cli.telefono + '</span>';
                    a.addEventListener('click', function(e) {
                        e.preventDefault();
                        document.getElementById('id_cliente').value = cli.id_cliente;
                        document.getElementById('cliente_nombre').value = cli.nombre_cliente;
                        document.getElementById('cliente_telefono').value = cli.telefono;
                        document.getElementById('cliente_nit').value = cli.ci_nit;
                        document.getElementById('clienteBuscar').value = cli.nombre_cliente + ' (' + cli.ci_nit + ')';
                        div.style.display = 'none';
                    });
                    div.appendChild(a);
                });
                div.style.display = 'block';
            })
            .catch(function() {
                div.style.display = 'none';
            });
    }, 300);
});
}

document.addEventListener('click', function(e) {
    var input = document.getElementById('clienteBuscar');
    if (input && !input.contains(e.target)) {
        var div = document.getElementById('clienteResultados');
        if (div) div.style.display = 'none';
    }
});

var idClienteInput = document.getElementById('id_cliente');
function limpiarIdCliente() { if (idClienteInput) idClienteInput.value = ''; }
var cNombre = document.getElementById('cliente_nombre');
var cNit = document.getElementById('cliente_nit');
var cTel = document.getElementById('cliente_telefono');
if (cNombre) cNombre.addEventListener('input', limpiarIdCliente);
if (cNit) cNit.addEventListener('input', limpiarIdCliente);
if (cTel) cTel.addEventListener('input', limpiarIdCliente);

function inicializarRelojYFecha() {
    const ahora = new Date();
    document.getElementById('txt-reloj').textContent = String(ahora.getHours()).padStart(2,'0')+':'+String(ahora.getMinutes()).padStart(2,'0')+':'+String(ahora.getSeconds()).padStart(2,'0');
    const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    document.getElementById('txt-fecha').textContent = String(ahora.getDate()).padStart(2,'0')+'/'+meses[ahora.getMonth()]+'/'+ahora.getFullYear();
}
inicializarRelojYFecha();
setInterval(inicializarRelojYFecha, 1000);

(function(){
    var toggle = document.createElement('div');
    toggle.className = 'widget-box';
    toggle.id = 'darkModeToggle';
    toggle.style.cssText = 'cursor:pointer;background:#f1f5f9;border-radius:20px;padding:6px 14px;';
    var savedTheme = localStorage.getItem('theme');
    toggle.innerHTML = '<i class="bi ' + (savedTheme === 'dark' ? 'bi-moon-fill' : savedTheme === 'sepia' ? 'bi-brightness-alt-high-fill' : 'bi-sun-fill') + '"></i>';
    toggle.title = 'Modo oscuro';
    var widgets = document.querySelector('.topbar-widgets');
    if(widgets) {
        var profile = widgets.querySelector('.user-profile');
        widgets.insertBefore(toggle, profile);
        toggle.addEventListener('click', function(){
                if (window.ciclarTema) { window.ciclarTema(); }
                var cur = document.documentElement.getAttribute('data-theme') || 'light';
                toggle.innerHTML = '<i class="bi ' + (cur === 'dark' ? 'bi-moon-fill' : cur === 'sepia' ? 'bi-brightness-alt-high-fill' : 'bi-sun-fill') + '"></i>';
        });
    }
    if (window.aplicarTema) { window.aplicarTema(localStorage.getItem('theme') || 'light'); }
})();

document.addEventListener('keydown', function(e){
    switch(e.key) {
        case 'F1':
            e.preventDefault();
            var bi = document.getElementById('barcodeInput');
            if (bi) bi.focus();
            break;
        case 'F2':
            e.preventDefault();
            var ps = document.getElementById('productoSelect');
            if (ps) ps.focus();
            break;
        case 'F8':
            e.preventDefault();
            var f = document.getElementById('ventaForm');
            if (f && carrito.length > 0) f.submit();
            break;
        case 'Escape':
            break;
    }
    if(e.ctrlKey && e.key === 's'){ e.preventDefault(); var f = document.getElementById('ventaForm'); if(f && carrito.length > 0) f.submit(); }
    if(e.key === 'F11'){ e.preventDefault(); toggleFullscreen(); }
});

function toggleFullscreen() {
    if (!document.fullscreenElement) {
        document.documentElement.requestFullscreen();
    } else {
        if (document.exitFullscreen) document.exitFullscreen();
    }
}

function toggleKiosk() {
    document.body.classList.toggle('kiosk-mode');
    var btn = document.getElementById('kioskBtn');
    if (btn) {
        btn.classList.toggle('active');
        btn.title = document.body.classList.contains('kiosk-mode') ? 'Salir de Modo Quiosco' : 'Modo Quiosco';
    }
}

document.getElementById('productoSelect').addEventListener('change', function() {
    var val = this.value;
    var infoDiv = document.getElementById('productoInfo');
    if (!val) {
        infoDiv.classList.add('d-none');
        return;
    }
    var opt = this.options[this.selectedIndex];
    var nombre = opt.getAttribute('data-nombre');
    var precio = opt.getAttribute('data-precio');
    var stock = opt.getAttribute('data-stock');
    document.getElementById('infoStock').textContent = stock;
    document.getElementById('infoPrecio').textContent = parseFloat(precio).toFixed(2);
    var prod = null;
    for (var i = 0; i < todosProductos.length; i++) {
        if (todosProductos[i].id_producto == val) {
            prod = todosProductos[i];
            break;
        }
    }
    if (prod) {
        document.getElementById('infoPrecioCompra').textContent = prod.precio_compra ? parseFloat(prod.precio_compra).toFixed(2) : '-';
        document.getElementById('infoUltVenta').textContent = prod.ult_venta || '-';
    }
    infoDiv.classList.remove('d-none');
});
</script>
</body>
</html>
