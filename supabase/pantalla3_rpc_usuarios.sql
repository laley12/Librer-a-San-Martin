-- RPCs DE ADMINISTRACIÓN DE CUENTAS (las consume seguridad.html)
-- La contraseña se hashéa con crypt()/gen_salt('bf') dentro de PostgreSQL: el
-- navegador nunca ve ni envía hashes. Además el solicitante debe tener rol
-- Admin General o Supervisor para poder crear, editar o bloquear cuentas.
-- ==============================================================================

-- pgcrypto puede vivir en `extensions` (viene instalado) o en `public`; las
-- funciones lo resuelven porque search_path incluye ambos.
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

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
