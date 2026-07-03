<?php
session_start();
header('Content-Type: application/json');
include("../config/conexion.php");

if (!isset($_SESSION['id'])) {
    echo json_encode(['success' => false, 'error' => 'No autorizado']);
    exit();
}

$nombre_cliente = mysqli_real_escape_string($conexion, $_POST['nombre_cliente'] ?? '');
$ci_nit = mysqli_real_escape_string($conexion, $_POST['ci_nit'] ?? '');
$telefono = mysqli_real_escape_string($conexion, $_POST['telefono'] ?? '');

if (!$nombre_cliente) {
    echo json_encode(['success' => false, 'error' => 'Nombre requerido']);
    exit();
}

mysqli_query($conexion, "INSERT INTO clientes (nombre_cliente, ci_nit, telefono) VALUES ('$nombre_cliente', '$ci_nit', '$telefono')");
$id = mysqli_insert_id($conexion);

$id_user = intval($_SESSION['id']);
mysqli_query($conexion, "INSERT INTO auditoria_clientes (id_usuario, accion) VALUES ($id_user, 'Registró nuevo cliente ID $id desde venta')");

echo json_encode(['success' => true, 'id_cliente' => $id, 'nombre_cliente' => $nombre_cliente]);
exit();
?>
