<?php
$stock_bajo = mysqli_query($conexion, "SELECT COUNT(*) total FROM productos WHERE activo=1 AND stock < 5");
$sb = mysqli_fetch_assoc($stock_bajo);
if($sb['total'] > 0) {
    echo '<div class="alert alert-warning alert-dismissible fade show m-0 rounded-0 py-2 text-center" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        Hay <strong>'.$sb['total'].' producto(s)</strong> con stock cr&iacute;tico. 
        <a href="'.$base_path.'inventario/stock_bajo.php" class="alert-link">Ver ahora</a>
        <button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>
    </div>';
}
?>
