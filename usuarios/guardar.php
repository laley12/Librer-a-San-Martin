<?php
session_start();
include("../config/conexion.php");
include("../config/auditoria.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
    die('Error de seguridad');
}

$nombre = mysqli_real_escape_string($conexion, $_POST['nombre']);
$usuario = mysqli_real_escape_string($conexion, $_POST['usuario']);
$password = $_POST['password'];
$rol = mysqli_real_escape_string($conexion, $_POST['rol']);

$hash = password_hash($password, PASSWORD_DEFAULT);

$sql = "INSERT INTO usuarios (nombre, usuario, password, password_hash, rol, estado)
VALUES ('$nombre','$usuario','$hash','$hash','$rol','Activo')";

if(mysqli_query($conexion,$sql)){
    $nuevo_id = mysqli_insert_id($conexion);
    if(isset($_FILES['imagen']) && $_FILES['imagen']['error'] === UPLOAD_ERR_OK){
        $ext = strtolower(pathinfo($_FILES['imagen']['name'], PATHINFO_EXTENSION));
        $allowed = ['jpg','jpeg','png','gif','webp'];
        if(in_array($ext, $allowed)){
            $filename = "user_{$nuevo_id}_" . time() . ".$ext";
            $destino = "../assets/uploads/usuarios/$filename";
            if(move_uploaded_file($_FILES['imagen']['tmp_name'], $destino)){
                mysqli_query($conexion, "UPDATE usuarios SET imagen='$filename' WHERE id=$nuevo_id");
            }
        }
    }
    registrar_auditoria($conexion, $_SESSION['id'], "Registró un nuevo usuario: $nombre (ID: $nuevo_id)", 'auditoria_usuarios');
    header("Location: index.php");
}else{
    echo "Error al guardar usuario";
}
?>