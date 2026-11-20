-- ==============================================================================
-- SISTEMA WEB PARA LA GESTIÓN INTEGRAL DE COMPRAS, VENTAS E INVENTARIO
-- LIBRERÍA "SAN MARTÍN" (LA GUARDIA - SANTA CRUZ, BOLIVIA)
-- TESIS DE GRADO - GUSTAVO GABRIEL GUACHALLA ROCHA (UDABOL 2026)
-- SCRIPT DDL: MODELO RELACIONAL NORMALIZADO EN TERCERA FORMA NORMAL (3FN)
-- COMPATIBLE CON SUPABASE CLOUD (POSTGRESQL 15+)
-- ==============================================================================

-- 0. Habilitar extensión para identificadores UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. TABLA: ROLES (RBAC) - Tabla 9 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 2. TABLA: SUCURSALES - Tabla 19 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.sucursales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT,
    telefono VARCHAR(20),
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 3. TABLA: USUARIOS - Tabla 10 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.usuarios (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    clave VARCHAR(255) NOT NULL,
    rol_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE RESTRICT,
    sucursal_id UUID NOT NULL REFERENCES public.sucursales(id) ON DELETE RESTRICT,
    estado BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 4. TABLA: CATEGORIAS - Tabla 11 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.categorias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 5. TABLA: PROVEEDORES - Tabla 12 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.proveedores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(120) NOT NULL,
    contacto VARCHAR(100),
    telefono VARCHAR(20),
    direccion TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 6. TABLA: CLIENTES - Tabla 13 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.clientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nombre VARCHAR(120) NOT NULL,
    nit_ci VARCHAR(20),
    telefono VARCHAR(20),
    email VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 7. TABLA: PRODUCTOS - Tabla 14 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.productos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    codigo_sku VARCHAR(50) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    categoria_id UUID NOT NULL REFERENCES public.categorias(id) ON DELETE RESTRICT,
    precio_costo NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    precio_venta NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    stock INTEGER NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INTEGER NOT NULL DEFAULT 5 CHECK (stock_minimo >= 0),
    activo BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 8. TABLA: COMPRAS (Encabezado) - Tabla 15 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proveedor_id UUID NOT NULL REFERENCES public.proveedores(id) ON DELETE RESTRICT,
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE RESTRICT,
    sucursal_id UUID NOT NULL REFERENCES public.sucursales(id) ON DELETE RESTRICT,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    total NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (total >= 0),
    activo BOOLEAN DEFAULT TRUE NOT NULL
);

-- ------------------------------------------------------------------------------
-- 9. TABLA: DETALLE_COMPRAS - Tabla 16 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.detalle_compras (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    compra_id UUID NOT NULL REFERENCES public.compras(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0)
);

-- ------------------------------------------------------------------------------
-- 10. TABLA: VENTAS (Encabezado POS) - Tabla 17 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.ventas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE RESTRICT,
    sucursal_id UUID NOT NULL REFERENCES public.sucursales(id) ON DELETE RESTRICT,
    cliente_id UUID REFERENCES public.clientes(id) ON DELETE SET NULL,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    metodo_pago VARCHAR(30) NOT NULL DEFAULT 'Efectivo',
    total NUMERIC(12,2) NOT NULL DEFAULT 0.00 CHECK (total >= 0),
    activo BOOLEAN DEFAULT TRUE NOT NULL
);

-- ------------------------------------------------------------------------------
-- 11. TABLA: DETALLE_VENTAS - Tabla 18 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.detalle_ventas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    venta_id UUID NOT NULL REFERENCES public.ventas(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(12,2) NOT NULL CHECK (subtotal >= 0)
);

-- ------------------------------------------------------------------------------
-- 12. TABLA: AUDIT_LOGS (Bitácora Inmutable WORM) - Tabla 20 de la Tesis
-- ------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE SET NULL,
    accion VARCHAR(80) NOT NULL,
    tabla_afectada VARCHAR(60) NOT NULL,
    registro_id VARCHAR(100),
    detalles TEXT,
    fecha TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- ------------------------------------------------------------------------------
-- 13. REGLA INMUTABLE: WORM (Write-Once-Read-Many) PARA AUDIT_LOGS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_bitacora_inmutable()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Violación de Seguridad WORM: Los registros de audit_logs son inmutables y no admiten UPDATE ni DELETE.';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_proteger_bitacora ON public.audit_logs;
CREATE TRIGGER trg_proteger_bitacora
BEFORE UPDATE OR DELETE ON public.audit_logs
FOR EACH ROW EXECUTE FUNCTION trg_bitacora_inmutable();

-- ------------------------------------------------------------------------------
-- 14. POLÍTICAS DE SEGURIDAD ROW LEVEL SECURITY (RLS)
-- ------------------------------------------------------------------------------
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sucursales ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Políticas de lectura anónima/autenticada para la aplicación comercial
CREATE POLICY "Lectura pública de roles" ON public.roles FOR SELECT USING (true);
CREATE POLICY "Lectura pública de sucursales" ON public.sucursales FOR SELECT USING (true);
CREATE POLICY "Lectura pública de categorías" ON public.categorias FOR SELECT USING (true);
CREATE POLICY "Lectura pública de proveedores" ON public.proveedores FOR SELECT USING (true);
CREATE POLICY "Lectura pública de productos" ON public.productos FOR SELECT USING (true);
CREATE POLICY "Lectura pública de clientes" ON public.clientes FOR SELECT USING (true);
CREATE POLICY "Acceso a ventas" ON public.ventas FOR ALL USING (true);
CREATE POLICY "Acceso a detalle_ventas" ON public.detalle_ventas FOR ALL USING (true);
CREATE POLICY "Acceso a compras" ON public.compras FOR ALL USING (true);
CREATE POLICY "Acceso a detalle_compras" ON public.detalle_compras FOR ALL USING (true);
CREATE POLICY "Acceso a auditoría" ON public.audit_logs FOR SELECT USING (true);
CREATE POLICY "Inserción en auditoría" ON public.audit_logs FOR INSERT WITH CHECK (true);

-- ------------------------------------------------------------------------------
-- 15. DATOS SEMILLA INICIALES (SEED DATA)
-- ------------------------------------------------------------------------------
-- Roles
INSERT INTO public.roles (nombre, descripcion) VALUES
('Admin TI', 'Administrador técnico con acceso a seguridad, auditoría y configuraciones'),
('Propietaria', 'Carmen Patricia Molina - Gerente general con acceso administrativo integral'),
('Cajero', 'Operador de caja en mostrador para atención y facturación en el POS'),
('Inventariador', 'Encargado de almacén para reabastecimiento y control de kárdex')
ON CONFLICT (nombre) DO NOTHING;

-- Sucursales
INSERT INTO public.sucursales (nombre, direccion, telefono, activo) VALUES
('Casa Matriz - La Guardia', 'Calle Paraíso, Km 12 Doble Vía a La Guardia', '70252840', true),
('Agencia Santa Cruz', 'Av. Grigotá esq. 2do Anillo', '70252841', true)
ON CONFLICT DO NOTHING;

-- Categorías
INSERT INTO public.categorias (nombre, descripcion) VALUES
('Textos Escolares', 'Libros de texto para primaria y secundaria autorizados por el Ministerio'),
('Literatura y Novelas', 'Obras clásicas, juveniles y novelas de autores nacionales e internacionales'),
('Papelería y Cuadernos', 'Cuadernos empastados, espirales, hojas tamaño carta y oficio'),
('Material de Escritorio y Arte', 'Bolígrafos, lápices de color, marcadores, pinturas y reglas')
ON CONFLICT (nombre) DO NOTHING;

-- Proveedores (Editoriales)
INSERT INTO public.proveedores (nombre, contacto, telefono, direccion) VALUES
('Editorial Santillana S.A.', 'Lic. Marcelo Justiniano', '33458900', 'Av. San Martín #450, Equipetrol'),
('Grupo Editorial Norma', 'Lic. Patricia Arnez', '33567800', 'Calle Warnes #230'),
('Editorial Don Bosco Bolivia', 'Hno. Juan Carlos Ramos', '33221100', 'Calle René Moreno #120')
ON CONFLICT DO NOTHING;

-- Clientes iniciales
INSERT INTO public.clientes (nombre, nit_ci, telefono, email) VALUES
('Cliente General (Sin NIT)', '0', '00000000', 'cliente@sanmartin.com'),
('Colegio Alemán Santa Cruz', '1028374025', '71234567', 'administracion@aleman.edu.bo'),
('Liceo Estudiantil La Guardia', '1058493021', '72345678', 'compras@liceolaguardia.edu.bo')
ON CONFLICT DO NOTHING;
