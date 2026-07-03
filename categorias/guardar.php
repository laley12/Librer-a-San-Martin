<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
    die('Error de seguridad');
}

$nombre = mysqli_real_escape_string($conexion, $_POST['nombre_categoria']);
$descripcion = mysqli_real_escape_string($conexion, $_POST['descripcion']);

$sql = "INSERT INTO categorias (nombre_categoria, descripcion) VALUES ('$nombre', '$descripcion')";

if(mysqli_query($conexion, $sql)){
    $nuevo_id = mysqli_insert_id($conexion);
    $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
    mysqli_query($conexion, "INSERT INTO auditoria_categorias (id_usuario, accion) VALUES ($id_user, 'Registró nueva categoría: $nombre (ID: $nuevo_id)')");
    header("Location: index.php");
    exit();
}else{
    echo "Error al guardar categoría";
}
?>
