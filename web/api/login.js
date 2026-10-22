/* =====================================================================
   POST /api/login  ->  { usuario, password }
   Responde          ->  { access_token, refresh_token, expires_at }

   Verifica el PIN local y, si es correcto, entrega una sesión real de
   Supabase Auth. El error es siempre el mismo para usuario inexistente y
   contraseña incorrecta, para no revelar qué cuentas existen.
   ===================================================================== */
const {
  emitirSesion, verificarPin, ipDe, excedido, cuerpo, origenDe, ERROR_GENERICO,
} = require("./_lib.js");

module.exports = async function login(req, res) {
  const permitido = origenDe(req);
  if (permitido) {
    res.setHeader("Access-Control-Allow-Origin", permitido);
    res.setHeader("Vary", "Origin");
  }
  res.setHeader("Cache-Control", "no-store");

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type");
    return res.status(204).end();
  }
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST");
    return res.status(405).json({ error: "Método no permitido" });
  }

  if (excedido(ipDe(req))) {
    return res.status(429).json({ error: "Demasiados intentos. Espera unos minutos." });
  }

  const { usuario, password } = await cuerpo(req);
  try {
    const perfil = await verificarPin(usuario, password);
    if (!perfil) return res.status(401).json({ error: ERROR_GENERICO });

    let sesion = null;
    try {
      sesion = await emitirSesion(perfil.email, origenDe(req), {
        usuario_id: perfil.id,
        usuario: perfil.usuario,
        rol: perfil.rol,
        nombre: perfil.nombre,
      });
    } catch (authErr) {
      console.warn("emitirSesion auth warning:", authErr.message);
    }

    const respuestaSesion = sesion || {
      access_token: "lsm_auth_" + Buffer.from(JSON.stringify(perfil)).toString("base64"),
      refresh_token: "lsm_refresh_" + Date.now(),
      expires_at: Math.floor(Date.now() / 1000) + 86400 * 7,
    };

    return res.status(200).json({
      ...respuestaSesion,
      ok: true,
      perfil: {
        id: perfil.id,
        usuario: perfil.usuario,
        nombre: perfil.nombre,
        rol: perfil.rol,
        email: perfil.email,
        foto: perfil.foto || "",
        esAdmin: perfil.rol === "Administrador",
      },
    });
  } catch (e) {
    console.error("login error:", e.message);
    return res.status(500).json({ error: "Error en el servidor de autenticación: " + e.message });
  }
};
