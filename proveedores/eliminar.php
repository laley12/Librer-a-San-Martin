<?php
session_start();
include("../config/conexion.php");

$id = intval($_GET['id']);
$prov = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT nombre FROM proveedores WHERE id_proveedor = $id AND activo=1"));
$nombre_prov = $prov ? $prov['nombre'] : 'Desconocido';

mysqli_query($conexion, "UPDATE proveedores SET activo=0 WHERE id_proveedor = $id");

$id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
mysqli_query($conexion, "INSERT INTO auditoria_proveedores (id_usuario, accion) VALUES ($id_user, 'Eliminó proveedor: $nombre_prov (ID: $id)')");

$redirect = isset($_GET['redirect']) ? $_GET['redirect'] : "index.php";
header("Location: $redirect");