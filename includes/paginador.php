<?php
function paginar($conexion, $sql_base, $limite = 20) {
    $pagina = isset($_GET['pagina']) ? max(1, intval($_GET['pagina'])) : 1;
    $offset = ($pagina - 1) * $limite;
    $total = mysqli_fetch_assoc(mysqli_query($conexion, $sql_base));
    $total_registros = $total['total'];
    $total_paginas = ceil($total_registros / $limite);
    $sql_limite = " LIMIT $offset, $limite";
    return ['pagina' => $pagina, 'total_paginas' => $total_paginas, 'total_registros' => $total_registros, 'offset' => $offset, 'limite' => $limite, 'sql_limite' => $sql_limite];
}
function mostrar_paginacion($pagina, $total_paginas, $url = '') {
    if ($total_paginas <= 1) return '';
    if (!$url) $url = $_SERVER['PHP_SELF'];
    $sep = (strpos($url, '?') !== false) ? '&' : '?';
    $html = '<nav><ul class="pagination pagination-sm justify-content-center mt-3">';
    $html .= '<li class="page-item ' . ($pagina <= 1 ? 'disabled' : '') . '"><a class="page-link" href="' . $url . $sep . 'pagina=' . ($pagina - 1) . '">&laquo;</a></li>';
    for ($i = 1; $i <= $total_paginas; $i++) {
        $active = $i == $pagina ? 'active' : '';
        $html .= '<li class="page-item ' . $active . '"><a class="page-link" href="' . $url . $sep . 'pagina=' . $i . '">' . $i . '</a></li>';
    }
    $html .= '<li class="page-item ' . ($pagina >= $total_paginas ? 'disabled' : '') . '"><a class="page-link" href="' . $url . $sep . 'pagina=' . ($pagina + 1) . '">&raquo;</a></li>';
    $html .= '</ul></nav>';
    return $html;
}
?>
