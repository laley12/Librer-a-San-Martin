<?php
session_start();
include("../config/conexion.php");

$id = intval($_GET['id']);
$cat = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT nombre_categoria FROM categorias WHERE id_categoria = $id AND activo=1"));
$nombre = $cat ? $cat['nombre_categoria'] : '';

mysqli_query($conexion, "UPDATE categorias SET activo=0 WHERE id_categoria = $id");

$id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
mysqli_query($conexion, "INSERT INTO auditoria_categorias (id_usuario, accion) VALUES ($id_user, 'Eliminó categoría: $nombre (ID: $id)')");

header("Location: index.php");
?>
