<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$compras = mysqli_query($conexion, "SELECT c.*, p.nombre FROM compras c INNER JOIN proveedores p ON c.proveedor_id = p.id_proveedor ORDER BY c.id_compra DESC");
$lista_proveedores = mysqli_query($conexion, "SELECT id_proveedor, nombre FROM proveedores WHERE activo=1 ORDER BY nombre ASC");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Pago a Proveedores - Librería San Martín</title>
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
body { background: var(--body-bg); font-family: 'Segoe UI', sans-serif; margin: 0; overflow-x: hidden; }
.sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: #ffffff; box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; }
.sidebar-brand { flex-shrink: 0; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; }
.sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
.sidebar-menu::-webkit-scrollbar { width: 4px; }
.sidebar-menu::-webkit-scrollbar-track { background: transparent; }
.sidebar-menu::-webkit-scrollbar-thumb { background: rgba(0,0,0,0.12); border-radius: 10px; }
.sidebar-menu::-webkit-scrollbar-thumb:hover { background: rgba(0,0,0,0.25); }
.sidebar-menu a { display: flex; align-items: center; color: #1e293b; text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; cursor: pointer; border-left: 3px solid transparent; }
.sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
.sidebar-menu a:hover { background: #e2e8f0; color: #1e3c72; border-left-color: #1e3c72; }
.sidebar-menu a.active { background: linear-gradient(90deg, rgba(30,60,114,0.12), rgba(42,82,152,0.05)); color: #1e3c72; font-weight: 700; border-left: 4px solid #1e3c72; box-shadow: inset 0 0 0 1px rgba(30,60,114,0.06); }
.collapse-submenu { position: relative; }
.collapse-submenu::before { content: ''; position: absolute; left: 22px; top: 4px; bottom: 4px; width: 2px; background: #cbd5e1; border-radius: 2px; }
.collapse-submenu a { padding-left: 45px !important; font-size: 0.9rem !important; position: relative; border-left: none !important; }
.collapse-submenu a::before { content: ''; position: absolute; left: 18px; top: 50%; transform: translateY(-50%); width: 18px; height: 2px; background: #cbd5e1; border-radius: 1px; }
.collapse-submenu a:hover { background: #e2e8f0; border-left: none !important; }
.collapse-submenu a.sub-item-active { background: #eef2ff; font-weight: 600; color: #1e3c72; border-radius: 0 8px 8px 0; }
.collapse-submenu-2 { position: relative; }
.collapse-submenu-2::before { content: ''; position: absolute; left: 35px; top: 4px; bottom: 4px; width: 2px; background: repeating-linear-gradient(to bottom, #94a3b8 0px, #94a3b8 4px, transparent 4px, transparent 8px); }
.collapse-submenu-2 a { padding-left: 62px !important; font-size: 0.88rem !important; position: relative; }
.collapse-submenu-2 a::before { content: ''; position: absolute; left: 35px; top: 50%; transform: translateY(-50%); width: 20px; height: 0; border-top: 2px dashed #94a3b8; }
.collapse-submenu-2 a:hover { background: #e2e8f0; }
.sub-item-active { color: #1e3c72 !important; font-weight: 600; background-color: #f8fafc !important; border-left: 3px solid #2a5298; border-radius: 0 8px 8px 0; }
.collapse-toggle { display: flex; justify-content: space-between; align-items: center; }
.collapse-toggle .chevron-icon { font-size: 0.8rem; transition: transform 0.2s ease; }
.collapse-toggle[aria-expanded="true"] .chevron-icon { transform: rotate(180deg); }
.main-content { margin-left: 260px; min-height: 100vh; }
.content-wrap { max-width: 1200px; margin: 0 auto; }
.topbar { background: rgba(255, 255, 255, 0.85); backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(0,0,0,0.05); position: sticky; top: 0; z-index: 999; }
.topbar-title { font-size: 1.2rem; font-weight: 600; color: #1e3c72; }
.topbar-widgets { display: flex; align-items: center; gap: 12px; }
.widget-box { padding: 6px 14px; border-radius: 20px; font-size: 0.88rem; font-weight: 600; display: flex; align-items: center; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
.widget-time { background: #e0f2fe; color: #0369a1; }
.widget-date { background: #dcfce7; color: #15803d; }
.user-profile { display: flex; align-items: center; background: #f1f5f9; padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: #333; }
.panel-custom { border: none; border-radius: 12px; background: #ffffff; box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 25px; animation: fadeInUp 0.5s ease-in-out; }
.panel-custom-header { padding: 18px 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: linear-gradient(135deg, #2a5298, #1e3c72); display: flex; justify-content: space-between; align-items: center; }
.barra-herramientas { background-color: #2ecc71; border-radius: 8px; padding: 15px; color: white; font-weight: 500; }
.barra-herramientas label { font-size: 0.85rem; font-weight: 700; text-transform: uppercase; margin-bottom: 4px; }
@keyframes fadeInUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
/* ==========================================================
   CORRECCIÓN DEL AVATAR Y PERFIL EN EL TOPBAR
   ========================================================== */
.profile-avatar-wrap { flex-shrink: 0; margin-right: 10px; display: flex; align-items: center; }
.profile-avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-info { display: flex; flex-direction: column; line-height: 1.2; }
.profile-name { font-size: 0.88rem; white-space: nowrap; }
.profile-role { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; white-space: nowrap; }
/* ========================================================
   SUBMENÚS COMPACTOS ESTILO ERP (Ultra-compacto y premium)
   ======================================================== */
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
/* ========================================================
   SIDEBAR TOGGLE (HAMBURGER MENU)
   ======================================================== */
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
    </style>
</head>
<body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-cash-coin me-2"></i> Pago a Proveedores</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill me-2"></i> <span id="live-clock">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill me-2"></i> <span id="live-date">--/--/----</span></div>
            <div class="widget-box widget-weather"><i class="bi bi-sun-fill me-2"></i> <span>17°C</span></div>
            <div class="user-profile shadow-sm">
    <div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div>
    <div class="profile-info">
        <div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div>
        <div class="profile-role"><?php echo $_SESSION["rol"]; ?></div>
    </div>
</div>        </div>
    </div>

    <div class="container-fluid p-4">
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header">
                <h5 class="m-0 fw-bold text-white"><i class="bi bi-cart-plus-fill me-2"></i>Registrar Transacción de Compra</h5>
            </div>
            <div class="panel-custom-body p-4">
                <form action="../compras/guardar.php" method="POST">
                    <div class="barra-herramientas mb-3">
                        <div class="row g-3 align-items-end">
                            <div class="col-md-3">
                                <label class="form-label">Recibo / Factura:</label>
                                <input type="text" name="nro_recibo" class="form-control form-control-sm" placeholder="Nro Recibo">
                            </div>
                            <div class="col-md-3">
                                <label class="form-label">Seleccionar Proveedor:</label>
                                <select name="proveedor_id" class="form-select form-select-sm" required>
                                    <option value="" disabled selected>Seleccionar...</option>
                                    <?php 
                                    mysqli_data_seek($lista_proveedores, 0); 
                                    while($prov = mysqli_fetch_assoc($lista_proveedores)): 
                                    ?>
                                        <option value="<?php echo $prov['id_proveedor']; ?>"><?php echo $prov['nombre']; ?></option>
                                    <?php endwhile; ?>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Fecha Registro:</label>
                                <input type="date" name="fecha" class="form-control form-control-sm" value="<?php echo date('Y-m-d'); ?>" required>
                            </div>
                            <div class="col-md-2">
                                <label class="form-label">Monto Total (Bs.):</label>
                                <input type="number" step="0.01" name="total" class="form-control form-control-sm" placeholder="0.00" required>
                            </div>
                            <div class="col-md-2 text-end">
                                <button type="submit" name="guardar" class="btn btn-primary btn-sm w-100 fw-bold shadow-sm">
                                    <i class="bi bi-check2-circle me-1"></i> PROCESAR COMPRA
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header">
                <i class="bi bi-receipt-cutoff me-2"></i> <span class="menu-text"> Historial y Registro General de Compras</span>
            </div>
            <div class="panel-custom-body p-4">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="table-light">
                                <th>ID Transacción</th>
                                <th>Proveedor</th>
                                <th>Fecha de Asiento</th>
                                <th class="text-end">Monto Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while($fila=mysqli_fetch_assoc($compras)){ ?>
                            <tr>
                                <td><span class="badge bg-secondary fw-bold"># <?php echo $fila['id_compra']; ?></span></td>
                                <td><strong><?php echo $fila['nombre']; ?></strong></td>
                                <td><span class="text-muted"><?php echo $fila['fecha']; ?></span></td>
                                <td class="text-end"><span class="badge bg-success fs-6">Bs. <?php echo number_format($fila['total'], 2); ?></span></td>
                            </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="/includes/base.js"></script>
</body>
</html>

