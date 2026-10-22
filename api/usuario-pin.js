/* =====================================================================
   POST /api/usuario-pin  ->  { usuario_id, pin }
   Cabecera: Authorization: Bearer <access_token>  (solo Administrador)

   Restablece el PIN de un usuario: actualiza el hash scrypt en
   `usuarios.clave`. usuario_id es el uuid de la fila en `usuarios`.
   ===================================================================== */
const {
  hashPin, ipDe, excedido, cuerpo, origenDe, rest,
  autenticarAdmin, SUPABASE_URL, SUPABASE_SECRET,
} = require("./_lib.js");

module.exports = async function usuarioPin(req, res) {
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
  if (!admin) return res.status(403).json({ error: "Solo un administrador puede restablecer PINs" });

  const { usuario_id, pin } = await cuerpo(req);
  const id = String(usuario_id || "").trim();
  const p = String(pin || "");
  if (!id) return res.status(400).json({ error: "Usuario no válido" });
  if (p.length < 1 || p.length > 100) {
    return res.status(400).json({ error: "El PIN / contraseña debe tener entre 1 y 100 caracteres" });
  }

  try {
    const objetivo = (await rest(`usuarios?id=eq.${encodeURIComponent(id)}&select=id,usuario&limit=1`))[0];
    if (!objetivo) return res.status(404).json({ error: "El usuario no existe" });

    const cr = await fetch(`${SUPABASE_URL}/rest/v1/usuarios?id=eq.${encodeURIComponent(id)}`, {
      method: "PATCH",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
        Prefer: "return=minimal",
      },
      body: JSON.stringify({ clave: hashPin(p) }),
    });
    if (!cr.ok) throw new Error(`usuarios: ${cr.status} ${await cr.text()}`);

    return res.status(200).json({ ok: true });
  } catch (e) {
    console.error("usuario-pin:", e.message);
    return res.status(500).json({ error: "No se pudo restablecer el PIN" });
  }
};