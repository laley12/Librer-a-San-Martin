<?php
session_start();
include("../config/conexion.php");

if (!isset($_SESSION['id'])) {
    header("Location: ../login/login.php");
    exit();
}

if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['pedido_id'], $_POST['estado'])) {
    $pedido_id = intval($_POST['pedido_id']);
    $estado = mysqli_real_escape_string($conexion, $_POST['estado']);
    $id_usuario = intval($_SESSION['id']);

    mysqli_query($conexion, "UPDATE pedidos SET estado = '$estado' WHERE id_pedido = $pedido_id");

    $accion = "Pedido ID $pedido_id cambió a estado $estado";
    mysqli_query($conexion, "INSERT INTO auditoria_ventas (id_usuario, accion) VALUES ($id_usuario, '$accion')");

    header("Location: detalle.php?id=$pedido_id&msg=ok");
    exit();
}

header("Location: index.php");
exit();
?>
