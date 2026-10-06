<?php
session_start();
include("../config/conexion.php");
if(!isset($_SESSION['id'])){ header("Location: ../login/login.php"); exit(); }

$busqueda = trim($_GET['busqueda'] ?? '');
$pedidos = null;
if ($busqueda !== '') {
    $b = mysqli_real_escape_string($conexion, $busqueda);
    $pedidos = mysqli_query($conexion, "SELECT p.*, s.nombre AS sucursal FROM pedidos p LEFT JOIN sucursales s ON p.sucursal_id = s.id_sucursal WHERE p.cliente_nombre LIKE '%$b%' OR p.cliente_telefono LIKE '%$b%' OR p.codigo_seguimiento LIKE '%$b%' ORDER BY p.fecha DESC");
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Historial de Pedidos por Cliente - Librería San Martín</title>
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
        <div class="topbar-title"><i class="bi bi-person me-2"></i> Historial de Pedidos por Cliente</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="user-profile shadow-sm"><div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div><div class="profile-info"><div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div><div class="profile-role"><?php echo $_SESSION["rol"]; ?></div></div></div>
        </div>
    </div>
    <div class="container-fluid p-4">
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header"><i class="bi bi-search me-2"></i> Buscar Pedidos por Cliente</div>
            <div class="panel-custom-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-6">
                        <input type="text" name="busqueda" class="form-control" placeholder="Buscar por nombre, teléfono o código de seguimiento..." value="<?php echo htmlspecialchars($busqueda); ?>" required>
                    </div>
                    <div class="col-md-3 d-flex align-items-end">
                        <button type="submit" class="btn btn-primary" style="background:#1e3c72;border:none;"><i class="bi bi-search me-1"></i> Buscar</button>
                    </div>
                </form>
            </div>
        </div>
        <?php if($busqueda !== ''): ?>
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header"><i class="bi bi-cart-check me-2"></i> Resultados para "<?php echo htmlspecialchars($busqueda); ?>"</div>
            <div class="panel-custom-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead class="table-light">
                            <tr><th>N°</th><th>Código</th><th>Cliente</th><th>Teléfono</th><th>Fecha</th><th>Total</th><th>Estado</th><th>Acción</th></tr>
                        </thead>
                        <tbody>
                            <?php if($pedidos && mysqli_num_rows($pedidos) > 0): $n=1; while($p = mysqli_fetch_assoc($pedidos)): ?>
                            <tr>
                                <td><?php echo $n++; ?></td>
                                <td><span class="badge bg-secondary"><?php echo htmlspecialchars($p['codigo_seguimiento']); ?></span></td>
                                <td><?php echo htmlspecialchars($p['cliente_nombre']); ?></td>
                                <td><?php echo htmlspecialchars($p['cliente_telefono']); ?></td>
                                <td><?php echo $p['fecha']; ?></td>
                                <td><strong>Bs. <?php echo number_format($p['total'],2); ?></strong></td>
                                <td><span class="badge bg-<?php echo match($p['estado']){'Pendiente'=>'warning','Preparando'=>'info','Listo'=>'primary','Entregado'=>'success','Cancelado'=>'danger',default=>'secondary'}; ?>"><?php echo $p['estado']; ?></span></td>
                                <td><a href="detalle.php?id=<?php echo $p['id_pedido']; ?>" class="btn btn-sm btn-outline-primary"><i class="bi bi-eye"></i></a></td>
                            </tr>
                            <?php endwhile; else: ?>
                            <tr><td colspan="8" class="text-center text-muted py-3">No se encontraron pedidos para esa búsqueda.</td></tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <?php endif; ?>
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
