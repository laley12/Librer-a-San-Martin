<?php
session_start();
include("../config/conexion.php");

$id = intval($_GET['id']);

if(isset($_POST['actualizar'])){

$nombre = mysqli_real_escape_string($conexion, $_POST['nombre']);
$telefono = mysqli_real_escape_string($conexion, $_POST['telefono']);
$direccion = mysqli_real_escape_string($conexion, $_POST['direccion']);

$sql = "UPDATE proveedores SET nombre='$nombre', telefono='$telefono', direccion='$direccion' WHERE id_proveedor=$id";

mysqli_query($conexion, $sql);

$id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
mysqli_query($conexion, "INSERT INTO auditoria_proveedores (id_usuario, accion) VALUES ($id_user, 'Modificó proveedor: $nombre (ID: $id)')");

header("Location: index.php");
exit();

}

$proveedor = mysqli_fetch_assoc(
mysqli_query($conexion,
"SELECT * FROM proveedores WHERE id_proveedor=$id AND activo=1")
);

?>

<!DOCTYPE html>
<html>

<head>

<title>Editar Proveedor</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

</head>

<body>

<div class="container mt-5">

<h2>Editar Proveedor</h2>

<form method="POST">

<input
type="text"
name="nombre"
value="<?php echo $proveedor['nombre']; ?>"
class="form-control mb-3">

<input
type="text"
name="telefono"
value="<?php echo $proveedor['telefono']; ?>"
class="form-control mb-3">

<input
type="text"
name="direccion"
value="<?php echo $proveedor['direccion']; ?>"
class="form-control mb-3">

<button
name="actualizar"
class="btn btn-primary">

Actualizar

</button>

</form>

</div>

</body>

</html>