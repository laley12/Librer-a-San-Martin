<?php
session_start();
include("config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: login/login.php");
    exit();
}

$id_usuario = $_SESSION['id'];
$usuario = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT nombre, forzar_cambio FROM usuarios WHERE id = $id_usuario"));
if($usuario && $usuario['forzar_cambio'] == 0){
    header("Location: dashboard/index.php");
    exit();
}

$mensaje = "";
if(isset($_POST['cambiar_clave'])){
    $nueva = mysqli_real_escape_string($conexion, $_POST['nueva_clave']);
    $confirmar = mysqli_real_escape_string($conexion, $_POST['confirmar_clave']);
    if(strlen($nueva) < 4){
        $mensaje = '<div class="alert alert-danger">La contraseña debe tener al menos 4 caracteres.</div>';
    } elseif($nueva !== $confirmar){
        $mensaje = '<div class="alert alert-danger">Las contraseñas no coinciden.</div>';
    } else {
        $hash = password_hash($nueva, PASSWORD_DEFAULT);
        mysqli_query($conexion, "UPDATE usuarios SET password = '$hash', forzar_cambio = 0 WHERE id = $id_usuario");
        $mensaje = '<div class="alert alert-success">Contraseña cambiada exitosamente. Redirigiendo...</div>';
        echo "<script>setTimeout(function(){ window.location.href = 'dashboard/index.php'; }, 1500);</script>";
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Cambio Obligatorio de Contraseña - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --body-bg: linear-gradient(135deg, #1e3c72, #2a5298);
            --topbar-bg: rgba(255,255,255,0.9);
            --profile-bg: #f1f5f9;
            --profile-text: #333;
            --border-color: rgba(0,0,0,0.05);
            --card-bg: #ffffff;
        }
        [data-theme="dark"] {
            --body-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --topbar-bg: rgba(30,41,59,0.95);
            --profile-bg: #334155;
            --profile-text: #e2e8f0;
            --border-color: rgba(255,255,255,0.06);
            --card-bg: #1e293b;
        }
        body {
            background: var(--body-bg);
            min-height: 100vh;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            margin: 0;
        }
        .topbar {
            background: var(--topbar-bg);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
            padding: 12px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid var(--border-color);
        }
        .topbar-brand {
            font-size: 1.2rem;
            font-weight: 700;
            color: #1e3c72;
        }
        .topbar-widgets {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 0.9rem;
            font-weight: 500;
        }
        .widget-box {
            padding: 6px 14px;
            border-radius: 20px;
            font-size: 0.88rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            box-shadow: 0 2px 6px rgba(0,0,0,0.02);
            cursor: pointer;
        }
        .widget-time { background: #e0f2fe; color: #0369a1; }
        .widget-date { background: #dcfce7; color: #15803d; }
        .user-profile {
            display: flex;
            align-items: center;
            background: var(--profile-bg);
            padding: 6px 14px;
            border-radius: 20px;
            color: var(--profile-text);
        }
        .card-cambio {
            width: 450px;
            border-radius: 16px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            background: var(--card-bg);
        }
    
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


    </style>
</head>
<body>
    <div class="topbar">
        <div class="topbar-brand"><i class="bi bi-shield-lock-fill me-2"></i>Cambio Obligatorio de Contraseña</div>
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

    <div class="d-flex align-items-center justify-content-center" style="min-height: calc(100vh - 70px);">
        <div class="card card-cambio p-4">
            <div class="text-center mb-4">
                <i class="bi bi-shield-lock-fill text-danger" style="font-size: 3rem;"></i>
                <h4 class="mt-2 fw-bold">Cambio de Contraseña Requerido</h4>
                <p class="text-muted">El administrador ha solicitado que cambies tu contraseña antes de continuar.</p>
            </div>
            <?php echo $mensaje; ?>
            <form method="POST">
                <div class="mb-3">
                    <label class="form-label fw-bold">Nueva Contraseña</label>
                    <input type="password" name="nueva_clave" class="form-control" placeholder="Mínimo 4 caracteres" required minlength="4">
                </div>
                <div class="mb-3">
                    <label class="form-label fw-bold">Confirmar Contraseña</label>
                    <input type="password" name="confirmar_clave" class="form-control" placeholder="Repite la contraseña" required minlength="4">
                </div>
                <button type="submit" name="cambiar_clave" class="btn btn-primary w-100 fw-bold" style="background: #1e3c72;">Cambiar Contraseña</button>
            </form>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
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
            if(e.ctrlKey && e.key === 's'){ e.preventDefault(); var f = document.querySelector('form'); if(f) f.submit(); }
        });
    
</script>
</body>
</html>


