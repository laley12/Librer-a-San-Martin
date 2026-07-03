<?php
session_start();

include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

include("../includes/paginador.php");
include("../includes/exportar.php");

if(isset($_POST['actualizar_proveedor'])){
    $id_prov = $_POST['id_proveedor'];
    $nombre = $_POST['nombre'];
    $telefono = $_POST['telefono'];
    $direccion = $_POST['direccion'];

    $sql_update = "UPDATE proveedores SET 
                   nombre='$nombre', 
                   telefono='$telefono', 
                   direccion='$direccion' 
                   WHERE id_proveedor=$id_prov";
    
    mysqli_query($conexion, $sql_update);
    $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
        mysqli_query($conexion, "INSERT INTO auditoria_proveedores (id_usuario, accion) VALUES ($id_user, 'Modificó proveedor: $nombre (ID: $id_prov)')");
    header("Location: index.php");
    exit();
}

$sql_base = "SELECT COUNT(*) as total FROM proveedores WHERE activo=1";
$sql_data = "SELECT * FROM proveedores WHERE activo=1 ORDER BY nombre ASC";

if(isset($_GET['exportar'])){
    $datos = mysqli_query($conexion, $sql_data);
    $filas = [];
    while($row = mysqli_fetch_assoc($datos)) $filas[] = $row;
    if($_GET['exportar'] == 'xls') exportar_excel($filas, 'proveedores');
    if($_GET['exportar'] == 'pdf'){
        $html = '<h2>Directorio de Proveedores</h2><table><thead><tr><th>Nombre</th><th>Telefono</th><th>Direccion</th></tr></thead><tbody>';
        foreach($filas as $p) $html .= '<tr><td>'.htmlspecialchars($p['nombre']).'</td><td>'.htmlspecialchars($p['telefono']).'</td><td>'.htmlspecialchars($p['direccion']).'</td></tr>';
        $html .= '</tbody></table>';
        exportar_pdf($html, 'proveedores');
    }
}

$paginacion = paginar($conexion, $sql_base);
$proveedores = mysqli_query($conexion, $sql_data . $paginacion['sql_limite']);
?>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Gestión de Proveedores - Librería San Martín</title>
    
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

        .main-content { margin-left: 260px; min-height: 100vh; }
        .content-wrap { max-width: 1200px; margin: 0 auto; }
        .topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 999; }
        .topbar-title { font-size: 1.2rem; font-weight: 600; color: #1e3c72; }
        .topbar-widgets { display: flex; align-items: center; gap: 12px; }
        .widget-box { padding: 6px 14px; border-radius: 20px; font-size: 0.88rem; font-weight: 600; display: flex; align-items: center; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
        .widget-time { background: #e0f2fe; color: #0369a1; }
        .widget-date { background: #dcfce7; color: #15803d; }
        .user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: var(--profile-text); }
        .panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; animation: fadeInUp 0.5s ease-in-out; }
        .panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: var(--panel-header-bg); display: flex; justify-content: space-between; align-items: center; }
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
        <div class="topbar-title"><i class="bi bi-truck me-2"></i> Gestión de Proveedores</div>
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
                <i class="bi bi-person-lines-fill me-2"></i> <span class="menu-text"> Directorio Activo de Proveedores</span>
                <!-- Nuevo Proveedor está en el sidebar -->
            </div>
            <div class="panel-custom-body p-4">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                            <input type="text" id="buscador" class="form-control" placeholder="Buscar por nombre, teléfono o dirección..." onkeyup="filtrarTabla()">
                        </div>
                    </div>
                    <div class="col-md-6 text-end">
                        <a href="?exportar=xls" class="btn btn-success btn-sm me-1"><i class="bi bi-file-earmark-excel"></i> Excel</a>
                        <a href="?exportar=pdf" class="btn btn-danger btn-sm me-1"><i class="bi bi-file-earmark-pdf"></i> PDF</a>
                    </div>
                </div>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="table-light">
                                <th style="width: 70px;">N°</th>
                                <th>Razón Social / Nombre</th>
                                <th>Teléfono de Contacto</th>
                                <th>Dirección Fiscal</th>
                                <th class="text-center" style="width: 150px;">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $num = ($paginacion['pagina'] - 1) * $paginacion['limite'] + 1; 
                            while($fila = mysqli_fetch_assoc($proveedores)){
                            ?>
                            <tr>
                                <td><span class="badge bg-secondary-subtle text-secondary fw-bold"><?php echo $num++; ?></span></td>
                                <td><strong><?php echo $fila['nombre']; ?></strong></td>
                                <td><span class="text-dark"><i class="bi bi-telephone-fill text-muted me-2"></i><?php echo $fila['telefono']; ?></span></td>
                                <td><small class="text-muted"><i class="bi bi-geo-alt-fill text-muted me-1"></i><?php echo $fila['direccion']; ?></small></td>
                                <td class="text-center">
                                    <div class="btn-group" role="group">
                                        <button class="btn btn-warning btn-sm shadow-sm me-1 rounded" data-bs-title="Editar proveedor" data-bs-toggle="modal" data-bs-target="#modalEditarProveedor<?php echo $fila['id_proveedor']; ?>">
                                            <i class="bi bi-pencil-square"></i>
                                        </button>
                                        <a href="eliminar.php?id=<?php echo $fila['id_proveedor']; ?>" class="btn btn-danger btn-sm shadow-sm rounded" data-confirm="¿Está seguro de dar de baja a este proveedor?" data-bs-toggle="tooltip" data-bs-title="Eliminar proveedor">
                                            <i class="bi bi-trash3-fill"></i>
                                        </a>
                                    </div>
                                </td>
                            </tr>

                            <div class="modal fade" id="modalEditarProveedor<?php echo $fila['id_proveedor']; ?>" tabindex="-1" aria-hidden="true">
                              <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content" style="border: none; border-radius: 12px;">
                                  <div class="modal-header text-white" style="background: linear-gradient(135deg, #f39c12, #d35400); border-top-left-radius: 12px; border-top-right-radius: 12px;">
                                    <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i>Modificar Datos de Proveedor</h5>
                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                                  </div>
                                  <form method="POST">
                                    <input type="hidden" name="id_proveedor" value="<?php echo $fila['id_proveedor']; ?>">
                                    <div class="modal-body p-4">
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Nombre / Razón Social</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light"><i class="bi bi-building-fill"></i></span>
                                                <input type="text" name="nombre" class="form-control" value="<?php echo $fila['nombre']; ?>" required>
                                            </div>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Teléfono de Contacto</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light"><i class="bi bi-telephone-fill"></i></span>
                                                <input type="text" name="telefono" class="form-control" value="<?php echo $fila['telefono']; ?>" required>
                                            </div>
                                        </div>
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Dirección Establecida</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light"><i class="bi bi-geo-alt-fill"></i></span>
                                                <input type="text" name="direccion" class="form-control" value="<?php echo $fila['direccion']; ?>" required>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer bg-light" style="border-bottom-left-radius: 12px; border-bottom-right-radius: 12px;">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
                                        <button type="submit" name="actualizar_proveedor" class="btn btn-warning px-4 text-white fw-bold" style="border: none;">Guardar Cambios</button>
                                    </div>
                                  </form>
                                </div>
                              </div>
                            </div>
                            <?php } ?>
                        </tbody>
                    </table>
                </div>
                <?php echo mostrar_paginacion($paginacion['pagina'], $paginacion['total_paginas']); ?>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="modalNuevoProveedor" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered">
    <div class="modal-content" style="border: none; border-radius: 12px;">
      <div class="modal-header text-white" style="background: linear-gradient(135deg, #2a5298, #1e3c72); border-top-left-radius: 12px; border-top-right-radius: 12px;">
        <h5 class="modal-title"><i class="bi bi-person-plus-fill me-2"></i>Registrar Nuevo Proveedor</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <form action="guardar.php" method="POST">
        <div class="modal-body p-4">
            <div class="mb-3">
                <label class="form-label fw-bold">Nombre / Razón Social</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="bi bi-building-fill"></i></span>
                    <input type="text" name="nombre" class="form-control" placeholder="Ej. Distribuidora San Juan" required>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Teléfono</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="bi bi-telephone-fill"></i></span>
                    <input type="text" name="telefono" class="form-control" placeholder="Ej. 78451223" required>
                </div>
            </div>
            <div class="mb-3">
                <label class="form-label fw-bold">Dirección</label>
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="bi bi-geo-alt-fill"></i></span>
                    <input type="text" name="direccion" class="form-control" placeholder="Ej. Av. Intercomunal N° 45" required>
                </div>
            </div>
        </div>
        <div class="modal-footer bg-light" style="border-bottom-left-radius: 12px; border-bottom-right-radius: 12px;">
            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
            <button type="submit" class="btn btn-primary px-4" style="background: #1e3c72; border: none;">Guardar Proveedor</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filtrarTabla() {
        const input = document.getElementById('buscador').value.toLowerCase();
        const filas = document.querySelectorAll('.table tbody tr');
        filas.forEach(fila => {
            if (!fila.querySelector('td')) return;
            const texto = fila.textContent.toLowerCase();
            fila.style.display = texto.includes(input) ? '' : 'none';
        });
    }

    function updateClock() {
        const now = new Date();
        document.getElementById('live-clock').textContent = now.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false });
        const day = String(now.getDate()).padStart(2, '0');
        const months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
        document.getElementById('live-date').textContent = `${day} de ${months[now.getMonth()]} de ${now.getFullYear()}`;
    }
    setInterval(updateClock, 1000);
    updateClock();
    document.querySelectorAll('[data-bs-title]').forEach(el => new bootstrap.Tooltip(el));

    // Dark Mode Toggle
    (function() {
        const btn = document.createElement('button');
        btn.id = 'darkModeToggle';
        btn.className = 'btn btn-sm btn-outline-secondary rounded-circle ms-2';
        btn.style.cssText = 'width:36px;height:36px;display:flex;align-items:center;justify-content:center;border:1px solid #dee2e6;';
        btn.setAttribute('title', 'Modo oscuro');
        const saved = localStorage.getItem('theme');
        if (window.aplicarTema) { window.aplicarTema(saved || 'light'); }
        const icon = document.createElement('i');
        icon.className = saved === 'dark' ? 'bi bi-moon-fill' : saved === 'sepia' ? 'bi bi-brightness-alt-high-fill' : 'bi bi-sun-fill';
        btn.appendChild(icon);
        const topbar = document.querySelector('.topbar-widgets') || document.querySelector('.topbar');
        if (topbar) {
            const profile = topbar.querySelector('.user-profile');
            if (profile) profile.parentNode.insertBefore(btn, profile);
            else topbar.appendChild(btn);
        }
        btn.addEventListener('click', function() {
            if (window.ciclarTema) { window.ciclarTema(); }
            var cur = document.documentElement.getAttribute('data-theme') || 'light';
            this.querySelector('i').className = cur === 'dark' ? 'bi bi-moon-fill' : cur === 'sepia' ? 'bi bi-brightness-alt-high-fill' : 'bi bi-sun-fill';
        });
    })();

    // Keyboard Shortcuts
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

</script>
</body>
</html>
