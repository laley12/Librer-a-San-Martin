<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id_venta = isset($_GET['venta_id']) ? intval($_GET['venta_id']) : 0;
if(!$id_venta){ echo "ID de venta inválido"; exit(); }

$venta = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT v.*, c.nombre_cliente, c.ci_nit FROM ventas v LEFT JOIN clientes c ON v.id_cliente = c.id_cliente WHERE v.id_venta = $id_venta"));
if(!$venta){ echo "Venta no encontrada"; exit(); }

$detalles = mysqli_query($conexion, "SELECT dv.*, p.nombre_producto, p.stock FROM detalle_ventas dv INNER JOIN productos p ON dv.producto_id = p.id_producto WHERE dv.venta_id = $id_venta");

$success = false;
$error = '';

if($_SERVER['REQUEST_METHOD'] === 'POST'){
    $motivo = mysqli_real_escape_string($conexion, $_POST['motivo'] ?? '');
    $items = $_POST['cantidad'] ?? [];
    $id_user = intval($_SESSION['id']);

    $total_devuelto = 0;
    $detalles_data = [];

    mysqli_data_seek($detalles, 0);
    while($d = mysqli_fetch_assoc($detalles)){
        $id_prod = $d['producto_id'];
        $dev = isset($items[$id_prod]) ? intval($items[$id_prod]) : 0;
        if($dev > 0){
            if($dev > $d['cantidad']){
                $error = "La cantidad a devolver de {$d['nombre_producto']} excede la cantidad vendida.";
                break;
            }
            $subtotal = $dev * $d['precio'];
            $total_devuelto += $subtotal;
            $detalles_data[] = [
                'id_producto' => $id_prod,
                'cantidad' => $dev,
                'precio' => $d['precio'],
                'subtotal' => $subtotal
            ];
        }
    }

    if(empty($error) && !empty($detalles_data)){
        mysqli_begin_transaction($conexion);
        try {
            mysqli_query($conexion, "INSERT INTO devoluciones (id_venta, id_usuario, fecha, motivo, total_devuelto) VALUES ($id_venta, $id_user, NOW(), '$motivo', $total_devuelto)");
            $id_devolucion = mysqli_insert_id($conexion);

            foreach($detalles_data as $dd){
                mysqli_query($conexion, "INSERT INTO detalle_devoluciones (id_devolucion, id_producto, cantidad, precio_unitario, subtotal) VALUES ($id_devolucion, {$dd['id_producto']}, {$dd['cantidad']}, {$dd['precio']}, {$dd['subtotal']})");
                mysqli_query($conexion, "UPDATE productos SET stock = stock + {$dd['cantidad']} WHERE id_producto = {$dd['id_producto']}");
            }

            mysqli_query($conexion, "INSERT INTO auditoria_ventas (id_usuario, accion) VALUES ($id_user, 'Devolución de venta #$id_venta - Bs. $total_devuelto')");

            mysqli_commit($conexion);
            $success = true;
        } catch(Exception $e){
            mysqli_rollback($conexion);
            $error = "Error al procesar la devolución: " . mysqli_error($conexion);
        }
    } elseif(empty($error)) {
        $error = "Debe seleccionar al menos un producto para devolver.";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Devolución Venta #<?php echo $id_venta; ?> - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
:root {
            --body-bg: #f0f3f8; --sidebar-bg: #ffffff; --sidebar-text: #1e293b;
            --sidebar-hover-bg: #e2e8f0; --sidebar-accent: #1e3c72;
            --sidebar-active-bg: linear-gradient(90deg, rgba(30,60,114,0.12), rgba(42,82,152,0.05));
            --sidebar-brand-bg: linear-gradient(135deg, #1e3c72, #2a5298);
            --topbar-bg: rgba(255,255,255,0.85); --panel-bg: #ffffff;
            --panel-header-bg: linear-gradient(135deg, #2a5298, #1e3c72);
            --profile-bg: #f1f5f9; --profile-text: #333;
            --border-color: rgba(0,0,0,0.05);
        }
[data-theme="dark"] {
            --body-bg: #0f172a; --sidebar-bg: #1e293b; --sidebar-text: #cbd5e1;
            --sidebar-hover-bg: #334155; --sidebar-accent: #60a5fa;
            --sidebar-active-bg: linear-gradient(90deg, rgba(59,130,246,0.15), rgba(37,99,235,0.08));
            --sidebar-brand-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --topbar-bg: rgba(30,41,59,0.95); --panel-bg: #1e293b;
            --panel-header-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --profile-bg: #334155; --profile-text: #e2e8f0;
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
    </style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-arrow-return-left me-2"></i> Devolución de Venta #<?php echo $id_venta; ?></div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
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
        <?php if($success): ?>
        <div class="alert alert-success alert-dismissible fade show">
            <i class="bi bi-check-circle-fill me-2"></i> Devolución registrada exitosamente.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <div class="mb-3">
            <a href="index.php" class="btn btn-primary" style="background:#1e3c72;border:none;"><i class="bi bi-arrow-left me-1"></i> Volver a Ventas</a>
            <a href="historial_devoluciones.php" class="btn btn-outline-secondary"><i class="bi bi-list me-1"></i> Ver Historial de Devoluciones</a>
        </div>
        <?php else: ?>
        <?php if($error): ?>
        <div class="alert alert-danger alert-dismissible fade show">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <?php echo $error; ?>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
        <?php endif; ?>

        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header">
                <i class="bi bi-receipt me-2"></i> Venta #<?php echo $id_venta; ?> - <?php echo htmlspecialchars($venta['nombre_cliente'] ?? 'Eventual'); ?>
                <span class="badge bg-light text-dark">Bs. <?php echo number_format($venta['total'], 2); ?></span>
            </div>
            <div class="panel-custom-body p-4">
                <div class="row mb-3">
                    <div class="col-md-4"><strong>Fecha:</strong> <?php echo $venta['fecha']; ?></div>
                    <div class="col-md-4"><strong>Cliente:</strong> <?php echo htmlspecialchars($venta['nombre_cliente'] ?? 'Eventual'); ?></div>
                    <div class="col-md-4"><strong>CI/NIT:</strong> <?php echo htmlspecialchars($venta['ci_nit'] ?? '-'); ?></div>
                </div>

                <form method="POST">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Producto</th>
                                    <th class="text-center">Vendido</th>
                                    <th class="text-center">P. Unit.</th>
                                    <th class="text-center">A devolver</th>
                                    <th class="text-end">Subtotal</th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php mysqli_data_seek($detalles, 0); $total_posible = 0; while($d = mysqli_fetch_assoc($detalles)): ?>
                                <tr>
                                    <td><?php echo htmlspecialchars($d['nombre_producto']); ?></td>
                                    <td class="text-center"><?php echo $d['cantidad']; ?></td>
                                    <td class="text-center">Bs. <?php echo number_format($d['precio'], 2); ?></td>
                                    <td class="text-center" style="width:120px;">
                                        <input type="number" name="cantidad[<?php echo $d['producto_id']; ?>]" class="form-control form-control-sm text-center qty-input" min="0" max="<?php echo $d['cantidad']; ?>" value="0" data-precio="<?php echo $d['precio']; ?>" onchange="calcTotal()">
                                    </td>
                                    <td class="text-end subtotal-cell">Bs. 0.00</td>
                                </tr>
                                <?php $total_posible += $d['cantidad'] * $d['precio']; endwhile; ?>
                            </tbody>
                            <tfoot>
                                <tr class="table-light fw-bold">
                                    <td colspan="4" class="text-end">TOTAL A DEVOLVER:</td>
                                    <td class="text-end text-danger" id="totalDevolver">Bs. 0.00</td>
                                </tr>
                            </tfoot>
                        </table>
                    </div>

                    <div class="row g-3 mb-3">
                        <div class="col-md-8">
                            <label class="form-label fw-bold">Motivo de la devolución</label>
                            <textarea name="motivo" class="form-control" rows="2" placeholder="Describa el motivo de la devolución..." required></textarea>
                        </div>
                    </div>

                    <div class="d-flex gap-2">
                        <button type="submit" class="btn btn-warning"><i class="bi bi-arrow-return-left me-1"></i> Procesar Devolución</button>
                        <a href="index.php" class="btn btn-outline-secondary"><i class="bi bi-x me-1"></i> Cancelar</a>
                    </div>
                </form>
            </div>
        </div>
        <?php endif; ?>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function calcTotal(){
    var total = 0;
    document.querySelectorAll('.qty-input').forEach(function(inp){
        var qty = parseInt(inp.value) || 0;
        var precio = parseFloat(inp.getAttribute('data-precio')) || 0;
        var subtotal = qty * precio;
        total += subtotal;
        var tr = inp.closest('tr');
        if(tr) tr.querySelector('.subtotal-cell').textContent = 'Bs. ' + subtotal.toFixed(2);
    });
    document.getElementById('totalDevolver').textContent = 'Bs. ' + total.toFixed(2);
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
    toggle.className = 'widget-box'; toggle.id = 'darkModeToggle';
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
</script>
</body>
</html>
