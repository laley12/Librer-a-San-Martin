/* =====================================================================
   POST /api/usuarios-nuevo  ->  { nombre, usuario, pin, rol, estado }
   Cabecera: Authorization: Bearer <access_token>  (solo Administrador)

   Alta de punta a punta de un usuario operativo (modelo ER de 8 tablas):
     1) fila en `usuarios` (nombre, usuario, rol, estado, clave = hash scrypt)
     2) cuenta real en Supabase Auth (correo sintético usuario@libreriasanmartin.app)

   El acceso en la app se hace con usuario + PIN a través de /api/login.
   ===================================================================== */
const crypto = require("node:crypto");
const {
  hashPin, ipDe, excedido, cuerpo, origenDe, rest,
  autenticarAdmin, SUPABASE_URL, SUPABASE_SECRET,
} = require("./_lib.js");

const ROLES = ["Administrador", "Empleado", "Vendedor"];
const DOMINIO = "libreriasanmartin.app";

async function restInsert(tabla, datos) {
  const r = await fetch(`${SUPABASE_URL}/rest/v1/${tabla}`, {
    method: "POST",
    headers: {
      apikey: SUPABASE_SECRET,
      Authorization: `Bearer ${SUPABASE_SECRET}`,
      "Content-Type": "application/json",
      Prefer: "return=representation",
    },
    body: JSON.stringify(datos),
  });
  if (!r.ok) throw new Error(`insert ${tabla}: ${r.status} ${await r.text()}`);
  const arr = await r.json();
  return arr[0] || datos;
}

module.exports = async function usuarioNuevo(req, res) {
  const permitido = origenDe(req);
  if (permitido) {
    res.setHeader("Access-Control-Allow-Origin", permitido);
    res.setHeader("Vary", "Origin");
  }
  res.setHeader("Cache-Control", "no-store");

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return res.status(204).end();
  }
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Método no permitido" });
  }
  if (excedido(ipDe(req))) {
    return res.status(429).json({ error: "Demasiados intentos. Espera unos minutos." });
  }

  const token = String(req.headers.authorization || "").replace(/^Bearer\s+/i, "").trim();
  const admin = await autenticarAdmin(token);
  if (!admin) return res.status(403).json({ error: "Solo un administrador puede crear usuarios" });

  const { nombre, usuario, pin, rol, estado, email, foto } = await cuerpo(req);
  const nom = String(nombre || "").trim();
  const usr = String(usuario || "").trim().toLowerCase();
  const p = String(pin || "");
  const rl = ROLES.includes(rol) ? rol : "Empleado";
  const est = [false, 0, "false", "Inactivo", "inactivo"].includes(estado) ? false : true;
  const correoReal = String(email || "").trim().toLowerCase();
  if (!nom) return res.status(400).json({ error: "Escribe el nombre completo" });
  if (!usr) return res.status(400).json({ error: "Escribe el usuario de acceso" });
  if (p.length < 1 || p.length > 100) {
    return res.status(400).json({ error: "El PIN / contraseña debe tener entre 1 y 100 caracteres" });
  }

  // Use real email if provided, otherwise fall back to synthetic
  const correo = correoReal && correoReal.includes("@") ? correoReal : `${usr}@${DOMINIO}`;

  try {
    const yaUsuario = (await rest(`usuarios?usuario=eq.${encodeURIComponent(usr)}&select=id&limit=1`))[0];
    if (yaUsuario) return res.status(409).json({ error: "El usuario de acceso ya existe" });

    const auth = await fetch(`${SUPABASE_URL}/auth/v1/admin/users`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        email: correo,
        password: crypto.randomBytes(18).toString("base64"),
        email_confirm: true,
        user_metadata: { name: nom },
      }),
    });
    if (!auth.ok) {
      const authErrText = (await auth.text()).slice(0, 300);
      let msgAmigable = "No se pudo crear la cuenta de acceso. Intenta de nuevo.";
      if (auth.status === 422 || authErrText.includes("email_exists") || authErrText.includes("already been registered")) {
        msgAmigable = "El correo o usuario ya se encuentra registrado. Intente con otro.";
      } else if (auth.status === 429) {
        msgAmigable = "Demasiados intentos. Espera unos minutos e intenta de nuevo.";
      }
      return res.status(auth.status === 422 ? 409 : 502).json({ error: msgAmigable });
    }
    const authUser = await auth.json();
    if (!authUser?.id) return res.status(502).json({ error: "No se pudo crear la cuenta" });

    try {
      const datosUsuario = {
        nombre: nom, usuario: usr, rol: rl, estado: est, clave: hashPin(p), email: correo,
      };
      if (foto && typeof foto === "string" && foto.startsWith("data:image")) {
        datosUsuario.foto = foto;
      }
      await restInsert("usuarios", datosUsuario);
      return res.status(200).json({ ok: true, usuario: nom, login: usr, rol: rl });
    } catch (e) {
      await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${authUser.id}`, {
        method: "DELETE",
        headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` },
      }).catch(() => {});
      console.error("usuarios-nuevo:", e.message);
      return res.status(500).json({ error: "No se pudo completar el alta. Reintenta." });
    }
  } catch (e) {
    console.error("usuarios-nuevo:", e.message);
    return res.status(500).json({ error: "No se pudo crear el usuario" });
  }
};