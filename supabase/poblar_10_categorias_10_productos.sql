-- ============================================================
-- Librería San Martín - 10 Categorías y 10 Productos Oficiales
-- Proyecto Supabase: tkypdjfmifywnwwjmcfh
-- Ejecutar en: Supabase Dashboard -> SQL Editor -> New query -> Run
-- ============================================================

set search_path = public;

-- 1. Insertar las 10 Categorías de Librería
INSERT INTO public.categorias (id, nombre, descripcion) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'Cuadernos y Anillados', 'Cuadernos universitarios, anillados, espirales y libretas escolares'),
  ('c1000000-0000-0000-0000-000000000002', 'Escritorio y Bolígrafos', 'Bolígrafos, lápices, portaminas, resaltadores y accesorios de oficina'),
  ('c1000000-0000-0000-0000-000000000003', 'Papelería y Hojas', 'Resmas de papel carta/oficio, hojas de carpeta, papel lustre y cartulinas'),
  ('c1000000-0000-0000-0000-000000000004', 'Arte y Pintura', 'Pinturas acrílicas, acuarelas, témperas, pinceles y lienzos para dibujo'),
  ('c1000000-0000-0000-0000-000000000005', 'Material Escolar', 'Estuches, compases, tijeras punta roma, borradores y tajadores'),
  ('c1000000-0000-0000-0000-000000000006', 'Archivadores y Carpetas', 'Archivadores de palanca tamaño oficio, carpetas de plástico y sobres manila'),
  ('c1000000-0000-0000-0000-000000000007', 'Textos y Libros', 'Diccionarios escolares, enciclopedias, textos de estudio y literatura'),
  ('c1000000-0000-0000-0000-000000000008', 'Adhesivos y Cintas', 'Cintas de embalaje transparente, pegamentos en barra, siliconas líquidas'),
  ('c1000000-0000-0000-0000-000000000009', 'Calculadoras y Tecnología', 'Calculadoras científicas y estándar, memorias USB y accesorios informáticos'),
  ('c1000000-0000-0000-0000-000000000010', 'Reglería y Geometría', 'Juegos de reglas flexibles 30cm, escuadras, transportadores y escalímetros')
ON CONFLICT (id) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  descripcion = EXCLUDED.descripcion;

-- 2. Insertar los 10 Productos con Stock y Precios Solicitados
INSERT INTO public.productos (codigo, nombre, categoria_id, precio_venta, stock, activo) VALUES
  ('CUA-LED100', 'Cuaderno Ledesma 100 Hojas A4', 'c1000000-0000-0000-0000-000000000001', 6.50, 45, true),
  ('BOL-FC07AZ', 'Bolígrafo Faber-Castell 0.7mm Azul', 'c1000000-0000-0000-0000-000000000002', 2.50, 120, true),
  ('PAP-TRZ500', 'Resma Hojas Carta Trazo 500 Hojas', 'c1000000-0000-0000-0000-000000000003', 35.00, 30, true),
  ('ART-PEL12C', 'Set Pinturas Acrílicas Pelican 12 colores', 'c1000000-0000-0000-0000-000000000004', 28.00, 18, true),
  ('ESC-MAP3PZ', 'Estuche Escolar Maped 3 Piezas', 'c1000000-0000-0000-0000-000000000005', 15.00, 25, true),
  ('ARC-PALOF', 'Archivador de Palanca Tamaño Oficio', 'c1000000-0000-0000-0000-000000000006', 18.00, 35, true),
  ('LIB-SANTIL', 'Diccionario Escolar Ilustrado Santillana', 'c1000000-0000-0000-0000-000000000007', 45.00, 12, true),
  ('ADH-CIN48M', 'Cinta Embalaje Transparente 48mm', 'c1000000-0000-0000-0000-000000000008', 8.00, 50, true),
  ('TEC-FX991L', 'Calculadora Científica Casio FX-991LA', 'c1000000-0000-0000-0000-000000000009', 130.00, 8, true),
  ('REG-FLEX30', 'Juego de Reglas Flexibles 30cm', 'c1000000-0000-0000-0000-000000000010', 12.00, 40, true)
ON CONFLICT (codigo) DO UPDATE SET
  nombre = EXCLUDED.nombre,
  categoria_id = EXCLUDED.categoria_id,
  precio_venta = EXCLUDED.precio_venta,
  stock = EXCLUDED.stock,
  activo = EXCLUDED.activo;
