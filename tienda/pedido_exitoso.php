<?php
session_start();
include("../config/conexion.php");

$codigo = $_GET['codigo'] ?? '';
$pedido = null;

if ($codigo !== '') {
    $codigo = mysqli_real_escape_string($conexion, $codigo);
    $res = mysqli_query($conexion, "SELECT p.*, s.nombre AS sucursal_nombre, s.direccion AS sucursal_direccion
                                    FROM pedidos p
                                    LEFT JOIN sucursales s ON p.sucursal_id = s.id_sucursal
                                    WHERE p.codigo_seguimiento = '$codigo'
                                    LIMIT 1");
    if ($res && mysqli_num_rows($res) > 0) {
        $pedido = mysqli_fetch_assoc($res);
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Pedido Registrado - Librería San Martín</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
body { background: #f8f9fa; font-family: 'Segoe UI', system-ui, sans-serif; display: flex; align-items: center; min-height: 100vh; }
.success-container { max-width: 600px; margin: 40px auto; }
.card { border-radius: 20px; border: none; box-shadow: 0 8px 30px rgba(0,0,0,0.08); }
.check-icon { width: 72px; height: 72px; border-radius: 50%; background: #d1fae5; display: flex; align-items: center; justify-content: center; margin: 0 auto 16px; }
.check-icon svg { width: 36px; height: 36px; stroke: #059669; }
.codigo-display { background: #f0fdf4; border: 2px dashed #86efac; border-radius: 12px; padding: 16px; font-size: 1.5rem; font-weight: 700; letter-spacing: 1px; color: #166534; text-align: center; }
.info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #f0f0f0; }
.info-row:last-child { border-bottom: none; }
.info-label { color: #6b7280; font-weight: 500; }
.info-value { font-weight: 600; color: #1f2937; }
</style>
</head>
<body>
<div class="success-container">
    <?php if ($pedido): ?>
        <div class="card">
            <div class="card-body p-5 text-center">
                <div class="check-icon">
                    <svg fill="none" viewBox="0 0 24 24" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M4.5 12.75l6 6 9-13.5"/></svg>
                </div>
                <h3 class="fw-bold text-success mb-1">¡Pedido Registrado!</h3>
                <p class="text-muted mb-4">Tu pedido ha sido procesado correctamente.</p>

                <div class="codigo-display mb-4"><?php echo htmlspecialchars($pedido['codigo_seguimiento']); ?></div>

                <div class="text-start bg-light rounded-4 p-4 mb-4">
                    <div class="info-row"><span class="info-label">Cliente</span><span class="info-value"><?php echo htmlspecialchars($pedido['cliente_nombre']); ?></span></div>
                    <div class="info-row"><span class="info-label">Teléfono</span><span class="info-value"><?php echo htmlspecialchars($pedido['cliente_telefono']); ?></span></div>
                    <div class="info-row"><span class="info-label">Sucursal</span><span class="info-value"><?php echo htmlspecialchars($pedido['sucursal_nombre'] ?? '—'); ?></span></div>
                    <div class="info-row"><span class="info-label">Total</span><span class="info-value">Bs <?php echo number_format($pedido['total'], 2); ?></span></div>
                    <div class="info-row"><span class="info-label">Método de pago</span><span class="info-value"><?php echo htmlspecialchars($pedido['metodo_pago']); ?></span></div>
                </div>

                <p class="text-muted mb-4">Su pedido ha sido enviado a la sucursal seleccionada. Pase a recogerlo.</p>

                <div class="d-flex gap-3 justify-content-center">
                    <a href="rastrear.php" class="btn btn-outline-primary rounded-pill px-4">Ver mis pedidos</a>
                    <a href="index.php" class="btn btn-primary rounded-pill px-4">Seguir Comprando</a>
                </div>
            </div>
        </div>
    <?php else: ?>
        <div class="card">
            <div class="card-body p-5 text-center">
                <div class="check-icon" style="background:#fee2e2;">
                    <svg fill="none" viewBox="0 0 24 24" stroke-width="2.5" style="stroke:#dc2626;"><path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12"/></svg>
                </div>
                <h3 class="fw-bold text-danger mb-1">Pedido no encontrado</h3>
                <p class="text-muted mb-4">El código de seguimiento ingresado no es válido o no existe.</p>
                <a href="rastrear.php" class="btn btn-primary rounded-pill px-4">Intentar de nuevo</a>
            </div>
        </div>
    <?php endif; ?>
</div>
</body>
</html>
