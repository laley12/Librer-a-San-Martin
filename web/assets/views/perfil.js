import { esc, toast } from "../ui.js";
import { cambiarClave, perfilActual, signOut } from "../supabase-client.js";
import { estadoRealtime, repo, state } from "../data.js";

export const meta = { id: "perfil", titulo: "Mi Perfil", icono: "👤", grupo: "Cuenta" };

export const VERSION = "v2.0";

let _ctx = null;

function procesarImagen(file, maxWidth = 360, maxHeight = 360, quality = 0.82) {
  return new Promise((resolve, reject) => {
    if (!file || !file.type.startsWith("image/")) {
      return reject(new Error("Por favor selecciona un archivo de imagen válido"));
    }
    const reader = new FileReader();
    reader.onload = (e) => {
      const img = new Image();
      img.onload = () => {
        let { width, height } = img;
        if (width > maxWidth || height > maxHeight) {
          const ratio = Math.min(maxWidth / width, maxHeight / height);
          width = Math.round(width * ratio);
          height = Math.round(height * ratio);
        }
        const canvas = document.createElement("canvas");
        canvas.width = width;
        canvas.height = height;
        const ctx = canvas.getContext("2d");
        ctx.drawImage(img, 0, 0, width, height);
        resolve(canvas.toDataURL("image/jpeg", quality));
      };
      img.onerror = () => reject(new Error("No se pudo procesar la imagen"));
      img.src = e.target.result;
    };
    reader.onerror = () => reject(new Error("Error al leer el archivo"));
    reader.readAsDataURL(file);
  });
}

export function render() {
  const p = _ctx?.perfil || {};
  const iniciales = (p.nombre || p.usuario || "LS").slice(0, 2).toUpperCase();
  const rol = p.rol || "Empleado";

  let con;
  if (!navigator.onLine) con = { t: "Sin conexión a Internet", c: "bg-red-400" };
  else if (estadoRealtime) con = { t: "En línea · Supabase Realtime activo", c: "bg-emerald-400" };
  else con = { t: "Conectando…", c: "bg-amber-400" };

  return `
  <div class="space-y-4 md:space-y-6 fade max-w-2xl mx-auto">
    <section class="rounded-2xl bg-gradient-to-br from-[#1e3c72] via-[#2a5298] to-[#1e3c72] p-5 md:p-6 text-white shadow-lg relative overflow-hidden">
      <div class="flex items-center gap-4 md:gap-5 relative z-10">
        <div class="relative shrink-0 group">
          <div class="w-20 h-20 md:w-24 md:h-24 rounded-full border-2 border-white/50 bg-white/20 shadow-xl overflow-hidden grid place-items-center">
            ${p.foto
              ? `<img id="avatarPerfilImg" src="${esc(p.foto)}" alt="" class="w-full h-full object-cover" />`
              : `<span id="avatarPerfilTxt" class="text-2xl md:text-3xl font-bold">${esc(iniciales)}</span>`
            }
          </div>
          <label for="inputFotoDirecta" title="Cambiar foto de perfil"
            class="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-white text-[#1e3c72] shadow-lg flex items-center justify-center cursor-pointer hover:bg-slate-100 active:scale-95 transition border border-slate-200">
            <span class="text-sm leading-none">📷</span>
            <input type="file" id="inputFotoDirecta" accept="image/*" class="hidden" />
          </label>
        </div>
        <div class="min-w-0 grow">
          <div class="text-lg md:text-2xl font-bold leading-tight truncate">${esc(p.nombre || "—")}</div>
          <div class="mt-1 flex flex-wrap items-center gap-2">
            <span class="inline-block px-2.5 py-0.5 rounded-full bg-white/20 text-[11px] font-semibold tracking-wide">${esc(rol)}</span>
            <span class="text-xs text-blue-100 truncate">${esc(p.email || (p.usuario + "@libreriasanmartin.app"))}</span>
          </div>
          <div class="mt-1 text-[11px] text-blue-200 font-mono">@${esc(p.usuario || "")}</div>
        </div>
        <button data-accion="editar"
          class="shrink-0 flex items-center gap-1.5 px-3.5 py-2.5 rounded-xl bg-white/15 hover:bg-white/25 text-xs font-semibold backdrop-blur-sm border border-white/20 shadow-sm active:scale-[0.98] transition">
          ✏️ Editar
        </button>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 md:p-5 shadow-sm">
      <div class="flex items-center justify-between mb-3 border-b border-slate-100 pb-2.5">
        <h2 class="text-xs uppercase tracking-wider text-slate-500 font-bold">Datos de la cuenta</h2>
        <button data-accion="editar" class="text-xs text-[#2a5298] font-semibold hover:underline">Modificar</button>
      </div>
      <div class="space-y-3 text-sm">
        <div class="flex justify-between items-center gap-3">
          <span class="text-slate-500 shrink-0">Nombre completo</span>
          <b class="text-right text-slate-800">${esc(p.nombre || "—")}</b>
        </div>
        <div class="flex justify-between items-center gap-3">
          <span class="text-slate-500 shrink-0">Usuario de acceso</span>
          <b class="text-right font-mono text-slate-800">@${esc(p.usuario || "—")}</b>
        </div>
        <div class="flex justify-between items-center gap-3">
          <span class="text-slate-500 shrink-0">Correo electrónico</span>
          <b class="text-right text-slate-800 break-all">${esc(p.email || (p.usuario + "@libreriasanmartin.app"))}</b>
        </div>
        <div class="flex justify-between items-center gap-3">
          <span class="text-slate-500 shrink-0">Rol asignado</span>
          <span class="text-right font-semibold text-[#1e3c72]">${esc(rol)}</span>
        </div>
      </div>
      <div class="mt-4 pt-3 border-t border-slate-100 grid grid-cols-1 md:grid-cols-2 gap-2">
        <button data-accion="editar"
          class="flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white text-xs font-semibold shadow-sm transition active:scale-[0.98]">
          ✏️ Editar perfil y foto
        </button>
        <button data-accion="pin"
          class="flex items-center justify-center gap-2 px-4 py-3 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-700 text-xs font-semibold transition active:scale-[0.98]">
          🔑 Cambiar PIN / Contraseña
        </button>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 md:p-5 shadow-sm">
      <h2 class="text-xs uppercase tracking-wider text-slate-500 font-bold mb-3 border-b border-slate-100 pb-2.5">Estado del sistema</h2>
      <div class="space-y-3 text-sm">
        <div class="flex items-center justify-between gap-3">
          <span class="text-slate-500 shrink-0">Conexión</span>
          <span class="flex items-center gap-2 text-right">
            <span class="w-2.5 h-2.5 rounded-full ${con.c} shrink-0"></span>
            <b class="text-xs text-slate-700">${esc(con.t)}</b>
          </span>
        </div>
        <div class="flex justify-between gap-3">
          <span class="text-slate-500 shrink-0">Versión</span>
          <b class="text-right text-xs text-slate-700">${VERSION} · Librería San Martín</b>
        </div>
      </div>
    </section>

    <button data-accion="salir"
      class="w-full flex items-center justify-center gap-2 px-4 py-3.5 rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-bold shadow-md transition active:scale-[0.98]">
      <span>🚪</span> Cerrar sesión
    </button>
  </div>`;
}

async function renovarPerfil() {
  const nuevo = await perfilActual();
  if (nuevo && _ctx) {
    Object.assign(_ctx.perfil, nuevo);
    if ($("nombreUsuario")) $("nombreUsuario").textContent = nuevo.nombre || nuevo.usuario;
    if ($("rolUsuario")) $("rolUsuario").textContent = nuevo.rol;
    const av = $("avatar");
    if (av) {
      av.style.overflow = "hidden";
      av.innerHTML = nuevo.foto
        ? `<img src="${esc(nuevo.foto)}" alt="" class="w-full h-full object-cover" />`
        : (nuevo.nombre || "LS").slice(0, 2).toUpperCase();
    }
  }
  _ctx?.rerender();
}

function modalEditarDatos() {
  const p = _ctx?.perfil || {};
  let nuevaFotoBase64 = p.foto || "";

  const wrap = document.createElement("div");
  wrap.className = "fixed inset-0 z-[1000] bg-slate-900/80 backdrop-blur-sm flex items-end md:items-center justify-center p-0 md:p-4";
  wrap.innerHTML = `
    <form id="formEditarPerfil" class="bg-white w-full max-w-md md:rounded-2xl rounded-t-2xl shadow-2xl flex flex-col max-h-[92vh] fade">
      <div class="px-6 pt-5 pb-3 border-b border-slate-100 flex items-center justify-between shrink-0">
        <div>
          <h2 class="text-lg font-bold text-[#1e3c72]">Editar Perfil</h2>
          <p class="text-xs text-slate-500 mt-0.5">Actualiza tus datos de usuario, foto y credenciales</p>
        </div>
        <button type="button" id="btnCerrarModalEdit" class="text-slate-400 hover:text-slate-600 text-xl p-1">×</button>
      </div>

      <div class="px-6 py-4 space-y-4 overflow-y-auto grow">
        <!-- Foto de Perfil con vista previa -->
        <div class="flex items-center gap-4 p-3 bg-slate-50 border border-slate-200 rounded-xl">
          <div class="relative w-16 h-16 rounded-full overflow-hidden bg-slate-200 border-2 border-white shadow-md shrink-0 grid place-items-center">
            <img id="editPreviewFoto" src="${nuevaFotoBase64 || './assets/images/logo.png'}" alt="Foto" class="w-full h-full object-cover ${nuevaFotoBase64 ? '' : 'opacity-40'}" />
          </div>
          <div class="min-w-0 grow">
            <span class="block text-xs font-bold text-slate-700 mb-1">Foto de perfil</span>
            <label class="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg bg-white border border-slate-300 text-slate-700 text-xs font-semibold cursor-pointer hover:bg-slate-100 active:scale-95 transition shadow-sm">
              <span>📷 Subir o tomar foto</span>
              <input type="file" id="dFotoFile" accept="image/*" class="hidden" />
            </label>
            ${nuevaFotoBase64 ? `<button type="button" id="btnQuitarFoto" class="block mt-1 text-[11px] text-red-500 hover:underline">Quitar foto</button>` : ''}
          </div>
        </div>

        <label class="block">
          <span class="block text-xs font-semibold text-slate-600 mb-1">Nombre completo *</span>
          <input id="dNombre" type="text" value="${esc(p.nombre || "")}" required autocomplete="name"
            class="w-full px-3 py-2.5 border border-slate-300 rounded-xl text-sm outline-none focus:ring-2 focus:ring-[#2a5298] transition" />
        </label>

        <label class="block">
          <span class="block text-xs font-semibold text-slate-600 mb-1">Usuario de acceso *</span>
          <input id="dUsuario" type="text" value="${esc(p.usuario || "")}" required autocomplete="username"
            class="w-full px-3 py-2.5 border border-slate-300 rounded-xl text-sm font-mono outline-none focus:ring-2 focus:ring-[#2a5298] transition" />
        </label>

        <label class="block">
          <span class="block text-xs font-semibold text-slate-600 mb-1">Correo electrónico</span>
          <input id="dEmail" type="email" value="${esc(p.email || (p.usuario + "@libreriasanmartin.app"))}" autocomplete="email"
            class="w-full px-3 py-2.5 border border-slate-300 rounded-xl text-sm outline-none focus:ring-2 focus:ring-[#2a5298] transition" />
        </label>

        <div class="pt-2 border-t border-slate-100">
          <label class="block">
            <span class="block text-xs font-semibold text-slate-600 mb-1">Nueva contraseña / PIN (opcional)</span>
            <input id="dClave" type="password" autocomplete="new-password" placeholder="Dejar en blanco para mantener la actual"
              class="w-full px-3 py-2.5 border border-slate-300 rounded-xl text-sm outline-none focus:ring-2 focus:ring-[#2a5298] transition" />
            <span class="block text-[11px] text-slate-400 mt-1">Si deseas cambiar tu PIN de acceso, escribe uno nuevo de 4 a 12 caracteres.</span>
          </label>
        </div>
      </div>

      <div class="px-6 py-3.5 border-t border-slate-100 flex gap-2 shrink-0 bg-slate-50 md:rounded-b-2xl">
        <button type="button" id="cancelarEdit" class="flex-1 py-2.5 rounded-xl bg-slate-200 hover:bg-slate-300 text-slate-700 text-xs font-bold transition">Cancelar</button>
        <button type="submit" id="btnGuardarEdit" class="flex-1 py-2.5 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white text-xs font-bold shadow-md shadow-blue-900/20 transition">Guardar</button>
      </div>
    </form>`;

  document.body.appendChild(wrap);

  const fileInput = wrap.querySelector("#dFotoFile");
  const previewImg = wrap.querySelector("#editPreviewFoto");

  fileInput.onchange = async (ev) => {
    const file = ev.target.files?.[0];
    if (!file) return;
    try {
      toast("Procesando imagen...", "ok", 1500);
      nuevaFotoBase64 = await procesarImagen(file, 400, 400, 0.82);
      previewImg.src = nuevaFotoBase64;
      previewImg.classList.remove("opacity-40");
    } catch (err) {
      toast(err.message, "error");
    }
  };

  const btnQuitar = wrap.querySelector("#btnQuitarFoto");
  if (btnQuitar) {
    btnQuitar.onclick = () => {
      nuevaFotoBase64 = "";
      previewImg.src = "./assets/images/logo.png";
      previewImg.classList.add("opacity-40");
      btnQuitar.remove();
    };
  }

  const cerrar = () => wrap.remove();
  wrap.querySelector("#cancelarEdit").onclick = cerrar;
  wrap.querySelector("#btnCerrarModalEdit").onclick = cerrar;
  wrap.addEventListener("click", (e) => { if (e.target === wrap) cerrar(); });

  wrap.querySelector("form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const btn = wrap.querySelector("#btnGuardarEdit");
    btn.disabled = true;
    btn.textContent = "Guardando...";

    try {
      const nombre = wrap.querySelector("#dNombre").value.trim();
      const usuario = wrap.querySelector("#dUsuario").value.trim().toLowerCase();
      const email = wrap.querySelector("#dEmail").value.trim();
      const claveNueva = wrap.querySelector("#dClave").value.trim();

      if (!nombre) throw new Error("El nombre no puede estar vacío");
      if (!usuario) throw new Error("El usuario no puede estar vacío");

      const usuarioId = p.usuarioId;
      if (!usuarioId) throw new Error("ID de usuario no identificado");

      // Actualizar datos de usuario y foto en Supabase
      await repo.actualizarPerfilPropio({
        usuarioId,
        nombre,
        usuario,
        email: email || `${usuario}@libreriasanmartin.app`,
        foto: nuevaFotoBase64,
      });

      // Si especificó nueva contraseña / PIN
      if (claveNueva) {
        if (claveNueva.length < 4 || claveNueva.length > 12) {
          throw new Error("El nuevo PIN debe tener entre 4 y 12 caracteres");
        }
        await cambiarClave(claveNueva);
      }

      wrap.remove();
      await renovarPerfil();
      toast("✅ Perfil actualizado con éxito", "ok", 3500);
    } catch (err) {
      console.error("[LSM] Error actualizando perfil:", err);
      toast(err.message || "Error al actualizar perfil", "error");
    } finally {
      btn.disabled = false;
      btn.textContent = "Guardar";
    }
  });
}

function modalCambiarPin() {
  const wrap = document.createElement("div");
  wrap.className = "fixed inset-0 z-[1000] bg-slate-900/80 backdrop-blur-sm flex items-center justify-center p-4";
  wrap.innerHTML = `
    <div class="bg-white w-full max-w-md rounded-2xl shadow-2xl fade">
      <div class="px-6 pt-6 pb-2 text-center border-b border-slate-100">
        <div class="text-3xl">🔑</div>
        <h2 class="mt-2 text-lg font-bold text-[#1e3c72]">Cambiar PIN / Contraseña</h2>
        <p class="text-xs text-slate-500 mt-1">Elige un PIN nuevo para acceder a tu cuenta.</p>
      </div>
      <form id="formPinPerfil" class="px-6 py-5 space-y-4">
        <label class="block">
          <span class="block text-xs font-semibold text-slate-600 mb-1">PIN nuevo</span>
          <input id="clave1" type="password" required autocomplete="new-password" inputmode="numeric" placeholder="Ingresa tu nuevo PIN"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <label class="block">
          <span class="block text-xs font-semibold text-slate-600 mb-1">Repite el PIN</span>
          <input id="clave2" type="password" required autocomplete="new-password" inputmode="numeric" placeholder="Repite tu nuevo PIN"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <p class="text-[11px] text-slate-500 bg-slate-50 border border-slate-200 rounded-lg px-3 py-2">
          Entre 4 y 12 caracteres. Evita <code>12345</code> y PINs fáciles de adivinar.
        </p>
        <button class="w-full py-3 rounded-lg bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition shadow-md">Guardar PIN</button>
        <button type="button" id="cancelarPin" class="w-full py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 text-sm font-semibold transition">Cancelar</button>
      </form>
    </div>`;
  document.body.appendChild(wrap);
  wrap.querySelector("#cancelarPin").onclick = () => wrap.remove();
  wrap.addEventListener("click", (e) => { if (e.target === wrap) wrap.remove(); });
  wrap.querySelector("#formPinPerfil").addEventListener("submit", async (e) => {
    e.preventDefault();
    const a = wrap.querySelector("#clave1").value;
    const b = wrap.querySelector("#clave2").value;
    if (a.length < 4 || a.length > 12) return toast("El PIN debe tener entre 4 y 12 caracteres", "warn");
    if (a !== b) return toast("Los PIN no coinciden", "warn");
    if (/^(1234|12345|123456|0000|password|clave123|admin|abc123)$/i.test(a)) {
      return toast("Ese PIN es demasiado fácil. Elige otro.", "warn");
    }
    try {
      await cambiarClave(a);
      wrap.remove();
      _ctx?.rerender();
      toast("✅ Perfil actualizado con éxito", "ok", 3500);
    } catch (ex) {
      toast(ex.message, "error");
    }
  });
}

async function cerrarSesion() {
  try { await signOut(); } catch (e) { console.warn("[LSM] signOut", e); }
  location.reload();
}

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", (e) => {
    const b = e.target.closest("[data-accion]");
    if (!b) return;
    if (b.dataset.accion === "pin") modalCambiarPin();
    if (b.dataset.accion === "salir") cerrarSesion();
    if (b.dataset.accion === "editar") modalEditarDatos();
  });

  const inputFoto = root.querySelector("#inputFotoDirecta");
  if (inputFoto) {
    inputFoto.addEventListener("change", async (ev) => {
      const file = ev.target.files?.[0];
      if (!file) return;
      try {
        toast("Procesando imagen...", "ok", 1500);
        const fotoBase64 = await procesarImagen(file, 400, 400, 0.82);
        const p = _ctx?.perfil;
        if (p?.usuarioId) {
          await repo.actualizarPerfilPropio({
            usuarioId: p.usuarioId,
            foto: fotoBase64,
          });
          await renovarPerfil();
          toast("✅ Perfil actualizado con éxito", "ok", 3500);
        }
      } catch (err) {
        toast(err.message, "error");
      }
    });
  }
}

function $(id) {
  return document.getElementById(id);
}