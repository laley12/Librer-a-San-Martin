USE libreria_san_martin;

-- 1. Tema oscuro/claro por usuario
ALTER TABLE usuarios ADD COLUMN IF NOT EXISTS tema VARCHAR(10) DEFAULT 'light' AFTER ultimo_acceso;

-- 2. Soft delete (activo/inactivo)
ALTER TABLE productos ADD COLUMN IF NOT EXISTS activo TINYINT(1) DEFAULT 1 AFTER imagen;
ALTER TABLE clientes ADD COLUMN IF NOT EXISTS activo TINYINT(1) DEFAULT 1 AFTER fecha_registro;
ALTER TABLE proveedores ADD COLUMN IF NOT EXISTS activo TINYINT(1) DEFAULT 1 AFTER direccion;
ALTER TABLE categorias ADD COLUMN IF NOT EXISTS activo TINYINT(1) DEFAULT 1 AFTER nombre_categoria;

-- 3. Código de barras para productos
ALTER TABLE productos ADD COLUMN IF NOT EXISTS codigo_barras VARCHAR(50) DEFAULT NULL AFTER codigo;

-- 4. IVA/Impuesto por producto
ALTER TABLE productos ADD COLUMN IF NOT EXISTS impuesto DECIMAL(5,2) DEFAULT 0.00 AFTER precio;

-- 5. Variantes: talla y color
ALTER TABLE productos ADD COLUMN IF NOT EXISTS talla VARCHAR(20) DEFAULT NULL AFTER impuesto;
ALTER TABLE productos ADD COLUMN IF NOT EXISTS color VARCHAR(50) DEFAULT NULL AFTER talla;
