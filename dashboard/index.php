<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$anio_actual = isset($_GET['anio']) ? intval($_GET['anio']) : date('Y');

$tot_productos = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM productos WHERE activo=1"))['total'];
$tot_proveedores = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM proveedores WHERE activo=1"))['total'];
$tot_compras = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM compras"))['total'];
$tot_ventas_cant = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM ventas"))['total'];
$tot_clientes = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM clientes WHERE activo=1"))['total'];
$tot_pedidos = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM pedidos"))['total'];
$tot_categorias = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM categorias WHERE activo=1"))['total'];
$tot_usuarios = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM usuarios"))['total'];

// --- Ventas: hoy vs ayer ---
$hoy = date('Y-m-d');
$ayer = date('Y-m-d', strtotime('-1 day'));
$ventas_hoy = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total, COALESCE(SUM(total),0) monto FROM ventas WHERE DATE(fecha)='$hoy'"));
$ventas_ayer = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total, COALESCE(SUM(total),0) monto FROM ventas WHERE DATE(fecha)='$ayer'"));

// --- Pie chart: ventas por método de pago ---
$metodos_pago = mysqli_query($conexion, "SELECT metodo_pago, COUNT(*) as total, COALESCE(SUM(total),0) as monto FROM ventas WHERE YEAR(fecha)=$anio_actual GROUP BY metodo_pago ORDER BY monto DESC");
$datos_pie = [];
$total_monto_pagos = 0;
while($mp = mysqli_fetch_assoc($metodos_pago)){
    $mp['monto'] = floatval($mp['monto']);
    $mp['total'] = intval($mp['total']);
    $datos_pie[] = $mp;
    $total_monto_pagos += $mp['monto'];
}

// --- Top 5 productos más vendidos del año ---
$top_productos = mysqli_query($conexion, "SELECT p.nombre_producto, p.precio, SUM(dv.cantidad) as total_vendido, SUM(dv.cantidad * dv.precio) as total_ingresos
    FROM detalle_ventas dv
    INNER JOIN ventas v ON dv.venta_id = v.id_venta
    INNER JOIN productos p ON dv.producto_id = p.id_producto
    WHERE YEAR(v.fecha) = $anio_actual
    GROUP BY dv.producto_id
    ORDER BY total_vendido DESC
    LIMIT 5");

// --- Stock bajo ---
$stock_bajo = mysqli_query($conexion, "SELECT id_producto, nombre_producto, stock, precio FROM productos WHERE activo=1 AND stock < 10 ORDER BY stock ASC LIMIT 8");

// Ensure id_usuario exists in ventas for top sellers query
mysqli_query($conexion, "ALTER TABLE ventas ADD COLUMN IF NOT EXISTS id_usuario INT NULL AFTER metodo_pago");

// --- a) Ventas Mensuales (Current Year Bar Chart) ---
$ventas_mensuales = [];
$res_vm = mysqli_query($conexion, "SELECT DATE_FORMAT(fecha, '%Y-%m') as mes, COUNT(*) total, COALESCE(SUM(total),0) monto FROM ventas WHERE YEAR(fecha) = YEAR(CURDATE()) GROUP BY DATE_FORMAT(fecha, '%Y-%m') ORDER BY mes ASC");
while ($vm = mysqli_fetch_assoc($res_vm)) {
    $ventas_mensuales[$vm['mes']] = ['total' => intval($vm['total']), 'monto' => floatval($vm['monto'])];
}
// Fill missing months
for ($m = 1; $m <= 12; $m++) {
    $key = sprintf("%04d-%02d", date('Y'), $m);
    if (!isset($ventas_mensuales[$key])) $ventas_mensuales[$key] = ['total' => 0, 'monto' => 0];
}
ksort($ventas_mensuales);

// --- b) Top Vendedores ---
$top_vendedores = mysqli_query($conexion, "SELECT u.nombre, COUNT(v.id_venta) total_ventas, COALESCE(SUM(v.total),0) total_monto FROM ventas v JOIN usuarios u ON v.id_usuario = u.id WHERE YEAR(v.fecha) = YEAR(CURDATE()) GROUP BY v.id_usuario ORDER BY total_monto DESC LIMIT 5");
$max_vendedor_monto = 0;
$tv_data = [];
while ($tv = mysqli_fetch_assoc($top_vendedores)) {
    $tv['total_ventas'] = intval($tv['total_ventas']);
    $tv['total_monto'] = floatval($tv['total_monto']);
    if ($tv['total_monto'] > $max_vendedor_monto) $max_vendedor_monto = $tv['total_monto'];
    $tv_data[] = $tv;
}

// --- c) Margen de Ganancia Real ---
$margen_ganancia = mysqli_query($conexion, "
    SELECT p.nombre_producto,
           SUM(dv.cantidad * dv.precio) as ingresos,
           COALESCE((SELECT SUM(dc.cantidad * dc.precio) FROM detalle_compras dc WHERE dc.producto_id = p.id_producto), 0) as costo,
           (SUM(dv.cantidad * dv.precio) - COALESCE((SELECT SUM(dc.cantidad * dc.precio) FROM detalle_compras dc WHERE dc.producto_id = p.id_producto), 0)) as ganancia
    FROM detalle_ventas dv
    JOIN productos p ON dv.producto_id = p.id_producto
    GROUP BY dv.producto_id
    ORDER BY ganancia DESC
    LIMIT 10
");

// --- Tab 2 - Analíticas queries ---
// Total compras este año vs año anterior
$compras_ea = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total, COALESCE(SUM(total),0) monto FROM compras WHERE YEAR(fecha) = YEAR(CURDATE())"));
$compras_aa = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total, COALESCE(SUM(total),0) monto FROM compras WHERE YEAR(fecha) = YEAR(CURDATE()) - 1"));
// Total ventas este año vs año anterior
$ventas_ea = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total, COALESCE(SUM(total),0) monto FROM ventas WHERE YEAR(fecha) = YEAR(CURDATE())"));
$ventas_aa = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total, COALESCE(SUM(total),0) monto FROM ventas WHERE YEAR(fecha) = YEAR(CURDATE()) - 1"));
// Producto más vendido (histórico)
$prod_top = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT p.nombre_producto, SUM(dv.cantidad) total_vendido FROM detalle_ventas dv JOIN productos p ON dv.producto_id = p.id_producto GROUP BY dv.producto_id ORDER BY total_vendido DESC LIMIT 1"));
// Cliente que más compra (histórico)
$cli_top = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT c.nombre_cliente, COUNT(v.id_venta) total_compras, COALESCE(SUM(v.total),0) total_gastado FROM ventas v JOIN clientes c ON v.id_cliente = c.id_cliente GROUP BY v.id_cliente ORDER BY total_gastado DESC LIMIT 1"));
// Día de la semana con más ventas
$dia_top = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT DAYNAME(fecha) dia, COUNT(*) total FROM ventas GROUP BY DAYNAME(fecha) ORDER BY total DESC LIMIT 1"));
$dias_map = ['Monday'=>'Lunes','Tuesday'=>'Martes','Wednesday'=>'Miércoles','Thursday'=>'Jueves','Friday'=>'Viernes','Saturday'=>'Sábado','Sunday'=>'Domingo'];

// --- Tab 3 - Sparkline data ---
// Get daily totals per month for sparklines
$sparkline_data = [];
$res_sl = mysqli_query($conexion, "SELECT DATE_FORMAT(fecha, '%Y-%m') as mes, SUM(total) as diario FROM ventas WHERE YEAR(fecha) = $anio_actual GROUP BY DATE(fecha) ORDER BY DATE(fecha) ASC");
while ($sl = mysqli_fetch_assoc($res_sl)) {
    $sparkline_data[$sl['mes']][] = floatval($sl['diario']);
}

// Helper for days per month (no calendar extension needed)
function diasDelMes($mes, $anio) {
    static $dias = [31,28,31,30,31,30,31,31,30,31,30,31];
    if ($mes == 2 && ($anio % 4 == 0 && ($anio % 100 != 0 || $anio % 400 == 0))) return 29;
    return $dias[$mes-1];
}

$meses_nombres = [
    1 => "Enero", 2 => "Febrero", 3 => "Marzo", 4 => "Abril", 
    5 => "Mayo", 6 => "Junio", 7 => "Julio", 8 => "Agosto", 
    9 => "Septiembre", 10 => "Octubre", 11 => "Noviembre", 12 => "Diciembre"
];

$balance_mensual = [];
for ($i = 1; $i <= 12; $i++) {
    $balance_mensual[$i] = ['mes_nombre' => $meses_nombres[$i], 'total' => 0.00];
}

$query_ventas = "SELECT MONTH(fecha) as mes, SUM(total) as total_mes FROM ventas WHERE YEAR(fecha) = '$anio_actual' GROUP BY MONTH(fecha)";
$res_ventas = mysqli_query($conexion, $query_ventas);
$monto_maximo = 0; 
if ($res_ventas) {
    while ($r = mysqli_fetch_assoc($res_ventas)) {
        $num_mes = intval($r['mes']);
        $monto_mes = floatval($r['total_mes']);
        $balance_mensual[$num_mes]['total'] = $monto_mes;
        if ($monto_mes > $monto_maximo) $monto_maximo = $monto_mes;
    }
}
$balance_vista = array_reverse($balance_mensual, true);

// Colores para pastel
$colores_pie = ['#3b82f6','#10b981','#f59e0b','#ef4444','#8b5cf6','#ec4899','#14b8a6','#f97316'];
$pie_json = [];
$pie_labels = [];
$pie_colors = [];
foreach($datos_pie as $i => $dp){
    $pie_labels[] = $dp['metodo_pago'];
    $pie_json[] = $dp['monto'];
    $pie_colors[] = $colores_pie[$i % count($colores_pie)];
}
// Calcular promedios diarios por mes
foreach ($balance_vista as $mes => &$datos) {
    $dias = diasDelMes($mes, $anio_actual);
    $datos['promedio_diario'] = $dias > 0 ? $datos['total'] / $dias : 0;
    $datos['dias_mes'] = $dias;
}
unset($datos);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Dashboard - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
            --border-color: rgba(0,0,0,0.05);
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
            --border-color: rgba(255,255,255,0.06);
        }
        html, body { height: 100%; }
        body { background: var(--body-bg); font-family: 'Segoe UI', system-ui, sans-serif; margin: 0; overflow-x: hidden; color: var(--profile-text); }
        .sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; top: 0; left: 0; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; transition: width 0.3s ease; }
        .sidebar.collapsed { width: 70px; }
        .sidebar.collapsed .brand-text, .sidebar.collapsed .sidebar-menu a .menu-text { display: none; }
        .sidebar.collapsed .sidebar-menu a { justify-content: center; padding: 12px 5px; }
        .sidebar.collapsed .sidebar-menu a i { margin-right: 0; font-size: 1.3rem; }
        .sidebar.collapsed .sidebar-brand { font-size: 0; padding: 15px 10px; }
        .sidebar.collapsed .sidebar-brand .brand-text { font-size: 1.5rem; display: block; }
        .sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; white-space: nowrap; overflow: hidden; }
        .sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
        .sidebar-menu::-webkit-scrollbar { width: 4px; }
        .sidebar-menu::-webkit-scrollbar-track { background: transparent; }
        .sidebar-menu::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.12); border-radius: 10px; }
        .sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; white-space: nowrap; overflow: hidden; border-left: 3px solid transparent; }
        .sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; flex-shrink: 0; }
        .sidebar-menu a:hover { background: var(--sidebar-hover-bg); color: var(--sidebar-accent); border-left-color: var(--sidebar-accent); }
        .sidebar-menu a.active { background: var(--sidebar-active-bg); color: var(--sidebar-accent); font-weight: 700; border-left: 4px solid var(--sidebar-accent); }
        .main-content { margin-left: 260px; min-height: 100vh; transition: margin-left 0.3s ease; }
        .sidebar.collapsed + .main-content { margin-left: 70px; }
        .topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); padding: 12px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 999; }
        .topbar-left { display: flex; align-items: center; gap: 15px; }
        .topbar-title { font-size: 1.2rem; font-weight: 600; color: #1e3c72; white-space: nowrap; }
        [data-theme="dark"] .topbar-title { color: #60a5fa; }
        .hamburger-btn { background: none; border: none; font-size: 1.6rem; color: var(--sidebar-accent); cursor: pointer; padding: 0 5px; line-height: 1; display: flex; align-items: center; }
        .hamburger-btn:hover { opacity: 0.7; }
        .topbar-widgets { display: flex; align-items: center; gap: 15px; }
        .user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: var(--profile-text); }
        .profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; margin-right: 10px; font-size: 1rem; flex-shrink: 0; }
        .profile-avatar-img { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); margin-right: 10px; flex-shrink: 0; }
        [data-theme="dark"] .profile-avatar-img { border-color: #334155; }
        .tab-selector { display: flex; gap: 10px; margin-bottom: 25px; }
        .tab-btn { padding: 10px 28px; border: 2px solid var(--sidebar-accent); border-radius: 30px; background: transparent; color: var(--sidebar-accent); font-weight: 600; font-size: 0.95rem; cursor: pointer; transition: all 0.3s ease; }
        .tab-btn:hover { background: rgba(30,60,114,0.08); }
        .tab-btn.active { background: var(--sidebar-accent); color: #fff; box-shadow: 0 4px 12px rgba(30,60,114,0.3); }
        .tab-content { display: none; }
        .tab-content.active { display: block; }
        .quick-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 24px; }
        .quick-card { display: flex; flex-direction: column; align-items: center; justify-content: center; padding: 38px 20px; min-height: 180px; background: var(--panel-bg); border-radius: 20px; text-decoration: none; color: var(--profile-text); box-shadow: 0 4px 15px rgba(0,0,0,0.04); border: 2px solid var(--border-color); transition: all 0.3s ease; }
        .quick-card:hover { transform: translateY(-6px) scale(1.03); box-shadow: 0 12px 35px rgba(0,0,0,0.15); color: inherit; }
        .quick-card .q-icon { font-size: 3.8rem; margin-bottom: 14px; color: var(--sidebar-accent); }
        .quick-card .q-label { font-size: 1.1rem; font-weight: 700; text-align: center; line-height: 1.3; }
        .card-stat { border: none; border-radius: 12px; overflow: hidden; display: flex; align-items: center; padding: 25px; transition: all 0.3s ease; text-decoration: none !important; color: white !important; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
        .card-stat:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.1); }
        .card-stat-icon { font-size: 2.5rem; opacity: 0.8; margin-right: 20px; flex-shrink: 0; }
        .card-stat-body h5 { margin: 0; font-size: 1rem; opacity: 0.9; }
        .card-stat-title { font-size: 1.8rem; font-weight: 700; margin-top: 5px; }
        .stat-productos { background: linear-gradient(135deg, #3b82f6, #1d4ed8); }
        .stat-ventas { background: linear-gradient(135deg, #10b981, #047857); }
        .stat-proveedores { background: linear-gradient(135deg, #8b5cf6, #5b21b6); }
        .stat-compras { background: linear-gradient(135deg, #f59e0b, #b45309); }
        .widget-pill { padding: 6px 16px; border-radius: 30px; font-weight: 600; font-size: 0.85rem; display: flex; align-items: center; gap: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.05); }
        .widget-time { background-color: #e0f2fe; color: #0284c7; }
        .widget-weather { background-color: #fef3c7; color: #d97706; }
        .widget-date { background-color: #dcfce7; color: #166534; }
        [data-theme="dark"] .widget-time { background-color: rgba(2, 132, 199, 0.2); color: #7dd3fc; }
        [data-theme="dark"] .widget-weather { background-color: rgba(217, 119, 6, 0.2); color: #fcd34d; }
        [data-theme="dark"] .widget-date { background-color: rgba(22, 101, 52, 0.2); color: #86efac; }
        .panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; }
        .panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: var(--panel-header-bg); }
        [data-theme="dark"] .table { color: var(--profile-text); }
        [data-theme="dark"] .table-light th { background-color: #334155 !important; color: #f1f5f9; border-color: var(--border-color); }
        [data-theme="dark"] .table td { border-color: var(--border-color); }
        [data-theme="dark"] .table-hover tbody tr:hover { background-color: #334155; color: #fff; }
        .day-card { border-radius: 16px; padding: 20px; color: #fff; display: flex; align-items: center; gap: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.08); }
        .day-card-icon { font-size: 2.5rem; opacity: 0.9; }
        .day-card h4 { margin: 0; font-weight: 300; font-size: 0.9rem; opacity: 0.9; }
        .day-card .amount { font-size: 1.8rem; font-weight: 800; }
        .day-card .count-label { font-size: 0.8rem; opacity: 0.8; }
        .day-hoy { background: linear-gradient(135deg, #1e3c72, #2a5298); }
        .day-ayer { background: linear-gradient(135deg, #64748b, #475569); }
        .trend-up { color: #10b981; }
        .trend-down { color: #ef4444; }
        canvas { max-width: 100%; }
        /* Analytics stat cards */
        .analytics-stat { display:flex;align-items:center;gap:15px;background:var(--panel-bg);border-radius:14px;padding:18px 20px;box-shadow:0 2px 10px rgba(0,0,0,0.04);border:1px solid var(--border-color);transition:all 0.3s ease; }
        .analytics-stat:hover { transform:translateY(-2px);box-shadow:0 6px 20px rgba(0,0,0,0.08); }
        .analytics-stat .as-icon { width:48px;height:48px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:1.5rem;color:#fff;flex-shrink:0; }
        .analytics-stat .as-icon.blue { background:linear-gradient(135deg,#3b82f6,#1d4ed8); }
        .analytics-stat .as-icon.green { background:linear-gradient(135deg,#10b981,#047857); }
        .analytics-stat .as-icon.purple { background:linear-gradient(135deg,#8b5cf6,#5b21b6); }
        .analytics-stat .as-icon.orange { background:linear-gradient(135deg,#f59e0b,#b45309); }
        .analytics-stat .as-icon.teal { background:linear-gradient(135deg,#14b8a6,#0f766e); }
        .analytics-stat .as-body { flex:1;min-width:0; }
        .analytics-stat .as-label { font-size:0.75rem;text-transform:uppercase;letter-spacing:0.5px;opacity:0.7;margin-bottom:2px; }
        .analytics-stat .as-value { font-size:1.25rem;font-weight:700;line-height:1.2; }
        .analytics-stat .as-compare { font-size:0.75rem;margin-top:2px; }
        .analytics-stat .as-compare.up { color:#10b981; }
        .analytics-stat .as-compare.down { color:#ef4444; }
        .analytics-stat .as-monto { font-size:0.85rem;font-weight:600;margin-top:2px;color:var(--sidebar-accent); }
    </style>
</head>
<body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content" id="mainContent">
    <div class="topbar">
        <div class="topbar-left">
            <button class="hamburger-btn" id="sidebarToggle" title="Alternar menú lateral"><i class="bi bi-list"></i></button>
            <div class="topbar-title"><i class="bi bi-speedometer2 me-2"></i> Gestión de Librería</div>
            <div class="topbar-widgets d-none d-lg-flex gap-3">
                <div class="widget-pill widget-time"><i class="bi bi-clock-fill"></i> <span id="relojDigital">00:00:00</span></div>
                <div class="widget-pill widget-weather"><i id="iconoClima" class="bi bi-sun-fill"></i> <span id="txtClima">--</span></div>
                <div class="widget-pill widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="fechaActual">--</span></div>
            </div>
        </div>
        <div class="d-flex align-items-center gap-3">
            <button id="darkModeToggle" class="btn btn-sm btn-outline-secondary rounded-circle d-flex align-items-center justify-content-center" style="width:38px;height:38px;" title="Modo oscuro">
                <i class="bi bi-moon-fill"></i>
            </button>
            <div class="user-profile shadow-sm">
                <?php if(!empty($_SESSION["imagen"]) && file_exists("../assets/uploads/usuarios/" . $_SESSION["imagen"])): ?>
                    <img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar-img" alt="Perfil">
                <?php else: ?>
                    <div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div>
                <?php endif; ?>
                <div>
                    <div style="font-size: 0.88rem; font-weight:bold;">Hola, <?php echo $_SESSION["nombre"]; ?></div>
                    <div style="font-size: 0.7rem; opacity:0.8; text-transform:uppercase;"><?php echo $_SESSION["rol"]; ?></div>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid p-4">
        <!-- Summary cards row -->
        <div class="row g-4 mb-4">
            <div class="col-md-3 col-6">
                <a href="../productos/index.php" class="card-stat stat-productos">
                    <div class="card-stat-icon"><i class="bi bi-book-half"></i></div>
                    <div class="card-stat-body"><h5>Productos</h5><div class="card-stat-title"><?php echo $tot_productos; ?></div></div>
                </a>
            </div>
            <div class="col-md-3 col-6">
                <a href="../ventas/index.php" class="card-stat stat-ventas">
                    <div class="card-stat-icon"><i class="bi bi-cash-stack"></i></div>
                    <div class="card-stat-body"><h5>Ventas</h5><div class="card-stat-title"><?php echo $tot_ventas_cant; ?></div></div>
                </a>
            </div>
            <div class="col-md-3 col-6">
                <a href="../proveedores/index.php" class="card-stat stat-proveedores">
                    <div class="card-stat-icon"><i class="bi bi-truck-flatbed"></i></div>
                    <div class="card-stat-body"><h5>Proveedores</h5><div class="card-stat-title"><?php echo $tot_proveedores; ?></div></div>
                </a>
            </div>
            <div class="col-md-3 col-6">
                <a href="../compras/index.php" class="card-stat stat-compras">
                    <div class="card-stat-icon"><i class="bi bi-bag-plus-fill"></i></div>
                    <div class="card-stat-body"><h5>Compras</h5><div class="card-stat-title"><?php echo $tot_compras; ?></div></div>
                </a>
            </div>
        </div>

        <!-- Hoy vs Ayer -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="day-card day-hoy">
                    <div class="day-card-icon"><i class="bi bi-calendar-check-fill"></i></div>
                    <div>
                        <h4>Ventas de Hoy</h4>
                        <div class="amount">Bs. <?php echo number_format($ventas_hoy['monto'], 2); ?></div>
                        <div class="count-label"><?php echo $ventas_hoy['total']; ?> transacciones</div>
                    </div>
                </div>
            </div>
            <div class="col-md-6">
                <div class="day-card day-ayer">
                    <div class="day-card-icon"><i class="bi bi-calendar-fill"></i></div>
                    <div>
                        <h4>Ventas de Ayer</h4>
                        <div class="amount">Bs. <?php echo number_format($ventas_ayer['monto'], 2); ?></div>
                        <div class="count-label"><?php echo $ventas_ayer['total']; ?> transacciones</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab selector -->
        <div class="tab-selector">
            <button class="tab-btn active" data-tab="dashboard-tab"><i class="bi bi-grid-3x3-gap-fill me-2"></i>Dashboard</button>
            <button class="tab-btn" data-tab="analytics-tab"><i class="bi bi-pie-chart-fill me-2"></i>Analíticas</button>
            <button class="tab-btn" data-tab="balance-tab"><i class="bi bi-graph-up-arrow me-2"></i>Balance Mensual</button>
        </div>

        <!-- Tab 1: Dashboard -->
        <div class="tab-content active" id="dashboard-tab">
            <!-- Rápida + Stock bajo row -->
            <div class="row g-4 mb-4">
                <div class="col-lg-8">
                    <div class="panel-custom">
                        <div class="panel-custom-header"><i class="bi bi-lightning-fill me-2 text-warning"></i> Accesos Rápidos</div>
                        <div class="panel-custom-body p-4">
                            <div class="quick-grid">
                                <a href="../usuarios/index.php" class="quick-card" style="border-color:#6366f1"><div class="q-icon"><i class="bi bi-people-fill" style="color:#6366f1"></i></div><div class="q-label">Usuarios</div></a>
                                <a href="../clientes/nuevo.php" class="quick-card" style="border-color:#06b6d4"><div class="q-icon"><i class="bi bi-person-plus-fill" style="color:#06b6d4"></i></div><div class="q-label">Nuevo Cliente</div></a>
                                <a href="../productos/nuevo.php" class="quick-card" style="border-color:#10b981"><div class="q-icon"><i class="bi bi-box-seam-fill" style="color:#10b981"></i></div><div class="q-label">Nuevo Producto</div></a>
                                <a href="../compras/nuevo.php" class="quick-card" style="border-color:#8b5cf6"><div class="q-icon"><i class="bi bi-bag-plus-fill" style="color:#8b5cf6"></i></div><div class="q-label">Registrar Compra</div></a>
                                <a href="../ventas/nuevo.php" class="quick-card" style="border-color:#14b8a6"><div class="q-icon"><i class="bi bi-cash-stack" style="color:#14b8a6"></i></div><div class="q-label">Registrar Venta</div></a>
                                <a href="../inventario/index.php" class="quick-card" style="border-color:#f97316"><div class="q-icon"><i class="bi bi-boxes" style="color:#f97316"></i></div><div class="q-label">Inventario</div></a>
                                <a href="../clientes/index.php" class="quick-card" style="border-color:#ec4899"><div class="q-icon"><i class="bi bi-person-hearts" style="color:#ec4899"></i></div><div class="q-label">Clientes</div></a>
                                <a href="../pedidos/index.php" class="quick-card" style="border-color:#84cc16"><div class="q-icon"><i class="bi bi-cart-check-fill" style="color:#84cc16"></i></div><div class="q-label">Pedidos Web</div></a>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="panel-custom">
                        <div class="panel-custom-header d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-exclamation-triangle-fill me-2 text-warning"></i> Stock Bajo</span>
                            <a href="../inventario/stock_bajo.php" class="btn btn-sm btn-outline-light">Ver todo</a>
                        </div>
                        <div class="panel-custom-body p-3">
                            <?php if(mysqli_num_rows($stock_bajo) > 0): ?>
                                <?php while($sb = mysqli_fetch_assoc($stock_bajo)): ?>
                                <div class="d-flex justify-content-between align-items-center p-2 mb-1 rounded-3" style="background:var(--body-bg);">
                                    <div>
                                        <strong style="font-size:0.85rem;"><?php echo htmlspecialchars($sb['nombre_producto']); ?></strong>
                                        <div class="text-muted small">Bs. <?php echo number_format($sb['precio'], 2); ?></div>
                                    </div>
                                    <span class="badge bg-danger bg-opacity-75 fs-6"><?php echo $sb['stock']; ?></span>
                                </div>
                                <?php endwhile; ?>
                            <?php else: ?>
                                <div class="text-center py-4 text-muted">
                                    <i class="bi bi-check-circle-fill text-success" style="font-size:2rem;"></i>
                                    <p class="mt-2 mb-0">No hay productos con stock bajo</p>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
            </div>

            <!-- === a) Ventas Mensuales Bar Chart === -->
            <div class="panel-custom mt-4">
                <div class="panel-custom-header"><i class="bi bi-bar-chart-fill me-2 text-warning"></i> Ventas Mensuales <?php echo date('Y'); ?></div>
                <div class="panel-custom-body p-4">
                    <canvas id="ventasMensualesChart" width="1000" height="350" style="width:100%;max-width:1000px;height:auto;max-height:350px;display:block;margin:0 auto;"></canvas>
                </div>
            </div>

            <!-- === b) Top Vendedores === -->
            <div class="panel-custom mt-4">
                <div class="panel-custom-header"><i class="bi bi-person-badge-fill me-2 text-warning"></i> Top Vendedores</div>
                <div class="panel-custom-body p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead><tr class="table-light"><th>Vendedor</th><th class="text-center">Ventas</th><th class="text-end">Total Bs.</th><th style="width:30%;"></th></tr></thead>
                            <tbody>
                                <?php if(count($tv_data)>0): ?>
                                <?php foreach($tv_data as $tv): $pct_bar = $max_vendedor_monto>0 ? ($tv['total_monto']/$max_vendedor_monto)*100 : 0; ?>
                                <tr>
                                    <td><strong><?php echo htmlspecialchars($tv['nombre']); ?></strong></td>
                                    <td class="text-center"><?php echo $tv['total_ventas']; ?></td>
                                    <td class="text-end fw-bold">Bs. <?php echo number_format($tv['total_monto'], 2); ?></td>
                                    <td>
                                        <div class="progress" style="height:8px;background:var(--body-bg);">
                                            <div class="progress-bar bg-success" style="width:<?php echo $pct_bar; ?>%;border-radius:4px;"></div>
                                        </div>
                                    </td>
                                </tr>
                                <?php endforeach; ?>
                                <?php else: ?>
                                <tr><td colspan="4" class="text-center text-muted py-3"><i class="bi bi-info-circle me-2"></i> No hay datos de vendedores disponibles. Asegúrate de que las ventas estén asignadas a usuarios.</td></tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- === c) Margen de Ganancia Real === -->
            <div class="panel-custom mt-4">
                <div class="panel-custom-header"><i class="bi bi-graph-up-arrow me-2 text-warning"></i> Margen de Ganancia Real (Top 10)</div>
                <div class="panel-custom-body p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead><tr class="table-light"><th>Producto</th><th class="text-end">Ingresos</th><th class="text-end">Costo</th><th class="text-end">Ganancia</th><th class="text-center">Margen</th></tr></thead>
                            <tbody>
                                <?php if(mysqli_num_rows($margen_ganancia)>0): ?>
                                <?php while($mg = mysqli_fetch_assoc($margen_ganancia)):
                                    $mg['ingresos'] = floatval($mg['ingresos']);
                                    $mg['costo'] = floatval($mg['costo']);
                                    $mg['ganancia'] = floatval($mg['ganancia']);
                                    $margen_pct = $mg['ingresos'] > 0 ? ($mg['ganancia']/$mg['ingresos'])*100 : 0;
                                    $color_margen = $margen_pct > 30 ? 'success' : ($margen_pct > 15 ? 'warning' : 'danger');
                                ?>
                                <tr>
                                    <td><strong><?php echo htmlspecialchars($mg['nombre_producto']); ?></strong></td>
                                    <td class="text-end">Bs. <?php echo number_format($mg['ingresos'], 2); ?></td>
                                    <td class="text-end">Bs. <?php echo number_format($mg['costo'], 2); ?></td>
                                    <td class="text-end fw-bold text-<?php echo $mg['ganancia']>=0?'success':'danger'; ?>">Bs. <?php echo number_format($mg['ganancia'], 2); ?></td>
                                    <td class="text-center"><span class="badge bg-<?php echo $color_margen; ?> fs-6"><?php echo number_format($margen_pct, 1); ?>%</span></td>
                                </tr>
                                <?php endwhile; ?>
                                <?php else: ?>
                                <tr><td colspan="5" class="text-center text-muted py-3"><i class="bi bi-info-circle me-2"></i> No hay datos de ventas con costo registrado.</td></tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab 2: Analíticas -->
        <div class="tab-content" id="analytics-tab">
            <!-- Stat cards grid -->
            <div class="row g-3 mb-4">
                <div class="col-md-4 col-6">
                    <div class="analytics-stat">
                        <div class="as-icon blue"><i class="bi bi-cart-plus"></i></div>
                        <div class="as-body">
                            <div class="as-label">Compras <?php echo date('Y'); ?></div>
                            <div class="as-value"><?php echo $compras_ea['total']; ?></div>
                            <div class="as-compare <?php echo $compras_aa['total'] > 0 && $compras_ea['total'] > $compras_aa['total'] ? 'up' : 'down'; ?>">
                                <i class="bi bi-arrow-<?php echo $compras_aa['total'] > 0 && $compras_ea['total'] > $compras_aa['total'] ? 'up' : 'down'; ?>"></i>
                                vs <?php echo date('Y')-1; ?>: <?php echo $compras_aa['total']; ?>
                            </div>
                            <div class="as-monto">Bs. <?php echo number_format($compras_ea['monto'], 2); ?></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-6">
                    <div class="analytics-stat">
                        <div class="as-icon green"><i class="bi bi-cash-coin"></i></div>
                        <div class="as-body">
                            <div class="as-label">Ventas <?php echo date('Y'); ?></div>
                            <div class="as-value"><?php echo $ventas_ea['total']; ?></div>
                            <div class="as-compare <?php echo $ventas_aa['total'] > 0 && $ventas_ea['total'] > $ventas_aa['total'] ? 'up' : 'down'; ?>">
                                <i class="bi bi-arrow-<?php echo $ventas_aa['total'] > 0 && $ventas_ea['total'] > $ventas_aa['total'] ? 'up' : 'down'; ?>"></i>
                                vs <?php echo date('Y')-1; ?>: <?php echo $ventas_aa['total']; ?>
                            </div>
                            <div class="as-monto">Bs. <?php echo number_format($ventas_ea['monto'], 2); ?></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-6">
                    <div class="analytics-stat">
                        <div class="as-icon purple"><i class="bi bi-trophy"></i></div>
                        <div class="as-body">
                            <div class="as-label">Producto Más Vendido</div>
                            <div class="as-value" style="font-size:1rem;"><?php echo $prod_top ? htmlspecialchars($prod_top['nombre_producto']) : 'N/A'; ?></div>
                            <div class="as-compare up"><i class="bi bi-box-seam"></i> <?php echo $prod_top ? $prod_top['total_vendido'].' uds.' : '0'; ?></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-6">
                    <div class="analytics-stat">
                        <div class="as-icon orange"><i class="bi bi-person-hearts"></i></div>
                        <div class="as-body">
                            <div class="as-label">Mejor Cliente</div>
                            <div class="as-value" style="font-size:1rem;"><?php echo $cli_top ? htmlspecialchars($cli_top['nombre_cliente']) : 'N/A'; ?></div>
                            <div class="as-compare up"><i class="bi bi-cash-stack"></i> Bs. <?php echo $cli_top ? number_format($cli_top['total_gastado'], 2) : '0.00'; ?></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4 col-6">
                    <div class="analytics-stat">
                        <div class="as-icon teal"><i class="bi bi-calendar-week"></i></div>
                        <div class="as-body">
                            <div class="as-label">Día + Ventas</div>
                            <div class="as-value" style="font-size:1rem;"><?php echo $dia_top ? ($dias_map[$dia_top['dia']]??$dia_top['dia']) : 'N/A'; ?></div>
                            <div class="as-compare up"><i class="bi bi-graph-up"></i> <?php echo $dia_top ? $dia_top['total'].' ventas' : '0'; ?></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="row g-4">
                <div class="col-md-5">
                    <div class="panel-custom">
                        <div class="panel-custom-header"><i class="bi bi-pie-chart-fill me-2"></i> Ventas por Método de Pago (<?php echo $anio_actual; ?>)</div>
                        <div class="panel-custom-body p-4 text-center">
                            <canvas id="pieChart" width="280" height="280"></canvas>
                            <div class="mt-3">
                                <?php foreach($datos_pie as $i => $dp): ?>
                                <span class="badge me-1 mb-1" style="background:<?php echo $colores_pie[$i % count($colores_pie)]; ?>">
                                    <?php echo $dp['metodo_pago']; ?>: Bs. <?php echo number_format($dp['monto'], 2); ?>
                                </span>
                                <?php endforeach; ?>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-md-7">
                    <div class="panel-custom">
                        <div class="panel-custom-header"><i class="bi bi-trophy-fill me-2 text-warning"></i> Top 5 Productos Más Vendidos (<?php echo $anio_actual; ?>)</div>
                        <div class="panel-custom-body p-4">
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead><tr class="table-light"><th>#</th><th>Producto</th><th class="text-center">Vendidos</th><th class="text-end">Ingresos</th></tr></thead>
                                    <tbody>
                                        <?php $rnk=1; while($tp = mysqli_fetch_assoc($top_productos)): ?>
                                        <tr>
                                            <td><span class="badge bg-warning text-dark fw-bold"><?php echo $rnk++; ?></span></td>
                                            <td><strong><?php echo htmlspecialchars($tp['nombre_producto']); ?></strong></td>
                                            <td class="text-center"><span class="badge bg-primary"><?php echo $tp['total_vendido']; ?></span></td>
                                            <td class="text-end fw-bold">Bs. <?php echo number_format($tp['total_ingresos'], 2); ?></td>
                                        </tr>
                                        <?php endwhile; ?>
                                        <?php if(mysqli_num_rows($top_productos)==0): ?>
                                        <tr><td colspan="4" class="text-center text-muted">Sin ventas registradas en <?php echo $anio_actual; ?></td></tr>
                                        <?php endif; ?>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Tab 3: Balance Mensual -->
        <div class="tab-content" id="balance-tab">
            <div class="panel-custom">
                <div class="panel-custom-header d-flex justify-content-between align-items-center">
                    <div><i class="bi bi-graph-up text-warning me-2"></i> Balance Estadístico Mensual</div>
                    <select class="form-select form-select-sm border-0" style="width: 110px;" onchange="location = '?anio='+this.value;">
                        <?php for ($y = 2026; $y <= 2032; $y++) { $sel = ($y == $anio_actual) ? 'selected' : ''; echo "<option value='$y' $sel>$y</option>"; } ?>
                    </select>
                </div>
                <div class="panel-custom-body p-4">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead><tr class="table-light"><th>Año</th><th>Mes</th><th>Tendencia</th><th>Ingreso Mensual</th><th>Prom. Diario</th><th>Desempeño</th><th>Progreso</th></tr></thead>
                            <tbody>
                                <?php foreach ($balance_vista as $mes => $datos) {
                                    $porcentaje = ($monto_maximo > 0) ? ($datos['total'] / $monto_maximo) * 100 : 0;
                                    $color = $porcentaje == 0 ? 'bg-secondary' : ($porcentaje < 30 ? 'bg-danger' : ($porcentaje < 70 ? 'bg-warning' : 'bg-success'));
                                    $mes_key = sprintf("%04d-%02d", $anio_actual, $mes);
                                ?>
                                <tr>
                                    <td><strong><?php echo $anio_actual; ?></strong></td>
                                    <td><?php echo $datos['mes_nombre']; ?></td>
                                    <td><canvas id="sparkline_<?php echo $mes; ?>" width="100" height="20" style="width:100px;height:20px;display:block;"></canvas></td>
                                    <td><strong>Bs. <?php echo number_format($datos['total'], 2); ?></strong></td>
                                    <td><span class="text-muted small">Bs. <?php echo number_format($datos['promedio_diario'], 2); ?></span></td>
                                    <td><span class="badge <?php echo $color; ?>"><?php echo number_format($porcentaje, 1); ?>%</span></td>
                                    <td style="width: 25%;"><div class="progress" style="height: 8px;"><div class="progress-bar <?php echo $color; ?>" style="width: <?php echo $porcentaje; ?>%"></div></div></td>
                                </tr>
                                <?php } ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function actualizarRelojYFecha() {
        const d = new Date();
        document.getElementById('relojDigital').innerText = d.toTimeString().split(' ')[0];
        const meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];
        document.getElementById('fechaActual').textContent = d.getDate() + '/' + meses[d.getMonth()] + '/' + d.getFullYear();
    }
    actualizarRelojYFecha();
    setInterval(actualizarRelojYFecha, 1000);

    function obtenerClima() {
        const lat = -17.88; const lon = -63.25;
        document.getElementById('txtClima').textContent = '---';
        fetch('https://api.open-meteo.com/v1/forecast?latitude='+lat+'&longitude='+lon+'&current=temperature_2m,weather_code')
            .then(r => r.json())
            .then(d => { if(d && d.current) document.getElementById('txtClima').textContent = Math.round(d.current.temperature_2m) + '°C'; })
            .catch(() => document.getElementById('txtClima').textContent = '17°C');
    }
    obtenerClima();
    setInterval(obtenerClima, 900000);

    // Dark mode toggle
    var btn = document.getElementById('darkModeToggle');
    var saved = localStorage.getItem('theme');
    if (window.aplicarTema) { window.aplicarTema(saved || 'light'); }
    if (btn) {
        btn.querySelector('i').className = saved === 'dark' ? 'bi bi-moon-fill' : saved === 'sepia' ? 'bi bi-brightness-alt-high-fill' : 'bi bi-sun-fill';
        btn.addEventListener('click', function() {
            if (window.ciclarTema) { window.ciclarTema(); }
            var cur = document.documentElement.getAttribute('data-theme') || 'light';
            this.querySelector('i').className = cur === 'dark' ? 'bi bi-moon-fill' : cur === 'sepia' ? 'bi bi-brightness-alt-high-fill' : 'bi bi-sun-fill';
        });
    }

    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(function(btn){
        btn.addEventListener('click', function(){
            document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
            document.querySelectorAll('.tab-content').forEach(function(t){ t.classList.remove('active'); });
            this.classList.add('active');
            document.getElementById(this.dataset.tab).classList.add('active');
        });
    });

    // Pie chart (pure canvas)
    (function(){
        var canvas = document.getElementById('pieChart');
        if (!canvas) return;
        var ctx = canvas.getContext('2d');
        var data = <?php echo json_encode($pie_json); ?>;
        var labels = <?php echo json_encode($pie_labels); ?>;
        var colors = <?php echo json_encode($pie_colors); ?>;
        if (data.length === 0) {
            ctx.fillStyle = '#ccc';
            ctx.font = '14px Segoe UI';
            ctx.textAlign = 'center';
            ctx.fillText('Sin datos', 140, 140);
            return;
        }
        var total = data.reduce(function(a,b){ return a+b; }, 0);
        if (total === 0) {
            ctx.fillStyle = '#ccc';
            ctx.font = '14px Segoe UI';
            ctx.textAlign = 'center';
            ctx.fillText('Sin datos', 140, 140);
            return;
        }
        var cx = 140, cy = 140, r = 120;
        var startAngle = -Math.PI / 2;
        for (var i = 0; i < data.length; i++) {
            var sliceAngle = (data[i] / total) * 2 * Math.PI;
            ctx.beginPath();
            ctx.moveTo(cx, cy);
            ctx.arc(cx, cy, r, startAngle, startAngle + sliceAngle);
            ctx.closePath();
            ctx.fillStyle = colors[i % colors.length];
            ctx.fill();
            var midAngle = startAngle + sliceAngle / 2;
            var tx = cx + (r * 0.65) * Math.cos(midAngle);
            var ty = cy + (r * 0.65) * Math.sin(midAngle);
            ctx.fillStyle = '#fff';
            ctx.font = 'bold 12px Segoe UI';
            ctx.textAlign = 'center';
            var pct = ((data[i] / total) * 100).toFixed(1);
            ctx.fillText(pct + '%', tx, ty);
            startAngle += sliceAngle;
        }
        // Centro
        ctx.beginPath();
        ctx.arc(cx, cy, 50, 0, 2 * Math.PI);
        ctx.fillStyle = 'var(--panel-bg, #fff)';
        ctx.fill();
        ctx.fillStyle = 'var(--profile-text, #333)';
        ctx.font = 'bold 14px Segoe UI';
        ctx.textAlign = 'center';
        ctx.fillText('Bs.', cx, cy - 8);
        ctx.font = 'bold 16px Segoe UI';
        ctx.fillText(total.toFixed(0), cx, cy + 14);
    })();

    // === Ventas Mensuales Bar Chart ===
    (function(){
        var canvas = document.getElementById('ventasMensualesChart');
        if (!canvas) return;
        var ctx = canvas.getContext('2d');
        var data = <?php
            $vm_chart = [];
            foreach ($ventas_mensuales as $k => $v) $vm_chart[] = $v['monto'];
            echo json_encode($vm_chart);
        ?>;
        var meses = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
        var W = canvas.width, H = canvas.height;
        var pad = {top:30, bottom:40, left:55, right:30};
        var chartW = W - pad.left - pad.right;
        var chartH = H - pad.top - pad.bottom;

        // Compute max and cumulative
        var maxVal = Math.max.apply(null, data);
        if (maxVal === 0) maxVal = 1;
        var cumulative = 0;
        var cumData = [];
        data.forEach(function(v){ cumulative += v; cumData.push(cumulative); });
        var maxCum = Math.max.apply(null, cumData);
        if (maxCum === 0) maxCum = 1;

        // Colors (sepia/warm palette)
        var barColors = ['#D4A574','#C4956A','#B4855A','#A4754A','#94653A','#84552A','#7A4C26','#6E4422','#623C1E','#56341A','#4A2C16','#3E2412'];

        // Clear
        ctx.clearRect(0, 0, W, H);

        // Y axis grid lines
        ctx.strokeStyle = 'rgba(0,0,0,0.06)';
        ctx.lineWidth = 1;
        ctx.setLineDash([4,4]);
        var steps = 5;
        for (var i = 0; i <= steps; i++) {
            var y = pad.top + chartH - (i/steps) * chartH;
            ctx.beginPath();
            ctx.moveTo(pad.left, y);
            ctx.lineTo(W - pad.right, y);
            ctx.stroke();
        }
        ctx.setLineDash([]);

        // Y axis labels
        ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue('--profile-text').trim() || '#666';
        ctx.font = '10px Segoe UI';
        ctx.textAlign = 'right';
        ctx.textBaseline = 'middle';
        for (var i = 0; i <= steps; i++) {
            var y = pad.top + chartH - (i/steps) * chartH;
            ctx.fillText('Bs.' + (maxVal * i / steps).toFixed(0), pad.left - 8, y);
        }

        var barW = chartW / data.length * 0.6;
        var gap = chartW / data.length;

        // Draw bars
        for (var i = 0; i < data.length; i++) {
            var x = pad.left + i * gap + (gap - barW) / 2;
            var barH = (data[i] / maxVal) * chartH;
            var y = pad.top + chartH - barH;

            // Rounded rect bar
            var r = 4;
            ctx.beginPath();
            ctx.moveTo(x + r, y);
            ctx.lineTo(x + barW - r, y);
            ctx.quadraticCurveTo(x + barW, y, x + barW, y + r);
            ctx.lineTo(x + barW, pad.top + chartH);
            ctx.lineTo(x, pad.top + chartH);
            ctx.lineTo(x, y + r);
            ctx.quadraticCurveTo(x, y, x + r, y);
            ctx.closePath();
            ctx.fillStyle = barColors[i % barColors.length];
            ctx.fill();

            // Number on top
            if (data[i] > 0) {
                ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue('--profile-text').trim() || '#333';
                ctx.font = 'bold 10px Segoe UI';
                ctx.textAlign = 'center';
                ctx.textBaseline = 'bottom';
                ctx.fillText('Bs.' + data[i].toFixed(0), x + barW / 2, y - 3);
            }

            // Month label
            ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue('--profile-text').trim() || '#666';
            ctx.font = '10px Segoe UI';
            ctx.textAlign = 'center';
            ctx.textBaseline = 'top';
            ctx.fillText(meses[i], x + barW / 2, pad.top + chartH + 5);
        }

        // Cumulative line
        ctx.beginPath();
        ctx.strokeStyle = '#1e3c72';
        ctx.lineWidth = 2;
        var cumScale = chartH / maxCum;
        for (var i = 0; i < data.length; i++) {
            var x = pad.left + i * gap + barW / 2;
            var y = pad.top + chartH - cumData[i] * cumScale;
            if (i === 0) ctx.moveTo(x, y);
            else ctx.lineTo(x, y);
        }
        ctx.stroke();

        // Legend
        var legY = H - 8;
        ctx.fillStyle = barColors[0];
        ctx.fillRect(W - pad.right - 90, legY - 8, 12, 12);
        ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue('--profile-text').trim() || '#333';
        ctx.font = '9px Segoe UI';
        ctx.textAlign = 'left';
        ctx.textBaseline = 'middle';
        ctx.fillText('Mensual', W - pad.right - 75, legY - 2);
        ctx.strokeStyle = '#1e3c72';
        ctx.lineWidth = 2;
        ctx.beginPath();
        ctx.moveTo(W - pad.right - 90, legY + 8);
        ctx.lineTo(W - pad.right - 78, legY + 8);
        ctx.stroke();
        ctx.fillStyle = getComputedStyle(document.documentElement).getPropertyValue('--profile-text').trim() || '#333';
        ctx.fillText('Acumulado', W - pad.right - 75, legY + 8);
    })();

    // === Sparklines for Balance Mensual ===
    (function(){
        var sparkData = <?php echo json_encode($sparkline_data); ?>;
        for (var mesKey in sparkData) {
            var parts = mesKey.split('-');
            var mesNum = parseInt(parts[1], 10);
            var canvas = document.getElementById('sparkline_' + mesNum);
            if (!canvas) continue;
            var vals = sparkData[mesKey];
            if (!vals || vals.length < 2) {
                var ctx2 = canvas.getContext('2d');
                ctx2.fillStyle = '#ccc';
                ctx2.font = '8px Segoe UI';
                ctx2.textAlign = 'center';
                ctx2.fillText('—', 50, 12);
                continue;
            }
            var ctx2 = canvas.getContext('2d');
            var w = canvas.width, h = canvas.height;
            var maxV = Math.max.apply(null, vals);
            if (maxV === 0) maxV = 1;
            var minV = Math.min.apply(null, vals);
            var range = maxV - minV || 1;
            ctx2.clearRect(0, 0, w, h);

            // Gradient fill under line
            ctx2.beginPath();
            var stepX = w / (vals.length - 1);
            for (var i = 0; i < vals.length; i++) {
                var x = i * stepX;
                var y = h - ((vals[i] - minV) / range) * (h - 4) - 2;
                if (i === 0) ctx2.moveTo(x, y);
                else ctx2.lineTo(x, y);
            }
            ctx2.lineTo(w - stepX, h);
            ctx2.lineTo(0, h);
            ctx2.closePath();
            var grad = ctx2.createLinearGradient(0, 0, 0, h);
            grad.addColorStop(0, 'rgba(30,60,114,0.25)');
            grad.addColorStop(1, 'rgba(30,60,114,0.02)');
            ctx2.fillStyle = grad;
            ctx2.fill();

            // Line
            ctx2.beginPath();
            for (var i = 0; i < vals.length; i++) {
                var x = i * stepX;
                var y = h - ((vals[i] - minV) / range) * (h - 4) - 2;
                if (i === 0) ctx2.moveTo(x, y);
                else ctx2.lineTo(x, y);
            }
            ctx2.strokeStyle = '#2a5298';
            ctx2.lineWidth = 1.5;
            ctx2.stroke();

            // Dot on last
            var lastX = (vals.length - 1) * stepX;
            var lastY = h - ((vals[vals.length-1] - minV) / range) * (h - 4) - 2;
            ctx2.beginPath();
            ctx2.arc(lastX, lastY, 2, 0, Math.PI * 2);
            ctx2.fillStyle = '#1e3c72';
            ctx2.fill();
        }
    })();
</script>
</body>
</html>
