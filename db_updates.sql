USE libreria_san_martin;

CREATE TABLE IF NOT EXISTS clientes (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    ci_nit VARCHAR(20) NOT NULL,
    nombre_cliente VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS caja_flujo (
    id_caja INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    monto_apertura DECIMAL(10,2) NOT NULL,
    monto_cierre DECIMAL(10,2),
    fecha_apertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_cierre DATETIME,
    estado ENUM('ABIERTA', 'CERRADA') DEFAULT 'ABIERTA'
);

CREATE TABLE IF NOT EXISTS gastos (
    id_gasto INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(255) NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    id_usuario INT NOT NULL
);

-- Attempt to add id_cliente to ventas if it doesn't exist
SET @dbname = 'libreria_san_martin';
SET @tablename = 'ventas';
SET @columnname = 'id_cliente';
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE
      (table_name = @tablename)
      AND (table_schema = @dbname)
      AND (column_name = @columnname)
  ) > 0,
  "SELECT 1",
  "ALTER TABLE ventas ADD COLUMN id_cliente INT NULL;"
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;
