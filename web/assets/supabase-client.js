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
  if (!r.ok) throw new Error(j.error || "Usuario o PIN incorrecto");

  // Almacenar perfil garantizado en sesión local
  if (j.perfil) {
    localStorage.setItem("lsm_perfil", JSON.stringify(j.perfil));
  }

  // Si Supabase emitió sesión real, sincronizarla con el cliente
  if (j.access_token && !j.access_token.startsWith("lsm_auth_")) {
    try {
      await sb.auth.setSession({
        access_token: j.access_token,
        refresh_token: j.refresh_token,
      });
    } catch (e) {
      console.warn("sb.auth.setSession skipped:", e.message);
    }
  }

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
  localStorage.removeItem("lsm_perfil");
  await sb.auth.signOut().catch(() => {});
}

export async function perfilActual() {
  console.log('[LSM] perfilActual called');

  // 1. Revisar perfil activo en localStorage
  try {
    const guardado = localStorage.getItem("lsm_perfil");
    if (guardado) {
      const p = JSON.parse(guardado);
      if (p && p.usuario) {
        return {
          id: p.id || 1,
          email: p.email,
          usuario: p.usuario,
          correoCuenta: p.email,
          rol: p.rol || "Administrador",
          nombre: p.nombre || p.usuario,
          foto: p.foto || "",
          usuarioId: p.usuarioId ?? p.id ?? null,
          activo: p.activo !== false,
          esAdmin: p.esAdmin || p.rol === "Administrador",
          pinObligatorio: false,
          debeCambiarClave: false,
        };
      }
    }
  } catch (err) {
    console.warn("[LSM] Error leyendo lsm_perfil:", err);
  }

  // 2. Revisar sesión oficial de Supabase Auth
  const { data: auth, error: authError } = await sb.auth.getUser().catch(() => ({ data: null }));
  if (!auth?.user) return null;

  // 3. Intentar obtener el perfil directo desde el API seguro (sin bloqueo de RLS)
  try {
    const { data: sesion } = await sb.auth.getSession();
    const token = sesion?.session?.access_token;
    if (token) {
      const resp = await fetch("/api/perfil", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (resp.ok) {
        const p = await resp.json();
        if (p?.usuario) {
          return {
            id: auth.user.id,
            email: p.email || auth.user.email,
            usuario: p.usuario,
            correoCuenta: auth.user.email,
            rol: p.rol || "Empleado",
            nombre: p.nombre || p.usuario,
            foto: p.foto || "",
            usuarioId: p.usuarioId ?? null,
            activo: p.activo !== false,
            esAdmin: p.esAdmin || p.rol === "Administrador",
            pinObligatorio: false,
            debeCambiarClave: false,
          };
        }
      }
    }
  } catch (err) {
    console.warn("[LSM] Error consultando /api/perfil:", err);
  }

  // 4. Fallback con metadata de Supabase Auth
  const meta = auth.user.user_metadata || {};
  const usuario = (meta.usuario || usuarioDeCorreo(auth.user.email)).toLowerCase();
  const rol = meta.rol || "Administrador";

  return {
    id: auth.user.id,
    email: auth.user.email,
    usuario,
    correoCuenta: auth.user.email,
    rol,
    nombre: meta.nombre || usuario,
    foto: "",
    usuarioId: meta.usuario_id ?? null,
    activo: true,
    esAdmin: rol === "Administrador",
    pinObligatorio: false,
    debeCambiarClave: false,
  };
}

export function onAuthChange(cb) {
  return sb.auth.onAuthStateChange((evento, session) => cb(evento, session));
}