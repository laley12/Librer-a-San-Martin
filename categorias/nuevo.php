<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$cats_padre = mysqli_query($conexion, "SELECT id_categoria, nombre_categoria FROM categorias WHERE activo=1 ORDER BY nombre_categoria ASC");
$lista_padres = [];
if ($cats_padre) {
    while ($c = mysqli_fetch_assoc($cats_padre)) {
        $lista_padres[] = $c;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nueva Categoría - Librería San Martín</title>
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
            --form-bg: #ffffff;
            --form-text: #212529;
            --form-border: #dee2e6;
            --form-focus-border: #86b7fe;
            --input-group-bg: #e9ecef;
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
.icon-grid { display: flex; flex-wrap: wrap; gap: 6px; max-height: 120px; overflow-y: auto; padding: 8px; border: 1px solid var(--form-border); border-radius: 8px; }
.icon-grid .icon-option { display: inline-flex; align-items: center; justify-content: center; width: 38px; height: 38px; border-radius: 8px; border: 2px solid transparent; cursor: pointer; font-size: 1.2rem; transition: all 0.15s ease; }
.icon-grid .icon-option:hover { border-color: var(--sidebar-accent); background: var(--sub-item-active-bg); }
.icon-grid .icon-option.selected { border-color: var(--sidebar-accent); background: var(--sidebar-accent); color: #fff; }
    </style>
</head>
<body>

<?php $base_path = '../'; include("../includes/sidebar.php"); ?>

<div class="main-content">
    <div class="topbar">
        <h5><i class="bi bi-tags-fill me-2"></i>Nueva Categoría</h5>
        <div class="user-profile">
            <span style="color:var(--sidebar-text);font-weight:500;"><?php echo htmlspecialchars($_SESSION['nombre'] ?? ''); ?></span>
            <div class="avatar">
                <?php if(!empty($_SESSION['imagen'])): ?>
                    <img src="../assets/uploads/usuarios/<?php echo htmlspecialchars($_SESSION['imagen']); ?>" alt="">
                <?php else: ?>
                    <?php echo strtoupper(substr($_SESSION['nombre'] ?? 'C', 0, 1)); ?>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <div class="container-fluid p-4">
        <div class="row justify-content-center">
            <div class="col-lg-8">

                <div class="panel-custom shadow-sm">
                    <div class="panel-custom-header">
                        <i class="bi bi-plus-circle me-2"></i> Registrar Nueva Categoría
                    </div>

                    <div class="panel-custom-body p-4">
                        <form action="guardar.php" method="POST">
                            <input type="hidden" name="csrf_token" value="<?php echo generarCsrf(); ?>">

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold"><i class="bi bi-tag me-1 text-primary"></i>Nombre de la Categoría <span class="text-danger">*</span></label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-tag"></i></span>
                                        <input type="text" class="form-control" name="nombre_categoria" required placeholder="Ej: Novelas, Textos Escolares...">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold"><i class="bi bi-upc-scan me-1 text-primary"></i>Código</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-upc-scan"></i></span>
                                        <input type="text" class="form-control" name="codigo_categoria" placeholder="Ej: NOV, TXT, INF">
                                    </div>
                                    <div class="form-text">Código corto único</div>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold"><i class="bi bi-sort-numeric-up me-1 text-primary"></i>Orden</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-sort-numeric-up"></i></span>
                                        <input type="number" class="form-control" name="orden" value="0" min="0" placeholder="0">
                                    </div>
                                    <div class="form-text">Posición en listados</div>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label fw-bold"><i class="bi bi-fonts me-1 text-primary"></i>Descripción</label>
                                <textarea class="form-control" name="descripcion" rows="3" placeholder="Descripción detallada de la categoría, ej: Novelas de ficción, drama, romance y literatura contemporánea."></textarea>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-6">
                                    <label class="form-label fw-bold"><i class="bi bi-layers me-1 text-primary"></i>Categoría Padre</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-layers"></i></span>
                                        <select name="categoria_padre" class="form-select">
                                            <option value="">— Ninguna (raíz) —</option>
                                            <?php foreach($lista_padres as $padre): ?>
                                                <option value="<?php echo $padre['id_categoria']; ?>"><?php echo htmlspecialchars($padre['nombre_categoria']); ?></option>
                                            <?php endforeach; ?>
                                        </select>
                                    </div>
                                    <div class="form-text">Si es subcategoría, selecciona la categoría principal</div>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold"><i class="bi bi-eye me-1 text-primary"></i>Visible en Tienda</label>
                                    <div class="input-group">
                                        <span class="input-group-text bg-light"><i class="bi bi-eye"></i></span>
                                        <select name="visible_tienda" class="form-select">
                                            <option value="1">Sí, visible</option>
                                            <option value="0">No, oculta</option>
                                        </select>
                                    </div>
                                    <div class="form-text">Mostrar en la tienda online</div>
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold"><i class="bi bi-asterisk me-1 text-primary"></i>Icono</label>
                                    <input type="text" name="icono" id="iconoInput" class="form-control" value="bi-tags-fill" placeholder="bi-tags-fill">
                                    <div class="form-text">Clase de Bootstrap Icon</div>
                                </div>
                            </div>

                            <div class="mb-4">
                                <label class="form-label fw-bold"><i class="bi bi-palette me-1 text-primary"></i>Iconos disponibles</label>
                                <div class="icon-grid" id="iconGrid">
                                    <div class="icon-option" data-icon="bi-bookmark-fill"><i class="bi bi-bookmark-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-tags-fill"><i class="bi bi-tags-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-book-fill"><i class="bi bi-book-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-pen-fill"><i class="bi bi-pen-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-pencil-fill"><i class="bi bi-pencil-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-journal-richtext"><i class="bi bi-journal-richtext"></i></div>
                                    <div class="icon-option" data-icon="bi-collection-fill"><i class="bi bi-collection-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-star-fill"><i class="bi bi-star-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-heart-fill"><i class="bi bi-heart-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-cup-hot-fill"><i class="bi bi-cup-hot-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-music-note-beamed"><i class="bi bi-music-note-beamed"></i></div>
                                    <div class="icon-option" data-icon="bi-globe"><i class="bi bi-globe"></i></div>
                                    <div class="icon-option" data-icon="bi-mortarboard-fill"><i class="bi bi-mortarboard-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-brush-fill"><i class="bi bi-brush-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-camera-fill"><i class="bi bi-camera-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-film"><i class="bi bi-film"></i></div>
                                    <div class="icon-option" data-icon="bi-controller"><i class="bi bi-controller"></i></div>
                                    <div class="icon-option" data-icon="bi-cpu-fill"><i class="bi bi-cpu-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-phone-fill"><i class="bi bi-phone-fill"></i></div>
                                    <div class="icon-option" data-icon="bi-laptop-fill"><i class="bi bi-laptop-fill"></i></div>
                                </div>
                            </div>

                            <hr>

                            <div class="d-flex justify-content-between align-items-center">
                                <a href="index.php" class="btn btn-outline-secondary px-4">
                                    <i class="bi bi-arrow-left-short"></i> Cancelar y Volver
                                </a>
                                <button type="submit" class="btn btn-primary px-4" style="background: #1e3c72; border: none;">
                                    <i class="bi bi-check-circle-fill me-1"></i> Guardar Categoría
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
    // Icon selector
    var iconInput = document.getElementById('iconoInput');
    var iconOptions = document.querySelectorAll('.icon-option');
    iconOptions.forEach(function(el) {
        el.addEventListener('click', function() {
            iconOptions.forEach(function(o) { o.classList.remove('selected'); });
            this.classList.add('selected');
            iconInput.value = this.getAttribute('data-icon');
        });
    });

    (function() {
        var saved = localStorage.getItem('theme');
        if (window.aplicarTema) { window.aplicarTema(saved || 'light'); }
    })();
</script>
</body>
</html>
