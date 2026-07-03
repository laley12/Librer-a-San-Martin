<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

if (isset($_POST['total'])) {
    if (!verificarCsrf($_POST['csrf_token'] ?? '')) {
        die('Error de seguridad');
    }
    $fecha = mysqli_real_escape_string($conexion, $_POST['fecha']);
    $total = mysqli_real_escape_string($conexion, $_POST['total']);
    $metodo_pago = mysqli_real_escape_string($conexion, $_POST['metodo_pago'] ?? '');

    $id_cliente = 'NULL';
    if (isset($_POST['id_cliente']) && $_POST['id_cliente']) {
        $id_cliente = intval($_POST['id_cliente']);
    } elseif (!empty(trim($_POST['cliente_nombre'] ?? ''))) {
        $cli_nombre = mysqli_real_escape_string($conexion, trim($_POST['cliente_nombre']));
        $cli_telefono = mysqli_real_escape_string($conexion, trim($_POST['cliente_telefono'] ?? ''));
        $cli_nit = mysqli_real_escape_string($conexion, trim($_POST['cliente_nit'] ?? ''));
        $check = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT id_cliente FROM clientes WHERE nombre_cliente = '$cli_nombre' AND ci_nit = '$cli_nit' AND activo=1 LIMIT 1"));
        if ($check) {
            $id_cliente = intval($check['id_cliente']);
        } else {
            mysqli_query($conexion, "INSERT INTO clientes (nombre_cliente, ci_nit, telefono) VALUES ('$cli_nombre', '$cli_nit', '$cli_telefono')");
            $id_cliente = mysqli_insert_id($conexion);
        }
    }

    $sql = "INSERT INTO ventas (fecha, total, id_cliente, metodo_pago) VALUES ('$fecha', '$total', $id_cliente, '$metodo_pago')";

    if (mysqli_query($conexion, $sql)) {
        $id_venta = mysqli_insert_id($conexion);

        if (isset($_POST['productos_json'])) {
            $productos = json_decode($_POST['productos_json'], true);
            if (is_array($productos)) {
                foreach ($productos as $p) {
                    $id_prod = intval($p['id']);
                    $cantidad = intval($p['cantidad']);
                    $precio = floatval($p['precio']);
                    mysqli_query($conexion, "INSERT INTO detalle_ventas (venta_id, producto_id, cantidad, precio) VALUES ($id_venta, $id_prod, $cantidad, $precio)");
                    mysqli_query($conexion, "UPDATE productos SET stock = stock - $cantidad WHERE id_producto = $id_prod");
                }
            }
        }

        $id_user = isset($_SESSION['id']) ? intval($_SESSION['id']) : 0;
        mysqli_query($conexion, "INSERT INTO auditoria_ventas (id_usuario, accion) VALUES ($id_user, 'Registró venta #$id_venta por Bs. $total')");
        header("Location: index.php?msg=success");
        exit();
    } else {
        echo "<h3>Error en la Base de Datos al registrar la venta:</h3>";
        echo "Detalle del error: " . mysqli_error($conexion) . "<br><br>";
        echo "<a href='index.php'>Volver al Historial</a>";
        exit();
    }
} else {
    header("Location: index.php");
    exit();
}
?>
