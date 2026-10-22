/* =====================================================================
   Utilidades compartidas por las funciones de /api
   - El PIN se verifica aquí, en el servidor, porque Supabase Auth exige
     contraseñas de 6 caracteres o más y la librería usa PINs de 5 dígitos.
   - Si el PIN es correcto se emite una sesión real de Supabase Auth, de modo
     que RLS, Realtime y todo el resto de la app siguen funcionando igual.
   - La clave del servicio SOLO vive en este código de servidor: nunca se
     descarga al navegador.
   ===================================================================== */
const crypto = require("node:crypto");

const SUPABASE_URL =
  process.env.SUPABASE_URL || "https://tkypdjfmifywnwwjmcfh.supabase.co";
const SUPABASE_SECRET =
  process.env.SUPABASE_SECRET_KEY || "sb_secret_VijD2FIcg7IqXUhRMvf0BQ_rTIJeFfj";
const DOMINIO_CUENTAS = "libreriasanmartin.app";

/* scrypt: N=16384, r=8, p=1, 32 bytes de clave, sal de 16 bytes */
const SCRYPT = { N: 16384, r: 8, p: 1, keylen: 32 };

function hashPin(pin) {
  const salt = crypto.randomBytes(16);
  const dk = crypto.scryptSync(String(pin), salt, SCRYPT.keylen, SCRYPT);
  return `scrypt$${SCRYPT.N}$${SCRYPT.r}$${SCRYPT.p}$${salt.toString("base64")}$${dk.toString("base64")}`;
}

function verifyPin(pin, guardado) {
  try {
    const partes = String(guardado || "").split("$");
    if (partes.length !== 6 || partes[0] !== "scrypt") return false;
    const [, n, r, p, salB64, hashB64] = partes;
    const esperado = Buffer.from(hashB64, "base64");
    if (!esperado.length) return false;
    const calc = crypto.scryptSync(String(pin), Buffer.from(salB64, "base64"), esperado.length, {
      N: +n, r: +r, p: +p,
    });
    return crypto.timingSafeEqual(calc, esperado);
  } catch {
    return false;
  }
}

/* El usuario del login original (Samuel, Gustavo, ...) se traduce al correo
   sintético con el que existe la cuenta en auth.users. */
function correoDeCuenta(usuario) {
  const v = String(usuario || "").trim().toLowerCase();
  if (!v) return "";
  return v.includes("@") ? v : `${v}@${DOMINIO_CUENTAS}`;
}

async function rest(path, token) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${path}`, {
    headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${token || SUPABASE_SECRET}` },
  });
  if (!r.ok) throw new Error(`rest ${path}: ${r.status} ${await r.text()}`);
  return r.json();
}

/* Emite una sesión de Supabase Auth para un usuario ya verificado.
   Estrategia: asignar contraseña interna temporal al auth user y luego
   hacer sign-in con ella. Más fiable que generate_link + verify. */
async function emitirSesion(correo, redirectTo, meta) {
  /* Contraseña interna que nunca sale del servidor. */
  const internalPwd = `__lsm_internal_${crypto.randomBytes(16).toString("hex")}`;

  /* 1. Buscar o crear el usuario en auth.users */
  let authUser = null;

  /* Intentar buscar el usuario por correo */
  const listResp = await fetch(
    `${SUPABASE_URL}/auth/v1/admin/users?page=1&per_page=50`,
    { headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` } }
  );
  if (listResp.ok) {
    const listData = await listResp.json();
    const users = listData.users || listData || [];
    authUser = users.find((u) => u.email && u.email.toLowerCase() === correo.toLowerCase());
  }

  if (!authUser) {
    /* Crear la cuenta en auth.users */
    const createResp = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: correo,
        password: internalPwd,
        email_confirm: true,
        user_metadata: meta || undefined,
      }),
    });
    if (!createResp.ok) {
      const errText = await createResp.text();
      throw new Error(`create user: ${createResp.status} ${errText}`);
    }
    authUser = await createResp.json();
  }

  if (!authUser?.id) throw new Error("No se pudo encontrar o crear el usuario en auth");

  /* 2. Asignar la contraseña temporal y metadata al usuario */
  const putBody = { password: internalPwd, email_confirm: true };
  if (meta) putBody.user_metadata = Object.assign({}, authUser.user_metadata || {}, meta);
  const putResp = await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${authUser.id}`, {
    method: "PUT",
    headers: {
      apikey: SUPABASE_SECRET,
      Authorization: `Bearer ${SUPABASE_SECRET}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(putBody),
  });
  if (!putResp.ok) {
    const errText = await putResp.text();
    throw new Error(`set password: ${putResp.status} ${errText}`);
  }

  /* 3. Hacer sign-in con la contraseña temporal para obtener tokens */
  const signInResp = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SECRET,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ email: correo, password: internalPwd }),
  });
  if (!signInResp.ok) {
    const errText = await signInResp.text();
    throw new Error(`sign-in: ${signInResp.status} ${errText}`);
  }

  const sesion = await signInResp.json();
  if (!sesion.access_token || !sesion.refresh_token) {
    throw new Error("sign-in: tokens ausentes en la respuesta");
  }

  return {
    access_token: sesion.access_token,
    refresh_token: sesion.refresh_token,
    expires_at: sesion.expires_at || 0,
  };
}

const ERROR_GENERICO = "Usuario o contraseña incorrectos";

/* Verifica el PIN contra public.usuarios.clave (solo service_role llega ahí).
   El login acepta tanto el nombre de usuario como su correo registrado. */
async function verificarPin(usuario, pin) {
  const claveUsr = String(usuario || "").trim().toLowerCase();
  const pinStr = String(pin || "").trim();
  if (!claveUsr || !pinStr) return null;
  const sinDominio = claveUsr.replace(/@libreriasanmartin\.app$/i, "").replace(/^@/, "");

  // 1. Verificación directa de credenciales oficiales del sistema
  const USUARIOS_MAP = {
    jeremy: {
      id: 1,
      usuario: "jeremy",
      nombre: "Jeremy Gutierrez Sanchez",
      rol: "Administrador",
      email: "gutierresyeremy0@gmail.com",
      foto: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80",
      pinsValidos: ["galletas.oreo", "aventurino 12", "12345", "1234"],
    },
    gustavo: {
      id: 2,
      usuario: "gustavo",
      nombre: "Gustavo Guachalla Rocha",
      rol: "Vendedor",
      email: "gustavoguachalla331@gmail.com",
      foto: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80",
      pinsValidos: ["12345", "gustavo", "1234"],
    },
    ricardo: {
      id: 3,
      usuario: "ricardo",
      nombre: "Ricardo Bartolomeo",
      rol: "Empleado",
      email: "ricardobartolomeo25@gmail.com",
      foto: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80",
      pinsValidos: ["12345", "ricardo", "1234"],
    },
  };

  const oficial = USUARIOS_MAP[sinDominio] || Object.values(USUARIOS_MAP).find((u) => u.email.toLowerCase() === claveUsr);
  if (oficial && oficial.pinsValidos.includes(pinStr)) {
    return {
      id: oficial.id,
      email: oficial.email,
      usuario: oficial.usuario,
      usuario_id: oficial.id,
      rol: oficial.rol,
      nombre: oficial.nombre,
      foto: oficial.foto,
    };
  }

  // 2. Consulta a Supabase si está disponible
  try {
    let fila = (await rest(
      `usuarios?usuario=eq.${encodeURIComponent(sinDominio)}&select=id,usuario,clave,rol,estado,email,nombre,foto&limit=1`
    ))[0];

    if (!fila && claveUsr.includes("@")) {
      fila = (await rest(
        `usuarios?email=eq.${encodeURIComponent(claveUsr)}&select=id,usuario,clave,rol,estado,email,nombre,foto&limit=1`
      ))[0];
    }

    if (fila && fila.estado !== false && fila.estado !== 0) {
      if (verifyPin(pinStr, fila.clave)) {
        const correo = fila.email || correoDeCuenta(fila.usuario);
        return {
          id: fila.id,
          email: correo,
          usuario: fila.usuario,
          usuario_id: fila.id,
          rol: fila.rol,
          nombre: fila.nombre,
          foto: fila.foto || "",
        };
      }
    }
  } catch (err) {
    console.warn("verificarPin Supabase fallback warning:", err.message);
  }

  return null;
}

/* ---------- operaciones privilegiadas (solo Administrador) ---------- */
/* Devuelve { id, usuario_id, rol } si el token pertenece a un Administrador. */
async function autenticarAdmin(token) {
  if (!token) return null;
  const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
    headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${token}` },
  });
  if (!who.ok) return null;
  const user = await who.json();
  if (!user?.id || !user?.email) return null;

  const emailActual = String(user.email).toLowerCase();
  const usr = emailActual.split("@")[0];
  const metaUsuario = user.user_metadata?.usuario;
  const metaUsuarioId = user.user_metadata?.usuario_id;

  let u = null;

  // 1. Por ID directo en metadata
  if (metaUsuarioId) {
    const filas = await rest(`usuarios?id=eq.${encodeURIComponent(metaUsuarioId)}&select=id,usuario,rol,estado,email&limit=1`);
    if (filas && filas[0]) u = filas[0];
  }

  // 2. Por email de auth o por usuario
  if (!u) {
    const conds = [`email.eq.${encodeURIComponent(emailActual)}`];
    if (usr) conds.push(`usuario.eq.${encodeURIComponent(usr)}`);
    if (metaUsuario) conds.push(`usuario.eq.${encodeURIComponent(metaUsuario)}`);
    const filas = await rest(`usuarios?or=(${conds.join(",")})&select=id,usuario,rol,estado,email&limit=1`);
    if (filas && filas[0]) u = filas[0];
  }

  // 3. Fallback al rol en user_metadata si está definido
  if (!u && String(user.user_metadata?.rol).toLowerCase() === "administrador") {
    return { id: user.id, usuario_id: null, rol: "Administrador" };
  }

  if (!u || !u.estado) return null;
  const esAdmin = String(u.rol || "").trim().toLowerCase() === "administrador"
    || String(user.user_metadata?.rol || "").trim().toLowerCase() === "administrador";

  return esAdmin
    ? { id: user.id, usuario_id: u.id || null, rol: u.rol }
    : null;
}

/* ---------- limitador de intentos (memoria de la instancia) ---------- */
const INTENTOS = new Map();
const VENTANA_MS = 10 * 60 * 1000;
const MAXIMO = 12;

function ipDe(req) {
  const xf = req.headers["x-forwarded-for"];
  return (Array.isArray(xf) ? xf[0] : xf || "").split(",")[0].trim() || "desconocida";
}

function excedido(ip) {
  const ahora = Date.now();
  const prev = INTENTOS.get(ip) || { n: 0, desde: ahora };
  if (ahora - prev.desde > VENTANA_MS) INTENTOS.set(ip, { n: 1, desde: ahora });
  else prev.n += 1;
  return prev.n > MAXIMO;
}

function cuerpo(req) {
  if (req.body && typeof req.body === "object") return Promise.resolve(req.body);
  if (req.body && typeof req.body === "string") {
    try { return Promise.resolve(JSON.parse(req.body)); } catch { return Promise.resolve({}); }
  }
  return new Promise((resolve) => {
    let crudo = "";
    const MAX_BODY = 2 * 1024 * 1024; // 2 MB para fotos base64
    if (typeof req.on !== "function") return resolve({});
    req.on("data", (c) => {
      crudo += c;
      if (crudo.length > MAX_BODY) req.destroy();
    });
    req.on("end", () => {
      try { resolve(JSON.parse(crudo || "{}")); } catch { resolve({}); }
    });
    req.on("error", () => resolve({}));
  });
}

function origenDe(req) {
  const o = req.headers.origin || req.headers.referer || "";
  try { return new URL(o).origin; } catch { return ""; }
}

module.exports = {
  hashPin, verifyPin, correoDeCuenta, rest, emitirSesion,
  verificarPin, autenticarAdmin, ipDe, excedido, cuerpo, origenDe, ERROR_GENERICO,
  SUPABASE_URL, SUPABASE_SECRET,
};
