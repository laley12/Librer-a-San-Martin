<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

if($_SERVER['REQUEST_METHOD'] == 'POST'){
    if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
        die('Error de seguridad');
    }
    $nombre = mysqli_real_escape_string($conexion, $_POST['nombre_producto']);
    $descripcion = mysqli_real_escape_string($conexion, $_POST['descripcion']);
    $precio = floatval($_POST['precio']);
    $stock = intval($_POST['stock']);
    $categoria_id = intval($_POST['categoria_id']);

    // Use provided code, or auto-generate if empty
    if(!empty(trim($_POST['codigo']))) {
        $codigo = mysqli_real_escape_string($conexion, trim($_POST['codigo']));
        // Check uniqueness
        $check = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT id_producto FROM productos WHERE codigo='$codigo' AND activo=1 LIMIT 1"));
        if ($check) {
            // Code already exists, add suffix
            $codigo = $codigo . '-' . rand(100, 999);
        }
    } else {
        // Auto-generate: use MAX id to ensure uniqueness
        $max = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT MAX(id_producto) as max_id FROM productos"));
        $next = ($max['max_id'] ?? 0) + 1;
        $codigo = 'PROD-' . str_pad($next, 4, '0', STR_PAD_LEFT);
    }

    $sql = "INSERT INTO productos (codigo, nombre_producto, descripcion, precio, stock, categoria_id)
            VALUES ('$codigo', '$nombre', '$descripcion', '$precio', '$stock', '$categoria_id')";

    if(mysqli_query($conexion, $sql)){
        $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
        $nuevo_id = mysqli_insert_id($conexion);
        mysqli_query($conexion, "INSERT INTO auditoria_productos (id_usuario, accion) VALUES ($id_user, 'Registró nuevo producto: $nombre (ID: $nuevo_id, Código: $codigo)')");
        header("Location: index.php?status=success");
        exit();
    } else {
        echo "Error al registrar el producto: " . mysqli_error($conexion);
    }
} else {
    header("Location: index.php");
    exit();
}
?>