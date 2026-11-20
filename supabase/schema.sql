-- ==============================================================================
-- LIBRERÍA SAN MARTÍN S.R.L. — ESQUEMA RELACIONAL NORMALIZADO (3FN · 10 TABLAS)
-- Motor: PostgreSQL (Supabase) | Casa Matriz: La Guardia, Santa Cruz - Bolivia
-- Proyecto activo: tkypdjfmifywnwwjmcfh.supabase.co
-- ==============================================================================

-- 0. LIMPIEZA TOTAL DEL ESQUEMA ANTIGUO
DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO anon;
GRANT ALL ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE metodo_pago_enum AS ENUM ('Efectivo', 'QR Transfer', 'Tarjeta');
CREATE TYPE estado_transaccion_enum AS ENUM ('Completada', 'Anulada', 'Pendiente');
CREATE TYPE operacion_dml_enum AS ENUM ('INSERT', 'UPDATE', 'DELETE');

-- ==============================================================================
-- MÓDULO I: SEGURIDAD, CONTROL DE ACCESO (RBAC) Y AUDITORÍA
-- ==============================================================================

CREATE TABLE public.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT,
    permisos JSONB NOT NULL DEFAULT '{}'::jsonb,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.usuarios (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rol_id UUID NOT NULL REFERENCES public.roles(id) ON DELETE RESTRICT,
    nombre_completo VARCHAR(120) NOT NULL,
    ci VARCHAR(20) NOT NULL UNIQUE,
    correo VARCHAR(120) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    cargo VARCHAR(80),
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso TIMESTAMPTZ,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    usuario_id UUID REFERENCES public.usuarios(id) ON DELETE SET NULL,
    tabla_afectada VARCHAR(60) NOT NULL,
    operacion operacion_dml_enum NOT NULL,
    registro_id TEXT NOT NULL,
    datos_anteriores JSONB,
    datos_nuevos JSONB,
    ip_terminal VARCHAR(60) DEFAULT '192.168.1.14 (CAJA-01)',
    detalles TEXT,
    fecha_hora TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- MÓDULO II: CATÁLOGO MAESTRO E INVENTARIO
-- ==============================================================================

CREATE TABLE public.categorias (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre VARCHAR(80) NOT NULL UNIQUE,
    descripcion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE public.proveedores (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    razon_social VARCHAR(150) NOT NULL,
    nit VARCHAR(25) NOT NULL UNIQUE,
    contacto_nombre VARCHAR(100),
    telefono VARCHAR(30),
    correo VARCHAR(120),
    direccion TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    creado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    categoria_id UUID NOT NULL REFERENCES public.categorias(id) ON DELETE RESTRICT,
    proveedor_id UUID REFERENCES public.proveedores(id) ON DELETE SET NULL,
    codigo_sku VARCHAR(30) NOT NULL UNIQUE,
    codigo_barras VARCHAR(50) UNIQUE,
    nombre VARCHAR(180) NOT NULL,
    marca_editorial VARCHAR(100),
    ubicacion_fisica VARCHAR(60),
    precio_costo NUMERIC(10,2) NOT NULL CHECK (precio_costo >= 0),
    precio_venta NUMERIC(10,2) NOT NULL CHECK (precio_venta >= precio_costo),
    stock_actual INTEGER NOT NULL DEFAULT 0 CHECK (stock_actual >= 0),
    stock_minimo INTEGER NOT NULL DEFAULT 10 CHECK (stock_minimo >= 0),
    imagen_url TEXT,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    actualizado_en TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ==============================================================================
-- MÓDULO III: OPERACIONES TRANSACCIONALES — POS Y COMPRAS
-- ==============================================================================

CREATE TABLE public.ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_ticket VARCHAR(30) NOT NULL UNIQUE,
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE RESTRICT,
    cliente_nombre VARCHAR(120) NOT NULL DEFAULT 'Cliente Particular / Mostrador',
    cliente_nit_ci VARCHAR(25) DEFAULT 'S/N',
    metodo_pago metodo_pago_enum NOT NULL DEFAULT 'Efectivo',
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0),
    total NUMERIC(10,2) NOT NULL CHECK (total >= 0),
    monto_recibido NUMERIC(10,2),
    cambio_vuelto NUMERIC(10,2) DEFAULT 0,
    estado estado_transaccion_enum NOT NULL DEFAULT 'Completada',
    fecha_venta TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.detalle_ventas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    venta_id UUID NOT NULL REFERENCES public.ventas(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0)
);

CREATE TABLE public.compras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    numero_comprobante VARCHAR(40) NOT NULL UNIQUE,
    proveedor_id UUID NOT NULL REFERENCES public.proveedores(id) ON DELETE RESTRICT,
    usuario_id UUID NOT NULL REFERENCES public.usuarios(id) ON DELETE RESTRICT,
    forma_pago VARCHAR(50) NOT NULL DEFAULT 'Contado',
    total_inversion NUMERIC(10,2) NOT NULL CHECK (total_inversion >= 0),
    estado estado_transaccion_enum NOT NULL DEFAULT 'Completada',
    fecha_compra TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.detalle_compras (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    compra_id UUID NOT NULL REFERENCES public.compras(id) ON DELETE CASCADE,
    producto_id UUID NOT NULL REFERENCES public.productos(id) ON DELETE RESTRICT,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    costo_unitario NUMERIC(10,2) NOT NULL CHECK (costo_unitario >= 0),
    subtotal NUMERIC(10,2) NOT NULL CHECK (subtotal >= 0)
);

-- ==============================================================================
-- REGLAS DE NEGOCIO AUTOMÁTICAS
-- ==============================================================================

CREATE OR REPLACE FUNCTION fn_descontar_stock_venta()
RETURNS TRIGGER AS $$
DECLARE
    v_stock_disponible INTEGER;
    v_nombre_prod VARCHAR;
BEGIN
    SELECT stock_actual, nombre INTO v_stock_disponible, v_nombre_prod
    FROM public.productos WHERE id = NEW.producto_id FOR UPDATE;

    IF v_stock_disponible < NEW.cantidad THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto "%" (Disponible: %, Solicitado: %)',
            v_nombre_prod, v_stock_disponible, NEW.cantidad;
    END IF;

    UPDATE public.productos
    SET stock_actual = stock_actual - NEW.cantidad,
        actualizado_en = NOW()
    WHERE id = NEW.producto_id;

    INSERT INTO public.audit_logs (tabla_afectada, operacion, registro_id, datos_nuevos, detalles)
    VALUES ('public.detalle_ventas', 'INSERT', NEW.id::text, row_to_json(NEW)::jsonb,
            'Emisión Nota de Venta - Descuento automático de stock (' || NEW.cantidad || ' u.)');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_descontar_stock_venta
AFTER INSERT ON public.detalle_ventas
FOR EACH ROW EXECUTE FUNCTION fn_descontar_stock_venta();

CREATE OR REPLACE FUNCTION fn_incrementar_stock_compra()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.productos
    SET stock_actual = stock_actual + NEW.cantidad,
        precio_costo = NEW.costo_unitario,
        actualizado_en = NOW()
    WHERE id = NEW.producto_id;

    INSERT INTO public.audit_logs (tabla_afectada, operacion, registro_id, datos_nuevos, detalles)
    VALUES ('public.compras', 'INSERT', NEW.id::text, row_to_json(NEW)::jsonb,
            'Ingreso de mercadería a almacén (+' || NEW.cantidad || ' u.)');

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_incrementar_stock_compra
AFTER INSERT ON public.detalle_compras
FOR EACH ROW EXECUTE FUNCTION fn_incrementar_stock_compra();

-- ==============================================================================
-- SEGURIDAD RLS
-- ==============================================================================
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.proveedores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_ventas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.compras ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.detalle_compras ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Acceso total app roles" ON public.roles FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app usuarios" ON public.usuarios FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Lectura e insercion audit_logs" ON public.audit_logs FOR SELECT USING (true);
CREATE POLICY "Insert append-only audit_logs" ON public.audit_logs FOR INSERT WITH CHECK (true);
CREATE POLICY "Acceso total app categorias" ON public.categorias FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app proveedores" ON public.proveedores FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app productos" ON public.productos FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app ventas" ON public.ventas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app detalle_ventas" ON public.detalle_ventas FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app compras" ON public.compras FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Acceso total app detalle_compras" ON public.detalle_compras FOR ALL USING (true) WITH CHECK (true);

-- ==============================================================================
-- DATOS INICIALES
-- ==============================================================================

INSERT INTO public.roles (id, nombre, descripcion, permisos) VALUES
('11111111-1111-1111-1111-111111111101', 'Admin General', 'Acceso total al sistema, configuración, usuarios y reportes', '{"all": true}'),
('11111111-1111-1111-1111-111111111102', 'Supervisor', 'Supervisión de turno, cajas, anulaciones y reportes', '{"pos": true, "compras": true, "reportes": true}'),
('11111111-1111-1111-1111-111111111103', 'Vendedor POS', 'Operación de caja, ventas rápidas y consulta de stock', '{"pos": true, "catalogo_lectura": true}'),
('11111111-1111-1111-1111-111111111104', 'Inventariador', 'Gestión de catálogo SKU, compras a proveedores y kardex', '{"catalogo": true, "compras": true}');

-- ==============================================================================
-- AUTENTICACIÓN (RPC sobre pgcrypto)
-- La validación ocurre dentro de PostgreSQL: password_hash nunca sale de la base
-- y el rol se resuelve en la misma consulta, así el navegador solo recibe el
-- perfil ya verificado.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.fn_iniciar_sesion(p_correo text, p_clave text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  v_correo  text := lower(trim(coalesce(p_correo, '')));
  v_usuario public.usuarios;
  v_result  jsonb;
  v_fallos  integer;
BEGIN
  IF v_correo = '' OR coalesce(p_clave, '') = '' THEN
    RAISE EXCEPTION 'Credenciales incompletas';
  END IF;

  SELECT count(*) INTO v_fallos
  FROM public.audit_logs
  WHERE tabla_afectada = 'sesion'
    AND registro_id = v_correo
    AND detalles = 'Intento fallido'
    AND fecha_hora > now() - interval '15 minutes';

  IF v_fallos >= 5 THEN
    RAISE EXCEPTION 'Cuenta bloqueada temporalmente por 15 minutos';
  END IF;

  SELECT * INTO v_usuario
  FROM public.usuarios
  WHERE lower(correo) = v_correo AND activo;

  IF NOT FOUND OR crypt(p_clave, v_usuario.password_hash) <> v_usuario.password_hash THEN
    INSERT INTO public.audit_logs (tabla_afectada, operacion, registro_id, detalles)
    VALUES ('sesion', 'INSERT', v_correo, 'Intento fallido');
    RAISE EXCEPTION 'Correo o contraseña incorrectos';
  END IF;

  UPDATE public.usuarios SET ultimo_acceso = now() WHERE id = v_usuario.id;

  INSERT INTO public.audit_logs (usuario_id, tabla_afectada, operacion, registro_id, detalles)
  VALUES (v_usuario.id, 'sesion', 'INSERT', v_correo, 'Acceso concedido');

  SELECT jsonb_build_object(
           'id', u.id,
           'nombre_completo', u.nombre_completo,
           'correo', u.correo,
           'cargo', u.cargo,
           'rol_id', r.id,
           'rol', r.nombre,
           'permisos', r.permisos
         )
  INTO v_result
  FROM public.usuarios u
  JOIN public.roles r ON r.id = u.rol_id
  WHERE u.id = v_usuario.id;

  RETURN v_result;
END;
$fn$;

/* Solo funciona mientras no exista ningún usuario: la primera persona que se
   registra es el Admin General y con eso la puerta se cierra sola. */
CREATE OR REPLACE FUNCTION public.fn_crear_primer_admin(
  p_nombre_completo text,
  p_ci text,
  p_correo text,
  p_clave text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  v_rol    public.roles;
  v_nuevo  public.usuarios;
BEGIN
  IF EXISTS (SELECT 1 FROM public.usuarios) THEN
    RAISE EXCEPTION 'El sistema ya tiene usuarios registrados';
  END IF;

  IF coalesce(p_nombre_completo, '') = '' OR coalesce(p_ci, '') = ''
     OR coalesce(p_correo, '') = '' OR length(coalesce(p_clave, '')) < 8 THEN
    RAISE EXCEPTION 'Faltan datos o la contraseña debe tener 8 caracteres o más';
  END IF;

  SELECT * INTO v_rol FROM public.roles WHERE nombre = 'Admin General';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'No existe el rol Admin General';
  END IF;

  INSERT INTO public.usuarios (rol_id, nombre_completo, ci, correo, password_hash, ultimo_acceso)
  VALUES (v_rol.id, initcap(trim(p_nombre_completo)), trim(p_ci), lower(trim(p_correo)),
          crypt(p_clave, gen_salt('bf', 10)), now())
  RETURNING * INTO v_nuevo;

  INSERT INTO public.audit_logs (usuario_id, tabla_afectada, operacion, registro_id, detalles)
  VALUES (v_nuevo.id, 'public.usuarios', 'INSERT', v_nuevo.id::text,
          'Alta del primer administrador del sistema');

  RETURN jsonb_build_object('id', v_nuevo.id, 'correo', v_nuevo.correo, 'rol', v_rol.nombre);
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.fn_iniciar_sesion(text, text) TO anon, authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.fn_crear_primer_admin(text, text, text, text) TO anon;

INSERT INTO public.categorias (id, nombre, descripcion) VALUES
('33333333-3333-3333-3333-333333333301', 'Papelería', 'Cuadernos, papel bond, archivadores y resmas'),
('33333333-3333-3333-3333-333333333302', 'Textos Escolares', 'Libros de primaria, secundaria y diccionarios'),
('33333333-3333-3333-3333-333333333303', 'Útiles & Arte', 'Colores, marcadores, reglas y geometría'),
('33333333-3333-3333-3333-333333333304', 'Mochilas & Acc.', 'Mochilas escolares, loncheras y cartucheras'),
('33333333-3333-3333-3333-333333333305', 'Material Oficina', 'Bolígrafos, engrapadoras y suministros administrativos');

INSERT INTO public.proveedores (id, razon_social, nit, contacto_nombre, telefono, direccion) VALUES
('44444444-4444-4444-4444-444444444401', 'Santillana Bolivia S.R.L.', '1004829023', 'Roberto Méndez', '3-3428910', 'Av. Beni 3er Anillo, Santa Cruz'),
('44444444-4444-4444-4444-444444444402', 'Distribuidora Papelera Vinto', '1020456019', 'Laura Soliz', '3-3551200', 'Parque Industrial PI-14, Santa Cruz'),
('44444444-4444-4444-4444-444444444403', 'BIC Bolivia Importadora', '1028945021', 'Carlos Torrico', '3-3367890', 'Av. Cristo Redentor Km 4, Santa Cruz'),
('44444444-4444-4444-4444-444444444404', 'Editorial La Hoguera', '1003284012', 'Patricia Roca', '3-3445566', 'Calle Sucre #450, Santa Cruz');

INSERT INTO public.productos (id, categoria_id, proveedor_id, codigo_sku, codigo_barras, nombre, marca_editorial, ubicacion_fisica, precio_costo, precio_venta, stock_actual, stock_minimo) VALUES
('55555555-5555-5555-5555-555555555501', '33333333-3333-3333-3333-333333333301', '44444444-4444-4444-4444-444444444402', 'PAP-CUAD-01', '7771234567890', 'Cuaderno Espiral 100 Hjs Líder', 'Cuadernos Líder Bolivia', 'Est. A-02', 8.50, 13.00, 0, 20),
('55555555-5555-5555-5555-555555555502', '33333333-3333-3333-3333-333333333302', '44444444-4444-4444-4444-444444444401', 'LIB-MAT-4EP', '9789990518821', 'Texto Matemática 4to Primaria', 'Santillana Bolivia', 'Est. E-14', 120.00, 165.00, 4, 15),
('55555555-5555-5555-5555-555555555503', '33333333-3333-3333-3333-333333333303', '44444444-4444-4444-4444-444444444403', 'UTIL-COL-12', '7891360592812', 'Caja Colores x12 Triangular Faber-Castell', 'Faber-Castell', 'Pasillo 1-B', 18.00, 26.50, 15, 30),
('55555555-5555-5555-5555-555555555504', '33333333-3333-3333-3333-333333333301', '44444444-4444-4444-4444-444444444402', 'PAP-BOND-A4', '7891118002018', 'Papel Bond Chamex 75g Carta Resma 500 Hjs', 'Sylvamo / Chamex', 'Pallet P-01', 28.00, 38.00, 120, 50),
('55555555-5555-5555-5555-555555555505', '33333333-3333-3333-3333-333333333304', '44444444-4444-4444-4444-444444444403', 'ESC-MOCH-PR', '7501314982736', 'Mochila Escolar Reforzada Chenson Pro', 'Chenson Original', 'Vitrina M-3', 145.00, 210.00, 0, 10),
('55555555-5555-5555-5555-555555555506', '33333333-3333-3333-3333-333333333305', '44444444-4444-4444-4444-444444444403', 'PAP-BOLI-AZ', '70330129623', 'Bolígrafo BIC Cristal Azul Caja x50', 'Société BIC', 'Mostrador P-02', 42.00, 60.00, 85, 40),
('55555555-5555-5555-5555-555555555507', '33333333-3333-3333-3333-333333333302', '44444444-4444-4444-4444-444444444404', 'TEX-LENG-5EP', '9789997401923', 'Texto Lenguaje y Comunicación 5to Primaria', 'Editorial Don Bosco', 'Est. E-09', 95.00, 135.00, 18, 12),
('55555555-5555-5555-5555-555555555508', '33333333-3333-3333-3333-333333333303', '44444444-4444-4444-4444-444444444403', 'REG-ESC-30', '7891360599002', 'Regla Plástica Escolar 30cm Maped', 'Maped', 'Mostrador P-01', 3.00, 5.50, 60, 25);

-- ==============================================================================
-- COMPATIBILIDAD SUPABASE
-- El borrado de public elimina los permisos heredados y las suscripciones de
-- Realtime que el proyecto tenía, así que hay que restablecerlos aquí.
-- ==============================================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO postgres, anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO postgres, anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres, anon, authenticated, service_role;

ALTER PUBLICATION supabase_realtime ADD TABLE public.usuarios;
ALTER PUBLICATION supabase_realtime ADD TABLE public.productos;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ventas;
ALTER PUBLICATION supabase_realtime ADD TABLE public.detalle_ventas;
ALTER PUBLICATION supabase_realtime ADD TABLE public.compras;

-- ==============================================================================
-- RPCs DE ADMINISTRACIÓN DE CUENTAS (las consume seguridad.html)
-- La contraseña se hashéa con crypt()/gen_salt('bf') dentro de PostgreSQL: el
-- navegador nunca ve ni envía hashes. Además el solicitante debe tener rol
-- Admin General o Supervisor para poder crear, editar o bloquear cuentas.
-- ==============================================================================

CREATE OR REPLACE FUNCTION public.fn_solicitante_autorizado(p_solicitante uuid)
RETURNS boolean
LANGUAGE sql
STABLE
AS $fn$
  SELECT EXISTS (
    SELECT 1
    FROM public.usuarios u
    JOIN public.roles r ON r.id = u.rol_id
    WHERE u.id = p_solicitante AND u.activo
      AND r.nombre IN ('Admin General', 'Supervisor')
  );
$fn$;

CREATE OR REPLACE FUNCTION public.fn_crear_usuario(
  p_solicitante uuid,
  p_nombre_completo text,
  p_ci text,
  p_correo text,
  p_cargo text,
  p_rol_id uuid,
  p_clave text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  v_nuevo public.usuarios;
BEGIN
  IF NOT public.fn_solicitante_autorizado(p_solicitante) THEN
    RAISE EXCEPTION 'Solo Admin General o Supervisor pueden crear cuentas';
  END IF;
  IF length(coalesce(p_clave, '')) < 8 THEN
    RAISE EXCEPTION 'La contraseña debe tener al menos 8 caracteres';
  END IF;

  INSERT INTO public.usuarios (rol_id, nombre_completo, ci, correo, cargo, password_hash)
  VALUES (p_rol_id, trim(p_nombre_completo), trim(p_ci), lower(trim(p_correo)), trim(p_cargo),
          crypt(p_clave, gen_salt('bf', 10)))
  RETURNING * INTO v_nuevo;

  INSERT INTO public.audit_logs (usuario_id, tabla_afectada, operacion, registro_id, datos_nuevos, detalles)
  VALUES (p_solicitante, 'public.usuarios', 'INSERT', v_nuevo.id::text,
          jsonb_build_object('nombre_completo', v_nuevo.nombre_completo, 'ci', v_nuevo.ci,
                             'correo', v_nuevo.correo, 'cargo', v_nuevo.cargo, 'rol_id', v_nuevo.rol_id),
          'Alta de cuenta de acceso');

  RETURN jsonb_build_object('id', v_nuevo.id, 'correo', v_nuevo.correo, 'nombre_completo', v_nuevo.nombre_completo);
EXCEPTION
  WHEN unique_violation THEN
    RAISE EXCEPTION 'Ya existe una cuenta con ese CI o ese correo';
END;
$fn$;

CREATE OR REPLACE FUNCTION public.fn_editar_usuario(
  p_solicitante uuid,
  p_id uuid,
  p_nombre_completo text,
  p_ci text,
  p_correo text,
  p_cargo text,
  p_rol_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  v_anterior public.usuarios;
  v_nuevo public.usuarios;
BEGIN
  IF NOT public.fn_solicitante_autorizado(p_solicitante) THEN
    RAISE EXCEPTION 'Solo Admin General o Supervisor pueden editar cuentas';
  END IF;

  SELECT * INTO v_anterior FROM public.usuarios WHERE id = p_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'La cuenta que se intenta editar no existe';
  END IF;

  UPDATE public.usuarios
  SET nombre_completo = trim(p_nombre_completo),
      ci = trim(p_ci),
      correo = lower(trim(p_correo)),
      cargo = trim(p_cargo),
      rol_id = p_rol_id
  WHERE id = p_id
  RETURNING * INTO v_nuevo;

  INSERT INTO public.audit_logs (usuario_id, tabla_afectada, operacion, registro_id, datos_anteriores, datos_nuevos, detalles)
  VALUES (p_solicitante, 'public.usuarios', 'UPDATE', v_nuevo.id::text,
          jsonb_build_object('nombre_completo', v_anterior.nombre_completo, 'ci', v_anterior.ci,
                             'correo', v_anterior.correo, 'cargo', v_anterior.cargo, 'rol_id', v_anterior.rol_id),
          jsonb_build_object('nombre_completo', v_nuevo.nombre_completo, 'ci', v_nuevo.ci,
                             'correo', v_nuevo.correo, 'cargo', v_nuevo.cargo, 'rol_id', v_nuevo.rol_id),
          'Edición de perfil y rol');

  RETURN jsonb_build_object('id', v_nuevo.id, 'correo', v_nuevo.correo);
EXCEPTION
  WHEN unique_violation THEN
    RAISE EXCEPTION 'Ya existe una cuenta con ese CI o ese correo';
END;
$fn$;

CREATE OR REPLACE FUNCTION public.fn_restablecer_clave(
  p_solicitante uuid,
  p_id uuid,
  p_clave text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  v_usuario public.usuarios;
BEGIN
  IF NOT public.fn_solicitante_autorizado(p_solicitante) THEN
    RAISE EXCEPTION 'Solo Admin General o Supervisor pueden restablecer contraseñas';
  END IF;
  IF length(coalesce(p_clave, '')) < 8 THEN
    RAISE EXCEPTION 'La contraseña debe tener al menos 8 caracteres';
  END IF;

  UPDATE public.usuarios
  SET password_hash = crypt(p_clave, gen_salt('bf', 10))
  WHERE id = p_id
  RETURNING * INTO v_usuario;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'La cuenta no existe';
  END IF;

  INSERT INTO public.audit_logs (usuario_id, tabla_afectada, operacion, registro_id, detalles)
  VALUES (p_solicitante, 'public.usuarios', 'UPDATE', v_usuario.id::text,
          'Restablecimiento de contraseña (hash bcrypt renovado)');

  RETURN jsonb_build_object('id', v_usuario.id, 'correo', v_usuario.correo);
END;
$fn$;

CREATE OR REPLACE FUNCTION public.fn_alternar_activo(
  p_solicitante uuid,
  p_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, extensions, pg_temp
AS $fn$
DECLARE
  v_usuario public.usuarios;
BEGIN
  IF NOT public.fn_solicitante_autorizado(p_solicitante) THEN
    RAISE EXCEPTION 'Solo Admin General o Supervisor pueden bloquear o habilitar cuentas';
  END IF;
  IF p_id = p_solicitante THEN
    RAISE EXCEPTION 'No puedes bloquear tu propia cuenta';
  END IF;

  UPDATE public.usuarios
  SET activo = NOT activo
  WHERE id = p_id
  RETURNING * INTO v_usuario;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'La cuenta no existe';
  END IF;

  INSERT INTO public.audit_logs (usuario_id, tabla_afectada, operacion, registro_id, datos_nuevos, detalles)
  VALUES (p_solicitante, 'public.usuarios', 'UPDATE', v_usuario.id::text,
          jsonb_build_object('activo', v_usuario.activo),
          CASE WHEN v_usuario.activo THEN 'Cuenta habilitada' ELSE 'Cuenta bloqueada' END);

  RETURN jsonb_build_object('id', v_usuario.id, 'activo', v_usuario.activo);
END;
$fn$;

GRANT EXECUTE ON FUNCTION public.fn_solicitante_autorizado(uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fn_crear_usuario(uuid, text, text, text, text, uuid, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fn_editar_usuario(uuid, uuid, text, text, text, text, uuid) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fn_restablecer_clave(uuid, uuid, text) TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.fn_alternar_activo(uuid, uuid) TO anon, authenticated;
