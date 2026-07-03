<?php
function exportar_excel($datos, $nombre_archivo) {
    header('Content-Type: application/vnd.ms-excel; charset=utf-8');
    header('Content-Disposition: attachment; filename="' . $nombre_archivo . '_' . date('Y-m-d') . '.xls"');
    echo '<html><head><meta charset="UTF-8"></head><body><table border="1">';
    $primero = true;
    foreach ($datos as $fila) {
        if ($primero) { echo '<tr>'; foreach ($fila as $k => $v) echo '<th>' . htmlspecialchars($k) . '</th>'; echo '</tr>'; $primero = false; }
        echo '<tr>'; foreach ($fila as $v) echo '<td>' . htmlspecialchars($v ?? '') . '</td>'; echo '</tr>';
    }
    echo '</table></body></html>';
    exit;
}
function exportar_pdf($html, $nombre_archivo) {
    header('Content-Type: text/html; charset=utf-8');
    echo '<html><head><meta charset="UTF-8"><style>body{font-family:sans-serif;padding:20px;}table{width:100%;border-collapse:collapse;}th,td{border:1px solid #ccc;padding:6px;text-align:left;}</style></head><body>';
    echo $html;
    echo '<script>window.print();</script></body></html>';
    exit;
}
?>
