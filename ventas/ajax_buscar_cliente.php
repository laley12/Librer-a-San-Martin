<?php
session_start();
include("../config/conexion.php");

header('Content-Type: application/json');

if (!isset($_SESSION['id'])) {
    echo json_encode([]);
    exit();
}

$q = trim($_GET['q'] ?? '');
if (strlen($q) < 1) {
    echo json_encode([]);
    exit();
}

$q = mysqli_real_escape_string($conexion, $q);
$r = mysqli_query($conexion, "SELECT id_cliente, nombre_cliente, ci_nit, telefono FROM clientes WHERE activo=1 AND (nombre_cliente LIKE '%$q%' OR ci_nit LIKE '%$q%') ORDER BY nombre_cliente ASC LIMIT 10");

$resultados = [];
while ($f = mysqli_fetch_assoc($r)) {
    $resultados[] = $f;
}

echo json_encode($resultados);
?>
