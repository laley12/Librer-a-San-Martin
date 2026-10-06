<?php
header('Content-Type: application/json');
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if (!isset($_SESSION['id'])) {
    echo json_encode(['success' => false, 'message' => 'No autorizado']);
    exit();
}

if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
    echo json_encode(['success' => false, 'message' => 'Error de seguridad']);
    exit();
}

$id_producto = intval($_POST['id_producto'] ?? 0);
$precio_compra = floatval($_POST['precio_compra'] ?? 0);
$precio_venta = floatval($_POST['precio'] ?? 0);

if ($id_producto <= 0) {
    echo json_encode(['success' => false, 'message' => 'ID de producto inválido']);
    exit();
}

// Get current values
$cur = mysqli_query($conexion, "SELECT precio, precio_compra FROM productos WHERE id_producto = $id_producto AND activo = 1");
$cur_f = $cur ? mysqli_fetch_assoc($cur) : null;
if (!$cur_f) {
    echo json_encode(['success' => false, 'message' => 'Producto no encontrado']);
    exit();
}

$old_compra = floatval($cur_f['precio_compra'] ?? 0);
$old_venta = floatval($cur_f['precio'] ?? 0);

// Update
$sql = "UPDATE productos SET precio_compra = $precio_compra, precio = $precio_venta WHERE id_producto = $id_producto";
if (!mysqli_query($conexion, $sql)) {
    echo json_encode(['success' => false, 'message' => 'Error BD: ' . mysqli_error($conexion)]);
    exit();
}

// Record price history
$id_user = intval($_SESSION['id']);
if ($old_compra != $precio_compra) {
    mysqli_query($conexion, "INSERT INTO historial_precios (id_producto, precio_anterior, precio_nuevo, tipo, id_usuario) 
                             VALUES ($id_producto, $old_compra, $precio_compra, 'compra', $id_user)");
}
if ($old_venta != $precio_venta) {
    mysqli_query($conexion, "INSERT INTO historial_precios (id_producto, precio_anterior, precio_nuevo, tipo, id_usuario) 
                             VALUES ($id_producto, $old_venta, $precio_venta, 'venta', $id_user)");
}

echo json_encode(['success' => true, 'message' => 'Precio actualizado correctamente']);
?>