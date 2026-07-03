<?php
function registrar_auditoria($conexion, $id_usuario, $accion, $tabla = 'auditoria'){
    $id_usuario = intval($id_usuario);
    $accion = mysqli_real_escape_string($conexion, $accion);
    $tabla = preg_replace('/[^a-zA-Z0-9_]/', '', $tabla);
    mysqli_query($conexion, "INSERT INTO {$tabla} (id_usuario, accion) VALUES ($id_usuario, '$accion')");
}
?>
