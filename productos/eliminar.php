<?php
session_start();
include("../config/conexion.php");

$id = intval($_GET['id']);
$prod = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT nombre_producto FROM productos WHERE id_producto = $id AND activo=1"));
$nombre = $prod ? $prod['nombre_producto'] : '';

mysqli_query($conexion, "UPDATE productos SET activo=0 WHERE id_producto = $id");

$id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
mysqli_query($conexion, "INSERT INTO auditoria_productos (id_usuario, accion) VALUES ($id_user, 'Eliminó producto: $nombre (ID: $id)')");

header("Location: index.php");