<?php
session_start();
include("../config/conexion.php");
if(!isset($_SESSION['id'])){ header("Location: ../login/login.php"); exit(); }

$top = mysqli_query($conexion, "SELECT c.id_cliente, c.nombre_cliente, c.ci_nit, c.telefono, COUNT(v.id_venta) AS total_compras, COALESCE(SUM(v.total),0) AS total_gastado FROM clientes c LEFT JOIN ventas v ON c.id_cliente = v.id_cliente WHERE c.activo=1 GROUP BY c.id_cliente HAVING total_compras > 0 ORDER BY total_gastado DESC LIMIT 20");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Clientes Frecuentes - Librería San Martín</title>
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
    </style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-trophy me-2"></i> Clientes Frecuentes</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="user-profile shadow-sm"><div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div><div class="profile-info"><div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div><div class="profile-role"><?php echo $_SESSION["rol"]; ?></div></div></div>
        </div>
    </div>
    <div class="container-fluid p-4">
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header"><i class="bi bi-trophy me-2"></i> Top 20 Clientes por Gasto</div>
            <div class="panel-custom-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>#</th><th>Cliente</th><th>NIT</th><th>Teléfono</th><th>Total Compras</th><th>Total Gastado</th></tr>
                        </thead>
                        <tbody>
                            <?php if(mysqli_num_rows($top) > 0): $n=1; while($c = mysqli_fetch_assoc($top)): ?>
                            <tr>
                                <td><span class="badge bg-<?php echo $n <= 3 ? 'warning' : 'secondary'; ?>"><?php echo $n++; ?></span></td>
                                <td><strong><?php echo htmlspecialchars($c['nombre_cliente']); ?></strong></td>
                                <td><?php echo htmlspecialchars($c['ci_nit']); ?></td>
                                <td><?php echo htmlspecialchars($c['telefono'] ?? '-'); ?></td>
                                <td><?php echo $c['total_compras']; ?> compras</td>
                                <td><strong>Bs. <?php echo number_format($c['total_gastado'],2); ?></strong></td>
                            </tr>
                            <?php endwhile; else: ?>
                            <tr><td colspan="6" class="text-center text-muted py-3">No hay clientes con compras registradas.</td></tr>
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
function inicializarRelojYFecha(){const a=new Date();document.getElementById('txt-reloj').textContent=String(a.getHours()).padStart(2,'0')+':'+String(a.getMinutes()).padStart(2,'0')+':'+String(a.getSeconds()).padStart(2,'0');const m=['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];document.getElementById('txt-fecha').textContent=String(a.getDate()).padStart(2,'0')+'/'+m[a.getMonth()]+'/'+a.getFullYear();}
inicializarRelojYFecha();setInterval(inicializarRelojYFecha,1000);
(function(){var t=document.createElement('div');t.className='widget-box';t.id='darkModeToggle';t.style.cssText='cursor:pointer;background:#f1f5f9;border-radius:20px;padding:6px 14px;';var s=localStorage.getItem('theme');t.innerHTML='<i class="bi '+(s==='dark'?'bi-moon-fill':s==='sepia'?'bi-brightness-alt-high-fill':'bi-sun-fill')+'"></i>';t.title='Modo oscuro';var w=document.querySelector('.topbar-widgets');if(w){var p=w.querySelector('.user-profile');w.insertBefore(t,p);t.addEventListener('click',function(){if(window.ciclarTema){window.ciclarTema();}var c=document.documentElement.getAttribute('data-theme')||'light';t.innerHTML='<i class="bi '+(c==='dark'?'bi-moon-fill':c==='sepia'?'bi-brightness-alt-high-fill':'bi-sun-fill')+'"></i>';});}if(window.aplicarTema){window.aplicarTema(localStorage.getItem('theme')||'light');}})();
</script>
</body>
</html>
