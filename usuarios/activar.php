<?php
session_start();
include("../config/conexion.php");
include("../config/auditoria.php");

$id = intval($_GET['id']);

$user = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT nombre FROM usuarios WHERE id = $id"));
$nombre_user = $user ? $user['nombre'] : 'Desconocido';

mysqli_query($conexion, "UPDATE usuarios SET estado = 'Activo' WHERE id = $id");

if(isset($_SESSION['id'])){
    registrar_auditoria($conexion, $_SESSION['id'], "Reactivó al usuario: $nombre_user (ID: $id)", 'auditoria_usuarios');
}

header("Location: index.php");
?>
