<?php
// Test Supabase connection and users query
// Using the Infinity Free MySQL connection (fallback to original DB)

define('BASE_PATH', '/');
define('BASE_URL', 'http://libreriasanmartin.lovestoblog.com/');
define('ROOT_PATH', $_SERVER['DOCUMENT_ROOT'] . '/');

// Connect to the database using the config from config/conexion.php
$conexion = new mysqli(
    "sql208.infinityfree.com",
    "if0_43082806",
    "Ed3xseFUTOj1",
    "if0_43082806_libreria"
);

if ($conexion->connect_error) {
    die("Error de conexión: " . $conexion->connect_error);
}

$conexion->set_charset("utf8mb4");

// Query the usuarios table
$result = $conexion->query("SELECT id, nombre, usuario, rol, foto FROM usuarios ORDER BY nombre ASC");

echo "=== USUARIOS EN LA BASE DE DATOS ===\n";
echo "Total usuarios encontrados: " . $result->num_rows . "\n\n";

if ($result->num_rows > 0) {
    while ($row = $result->fetch_assoc()) {
        echo "ID: " . $row['id'] . "\n";
        echo "  Nombre: " . $row['nombre'] . "\n";
        echo "  Usuario: @" . $row['usuario'] . "\n";
        echo "  Rol: " . $row['rol'] . "\n";
        echo "  Foto: " . ($row['foto'] ?? 'NULL') . "\n";
        echo "  ----\n";
    }
} else {
    echo "No hay usuarios registrados en la tabla 'usuarios'\n";
}

$conexion->close();
?>