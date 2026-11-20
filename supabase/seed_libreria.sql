-- ============================================================
-- Libreria San Martin - Datos base semilla (negocio propio, sede unica)
-- Ejecutar DESPUES de migracion_er.sql en el SQL Editor de Supabase.
-- Incluye: usuarios demo, 4 categorias, 8 productos (5 con stock
-- critico <=5 para las alertas HU8), 3 proveedores, compras y ventas
-- con detalle distribuidas en las ultimas 3 semanas (graficos HU9).
-- ============================================================

set search_path = public;

begin;

-- Triggers de stock desactivados durante la siembra: el stock final
-- de cada producto es el que se quiere dejar (el historial de compras/
-- ventas ya lo refleja), evitando duplicar el calculo.
alter table public.detalle_ventas disable trigger trg_stock_ventas;
alter table public.detalle_compras disable trigger trg_stock_compras;

truncate table public.detalle_ventas, public.ventas,
             public.detalle_compras, public.compras,
             public.productos, public.categorias,
             public.proveedores, public.usuarios cascade;

-- ------------------------------------------------------------
-- Usuarios (el login real usa auth.users -> Gustavo/12345)
--   Gustavo: Administrador (activo)  - cuenta de login existente
--   Maria:   Vendedora (activa)      - fila demo para el listado
--   Carlos:  Empleado (inactivo)     - fila demo para la baja logica
-- ------------------------------------------------------------
insert into public.usuarios (nombre, usuario, clave, rol, estado) values
 ('Gustavo Guachalla', 'gustavo',
  'scrypt$16384$8$1$2gvvgUTo9knmxLsL5N/pXg==$3YrlPauTWFlddyQ1ul9G09sukXCrblV9A4FuEx7586c=',
  'Administrador', true),
 ('María Rodríguez', 'maria',
  'scrypt$16384$8$1$2gvvgUTo9knmxLsL5N/pXg==$3YrlPauTWFlddyQ1ul9G09sukXCrblV9A4FuEx7586c=',
  'Vendedor', true),
 ('Carlos Limachi', 'carlos',
  'scrypt$16384$8$1$2gvvgUTo9knmxLsL5N/pXg==$3YrlPauTWFlddyQ1ul9G09sukXCrblV9A4FuEx7586c=',
  'Empleado', false);

-- ------------------------------------------------------------
-- Categorias (10 Categorias Oficiales)
-- ------------------------------------------------------------
insert into public.categorias (id, nombre, descripcion) values
 ('c1000000-0000-0000-0000-000000000001', 'Cuadernos y Anillados', 'Cuadernos universitarios, anillados, espirales y libretas escolares'),
 ('c1000000-0000-0000-0000-000000000002', 'Escritorio y Bolígrafos', 'Bolígrafos, lápices, portaminas, resaltadores y accesorios de oficina'),
 ('c1000000-0000-0000-0000-000000000003', 'Papelería y Hojas', 'Resmas de papel carta/oficio, hojas de carpeta, papel lustre y cartulinas'),
 ('c1000000-0000-0000-0000-000000000004', 'Arte y Pintura', 'Pinturas acrílicas, acuarelas, témperas, pinceles y lienzos para dibujo'),
 ('c1000000-0000-0000-0000-000000000005', 'Material Escolar', 'Estuches, compases, tijeras punta roma, borradores y tajadores'),
 ('c1000000-0000-0000-0000-000000000006', 'Archivadores y Carpetas', 'Archivadores de palanca tamaño oficio, carpetas de plástico y sobres manila'),
 ('c1000000-0000-0000-0000-000000000007', 'Textos y Libros', 'Diccionarios escolares, enciclopedias, textos de estudio y literatura'),
 ('c1000000-0000-0000-0000-000000000008', 'Adhesivos y Cintas', 'Cintas de embalaje transparente, pegamentos en barra, siliconas líquidas'),
 ('c1000000-0000-0000-0000-000000000009', 'Calculadoras y Tecnología', 'Calculadoras científicas y estándar, memorias USB y accesorios informáticos'),
 ('c1000000-0000-0000-0000-000000000010', 'Reglería y Geometría', 'Juegos de reglas flexibles 30cm, escuadras, transportadores y escalímetros');

-- ------------------------------------------------------------
-- Proveedores
-- ------------------------------------------------------------
insert into public.proveedores (nombre, contacto, telefono) values
 ('Distribuidora Papelera Bolivia', 'Juan Carlos Rojas', '2 231 4545'),
 ('Librería e Importaciones El Ateneo', 'María Elena Castro', '2 244 7890'),
 ('Comercializadora Faber-Castell', 'Luis Alberto Paredes', '3 322 5566');

-- ------------------------------------------------------------
-- Productos (10 Productos Oficiales con Stock y Precios)
-- ------------------------------------------------------------
insert into public.productos (codigo, nombre, categoria_id, precio_venta, stock, activo) values
 ('CUA-LED100', 'Cuaderno Ledesma 100 Hojas A4', 'c1000000-0000-0000-0000-000000000001', 6.50, 45, true),
 ('BOL-FC07AZ', 'Bolígrafo Faber-Castell 0.7mm Azul', 'c1000000-0000-0000-0000-000000000002', 2.50, 120, true),
 ('PAP-TRZ500', 'Resma Hojas Carta Trazo 500 Hojas', 'c1000000-0000-0000-0000-000000000003', 35.00, 30, true),
 ('ART-PEL12C', 'Set Pinturas Acrílicas Pelican 12 colores', 'c1000000-0000-0000-0000-000000000004', 28.00, 18, true),
 ('ESC-MAP3PZ', 'Estuche Escolar Maped 3 Piezas', 'c1000000-0000-0000-0000-000000000005', 15.00, 25, true),
 ('ARC-PALOF', 'Archivador de Palanca Tamaño Oficio', 'c1000000-0000-0000-0000-000000000006', 18.00, 35, true),
 ('LIB-SANTIL', 'Diccionario Escolar Ilustrado Santillana', 'c1000000-0000-0000-0000-000000000007', 45.00, 12, true),
 ('ADH-CIN48M', 'Cinta Embalaje Transparente 48mm', 'c1000000-0000-0000-0000-000000000008', 8.00, 50, true),
 ('TEC-FX991L', 'Calculadora Científica Casio FX-991LA', 'c1000000-0000-0000-0000-000000000009', 130.00, 8, true),
 ('REG-FLEX30', 'Juego de Reglas Flexibles 30cm', 'c1000000-0000-0000-0000-000000000010', 12.00, 40, true);

-- ------------------------------------------------------------
-- Compras historicas (usuario admin; fechas en las ultimas 3 semanas)
-- ------------------------------------------------------------
insert into public.compras (proveedor_id, usuario_id, fecha, total)
select p.id, u.id, current_date - 21, 1040.80
  from public.proveedores p, public.usuarios u
 where p.nombre = 'Distribuidora Papelera Bolivia' and u.usuario = 'gustavo';

insert into public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario)
select c.id, p.id, 40, 22.00 from public.compras c, public.productos p where c.fecha = current_date - 21 and p.codigo = 'RPA-503'
union all
select c.id, p.id, 24, 4.20  from public.compras c, public.productos p where c.fecha = current_date - 21 and p.codigo = 'CUA-100'
union all
select c.id, p.id, 50, 1.20  from public.compras c, public.productos p where c.fecha = current_date - 21 and p.codigo = 'HCT-002';

insert into public.compras (proveedor_id, usuario_id, fecha, total)
select p.id, u.id, current_date - 12, 448.80
  from public.proveedores p, public.usuarios u
 where p.nombre = 'Comercializadora Faber-Castell' and u.usuario = 'gustavo';

insert into public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario)
select c.id, p.id, 48, 2.80 from public.compras c, public.productos p where c.fecha = current_date - 12 and p.codigo = 'BOL-AZ'
union all
select c.id, p.id, 48, 2.80 from public.compras c, public.productos p where c.fecha = current_date - 12 and p.codigo = 'BOL-NG'
union all
select c.id, p.id, 10, 18.00 from public.compras c, public.productos p where c.fecha = current_date - 12 and p.codigo = 'MRK-120';

insert into public.compras (proveedor_id, usuario_id, fecha, total)
select p.id, u.id, current_date - 6, 550.00
  from public.proveedores p, public.usuarios u
 where p.nombre = 'Librería e Importaciones El Ateneo' and u.usuario = 'gustavo';

insert into public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario)
select c.id, p.id, 6, 85.00 from public.compras c, public.productos p where c.fecha = current_date - 6 and p.codigo = 'CAL-201'
union all
select c.id, p.id, 40, 1.00 from public.compras c, public.productos p where c.fecha = current_date - 6 and p.codigo = 'CRT-014';

insert into public.compras (proveedor_id, usuario_id, fecha, total)
select p.id, u.id, current_date - 2, 490.40
  from public.proveedores p, public.usuarios u
 where p.nombre = 'Distribuidora Papelera Bolivia' and u.usuario = 'gustavo';

insert into public.detalle_compras (compra_id, producto_id, cantidad, precio_unitario)
select c.id, p.id, 20, 22.00 from public.compras c, public.productos p where c.fecha = current_date - 2 and p.codigo = 'RPA-503'
union all
select c.id, p.id, 12, 4.20  from public.compras c, public.productos p where c.fecha = current_date - 2 and p.codigo = 'CUA-100';

-- ------------------------------------------------------------
-- Ventas historicas (hoy y dias previos; cliente libre, sin tabla clientes)
-- ------------------------------------------------------------
insert into public.ventas (usuario_id, cliente, fecha, metodo_pago, total)
select u.id, 'Cliente mostrador',          current_date,     'Efectivo', 133.00 from public.usuarios u where u.usuario = 'gustavo';
insert into public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario)
select v.id, p.id, 2, 6.50  from public.ventas v, public.productos p where v.fecha = current_date and p.codigo = 'CUA-100'
union all
select v.id, p.id, 1, 120.00 from public.ventas v, public.productos p where v.fecha = current_date and p.codigo = 'CAL-201';

insert into public.ventas (usuario_id, cliente, fecha, metodo_pago, total)
select u.id, 'Liceo Santa Cruz',             current_date - 1, 'QR',       123.00 from public.usuarios u where u.usuario = 'gustavo';
insert into public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario)
select v.id, p.id, 3, 28.00 from public.ventas v, public.productos p where v.fecha = current_date - 1 and p.codigo = 'RPA-503'
union all
select v.id, p.id, 1, 39.00 from public.ventas v, public.productos p where v.fecha = current_date - 1 and p.codigo = 'MRK-120';

insert into public.ventas (usuario_id, cliente, fecha, metodo_pago, total)
select u.id, 'Sra. Vargas',                  current_date - 2, 'Efectivo', 37.00 from public.usuarios u where u.usuario = 'gustavo';
insert into public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario)
select v.id, p.id, 5, 5.00 from public.ventas v, public.productos p where v.fecha = current_date - 2 and p.codigo = 'BOL-AZ'
union all
select v.id, p.id, 4, 3.00 from public.ventas v, public.productos p where v.fecha = current_date - 2 and p.codigo = 'CRT-014';

insert into public.ventas (usuario_id, cliente, fecha, metodo_pago, total)
select u.id, 'Universidad Mayor de San Andrés', current_date - 4, 'Tarjeta', 380.00 from public.usuarios u where u.usuario = 'gustavo';
insert into public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario)
select v.id, p.id, 2, 120.00 from public.ventas v, public.productos p where v.fecha = current_date - 4 and p.codigo = 'CAL-201'
union all
select v.id, p.id, 5, 28.00 from public.ventas v, public.productos p where v.fecha = current_date - 4 and p.codigo = 'RPA-503';

insert into public.ventas (usuario_id, cliente, fecha, metodo_pago, total)
select u.id, 'Papelería El Rincón',          current_date - 9, 'Efectivo', 133.00 from public.usuarios u where u.usuario = 'gustavo';
insert into public.detalle_ventas (venta_id, producto_id, cantidad, precio_unitario)
select v.id, p.id, 10, 2.50 from public.ventas v, public.productos p where v.fecha = current_date - 9 and p.codigo = 'HCT-002'
union all
select v.id, p.id, 6, 5.00 from public.ventas v, public.productos p where v.fecha = current_date - 9 and p.codigo = 'BOL-NG'
union all
select v.id, p.id, 2, 39.00 from public.ventas v, public.productos p where v.fecha = current_date - 9 and p.codigo = 'MRK-120';

-- ------------------------------------------------------------
-- Reactivar triggers de stock
-- ------------------------------------------------------------
alter table public.detalle_compras enable trigger trg_stock_compras;
alter table public.detalle_ventas enable trigger trg_stock_ventas;

commit;