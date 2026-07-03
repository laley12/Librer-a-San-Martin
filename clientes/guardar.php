<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !verificarCsrf($_POST['csrf_token'] ?? '')) {
    die('Error de seguridad');
}

$id_cliente = isset($_POST['id_cliente']) ? intval($_POST['id_cliente']) : 0;
$nombre_cliente = mysqli_real_escape_string($conexion, $_POST['nombre_cliente']);
$ci_nit = mysqli_real_escape_string($conexion, $_POST['ci_nit']);
$telefono = mysqli_real_escape_string($conexion, $_POST['telefono'] ?? '');
$fecha_nacimiento = !empty($_POST['fecha_nacimiento']) ? "'".mysqli_real_escape_string($conexion, $_POST['fecha_nacimiento'])."'" : "NULL";
$id_user = intval($_SESSION['id']);

if ($id_cliente > 0) {
    $sql = "UPDATE clientes SET nombre_cliente='$nombre_cliente', ci_nit='$ci_nit', telefono='$telefono', fecha_nacimiento=$fecha_nacimiento WHERE id_cliente=$id_cliente";
    mysqli_query($conexion, $sql);
    mysqli_query($conexion, "INSERT INTO auditoria_clientes (id_usuario, accion) VALUES ($id_user, 'Editó cliente ID $id_cliente')");
} else {
    $sql = "INSERT INTO clientes (nombre_cliente, ci_nit, telefono, fecha_nacimiento) VALUES ('$nombre_cliente', '$ci_nit', '$telefono', $fecha_nacimiento)";
    mysqli_query($conexion, $sql);
    $id_cliente = mysqli_insert_id($conexion);
    mysqli_query($conexion, "INSERT INTO auditoria_clientes (id_usuario, accion) VALUES ($id_user, 'Registró nuevo cliente ID $id_cliente')");
}

header("Location: index.php");
exit();
?>
