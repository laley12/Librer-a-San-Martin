<?php
session_start();
include("../config/conexion.php");

$pedido = null;
$buscado = false;

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['codigo'])) {
    $buscado = true;
    $codigo = mysqli_real_escape_string($conexion, trim($_POST['codigo']));
    $res = mysqli_query($conexion, "SELECT p.*, s.nombre AS sucursal_nombre, s.direccion AS sucursal_direccion
                                    FROM pedidos p
                                    LEFT JOIN sucursales s ON p.sucursal_id = s.id_sucursal
                                    WHERE p.codigo_seguimiento = '$codigo'
                                    LIMIT 1");
    if ($res && mysqli_num_rows($res) > 0) {
        $pedido = mysqli_fetch_assoc($res);

        $detalle = mysqli_query($conexion, "SELECT dp.*, pr.nombre_producto AS producto_nombre
                                            FROM detalle_pedidos dp
                                            LEFT JOIN productos pr ON dp.producto_id = pr.id_producto
                                            WHERE dp.pedido_id = " . intval($pedido['id_pedido']));
    }
}

$badge_class = [
    'Pendiente' => 'bg-warning text-dark',
    'Confirmado' => 'bg-info text-dark',
    'En preparación' => 'bg-primary',
    'Listo' => 'bg-success',
    'Entregado' => 'bg-secondary',
    'Cancelado' => 'bg-danger',
];
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Rastrear Pedido - Librería San Martín</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="/includes/base.css">
<style>
body { background: #f8f9fa; font-family: 'Segoe UI', system-ui, sans-serif; }
.rastrear-container { max-width: 650px; margin: 60px auto; }
.card { border-radius: 16px; border: none; box-shadow: 0 4px 20px rgba(0,0,0,0.06); }
.card-body { padding: 28px; }
.form-control { border-radius: 10px; padding: 12px 16px; border: 1.5px solid #e0e0e0; }
.form-control:focus { border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13,110,253,0.12); }
.btn-primary { border-radius: 10px; padding: 12px 28px; font-weight: 600; }
.info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }
.info-row:last-child { border-bottom: none; }
.info-label { color: #6b7280; font-weight: 500; }
.info-value { font-weight: 600; color: #1f2937; }
</style>
</head>
<body>
<div class="rastrear-container">
    <div class="text-center mb-4">
        <a href="index.php" class="text-decoration-none text-muted">&larr; Volver a la tienda</a>
        <h3 class="fw-bold mt-2">Rastrear Pedido</h3>
        <p class="text-muted">Ingrese el código de seguimiento de su pedido</p>
    </div>

    <div class="card mb-4">
        <div class="card-body">
            <form method="POST">
                <div class="input-group">
                    <input type="text" name="codigo" class="form-control" placeholder="Ej: PED-AB12CD-0001" value="<?php echo htmlspecialchars($_POST['codigo'] ?? ''); ?>" required>
                    <button type="submit" class="btn btn-primary">Buscar</button>
                </div>
            </form>
        </div>
    </div>

    <?php if ($buscado): ?>
        <?php if ($pedido): ?>
            <div class="card">
                <div class="card-body">
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="fw-bold mb-0"><?php echo htmlspecialchars($pedido['codigo_seguimiento']); ?></h5>
                        <span class="badge rounded-pill <?php echo $badge_class[$pedido['estado']] ?? 'bg-secondary'; ?> fs-6 px-3 py-2"><?php echo htmlspecialchars($pedido['estado']); ?></span>
                    </div>

                    <div class="bg-light rounded-4 p-3 mb-3">
                        <div class="info-row"><span class="info-label">Cliente</span><span class="info-value"><?php echo htmlspecialchars($pedido['cliente_nombre']); ?></span></div>
                        <div class="info-row"><span class="info-label">Teléfono</span><span class="info-value"><?php echo htmlspecialchars($pedido['cliente_telefono']); ?></span></div>
                        <div class="info-row"><span class="info-label">Sucursal</span><span class="info-value"><?php echo htmlspecialchars($pedido['sucursal_nombre'] ?? '—'); ?></span></div>
                        <div class="info-row"><span class="info-label">Método de pago</span><span class="info-value"><?php echo htmlspecialchars($pedido['metodo_pago']); ?></span></div>
                        <div class="info-row"><span class="info-label">Total</span><span class="info-value fw-bold">Bs <?php echo number_format($pedido['total'], 2); ?></span></div>
                        <?php if ($pedido['notas']): ?>
                            <div class="info-row"><span class="info-label">Notas</span><span class="info-value"><?php echo htmlspecialchars($pedido['notas']); ?></span></div>
                        <?php endif; ?>
                    </div>

                    <h6 class="fw-bold mb-2">Productos</h6>
                    <div class="table-responsive">
                        <table class="table table-sm table-borderless">
                            <thead class="text-muted small">
                                <tr><th>Producto</th><th class="text-center">Cant</th><th class="text-end">Precio</th><th class="text-end">Subtotal</th></tr>
                            </thead>
                            <tbody>
                                <?php while ($d = mysqli_fetch_assoc($detalle)): ?>
                                    <tr>
                                        <td><?php echo htmlspecialchars($d['producto_nombre'] ?? 'Producto #' . $d['producto_id']); ?></td>
                                        <td class="text-center"><?php echo intval($d['cantidad']); ?></td>
                                        <td class="text-end">Bs <?php echo number_format($d['precio'], 2); ?></td>
                                        <td class="text-end fw-semibold">Bs <?php echo number_format($d['cantidad'] * $d['precio'], 2); ?></td>
                                    </tr>
                                <?php endwhile; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        <?php else: ?>
            <div class="card">
                <div class="card-body text-center py-5">
                    <p class="fs-5 fw-semibold text-danger mb-0">Código no válido</p>
                    <p class="text-muted">No se encontró ningún pedido con ese código. Verifique e intente nuevamente.</p>
                </div>
            </div>
        <?php endif; ?>
    <?php endif; ?>
</div>
</body>
</html>
