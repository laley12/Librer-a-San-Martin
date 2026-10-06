<?php
date_default_timezone_set('America/La_Paz');
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id_user = intval($_SESSION['id']);
$rol = $_SESSION['rol'] ?? 'Empleado';
$es_admin = ($rol === 'Administrador');

$where = $es_admin ? "1=1" : "ac.id_usuario = $id_user";
$params = [];

if ($es_admin && !empty($_GET['usuario'])) {
    $busq = mysqli_real_escape_string($conexion, $_GET['usuario']);
    $where .= " AND u.nombre LIKE '%$busq%'";
}
if (!empty($_GET['desde'])) {
    $desde = mysqli_real_escape_string($conexion, $_GET['desde']);
    $where .= " AND DATE(ac.fecha_apertura) >= '$desde'";
}
if (!empty($_GET['hasta'])) {
    $hasta = mysqli_real_escape_string($conexion, $_GET['hasta']);
    $where .= " AND DATE(ac.fecha_apertura) <= '$hasta'";
}

$historial = mysqli_query($conexion, "
    SELECT ac.*, u.nombre, u.imagen, u.rol
    FROM apertura_caja ac
    INNER JOIN usuarios u ON ac.id_usuario = u.id
    WHERE $where AND ac.activo = 0
    ORDER BY ac.fecha_cierre DESC
");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Historial de Turnos - Librería San Martín</title>
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
.card-custom { border: none; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); }
.card-custom .card-header { background: linear-gradient(135deg, #2a5298, #1e3c72); color: #fff; border-radius: 12px 12px 0 0; padding: 16px 20px; font-weight: 600; }
.card-custom .card-body { padding: 20px; }
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
            .sidebar.collapsed .collapse-toggle .chevron-icon { display: inline; }
            .sidebar.collapsed .collapse-submenu { display: block !important; }
            .sidebar.collapsed ~ .main-content { margin-left: 0; }
            .main-content { margin-left: 0 !important; }
            .sidebar ~ .main-content { margin-left: 0; }
            #sidebarOverlay { display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); z-index: 999; }
            #sidebarOverlay.show { display: block; }
            .topbar { padding: 12px 15px; flex-wrap: wrap; gap: 8px; }
            .topbar-widgets .widget-box { font-size: 0.7rem; padding: 4px 8px; }
            .topbar-widgets .user-profile .profile-name { font-size: 0.7rem; }
            .topbar-widgets .user-profile .profile-role { display: none; }
            .container-fluid.p-4 { padding: 12px !important; }
            .panel-custom-header { padding: 14px 16px; font-size: 0.95rem; }
            .panel-custom-body { padding: 14px; }
            .table { font-size: 0.78rem; }
            .hamburger-btn { display: flex !important; }
            .topbar-title { font-size: 1rem; }
        }
    </style>
</head>
<body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content">
    <div class="topbar">
        <div style="display:flex;align-items:center;gap:12px;">
            <button class="hamburger-btn" id="sidebarToggleMobile" onclick="document.getElementById('mainSidebar').classList.toggle('mobile-open');document.getElementById('sidebarOverlay').classList.toggle('show');" title="Menú"><i class="bi bi-list"></i></button>
            <div class="topbar-title"><i class="bi bi-clock-history me-2"></i> Historial de Turnos</div>
        </div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill me-1"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill me-1"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="user-profile">
                <div class="profile-avatar-wrap">
                    <?php if(!empty($_SESSION['imagen'])): ?>
                        <img src="<?php echo BASE_PATH; ?>assets/uploads/usuarios/<?php echo htmlspecialchars($_SESSION['imagen']); ?>" class="profile-avatar">
                    <?php else: ?>
                        <div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION['nombre'] ?? 'U', 0, 1)); ?></div>
                    <?php endif; ?>
                </div>
                <div class="profile-info">
                    <span class="profile-name"><?php echo htmlspecialchars($_SESSION['nombre'] ?? ''); ?></span>
                    <span class="profile-role"><?php echo htmlspecialchars($_SESSION['rol'] ?? ''); ?></span>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid p-4">

        <?php if ($es_admin): ?>
        <div class="card card-custom mb-4">
            <div class="card-header"><i class="bi bi-funnel me-2"></i> Filtros</div>
            <div class="card-body">
                <form method="GET" class="row g-3 align-items-end">
                    <div class="col-md-4">
                        <label class="form-label fw-bold small">Buscar Personal</label>
                        <input type="text" name="usuario" class="form-control" placeholder="Nombre del usuario..." value="<?php echo htmlspecialchars($_GET['usuario'] ?? ''); ?>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold small">Desde</label>
                        <input type="date" name="desde" class="form-control" value="<?php echo htmlspecialchars($_GET['desde'] ?? ''); ?>">
                    </div>
                    <div class="col-md-3">
                        <label class="form-label fw-bold small">Hasta</label>
                        <input type="date" name="hasta" class="form-control" value="<?php echo htmlspecialchars($_GET['hasta'] ?? ''); ?>">
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary w-100" style="background:#1e3c72;border:none;"><i class="bi bi-search me-1"></i>Filtrar</button>
                    </div>
                </form>
            </div>
        </div>
        <?php endif; ?>

        <div class="card card-custom">
            <div class="card-header"><i class="bi bi-table me-2"></i> Registro de Turnos</div>
            <div class="card-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" style="font-size:0.9rem;">
                        <thead class="table-light">
                            <tr>
                                <th>Fecha</th>
                                <th>Usuario</th>
                                <th>Rol</th>
                                <th>Entrada</th>
                                <th>Salida</th>
                                <th>Tiempo Trabajado</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if ($historial && mysqli_num_rows($historial) > 0): ?>
                                <?php while ($h = mysqli_fetch_assoc($historial)): 
                                    $entrada = new DateTime($h['fecha_apertura']);
                                    $salida = new DateTime($h['fecha_cierre']);
                                    $diff = $entrada->diff($salida);
                                    $tiempo = $diff->h . 'h ' . $diff->i . 'm';
                                ?>
                                <tr>
                                    <td><?php echo $entrada->format('d/m/Y'); ?></td>
                                    <td>
                                        <div class="d-flex align-items-center gap-2">
                                            <?php if ($h['imagen']): ?>
                                                <img src="<?php echo BASE_PATH; ?>assets/uploads/usuarios/<?php echo htmlspecialchars($h['imagen']); ?>" style="width:26px;height:26px;border-radius:50%;object-fit:cover;">
                                            <?php else: ?>
                                                <div style="width:26px;height:26px;border-radius:50%;background:linear-gradient(135deg,#1e3c72,#2a5298);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.75rem;"><?php echo strtoupper(substr($h['nombre'], 0, 1)); ?></div>
                                            <?php endif; ?>
                                            <strong><?php echo htmlspecialchars($h['nombre']); ?></strong>
                                        </div>
                                    </td>
                                    <td><span class="badge bg-<?php echo $h['rol'] === 'Administrador' ? 'warning text-dark' : 'info'; ?>"><?php echo htmlspecialchars($h['rol']); ?></span></td>
                                    <td><span class="text-muted"><?php echo $entrada->format('H:i'); ?></span></td>
                                    <td><span class="text-muted"><?php echo $salida->format('H:i'); ?></span></td>
                                    <td><strong><?php echo $tiempo; ?></strong></td>
                                </tr>
                                <?php endwhile; ?>
                            <?php else: ?>
                                <tr><td colspan="6" class="text-center text-muted py-4">No hay turnos registrados</td></tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>
</div>

<script src="<?php echo BASE_PATH; ?>assets/js/bootstrap.bundle.min.js"></script>
<script>
function inicializarRelojYFecha() {
    var ahora = new Date();
    var utc = ahora.getTime() + (ahora.getTimezoneOffset() * 60000);
    var bolivia = new Date(utc + (-14400000));
    document.getElementById('txt-reloj').textContent = String(bolivia.getHours()).padStart(2,'0')+':'+String(bolivia.getMinutes()).padStart(2,'0')+':'+String(bolivia.getSeconds()).padStart(2,'0');
    var meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
    document.getElementById('txt-fecha').textContent = String(bolivia.getDate()).padStart(2,'0')+'/'+meses[bolivia.getMonth()]+'/'+bolivia.getFullYear();
}
inicializarRelojYFecha();
setInterval(inicializarRelojYFecha, 1000);
</script>
</body>
</html>
