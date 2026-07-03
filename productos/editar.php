<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id = intval($_GET['id']);

if(isset($_POST['actualizar'])){
    if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
        die('Error de seguridad');
    }
    $nombre = mysqli_real_escape_string($conexion, $_POST['nombre_producto']);
    $descripcion = mysqli_real_escape_string($conexion, $_POST['descripcion']);
    $precio = floatval($_POST['precio']);
    $impuesto = floatval($_POST['impuesto'] ?? 0);
    $stock = intval($_POST['stock']);
    $categoria = intval($_POST['categoria']);
    $codigo = mysqli_real_escape_string($conexion, $_POST['codigo']);
    $codigo_barras = mysqli_real_escape_string($conexion, trim($_POST['codigo_barras'] ?? ''));
    $talla = mysqli_real_escape_string($conexion, trim($_POST['talla'] ?? ''));
    $color = mysqli_real_escape_string($conexion, trim($_POST['color'] ?? ''));

    $producto_actual = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT imagen FROM productos WHERE id_producto=$id AND activo=1"));
    $imagen_nombre = $producto_actual['imagen'] ?? null;

    if(isset($_POST['eliminar_imagen']) && !empty($imagen_nombre)){
        $ruta_imagen = "../assets/uploads/productos/" . $imagen_nombre;
        if(file_exists($ruta_imagen)) unlink($ruta_imagen);
        $imagen_nombre = null;
    }

    if(isset($_FILES['imagen']) && $_FILES['imagen']['error'] == UPLOAD_ERR_OK){
        $permitidos = ['image/png', 'image/jpeg', 'image/webp'];
        $tipo = $_FILES['imagen']['type'];
        $tamano = $_FILES['imagen']['size'];

        if(in_array($tipo, $permitidos) && $tamano <= 2 * 1024 * 1024){
            if(!empty($producto_actual['imagen'])){
                $ruta_vieja = "../assets/uploads/productos/" . $producto_actual['imagen'];
                if(file_exists($ruta_vieja)) unlink($ruta_vieja);
            }

            $carpeta_destino = "../assets/uploads/productos/";
            if(!file_exists($carpeta_destino)) mkdir($carpeta_destino, 0777, true);

            $imagen_nombre = time() . '_' . basename($_FILES['imagen']['name']);
            move_uploaded_file($_FILES['imagen']['tmp_name'], $carpeta_destino . $imagen_nombre);
        }
    }

    $sql = "UPDATE productos SET
            codigo='$codigo',
            codigo_barras=" . ($codigo_barras ? "'$codigo_barras'" : "NULL") . ",
            nombre_producto='$nombre',
            descripcion='$descripcion',
            precio='$precio',
            impuesto='$impuesto',
            stock='$stock',
            talla=" . ($talla ? "'$talla'" : "NULL") . ",
            color=" . ($color ? "'$color'" : "NULL") . ",
            categoria_id='$categoria'";

    if($imagen_nombre === null){
        $sql .= ", imagen=NULL";
    } elseif($imagen_nombre !== $producto_actual['imagen']){
        $sql .= ", imagen='" . mysqli_real_escape_string($conexion, $imagen_nombre) . "'";
    }

    $sql .= " WHERE id_producto=$id";

    mysqli_query($conexion, $sql);
    $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
    mysqli_query($conexion, "INSERT INTO auditoria_productos (id_usuario, accion) VALUES ($id_user, 'Editó producto ID: $id, Código: $codigo, Nombre: $nombre')");
    header("Location: index.php");
    exit();
}

$producto = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT p.*, c.nombre_categoria FROM productos p LEFT JOIN categorias c ON p.categoria_id = c.id_categoria WHERE p.id_producto=$id AND p.activo=1"));
$categorias = mysqli_query($conexion, "SELECT * FROM categorias WHERE activo=1 ORDER BY nombre_categoria ASC");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Producto - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --body-bg: #f0f3f8;
            --panel-bg: #ffffff;
            --sidebar-accent: #1e3c72;
        }
        [data-theme="dark"] {
            --body-bg: #0f172a;
            --panel-bg: #1e293b;
            --sidebar-accent: #60a5fa;
        }
        body { background: var(--body-bg); font-family: 'Inter', 'Segoe UI', sans-serif; min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 30px 15px; }
        .edit-card { background: var(--panel-bg); border: none; border-radius: 20px; box-shadow: 0 20px 60px rgba(0,0,0,0.08); overflow: hidden; max-width: 680px; width: 100%; animation: fadeInUp 0.4s ease; }
        @keyframes fadeInUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
        .edit-header { background: linear-gradient(135deg, #f39c12, #d35400); padding: 28px 32px; display: flex; align-items: center; gap: 15px; }
        .edit-header-icon { width: 52px; height: 52px; border-radius: 14px; background: rgba(255,255,255,0.2); display: flex; align-items: center; justify-content: center; font-size: 1.5rem; flex-shrink: 0; }
        .edit-header h4 { color: #fff; font-weight: 700; margin: 0; font-size: 1.2rem; }
        .edit-header p { color: rgba(255,255,255,0.8); margin: 2px 0 0; font-size: 0.85rem; }
        .edit-body { padding: 32px; }
        .code-badge { display: inline-flex; align-items: center; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; border-radius: 10px; padding: 6px 14px; font-family: 'Courier New', monospace; font-size: 0.95rem; font-weight: 700; letter-spacing: 1px; margin-bottom: 20px; }
        .form-label { font-weight: 600; color: #475569; font-size: 0.88rem; margin-bottom: 6px; }
        [data-theme="dark"] .form-label { color: #94a3b8; }
        .input-group-text { background: #f8fafc; border-color: #e2e8f0; color: #64748b; }
        [data-theme="dark"] .input-group-text { background: #334155; border-color: #475569; color: #94a3b8; }
        [data-theme="dark"] .form-control, [data-theme="dark"] .form-select { background: #334155; border-color: #475569; color: #e2e8f0; }
        [data-theme="dark"] .form-control:focus, [data-theme="dark"] .form-select:focus { background: #3b4f6b; border-color: #60a5fa; color: #e2e8f0; box-shadow: 0 0 0 3px rgba(96,165,250,0.15); }
        .btn-save { background: linear-gradient(135deg, #f39c12, #d35400); border: none; color: #fff; font-weight: 700; border-radius: 12px; padding: 12px 30px; font-size: 1rem; transition: all 0.2s ease; }
        .btn-save:hover { transform: translateY(-1px); box-shadow: 0 8px 20px rgba(243,156,18,0.35); color: #fff; }
        .btn-cancel { border-radius: 12px; padding: 12px 24px; font-weight: 600; }
        .dark-toggle { position: fixed; top: 20px; right: 20px; background: var(--panel-bg); border: 1px solid rgba(0,0,0,0.08); border-radius: 50%; width: 42px; height: 42px; display: flex; align-items: center; justify-content: center; cursor: pointer; font-size: 1.1rem; box-shadow: 0 2px 12px rgba(0,0,0,0.08); transition: all 0.2s; }
        .stock-badge { display: inline-flex; align-items: center; gap: 6px; font-size: 0.78rem; font-weight: 600; padding: 3px 10px; border-radius: 20px; }
    </style>
</head>
<body>

<div class="dark-toggle" id="darkToggle" title="Modo oscuro">
    <i class="bi bi-moon-fill"></i>
</div>

<div class="edit-card">
    <div class="edit-header">
        <div class="edit-header-icon"><i class="bi bi-pencil-square"></i></div>
        <div>
            <h4>Editar Producto</h4>
            <p>Modificando: <strong><?php echo htmlspecialchars($producto['nombre_producto']); ?></strong></p>
        </div>
    </div>
    <div class="edit-body">
        <div class="d-flex align-items-center gap-3 mb-4">
            <div class="code-badge"><i class="bi bi-upc-scan me-2"></i><?php echo htmlspecialchars($producto['codigo']); ?></div>
            <div>
                <span class="text-muted small">ID del producto:</span>
                <span class="badge bg-secondary-subtle text-secondary ms-1">#<?php echo $producto['id_producto']; ?></span>
            </div>
            <div>
                <?php $sc = $producto['stock'] < 10 ? 'bg-danger-subtle text-danger' : ($producto['stock'] < 30 ? 'bg-warning-subtle text-warning' : 'bg-success-subtle text-success'); ?>
                <span class="stock-badge <?php echo $sc; ?>"><i class="bi bi-boxes"></i><?php echo $producto['stock']; ?> unid.</span>
            </div>
        </div>

        <form method="POST" enctype="multipart/form-data">
            <input type="hidden" name="csrf_token" value="<?php echo generarCsrf(); ?>">
            <div class="row g-3">
                <div class="col-md-4">
                    <label class="form-label"><i class="bi bi-upc me-1"></i>Código de Producto</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-upc-scan"></i></span>
                        <input type="text" name="codigo" class="form-control fw-bold" value="<?php echo htmlspecialchars($producto['codigo']); ?>" placeholder="PROD-0001" required>
                    </div>
                    <small class="text-muted">Puedes personalizarlo</small>
                </div>
                <div class="col-md-8">
                    <label class="form-label"><i class="bi bi-tag-fill me-1"></i>Nombre del Producto</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-book-half"></i></span>
                        <input type="text" name="nombre_producto" class="form-control" value="<?php echo htmlspecialchars($producto['nombre_producto']); ?>" required>
                    </div>
                </div>
                <div class="col-12">
                    <label class="form-label"><i class="bi bi-card-text me-1"></i>Descripción / Detalles</label>
                    <textarea name="descripcion" class="form-control" rows="2"><?php echo htmlspecialchars($producto['descripcion']); ?></textarea>
                </div>
                <div class="col-md-4">
                    <label class="form-label"><i class="bi bi-currency-dollar me-1"></i>Precio de Venta (Bs.)</label>
                    <div class="input-group">
                        <span class="input-group-text">Bs.</span>
                        <input type="number" step="0.01" name="precio" class="form-control" value="<?php echo $producto['precio']; ?>" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="form-label"><i class="bi bi-boxes me-1"></i>Stock Actual</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-boxes"></i></span>
                        <input type="number" name="stock" class="form-control" value="<?php echo $producto['stock']; ?>" required>
                    </div>
                </div>
                <div class="col-md-4">
                    <label class="form-label"><i class="bi bi-folder-fill me-1"></i>Categoría</label>
                    <div class="input-group">
                        <span class="input-group-text"><i class="bi bi-tags-fill"></i></span>
                        <select name="categoria" class="form-select" required>
                            <?php while($cat = mysqli_fetch_assoc($categorias)){ ?>
                                <option value="<?php echo $cat['id_categoria']; ?>" <?php if($producto['categoria_id'] == $cat['id_categoria']){ echo 'selected'; } ?>>
                                    <?php echo htmlspecialchars($cat['nombre_categoria']); ?>
                                </option>
                            <?php } ?>
                                </select>
                                    </div>
                                </div>
                            </div>

                            <div class="row g-3 mb-3">
                                <div class="col-md-4">
                                    <label class="form-label"><i class="bi bi-upc-scan me-1"></i>Código de Barras</label>
                                    <input type="text" name="codigo_barras" class="form-control" value="<?php echo htmlspecialchars($producto['codigo_barras'] ?? ''); ?>" placeholder="Ej. 7791234567890">
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label"><i class="bi bi-percent me-1"></i>IVA (%)</label>
                                    <input type="number" step="0.01" name="impuesto" class="form-control" value="<?php echo $producto['impuesto'] ?? 0; ?>">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label"><i class="bi bi-rulers me-1"></i>Talla</label>
                                    <input type="text" name="talla" class="form-control" value="<?php echo htmlspecialchars($producto['talla'] ?? ''); ?>" placeholder="Único, S, M, L, XL">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label"><i class="bi bi-palette me-1"></i>Color</label>
                                    <input type="text" name="color" class="form-control" value="<?php echo htmlspecialchars($producto['color'] ?? ''); ?>" placeholder="Azul, Rojo, Negro">
                                </div>
                            </div>

                            <hr class="my-4">

            <div class="row g-3 mb-3 align-items-center">
                <div class="col-md-5">
                    <?php if(!empty($producto['imagen'])): ?>
                        <div class="text-center">
                            <img src="../assets/uploads/productos/<?php echo $producto['imagen']; ?>" alt="Imagen actual" style="max-width:150px; border-radius:8px; border:1px solid #e2e8f0; padding:4px;">
                            <div class="form-check mt-2">
                                <input class="form-check-input" type="checkbox" name="eliminar_imagen" id="eliminar_imagen" value="1">
                                <label class="form-check-label text-danger" for="eliminar_imagen"><i class="bi bi-trash3 me-1"></i>Eliminar imagen</label>
                            </div>
                        </div>
                    <?php else: ?>
                        <div class="text-center text-muted py-3">
                            <i class="bi bi-image" style="font-size:2.5rem;"></i>
                            <p class="mt-1 mb-0 small">Sin imagen actual</p>
                        </div>
                    <?php endif; ?>
                </div>
                <div class="col-md-7">
                    <label class="form-label"><i class="bi bi-image me-1"></i>Cambiar imagen</label>
                    <input type="file" name="imagen" class="form-control" accept="image/png, image/jpeg, image/webp">
                    <div class="form-text">Formatos: PNG, JPG, WebP — Máx. 2MB.</div>
                </div>
            </div>

            <div class="d-flex justify-content-end gap-3">
                <a href="index.php" class="btn btn-outline-secondary btn-cancel"><i class="bi bi-arrow-left me-1"></i>Cancelar</a>
                <button name="actualizar" class="btn btn-save"><i class="bi bi-check-circle me-2"></i>Guardar Cambios</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const darkToggle = document.getElementById('darkToggle');
    if (window.aplicarTema) { window.aplicarTema(localStorage.getItem('theme') || 'light'); }
    var savedT = localStorage.getItem('theme');
    darkToggle.querySelector('i').className = savedT === 'dark' ? 'bi bi-moon-fill' : savedT === 'sepia' ? 'bi bi-brightness-alt-high-fill' : 'bi bi-sun-fill';
    darkToggle.addEventListener('click', function(){
        if (window.ciclarTema) { window.ciclarTema(); }
        var cur = document.documentElement.getAttribute('data-theme') || 'light';
        darkToggle.querySelector('i').className = cur === 'dark' ? 'bi bi-moon-fill' : cur === 'sepia' ? 'bi bi-brightness-alt-high-fill' : 'bi bi-sun-fill';
    });
</script>
</body>
</html>