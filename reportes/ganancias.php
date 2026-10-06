<?php
session_start();
include("../config/conexion.php");
if(!isset($_SESSION['id'])){ header("Location: ../login/login.php"); exit(); }

include("../includes/paginador.php");
include("../includes/exportar.php");

$filtro_mes = $_GET['mes'] ?? date('Y-m');

$total_ventas = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COALESCE(SUM(total),0) AS total FROM ventas WHERE DATE_FORMAT(fecha, '%Y-%m') = '$filtro_mes'"))['total'];
$total_compras = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COALESCE(SUM(total),0) AS total FROM compras WHERE DATE_FORMAT(fecha, '%Y-%m') = '$filtro_mes'"))['total'];
$ganancia = $total_ventas - $total_compras;

$sql_data = "
    SELECT m.mes, 
           COALESCE(v.total_v,0) AS ventas, 
           COALESCE(c.total_c,0) AS compras, 
           (COALESCE(v.total_v,0) - COALESCE(c.total_c,0)) AS ganancia
    FROM (
        SELECT DISTINCT DATE_FORMAT(fecha, '%Y-%m') AS mes FROM ventas
        UNION
        SELECT DISTINCT DATE_FORMAT(fecha, '%Y-%m') AS mes FROM compras
    ) m
    LEFT JOIN (SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, SUM(total) AS total_v FROM ventas GROUP BY mes) v ON m.mes = v.mes
    LEFT JOIN (SELECT DATE_FORMAT(fecha, '%Y-%m') AS mes, SUM(total) AS total_c FROM compras GROUP BY mes) c ON m.mes = c.mes
    ORDER BY m.mes DESC
";
$mensual = mysqli_query($conexion, $sql_data);

if(isset($_GET['exportar'])){
    $filas = [];
    $r = mysqli_query($conexion, $sql_data);
    while($row = mysqli_fetch_assoc($r)) $filas[] = $row;
    if($_GET['exportar'] == 'xls') exportar_excel($filas, 'ganancias');
    if($_GET['exportar'] == 'pdf'){
        $html = '<h2>Ganancias Mensuales</h2><p>Periodo: '.$filtro_mes.'</p>';
        $html .= '<h3>Resumen: Ventas Bs. '.number_format($total_ventas,2).' | Compras Bs. '.number_format($total_compras,2).' | Ganancia Bs. '.number_format($ganancia,2).'</h3>';
        $html .= '<table><thead><tr><th>Mes</th><th>Ventas</th><th>Compras</th><th>Ganancia</th></tr></thead><tbody>';
        foreach($filas as $m) $html .= '<tr><td>'.$m['mes'].'</td><td>Bs. '.number_format($m['ventas'],2).'</td><td>Bs. '.number_format($m['compras'],2).'</td><td>Bs. '.number_format($m['ganancia'],2).'</td></tr>';
        $html .= '</tbody></table>';
        exportar_pdf($html, 'ganancias');
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ganancias - Reportes - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
:root{--body-bg:#f0f3f8;--sidebar-bg:#fff;--sidebar-text:#1e293b;--sidebar-hover-bg:#e2e8f0;--sidebar-accent:#1e3c72;--sidebar-active-bg:linear-gradient(90deg,rgba(30,60,114,0.12),rgba(42,82,152,0.05));--sidebar-brand-bg:linear-gradient(135deg,#1e3c72,#2a5298);--topbar-bg:rgba(255,255,255,0.85);--panel-bg:#fff;--panel-header-bg:linear-gradient(135deg,#2a5298,#1e3c72);--profile-bg:#f1f5f9;--profile-text:#333;--scrollbar-thumb:rgba(0,0,0,0.12);--border-color:rgba(0,0,0,0.05);}
[data-theme="dark"]{--body-bg:#0f172a;--sidebar-bg:#1e293b;--sidebar-text:#cbd5e1;--sidebar-hover-bg:#334155;--sidebar-accent:#60a5fa;--sidebar-active-bg:linear-gradient(90deg,rgba(59,130,246,0.15),rgba(37,99,235,0.08));--sidebar-brand-bg:linear-gradient(135deg,#0f172a,#1e293b);--topbar-bg:rgba(30,41,59,0.95);--panel-bg:#1e293b;--panel-header-bg:linear-gradient(135deg,#0f172a,#1e293b);--profile-bg:#334155;--profile-text:#e2e8f0;--scrollbar-thumb:rgba(255,255,255,0.15);--border-color:rgba(255,255,255,0.06);}
.sidebar{display:flex;flex-direction:column;width:260px;height:100vh;position:fixed;background:var(--sidebar-bg);box-shadow:4px 0 20px rgba(0,0,0,0.03);z-index:1000;}
.sidebar-brand{flex-shrink:0;background:var(--sidebar-brand-bg);color:#fff;padding:20px;font-size:1.3rem;font-weight:700;text-align:center;}
.sidebar-menu a{display:flex;align-items:center;color:var(--sidebar-text);text-decoration:none;padding:12px 15px;font-size:0.95rem;border-radius:8px;margin-bottom:5px;transition:all 0.25s ease;border-left:3px solid transparent;}
.sidebar-menu a.active{background:var(--sidebar-active-bg);color:var(--sidebar-accent);font-weight:700;border-left:4px solid var(--sidebar-accent);}
.main-content{margin-left:260px;min-height:100vh;}
.topbar{background:var(--topbar-bg);backdrop-filter:blur(10px);padding:15px 30px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border-color);position:sticky;top:0;z-index:999;}
.panel-custom{border:none;border-radius:12px;background:var(--panel-bg);box-shadow:0 4px 15px rgba(0,0,0,0.02);margin-bottom:30px;}
.panel-custom-header{padding:20px;font-size:1.05rem;font-weight:600;color:#fff;border-top-left-radius:12px;border-top-right-radius:12px;background:var(--panel-header-bg);display:flex;justify-content:space-between;align-items:center;}
.panel-custom-body{padding:24px;}
.profile-avatar-wrap{flex-shrink:0;margin-right:10px;}
.kpi-card{border:none;border-radius:16px;min-height:160px;display:flex;flex-direction:column;justify-content:center;align-items:center;padding:25px 20px;color:#fff;box-shadow:0 8px 25px rgba(0,0,0,0.1);transition:transform 0.3s ease;}
.kpi-card:hover{transform:translateY(-5px);}
.kpi-icon{font-size:2.2rem;margin-bottom:10px;opacity:0.9;}
.kpi-label{font-size:0.9rem;font-weight:500;text-transform:uppercase;letter-spacing:0.5px;opacity:0.85;}
.kpi-value{font-size:2.2rem;font-weight:800;line-height:1.2;}
    </style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-graph-up-arrow me-2"></i> Reportes > Ganancias Netas</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="user-profile shadow-sm"><div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div><div class="profile-info"><div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div><div class="profile-role"><?php echo $_SESSION["rol"]; ?></div></div></div>
        </div>
    </div>
    <div class="container-fluid p-4">
        <form method="GET" class="row g-3 mb-4">
            <div class="col-auto">
                <label class="form-label fw-semibold">Mes</label>
                <input type="month" name="mes" class="form-control" value="<?php echo $filtro_mes; ?>">
            </div>
            <div class="col-auto d-flex align-items-end">
                <button type="submit" class="btn btn-primary" style="background:#1e3c72;border:none;"><i class="bi bi-search me-1"></i> Filtrar</button>
            </div>
            <div class="col-auto d-flex align-items-end gap-1">
                <a href="?exportar=xls&mes=<?php echo urlencode($filtro_mes); ?>" class="btn btn-success btn-sm"><i class="bi bi-file-earmark-excel"></i> Excel</a>
                <a href="?exportar=pdf&mes=<?php echo urlencode($filtro_mes); ?>" class="btn btn-danger btn-sm"><i class="bi bi-file-earmark-pdf"></i> PDF</a>
            </div>
        </form>
        <div class="row g-4 mb-4">
            <div class="col-md-4">
                <div class="kpi-card" style="background:linear-gradient(135deg,#4facfe,#00f2fe);">
                    <i class="bi bi-cash-stack kpi-icon"></i>
                    <div class="kpi-label">Ventas</div>
                    <div class="kpi-value">Bs. <?php echo number_format($total_ventas,2); ?></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="kpi-card" style="background:linear-gradient(135deg,#f093fb,#f5576c);">
                    <i class="bi bi-cart-dash kpi-icon"></i>
                    <div class="kpi-label">Compras</div>
                    <div class="kpi-value">Bs. <?php echo number_format($total_compras,2); ?></div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="kpi-card" style="background:linear-gradient(135deg,#43e97b,#38f9d7);<?php if($ganancia < 0): ?>background:linear-gradient(135deg,#f5576c,#f093fb);<?php endif; ?>">
                    <i class="bi bi-graph-up-arrow kpi-icon"></i>
                    <div class="kpi-label"><?php echo $ganancia >= 0 ? 'Ganancia Neta' : 'Pérdida'; ?></div>
                    <div class="kpi-value">Bs. <?php echo number_format(abs($ganancia),2); ?></div>
                </div>
            </div>
        </div>
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header"><i class="bi bi-table me-2"></i> Ganancias Mensuales</div>
            <div class="panel-custom-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <input type="text" id="buscador" class="form-control form-control-sm" placeholder="Buscar mes...">
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>Mes</th><th>Ventas</th><th>Compras</th><th>Ganancia Neta</th></tr>
                        </thead>
                        <tbody>
                            <?php if(mysqli_num_rows($mensual) > 0): while($m = mysqli_fetch_assoc($mensual)): ?>
                            <tr>
                                <td><strong><?php echo $m['mes']; ?></strong></td>
                                <td>Bs. <?php echo number_format($m['ventas'],2); ?></td>
                                <td>Bs. <?php echo number_format($m['compras'],2); ?></td>
                                <td><span class="text-<?php echo $m['ganancia'] >= 0 ? 'success' : 'danger'; ?> fw-bold">Bs. <?php echo number_format($m['ganancia'],2); ?></span></td>
                            </tr>
                            <?php endwhile; else: ?>
                            <tr><td colspan="4" class="text-center text-muted py-3">No hay datos disponibles.</td></tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
document.getElementById('buscador')?.addEventListener('keyup', function(){
    var q = this.value.toLowerCase();
    document.querySelectorAll('table tbody tr').forEach(function(row){
        row.style.display = row.textContent.toLowerCase().indexOf(q) > -1 ? '' : 'none';
    });
});
function inicializarRelojYFecha(){const a=new Date();document.getElementById('txt-reloj').textContent=String(a.getHours()).padStart(2,'0')+':'+String(a.getMinutes()).padStart(2,'0')+':'+String(a.getSeconds()).padStart(2,'0');const m=['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];document.getElementById('txt-fecha').textContent=String(a.getDate()).padStart(2,'0')+'/'+m[a.getMonth()]+'/'+a.getFullYear();}
inicializarRelojYFecha();setInterval(inicializarRelojYFecha,1000);
(function(){var t=document.createElement('div');t.className='widget-box';t.id='darkModeToggle';t.style.cssText='cursor:pointer;background:#f1f5f9;border-radius:20px;padding:6px 14px;';var s=localStorage.getItem('theme');t.innerHTML='<i class="bi '+(s==='dark'?'bi-moon-fill':s==='sepia'?'bi-brightness-alt-high-fill':'bi-sun-fill')+'"></i>';t.title='Modo oscuro';var w=document.querySelector('.topbar-widgets');if(w){var p=w.querySelector('.user-profile');w.insertBefore(t,p);t.addEventListener('click',function(){if(window.ciclarTema){window.ciclarTema();}var c=document.documentElement.getAttribute('data-theme')||'light';t.innerHTML='<i class="bi '+(c==='dark'?'bi-moon-fill':c==='sepia'?'bi-brightness-alt-high-fill':'bi-sun-fill')+'"></i>';});}if(window.aplicarTema){window.aplicarTema(localStorage.getItem('theme')||'light');}})();
</script>
</body>
</html>
