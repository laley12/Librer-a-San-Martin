<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
    die('Error de seguridad');
}

$nombre = mysqli_real_escape_string($conexion, $_POST['nombre_categoria']);
$descripcion = mysqli_real_escape_string($conexion, $_POST['descripcion']);
$codigo_categoria = mysqli_real_escape_string($conexion, trim($_POST['codigo_categoria'] ?? ''));
$icono = mysqli_real_escape_string($conexion, trim($_POST['icono'] ?? 'bi-tags-fill'));
$categoria_padre = !empty($_POST['categoria_padre']) ? intval($_POST['categoria_padre']) : 'NULL';
$visible_tienda = intval($_POST['visible_tienda'] ?? 1);
$orden = intval($_POST['orden'] ?? 0);

$sql = "INSERT INTO categorias (nombre_categoria, codigo_categoria, icono, categoria_padre, descripcion, visible_tienda, activo, orden) 
        VALUES ('$nombre', " . ($codigo_categoria ? "'$codigo_categoria'" : "NULL") . ", " . ($icono ? "'$icono'" : "'bi-tags-fill'") . ", " . $categoria_padre . ", '$descripcion', $visible_tienda, 1, $orden)";

if(mysqli_query($conexion, $sql)){
    $nuevo_id = mysqli_insert_id($conexion);
    $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
    mysqli_query($conexion, "INSERT INTO auditoria_categorias (id_usuario, accion) VALUES ($id_user, 'Registró nueva categoría: $nombre (ID: $nuevo_id)')");
    header("Location: index.php?status=success");
    exit();
}else{
    echo "Error al guardar categoría: " . mysqli_error($conexion);
}
?>