<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$sql = "SELECT c.id_categoria, c.nombre_categoria, c.descripcion FROM categorias c LEFT JOIN productos p ON c.id_categoria = p.categoria_id AND p.activo=1 WHERE c.activo=1 GROUP BY c.id_categoria HAVING COUNT(p.id_producto) = 0 ORDER BY c.nombre_categoria";
$resultado = mysqli_query($conexion, $sql);
$datos = mysqli_fetch_all($resultado, MYSQLI_ASSOC);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Categor�as Vac�as - Librer�a San Mart�n</title>
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
        .sidebar-menu a:hover { background: var(--sidebar-hover-bg); color: var(--sidebar-accent); border-left-color: #1e3c72; }
        .sidebar-menu a.active { background: var(--sidebar-active-bg); color: var(--sidebar-accent); font-weight: 700; border-left: 4px solid var(--sidebar-accent); box-shadow: inset 0 0 0 1px rgba(30,60,114,0.06); }
        .collapse-submenu { position: relative; }
        .collapse-submenu::before { content: ''; position: absolute; left: 22px; top: 4px; bottom: 4px; width: 2px; background: var(--collapse-line); border-radius: 2px; }
        .collapse-submenu a { padding-left: 45px !important; font-size: 0.9rem !important; position: relative; border-left: none !important; }
        .collapse-submenu a::before { content: ''; position: absolute; left: 18px; top: 50%; transform: translateY(-50%); width: 18px; height: 2px; background: var(--collapse-line); border-radius: 1px; }
        .collapse-submenu a:hover { background: var(--sidebar-hover-bg); border-left: none !important; }
        .collapse-submenu a.sub-item-active { background: var(--sub-item-active-bg); font-weight: 600; color: #1e3c72; border-radius: 0 8px 8px 0; }
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
        .widget-weather { background: #fef3c7; color: #d97706; }
        .widget-date { background: #dcfce7; color: #15803d; }
        .user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: var(--profile-text); }
        .panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; animation: fadeInUp 0.5s ease-in-out; }
        .panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: var(--panel-header-bg); display: flex; justify-content: space-between; align-items: center; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
    
/* ==========================================================
   CORRECCI�N DEL AVATAR Y PERFIL EN EL TOPBAR
   ========================================================== */
.profile-avatar-wrap { flex-shrink: 0; margin-right: 10px; display: flex; align-items: center; }
.profile-avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
.profile-info { display: flex; flex-direction: column; line-height: 1.2; }
.profile-name { font-size: 0.88rem; white-space: nowrap; }
.profile-role { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; white-space: nowrap; }

/* ========================================================
   SUBMEN�S COMPACTOS ESTILO ERP (Ultra-compacto y premium)
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
        <div class="topbar-title"><i class="bi bi-folder-x me-2"></i> Categor�as Vac�as</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill me-2"></i> <span id="live-clock">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill me-2"></i> <span id="live-date">--/--/----</span></div>
            <div class="user-profile shadow-sm">
    <div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div>
    <div class="profile-info">
        <div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div>
        <div class="profile-role"><?php echo $_SESSION["rol"]; ?></div>
    </div>
</div>        </div>
    </div>

    <div class="container-fluid p-4 content-wrap">
        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header">
                <i class="bi bi-folder-x me-2"></i> <span class="menu-text"> Categor�as Vac�as</span>
            </div>
            <div class="panel-custom-body p-4">
                <?php if(count($datos) == 0){ ?>
                <div class="alert alert-success d-flex align-items-center py-3 px-4 mb-0" role="alert">
                    <i class="bi bi-check-circle-fill me-3 fs-3"></i>
                    <div>
                        <strong class="fs-6">�Todo en orden!</strong><br>
                        <span>Todas las categor�as tienen productos asignados.</span>
                    </div>
                </div>
                <?php } else { ?>
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="table-light border-bottom">
                                <th style="padding: 12px 8px;">N�</th>
                                <th style="padding: 12px 8px;">Categor�a</th>
                                <th style="padding: 12px 8px;">Descripci�n</th>
                                <th style="padding: 12px 8px;" class="text-center">Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php
                            $num = 1;
                            foreach($datos as $fila){
                            ?>
                            <tr>
                                <td><span class="badge bg-secondary-subtle text-secondary fw-bold"><?php echo $num++; ?></span></td>
                                <td><strong><?php echo $fila['nombre_categoria']; ?></strong></td>
                                <td><span class="text-muted"><?php echo $fila['descripcion']; ?></span></td>
                                <td class="text-center">
                                    <a href="../productos/index.php?categoria_id=<?php echo $fila['id_categoria']; ?>" class="btn btn-success btn-sm shadow-sm rounded-2 d-inline-flex align-items-center gap-1 px-3">
                                        <i class="bi bi-plus-circle-fill"></i> Agregar Productos
                                    </a>
                                </td>
                            </tr>
                            <?php } ?>
                        </tbody>
                    </table>
                </div>
                <?php } ?>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function updateClock() {
        const now = new Date();
        document.getElementById('live-clock').textContent = now.toLocaleTimeString('es-PE', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false });
        const day = String(now.getDate()).padStart(2, '0');
        const months = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
        document.getElementById('live-date').textContent = `${day} de ${months[now.getMonth()]} de ${now.getFullYear()}`;
    }
    setInterval(updateClock, 1000);
    updateClock();

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


