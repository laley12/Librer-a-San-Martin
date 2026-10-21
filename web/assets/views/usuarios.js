import { esc, toast, modal, seccion, input, select, btn, confirmar } from "../ui.js?v=4.1";
import { state, repo, estaEnLinea, onlineUsuarios } from "../data.js?v=4.1";

export const meta = { id: "usuarios", titulo: "Usuarios & Roles", icono: "🔐", grupo: "Control" };

const ROLES = ["Administrador", "Empleado", "Vendedor"];
const ESTADO_OPTS = [
  { v: "Activo", t: "✅ Activo" },
  { v: "Inactivo", t: "⛔ Inactivo" },
];

/* estado en Supabase puede venir como true/false o 1/0 */
const esActivo = (u) => u.estado === true || u.estado === 1 || u.estado === "true" || u.estado === "Activo";

let verInactivos = false;
let _ctx = null;

/* ---------- helpers visuales ---------- */
function badgeRol(rol) {
  const clr = rol === "Administrador"
    ? "bg-violet-100 text-violet-700 ring-1 ring-violet-200"
    : rol === "Empleado"
    ? "bg-blue-100 text-blue-700 ring-1 ring-blue-200"
    : "bg-emerald-100 text-emerald-700 ring-1 ring-emerald-200";
  const icono = rol === "Administrador" ? "🛡️" : rol === "Empleado" ? "💼" : "🏪";
  return `<span class="inline-flex items-center gap-1 text-[10px] px-2 py-0.5 rounded-full font-semibold ${clr}">${icono} ${esc(rol || "—")}</span>`;
}

function avatarHTML(u, tam = "w-12 h-12") {
  const ini = (u.nombre || u.usuario || "?").slice(0, 2).toUpperCase();
  const colores = ["bg-violet-600", "bg-sky-600", "bg-emerald-600", "bg-orange-500", "bg-rose-600", "bg-indigo-600"];
  const col = colores[(u.id || 0) % colores.length];
  if (u.foto) {
    return `<img src="${esc(u.foto)}" alt="${esc(u.nombre)}" class="${tam} rounded-full object-cover ring-2 ring-white shadow" />`;
  }
  return `<div class="${tam} rounded-full ${col} text-white font-bold flex items-center justify-center ring-2 ring-white shadow text-sm">${esc(ini)}</div>`;
}

/* Indicador de presencia en tiempo real con Supabase Presence */
function dotPresencia(u) {
  const online = estaEnLinea(u);
  if (online) {
    return `<span title="🟢 En línea (conectado ahora mismo)"
      class="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 rounded-full border-2 border-white shadow-sm bg-emerald-500 ring-2 ring-emerald-400 animate-pulse"></span>`;
  }
  return `<span title="⚪ Desconectado"
    class="absolute -bottom-0.5 -right-0.5 w-3.5 h-3.5 rounded-full border-2 border-white shadow-sm bg-slate-400"></span>`;
}

/* ---------- render principal ---------- */
export function render() {
  const soyAdmin = esAdmin();
  const todos = state.usuarios;
  const conectados = todos.filter(estaEnLinea);
  const desconectados = todos.filter((u) => !estaEnLinea(u));
  const activos = todos.filter(esActivo);
  const inactivos = todos.filter((u) => !esActivo(u));
  const lista = verInactivos ? todos : activos;

  return `
  <div class="fade space-y-5">
    <!-- Banner si no soy admin -->
    ${!soyAdmin ? `
    <div class="flex items-center gap-3 bg-amber-50 border border-amber-200 text-amber-800 rounded-2xl px-4 py-3 text-sm shadow-sm">
      <span class="text-xl">🔒</span>
      <span>Solo un <b>administrador</b> puede crear, editar o eliminar usuarios.</span>
    </div>` : ""}

    <!-- Encabezado con métricas de Presencia Real y Cuentas -->
    <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
      <div class="bg-gradient-to-br from-slate-50 to-slate-100 rounded-2xl p-3.5 text-center border border-slate-200 shadow-sm">
        <div class="text-2xl font-black text-slate-700">${todos.length}</div>
        <div class="text-[10px] font-bold text-slate-500 uppercase tracking-wider mt-0.5">Total Registrados</div>
      </div>
      <div class="bg-gradient-to-br from-emerald-50 to-emerald-100 rounded-2xl p-3.5 text-center border border-emerald-200 shadow-sm relative overflow-hidden">
        <div class="flex items-center justify-center gap-1.5">
          <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-ping"></span>
          <div class="text-2xl font-black text-emerald-700">${conectados.length}</div>
        </div>
        <div class="text-[10px] font-bold text-emerald-600 uppercase tracking-wider mt-0.5">En línea ahora</div>
      </div>
      <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-2xl p-3.5 text-center border border-blue-200 shadow-sm">
        <div class="text-2xl font-black text-blue-700">${activos.length}</div>
        <div class="text-[10px] font-bold text-blue-600 uppercase tracking-wider mt-0.5">Cuentas Activas</div>
      </div>
      <div class="bg-gradient-to-br from-slate-50 to-slate-100 rounded-2xl p-3.5 text-center border border-slate-200 shadow-sm">
        <div class="text-2xl font-black text-slate-600">${desconectados.length}</div>
        <div class="text-[10px] font-bold text-slate-500 uppercase tracking-wider mt-0.5">Desconectados</div>
      </div>
    </div>

    <!-- Lista de usuarios -->
    <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
      <div class="px-4 py-3 border-b border-slate-100 flex items-center justify-between gap-3 flex-wrap bg-slate-50/60">
        <div>
          <h2 class="font-bold text-slate-700 text-sm">Usuarios del sistema</h2>
          <p class="text-[10px] text-slate-400">${lista.length} ${lista.length === 1 ? "usuario" : "usuarios"} mostrados · 🟢 ${conectados.length} en línea</p>
        </div>
        <div class="flex items-center gap-2 flex-wrap">
          <button data-toggle-inactivos
            class="text-[10px] px-3 py-1.5 rounded-lg font-semibold border transition ${verInactivos ? "bg-[#1e3c72] text-white border-[#1e3c72]" : "bg-white text-slate-600 border-slate-200 hover:border-slate-400"}">
            ${verInactivos ? "Ocultar inactivos" : `Ver inactivos (${inactivos.length})`}
          </button>
          ${soyAdmin ? `<button data-nuevo-user
            class="text-[10px] px-3 py-1.5 rounded-lg font-bold bg-[#1e3c72] text-white hover:bg-[#2a5298] transition shadow-sm flex items-center gap-1">
            ➕ Nuevo usuario
          </button>` : ""}
        </div>
      </div>

      <div class="divide-y divide-slate-50" id="listaUsuariosContainer">
        ${lista.length === 0 ? `
        <div class="py-12 text-center text-slate-400 space-y-2">
          <div class="text-4xl">👥</div>
          <p class="text-sm font-medium">${todos.length === 0 ? "No hay usuarios registrados aún" : "Sin usuarios" + (verInactivos ? "" : " activos")}</p>
          ${soyAdmin && todos.length === 0 ? `<p class="text-xs">Crea el primer usuario con el botón <b>➕ Nuevo usuario</b></p>` : ""}
        </div>` : lista.map((u) => tarjetaUsuario(u, soyAdmin)).join("")}
      </div>
    </section>

    <!-- Info de roles -->
    <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
      <div class="px-4 py-3 border-b border-slate-100 bg-slate-50/60">
        <h2 class="font-bold text-slate-700 text-sm">Roles del sistema</h2>
      </div>
      <div class="p-4 grid grid-cols-1 md:grid-cols-3 gap-3">
        <div class="rounded-xl bg-violet-50 border border-violet-100 p-3.5">
          <div class="flex items-center gap-2 mb-1.5">${badgeRol("Administrador")}</div>
          <p class="text-[11px] text-violet-800/80">Acceso total: usuarios, compras, reportes y configuración del sistema.</p>
        </div>
        <div class="rounded-xl bg-blue-50 border border-blue-100 p-3.5">
          <div class="flex items-center gap-2 mb-1.5">${badgeRol("Empleado")}</div>
          <p class="text-[11px] text-blue-800/80">Operaciones generales: inventario, stock bajo, compras e historial diario.</p>
        </div>
        <div class="rounded-xl bg-emerald-50 border border-emerald-100 p-3.5">
          <div class="flex items-center gap-2 mb-1.5">${badgeRol("Vendedor")}</div>
          <p class="text-[11px] text-emerald-800/80">Exclusivo para el Punto de Venta (POS): cobrar, emitir notas y revisar precios.</p>
        </div>
      </div>
    </section>
  </div>`;
}

function tarjetaUsuario(u, soyAdmin) {
  const activo = esActivo(u);
  const online = estaEnLinea(u);
  const email = u.email || `${u.usuario}@libreriasanmartin.app`;
  return `
  <div class="flex items-center gap-3 px-4 py-3.5 hover:bg-slate-50/70 transition group" data-user-row="${u.id}">
    <!-- Avatar con indicador de presencia en tiempo real -->
    <div class="relative shrink-0">
      ${avatarHTML(u, "w-11 h-11")}
      ${dotPresencia(u)}
    </div>

    <!-- Info principal -->
    <div class="flex-1 min-w-0">
      <div class="flex items-center gap-2 flex-wrap">
        <span class="font-semibold text-sm text-slate-800 truncate">${esc(u.nombre || "—")}</span>
        ${badgeRol(u.rol)}
        ${online
          ? `<span class="inline-flex items-center gap-1 text-[9px] px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-700 font-bold border border-emerald-200 shadow-2xs"><span class="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-ping"></span> EN LÍNEA</span>`
          : `<span class="text-[9px] px-1.5 py-0.5 rounded-full bg-slate-100 text-slate-500 font-medium">Desconectado</span>`}
        ${!activo ? `<span class="text-[9px] px-1.5 py-0.5 rounded-full bg-red-100 text-red-600 font-bold">DADO DE BAJA</span>` : ""}
      </div>
      <div class="flex items-center gap-3 mt-0.5">
        <span class="text-[11px] text-slate-400 font-mono">@${esc(u.usuario || "")}</span>
        <span class="text-[11px] text-slate-400 truncate hidden sm:block">${esc(email)}</span>
      </div>
    </div>

    <!-- Botones de acción -->
    <div class="shrink-0 flex items-center gap-1 opacity-60 group-hover:opacity-100 transition">
      <button data-ver-user="${u.id}" title="Ver detalles"
        class="w-8 h-8 rounded-lg flex items-center justify-center text-base hover:bg-sky-50 hover:text-sky-600 transition cursor-pointer">
        👁️
      </button>
      ${soyAdmin ? `
      <button data-editusr="${u.id}" title="Editar usuario"
        class="w-8 h-8 rounded-lg flex items-center justify-center text-base hover:bg-violet-50 hover:text-violet-600 transition cursor-pointer">
        ✏️
      </button>
      <button data-${activo ? "baja" : "alta"}="${u.id}" title="${activo ? "Dar de baja" : "Reactivar"}"
        class="w-8 h-8 rounded-lg flex items-center justify-center text-base hover:bg-${activo ? "red" : "emerald"}-50 hover:text-${activo ? "red" : "emerald"}-600 transition cursor-pointer">
        ${activo ? "🗑️" : "♻️"}
      </button>` : ""}
    </div>
  </div>`;
}

function esAdmin() {
  const r = String(_ctx?.perfil?.rol || document.getElementById("rolUsuario")?.textContent || "").toLowerCase();
  return r.includes("admin");
}

/* ---------- modal: ver usuario ---------- */
function modalVerUsuario(id) {
  const u = state.usuarios.find((x) => String(x.id) === String(id));
  if (!u) return;
  const activo = esActivo(u);
  const online = estaEnLinea(u);
  const email = u.email || `${u.usuario}@libreriasanmartin.app`;
  const creadoEn = u.created_at ? new Date(u.created_at).toLocaleDateString("es-BO", { dateStyle: "medium" }) : "—";
  modal({
    titulo: "Detalles del usuario", ancho: "max-w-sm",
    cuerpo: `
    <div class="space-y-4">
      <div class="flex items-center gap-4">
        <div class="relative">${avatarHTML(u, "w-16 h-16")}${dotPresencia(u)}</div>
        <div>
          <div class="font-bold text-lg text-slate-800">${esc(u.nombre || "—")}</div>
          <div class="mt-1">${badgeRol(u.rol)}</div>
        </div>
      </div>
      <div class="space-y-2 text-sm bg-slate-50 rounded-xl p-3.5">
        <div class="flex justify-between gap-3">
          <span class="text-slate-500">Conexión</span>
          <span class="px-2 py-0.5 rounded-full text-[10px] font-bold ${online ? "bg-emerald-100 text-emerald-700" : "bg-slate-200 text-slate-600"}">
            ${online ? "🟢 En línea (Conectado ahora)" : "⚪ Desconectado"}
          </span>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-slate-500">Usuario</span>
          <b class="font-mono">@${esc(u.usuario || "—")}</b>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-slate-500">Correo</span>
          <b class="text-right text-[11px] break-all">${esc(email)}</b>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-slate-500">Estado cuenta</span>
          <span class="px-2 py-0.5 rounded-full text-[10px] font-bold ${activo ? "bg-blue-100 text-blue-700" : "bg-red-100 text-red-600"}">
            ${activo ? "Habilitado" : "Dado de baja"}
          </span>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-slate-500">ID interno</span>
          <b class="font-mono text-[10px] text-slate-400">${u.id}</b>
        </div>
      </div>
    </div>`,
    acciones: [
      { texto: "Cerrar", clase: "bg-slate-200 text-slate-700", fn: () => true },
      ...(esAdmin() ? [{ texto: "✏️ Editar", clase: "bg-[#1e3c72] text-white", fn: () => { modalEditarUsuario(id); return true; } }] : []),
    ],
  });
}

/* ---------- modal: editar usuario ---------- */
async function modalEditarUsuario(id) {
  let u = state.usuarios.find((x) => String(x.id) === String(id));
  if (!u) {
    try {
      const r = await fetch(`/api/usuarios?_t=${Date.now()}`, { cache: "no-store" });
      if (r.ok) {
        const list = await r.json();
        if (Array.isArray(list) && list.length > 0) {
          state.usuarios = list;
          u = list.find((x) => String(x.id) === String(id));
        }
      }
    } catch {}
  }
  if (!u) {
    toast("No se encontró el usuario a editar", "warn");
    return;
  }
  const emailActual = u.email || `${u.usuario}@libreriasanmartin.app`;
  let fotoActual = u.foto || null;

  modal({
    titulo: `Editar usuario (${u.usuario})`, ancho: "max-w-md",
    cuerpo: `<div class="space-y-3.5">
      <div class="flex items-center gap-3 bg-slate-50 rounded-xl p-3 border border-slate-100">
        <div id="editPreviewAvatar" class="relative shrink-0">
          ${avatarHTML(u, "w-12 h-12")}
        </div>
        <div class="text-sm min-w-0">
          <div class="font-bold text-slate-800 truncate">${esc(u.nombre)}</div>
          <div class="text-slate-400 text-xs font-mono">@${esc(u.usuario)}</div>
          <div class="text-slate-400 text-[11px] truncate">${esc(emailActual)}</div>
        </div>
      </div>

      ${input("Nombre completo *", { id: "uNombre", value: esc(u.nombre), placeholder: "Ej. Guilberto Guillermo" })}
      
      <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        ${input("Usuario de acceso (@) *", { id: "uUsuario", value: esc(u.usuario), autocapitalize: "none", spellcheck: "false" })}
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Correo electrónico</span>
          <input id="uEmail" type="email" value="${esc(u.email || "")}" placeholder="ejemplo@gmail.com"
            class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298] focus:border-transparent" />
        </label>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 gap-2.5">
        ${select("Rol / Permisos *", ROLES.map((r) => ({ v: r, t: r })), { id: "uRol", value: u.rol })}
        ${select("Estado de cuenta *", ESTADO_OPTS, { id: "uEstado", value: esActivo(u) ? "Activo" : "Inactivo" })}
      </div>

      ${input("Nueva Contraseña / PIN (vacío = mantener actual)", { id: "uPin", type: "password", autocomplete: "new-password", placeholder: "Cualquier contraseña (ej. Madugador 23)" })}

      <label class="block">
        <span class="block text-xs font-semibold text-slate-500 mb-1">Foto de perfil</span>
        <div class="flex items-center gap-3">
          <div id="editPreviewFoto" class="w-12 h-12 rounded-full overflow-hidden shrink-0 border border-slate-200">
            ${avatarHTML(u, "w-12 h-12")}
          </div>
          <div class="flex-1 space-y-1">
            <input id="uFoto" type="file" accept="image/*"
              class="w-full text-xs file:mr-2 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-blue-50 file:text-[#2a5298] hover:file:bg-blue-100 cursor-pointer" />
            <div class="flex gap-2">
              <button type="button" id="btnQuitarFoto" class="text-[10px] text-red-600 hover:underline">Quitar foto actual</button>
            </div>
          </div>
        </div>
      </label>
    </div>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "💾 Guardar cambios", clase: "bg-[#1e3c72] text-white",
        fn: async (w) => {
          const nombre = w.querySelector("#uNombre").value.trim();
          const usuario = w.querySelector("#uUsuario").value.trim().toLowerCase();
          const email = w.querySelector("#uEmail").value.trim().toLowerCase();
          const pin = w.querySelector("#uPin")?.value || "";
          const rol = w.querySelector("#uRol").value;
          const estadoVal = w.querySelector("#uEstado").value;

          if (!nombre) { toast("Escribe el nombre completo", "warn"); return false; }
          if (!usuario) { toast("Escribe el usuario de acceso", "warn"); return false; }
          if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            toast("Escribe un correo electrónico válido", "warn"); return false;
          }
          if (pin && pin.length > 100) {
            toast("La contraseña no debe superar los 100 caracteres", "warn"); return false;
          }

          const fileInput = w.querySelector("#uFoto");
          let foto = fotoActual;
          if (fileInput?.files?.[0]) {
            try {
              foto = await procesarImagen(fileInput.files[0]);
            } catch (e) {
              toast("Error al procesar la foto: " + e.message, "warn");
            }
          }

          /* ── Protección: degradar a un Administrador requiere clave maestra ── */
          let claveMaestra = undefined;
          const rolOriginal = String(u.rol || "").toLowerCase();
          const rolNuevo = String(rol || "").toLowerCase();
          if (rolOriginal === "administrador" && rolNuevo !== "administrador") {
            claveMaestra = await new Promise((resolve) => {
              const m = modal({
                titulo: "⚠️ Autorización de Seguridad", ancho: "max-w-sm",
                cuerpo: `
                <div class="text-center space-y-3">
                  <div class="text-5xl animate-bounce">🚨</div>
                  <div class="bg-red-50 border-2 border-red-200 rounded-xl p-4 space-y-2">
                    <p class="text-sm font-bold text-red-700">⚠️ ALERTA DE SEGURIDAD ⚠️</p>
                    <p class="text-xs text-red-600">
                      Estás a punto de <b>revocar los privilegios de Administrador</b> a
                      <b class="text-red-800">${esc(u.nombre || u.usuario)}</b>
                      y asignarle el rol <b class="text-red-800">${esc(rol)}</b>.
                    </p>
                    <p class="text-[11px] text-red-500 italic">
                      Solo el Administrador Principal (Jeremy) posee la contraseña maestra para autorizar esta acción.
                    </p>
                  </div>
                  <label class="block text-left">
                    <span class="block text-xs font-semibold text-slate-600 mb-1">🔑 Contraseña Maestra</span>
                    <input id="inputClaveMaestra" type="password" placeholder="Ingresa la contraseña maestra"
                      class="w-full px-3 py-2.5 border-2 border-red-300 rounded-lg text-sm outline-none
                             focus:ring-2 focus:ring-red-400 focus:border-transparent bg-white
                             placeholder:text-slate-400" autocomplete="off" />
                  </label>
                </div>`,
                acciones: [
                  { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => { resolve(null); return true; } },
                  { texto: "🔓 Autorizar", clase: "bg-red-600 text-white hover:bg-red-700", fn: (mw) => {
                    const val = mw.querySelector("#inputClaveMaestra")?.value?.trim();
                    if (!val) { toast("Debes ingresar la contraseña maestra", "warn"); return false; }
                    resolve(val);
                    return true;
                  }},
                ],
              });
              /* Si cierra el modal con la X, también cancelar */
              m.wrap.querySelector("[data-cerrar]").addEventListener("click", () => resolve(null));
            });

            if (!claveMaestra) {
              toast("🚫 Operación cancelada. No se proporcionó la contraseña maestra.", "warn");
              return false;
            }
          }

          try {
            await repo.guardarUsuario({
              usuarioId: id,
              nombre,
              usuario,
              email,
              rol,
              estado: estadoVal,
              foto,
              pin: pin || undefined,
              claveMaestra,
              idUsuario: _ctx?.perfil?.usuarioId,
            });

            toast(`✅ Usuario "${nombre}" actualizado correctamente`);
            _ctx?.rerender();
            _ctx?.recargar().catch(() => {});
            return true;
          } catch (err) {
            toast("❌ " + (err.message || "Error al actualizar usuario"), "error", 5000);
            return false;
          }
        },
      },
    ],
  });

  setTimeout(() => {
    const fi = document.querySelector("#uFoto");
    const prev = document.querySelector("#editPreviewFoto");
    const btnQuitar = document.querySelector("#btnQuitarFoto");
    if (fi && prev) {
      fi.addEventListener("change", async () => {
        const file = fi.files?.[0];
        if (!file) return;
        try {
          fotoActual = await procesarImagen(file);
          prev.innerHTML = `<img src="${fotoActual}" class="w-full h-full object-cover" />`;
        } catch { }
      });
    }
    if (btnQuitar && prev) {
      btnQuitar.addEventListener("click", () => {
        fotoActual = "";
        if (fi) fi.value = "";
        const ini = (u.nombre || "?").slice(0, 2).toUpperCase();
        prev.innerHTML = `<div class="w-full h-full bg-slate-200 text-slate-600 font-bold flex items-center justify-center text-xs">${esc(ini)}</div>`;
        toast("Foto eliminada. Guarda los cambios para aplicar.");
      });
    }
  }, 100);
}

/* ---------- modal: nuevo usuario ---------- */
function modalNuevoUsuario() {
  modal({
    titulo: "Nuevo usuario", ancho: "max-w-md",
    cuerpo: `<div class="space-y-3">
      <p class="text-[11px] text-slate-600 bg-blue-50 border border-blue-100 rounded-xl px-3 py-2.5">
        💡 Se crea la cuenta completa. El usuario podrá iniciar sesión de inmediato con el usuario y PIN que definas.
      </p>
      ${input("Nombre completo *", { id: "nNombre", placeholder: "Ej.: Ana María Ríos" })}
      ${input("Usuario de acceso *", { id: "nUsuario", placeholder: "Ej.: ana", autocapitalize: "none", spellcheck: "false" })}
      <label class="block">
        <span class="block text-xs font-semibold text-slate-500 mb-1">Correo electrónico *</span>
        <input id="nEmail" type="email" required placeholder="ejemplo@gmail.com"
          class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298] focus:border-transparent" />
        <span class="text-[10px] text-slate-400 mt-0.5 block">📌 Debe ser único. Se usa para la autenticación en Supabase.</span>
      </label>
      ${input("PIN / Contraseña *", { id: "nPin", type: "password", autocomplete: "new-password", placeholder: "Cualquier contraseña (ej. Madugador 23)" })}
      ${select("Rol / Acceso *", ROLES.map((r) => ({ v: r, t: r })), { id: "nRol" })}
      ${select("Estado", ESTADO_OPTS, { id: "nEstado", value: "Activo" })}
      <label class="block">
        <span class="block text-xs font-semibold text-slate-500 mb-1">Foto de perfil (opcional)</span>
        <div class="flex items-center gap-3">
          <div id="previewFotoNuevo" class="w-12 h-12 rounded-full bg-slate-100 border-2 border-dashed border-slate-300 flex items-center justify-center text-xl text-slate-400 overflow-hidden shrink-0">
            👤
          </div>
          <input id="nFoto" type="file" accept="image/*"
            class="flex-1 text-xs file:mr-2 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-blue-50 file:text-[#2a5298] hover:file:bg-blue-100 cursor-pointer" />
        </div>
      </label>
    </div>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "➕ Crear usuario", clase: "bg-[#1e3c72] text-white",
        fn: async (w) => {
          const nombre = w.querySelector("#nNombre").value.trim();
          const usuario = w.querySelector("#nUsuario").value.trim().toLowerCase();
          const email = w.querySelector("#nEmail").value.trim().toLowerCase();
          const pin = w.querySelector("#nPin")?.value || "";
          if (!nombre) { toast("Escribe el nombre completo", "warn"); return false; }
          if (!usuario) { toast("Escribe el usuario de acceso", "warn"); return false; }
          if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
            toast("Escribe un correo electrónico válido", "warn"); return false;
          }
          if (!pin || pin.length < 1 || pin.length > 100) {
            toast("La contraseña debe tener entre 1 y 100 caracteres", "warn"); return false;
          }
          let foto = null;
          const fi = w.querySelector("#nFoto");
          if (fi?.files?.[0]) {
            try { foto = await procesarImagen(fi.files[0]); } catch (e) { toast("Error al procesar la foto: " + e.message, "warn"); }
          }
          try {
            await repo.crearUsuario({
              nombre, usuario, pin, email, foto,
              rol: w.querySelector("#nRol").value,
              estado: w.querySelector("#nEstado").value,
              idUsuario: _ctx?.perfil?.usuarioId,
            });
            toast(`✅ Usuario "${nombre}" creado correctamente`);
            await _ctx?.recargar();
            _ctx?.rerender();
            return true;
          } catch (err) {
            const m = err.message || "";
            if (m.includes("email_exists") || m.includes("422") || m.includes("registrado") || m.includes("Intente con otro")) {
              toast("⚠️ El correo o usuario ya se encuentra registrado. Intente con otro.", "error", 5500);
            } else if (m.includes("409") || m.includes("ya existe")) {
              toast("⚠️ El nombre de usuario ya existe. Usa otro.", "error", 5000);
            } else if (m.includes("403")) {
              toast("🔒 Solo un administrador puede crear usuarios.", "error", 4000);
            } else {
              toast("❌ " + (m || "No se pudo crear el usuario. Intenta de nuevo."), "error", 5000);
            }
            return false;
          }
        },
      },
    ],
  });

  setTimeout(() => {
    const fi = document.querySelector("#nFoto");
    const prev = document.querySelector("#previewFotoNuevo");
    if (fi && prev) {
      fi.addEventListener("change", async () => {
        const file = fi.files?.[0];
        if (!file) return;
        try {
          const d = await procesarImagen(file);
          prev.innerHTML = `<img src="${d}" class="w-full h-full object-cover rounded-full" />`;
        } catch { }
      });
    }
  }, 100);
}

/* ---------- confirmar baja / alta ---------- */
async function cambiarEstado(id, nuevoEstado) {
  const u = state.usuarios.find((x) => String(x.id) === String(id));
  if (!u) return;
  const deBaja = nuevoEstado === "Inactivo";
  const ok = await confirmar(
    deBaja
      ? `¿Dar de baja a <b>${esc(u.nombre)}</b>?<br/><span class="text-[12px] text-slate-500">Dejará de poder iniciar sesión. Sus registros se conservan.</span>`
      : `¿Reactivar a <b>${esc(u.nombre)}</b>?<br/><span class="text-[12px] text-slate-500">Volverá a poder iniciar sesión.</span>`,
    deBaja ? "🗑️ Sí, dar de baja" : "♻️ Sí, reactivar"
  );
  if (!ok) return;
  try {
    await repo.cambiarEstadoUsuario({ usuarioId: id, estado: nuevoEstado, idUsuario: _ctx?.perfil?.usuarioId });
    toast(deBaja ? `${u.nombre} fue dado de baja` : `${u.nombre} fue reactivado`);
    await _ctx?.recargar(); _ctx?.rerender();
  } catch (err) {
    toast("Error al cambiar el estado: " + err.message, "error");
  }
}

/* ---------- procesado de imagen ---------- */
function procesarImagen(file, maxW = 360, maxH = 360, quality = 0.82) {
  return new Promise((resolve, reject) => {
    if (!file || !file.type.startsWith("image/")) return reject(new Error("Archivo no válido"));
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        let { width: w, height: h } = img;
        if (w > maxW || h > maxH) { const r = Math.min(maxW / w, maxH / h); w = Math.round(w * r); h = Math.round(h * r); }
        const c = document.createElement("canvas"); c.width = w; c.height = h;
        c.getContext("2d").drawImage(img, 0, 0, w, h);
        resolve(c.toDataURL("image/jpeg", quality));
      };
      img.onerror = () => reject(new Error("No se pudo procesar la imagen"));
      img.src = e.target.result;
    };
    reader.onerror = () => reject(new Error("Error al leer el archivo"));
    reader.readAsDataURL(file);
  });
}

/* ---------- montaje de eventos ---------- */
let cargandoAuto = false;
export async function onRender() {
  if ((!state.usuarios || state.usuarios.length === 0) && !cargandoAuto) {
    cargandoAuto = true;
    try {
      const r = await fetch("/api/usuarios");
      if (r.ok) {
        const list = await r.json();
        if (Array.isArray(list) && list.length > 0) {
          state.usuarios = list;
          _ctx?.rerender();
        }
      }
    } catch (e) {
      console.warn("onRender auto fetch error:", e);
    } finally {
      cargandoAuto = false;
    }
  }
}

export function mount(root, ctx) {
  _ctx = ctx;
  if (!state.usuarios || state.usuarios.length === 0) {
    onRender();
  }
  root.addEventListener("click", (e) => {
    if (e.target.closest("[data-toggle-inactivos]")) {
      verInactivos = !verInactivos;
      ctx.rerender();
      return;
    }
    if (e.target.closest("[data-nuevo-user]")) return modalNuevoUsuario();

    const ver = e.target.closest("[data-ver-user]");
    if (ver) return modalVerUsuario(ver.dataset.verUser);

    const ed = e.target.closest("[data-editusr]");
    if (ed) return modalEditarUsuario(ed.dataset.editusr);

    const baja = e.target.closest("[data-baja]");
    if (baja) return cambiarEstado(baja.dataset.baja, "Inactivo");

    const alta = e.target.closest("[data-alta]");
    if (alta) return cambiarEstado(alta.dataset.alta, "Activo");
  });
}