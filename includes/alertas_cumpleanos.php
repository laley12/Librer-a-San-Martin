<?php
$hoy = date('m-d');
$cumples = mysqli_query($conexion, "SELECT id_cliente, nombre_cliente, telefono FROM clientes WHERE DATE_FORMAT(fecha_nacimiento, '%m-%d') = '$hoy' AND activo=1");
if(mysqli_num_rows($cumples) > 0) {
    echo '<div class="alert alert-info alert-dismissible fade show m-0 rounded-0 py-2 text-center" role="alert">
        <i class="bi bi-gift-fill me-2"></i> Hoy cumplen a&ntilde;os: ';
    $nombres = [];
    while($c = mysqli_fetch_assoc($cumples)) { $nombres[] = '<a href="'.$base_path.'clientes/historial_compras.php?id_cliente='.$c['id_cliente'].'" class="alert-link">'.$c['nombre_cliente'].'</a>'; }
    echo implode(', ', $nombres);
    echo ' <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button></div>';
}
?>
