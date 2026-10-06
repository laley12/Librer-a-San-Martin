<?php
session_start();
include("../config/conexion.php");
if(!isset($_SESSION['id'])){ header("Location: ../login/login.php"); exit(); }

include("../includes/paginador.php");
include("../includes/exportar.php");

$where = "WHERE 1=1";
$fd=''; $fh='';
if(isset($_GET['fecha_desde']) || isset($_POST['filtrar'])){
    if(!empty($_GET['fecha_desde'])){ $fd = mysqli_real_escape_string($conexion,$_GET['fecha_desde']); $where.=" AND v.fecha>='$fd'"; }
    elseif(!empty($_POST['fecha_desde'])){ $fd = mysqli_real_escape_string($conexion,$_POST['fecha_desde']); $where.=" AND v.fecha>='$fd'"; }
    if(!empty($_GET['fecha_hasta'])){ $fh = mysqli_real_escape_string($conexion,$_GET['fecha_hasta']); $where.=" AND v.fecha<='$fh'"; }
    elseif(!empty($_POST['fecha_hasta'])){ $fh = mysqli_real_escape_string($conexion,$_POST['fecha_hasta']); $where.=" AND v.fecha<='$fh'"; }
}

$url_params = '';
if($fd) $url_params .= '&fecha_desde=' . urlencode($fd);
if($fh) $url_params .= '&fecha_hasta=' . urlencode($fh);

$sql_data = "SELECT v.id_venta,v.fecha,v.total,p.nombre_producto,dv.cantidad,dv.precio FROM ventas v INNER JOIN detalle_ventas dv ON v.id_venta=dv.venta_id INNER JOIN productos p ON dv.producto_id=p.id_producto $where ORDER BY v.fecha DESC";
$res = mysqli_fetch_assoc(mysqli_query($conexion,"SELECT COUNT(DISTINCT id_venta) AS tv, COALESCE(SUM(total),0) AS ti FROM ventas $where"));

if(isset($_GET['exportar'])){
    $datos = mysqli_query($conexion, $sql_data);
    $filas = [];
    while($row = mysqli_fetch_assoc($datos)) $filas[] = $row;
    if($_GET['exportar'] == 'xls') exportar_excel($filas, 'ventas_periodo');
    if($_GET['exportar'] == 'pdf'){
        $html = '<h2>Ventas por Periodo</h2><p>Desde: '.$fd.' Hasta: '.$fh.'</p><table><thead><tr><th>Fecha</th><th>Producto</th><th>Cant.</th><th>P. Unitario</th><th>Total</th></tr></thead><tbody>';
        foreach($filas as $f) $html .= '<tr><td>'.$f['fecha'].'</td><td>'.htmlspecialchars($f['nombre_producto']).'</td><td>'.$f['cantidad'].'</td><td>Bs. '.number_format($f['precio'],2).'</td><td>Bs. '.number_format($f['total'],2).'</td></tr>';
        $html .= '</tbody></table>';
        exportar_pdf($html, 'ventas_periodo');
    }
}
?><!DOCTYPE html><html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ventas por Fecha - Reportes</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
        }
body{background:var(--body-bg);font-family:'Segoe UI',sans-serif;margin:0;overflow-x:hidden}
.sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; }
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
.collapse-submenu-2::before { content: ''; position: absolute; left: 35px; top: 4px; bottom: 4px; width: 2px; background: repeating-linear-gradient(to bottom, #94a3b8 0px, #94a3b8 4px, transparent 4px, transparent 8px); }
.collapse-submenu-2 a { padding-left: 62px !important; font-size: 0.88rem !important; position: relative; }
.collapse-submenu-2 a::before { content: ''; position: absolute; left: 35px; top: 50%; transform: translateY(-50%); width: 20px; height: 0; border-top: 2px dashed var(--collapse-dash); }
.collapse-submenu-2 a:hover { background: var(--sidebar-hover-bg); }
.sub-item-active { color: var(--sidebar-accent) !important; font-weight: 600; background-color: #f8fafc !important; border-left: 3px solid #2a5298; border-radius: 0 8px 8px 0; }
.collapse-toggle { display: flex; justify-content: space-between; align-items: center; }
.collapse-toggle .chevron-icon { font-size: 0.8rem; transition: transform 0.2s ease; }
.collapse-toggle[aria-expanded="true"] .chevron-icon { transform: rotate(180deg); }
.main-content{margin-left:260px;min-height:100vh}
.topbar{background:var(--topbar-bg);backdrop-filter:blur(10px);padding:15px 30px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border-color);position:sticky;top:0;z-index:999}
.topbar-title{font-size:1.2rem;font-weight:600;color:#1e3c72}
.topbar-widgets{display:flex;align-items:center;gap:12px}
.widget-box{padding:6px 14px;border-radius:20px;font-size:.88rem;font-weight:600;display:flex;align-items:center;box-shadow:0 2px 6px rgba(0,0,0,0.02)}
.widget-time{background:#e0f2fe;color:#0369a1}
.widget-date{background:#dcfce7;color:#15803d}
.user-profile{display:flex;align-items:center;background:var(--profile-bg);padding:6px 14px;border-radius:20px;font-size:.9rem;color:var(--profile-text)}
.panel-custom{border:none;border-radius:12px;background:var(--panel-bg);box-shadow:0 4px 15px rgba(0,0,0,0.02);margin-bottom:30px;animation:fadeInUp .5s ease-in-out}
.panel-custom-header{padding:20px;font-size:1.05rem;font-weight:600;color:#fff;border-radius:12px 12px 0 0;background:var(--panel-header-bg);display:flex;justify-content:space-between;align-items:center}
@keyframes fadeInUp{from{opacity:0;transform:translateY(15px)}to{opacity:1;transform:translateY(0)}}
.card-resumen{border-left:4px solid #059669;background:#f8fafc;border-radius:10px;padding:18px}
.filtro{background:#f1f5f9;border-radius:10px;padding:15px}
.profile-avatar-wrap { flex-shrink: 0; margin-right: 10px; display: flex; align-items: center; }
.profile-avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-info { display: flex; flex-direction: column; line-height: 1.2; }
.profile-name { font-size: 0.88rem; white-space: nowrap; }
.profile-role { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; white-space: nowrap; }
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
.sidebar { transition: all 0.3s ease; }
.main-content { transition: all 0.3s ease; }
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
</style></head><body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content">
<div class="topbar"><div class="topbar-title"><i class="bi bi-calendar-range me-2"></i> Reportes > Ventas por Fecha</div>
<div class="topbar-widgets"><div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div><div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div><div class="widget-box widget-weather"><i class="bi bi-sun-fill me-2"></i> <span>17°C</span></div><div class="user-profile shadow-sm">
    <div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div>
    <div class="profile-info">
        <div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div>
        <div class="profile-role"><?php echo $_SESSION["rol"]; ?></div>
    </div>
</div>
        </div>
    </div>

    <div class="container-fluid p-4">
<div class="panel-custom shadow-sm"><div class="panel-custom-header"><i class="bi bi-funnel me-2"></i> <span class="menu-text"> Filtrar por Rango de Fechas</span></div>
<div class="panel-custom-body p-4"><form method="GET" class="filtro"><div class="row g-3 align-items-end">
<div class="col-md-4"><label class="form-label fw-semibold">Desde</label><input type="date" name="fecha_desde" class="form-control" value="<?php echo $fd; ?>"></div>
<div class="col-md-4"><label class="form-label fw-semibold">Hasta</label><input type="date" name="fecha_hasta" class="form-control" value="<?php echo $fh; ?>"></div>
<div class="col-md-4 d-flex gap-2"><button type="submit" name="filtrar" class="btn btn-primary w-100 fw-bold"><i class="bi bi-search me-1"></i> Filtrar</button><a href="ventas_periodo.php" class="btn btn-outline-secondary w-100"><i class="bi bi-x-circle me-1"></i> <span class="menu-text">Limpiar</span></a></div></div></form></div></div>

<div class="row g-3 mb-4"><div class="col-md-6"><div class="card-resumen shadow-sm h-100"><h6 class="text-muted mb-1">Ventas en el Periodo</h6><span class="fs-3 fw-bold text-primary"><?php echo $res['tv']; ?></span></div></div>
<div class="col-md-6"><div class="card-resumen shadow-sm h-100" style="border-left-color:#d97706;"><h6 class="text-muted mb-1">Total Ingresos</h6><span class="fs-3 fw-bold" style="color:#d97706;">Bs. <?php echo number_format($res['ti'],2); ?></span></div></div></div>

<div class="panel-custom shadow-sm"><div class="panel-custom-header"><i class="bi bi-journal-check me-2"></i> <span class="menu-text"> Ventas Registradas</span><span class="badge bg-light text-dark"><?php echo $res['tv']; ?> registros</span></div>
<div class="panel-custom-body p-4">
<div class="row mb-3">
    <div class="col-md-6">
        <input type="text" id="buscador" class="form-control form-control-sm" placeholder="Buscar en ventas...">
    </div>
    <div class="col-md-6 text-end">
        <a href="?exportar=xls<?php echo $url_params; ?>" class="btn btn-success btn-sm me-1"><i class="bi bi-file-earmark-excel"></i> Excel</a>
        <a href="?exportar=pdf<?php echo $url_params; ?>" class="btn btn-danger btn-sm"><i class="bi bi-file-earmark-pdf"></i> PDF</a>
    </div>
</div>
<div class="table-responsive"><table class="table table-hover align-middle mb-0"><thead><tr class="table-light"><th>N°</th><th>Fecha</th><th>Producto</th><th class="text-center">Cant.</th><th class="text-end">P. Unitario</th><th class="text-end">Total</th></tr></thead>
<tbody><?php if(mysqli_num_rows($ventas = mysqli_query($conexion, $sql_data))>0){ $i=1; while($f=mysqli_fetch_assoc($ventas)){ ?>
<tr><td><span class="badge bg-secondary-subtle text-secondary fw-bold"><?php echo $i++; ?></span></td><td><?php echo $f['fecha']; ?></td><td><?php echo htmlspecialchars($f['nombre_producto']); ?></td><td class="text-center"><?php echo $f['cantidad']; ?> u.</td><td class="text-end">Bs. <?php echo number_format($f['precio'],2); ?></td><td class="text-end"><span class="badge bg-success-subtle text-success fs-6 fw-bold">Bs. <?php echo number_format($f['total'],2); ?></span></td></tr>
<?php } }else{ ?><tr><td colspan="6" class="text-center text-muted py-3">No hay ventas en el periodo seleccionado.</td></tr><?php } ?></tbody></table></div></div></div></div></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('buscador')?.addEventListener('keyup', function(){
    var q = this.value.toLowerCase();
    document.querySelectorAll('table tbody tr').forEach(function(row){
        row.style.display = row.textContent.toLowerCase().indexOf(q) > -1 ? '' : 'none';
    });
});
function init(){const a=new Date();document.getElementById('txt-reloj').textContent=String(a.getHours()).padStart(2,'0')+':'+String(a.getMinutes()).padStart(2,'0')+':'+String(a.getSeconds()).padStart(2,'0');const m=['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];document.getElementById('txt-fecha').textContent=String(a.getDate()).padStart(2,'0')+'/'+m[a.getMonth()]+'/'+a.getFullYear();}init();setInterval(init,1000);

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

    document.addEventListener('keydown', function(e) {
        if (e.ctrlKey && e.key === 'n') {
            e.preventDefault();
            const modal = document.querySelector('[data-bs-target]');
            if (modal) {
                const target = modal.getAttribute('data-bs-target');
                const el = document.querySelector(target);
                if (el) { const m = new bootstrap.Modal(el); m.show(); return; }
            }
            const nuevo = document.querySelector('a[href*="nuevo.php"]');
            if (nuevo) { window.location.href = nuevo.getAttribute('href'); }
        }
        if (e.ctrlKey && e.key === 'f') {
            e.preventDefault();
            const input = document.getElementById('buscador');
            if (input) input.focus();
        }
        if (e.ctrlKey && e.key === 's') {
            const form = document.querySelector('form');
            if (form && e.target.closest('form')) { e.preventDefault(); form.querySelector('[type="submit"]')?.click(); }
        }
    });

</script></body></html>
