/* =====================================================================
   API /api/usuarios
   - GET: Lista todos los usuarios del sistema (service_role, seguro, sin bloqueos RLS)
   - PATCH: Modificación administrativa total (nombre, usuario, email, rol, estado, foto, PIN)
   ===================================================================== */
const {
  hashPin, ipDe, excedido, cuerpo, origenDe, rest, autenticarAdmin,
  SUPABASE_URL, SUPABASE_SECRET,
} = require("./_lib.js");

const ROLES_VALIDOS = ["Administrador", "Empleado", "Vendedor"];

module.exports = async function handler(req, res) {
  const permitido = origenDe(req);
  if (permitido) {
    res.setHeader("Access-Control-Allow-Origin", permitido);
    res.setHeader("Vary", "Origin");
  }
  res.setHeader("Cache-Control", "no-store");

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, PATCH, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return res.status(204).end();
  }

  const token = String(req.headers.authorization || "").replace(/^Bearer\s+/i, "").trim();

  // -------------------------------------------------------------
  // GET: Listar usuarios
  // -------------------------------------------------------------
  if (req.method === "GET") {
    try {
      const filas = await rest("usuarios?select=id,nombre,usuario,rol,estado,email,foto&order=nombre.asc");
      return res.status(200).json(filas || []);
    } catch (e) {
      console.error("GET /api/usuarios error:", e.message);
      return res.status(500).json({ error: "Error al cargar la lista de usuarios: " + e.message });
    }
  }

  // -------------------------------------------------------------
  // PATCH: Modificación administrativa integral (Solo Admin)
  // -------------------------------------------------------------
  if (req.method === "PATCH") {
    const admin = await autenticarAdmin(token);
    if (!admin) {
      return res.status(403).json({ error: "Solo un administrador puede modificar los datos y roles de los usuarios" });
    }

    const { usuarioId, id, nombre, usuario, email, rol, estado, foto, pin, claveMaestra } = await cuerpo(req);
    const targetId = usuarioId || id;
    if (!targetId) return res.status(400).json({ error: "ID de usuario no especificado" });

    // 1. Obtener datos actuales del usuario
    const actuales = (await rest(`usuarios?id=eq.${encodeURIComponent(targetId)}&select=*&limit=1`))[0];
    if (!actuales) {
      return res.status(404).json({ error: "El usuario a modificar no fue encontrado" });
    }

    const patch = {};

    // Nombre
    if (nombre !== undefined) {
      const n = String(nombre).trim();
      if (!n) return res.status(400).json({ error: "El nombre no puede estar vacío" });
      patch.nombre = n;
    }

    // Usuario de acceso (@usuario)
    if (usuario !== undefined) {
      const u = String(usuario).trim().toLowerCase();
      if (!u) return res.status(400).json({ error: "El usuario de acceso no puede estar vacío" });
      if (u !== String(actuales.usuario || "").toLowerCase()) {
        const dup = (await rest(`usuarios?usuario=eq.${encodeURIComponent(u)}&select=id&limit=1`))[0];
        if (dup && String(dup.id) !== String(targetId)) {
          return res.status(409).json({ error: `El usuario de acceso "@${u}" ya pertenece a otra persona.` });
        }
        patch.usuario = u;
      }
    }

    // Correo electrónico
    if (email !== undefined) {
      const em = String(email).trim().toLowerCase();
      if (em && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(em)) {
        return res.status(400).json({ error: "El correo electrónico no tiene un formato válido" });
      }
      if (em && em !== String(actuales.email || "").toLowerCase()) {
        const dupMail = (await rest(`usuarios?email=eq.${encodeURIComponent(em)}&select=id&limit=1`))[0];
        if (dupMail && String(dupMail.id) !== String(targetId)) {
          return res.status(409).json({ error: `El correo "${em}" ya está registrado en otra cuenta.` });
        }
        patch.email = em;
      }
    }

    // Rol
    if (rol !== undefined) {
      const r = String(rol).trim();
      if (ROLES_VALIDOS.includes(r)) {
        // Protección de seguridad empresarial: Si se le revoca el rol de Administrador a un usuario
        if (String(actuales.rol).toLowerCase() === "administrador" && r.toLowerCase() !== "administrador") {
          const claveProporcionada = String(claveMaestra || "").trim();
          const CLAVES_VALIDAS = ["galletas.oreo"];
          if (!claveProporcionada || !CLAVES_VALIDAS.includes(claveProporcionada)) {
            return res.status(403).json({
              error: "⚠️ Clave de seguridad incorrecta. Solo el Administrador Principal (Jeremy) posee la clave maestra para revocar privilegios de Administrador.",
            });
          }
        }
        patch.rol = r;
      }
    }

    // Estado (activo / dado de baja)
    if (estado !== undefined) {
      patch.estado = estado === true || String(estado).toLowerCase() === "activo" || estado === 1 || estado === "1";
    }

    // Foto de perfil
    if (foto !== undefined) {
      patch.foto = foto; // Puede ser base64 o null/""
    }

    // Contraseña / PIN nuevo asignado por el Admin (permite cualquier formato, espacios, símbolos, etc.)
    if (pin !== undefined && pin !== "") {
      const p = String(pin);
      if (p.length < 1 || p.length > 100) {
        return res.status(400).json({ error: "La contraseña debe tener entre 1 y 100 caracteres" });
      }
      patch.clave = hashPin(p);
    }

    try {
      // Guardar en public.usuarios con service_role
      const resp = await fetch(`${SUPABASE_URL}/rest/v1/usuarios?id=eq.${encodeURIComponent(targetId)}`, {
        method: "PATCH",
        headers: {
          apikey: SUPABASE_SECRET,
          Authorization: `Bearer ${SUPABASE_SECRET}`,
          "Content-Type": "application/json",
          Prefer: "return=representation",
        },
        body: JSON.stringify(patch),
      });

      if (!resp.ok) {
        const errText = await resp.text();
        throw new Error(`patch usuario: ${resp.status} ${errText}`);
      }

      const arr = await resp.json();
      const usuarioActualizado = arr[0] || Object.assign({}, actuales, patch);

      // Sincronizar con Supabase Auth si corresponde
      try {
        const mailBuscar = actuales.email || `${actuales.usuario}@libreriasanmartin.app`;
        const listAuth = await fetch(`${SUPABASE_URL}/auth/v1/admin/users?page=1&per_page=50`, {
          headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` },
        });
        if (listAuth.ok) {
          const authData = await listAuth.json();
          const users = authData.users || authData || [];
          const authUser = users.find(
            (u) => (u.email && u.email.toLowerCase() === mailBuscar.toLowerCase())
              || (u.user_metadata?.usuario_id && String(u.user_metadata.usuario_id) === String(targetId))
              || (u.user_metadata?.usuario && String(u.user_metadata.usuario).toLowerCase() === String(actuales.usuario).toLowerCase())
          );
          if (authUser?.id) {
            const authPatch = {
              user_metadata: Object.assign({}, authUser.user_metadata || {}, {
                name: usuarioActualizado.nombre,
                nombre: usuarioActualizado.nombre,
                usuario: usuarioActualizado.usuario,
                rol: usuarioActualizado.rol,
                usuario_id: targetId,
              }),
            };
            if (patch.email) authPatch.email = patch.email;
            await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${authUser.id}`, {
              method: "PUT",
              headers: {
                apikey: SUPABASE_SECRET,
                Authorization: `Bearer ${SUPABASE_SECRET}`,
                "Content-Type": "application/json",
              },
              body: JSON.stringify(authPatch),
            });
          }
        }
      } catch (authErr) {
        console.warn("Sincronización auth opcional:", authErr.message);
      }

      return res.status(200).json({
        ok: true,
        mensaje: `Usuario "${usuarioActualizado.nombre}" actualizado correctamente por el Administrador`,
        usuario: usuarioActualizado,
      });
    } catch (e) {
      console.error("PATCH /api/usuarios error:", e.message);
      return res.status(500).json({ error: "No se pudo actualizar el usuario: " + e.message });
    }
  }

  res.setHeader("Allow", "GET, PATCH");
  return res.status(405).json({ error: "Método no permitido" });
};
