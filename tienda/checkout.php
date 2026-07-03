<?php
session_start();
include("../config/conexion.php");

if (empty($_SESSION['carrito'])) {
    header("Location: index.php");
    exit;
}

$sucursales = mysqli_query($conexion, "SELECT id_sucursal, nombre, direccion, telefono FROM sucursales WHERE activo = 1");

$total = 0;
foreach ($_SESSION['carrito'] as $item) {
    $total += $item['precio'] * $item['cantidad'];
}

$errores = [];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nombre = trim($_POST['nombre'] ?? '');
    $telefono = trim($_POST['telefono'] ?? '');
    $sucursal_id = intval($_POST['sucursal_id'] ?? 0);
    $metodo_pago = $_POST['metodo_pago'] ?? 'Efectivo';
    $notas = trim($_POST['notas'] ?? '');

    if ($nombre === '') $errores[] = 'El nombre es obligatorio.';
    if ($telefono === '') $errores[] = 'El teléfono es obligatorio.';
    if ($sucursal_id <= 0) $errores[] = 'Seleccione una sucursal.';

    if (empty($errores)) {
        $nombre = mysqli_real_escape_string($conexion, $nombre);
        $telefono = mysqli_real_escape_string($conexion, $telefono);
        $notas = mysqli_real_escape_string($conexion, $notas);
        $metodo_pago = mysqli_real_escape_string($conexion, $metodo_pago);

        $res = mysqli_query($conexion, "SELECT COALESCE(MAX(id_pedido), 0) + 1 AS next_id FROM pedidos");
        $row = mysqli_fetch_assoc($res);
        $next_id = $row['next_id'];
        $codigo_seguimiento = 'PED-' . strtoupper(substr(uniqid(), -6)) . '-' . str_pad($next_id, 4, '0', STR_PAD_LEFT);

        $sql_pedido = "INSERT INTO pedidos (cliente_nombre, cliente_telefono, sucursal_id, metodo_pago, estado, total, codigo_seguimiento, notas)
                       VALUES ('$nombre', '$telefono', $sucursal_id, '$metodo_pago', 'Pendiente', $total, '$codigo_seguimiento', '$notas')";
        mysqli_query($conexion, $sql_pedido);
        $pedido_id = mysqli_insert_id($conexion);

        foreach ($_SESSION['carrito'] as $item) {
            $prod_id = intval($item['id']);
            $cant = intval($item['cantidad']);
            $precio = floatval($item['precio']);
            mysqli_query($conexion, "INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio) VALUES ($pedido_id, $prod_id, $cant, $precio)");
        }

        unset($_SESSION['carrito']);
        header("Location: pedido_exitoso.php?codigo=$codigo_seguimiento");
        exit;
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Checkout - Librería San Martín</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
body { background: #f8f9fa; font-family: 'Segoe UI', system-ui, sans-serif; }
.checkout-container { max-width: 1100px; margin: 40px auto; }
.card { border-radius: 16px; border: none; box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
.card-header { background: transparent; border-bottom: 1px solid #eee; font-weight: 700; font-size: 1.1rem; padding: 18px 24px; }
.card-body { padding: 24px; }
.form-label { font-weight: 600; font-size: 0.9rem; color: #333; }
.form-control, .form-select { border-radius: 10px; padding: 10px 14px; border: 1.5px solid #e0e0e0; }
.form-control:focus, .form-select:focus { border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13,110,253,0.12); }
.btn-primary { border-radius: 10px; padding: 12px 24px; font-weight: 600; }
.btn-outline-secondary { border-radius: 10px; }
.cart-item { border-bottom: 1px solid #f0f0f0; padding: 10px 0; }
.cart-item:last-child { border-bottom: none; }
.cart-total-row { font-weight: 700; font-size: 1.1rem; border-top: 2px solid #dee2e6; padding-top: 14px; margin-top: 8px; }
.qr-preview { text-align: center; padding: 20px 0; }
#qrCanvas { margin: 0 auto; }
</style>
</head>
<body>

<div class="checkout-container">
    <div class="text-center mb-4">
        <a href="index.php" class="text-decoration-none text-muted">&larr; Volver a la tienda</a>
        <h2 class="mt-2 fw-bold">Finalizar Pedido</h2>
    </div>

    <?php if (!empty($errores)): ?>
        <div class="alert alert-danger alert-dismissible fade show rounded-4" role="alert">
            <ul class="mb-0"><?php foreach ($errores as $e): ?><li><?php echo htmlspecialchars($e); ?></li><?php endforeach; ?></ul>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <?php endif; ?>

    <div class="row g-4">
        <div class="col-lg-7">
            <form method="POST" id="checkoutForm">
                <div class="card mb-4">
                    <div class="card-header">Información del Cliente</div>
                    <div class="card-body">
                        <div class="mb-3">
                            <label class="form-label">Nombre completo <span class="text-danger">*</span></label>
                            <input type="text" name="nombre" class="form-control" placeholder="Ej: Juan Pérez" value="<?php echo htmlspecialchars($_POST['nombre'] ?? ''); ?>" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label">Teléfono <span class="text-danger">*</span></label>
                            <input type="text" name="telefono" class="form-control" placeholder="Ej: 71234567" value="<?php echo htmlspecialchars($_POST['telefono'] ?? ''); ?>" required>
                        </div>
                    </div>
                </div>

                <div class="card mb-4">
                    <div class="card-header">Sucursal para recoger</div>
                    <div class="card-body">
                        <select name="sucursal_id" class="form-select" required>
                            <option value="">Seleccione una sucursal...</option>
                            <?php while ($s = mysqli_fetch_assoc($sucursales)): ?>
                                <option value="<?php echo $s['id_sucursal']; ?>" <?php echo (isset($_POST['sucursal_id']) && intval($_POST['sucursal_id']) === intval($s['id_sucursal'])) ? 'selected' : ''; ?>>
                                    <?php echo htmlspecialchars($s['nombre'] . ' - ' . $s['direccion'] . ' (Tel: ' . $s['telefono'] . ')'); ?>
                                </option>
                            <?php endwhile; ?>
                        </select>
                    </div>
                </div>

                <div class="card mb-4">
                    <div class="card-header">Método de Pago</div>
                    <div class="card-body">
                        <div class="d-flex gap-4">
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="metodo_pago" value="Efectivo" id="pagoEfectivo" <?php echo (!isset($_POST['metodo_pago']) || $_POST['metodo_pago'] === 'Efectivo') ? 'checked' : ''; ?>>
                                <label class="form-check-label fw-medium" for="pagoEfectivo">Efectivo</label>
                            </div>
                            <div class="form-check">
                                <input class="form-check-input" type="radio" name="metodo_pago" value="Transferencia QR" id="pagoQR" <?php echo (isset($_POST['metodo_pago']) && $_POST['metodo_pago'] === 'Transferencia QR') ? 'checked' : ''; ?>>
                                <label class="form-check-label fw-medium" for="pagoQR">Transferencia QR</label>
                            </div>
                        </div>

                        <div id="qrPreview" class="qr-preview" style="display:none;">
                            <canvas id="qrCanvas" width="200" height="200"></canvas>
                            <p class="mt-2 mb-0 text-muted small">Escaneé el código QR para realizar el pago</p>
                        </div>
                    </div>
                </div>

                <div class="card mb-4">
                    <div class="card-header">Notas (opcional)</div>
                    <div class="card-body">
                        <textarea name="notas" class="form-control" rows="3" placeholder="Alguna observación..."><?php echo htmlspecialchars($_POST['notas'] ?? ''); ?></textarea>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary w-100 btn-lg">Confirmar Pedido</button>
            </form>
        </div>

        <div class="col-lg-5">
            <div class="card">
                <div class="card-header">Resumen del Pedido</div>
                <div class="card-body">
                    <?php foreach ($_SESSION['carrito'] as $item): ?>
                        <div class="cart-item d-flex justify-content-between align-items-center">
                            <div>
                                <strong><?php echo htmlspecialchars($item['nombre']); ?></strong>
                                <div class="text-muted small">Cant: <?php echo intval($item['cantidad']); ?> x Bs <?php echo number_format($item['precio'], 2); ?></div>
                            </div>
                            <span class="fw-semibold">Bs <?php echo number_format($item['precio'] * $item['cantidad'], 2); ?></span>
                        </div>
                    <?php endforeach; ?>
                    <div class="cart-total-row d-flex justify-content-between">
                        <span>Total</span>
                        <span>Bs <?php echo number_format($total, 2); ?></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/qrious@4.0.2/dist/qrious.min.js"></script>
<script>
(function() {
    const qrRadio = document.getElementById('pagoQR');
    const efectivoRadio = document.getElementById('pagoEfectivo');
    const qrPreview = document.getElementById('qrPreview');
    const total = <?php echo json_encode(number_format($total, 2)); ?>;
    const ref = 'PED-' + Date.now().toString(36).toUpperCase().slice(-6);
    let qr = null;

    function toggleQR() {
        if (qrRadio.checked) {
            qrPreview.style.display = 'block';
            if (!qr) {
                qr = new QRious({
                    element: document.getElementById('qrCanvas'),
                    size: 200,
                    value: 'PEDIDO QR | Librer\u00eda San Mart\u00edn | Bs ' + total + ' | Ref: ' + ref
                });
            }
        } else {
            qrPreview.style.display = 'none';
        }
    }

    qrRadio.addEventListener('change', toggleQR);
    efectivoRadio.addEventListener('change', toggleQR);
    toggleQR();
})();
</script>
</body>
</html>
