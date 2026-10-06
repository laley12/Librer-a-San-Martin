import { createClient } from "https://esm.sh/@supabase/supabase-js@2.117.2";

export const SUPABASE_URL = "https://tkypdjfmifywnwwjmcfh.supabase.co";
export const SUPABASE_ANON_KEY =
  "sb_publishable_jJy8UBoSuEl7tqiRMvbXxw_V3XtqaCz";

export const sb = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
  auth: { persistSession: true, autoRefreshToken: true },
  realtime: { params: { eventsPerSecond: 10 } },
});

/* ---------------- formatadores ---------------- */
/* "Bs" en vez del símbolo de moneda de la API (que en algunos navegadores
   sale como "BOB" y al ser más largo se cortaba en las tarjetas). */
export const money = (n) =>
  "Bs " + Number(n || 0).toLocaleString("es-BO", {
    minimumFractionDigits: 2, maximumFractionDigits: 2,
  });

export const moneyCorto = (n) => {
  const v = Number(n || 0);
  if (Math.abs(v) >= 1000000) return "Bs " + (v / 1000000).toFixed(1) + "M";
  if (Math.abs(v) >= 1000) return "Bs " + (v / 1000).toFixed(1) + "k";
  return money(v);
};

export const num = (n) => Number(n || 0).toLocaleString("es-BO");

export const fecha = (d) =>
  d ? new Date(d).toLocaleDateString("es-BO", { day: "2-digit", month: "2-digit", year: "2-digit" }) : "—";

export const fechaLarga = (d) =>
  d ? new Date(d).toLocaleDateString("es-BO", { weekday: "long", day: "numeric", month: "long", year: "numeric" }) : "—";

export const hora = (d) =>
  d ? new Date(d).toLocaleTimeString("es-BO", { hour: "2-digit", minute: "2-digit" }) : "—";

export const fechaHora = (d) => (d ? `${fecha(d)} ${hora(d)}` : "—");

export const hace = (d) => {
  if (!d) return "—";
  const s = Math.floor((Date.now() - new Date(d).getTime()) / 1000);
  if (s < 60) return `hace ${s}s`;
  if (s < 3600) return `hace ${Math.floor(s / 60)} min`;
  if (s < 86400) return `hace ${Math.floor(s / 3600)} h`;
  return `hace ${Math.floor(s / 86400)} d`;
};

export const hoyISO = () => new Date().toISOString().slice(0, 10);
export const mesISO = () => new Date().toISOString().slice(0, 7);

/* ---------------- sesión ---------------- */
/* El sistema original (login/login.php) autenticaba con `usuarios.usuario`.
   Supabase Auth exige un correo, así que cada cuenta real usa un correo
   sintético derivado del usuario:  Gustavo  ->  gustavo@libreriasanmartin.app
   El login acepta indistintamente el usuario o el correo completo. */
export const DOMINIO_CUENTAS = "libreriasanmartin.app";

export function correoDeCuenta(usuario) {
  const v = String(usuario || "").trim().toLowerCase();
  if (!v) return "";
  return v.includes("@") ? v : `${v}@${DOMINIO_CUENTAS}`;
}

export function usuarioDeCorreo(email) {
  return String(email || "").split("@")[0];
}

/* El login NO va contra sb.auth.signInWithPassword: Supabase Auth exige
   contraseñas de 6 caracteres o más y la librería usa PINs de 5 dígitos
   (Samuel / 12345). El PIN se verifica en el servidor (/api/login) y, si es
   correcto, el servidor devuelve una sesión de Supabase Auth ya emitida.
   A partir de aquí la app trabaja con una sesión normal: RLS, Realtime y
   todo lo demás siguen igual. */
export async function signIn(usuario, password) {
  const r = await fetch("/api/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ usuario, password }),
  });
  const j = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(j.error || "Usuario o contraseña incorrectos");
  const { error } = await sb.auth.setSession({
    access_token: j.access_token,
    refresh_token: j.refresh_token,
  });
  if (error) throw new Error(error.message);
  return j;
}

export async function cambiarClave(nueva) {
  const { data, error: eSession } = await sb.auth.getSession();
  if (eSession || !data?.session) throw new Error("Sesión no válida");
  const r = await fetch("/api/clave", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${data.session.access_token}`,
    },
    body: JSON.stringify({ password: nueva }),
  });
  const j = await r.json().catch(() => ({}));
  if (!r.ok) throw new Error(j.error || "No se pudo guardar la clave");
}

export async function signOut() {
  await sb.auth.signOut();
}

export async function perfilActual() {
  console.log('[LSM] perfilActual called');
  const { data: auth, error: authError } = await sb.auth.getUser();
  console.log('[LSM] perfilActual - getUser result:', auth?.user ? 'user exists' : 'no user', authError ? authError.message : 'no error');
  if (authError) console.error('[LSM] perfilActual - auth error:', authError);
  if (!auth?.user) return null;
  const { data, error: perfilError } = await sb.from("perfiles").select("*").eq("id", auth.user.id).maybeSingle();
  console.log('[LSM] perfilActual - perfiles query:', data ? 'found' : 'not found', perfilError ? perfilError.message : 'no error');
  if (perfilError) console.error('[LSM] perfilActual - perfiles error:', perfilError);
  const legacy = (data?.usuario_id ?? null);
  let nombre = data?.nombre || usuarioDeCorreo(auth.user.email);
  return {
    id: auth.user.id,
    email: auth.user.email,
    usuario: usuarioDeCorreo(auth.user.email),
    correoCuenta: data?.email || auth.user.email,
    rol: data?.rol || "Empleado",
    nombre,
    usuarioId: legacy,
    sucursalId: data?.sucursal_id ?? null,
    esAdmin: (data?.rol || "") === "Administrador",
    pinObligatorio: !!data?.pin_obligatorio,
    debeCambiarClave: !!data?.pin_obligatorio || !!data?.debe_cambiar_clave,
  };
}

export function onAuthChange(cb) {
  return sb.auth.onAuthStateChange((evento, session) => cb(evento, session));
}