<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(isset($_POST['ingresar'])){

    if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
        die('Error de seguridad');
    }

    $usuario = mysqli_real_escape_string($conexion, $_POST['usuario']);
    $password = $_POST['password'];
    $ip = $_SERVER['REMOTE_ADDR'];

    $usuario_esc = mysqli_real_escape_string($conexion, $usuario);

    $bloqueo = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT * FROM intentos_login WHERE usuario='$usuario_esc' AND ip='$ip'"));
    if ($bloqueo && !empty($bloqueo['bloqueado_hasta']) && strtotime($bloqueo['bloqueado_hasta']) > time()) {
        $diff = strtotime($bloqueo['bloqueado_hasta']) - time();
        $mins = ceil($diff / 60);
        $error = "Demasiados intentos. Intente en $mins minuto(s).";
    } else {

        $sql = "SELECT * FROM usuarios WHERE usuario='$usuario_esc'";
        $resultado = mysqli_query($conexion,$sql);

        if(mysqli_num_rows($resultado)>0){

            $fila = mysqli_fetch_assoc($resultado);

            $password_ok = false;
            if (!empty($fila['password_hash']) && password_verify($password, $fila['password_hash'])) {
                $password_ok = true;
            } elseif (password_verify($password, $fila['password'])) {
                $password_ok = true;
                $hashed = password_hash($password, PASSWORD_DEFAULT);
                mysqli_query($conexion, "UPDATE usuarios SET password_hash='$hashed' WHERE id={$fila['id']}");
            } elseif (!empty($fila['password']) && $fila['password'] === $password) {
                $password_ok = true;
                $hashed = password_hash($password, PASSWORD_DEFAULT);
                mysqli_query($conexion, "UPDATE usuarios SET password_hash='$hashed', password='$hashed' WHERE id={$fila['id']}");
            }

            if($password_ok){
                mysqli_query($conexion, "DELETE FROM intentos_login WHERE usuario='$usuario_esc' AND ip='$ip'");

                if(isset($fila['estado']) && strtolower($fila['estado']) === 'inactivo'){
                    $error = "Esta cuenta está desactivada. Contacte al administrador.";
                } else {
                    $_SESSION['id'] = $fila['id'];
                $_SESSION['nombre'] = $fila['nombre'];
                $_SESSION['rol'] = $fila['rol'];
                $_SESSION['imagen'] = $fila['imagen'] ?? '';
                $_SESSION['tema'] = $fila['tema'] ?? 'light';
                $_SESSION['welcome'] = true;
                mysqli_query($conexion, "UPDATE usuarios SET ultimo_acceso = NOW() WHERE id = {$fila['id']}");

                if(isset($fila['forzar_cambio']) && $fila['forzar_cambio'] == 1){
                        header("Location: ../cambiar_clave_obligatorio.php");
                    } else {
                        header("Location: ../dashboard/index.php");
                    }
                }
            } else {
                $error = "Usuario o contraseña incorrectos";
                $exist = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT * FROM intentos_login WHERE usuario='$usuario_esc' AND ip='$ip'"));
                if ($exist) {
                    mysqli_query($conexion, "UPDATE intentos_login SET intentos=intentos+1, ultimo_intento=NOW() WHERE usuario='$usuario_esc' AND ip='$ip'");
                    if (($exist['intentos'] + 1) >= 5) {
                        mysqli_query($conexion, "UPDATE intentos_login SET bloqueado_hasta=DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE usuario='$usuario_esc' AND ip='$ip'");
                    }
                } else {
                    mysqli_query($conexion, "INSERT INTO intentos_login (usuario, ip, intentos, ultimo_intento) VALUES ('$usuario_esc', '$ip', 1, NOW())");
                }
            }

        }else{

            $error = "Usuario o contraseña incorrectos";

        }
    }
}
?>

<!DOCTYPE html>
<html lang="es">
<head>

<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">

<title>Librería San Martín</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

<style>

body {
    background: linear-gradient(rgba(0, 0, 0, 0.45), rgba(0, 0, 0, 0.45)), url('https://cdn.phototourl.com/free/2026-06-18-cfe49294-a2ef-4f79-8115-11677f814edb.png');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-attachment: fixed;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: center;
    margin: 0;
    overflow: hidden;
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
}

.card-login {
    width: 450px;
    border: 1px solid rgba(255, 255, 255, 0.12);
    border-radius: 24px;
    box-shadow: 0 25px 60px rgba(0, 0, 0, 0.65);
    background: rgba(0, 0, 0, 0.78);
    backdrop-filter: blur(15px);
    -webkit-backdrop-filter: blur(15px);
    color: #ffffff;
    animation: fadeInScale 0.6s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
}

.logo-container {
    display: flex;
    justify-content: center;
    margin-bottom: 10px;
    margin-top: 10px;
}

.logo-img {
    width: 280px;
    height: auto;
    object-fit: contain;
}

.form-control {
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid rgba(255, 255, 255, 0.15);
    color: #ffffff;
    border-radius: 12px;
    padding: 12px 15px;
    transition: all 0.3s ease;
}

.form-control:focus {
    background: rgba(255, 255, 255, 0.12);
    border-color: #00ced1;
    color: #ffffff;
    box-shadow: 0 0 15px rgba(0, 206, 209, 0.35);
}

.form-label-custom {
    font-weight: 600;
    margin-bottom: 6px;
    font-size: 0.95rem;
    letter-spacing: 0.5px;
}

.btn-animate {
    background: linear-gradient(135deg, #00ced1, #20b2aa);
    background-size: 200% auto;
    border: none;
    border-radius: 12px;
    padding: 13px;
    font-weight: 700;
    font-size: 1rem;
    letter-spacing: 0.5px;
    color: white;
    box-shadow: 0 4px 15px rgba(0, 206, 209, 0.4);
    transition: all 0.4s ease;
    animation: gradientMove 4s ease infinite;
}

.btn-animate:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(0, 206, 209, 0.6);
    color: white;
}

@keyframes fadeInScale {
    0% {
        opacity: 0;
        transform: scale(0.92) translateY(15px);
    }
    100% {
        opacity: 1;
        transform: scale(1) translateY(0);
    }
}

@keyframes gradientMove {
    0% { background-position: 0% 50%; }
    50% { background-position: 100% 50%; }
    100% { background-position: 0% 50%; }
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

<div class="card card-login">

<div class="card-body p-4 text-center">

<div class="logo-container">
    <img src="https://cdn.phototourl.com/free/2026-06-18-fab46ea4-e5da-46f6-8d74-d414278dc5ef.png" alt="Librería San Martín" class="logo-img">
</div>

<?php
if(isset($error)){
?>
<div class="alert alert-danger bg-danger text-white border-0 rounded-3 text-center py-2 mb-3">
<?php echo $error; ?>
</div>
<?php
}
?>

<form method="POST" class="text-start mt-3">

<input type="hidden" name="csrf_token" value="<?php echo generarCsrf(); ?>">

<div class="mb-3">

<label class="form-label-custom">Usuario</label>

<input
type="text"
name="usuario"
class="form-control"
placeholder="Ingresa tu usuario"
required>

</div>

<div class="mb-4">

<label class="form-label-custom">Contraseña</label>

<input
type="password"
name="password"
class="form-control"
placeholder="••••••••"
required>

</div>

<button
type="submit"
name="ingresar"
class="btn btn-animate w-100">

Iniciar Sesión

</button>

</form>

</div>

</div>

</body>
</html>