<?php
session_start();

include("../config/conexion.php");

$ruta_imagenes = "../assets/uploads/productos/";

if (isset($_GET['reset_cart'])) {
    unset($_SESSION['carrito']);
    header("Location: index.php");
    exit();
}

$categorias = mysqli_query($conexion, "SELECT id_categoria, nombre_categoria FROM categorias WHERE activo=1 ORDER BY nombre_categoria");

$where = "WHERE 1=1";
$params = [];

if (!empty($_GET['categoria'])) {
    $cat_id = intval($_GET['categoria']);
    $where .= " AND p.categoria_id = $cat_id";
}

if (!empty($_GET['buscar'])) {
    $buscar = mysqli_real_escape_string($conexion, $_GET['buscar']);
    $where .= " AND p.nombre_producto LIKE '%$buscar%'";
}

$productos = mysqli_query($conexion, "
    SELECT p.*, c.nombre_categoria 
    FROM productos p 
    INNER JOIN categorias c ON p.categoria_id = c.id_categoria 
    $where 
    ORDER BY p.nombre_producto
");

$cat_activa = isset($_GET['categoria']) ? intval($_GET['categoria']) : 0;
$buscar_activo = isset($_GET['buscar']) ? htmlspecialchars($_GET['buscar']) : '';

$carrito = isset($_SESSION['carrito']) ? $_SESSION['carrito'] : [];
$cart_count = array_sum(array_column($carrito, 'cantidad'));
?>
<!DOCTYPE html>
<html lang="es" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Librería San Martín - Tienda</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --hero-bg: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            --card-shadow: 0 4px 15px rgba(0,0,0,0.06);
            --card-hover-shadow: 0 8px 25px rgba(0,0,0,0.12);
            --card-radius: 16px;
            --transition: all 0.3s ease;
        }
        [data-bs-theme="dark"] {
            --card-shadow: 0 4px 15px rgba(0,0,0,0.3);
            --card-hover-shadow: 0 8px 25px rgba(0,0,0,0.5);
        }
        [data-bs-theme="sepia"] {
            --card-shadow: 0 4px 15px rgba(60,45,30,0.1);
            --card-hover-shadow: 0 8px 25px rgba(60,45,30,0.15);
        }
        body {
            background: #f8fafc;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
        }
        [data-bs-theme="sepia"] body {
            background: #F5F0E1;
        }
        [data-bs-theme="dark"] body {
            background: #0f172a;
        }
        .hero-section {
            background: var(--hero-bg);
            padding: 60px 0 50px;
            margin-bottom: 30px;
            position: relative;
            overflow: hidden;
        }
        .hero-section::before {
            content: '';
            position: absolute;
            top: -50%;
            right: -20%;
            width: 600px;
            height: 600px;
            background: rgba(255,255,255,0.03);
            border-radius: 50%;
        }
        .hero-section::after {
            content: '';
            position: absolute;
            bottom: -30%;
            left: -10%;
            width: 400px;
            height: 400px;
            background: rgba(255,255,255,0.02);
            border-radius: 50%;
        }
        .hero-title {
            font-size: 2.2rem;
            font-weight: 800;
            color: #fff;
            text-shadow: 0 2px 10px rgba(0,0,0,0.15);
            position: relative;
            z-index: 1;
        }
        .hero-subtitle {
            color: rgba(255,255,255,0.8);
            font-size: 1.1rem;
            position: relative;
            z-index: 1;
        }
        .cart-btn {
            position: relative;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.25);
            color: #fff;
            border-radius: 50px;
            padding: 8px 20px;
            backdrop-filter: blur(8px);
            transition: var(--transition);
        }
        .cart-btn:hover {
            background: rgba(255,255,255,0.25);
            color: #fff;
        }
        .cart-badge {
            position: absolute;
            top: -6px;
            right: -6px;
            background: #dc3545;
            color: #fff;
            border-radius: 50%;
            width: 22px;
            height: 22px;
            font-size: 0.7rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 2px 6px rgba(220,53,69,0.4);
        }
        .category-pill {
            border-radius: 50px;
            padding: 8px 20px;
            font-size: 0.85rem;
            font-weight: 500;
            transition: var(--transition);
            border: 1px solid #dee2e6;
            color: #495057;
            background: #fff;
            text-decoration: none;
            display: inline-block;
        }
        .category-pill:hover, .category-pill.active {
            background: #1e3c72;
            color: #fff;
            border-color: #1e3c72;
        }
        [data-bs-theme="sepia"] .category-pill {
            background: #EDE4CC;
            border-color: #C4B59A;
            color: #3D2B1F;
        }
        [data-bs-theme="sepia"] .category-pill:hover,
        [data-bs-theme="sepia"] .category-pill.active {
            background: #C4B59A;
            border-color: #8B7D6B;
            color: #2C1810;
        }
        [data-bs-theme="dark"] .category-pill {
            background: #1e293b;
            border-color: #334155;
            color: #cbd5e1;
        }
        [data-bs-theme="dark"] .category-pill:hover,
        [data-bs-theme="dark"] .category-pill.active {
            background: #2a5298;
            border-color: #2a5298;
            color: #fff;
        }
        .producto-card {
            background: #fff;
            border-radius: var(--card-radius);
            box-shadow: var(--card-shadow);
            transition: var(--transition);
            overflow: hidden;
            height: 100%;
            border: none;
        }
        .producto-card:hover {
            box-shadow: var(--card-hover-shadow);
            transform: translateY(-4px);
        }
        [data-bs-theme="dark"] .producto-card {
            background: #1e293b;
        }
        [data-bs-theme="sepia"] .producto-card {
            background: #EDE4CC;
        }
        .producto-img {
            width: 100%;
            height: 200px;
            object-fit: contain;
            padding: 20px;
            background: #f8f9fa;
            border-bottom: 1px solid #f0f0f0;
        }
        [data-bs-theme="dark"] .producto-img {
            background: #0f172a;
            border-bottom-color: #1e293b;
        }
        [data-bs-theme="sepia"] .producto-img {
            background: #F0E8D4;
            border-bottom-color: #C4B59A;
        }
        .producto-img-placeholder {
            width: 100%;
            height: 200px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
            font-size: 4rem;
            color: #adb5bd;
            border-bottom: 1px solid #f0f0f0;
        }
        [data-bs-theme="dark"] .producto-img-placeholder {
            background: #0f172a;
            border-bottom-color: #1e293b;
        }
        [data-bs-theme="sepia"] .producto-img-placeholder {
            background: #F0E8D4;
            border-bottom-color: #C4B59A;
        }
        .producto-body {
            padding: 16px;
        }
        .producto-nombre {
            font-size: 0.95rem;
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 6px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
            min-height: 2.4em;
        }
        [data-bs-theme="dark"] .producto-nombre {
            color: #e2e8f0;
        }
        [data-bs-theme="sepia"] .producto-nombre {
            color: #3D2B1F;
        }
        .producto-precio {
            font-size: 1.35rem;
            font-weight: 800;
            color: #1e3c72;
        }
        [data-bs-theme="dark"] .producto-precio {
            color: #60a5fa;
        }
        .producto-stock {
            font-size: 0.8rem;
        }
        .btn-add-cart {
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.85rem;
            padding: 8px 16px;
            transition: var(--transition);
            width: 100%;
        }
        .toast-cart {
            position: fixed;
            bottom: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 250px;
        }
        .dark-toggle-btn {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.25);
            color: #fff;
            border-radius: 50px;
            padding: 8px 12px;
            cursor: pointer;
            transition: var(--transition);
        }
        .dark-toggle-btn:hover {
            background: rgba(255,255,255,0.25);
        }
        .search-form .input-group {
            border-radius: 50px;
            overflow: hidden;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
        }
        .search-form .form-control {
            border: 1px solid #dee2e6;
            border-right: none;
            padding: 10px 16px;
        }
        .search-form .btn {
            border: 1px solid #dee2e6;
            border-left: none;
            padding: 10px 16px;
        }
        @media (max-width: 576px) {
            .hero-title { font-size: 1.6rem; }
            .hero-section { padding: 40px 0 30px; }
        }
    </style>
</head>
<body>

<div class="hero-section">
    <div class="container">
        <div class="d-flex justify-content-between align-items-start">
            <div>
                <h1 class="hero-title mb-2"><i class="bi bi-book-half me-2"></i>Librería San Martín</h1>
                <p class="hero-subtitle mb-0">Material escolar, útiles de oficina y más...</p>
            </div>
            <div class="d-flex gap-2">
                <button class="dark-toggle-btn" id="darkModeBtn" title="Modo oscuro">
                    <i class="bi bi-moon-fill"></i>
                </button>
                <a href="carrito.php" class="cart-btn text-decoration-none">
                    <i class="bi bi-cart3 me-1"></i> Carrito
                    <span class="cart-badge" id="cartBadge"><?php echo $cart_count; ?></span>
                </a>
            </div>
        </div>
    </div>
</div>

<div class="container pb-5">

    <div class="row mb-4">
        <div class="col-md-8 mb-3 mb-md-0">
            <div class="d-flex flex-wrap gap-2">
                <a href="index.php" class="category-pill <?php echo !$cat_activa ? 'active' : ''; ?>">Todas</a>
                <?php while ($cat = mysqli_fetch_assoc($categorias)): ?>
                    <a href="index.php?categoria=<?php echo $cat['id_categoria']; ?><?php echo $buscar_activo ? '&buscar='.urlencode($buscar_activo) : ''; ?>" 
                       class="category-pill <?php echo $cat_activa == $cat['id_categoria'] ? 'active' : ''; ?>">
                        <?php echo htmlspecialchars($cat['nombre_categoria']); ?>
                    </a>
                <?php endwhile; ?>
            </div>
        </div>
        <div class="col-md-4">
            <form method="GET" class="search-form">
                <?php if ($cat_activa): ?>
                    <input type="hidden" name="categoria" value="<?php echo $cat_activa; ?>">
                <?php endif; ?>
                <div class="input-group">
                    <input type="text" name="buscar" class="form-control" placeholder="Buscar productos..." value="<?php echo $buscar_activo; ?>">
                    <button class="btn btn-light" type="submit"><i class="bi bi-search"></i></button>
                    <?php if ($buscar_activo): ?>
                        <a href="index.php<?php echo $cat_activa ? '?categoria='.$cat_activa : ''; ?>" class="btn btn-light"><i class="bi bi-x-lg"></i></a>
                    <?php endif; ?>
                </div>
            </form>
        </div>
    </div>

    <?php if ($buscar_activo): ?>
        <div class="mb-4">
            <span class="badge bg-primary fs-6 px-3 py-2">
                <i class="bi bi-search me-1"></i> Resultados para: "<?php echo $buscar_activo; ?>"
            </span>
        </div>
    <?php endif; ?>

    <?php if (mysqli_num_rows($productos) == 0): ?>
        <div class="text-center py-5">
            <i class="bi bi-emoji-frown" style="font-size:4rem;color:#adb5bd;"></i>
            <h4 class="mt-3 text-muted">No se encontraron productos</h4>
            <a href="index.php" class="btn btn-outline-primary mt-2"><i class="bi bi-arrow-left me-1"></i> Volver a la tienda</a>
        </div>
    <?php else: ?>
        <div class="row g-4">
            <?php while ($prod = mysqli_fetch_assoc($productos)): 
                $imagen = $prod['imagen'];
                $ruta_img = $ruta_imagenes . $imagen;
                $tiene_img = !empty($imagen) && file_exists($ruta_img);
            ?>
                <div class="col-sm-6 col-md-4 col-lg-3">
                    <div class="producto-card">
                        <?php if ($tiene_img): ?>
                            <img src="<?php echo $ruta_img; ?>" alt="<?php echo htmlspecialchars($prod['nombre_producto']); ?>" class="producto-img">
                        <?php else: ?>
                            <div class="producto-img-placeholder">
                                <i class="bi bi-image"></i>
                            </div>
                        <?php endif; ?>
                        <div class="producto-body">
                            <div class="producto-nombre"><?php echo htmlspecialchars($prod['nombre_producto']); ?></div>
                            <div class="producto-precio mb-1">Bs <?php echo number_format($prod['precio'], 2); ?></div>
                            <div class="producto-stock mb-3">
                                <?php if ($prod['stock'] > 0): ?>
                                    <span class="text-success"><i class="bi bi-check-circle-fill me-1"></i>En stock (<?php echo $prod['stock']; ?> u.)</span>
                                <?php else: ?>
                                    <span class="text-danger"><i class="bi bi-x-circle-fill me-1"></i>Sin stock</span>
                                <?php endif; ?>
                            </div>
                            <button class="btn btn-primary btn-add-cart" 
                                    onclick="agregarCarrito(<?php echo $prod['id_producto']; ?>)" 
                                    <?php echo $prod['stock'] < 1 ? 'disabled' : ''; ?>>
                                <i class="bi bi-cart-plus me-1"></i> Agregar al Carrito
                            </button>
                        </div>
                    </div>
                </div>
            <?php endwhile; ?>
        </div>
    <?php endif; ?>

</div>

<div class="toast-container toast-cart" id="cartToastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function agregarCarrito(id) {
    fetch('carrito.php?action=add&id=' + id + '&cantidad=1')
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                document.getElementById('cartBadge').textContent = data.count;
                mostrarToast(data.message || 'Producto agregado al carrito');
            } else {
                mostrarToast(data.message || 'Error al agregar', 'danger');
            }
        })
        .catch(() => mostrarToast('Error de conexión', 'danger'));
}

function mostrarToast(mensaje, tipo) {
    tipo = tipo || 'success';
    const container = document.getElementById('cartToastContainer');
    const toast = document.createElement('div');
    toast.className = 'toast align-items-center text-bg-' + tipo + ' border-0 show';
    toast.setAttribute('role', 'alert');
    toast.innerHTML = '<div class="d-flex"><div class="toast-body"><i class="bi bi-' + (tipo === 'success' ? 'check-circle-fill' : 'exclamation-triangle-fill') + ' me-2"></i>' + mensaje + '</div><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button></div>';
    container.appendChild(toast);
    setTimeout(() => { toast.remove(); }, 3000);
}

(function() {
    var temas = ['light', 'sepia', 'dark'];
    var iconos = {'light': 'bi-moon-fill', 'sepia': 'bi-sun-fill', 'dark': 'bi-sun-fill'};
    var saved = localStorage.getItem('theme');
    if (temas.indexOf(saved) >= 0 && saved !== 'light') {
        document.documentElement.setAttribute('data-bs-theme', saved);
    }
    var btn = document.getElementById('darkModeBtn');
    if (btn) {
        if (saved && saved !== 'light') {
            btn.querySelector('i').className = saved === 'sepia' ? 'bi bi-bookmark-fill' : 'bi bi-sun-fill';
        }
        btn.addEventListener('click', function() {
            var current = document.documentElement.getAttribute('data-bs-theme') || 'light';
            var idx = temas.indexOf(current);
            if (idx < 0) idx = 0;
            var next = temas[(idx + 1) % temas.length];
            if (next === 'light') {
                document.documentElement.removeAttribute('data-bs-theme');
            } else {
                document.documentElement.setAttribute('data-bs-theme', next);
            }
            localStorage.setItem('theme', next);
            var icons = {'light': 'bi-moon-fill', 'sepia': 'bi-bookmark-fill', 'dark': 'bi-sun-fill'};
            this.querySelector('i').className = 'bi ' + (icons[next] || 'bi-moon-fill');
        });
    }
})();
</script>
</body>
</html>
