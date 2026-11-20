-- ==============================================================================
-- DESMONTE TOTAL DE LA BASE EN LA NUBE (proyecto tkypdjfmifywnwwjmcfh)
-- Objetivo: dejar Supabase en cero para reconstruir el sistema desde cero.
--
-- QUÉ SE VA (irreversible):
--   • 10 tablas con sus datos y políticas RLS: roles, usuarios, audit_logs,
--     categorias, proveedores, productos, ventas, detalle_ventas, compras,
--     detalle_compras
--   • 2 triggers y sus funciones: trg_descontar_stock_venta,
--     trg_incrementar_stock_compra
--   • 7 funciones RPC: fn_iniciar_sesion, fn_crear_primer_admin,
--     fn_solicitante_autorizado, fn_crear_usuario, fn_editar_usuario,
--     fn_restablecer_clave, fn_alternar_activo
--   • Consecuencia: se borran Carmen y Luis, FAC-2026-001/002, VTA-2026-0001
--     y los 23 eventos de public.audit_logs. El login deja de funcionar.
--
-- QUÉ NO SE TOCA:
--   • La extensión pgcrypto (vive en el esquema extensions; hace falta para
--     reconstruir). Ningún otro esquema (storage, auth, realtime) se modifica.
--   • La carpeta local supabase/ (es el plano de la reconstrucción).
--
-- CÓMO RECONSTRUIR DESPUÉS (orden exacto):
--   1) supabase/schema.sql
--   2) supabase/seed_libreria.sql  (o poblar_10_categorias_10_productos.sql)
--   3) supabase/pantalla3_rpc_usuarios.sql
--   4) supabase/parche_pgcrypto.sql
--   5) Abrir index.html: al no haber usuarios, el formulario entra solo en
--      modo "alta del primer administrador" y crea a Carmen.
-- ==============================================================================

BEGIN;

/* ---------- 1. Triggers (se van con la tabla, pero se declaran por claridad) ---------- */
DROP TRIGGER IF EXISTS trg_descontar_stock_venta      ON public.detalle_ventas;
DROP TRIGGER IF EXISTS trg_incrementar_stock_compra   ON public.detalle_compras;

/* ---------- 2. Tablas, en orden de dependencia (hijas primero) ---------- */
DROP TABLE IF EXISTS public.detalle_compras CASCADE;
DROP TABLE IF EXISTS public.compras         CASCADE;
DROP TABLE IF EXISTS public.detalle_ventas  CASCADE;
DROP TABLE IF EXISTS public.ventas          CASCADE;
DROP TABLE IF EXISTS public.productos       CASCADE;
DROP TABLE IF EXISTS public.proveedores     CASCADE;
DROP TABLE IF EXISTS public.categorias      CASCADE;
DROP TABLE IF EXISTS public.audit_logs      CASCADE;
DROP TABLE IF EXISTS public.usuarios        CASCADE;
DROP TABLE IF EXISTS public.roles           CASCADE;

/* ---------- 3. Funciones de trigger ---------- */
DROP FUNCTION IF EXISTS public.fn_descontar_stock_venta()      CASCADE;
DROP FUNCTION IF EXISTS public.fn_incrementar_stock_compra()   CASCADE;

/* ---------- 4. Funciones RPC (firma exacta; si cambió, CASCADE las alcanza) ---------- */
DROP FUNCTION IF EXISTS public.fn_iniciar_sesion(text, text)                                CASCADE;
DROP FUNCTION IF EXISTS public.fn_crear_primer_admin(text, text, text, text)                 CASCADE;
DROP FUNCTION IF EXISTS public.fn_solicitante_autorizado(uuid)                               CASCADE;
DROP FUNCTION IF EXISTS public.fn_crear_usuario(uuid, text, text, text, text, uuid, text)    CASCADE;
DROP FUNCTION IF EXISTS public.fn_editar_usuario(uuid, uuid, text, text, text, text, uuid)   CASCADE;
DROP FUNCTION IF EXISTS public.fn_restablecer_clave(uuid, uuid, text)                        CASCADE;
DROP FUNCTION IF EXISTS public.fn_alternar_activo(uuid, uuid)                                CASCADE;

/* ---------- 5. Barrido de sobrantes: cualquier tabla o función que haya
   quedado en public (por ejemplo objetos del sistema anterior). ---------- */
DO $barra$
DECLARE r record;
BEGIN
  FOR r IN SELECT c.relname FROM pg_class c
           JOIN pg_namespace n ON n.oid = c.relnamespace
           WHERE n.nspname = 'public' AND c.relkind IN ('r','p','v','m','s')
  LOOP
    EXECUTE format('DROP %s IF EXISTS public.%I CASCADE',
      CASE r.relkind WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW'
                     WHEN 's' THEN 'SEQUENCE' ELSE 'TABLE' END, r.relname);
  END LOOP;

  FOR r IN SELECT p.oid::regprocedure AS sig FROM pg_proc p
           JOIN pg_namespace n ON n.oid = p.pronamespace
           WHERE n.nspname = 'public'
  LOOP
    EXECUTE format('DROP FUNCTION IF EXISTS %s CASCADE', r.sig);
  END LOOP;
END
$barra$;

COMMIT;

/* ---------- 6. Verificación: las tres consultas deben salir vacías ---------- */
SELECT c.relname AS tabla_quedante
FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind IN ('r','p','v','m','s')
ORDER BY 1;

SELECT p.proname AS funcion_quedante
FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public'
ORDER BY 1;

SELECT schemaname, tablename, policyname
FROM pg_policies WHERE schemaname = 'public'
ORDER BY 1, 2;
