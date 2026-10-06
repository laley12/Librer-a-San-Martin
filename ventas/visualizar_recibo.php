<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id_venta = isset($_GET['id']) ? intval($_GET['id']) : 0;
if(!$id_venta){ echo "ID de venta inválido"; exit(); }

$venta = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT v.*, cl.nombre_cliente, cl.ci_nit, cl.telefono
    FROM ventas v LEFT JOIN clientes cl ON v.id_cliente = cl.id_cliente WHERE v.id_venta = $id_venta"));

if(!$venta){ echo "Venta no encontrada"; exit(); }

$detalles = mysqli_query($conexion, "SELECT dv.*, p.nombre_producto, p.codigo
    FROM detalle_ventas dv INNER JOIN productos p ON dv.producto_id = p.id_producto WHERE dv.venta_id = $id_venta");

$recibo = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT * FROM recibos WHERE venta_id = $id_venta"));
$numero_recibo = $recibo ? $recibo['numero_recibo'] : 'REC-' . str_pad($id_venta, 6, '0', STR_PAD_LEFT);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Recibo #<?php echo $numero_recibo; ?> - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
body { background: #f0f3f8; font-family: 'Courier New', monospace; }
.receipt { max-width: 400px; margin: 30px auto; background: #fff; border-radius: 12px; box-shadow: 0 8px 30px rgba(0,0,0,0.08); padding: 30px; }
.receipt-header { text-align: center; border-bottom: 2px dashed #dee2e6; padding-bottom: 15px; margin-bottom: 15px; }
.receipt-title { font-size: 1.3rem; font-weight: 800; color: #1e3c72; }
.receipt-line { display: flex; justify-content: space-between; padding: 3px 0; font-size: 0.9rem; }
.receipt-items { border-top: 1px dashed #dee2e6; border-bottom: 2px dashed #dee2e6; padding: 10px 0; margin: 10px 0; }
.receipt-total { font-size: 1.2rem; font-weight: 800; color: #198754; text-align: right; border-top: 1px solid #dee2e6; padding-top: 10px; margin-top: 5px; }
.receipt-footer { text-align: center; font-size: 0.8rem; color: #6c757d; margin-top: 15px; border-top: 2px dashed #dee2e6; padding-top: 15px; }
.status-badge { font-size: 0.7rem; padding: 2px 10px; }
.corte-line { text-align: center; font-size: 0.8rem; color: #6c757d; letter-spacing: 3px; margin-top: 10px; }
@media print { body { background: #fff; } .receipt { box-shadow: none; margin: 0; border-radius: 0; padding: 20px; max-width: 100%; font-family: 'Courier New', Courier, monospace; } .no-print { display: none !important; } header, nav, .sidebar, .topbar, .main-content > .topbar, .main-content > .container-fluid > .panel-custom > .panel-custom-header, .main-content > .container-fluid > .panel-custom > .panel-custom-body > .text-center.mt-3.mb-0 { display: none !important; } .main-content { margin-left: 0 !important; } .container-fluid { padding: 0 !important; } }
    </style>
</head>
<body>
    <div class="no-print text-center mt-3 mb-0">
        <a href="index.php" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Volver</a>
        <button class="btn btn-primary btn-sm" onclick="window.print()"><i class="bi bi-printer"></i> Imprimir</button>
    </div>
    <div class="receipt">
        <div class="receipt-header">
            <div class="receipt-title">📚 Librería San Martín</div>
            <div style="font-size:0.8rem;color:#6c757d;">Sistema de Gestión de Ventas</div>
            <div class="mt-2"><span class="badge bg-dark fs-6"><?php echo htmlspecialchars($numero_recibo); ?></span></div>
        </div>

        <div class="receipt-line"><span class="text-muted">Fecha:</span><span><?php echo $venta['fecha']; ?></span></div>
        <div class="receipt-line"><span class="text-muted">Hora:</span><span><?php echo date('h:i A'); ?></span></div>
        <div class="receipt-line"><span class="text-muted">Método Pago:</span>
            <span class="badge <?php echo $venta['metodo_pago'] === 'Efectivo' ? 'bg-success' : 'bg-info text-dark'; ?> status-badge">
                <?php echo htmlspecialchars($venta['metodo_pago'] ?? 'Efectivo'); ?>
            </span>
        </div>
        <div class="receipt-line"><span class="text-muted">Estado:</span>
            <span class="badge <?php echo ($venta['estado'] ?? 'Completado') === 'Completado' ? 'bg-success' : 'bg-warning text-dark'; ?> status-badge">
                <?php echo ($venta['estado'] ?? 'Completado') === 'Completado' ? 'Pagado' : 'Pendiente'; ?>
            </span>
        </div>
        <div class="receipt-line"><span class="text-muted">Cliente:</span>
            <span><?php echo !empty($venta['nombre_cliente']) ? htmlspecialchars($venta['nombre_cliente']) : 'Eventual'; ?></span>
        </div>
        <?php if(!empty($venta['ci_nit'])): ?>
        <div class="receipt-line"><span class="text-muted">CI/NIT:</span><span><?php echo htmlspecialchars($venta['ci_nit']); ?></span></div>
        <?php endif; ?>

        <div class="receipt-items">
            <div class="fw-bold mb-2" style="font-size:0.85rem;">DETALLE DE COMPRA</div>
            <?php $num = 1; $subtotal = 0; while($d = mysqli_fetch_assoc($detalles)): ?>
            <div class="receipt-line"><span><?php echo $num++; ?>. <?php echo htmlspecialchars($d['nombre_producto']); ?></span></div>
            <div class="receipt-line" style="font-size:0.8rem;padding-left:15px;">
                <span><?php echo $d['cantidad']; ?> x Bs. <?php echo number_format($d['precio'],2); ?></span>
                <span>Bs. <?php echo number_format($d['cantidad'] * $d['precio'],2); ?></span>
            </div>
            <?php $subtotal += $d['cantidad'] * $d['precio']; endwhile; ?>
        </div>

        <div class="receipt-total">
            TOTAL: Bs. <?php echo number_format($venta['total'],2); ?>
        </div>

        <?php if($venta['metodo_pago'] === 'Transferencia QR' && file_exists('../assets/uploads/qr/qr_pago.png')): ?>
        <div class="text-center mt-3 pt-3" style="border-top:1px dashed #dee2e6;">
            <p class="small text-muted mb-1">Escanea para pagar</p>
            <img src="../assets/uploads/qr/qr_pago.png" style="width:120px;height:120px;border-radius:8px;border:1px solid #dee2e6;">
        </div>
        <?php endif; ?>

        <div class="receipt-footer">
            ¡Gracias por su compra!<br>
            <span style="font-size:0.7rem;"><?php echo $numero_recibo; ?> | <?php echo date('d/m/Y h:i A'); ?></span>
        </div>
        <div class="corte-line">- - - - - - - - - - - - - - -</div>
    </div>
</body>
</html>
