<?php
session_start();

include("../config/conexion.php");

$ruta_imagenes = "../assets/uploads/productos/";
$action = isset($_GET['action']) ? $_GET['action'] : '';
$is_ajax = !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest';

if (!isset($_SESSION['carrito'])) {
    $_SESSION['carrito'] = [];
}

if ($action) {
    switch ($action) {
        case 'add':
            $id = intval($_GET['id'] ?? 0);
            $cantidad = intval($_GET['cantidad'] ?? 1);
            if ($id <= 0) {
                echo json_encode(['success' => false, 'message' => 'ID inválido']);
                exit();
            }
            $found = false;
            foreach ($_SESSION['carrito'] as &$item) {
                if ($item['id'] == $id) {
                    $item['cantidad'] += $cantidad;
                    $found = true;
                    break;
                }
            }
            unset($item);
            if (!$found) {
                $result = mysqli_query($conexion, "SELECT id_producto, nombre_producto, precio, imagen FROM productos WHERE id_producto = $id AND activo=1 LIMIT 1");
                if ($row = mysqli_fetch_assoc($result)) {
                    $_SESSION['carrito'][] = [
                        'id' => (int)$row['id_producto'],
                        'nombre' => $row['nombre_producto'],
                        'precio' => (float)$row['precio'],
                        'cantidad' => $cantidad,
                        'imagen' => $row['imagen']
                    ];
                } else {
                    echo json_encode(['success' => false, 'message' => 'Producto no encontrado']);
                    exit();
                }
            }
            $count = array_sum(array_column($_SESSION['carrito'], 'cantidad'));
            echo json_encode(['success' => true, 'count' => $count, 'message' => 'Producto agregado al carrito']);
            exit();

        case 'remove':
            $id = intval($_GET['id'] ?? 0);
            $_SESSION['carrito'] = array_values(array_filter($_SESSION['carrito'], function($item) use ($id) {
                return $item['id'] != $id;
            }));
            $count = array_sum(array_column($_SESSION['carrito'], 'cantidad'));
            echo json_encode(['success' => true, 'count' => $count]);
            exit();

        case 'update':
            $id = intval($_GET['id'] ?? 0);
            $cantidad = intval($_GET['cantidad'] ?? 1);
            if ($cantidad < 1) $cantidad = 1;
            foreach ($_SESSION['carrito'] as &$item) {
                if ($item['id'] == $id) {
                    $item['cantidad'] = $cantidad;
                    break;
                }
            }
            unset($item);
            $count = array_sum(array_column($_SESSION['carrito'], 'cantidad'));
            echo json_encode(['success' => true, 'count' => $count]);
            exit();

        case 'count':
            $count = array_sum(array_column($_SESSION['carrito'], 'cantidad'));
            echo json_encode(['count' => $count]);
            exit();

        case 'clear':
            $_SESSION['carrito'] = [];
            if ($is_ajax) {
                echo json_encode(['success' => true, 'count' => 0]);
                exit();
            }
            header("Location: carrito.php");
            exit();
    }
    if ($is_ajax) {
        echo json_encode(['success' => false, 'message' => 'Acción no válida']);
        exit();
    }
}

$carrito = $_SESSION['carrito'];
$total = 0;
foreach ($carrito as $item) {
    $total += $item['precio'] * $item['cantidad'];
}
$cart_count = array_sum(array_column($carrito, 'cantidad'));
?>
<!DOCTYPE html>
<html lang="es" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Carrito - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        :root {
            --hero-bg: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            --card-radius: 16px;
            --transition: all 0.3s ease;
        }
        [data-bs-theme="dark"] {
            --cart-bg: #1e293b;
            --cart-text: #e2e8f0;
            --cart-border: #334155;
            --cart-input-bg: #0f172a;
        }
        [data-bs-theme="sepia"] {
            --cart-bg: #EDE4CC;
            --cart-text: #3D2B1F;
            --cart-border: #C4B59A;
            --cart-input-bg: #FAF5E8;
        }
        body {
            background: #f8fafc;
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            min-height: 100vh;
        }
        [data-bs-theme="dark"] body {
            background: #0f172a;
        }
        [data-bs-theme="sepia"] body {
            background: #F5F0E1;
        }
        .top-bar {
            background: var(--hero-bg);
            padding: 20px 0;
        }
        .top-bar h4 {
            color: #fff;
            font-weight: 700;
            margin: 0;
        }
        .top-bar a {
            color: rgba(255,255,255,0.85);
            text-decoration: none;
            transition: var(--transition);
        }
        .top-bar a:hover {
            color: #fff;
        }
        .cart-table {
            background: #fff;
            border-radius: var(--card-radius);
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            overflow: hidden;
        }
        [data-bs-theme="dark"] .cart-table {
            background: #1e293b;
        }
        [data-bs-theme="sepia"] .cart-table {
            background: #EDE4CC;
        }
        .cart-table th {
            background: #f1f5f9;
            border-bottom: 2px solid #e2e8f0;
            font-weight: 600;
            font-size: 0.85rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            color: #475569;
        }
        [data-bs-theme="dark"] .cart-table th {
            background: #0f172a;
            border-bottom-color: #334155;
            color: #94a3b8;
        }
        [data-bs-theme="sepia"] .cart-table th {
            background: #E0D5BB;
            border-bottom-color: #C4B59A;
            color: #3D2B1F;
        }
        .cart-table td {
            vertical-align: middle;
            border-color: #f1f5f9;
        }
        [data-bs-theme="dark"] .cart-table td {
            border-color: #334155;
            color: #e2e8f0;
        }
        [data-bs-theme="sepia"] .cart-table td {
            border-color: #C4B59A;
            color: #3D2B1F;
        }
        .cart-img {
            width: 60px;
            height: 60px;
            object-fit: contain;
            border-radius: 8px;
            background: #f8f9fa;
            padding: 5px;
        }
        [data-bs-theme="dark"] .cart-img {
            background: #0f172a;
        }
        [data-bs-theme="sepia"] .cart-img {
            background: #F0E8D4;
        }
        .cart-img-placeholder {
            width: 60px;
            height: 60px;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f8f9fa;
            border-radius: 8px;
            font-size: 1.5rem;
            color: #adb5bd;
        }
        [data-bs-theme="dark"] .cart-img-placeholder {
            background: #0f172a;
        }
        [data-bs-theme="sepia"] .cart-img-placeholder {
            background: #F0E8D4;
        }
        .qty-btn {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            border: 1px solid #dee2e6;
            background: #fff;
            cursor: pointer;
            transition: var(--transition);
            font-weight: 700;
        }
        .qty-btn:hover {
            background: #f1f5f9;
            border-color: #cbd5e1;
        }
        [data-bs-theme="dark"] .qty-btn {
            background: #334155;
            border-color: #475569;
            color: #e2e8f0;
        }
        [data-bs-theme="sepia"] .qty-btn {
            background: #FAF5E8;
            border-color: #C4B59A;
            color: #3D2B1F;
        }
        [data-bs-theme="dark"] .qty-btn:hover {
            background: #475569;
        }
        [data-bs-theme="sepia"] .qty-btn:hover {
            background: #D4C5A9;
        }
        .qty-display {
            display: inline-block;
            min-width: 32px;
            text-align: center;
            font-weight: 600;
        }
        .total-box {
            background: #fff;
            border-radius: var(--card-radius);
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            padding: 24px;
        }
        [data-bs-theme="dark"] .total-box {
            background: #1e293b;
        }
        [data-bs-theme="sepia"] .total-box {
            background: #EDE4CC;
        }
        .total-label {
            font-size: 0.9rem;
            color: #64748b;
        }
        .total-amount {
            font-size: 2rem;
            font-weight: 800;
            color: #1e3c72;
        }
        [data-bs-theme="dark"] .total-amount {
            color: #60a5fa;
        }
        [data-bs-theme="sepia"] .total-amount {
            color: #7A5C2E;
        }
        .btn-checkout {
            border-radius: 50px;
            padding: 12px 32px;
            font-weight: 600;
        }
        .dark-toggle-btn {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.25);
            color: #fff;
            border-radius: 50px;
            padding: 8px 12px;
            cursor: pointer;
            transition: var(--transition);
            line-height: 1;
        }
        .dark-toggle-btn:hover {
            background: rgba(255,255,255,0.25);
        }
        .empty-cart {
            text-align: center;
            padding: 80px 20px;
        }
        .empty-cart i {
            font-size: 5rem;
            color: #cbd5e1;
        }
        .empty-cart h4 {
            color: #64748b;
            margin-top: 16px;
        }
        @media (max-width: 576px) {
            .total-amount { font-size: 1.5rem; }
        }
    </style>
</head>
<body>

<div class="top-bar">
    <div class="container">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <a href="index.php" class="me-3"><i class="bi bi-arrow-left me-1"></i> Tienda</a>
                <span class="text-white-50">|</span>
                <span class="text-white ms-3"><i class="bi bi-cart3 me-1"></i> Carrito de Compras</span>
            </div>
            <div class="d-flex gap-2 align-items-center">
                <button class="dark-toggle-btn" id="darkModeBtn" title="Modo oscuro">
                    <i class="bi bi-moon-fill"></i>
                </button>
                <span class="text-white-50 small">
                    <i class="bi bi-box me-1"></i> <?php echo $cart_count; ?> artículos
                </span>
            </div>
        </div>
    </div>
</div>

<div class="container py-4">

    <?php if (empty($carrito)): ?>
        <div class="empty-cart">
            <i class="bi bi-cart-x"></i>
            <h4>Tu carrito está vacío</h4>
            <p class="text-muted">Agrega productos desde la tienda para comenzar.</p>
            <a href="index.php" class="btn btn-primary btn-lg rounded-pill px-4 mt-2">
                <i class="bi bi-shop me-2"></i> Ir a la Tienda
            </a>
        </div>
    <?php else: ?>

        <div class="row">
            <div class="col-lg-8 mb-4">
                <div class="cart-table">
                    <div class="table-responsive">
                        <table class="table table-hover align-middle mb-0">
                            <thead>
                                <tr>
                                    <th style="width: 80px;"></th>
                                    <th>Producto</th>
                                    <th class="text-center" style="width: 120px;">Precio</th>
                                    <th class="text-center" style="width: 140px;">Cantidad</th>
                                    <th class="text-center" style="width: 100px;">Subtotal</th>
                                    <th style="width: 50px;"></th>
                                </tr>
                            </thead>
                            <tbody>
                                <?php foreach ($carrito as $item): 
                                    $tiene_img = !empty($item['imagen']) && file_exists($ruta_imagenes . $item['imagen']);
                                    $subtotal = $item['precio'] * $item['cantidad'];
                                ?>
                                    <tr data-id="<?php echo $item['id']; ?>">
                                        <td class="text-center">
                                            <?php if ($tiene_img): ?>
                                                <img src="<?php echo $ruta_imagenes . $item['imagen']; ?>" alt="<?php echo htmlspecialchars($item['nombre']); ?>" class="cart-img">
                                            <?php else: ?>
                                                <div class="cart-img-placeholder mx-auto"><i class="bi bi-image"></i></div>
                                            <?php endif; ?>
                                        </td>
                                        <td>
                                            <strong><?php echo htmlspecialchars($item['nombre']); ?></strong>
                                        </td>
                                        <td class="text-center">Bs <?php echo number_format($item['precio'], 2); ?></td>
                                        <td class="text-center">
                                            <div class="d-flex align-items-center justify-content-center gap-1">
                                                <button class="qty-btn" onclick="actualizarCantidad(<?php echo $item['id']; ?>, <?php echo $item['cantidad'] - 1; ?>)">−</button>
                                                <span class="qty-display"><?php echo $item['cantidad']; ?></span>
                                                <button class="qty-btn" onclick="actualizarCantidad(<?php echo $item['id']; ?>, <?php echo $item['cantidad'] + 1; ?>)">+</button>
                                            </div>
                                        </td>
                                        <td class="text-center fw-bold">Bs <?php echo number_format($subtotal, 2); ?></td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-danger border-0" onclick="eliminarItem(<?php echo $item['id']; ?>)" title="Eliminar">
                                                <i class="bi bi-trash3"></i>
                                            </button>
                                        </td>
                                    </tr>
                                <?php endforeach; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="d-flex justify-content-between mt-3">
                    <a href="index.php" class="btn btn-outline-secondary rounded-pill px-4">
                        <i class="bi bi-arrow-left me-1"></i> Seguir Comprando
                    </a>
                    <button class="btn btn-outline-danger rounded-pill px-4" onclick="vaciarCarrito()">
                        <i class="bi bi-cart-x me-1"></i> Vaciar Carrito
                    </button>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="total-box">
                    <h5 class="fw-bold mb-4"><i class="bi bi-receipt me-2"></i>Resumen</h5>
                    <div class="d-flex justify-content-between mb-2">
                        <span class="total-label">Productos:</span>
                        <span><?php echo count($carrito); ?> artículos</span>
                    </div>
                    <div class="d-flex justify-content-between mb-3">
                        <span class="total-label">Subtotal:</span>
                        <span class="fw-semibold">Bs <?php echo number_format($total, 2); ?></span>
                    </div>
                    <hr>
                    <div class="d-flex justify-content-between mb-4">
                        <span class="total-label fw-bold">Total:</span>
                        <span class="total-amount">Bs <?php echo number_format($total, 2); ?></span>
                    </div>
                    <a href="checkout.php" class="btn btn-primary btn-checkout w-100">
                        <i class="bi bi-credit-card me-2"></i> Pasar a Caja
                    </a>
                </div>
            </div>
        </div>

    <?php endif; ?>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function actualizarCantidad(id, cantidad) {
    if (cantidad < 1) return;
    fetch('carrito.php?action=update&id=' + id + '&cantidad=' + cantidad)
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                location.reload();
            }
        });
}

function eliminarItem(id) {
    showConfirmModal('¿Eliminar este producto del carrito?', function() {
        fetch('carrito.php?action=remove&id=' + id)
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                }
            });
    });
}

function vaciarCarrito() {
    showConfirmModal('¿Vaciar todo el carrito?', function() {
        fetch('carrito.php?action=clear')
            .then(r => r.json())
            .then(data => {
                if (data.success) {
                    location.reload();
                }
            });
    });
}

(function() {
    var temas = ['light', 'sepia', 'dark'];
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
