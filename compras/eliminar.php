<?php
session_start();
include("../config/conexion.php");

$id = intval($_GET['id']);

$id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
mysqli_query($conexion, "INSERT INTO auditoria_compras (id_usuario, accion) VALUES ($id_user, 'Eliminó compra ID: $id')");

mysqli_query($conexion, "DELETE FROM compras WHERE id_compra = $id");
mysqli_query($conexion, "DELETE FROM detalle_compras WHERE id_compra = $id");

header("Location: index.php");
