<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$filtro = isset($_GET['estado']) && $_GET['estado'] ? mysqli_real_escape_string($conexion, $_GET['estado']) : '';
$sql = "SELECT p.*, s.nombre AS sucursal_nombre FROM pedidos p LEFT JOIN sucursales s ON p.sucursal_id = s.id_sucursal";
if ($filtro) $sql .= " WHERE p.estado = '$filtro'";
$sql .= " ORDER BY p.fecha DESC";
$pedidos = mysqli_query($conexion, $sql);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Pedidos Web - Librería San Martín</title>
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
            --scrollbar-thumb: rgba(0,0,0,0.12);
            --scrollbar-thumb-hover: rgba(0,0,0,0.25);
            --collapse-line: #cbd5e1;
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
            --scrollbar-thumb: rgba(255,255,255,0.15);
            --scrollbar-thumb-hover: rgba(255,255,255,0.25);
            --collapse-line: #475569;
            --border-color: rgba(255,255,255,0.06);
        }
        body { background: var(--body-bg); font-family: 'Segoe UI', sans-serif; margin: 0; overflow-x: hidden; }
        .sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; }
        .sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; }
        .sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
        .sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; cursor: pointer; border-left: 3px solid transparent; }
        .sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
        .sidebar-menu a:hover { background: var(--sidebar-hover-bg); color: var(--sidebar-accent); border-left-color: var(--sidebar-accent); }
        .sidebar-menu a.active { background: var(--sidebar-active-bg); color: var(--sidebar-accent); font-weight: 700; border-left: 4px solid var(--sidebar-accent); }
        .main-content { margin-left: 260px; min-height: 100vh; }
        .topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 999; }
        .topbar-title { font-size: 1.2rem; font-weight: 600; color: #1e3c72; }
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
        .panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; animation: fadeInUp 0.5s ease-in-out; }
        .panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: var(--panel-header-bg); display: flex; justify-content: space-between; align-items: center; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
        .sidebar { transition: all 0.3s ease; }
        .main-content { transition: all 0.3s ease; }
        .sidebar.collapsed { width: 70px; }
        .sidebar.collapsed .sidebar-brand span.brand-text { display: none; }
        .sidebar.collapsed .sidebar-brand { font-size: 1.1rem; padding: 20px 0; text-align: center; }
        .sidebar.collapsed .sidebar-menu { padding: 15px 5px; }
        .sidebar.collapsed .sidebar-menu a { padding: 12px 10px; justify-content: center; margin-bottom: 8px; }
        .sidebar.collapsed .sidebar-menu a i.bi { margin-right: 0 !important; font-size: 1.3rem; }
        .sidebar.collapsed .sidebar-menu a span.menu-text { display: none; }
        .sidebar.collapsed .collapse-toggle .chevron-icon { display: none; }
        .sidebar.collapsed .collapse-submenu, .sidebar.collapsed .collapse-submenu-2 { display: none !important; }
        .sidebar.collapsed ~ .main-content { margin-left: 70px; }
        .status-badge { font-size: 0.8rem; padding: 4px 12px; border-radius: 20px; font-weight: 600; }
    </style>
</head>
<body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-cart-check-fill me-2"></i> Lista de Pedidos Web</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill me-2"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill me-2"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="widget-box widget-weather"><i class="bi bi-sun-fill me-2"></i> <span>17°C</span></div>
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
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header">
                <i class="bi bi-cart-check me-2"></i> Pedidos Recibidos
            </div>
            <div class="panel-custom-body p-4">
                <div class="row mb-3">
                    <div class="col-md-4">
                        <select class="form-select" onchange="window.location='?estado='+this.value">
                            <option value="">Todos los estados</option>
                            <?php
                            $estados = ['Pendiente','Preparando','Listo','Entregado','Cancelado'];
                            foreach($estados as $e) {
                                $sel = ($filtro == $e) ? 'selected' : '';
                                echo "<option value=\"$e\" $sel>$e</option>";
                            }
                            ?>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <input type="text" id="buscador" class="form-control" placeholder="Buscar por cliente o código..." onkeyup="filtrarTabla()">
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="table-light">
                                <th>N°</th>
                                <th>Código</th>
                                <th>Cliente</th>
                                <th>Teléfono</th>
                                <th>Total</th>
                                <th>Estado</th>
                                <th>Fecha</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php $num = 1; while($p = mysqli_fetch_assoc($pedidos)):
                            $badge = match($p['estado']) {
                                'Pendiente' => 'warning',
                                'Preparando' => 'info',
                                'Listo' => 'success',
                                'Entregado' => 'secondary',
                                'Cancelado' => 'danger',
                                default => 'secondary'
                            };
                            ?>
                            <tr>
                                <td><span class="badge bg-secondary"><?php echo $num++; ?></span></td>
                                <td><strong><?php echo htmlspecialchars($p['codigo_seguimiento']); ?></strong></td>
                                <td><?php echo htmlspecialchars($p['cliente_nombre']); ?></td>
                                <td><?php echo htmlspecialchars($p['cliente_telefono']); ?></td>
                                <td><strong>Bs. <?php echo number_format($p['total'], 2); ?></strong></td>
                                <td><span class="badge bg-<?php echo $badge; ?> status-badge"><?php echo $p['estado']; ?></span></td>
                                <td><?php echo $p['fecha']; ?></td>
                                <td>
                                    <a href="detalle.php?id=<?php echo $p['id_pedido']; ?>" class="btn btn-sm btn-outline-primary">
                                        <i class="bi bi-eye"></i> Ver Detalle
                                    </a>
                                </td>
                            </tr>
                            <?php endwhile; if(mysqli_num_rows($pedidos)==0): ?>
                            <tr><td colspan="8" class="text-center text-muted py-4">No hay pedidos</td></tr>
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
function filtrarTabla() {
    var input = document.getElementById('buscador').value.toLowerCase();
    var filas = document.querySelectorAll('.table tbody tr');
    filas.forEach(function(fila) {
        if (!fila.querySelector('td')) return;
        var texto = fila.textContent.toLowerCase();
        fila.style.display = texto.includes(input) ? '' : 'none';
    });
}

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
    if(e.ctrlKey && e.key === 's'){ e.preventDefault(); var form = document.querySelector('form'); if(form) form.submit(); }
});
</script>
</body>
</html>
