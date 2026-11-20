-- ==============================================================================
-- PARCHE 2026-11-16 — alta del primer administrador
-- Error que devolvía el login:
--   "function gen_salt(unknown, integer) does not exist"
--
-- Causa: Supabase ya trae pgcrypto instalado en el esquema `extensions`, así que
-- el CREATE EXTENSION del script maestro no hizo nada. Las dos RPCs de acceso
-- quedaron con `search_path = public, pg_temp` y por eso no encontraban
-- crypt() / gen_salt() al hashear la contraseña.
--
-- Solución: 3 líneas, sin borrar nada. Pegar completo en SQL Editor y ejecutar
-- con Ctrl+Enter. Es idempotente (se puede repetir sin daño).
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

ALTER FUNCTION public.fn_iniciar_sesion(text, text)
  SET search_path = public, extensions, pg_temp;

ALTER FUNCTION public.fn_crear_primer_admin(text, text, text, text)
  SET search_path = public, extensions, pg_temp;

-- Verificación: las dos funciones deben mostrar {search_path=public,extensions,pg_temp}
SELECT proname, proconfig
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND proname IN ('fn_iniciar_sesion', 'fn_crear_primer_admin')
ORDER BY proname;
