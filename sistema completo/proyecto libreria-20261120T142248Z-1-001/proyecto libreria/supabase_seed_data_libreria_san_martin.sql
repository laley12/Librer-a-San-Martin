-- ==============================================================================
-- LIBRERÍA "SAN MARTÍN" - SEED DATA Y POLÍTICAS CRUD
-- EJECUTAR EN SUPABASE SQL EDITOR PARA POBLAR TODAS LAS TABLAS
-- ==============================================================================

-- 1. Asegurar políticas completas de lectura y escritura (RLS) para el cliente web/móvil
DROP POLICY IF EXISTS "Acceso total a usuarios" ON public.usuarios;
CREATE POLICY "Acceso total a usuarios" ON public.usuarios FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Lectura pública de productos" ON public.productos;
DROP POLICY IF EXISTS "Acceso total a productos" ON public.productos;
CREATE POLICY "Acceso total a productos" ON public.productos FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Lectura pública de categorías" ON public.categorias;
DROP POLICY IF EXISTS "Acceso total a categorias" ON public.categorias;
CREATE POLICY "Acceso total a categorias" ON public.categorias FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Lectura pública de proveedores" ON public.proveedores;
DROP POLICY IF EXISTS "Acceso total a proveedores" ON public.proveedores;
CREATE POLICY "Acceso total a proveedores" ON public.proveedores FOR ALL USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "Lectura pública de clientes" ON public.clientes;
DROP POLICY IF EXISTS "Acceso total a clientes" ON public.clientes;
CREATE POLICY "Acceso total a clientes" ON public.clientes FOR ALL USING (true) WITH CHECK (true);

-- 2. Limpieza previa de tablas transaccionales (para evitar duplicados en re-ejecución)
DELETE FROM public.detalle_ventas;
DELETE FROM public.ventas;
DELETE FROM public.detalle_compras;
DELETE FROM public.compras;
DELETE FROM public.productos;
DELETE FROM public.usuarios;

-- 3. Inserción de Usuarios de Prueba (Vinculados a Roles y Casa Matriz)
DO $$
DECLARE
    v_rol_admin UUID;
    v_rol_prop UUID;
    v_rol_cajero UUID;
    v_rol_inv UUID;
    v_sucursal UUID;
    v_cat_textos UUID;
    v_cat_novelas UUID;
    v_cat_papeleria UUID;
    v_cat_arte UUID;
    v_prov_santillana UUID;
    v_prov_norma UUID;
    v_prov_donbosco UUID;
    v_cli_general UUID;
    v_cli_aleman UUID;
    v_cli_liceo UUID;
    
    -- IDs de usuarios creados
    v_user_admin UUID;
    v_user_prop UUID;
    v_user_cajero UUID;
    v_user_inv UUID;
    
    -- IDs de productos creados
    v_prod_lenguaje UUID;
    v_prod_mate UUID;
    v_prod_historia UUID;
    v_prod_raza UUID;
    v_prod_soledad UUID;
    v_prod_cuad_top UUID;
    v_prod_cuad_lider UUID;
    v_prod_colores UUID;
    v_prod_estuche UUID;
    v_prod_resma UUID;
    
    -- IDs de compras y ventas
    v_compra_1 UUID;
    v_compra_2 UUID;
    v_venta_1 UUID;
    v_venta_2 UUID;
BEGIN
    -- Obtener Roles
    SELECT id INTO v_rol_admin FROM public.roles WHERE nombre = 'Admin TI' LIMIT 1;
    SELECT id INTO v_rol_prop FROM public.roles WHERE nombre = 'Propietaria' LIMIT 1;
    SELECT id INTO v_rol_cajero FROM public.roles WHERE nombre = 'Cajero' LIMIT 1;
    SELECT id INTO v_rol_inv FROM public.roles WHERE nombre = 'Inventariador' LIMIT 1;

    -- Obtener Sucursal Casa Matriz
    SELECT id INTO v_sucursal FROM public.sucursales WHERE nombre LIKE '%Matriz%' LIMIT 1;

    -- A) INSERTAR USUARIOS DEL PERSONAL
    INSERT INTO public.usuarios (nombre, usuario, clave, rol_id, sucursal_id, estado)
    VALUES ('Gustavo Gabriel Guachalla Rocha', 'gguachalla', '$2a$12$e8z9XQ7o3a7ZgW2oE5jUze3aKq3Lp7Yt6u1m4w8c9z0', v_rol_admin, v_sucursal, true)
    RETURNING id INTO v_user_admin;

    INSERT INTO public.usuarios (nombre, usuario, clave, rol_id, sucursal_id, estado)
    VALUES ('Carmen Patricia Molina Roca', 'cpatricia', '$2a$12$e8z9XQ7o3a7ZgW2oE5jUze3aKq3Lp7Yt6u1m4w8c9z0', v_rol_prop, v_sucursal, true)
    RETURNING id INTO v_user_prop;

    INSERT INTO public.usuarios (nombre, usuario, clave, rol_id, sucursal_id, estado)
    VALUES ('Juan Pérez Flores', 'jperez', '$2a$12$e8z9XQ7o3a7ZgW2oE5jUze3aKq3Lp7Yt6u1m4w8c9z0', v_rol_cajero, v_sucursal, true)
    RETURNING id INTO v_user_cajero;

    INSERT INTO public.usuarios (nombre, usuario, clave, rol_id, sucursal_id, estado)
    VALUES ('Carlos Mendoza Rojas', 'cmendoza', '$2a$12$e8z9XQ7o3a7ZgW2oE5jUze3aKq3Lp7Yt6u1m4w8c9z0', v_rol_inv, v_sucursal, true)
    RETURNING id INTO v_user_inv;

    -- Obtener Categorías
    SELECT id INTO v_cat_textos FROM public.categorias WHERE nombre = 'Textos Escolares' LIMIT 1;
    SELECT id INTO v_cat_novelas FROM public.categorias WHERE nombre = 'Literatura y Novelas' LIMIT 1;
    SELECT id INTO v_cat_papeleria FROM public.categorias WHERE nombre = 'Papelería y Cuadernos' LIMIT 1;
    SELECT id INTO v_cat_arte FROM public.categorias WHERE nombre = 'Material de Escritorio y Arte' LIMIT 1;

    -- Obtener Proveedores
    SELECT id INTO v_prov_santillana FROM public.proveedores WHERE nombre LIKE '%Santillana%' LIMIT 1;
    SELECT id INTO v_prov_norma FROM public.proveedores WHERE nombre LIKE '%Norma%' LIMIT 1;
    SELECT id INTO v_prov_donbosco FROM public.proveedores WHERE nombre LIKE '%Don Bosco%' LIMIT 1;

    -- Obtener Clientes
    SELECT id INTO v_cli_general FROM public.clientes WHERE nit_ci = '0' LIMIT 1;
    SELECT id INTO v_cli_aleman FROM public.clientes WHERE nombre LIKE '%Alemán%' LIMIT 1;
    SELECT id INTO v_cli_liceo FROM public.clientes WHERE nombre LIKE '%Liceo%' LIMIT 1;

    -- B) INSERTAR CATÁLOGO DE PRODUCTOS (Con estados Óptimo, Advertencia y Crítico)
    -- 1. Lenguaje 4to Primaria (Santillana) - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('978-8429408234', 'Lenguaje y Comunicación 4to Primaria - Santillana', v_cat_textos, 95.00, 135.00, 45, 10, true)
    RETURNING id INTO v_prod_lenguaje;

    -- 2. Matemáticas 5to Primaria (Norma) - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('978-9580456201', 'Matemáticas Avanzadas 5to Primaria - Norma', v_cat_textos, 110.00, 155.00, 32, 10, true)
    RETURNING id INTO v_prod_mate;

    -- 3. Historia de Bolivia (Don Bosco) - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('978-9990520112', 'Historia Geográfica de Bolivia - Don Bosco', v_cat_textos, 75.00, 110.00, 24, 8, true)
    RETURNING id INTO v_prod_historia;

    -- 4. Raza de Bronce (Literatura) - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('978-8437604947', 'Raza de Bronce - Alcides Arguedas', v_cat_novelas, 40.00, 65.00, 18, 5, true)
    RETURNING id INTO v_prod_raza;

    -- 5. Cien Años de Soledad (Literatura) - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('978-9875666481', 'Cien Años de Soledad - Gabriel García Márquez', v_cat_novelas, 60.00, 95.00, 15, 5, true)
    RETURNING id INTO v_prod_soledad;

    -- 6. Cuaderno Empastado 100 Hojas Top - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('7771234001015', 'Cuaderno Empastado 100 Hojas Cuadriculado Top', v_cat_papeleria, 12.50, 18.00, 120, 20, true)
    RETURNING id INTO v_prod_cuad_top;

    -- 7. Cuaderno Espiral 200 Hojas 5 Materias - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('7771234001022', 'Cuaderno Espiral 200 Hojas 5 Materias Líder', v_cat_papeleria, 22.00, 32.00, 85, 15, true)
    RETURNING id INTO v_prod_cuad_lider;

    -- 8. Resma de Papel Bond Carta 75g - Stock Óptimo
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('7891234567818', 'Resma Papel Bond Carta 75g Report (500 hojas)', v_cat_papeleria, 28.00, 38.00, 50, 10, true)
    RETURNING id INTO v_prod_resma;

    -- 9. Estuche Geométrico Maped - 🟡 STOCK EN ADVERTENCIA (Stock <= Min * 1.5)
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('7891234567801', 'Estuche Geométrico Escolar 30cm Maped', v_cat_arte, 10.00, 16.00, 12, 10, true)
    RETURNING id INTO v_prod_estuche;

    -- 10. Caja de Colores x 24 Faber-Castell - 🔴 STOCK CRÍTICO (Stock < Stock Mínimo)
    INSERT INTO public.productos (codigo_sku, nombre, categoria_id, precio_costo, precio_venta, stock, stock_minimo, activo)
    VALUES ('7891234567890', 'Caja de Lápices de Color x 24 Faber-Castell', v_cat_arte, 28.00, 42.00, 3, 10, true)
    RETURNING id INTO v_prod_colores;

    -- C) INSERTAR ÓRDENES DE COMPRA (Reabastecimiento de Almacén para Kárdex PEPS)
    -- Compra 1: Santillana
    INSERT INTO public.compras (proveedor_id, usuario_id, sucursal_id, fecha, total, activo)
    VALUES (v_prov_santillana, v_user_inv, v_sucursal, now() - INTERVAL '5 days', 4750.00, true)
    RETURNING id INTO v_compra_1;

    INSERT INTO public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_compra_1, v_prod_lenguaje, 50, 95.00, 4750.00);

    -- Compra 2: Papelería y Arte
    INSERT INTO public.compras (proveedor_id, usuario_id, sucursal_id, fecha, total, activo)
    VALUES (v_prov_donbosco, v_user_inv, v_sucursal, now() - INTERVAL '3 days', 2900.00, true)
    RETURNING id INTO v_compra_2;

    INSERT INTO public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_compra_2, v_prod_cuad_top, 100, 12.50, 1250.00);
    INSERT INTO public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_compra_2, v_prod_historia, 22, 75.00, 1650.00);

    -- D) INSERTAR VENTAS EN TERMINAL POS (Tickets y Facturación)
    -- Venta 1: Cliente Colegio Alemán (Cobro QR)
    INSERT INTO public.ventas (usuario_id, sucursal_id, cliente_id, fecha, metodo_pago, total, activo)
    VALUES (v_user_cajero, v_sucursal, v_cli_aleman, now() - INTERVAL '2 days', 'QR Simple', 835.00, true)
    RETURNING id INTO v_venta_1;

    INSERT INTO public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_venta_1, v_prod_lenguaje, 5, 135.00, 675.00);
    INSERT INTO public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_venta_1, v_prod_estuche, 10, 16.00, 160.00);

    -- Venta 2: Cliente General en Mostrador (Efectivo)
    INSERT INTO public.ventas (usuario_id, sucursal_id, cliente_id, fecha, metodo_pago, total, activo)
    VALUES (v_user_cajero, v_sucursal, v_cli_general, now() - INTERVAL '1 day', 'Efectivo', 197.00, true)
    RETURNING id INTO v_venta_2;

    INSERT INTO public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_venta_2, v_prod_cuad_top, 3, 18.00, 54.00);
    INSERT INTO public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_venta_2, v_prod_colores, 1, 42.00, 42.00);
    INSERT INTO public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_venta_2, v_prod_soledad, 1, 95.00, 95.00);
    INSERT INTO public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario, subtotal)
    VALUES (v_venta_2, v_prod_resma, 1, 38.00, 38.00);

    -- E) INSERTAR BITÁCORA FORENSE DE AUDITORÍA (WORM)
    INSERT INTO public.audit_logs (usuario_id, accion, tabla_afectada, registro_id, detalles, fecha)
    VALUES (v_user_admin, 'SISTEMA_INICIALIZADO', 'sistema', 'init', 'Configuración de entorno de producción y conexión con Supabase Cloud completada.', now() - INTERVAL '5 days');

    INSERT INTO public.audit_logs (usuario_id, accion, tabla_afectada, registro_id, detalles, fecha)
    VALUES (v_user_inv, 'RECEPCION_COMPRA', 'compras', v_compra_1::text, 'Reabastecimiento de 50 textos de Lenguaje 4to Primaria ingresado a Kárdex PEPS.', now() - INTERVAL '5 days');

    INSERT INTO public.audit_logs (usuario_id, accion, tabla_afectada, registro_id, detalles, fecha)
    VALUES (v_user_cajero, 'EMISION_FACTURA_POS', 'ventas', v_venta_1::text, 'Factura electrónica emitida a Colegio Alemán por Bs 835.00.', now() - INTERVAL '2 days');

    RAISE NOTICE '¡Carga de datos semilla para la Librería San Martín completada exitosamente!';
END $$;
