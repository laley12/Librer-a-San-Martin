<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
    die('Error de seguridad');
}

if (isset($_POST['nombre'])) {
    $nombre = mysqli_real_escape_string($conexion, $_POST['nombre']);
    $telefono = mysqli_real_escape_string($conexion, $_POST['telefono']);
    $direccion = mysqli_real_escape_string($conexion, $_POST['direccion']);

    $sql = "INSERT INTO proveedores (nombre, telefono, direccion) VALUES ('$nombre', '$telefono', '$direccion')";
    
    if (mysqli_query($conexion, $sql)) {
        $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
        $nuevo_id = mysqli_insert_id($conexion);
        mysqli_query($conexion, "INSERT INTO auditoria_proveedores (id_usuario, accion) VALUES ($id_user, 'Registró nuevo proveedor: $nombre (ID: $nuevo_id)')");
        $redirect = isset($_POST['redirect']) ? $_POST['redirect'] : "index.php";
        header("Location: $redirect");
        exit();
    } else {
        echo "<h3>Error en la Base de Datos:</h3>";
        echo "Mensaje de error: " . mysqli_error($conexion) . "<br><br>";
        echo "<a href='index.php'>Volver</a>";
        exit();
    }
} else {
    header("Location: index.php");
    exit();
}
?>