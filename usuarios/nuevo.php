<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$rol_actual = isset($_SESSION['rol']) ? trim(strtolower($_SESSION['rol'])) : '';
if($rol_actual !== 'administrador' && $rol_actual !== 'admin'){
    header("Location: ../dashboard/index.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nuevo Usuario - Librería San Martín</title>
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
            --form-bg: #1e293b;
            --form-text: #f1f5f9;
            --form-border: #334155;
            --form-focus-border: #60a5fa;
            --input-group-bg: #0f172a;
        }
body { background: var(--body-bg); font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; margin: 0; overflow-x: hidden; }
.sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; }
.sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; }
.sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
.sidebar-menu::-webkit-scrollbar { width: 4px; }
.sidebar-menu::-webkit-scrollbar-track { background: transparent; }
.sidebar-menu::-webkit-scrollbar-thumb { background: var(--scrollbar-thumb); border-radius: 10px; }
.sidebar-menu::-webkit-scrollbar-thumb:hover { background: var(--scrollbar-thumb-hover); }
.sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; cursor: pointer; border-left: 3px solid transparent; }
.sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
.sidebar-menu a:hover { background: var(--sidebar-hover-bg); border-left-color: var(--sidebar-accent); }
.main-content { margin-left: 260px; min-height: 100vh; }
.topbar { display: flex; justify-content: space-between; align-items: center; padding: 12px 25px; background: var(--topbar-bg); backdrop-filter: blur(12px); border-bottom: 1px solid rgba(0,0,0,0.04); position: sticky; top: 0; z-index: 500; }
.topbar h5 { margin: 0; font-weight: 700; color: var(--sidebar-text); }
.user-profile { display: flex; align-items: center; gap: 12px; }
.user-profile .avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--sidebar-brand-bg); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; }
.user-profile .avatar img { width: 38px; height: 38px; border-radius: 50%; object-fit: cover; }
.panel-custom { background: var(--panel-bg); border-radius: 12px; overflow: hidden; }
.panel-custom-header { background: var(--panel-header-bg); color: #fff; padding: 14px 20px; font-weight: 700; font-size: 1.1rem; }
.panel-custom-body { padding: 20px; }
[data-theme="dark"] .form-control, [data-theme="dark"] .form-select {
            background-color: var(--form-bg); color: var(--form-text); border-color: var(--form-border);
        }
[data-theme="dark"] .form-control:focus, [data-theme="dark"] .form-select:focus {
            border-color: var(--form-focus-border); box-shadow: 0 0 0 0.2rem rgba(96,165,250,0.15);
        }
[data-theme="dark"] .input-group-text { background: var(--input-group-bg) !important; color: var(--form-text); border-color: var(--form-border); }
.form-label { color: var(--profile-text); }
    </style>
</head>
<body>

<?php $base_path = '../'; include("../includes/sidebar.php"); ?>

<div class="main-content">

    <div class="topbar">
        <h5><i class="bi bi-person-plus-fill me-2"></i>Nuevo Usuario</h5>
        <div class="user-profile">
            <span style="color:var(--sidebar-text);font-weight:500;"><?php echo htmlspecialchars($_SESSION['nombre'] ?? ''); ?></span>
            <div class="avatar">
                <?php if(!empty($_SESSION['imagen'])): ?>
                    <img src="../assets/uploads/usuarios/<?php echo htmlspecialchars($_SESSION['imagen']); ?>" alt="">
                <?php else: ?>
                    <?php echo strtoupper(substr($_SESSION['nombre'] ?? 'U', 0, 1)); ?>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <div class="container-fluid p-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">

                <div class="panel-custom shadow-sm">
                    <div class="panel-custom-header">
                        <i class="bi bi-person-plus-fill me-2"></i> Registrar Nuevo Usuario
                    </div>

                    <div class="panel-custom-body p-4">
                        <form action="guardar.php" method="POST" enctype="multipart/form-data">
                            <input type="hidden" name="csrf_token" value="<?php echo generarCsrf(); ?>">

                            <div class="row g-3 mb-3">
                                <div class="col-md-4">
                                    <div class="text-center">
                                        <i class="bi bi-person-circle text-secondary" style="font-size: 5rem;" id="preview-icon"></i>
                                        <img id="preview-img" src="" style="width:100px;height:100px;border-radius:50%;object-fit:cover;border:3px solid #e0e0e0;display:none;">
                                        <div class="mt-2">
                                            <label class="btn btn-outline-primary btn-sm"><i class="bi bi-camera-fill"></i> Foto de Perfil
                                                <input type="file" name="imagen" accept="image/jpeg,image/png,image/gif,image/webp" class="d-none" onchange="previewFoto(event)">
                                            </label>
                                        </div>
                                        <div class="form-text">PNG, JPG, WebP. Opcional.</div>
                                    </div>
                                </div>
                                <div class="col-md-8">
                                    <div class="mb-3">
                                        <label class="form-label fw-bold"><i class="bi bi-person me-1 text-primary"></i>Nombre Completo <span class="text-danger">*</span></label>
                                        <div class="input-group">
                                            <span class="input-group-text bg-light"><i class="bi bi-person"></i></span>
                                            <input type="text" name="nombre" class="form-control" placeholder="Ej. Juan Pérez López" required>
                                        </div>
                                    </div>
                                    <div class="row g-2">
                                        <div class="col-md-6">
                                            <label class="form-label fw-bold"><i class="bi bi-at me-1 text-primary"></i>Usuario <span class="text-danger">*</span></label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light"><i class="bi bi-at"></i></span>
                                                <input type="text" name="usuario" class="form-control" placeholder="Ej. jperez" required>
                                            </div>
                                        </div>
                                        <div class="col-md-6">
                                            <label class="form-label fw-bold"><i class="bi bi-envelope me-1 text-primary"></i>Correo Electrónico</label>
                                            <div class="input-group">
                                                <span class="input-group-text bg-light"><i class="bi bi-envelope"></i></span>
                                                <input type="email" name="email" class="form-control" placeholder="ejemplo@correo.com">
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <hr>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold"><i class="bi bi-key me-1 text-primary"></i>Contraseña <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-key"></i></span>
                                        <input type="password" name="password" id="password" class="form-control" placeholder="Mín. 6 caracteres" required minlength="6">
                                        <button type="button" class="btn btn-outline-secondary" onclick="verPass()"><i class="bi bi-eye" id="passIcon"></i></button>
                                    </div>
                                    <div class="form-text">Mínimo 6 caracteres</div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold"><i class="bi bi-shield-check me-1 text-primary"></i>Rol de Usuario <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-shield-check"></i></span>
                                        <select name="rol" class="form-select" required>
                                            <option value="" disabled selected>Seleccione un rol...</option>
                                            <option value="Administrador">Administrador</option>
                                            <option value="Empleado">Empleado</option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold"><i class="bi bi-telephone me-1 text-primary"></i>Teléfono</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-telephone"></i></span>
                                        <input type="text" name="telefono" class="form-control" placeholder="Ej. 78912345">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-bold"><i class="bi bi-geo-alt me-1 text-primary"></i>Dirección</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-geo-alt"></i></span>
                                        <input type="text" name="direccion" class="form-control" placeholder="Dirección (opcional)">
                                    </div>
                                </div>
                            </div>

                            <hr>

                            <div class="d-flex justify-content-between align-items-center">
                                <a href="index.php" class="btn btn-outline-secondary px-4">
                                    <i class="bi bi-arrow-left-short"></i> Cancelar y Volver
                                </a>
                                <button type="submit" name="guardar" class="btn btn-primary px-4" style="background: #1e3c72; border: none;">
                                    <i class="bi bi-check-circle-fill me-1"></i> Guardar Usuario
                                </button>
                            </div>

                        </form>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function previewFoto(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = function(e) {
                const img = document.getElementById('preview-img');
                const icon = document.getElementById('preview-icon');
                img.src = e.target.result;
                img.style.display = 'block';
                icon.style.display = 'none';
            }
            reader.readAsDataURL(file);
        }
    }

    function verPass() {
        const p = document.getElementById('password');
        const ic = document.getElementById('passIcon');
        if (p.type === 'password') {
            p.type = 'text';
            ic.className = 'bi bi-eye-slash';
        } else {
            p.type = 'password';
            ic.className = 'bi bi-eye';
        }
    }

    (function() {
        const saved = localStorage.getItem('theme');
        if (window.aplicarTema) { window.aplicarTema(saved || 'light'); }
    })();
</script>

</body>
</html>
