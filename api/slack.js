/* =====================================================================
   POST /api/slack -> Enviar notificación a Slack Webhook
   Librería San Martín - Tarea 6
   ===================================================================== */
const SLACK_WEBHOOK_URL =
  process.env.SLACK_WEBHOOK_URL ||
  "https://hooks.slack.com/services/T0C9R799A4R/C0C9R7KBGTB/XyZ1234567890ExampleWebhook";

module.exports = async function handler(req, res) {
  res.setHeader("Cache-Control", "no-store");
  res.setHeader("Access-Control-Allow-Origin", "*");
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");

  if (req.method === "OPTIONS") return res.status(204).end();
  if (req.method !== "POST") {
    return res.status(405).json({ error: "Método no permitido" });
  }

  try {
    const body = req.body || {};
    const { tipo = "producto", titulo, detalle, precio, stock } = body;

    const texto = titulo || "Alerta de inventario - Librería San Martín";

    const payload = {
      text: `📢 [Librería San Martín] ${texto}`,
      blocks: [
        {
          type: "header",
          text: {
            type: "plain_text",
            text: "📚 Notificación · Librería San Martín",
            emoji: true,
          },
        },
        {
          type: "section",
          fields: [
            {
              type: "mrkdwn",
              text: `*Evento:*\n${tipo === "producto" ? "📦 Producto Actualizado/Creado" : "🛒 Venta Registrada"}`,
            },
            {
              type: "mrkdwn",
              text: `*Detalle:*\n${detalle || texto}`,
            },
          ],
        },
      ],
    };

    if (precio) {
      payload.blocks[1].fields.push({
        type: "mrkdwn",
        text: `*Precio:*\nBs ${Number(precio).toFixed(2)}`,
      });
    }
    if (stock !== undefined) {
      payload.blocks[1].fields.push({
        type: "mrkdwn",
        text: `*Stock:*\n${stock} unidades`,
      });
    }

    // Si es la URL de ejemplo, responder simulado exitoso
    if (SLACK_WEBHOOK_URL.includes("ExampleWebhook")) {
      return res.status(200).json({
        ok: true,
        modo: "simulado",
        mensaje: "Notificación procesada correctamente (Modo Sandbox)",
        payload,
      });
    }

    const respuesta = await fetch(SLACK_WEBHOOK_URL, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload),
    });

    if (!respuesta.ok) {
      const err = await respuesta.text();
      return res.status(respuesta.status).json({ error: err });
    }

    return res.status(200).json({ ok: true, mensaje: "Mensaje enviado a Slack exitosamente" });
  } catch (e) {
    return res.status(500).json({ error: e.message });
  }
};
