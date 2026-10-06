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
    <title>Imprimir Recibo #<?php echo $numero_recibo; ?></title>
<link rel="stylesheet" href="/includes/base.css">
    <style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { font-family: 'Courier New', Courier, monospace; width: 80mm; margin: 0 auto; padding: 10px 5px; font-size: 12px; line-height: 1.4; color: #000; }
.header { text-align: center; margin-bottom: 10px; }
.header h2 { font-size: 16px; font-weight: 800; }
.header .sub { font-size: 10px; }
.recibo-num { text-align: center; font-size: 14px; font-weight: 700; margin: 5px 0; letter-spacing: 1px; }
.line { border-top: 1px dashed #000; margin: 5px 0; }
.row { display: flex; justify-content: space-between; }
.items { margin: 5px 0; }
.item { margin-bottom: 3px; }
.item-name { font-size: 11px; }
.item-detail { display: flex; justify-content: space-between; font-size: 11px; padding-left: 10px; }
.total { font-size: 14px; font-weight: 800; text-align: right; border-top: 1px solid #000; padding-top: 5px; margin-top: 5px; }
.footer { text-align: center; font-size: 10px; margin-top: 10px; }
.corte { text-align: center; font-size: 10px; letter-spacing: 3px; margin-top: 5px; }
.qr-img { text-align: center; margin: 5px 0; }
.qr-img img { width: 80px; height: 80px; }
@media print {
            body { width: 80mm; }
            .no-print { display: none; }
        }
.no-print { text-align: center; margin-bottom: 10px; }
    </style>
</head>
<body>
    <div class="no-print">
        <button onclick="window.print()" style="padding:8px 20px;font-size:14px;cursor:pointer;"><strong>Imprimir</strong></button>
        <button onclick="window.close()" style="padding:8px 20px;font-size:14px;cursor:pointer;">Cerrar</button>
    </div>

    <div class="header">
        <h2>LIBRERÍA SAN MARTÍN</h2>
        <div class="sub">Sistema de Gestión de Ventas</div>
    </div>
    <div class="recibo-num"><?php echo htmlspecialchars($numero_recibo); ?></div>
    <div class="line"></div>
    <div class="row"><span>Fecha:</span><span><?php echo $venta['fecha']; ?></span></div>
    <div class="row"><span>Hora:</span><span><?php echo date('h:i A'); ?></span></div>
    <div class="row"><span>Pago:</span><span><?php echo htmlspecialchars($venta['metodo_pago'] ?? 'Efectivo'); ?></span></div>
    <div class="row"><span>Cliente:</span><span><?php echo !empty($venta['nombre_cliente']) ? htmlspecialchars($venta['nombre_cliente']) : 'Eventual'; ?></span></div>
    <?php if(!empty($venta['ci_nit'])): ?>
    <div class="row"><span>NIT:</span><span><?php echo htmlspecialchars($venta['ci_nit']); ?></span></div>
    <?php endif; ?>
    <div class="line"></div>
    <div class="items">
        <?php $num = 1; while($d = mysqli_fetch_assoc($detalles)): ?>
        <div class="item">
            <div class="item-name"><?php echo $num++; ?>. <?php echo htmlspecialchars($d['nombre_producto']); ?></div>
            <div class="item-detail">
                <span><?php echo $d['cantidad']; ?> x Bs. <?php echo number_format($d['precio'], 2); ?></span>
                <span>Bs. <?php echo number_format($d['cantidad'] * $d['precio'], 2); ?></span>
            </div>
        </div>
        <?php endwhile; ?>
    </div>
    <div class="line"></div>
    <div class="total">TOTAL: Bs. <?php echo number_format($venta['total'], 2); ?></div>

    <?php if($venta['metodo_pago'] === 'Transferencia QR' && file_exists('../assets/uploads/qr/qr_pago.png')): ?>
    <div class="qr-img">
        <img src="../assets/uploads/qr/qr_pago.png">
        <div style="font-size:9px;">Escanea para pagar</div>
    </div>
    <?php endif; ?>

    <div class="footer">
        ¡Gracias por su compra!<br>
        <?php echo $numero_recibo; ?> | <?php echo date('d/m/Y h:i A'); ?>
    </div>
    <div class="corte">- - - - - - - - - - - - - - -</div>

    <script>
        window.onload = function() {
            window.print();
            setTimeout(function() { window.close(); }, 500);
        };
    </script>
</body>
</html>
