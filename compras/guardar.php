<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

mysqli_query($conexion, "CREATE TABLE IF NOT EXISTS detalle_compras (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    compra_id INT NOT NULL,
    producto_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio DECIMAL(10,2) NOT NULL
)");

if (isset($_POST['proveedor_id']) && isset($_POST['total'])) {
    if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
        die('Error de seguridad');
    }
    $proveedor_id = intval($_POST['proveedor_id']);
    $fecha = mysqli_real_escape_string($conexion, $_POST['fecha']);
    $nro_factura = mysqli_real_escape_string($conexion, $_POST['nro_factura'] ?? '');
    $total = mysqli_real_escape_string($conexion, $_POST['total']);

    $sql = "INSERT INTO compras (proveedor_id, nro_factura, fecha, total) VALUES ($proveedor_id, '$nro_factura', '$fecha', '$total')";

    if (mysqli_query($conexion, $sql)) {
        $id_compra = mysqli_insert_id($conexion);

        if (isset($_POST['productos_json'])) {
            $productos = json_decode($_POST['productos_json'], true);
            if (is_array($productos)) {
                foreach ($productos as $p) {
                    $id_prod = intval($p['id']);
                    $cantidad = intval($p['cantidad']);
                    $precio_compra = floatval($p['precio_compra']);
                    mysqli_query($conexion, "INSERT INTO detalle_compras (compra_id, producto_id, cantidad, precio) VALUES ($id_compra, $id_prod, $cantidad, $precio_compra)");
                    mysqli_query($conexion, "UPDATE productos SET stock = stock + $cantidad WHERE id_producto = $id_prod");
                }
            }
        }

        $prov = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT nombre FROM proveedores WHERE id_proveedor = $proveedor_id AND activo=1"));
        $nom = $prov ? $prov['nombre'] : 'Desconocido';
        $id_user = intval($_SESSION['id']);
        mysqli_query($conexion, "INSERT INTO auditoria_compras (id_usuario, accion) VALUES ($id_user, 'Registró compra #$id_compra a $nom factura $nro_factura por Bs. $total')");
        header("Location: index.php?msg=success");
        exit();
    } else {
        echo "<h3>Error en la Base de Datos:</h3>";
        echo "Detalle: " . mysqli_error($conexion) . "<br><br>";
        echo "<a href='index.php'>Volver</a>";
        exit();
    }
} else {
    header("Location: index.php");
    exit();
}
?>
