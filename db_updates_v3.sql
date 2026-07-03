-- =============================================
-- DB Migration v3: Nuevas características
-- =============================================

-- 1. Columnas nuevas en usuarios
ALTER TABLE usuarios
  ADD COLUMN IF NOT EXISTS foto VARCHAR(255) DEFAULT NULL AFTER imagen,
  ADD COLUMN IF NOT EXISTS firma TEXT DEFAULT NULL AFTER foto;

-- 2. password_hash (migrar passwords existentes después manualmente)
ALTER TABLE usuarios
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255) DEFAULT NULL AFTER password;

-- 3. clientes: fecha_nacimiento para cumpleaños + email
ALTER TABLE clientes
  ADD COLUMN IF NOT EXISTS fecha_nacimiento DATE DEFAULT NULL AFTER ci_nit,
  ADD COLUMN IF NOT EXISTS email VARCHAR(100) DEFAULT NULL AFTER telefono;

-- 4. productos: trigger para historial_precios (se crea tabla aparte vía PHP)

-- 5. Chat interno
CREATE TABLE IF NOT EXISTS mensajes_chat (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_remitente INT NOT NULL,
  id_destinatario INT DEFAULT NULL,
  mensaje TEXT NOT NULL,
  leido TINYINT(1) DEFAULT 0,
  fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_remitente) REFERENCES usuarios(id),
  FOREIGN KEY (id_destinatario) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Devoluciones/notas de crédito
CREATE TABLE IF NOT EXISTS devoluciones (
  id_devolucion INT AUTO_INCREMENT PRIMARY KEY,
  id_venta INT NOT NULL,
  id_usuario INT NOT NULL,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  motivo TEXT DEFAULT NULL,
  total_devuelto DECIMAL(10,2) NOT NULL DEFAULT 0,
  FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS detalle_devoluciones (
  id_detalle INT AUTO_INCREMENT PRIMARY KEY,
  id_devolucion INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (id_devolucion) REFERENCES devoluciones(id_devolucion),
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Historial de precios
CREATE TABLE IF NOT EXISTS historial_precios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_producto INT NOT NULL,
  precio_anterior DECIMAL(10,2) NOT NULL,
  precio_nuevo DECIMAL(10,2) NOT NULL,
  tipo VARCHAR(20) NOT NULL DEFAULT 'venta',
  id_usuario INT DEFAULT NULL,
  fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. Intentos de login (rate limiting)
CREATE TABLE IF NOT EXISTS intentos_login (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario VARCHAR(100) NOT NULL,
  ip VARCHAR(45) NOT NULL,
  intentos INT DEFAULT 0,
  ultimo_intento DATETIME DEFAULT CURRENT_TIMESTAMP,
  bloqueado_hasta DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 9. fichas tecnicas de impresora térmica
CREATE TABLE IF NOT EXISTS config_impresora (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  tipo VARCHAR(20) DEFAULT 'ticket',
  ancho INT DEFAULT 80,
  charset VARCHAR(20) DEFAULT 'UTF-8',
  FOREIGN KEY (id_usuario) REFERENCES usuarios(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
