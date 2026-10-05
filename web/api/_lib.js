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
const SUPABASE_SECRET = process.env.SUPABASE_SECRET_KEY || "";
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

/* Emite una sesión de Supabase Auth para un usuario ya verificado. */
async function emitirSesion(correo, redirectTo) {
  const gl = await fetch(`${SUPABASE_URL}/auth/v1/admin/generate_link`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SECRET,
      Authorization: `Bearer ${SUPABASE_SECRET}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ type: "magiclink", email: correo }),
  });
  if (!gl.ok) throw new Error(`generate_link: ${gl.status} ${await gl.text()}`);
  const { hashed_token } = await gl.json();

  const destino = redirectTo || SUPABASE_URL;
  const vf = await fetch(
    `${SUPABASE_URL}/auth/v1/verify?token=${hashed_token}&type=magiclink&redirect_to=${encodeURIComponent(destino)}`,
    { headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` }, redirect: "manual" }
  );
  const loc = vf.headers.get("location");
  if (!loc) throw new Error(`verify ${vf.status}: ${await vf.text()}`);

  const p = new URLSearchParams(new URL(loc).hash.replace(/^#/, ""));
  const access_token = p.get("access_token");
  const refresh_token = p.get("refresh_token");
  if (!access_token || !refresh_token) throw new Error("verify: tokens ausentes");
  return { access_token, refresh_token, expires_at: Number(p.get("expires_at") || 0) };
}

const ERROR_GENERICO = "Usuario o contraseña incorrectos";

/* Verifica el PIN contra public.credenciales (solo service_role llega ahí). */
async function verificarPin(usuario, pin) {
  const correo = correoDeCuenta(usuario);
  if (!correo || !pin) return null;
  const perfil = (await rest(`perfiles?email=eq.${encodeURIComponent(correo)}&select=id,email&limit=1`))[0];
  if (!perfil) return null;
  const fila = (await rest(`credenciales?id=eq.${perfil.id}&select=clave_hash&limit=1`))[0];
  if (!fila || !verifyPin(pin, fila.clave_hash)) return null;
  return perfil;
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
  return new Promise((resolve) => {
    let crudo = "";
    req.on("data", (c) => {
      crudo += c;
      if (crudo.length > 4096) req.destroy();
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
  verificarPin, ipDe, excedido, cuerpo, origenDe, ERROR_GENERICO,
  SUPABASE_URL, SUPABASE_SECRET,
};
