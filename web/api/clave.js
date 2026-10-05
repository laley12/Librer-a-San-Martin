/* =====================================================================
   POST /api/clave  ->  { password }
   Cabecera          Authorization: Bearer <access_token>

   Guarda un PIN nuevo. Mismo motivo que /api/login: el cambio de clave va al
   hash local porque Supabase Auth no acepta PINs de menos de 6 caracteres.
   También cierra el cambio pendiente (pin_obligatorio = false).
   ===================================================================== */
const {
  hashPin, ipDe, excedido, cuerpo, origenDe, SUPABASE_URL, SUPABASE_SECRET,
} = require("./_lib.js");

module.exports = async function clave(req, res) {
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
  if (!token) return res.status(401).json({ error: "Sesión no válida" });

  const { password } = await cuerpo(req);
  const pin = String(password || "");
  if (pin.length < 4 || pin.length > 12) {
    return res.status(400).json({ error: "El PIN debe tener entre 4 y 12 caracteres" });
  }

  try {
    const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${token}` },
    });
    if (!who.ok) return res.status(401).json({ error: "Sesión no válida" });
    const user = await who.json();
    if (!user?.id) return res.status(401).json({ error: "Sesión no válida" });

    await fetch(`${SUPABASE_URL}/rest/v1/credenciales`, {
      method: "POST",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
        Prefer: "resolution=merge-duplicates,return=minimal",
      },
      body: JSON.stringify({ id: user.id, clave_hash: hashPin(pin) }),
    });

    await fetch(`${SUPABASE_URL}/rest/v1/perfiles?id=eq.${user.id}`, {
      method: "PATCH",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
        Prefer: "return=minimal",
      },
      body: JSON.stringify({ pin_obligatorio: false, debe_cambiar_clave: false }),
    });

    return res.status(200).json({ ok: true });
  } catch (e) {
    console.error("clave:", e.message);
    return res.status(500).json({ error: "No se pudo guardar el PIN" });
  }
};
