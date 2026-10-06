<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION["id"])){
    header("Location: ../login/login.php");
    exit();
}

$auditoria = mysqli_query($conexion, "SELECT a.*, u.nombre AS usuario FROM auditoria_ventas a LEFT JOIN usuarios u ON a.id_usuario = u.id ORDER BY a.fecha_hora DESC");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Auditoría de Ventas - Librería San Martín</title>
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
body { background: var(--body-bg); font-family: "Segoe UI", sans-serif; margin: 0; overflow-x: hidden; }
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
.collapse-submenu::before { content: ""; position: absolute; left: 22px; top: 4px; bottom: 4px; width: 2px; background: var(--collapse-line); border-radius: 2px; }
.collapse-submenu a { padding-left: 45px !important; font-size: 0.9rem !important; position: relative; border-left: none !important; }
.collapse-submenu a::before { content: ""; position: absolute; left: 18px; top: 50%; transform: translateY(-50%); width: 18px; height: 2px; background: var(--collapse-line); border-radius: 1px; }
.collapse-submenu a:hover { background: var(--sidebar-hover-bg); border-left: none !important; }
.collapse-submenu a.sub-item-active { background: var(--sub-item-active-bg); font-weight: 600; color: var(--sidebar-accent); border-radius: 0 8px 8px 0; }
.collapse-submenu-2 { position: relative; }
.collapse-submenu-2::before { content: ""; position: absolute; left: 35px; top: 4px; bottom: 4px; width: 2px; background: repeating-linear-gradient(to bottom, #94a3b8 0px, #94a3b8 4px, transparent 4px, transparent 8px); }
.collapse-submenu-2 a { padding-left: 62px !important; font-size: 0.88rem !important; position: relative; }
.collapse-submenu-2 a::before { content: ""; position: absolute; left: 35px; top: 50%; transform: translateY(-50%); width: 20px; height: 0; border-top: 2px dashed var(--collapse-dash); }
.collapse-submenu-2 a:hover { background: var(--sidebar-hover-bg); }
.sub-item-active { color: var(--sidebar-accent) !important; font-weight: 600; background-color: #f8fafc !important; border-left: 3px solid #2a5298; border-radius: 0 8px 8px 0; }
.collapse-toggle { display: flex; justify-content: space-between; align-items: center; }
.collapse-toggle .chevron-icon { font-size: 0.8rem; transition: transform 0.2s ease; }
.collapse-toggle[aria-expanded="true"] .chevron-icon { transform: rotate(180deg); }
.main-content { margin-left: 260px; min-height: 100vh; }
.topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 999; }
.topbar-title { font-size: 1.2rem; font-weight: 600; color: var(--sidebar-accent); }
.topbar-widgets { display: flex; align-items: center; gap: 12px; }
.widget-box { padding: 6px 14px; border-radius: 20px; font-size: 0.88rem; font-weight: 600; display: flex; align-items: center; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
.widget-time { background: #e0f2fe; color: #0369a1; }
.widget-date { background: #dcfce7; color: #15803d; }
.user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: var(--profile-text); }
.panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; animation: fadeInUp 0.5s ease-in-out; }
.panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: var(--panel-header-bg); display: flex; justify-content: space-between; align-items: center; }
@keyframes fadeInUp { from { opacity: 0; transform: translateY(15px); } to { opacity: 1; transform: translateY(0); } }
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
    </style>
</head>
<body>

<?php $base_path = "../"; include "../includes/sidebar.php"; ?>

<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-shield-check me-2"></i> Auditoría de Ventas</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
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
                <i class="bi bi-journal-text me-2"></i> <span class="menu-text"> Registro de Auditoría - Ventas</span>
                <span class="badge bg-light text-dark"><?php echo mysqli_num_rows($auditoria); ?> eventos</span>
            </div>
            <div class="panel-custom-body p-4">
                <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                        <thead>
                            <tr class="table-light">
                                <th>#</th>
                                <th>Usuario</th>
                                <th>Acción</th>
                                <th>Fecha y Hora</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if(mysqli_num_rows($auditoria) > 0): ?>
                                <?php while($a = mysqli_fetch_assoc($auditoria)){ ?>
                                <tr>
                                    <td><span class="badge bg-secondary"><?php echo $a["id_auditoria"] ?? $a["id"] ?? "-"; ?></span></td>
                                    <td><strong><?php echo htmlspecialchars($a["usuario"] ?? "Sistema"); ?></strong></td>
                                    <td><?php echo htmlspecialchars($a["accion"]); ?></td>
                                    <td><span class="text-muted"><?php echo $a["fecha_hora"]; ?></span></td>
                                </tr>
                                <?php } ?>
                            <?php else: ?>
                                <tr><td colspan="4" class="text-center text-muted py-3">No hay eventos de auditoría registrados.</td></tr>
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
    function inicializarRelojYFecha() {
        const ahora = new Date();
        document.getElementById("txt-reloj").textContent = String(ahora.getHours()).padStart(2,"0")+":"+String(ahora.getMinutes()).padStart(2,"0")+":"+String(ahora.getSeconds()).padStart(2,"0");
        const meses = ["Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"];
        document.getElementById("txt-fecha").textContent = String(ahora.getDate()).padStart(2,"0")+"/"+meses[ahora.getMonth()]+"/"+ahora.getFullYear();
    }
    inicializarRelojYFecha();
    setInterval(inicializarRelojYFecha, 1000);
    (function(){
        var toggle = document.createElement("div");
        toggle.className = "widget-box";
        toggle.id = "darkModeToggle";
        toggle.style.cssText = "cursor:pointer;background:#f1f5f9;border-radius:20px;padding:6px 14px;";
        toggle.innerHTML = "<i class=\"bi " + (localStorage.getItem("theme") === "dark" ? "bi-sun-fill" : "bi-moon-fill") + "\"></i>";
        toggle.title = "Modo oscuro";
        var widgets = document.querySelector(".topbar-widgets");
        if(widgets) {
            var profile = widgets.querySelector(".user-profile");
            widgets.insertBefore(toggle, profile);
            toggle.addEventListener("click", function(){
                var html = document.documentElement;
                var isDark = html.getAttribute("data-theme") === "dark";
                html.setAttribute("data-theme", isDark ? "" : "dark");
                localStorage.setItem("theme", isDark ? "" : "dark");
                toggle.innerHTML = "<i class=\"bi " + (isDark ? "bi-moon-fill" : "bi-sun-fill") + "\"></i>";
            });
        }
        if(localStorage.getItem("theme") === "dark") document.documentElement.setAttribute("data-theme", "dark");
    })();
    document.addEventListener("keydown", function(e){
        if(e.ctrlKey && e.key === "n"){ e.preventDefault();
            var nl = document.querySelector("a[href*=\"nuevo.php\"]");
            if(nl) window.location.href = nl.getAttribute("href"); }
        if(e.ctrlKey && e.key === "f"){ e.preventDefault();
            var b = document.getElementById("buscador");
            if(b) b.focus(); }
        if(e.ctrlKey && e.key === "s"){ e.preventDefault();
            var f = document.querySelector("form");
            if(f) f.submit(); }
    });
</script>
</body>
</html>
