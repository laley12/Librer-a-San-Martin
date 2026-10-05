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
    const sesion = await emitirSesion(perfil.email, origenDe(req));
    return res.status(200).json(sesion);
  } catch (e) {
    console.error("login:", e.message);
    return res.status(500).json({ error: "No se pudo iniciar sesión" });
  }
};
