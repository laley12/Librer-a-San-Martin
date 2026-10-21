/* =====================================================================
   GET /api/perfil
   POST /api/perfil
   Cabecera: Authorization: Bearer <access_token>
   Cuerpo (POST): { nombre, usuario, email, foto, password, id }

   Permite consultar y actualizar de forma integral y segura el perfil
   del usuario autenticado sin ser bloqueado por RLS:
   nombre completo, nombre de usuario, correo electrónico, foto (base64)
   y contraseña/PIN.
   ===================================================================== */
const {
  hashPin, ipDe, excedido, cuerpo, origenDe, SUPABASE_URL, SUPABASE_SECRET, correoDeCuenta,
} = require("./_lib.js");

module.exports = async function perfil(req, res) {
  const permitido = origenDe(req);
  if (permitido) {
    res.setHeader("Access-Control-Allow-Origin", permitido);
    res.setHeader("Vary", "Origin");
  }
  res.setHeader("Cache-Control", "no-store");

  if (req.method === "OPTIONS") {
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type, Authorization");
    return res.status(204).end();
  }
  if (req.method !== "GET" && req.method !== "POST") {
    res.setHeader("Allow", "GET, POST, OPTIONS");
    return res.status(405).json({ error: "Método no permitido" });
  }

  if (excedido(ipDe(req))) {
    return res.status(429).json({ error: "Demasiados intentos. Espera unos minutos." });
  }

  const token = String(req.headers.authorization || "").replace(/^Bearer\s+/i, "").trim();
  if (!token) return res.status(401).json({ error: "Sesión no válida" });

  try {
    const who = await fetch(`${SUPABASE_URL}/auth/v1/user`, {
      headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${token}` },
    });
    if (!who.ok) return res.status(401).json({ error: "Sesión no válida o expirada" });
    const authUser = await who.json();
    if (!authUser?.id || !authUser?.email) return res.status(401).json({ error: "Sesión no válida" });

    // Localizar el usuario en public.usuarios con máxima fiabilidad
    const emailActual = String(authUser.email).toLowerCase();
    const usuarioActual = emailActual.split("@")[0];
    const metaUsuarioId = authUser.user_metadata?.usuario_id;
    const metaUsuario = authUser.user_metadata?.usuario;

    let usuarioFila = null;

    // 1. Por ID directo en metadata
    if (metaUsuarioId) {
      const rId = await fetch(
        `${SUPABASE_URL}/rest/v1/usuarios?id=eq.${encodeURIComponent(metaUsuarioId)}&select=*&limit=1`,
        { headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` } }
      );
      const filas = await rId.json();
      if (filas && filas[0]) usuarioFila = filas[0];
    }

    // 2. Por email de auth o por usuario
    if (!usuarioFila) {
      const conds = [`email.eq.${encodeURIComponent(emailActual)}`, `usuario.eq.${encodeURIComponent(usuarioActual)}`];
      if (metaUsuario) conds.push(`usuario.eq.${encodeURIComponent(metaUsuario)}`);
      const rBuscar = await fetch(
        `${SUPABASE_URL}/rest/v1/usuarios?or=(${conds.join(",")})&select=*&limit=1`,
        { headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` } }
      );
      const filas = await rBuscar.json();
      if (filas && filas[0]) usuarioFila = filas[0];
    }

    // 3. Si no existe aún fila en public.usuarios, crear una por defecto
    if (!usuarioFila) {
      const nuevoNom = authUser.user_metadata?.nombre || usuarioActual;
      const rCrear = await fetch(`${SUPABASE_URL}/rest/v1/usuarios`, {
        method: "POST",
        headers: {
          apikey: SUPABASE_SECRET,
          Authorization: `Bearer ${SUPABASE_SECRET}`,
          "Content-Type": "application/json",
          Prefer: "return=representation",
        },
        body: JSON.stringify({
          nombre: nuevoNom,
          usuario: usuarioActual,
          email: emailActual,
          rol: authUser.user_metadata?.rol || "Empleado",
          estado: true,
          clave: hashPin("12345"),
        }),
      });
      const filasCreadas = await rCrear.json();
      usuarioFila = filasCreadas?.[0];
    }

    if (!usuarioFila) {
      return res.status(404).json({ error: "Usuario no encontrado en la base de datos" });
    }

    // Si la petición es GET, devolver los datos del perfil
    if (req.method === "GET") {
      const rol = usuarioFila.rol || "Empleado";
      return res.status(200).json({
        id: authUser.id,
        usuarioId: usuarioFila.id,
        nombre: usuarioFila.nombre || usuarioFila.usuario,
        usuario: usuarioFila.usuario,
        email: usuarioFila.email || authUser.email,
        foto: usuarioFila.foto || "",
        rol,
        estado: usuarioFila.estado,
        activo: usuarioFila.estado === true || Number(usuarioFila.estado) === 1,
        esAdmin: rol === "Administrador",
      });
    }

    // ---------------- MÉTODO POST (Actualizar Perfil) ----------------
    const datos = await cuerpo(req);
    const nombre = String(datos.nombre || "").trim();
    const usuarioNuevo = String(datos.usuario || "").trim().toLowerCase();
    const emailNuevo = String(datos.email || "").trim().toLowerCase();
    const foto = datos.foto !== undefined ? String(datos.foto || "") : undefined;
    const password = datos.password ? String(datos.password).trim() : null;

    if (!nombre) return res.status(400).json({ error: "El nombre no puede estar vacío" });
    if (!usuarioNuevo) return res.status(400).json({ error: "El usuario no puede estar vacío" });

    // Verificar si el nuevo usuario ya pertenece a otra persona
    if (usuarioNuevo !== usuarioFila.usuario) {
      const rExiste = await fetch(
        `${SUPABASE_URL}/rest/v1/usuarios?usuario=eq.${encodeURIComponent(usuarioNuevo)}&id=neq.${usuarioFila.id}&select=id,estado&limit=1`,
        { headers: { apikey: SUPABASE_SECRET, Authorization: `Bearer ${SUPABASE_SECRET}` } }
      );
      const existeFilas = await rExiste.json();
      if (existeFilas && existeFilas.length > 0) {
        const otro = existeFilas[0];
        if (otro.estado === false || otro.estado === 0) {
          await fetch(`${SUPABASE_URL}/rest/v1/usuarios?id=eq.${otro.id}`, {
            method: "PATCH",
            headers: {
              apikey: SUPABASE_SECRET,
              Authorization: `Bearer ${SUPABASE_SECRET}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({ usuario: `${usuarioNuevo}_antiguo_${String(otro.id).slice(0, 4)}` }),
          });
        } else {
          return res.status(400).json({ error: "Ese nombre de usuario ya está en uso por otra persona" });
        }
      }
    }

    // Armar el objeto de actualización
    const patch = {
      nombre,
      usuario: usuarioNuevo,
      email: emailNuevo || `${usuarioNuevo}@libreriasanmartin.app`,
    };

    if (foto !== undefined) {
      patch.foto = foto;
    }

    if (password) {
      if (password.length < 4 || password.length > 64) {
        return res.status(400).json({ error: "La contraseña / PIN debe tener entre 4 y 64 caracteres" });
      }
      patch.clave = hashPin(password);
    }

    // Actualizar en public.usuarios
    const rUpdate = await fetch(`${SUPABASE_URL}/rest/v1/usuarios?id=eq.${usuarioFila.id}`, {
      method: "PATCH",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
        Prefer: "return=representation",
      },
      body: JSON.stringify(patch),
    });

    if (!rUpdate.ok) {
      const errTxt = await rUpdate.text();
      console.error("[LSM API] Error actualizando usuarios:", errTxt);
      return res.status(500).json({ error: "No se pudieron guardar los datos en la base de datos" });
    }

    const actualizado = (await rUpdate.json())?.[0] || patch;

    // Actualizar metadata y correo en auth.users
    const correoFinal = patch.email;
    const authPutBody = {
      user_metadata: {
        ...(authUser.user_metadata || {}),
        nombre: actualizado.nombre,
        usuario: actualizado.usuario,
        usuario_id: usuarioFila.id,
        rol: usuarioFila.rol,
      },
    };
    if (correoFinal && correoFinal !== emailActual) {
      authPutBody.email = correoFinal;
      authPutBody.email_confirm = true;
    }

    await fetch(`${SUPABASE_URL}/auth/v1/admin/users/${authUser.id}`, {
      method: "PUT",
      headers: {
        apikey: SUPABASE_SECRET,
        Authorization: `Bearer ${SUPABASE_SECRET}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(authPutBody),
    }).catch((e) => console.warn("No se pudo actualizar auth.users:", e));

    return res.status(200).json({
      ok: true,
      mensaje: "Perfil actualizado con éxito",
      perfil: {
        id: authUser.id,
        usuarioId: usuarioFila.id,
        nombre: actualizado.nombre,
        usuario: actualizado.usuario,
        email: actualizado.email,
        foto: actualizado.foto || "",
        rol: usuarioFila.rol,
        estado: usuarioFila.estado,
        activo: true,
        esAdmin: usuarioFila.rol === "Administrador",
      },
    });
  } catch (err) {
    console.error("[LSM API perfil] Error:", err);
    return res.status(500).json({ error: err.message || "Error al actualizar perfil" });
  }
};
