<?php
session_start();
include("../config/conexion.php");
if(!isset($_SESSION['id'])){ header("Location: ../login/login.php"); exit(); }

$mensaje = '';
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_producto = intval($_POST['id_producto']);
    $tipo = mysqli_real_escape_string($conexion, $_POST['tipo']);
    $cantidad = intval($_POST['cantidad']);
    $motivo = mysqli_real_escape_string($conexion, $_POST['motivo'] ?? 'Ajuste manual');

    if ($id_producto > 0 && $cantidad > 0 && in_array($tipo, ['entrada','salida'])) {
        $prod = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT * FROM productos WHERE id_producto = $id_producto AND activo=1"));
        if ($prod) {
            $nuevo_stock = $tipo === 'entrada' ? $prod['stock'] + $cantidad : $prod['stock'] - $cantidad;
            if ($nuevo_stock < 0) {
                $mensaje = '<div class="alert alert-danger">Error: Stock insuficiente (actual: ' . $prod['stock'] . ').</div>';
            } else {
                mysqli_query($conexion, "UPDATE productos SET stock = $nuevo_stock WHERE id_producto = $id_producto");
                mysqli_query($conexion, "INSERT INTO movimientos_inventario (id_producto, tipo, cantidad, id_usuario, fecha_hora, motivo) VALUES ($id_producto, '$tipo', $cantidad, {$_SESSION['id']}, NOW(), '$motivo')");
                $mensaje = '<div class="alert alert-success">Stock ajustado correctamente. Nuevo stock: ' . $nuevo_stock . '</div>';
            }
        } else {
            $mensaje = '<div class="alert alert-danger">Producto no encontrado.</div>';
        }
    } else {
        $mensaje = '<div class="alert alert-danger">Datos inválidos. Verifique producto, tipo y cantidad.</div>';
    }
}
$productos = mysqli_query($conexion, "SELECT p.*, c.nombre_categoria FROM productos p LEFT JOIN categorias c ON p.categoria_id = c.id_categoria WHERE p.activo=1 ORDER BY p.nombre_producto ASC");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Ajuste de Stock - Inventario - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>:root{--body-bg:#f0f3f8;--sidebar-bg:#fff;--sidebar-text:#1e293b;--sidebar-hover-bg:#e2e8f0;--sidebar-accent:#1e3c72;--sidebar-active-bg:linear-gradient(90deg,rgba(30,60,114,0.12),rgba(42,82,152,0.05));--sidebar-brand-bg:linear-gradient(135deg,#1e3c72,#2a5298);--topbar-bg:rgba(255,255,255,0.85);--panel-bg:#fff;--panel-header-bg:linear-gradient(135deg,#2a5298,#1e3c72);--profile-bg:#f1f5f9;--profile-text:#333;--scrollbar-thumb:rgba(0,0,0,0.12);--border-color:rgba(0,0,0,0.05);}[data-theme="dark"]{--body-bg:#0f172a;--sidebar-bg:#1e293b;--sidebar-text:#cbd5e1;--sidebar-hover-bg:#334155;--sidebar-accent:#60a5fa;--sidebar-active-bg:linear-gradient(90deg,rgba(59,130,246,0.15),rgba(37,99,235,0.08));--sidebar-brand-bg:linear-gradient(135deg,#0f172a,#1e293b);--topbar-bg:rgba(30,41,59,0.95);--panel-bg:#1e293b;--panel-header-bg:linear-gradient(135deg,#0f172a,#1e293b);--profile-bg:#334155;--profile-text:#e2e8f0;--scrollbar-thumb:rgba(255,255,255,0.15);--border-color:rgba(255,255,255,0.06);}
body{background:var(--body-bg);font-family:'Segoe UI',sans-serif;margin:0;overflow-x:hidden;}
.sidebar{display:flex;flex-direction:column;width:260px;height:100vh;position:fixed;background:var(--sidebar-bg);box-shadow:4px 0 20px rgba(0,0,0,0.03);z-index:1000;}
.sidebar-brand{flex-shrink:0;background:var(--sidebar-brand-bg);color:#fff;padding:20px;font-size:1.3rem;font-weight:700;text-align:center;}
.sidebar-menu{flex:1;overflow-y:auto;overflow-x:hidden;padding:15px 10px;}
.sidebar-menu a{display:flex;align-items:center;color:var(--sidebar-text);text-decoration:none;padding:12px 15px;font-size:0.95rem;border-radius:8px;margin-bottom:5px;transition:all 0.25s ease;border-left:3px solid transparent;}
.sidebar-menu a i{font-size:1.1rem;margin-right:12px;width:25px;text-align:center;}
.sidebar-menu a:hover{background:var(--sidebar-hover-bg);color:var(--sidebar-accent);border-left-color:var(--sidebar-accent);}
.sidebar-menu a.active{background:var(--sidebar-active-bg);color:var(--sidebar-accent);font-weight:700;border-left:4px solid var(--sidebar-accent);}
.main-content{margin-left:260px;min-height:100vh;}
.topbar{background:var(--topbar-bg);backdrop-filter:blur(10px);padding:15px 30px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border-color);position:sticky;top:0;z-index:999;}
.topbar-title{font-size:1.2rem;font-weight:600;color:var(--sidebar-accent);}
.topbar-widgets{display:flex;align-items:center;gap:12px;}
.widget-box{padding:6px 14px;border-radius:20px;font-size:0.88rem;font-weight:600;display:flex;align-items:center;box-shadow:0 2px 6px rgba(0,0,0,0.02);}
.widget-time{background:#e0f2fe;color:#0369a1;}.widget-date{background:#dcfce7;color:#15803d;}
.user-profile{display:flex;align-items:center;background:var(--profile-bg);padding:6px 14px;border-radius:20px;font-size:0.9rem;color:var(--profile-text);}
.panel-custom{border:none;border-radius:12px;background:var(--panel-bg);box-shadow:0 4px 15px rgba(0,0,0,0.02);margin-bottom:30px;}
.panel-custom-header{padding:20px;font-size:1.05rem;font-weight:600;color:#fff;border-top-left-radius:12px;border-top-right-radius:12px;background:var(--panel-header-bg);display:flex;justify-content:space-between;align-items:center;}
.panel-custom-body{padding:24px;}
.sidebar.collapsed ~ .main-content{margin-left:70px;}
.profile-avatar-wrap{flex-shrink:0;margin-right:10px;}
.profile-avatar{width:36px;height:36px;border-radius:50%;object-fit:cover;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.15);}
.profile-avatar-inicial{width:36px;height:36px;border-radius:50%;background:linear-gradient(135deg,#1e3c72,#2a5298);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:1rem;border:2px solid #fff;box-shadow:0 2px 6px rgba(0,0,0,0.15);}
</style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-sliders me-2"></i> Inventario > Ajuste de Stock</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="user-profile shadow-sm"><div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div><div class="profile-info"><div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div><div class="profile-role"><?php echo $_SESSION["rol"]; ?></div></div></div>
        </div>
    </div>
    <div class="container-fluid p-4">
        <?php if($mensaje) echo $mensaje; ?>
        <div class="row">
            <div class="col-md-5">
                <div class="panel-custom shadow-sm">
                    <div class="panel-custom-header"><i class="bi bi-sliders me-2"></i> Ajustar Stock</div>
                    <div class="panel-custom-body">
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Producto</label>
                                <select name="id_producto" class="form-select" required>
                                    <option value="">Seleccione un producto...</option>
                                    <?php while($p = mysqli_fetch_assoc($productos)): ?>
                                    <option value="<?php echo $p['id_producto']; ?>"><?php echo htmlspecialchars($p['nombre_producto']); ?> (Stock: <?php echo $p['stock']; ?>)</option>
                                    <?php endwhile; ?>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Tipo de Ajuste</label>
                                <div class="d-flex gap-3">
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="tipo" id="tipoEntrada" value="entrada" checked>
                                        <label class="form-check-label" for="tipoEntrada"><i class="bi bi-plus-circle text-success"></i> Entrada</label>
                                    </div>
                                    <div class="form-check">
                                        <input class="form-check-input" type="radio" name="tipo" id="tipoSalida" value="salida">
                                        <label class="form-check-label" for="tipoSalida"><i class="bi bi-dash-circle text-danger"></i> Salida</label>
                                    </div>
                                </div>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Cantidad</label>
                                <input type="number" name="cantidad" class="form-control" min="1" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-semibold">Motivo</label>
                                <textarea name="motivo" class="form-control" rows="2" placeholder="Ej: Conteo físico, producto dañado, etc."></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary w-100" style="background:#1e3c72;border:none;"><i class="bi bi-check-lg me-1"></i> Aplicar Ajuste</button>
                        </form>
                    </div>
                </div>
            </div>
            <div class="col-md-7">
                <div class="panel-custom shadow-sm">
                    <div class="panel-custom-header"><i class="bi bi-box-seam me-2"></i> Productos en Inventario</div>
                    <div class="panel-custom-body">
                        <div class="table-responsive" style="max-height:400px;overflow-y:auto;">
                            <table class="table table-hover table-sm align-middle mb-0">
                                <thead class="table-light sticky-top">
                                    <tr><th>Producto</th><th>Categoría</th><th>Stock</th><th>Precio</th></tr>
                                </thead>
                                <tbody>
                                    <?php mysqli_data_seek($productos, 0); while($p = mysqli_fetch_assoc($productos)): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($p['nombre_producto']); ?></td>
                                        <td><?php echo htmlspecialchars($p['nombre_categoria'] ?? '-'); ?></td>
                                        <td><span class="badge bg-<?php echo $p['stock'] <= 5 ? 'danger' : 'success'; ?>"><?php echo $p['stock']; ?></span></td>
                                        <td>Bs. <?php echo number_format($p['precio'],2); ?></td>
                                    </tr>
                                    <?php endwhile; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
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
