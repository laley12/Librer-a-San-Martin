import { esc, toast, $ } from "../ui.js";
import { cambiarClave, perfilActual, signOut } from "../supabase-client.js";
import { estadoRealtime, repo, state } from "../data.js";

export const meta = { id: "perfil", titulo: "Mi Perfil", icono: "👤", grupo: "Cuenta" };

export const VERSION = "v1.4";

function datos() {
  const p = _ctx?.perfil || {};
  const fila = state.perfiles.find((x) => x.id === p.id);
  return {
    p,
    foto: fila?.foto || p.foto || null,
    nombre: fila?.nombre || p.nombre || "",
    telefono: fila?.telefono || p.telefono || "",
    correo: fila?.correo_contacto || p.correoContacto || "",
  };
}

export function render() {
  const { p, foto, nombre, telefono, correo } = datos();
  const sede = state.sucursales.find((s) => Number(s.activo) === 1)?.nombre || "Sucursal principal";
  const iniciales = (p.nombre || "LS").slice(0, 2).toUpperCase();
  const pinTexto = (p.pinObligatorio || p.debeCambiarClave) ? "Pendiente de definir" : "Definido (privado)";

  let con;
  if (!navigator.onLine) con = { t: "Sin conexión a Internet", c: "bg-red-400" };
  else if (estadoRealtime) con = { t: "En línea · Supabase Realtime activo", c: "bg-emerald-400" };
  else con = { t: "Conectando…", c: "bg-amber-400" };

  return `
  <div class="space-y-4 md:space-y-6 fade">
    <section class="rounded-2xl bg-gradient-to-br from-[#1e3c72] to-[#2a5298] p-5 text-white shadow-md">
      <div class="flex items-start gap-4">
        <div class="relative shrink-0">
          <div class="w-20 h-20 rounded-full border-2 border-white/40 bg-white/20 grid place-items-center overflow-hidden">
            ${foto ? `<img src="${esc(foto)}" alt="Foto de perfil" class="w-full h-full object-cover" />` : `<span class="text-2xl font-bold">${esc(iniciales)}</span>`}
          </div>
          <button data-accion="foto"
            class="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-white text-[#1e3c72] grid place-items-center shadow-lg border border-slate-200 active:scale-95"
            aria-label="Cambiar foto">📷</button>
          <input type="file" id="fotoInput" accept="image/*" class="hidden" />
        </div>
        <div class="min-w-0 grow">
          <div class="text-lg md:text-xl font-bold leading-tight truncate">${esc(nombre || "—")}</div>
          <div class="mt-1.5 inline-block px-2.5 py-0.5 rounded-full bg-white/15 text-[11px] font-semibold">${esc(p.rol || "Empleado")}</div>
        </div>
        <button data-accion="editar"
          class="shrink-0 flex items-center gap-1.5 px-3 py-2 rounded-lg bg-white/15 hover:bg-white/25 text-xs font-semibold active:scale-[0.98]">
          ✏️ Editar datos
        </button>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 md:p-5 shadow-sm">
      <h2 class="text-[11px] uppercase tracking-wide text-slate-400 font-semibold mb-3">Información personal</h2>
      <div class="space-y-2.5 text-sm">
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Nombre</span><b class="text-right truncate">${esc(nombre || "—")}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Teléfono</span><b class="text-right truncate">${esc(telefono || "—")}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Correo de contacto</span><b class="text-right truncate">${esc(correo || "—")}</b></div>
        <div class="flex justify-between gap-3">
          <span class="text-slate-500 shrink-0">Correo de acceso<br /><span class="text-[10px] text-slate-400">identidad de inicio de sesión</span></span>
          <b class="text-right truncate">${esc(p.email || p.correoCuenta || "—")}</b>
        </div>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 md:p-5 shadow-sm">
      <h2 class="text-[11px] uppercase tracking-wide text-slate-400 font-semibold mb-3">Cuenta y seguridad</h2>
      <div class="space-y-2.5 text-sm">
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Usuario</span><b class="text-right">${esc(p.usuario || "—")}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Rol</span><b class="text-right">${esc(p.rol || "Empleado")}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">PIN asignado</span><b class="text-right">${esc(pinTexto)}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Sede</span><b class="text-right">${esc(sede)} · sede única</b></div>
      </div>
      <button data-accion="pin"
        class="mt-4 w-full flex items-center justify-center gap-2 px-4 py-3.5 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition active:scale-[0.98]">
        🔑 Cambiar PIN / Contraseña
      </button>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 md:p-5 shadow-sm">
      <h2 class="text-[11px] uppercase tracking-wide text-slate-400 font-semibold mb-3">Información del sistema</h2>
      <div class="space-y-2.5 text-sm">
        <div class="flex items-center justify-between gap-3">
          <span class="text-slate-500 shrink-0">Conexión</span>
          <span class="flex items-center gap-2 text-right">
            <span class="w-2.5 h-2.5 rounded-full ${con.c} shrink-0"></span>
            <b>${esc(con.t)}</b>
          </span>
        </div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Versión</span><b class="text-right">${VERSION} · Librería San Martín</b></div>
      </div>
    </section>

    <button data-accion="salir"
      class="w-full flex items-center justify-center gap-2 px-4 py-4 rounded-2xl bg-rose-600 hover:bg-rose-700 text-white font-bold shadow-sm transition active:scale-[0.98]">
      Cerrar sesión
    </button>
  </div>`;
}

function redimensionarFoto(archivo, max = 360) {
  return new Promise((resolve, reject) => {
    const lector = new FileReader();
    lector.onload = () => {
      const img = new Image();
      img.onload = () => {
        const escala = Math.min(1, max / Math.max(img.width, img.height || 1));
        const c = document.createElement("canvas");
        c.width = Math.max(1, Math.round(img.width * escala));
        c.height = Math.max(1, Math.round(img.height * escala));
        c.getContext("2d").drawImage(img, 0, 0, c.width, c.height);
        resolve(c.toDataURL("image/jpeg", 0.82));
      };
      img.onerror = reject;
      img.src = lector.result;
    };
    lector.onerror = reject;
    lector.readAsDataURL(archivo);
  });
}

async function renovarPerfil() {
  const nuevo = await perfilActual();
  if (nuevo && _ctx) {
    Object.assign(_ctx.perfil, nuevo);
    const fila = state.perfiles.find((x) => x.id === nuevo.id);
    if (fila) Object.assign(fila, {
      nombre: nuevo.nombre, foto: nuevo.foto,
      telefono: nuevo.telefono, correo_contacto: nuevo.correoContacto,
    });
    if ($("#nombreUsuario")) $("#nombreUsuario").textContent = nuevo.nombre || nuevo.usuario;
    if ($("#rolUsuario")) $("#rolUsuario").textContent = nuevo.rol;
    const av = $("#avatar");
    if (av) {
      av.style.overflow = "hidden";
      av.innerHTML = nuevo.foto
        ? `<img src="${esc(nuevo.foto)}" alt="" class="w-full h-full object-cover" />`
        : (nuevo.nombre || "LS").slice(0, 2).toUpperCase();
    }
  }
  _ctx?.rerender();
}

async function guardarFotoDatos(patch) {
  const { p } = datos();
  const actualizado = await repo.actualizarPerfil(p.id, patch);
  await _ctx?.recargar();
  await renovarPerfil();
  return actualizado;
}

function modalEditarDatos() {
  const { nombre, telefono, correo } = datos();
  const wrap = document.createElement("div");
  wrap.className = "fixed inset-0 z-[1000] bg-slate-900/80 backdrop-blur-sm flex items-end md:items-center justify-center p-0 md:p-4";
  wrap.innerHTML = `
    <form class="bg-white w-full max-w-md md:rounded-2xl rounded-t-2xl shadow-2xl fade">
      <div class="px-6 pt-6 pb-2 border-b border-slate-100">
        <h2 class="text-lg font-bold text-[#1e3c72]">Editar datos</h2>
        <p class="text-xs text-slate-500 mt-0.5">Tu nombre, teléfono y correo de contacto. El correo de acceso no se modifica.</p>
      </div>
      <div class="px-6 py-5 space-y-4">
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Nombre</span>
          <input id="dNombre" type="text" value="${esc(nombre)}" required autocomplete="name"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Teléfono</span>
          <input id="dTelefono" type="tel" value="${esc(telefono)}" autocomplete="tel"
            placeholder="Ej.: 71234567"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Correo de contacto</span>
          <input id="dCorreo" type="email" value="${esc(correo)}" autocomplete="email"
            placeholder="correo@ejemplo.com"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <p id="editErr" class="hidden text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2"></p>
        <button class="w-full py-3 rounded-lg bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition">Guardar cambios</button>
        <button type="button" id="cancelarEdit" class="w-full py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 text-sm font-semibold transition">Cancelar</button>
      </div>
    </form>`;
  document.body.appendChild(wrap);
  wrap.querySelector("#cancelarEdit").onclick = () => wrap.remove();
  wrap.addEventListener("click", (e) => { if (e.target === wrap) wrap.remove(); });
  wrap.querySelector("form").addEventListener("submit", async (e) => {
    e.preventDefault();
    const err = wrap.querySelector("#editErr");
    err.classList.add("hidden");
    const nombreV = wrap.querySelector("#dNombre").value.trim();
    const telefonoV = wrap.querySelector("#dTelefono").value.trim();
    const correoV = wrap.querySelector("#dCorreo").value.trim();
    if (!nombreV) { err.textContent = "El nombre no puede estar vacío"; return err.classList.remove("hidden"); }
    const btn = wrap.querySelector("form button");
    btn.disabled = true;
    btn.textContent = "Guardando…";
    try {
      const { p } = datos();
      await guardarFotoDatos({ nombre: nombreV, telefono: telefonoV || null, correo_contacto: correoV || null });
      if (_ctx?.perfil?.esAdmin && p.usuarioId) {
        try { await repo.actualizarUsuario(p.usuarioId, { nombre: nombreV }, p.usuarioId); } catch (e) { console.warn("[LSM] usuarios.nombre (admin)", e); }
      }
      wrap.remove();
      toast("Datos actualizados");
    } catch (ex) {
      err.textContent = ex.message;
      err.classList.remove("hidden");
    } finally {
      btn.disabled = false;
      btn.textContent = "Guardar cambios";
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
        <h2 class="mt-2 text-lg font-bold text-[#1e3c72]">Cambiar PIN</h2>
        <p class="text-xs text-slate-500 mt-1">Elige un PIN nuevo para tu cuenta.</p>
      </div>
      <form id="formPinPerfil" class="px-6 py-5 space-y-4">
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">PIN nuevo</span>
          <input id="clave1" type="password" required autocomplete="new-password" inputmode="numeric"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Repite el PIN</span>
          <input id="clave2" type="password" required autocomplete="new-password" inputmode="numeric"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg outline-none focus:ring-2 focus:ring-[#2a5298]" />
        </label>
        <p class="text-[11px] text-slate-500 bg-slate-50 border border-slate-200 rounded-lg px-3 py-2">
          Entre 4 y 12 caracteres. Evita <code>12345</code> y PINs fáciles de adivinar.
        </p>
        <p id="pinErr" class="hidden text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2"></p>
        <button class="w-full py-3 rounded-lg bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition">Guardar PIN</button>
        <button type="button" id="cancelarPin" class="w-full py-2 rounded-lg bg-slate-100 hover:bg-slate-200 text-slate-600 text-sm font-semibold transition">Cancelar</button>
      </form>
    </div>`;
  document.body.appendChild(wrap);
  wrap.querySelector("#cancelarPin").onclick = () => wrap.remove();
  wrap.addEventListener("click", (e) => { if (e.target === wrap) wrap.remove(); });
  wrap.querySelector("#formPinPerfil").addEventListener("submit", async (e) => {
    e.preventDefault();
    const err = wrap.querySelector("#pinErr");
    err.classList.add("hidden");
    const a = wrap.querySelector("#clave1").value;
    const b = wrap.querySelector("#clave2").value;
    if (a.length < 4 || a.length > 12) {
      err.textContent = "El PIN debe tener entre 4 y 12 caracteres";
      return err.classList.remove("hidden");
    }
    if (a !== b) {
      err.textContent = "Los PIN no coinciden";
      return err.classList.remove("hidden");
    }
    if (/^(1234|12345|123456|0000|password|clave123|admin|abc123)$/i.test(a)) {
      err.textContent = "Ese PIN es demasiado fácil. Elige otro.";
      return err.classList.remove("hidden");
    }
    const btn = wrap.querySelector("#formPinPerfil button");
    btn.disabled = true;
    btn.textContent = "Guardando…";
    try {
      await cambiarClave(a);
      if (_ctx?.perfil) {
        _ctx.perfil.pinObligatorio = false;
        _ctx.perfil.debeCambiarClave = false;
      }
      wrap.remove();
      _ctx?.rerender();
      toast("PIN actualizado");
    } catch (ex) {
      err.textContent = ex.message;
      err.classList.remove("hidden");
    } finally {
      btn.disabled = false;
      btn.textContent = "Guardar PIN";
    }
  });
}

async function cerrarSesion() {
  try { await signOut(); } catch (e) { console.warn("[LSM] signOut", e); }
  location.reload();
}

let _ctx = null;

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", (e) => {
    const b = e.target.closest("[data-accion]");
    if (!b) return;
    if (b.dataset.accion === "pin") modalCambiarPin();
    if (b.dataset.accion === "salir") cerrarSesion();
    if (b.dataset.accion === "editar") modalEditarDatos();
    if (b.dataset.accion === "foto") {
      const fi = $("#fotoInput", root);
      if (fi) fi.click();
    }
  });
  root.addEventListener("change", async (e) => {
    if (e.target.id !== "fotoInput") return;
    const archivo = e.target.files?.[0];
    if (!archivo) return;
    if (!archivo.type.startsWith("image/")) return toast("Selecciona una imagen", "warn");
    const btn = $("#btnFoto", root);
    if (btn) btn.textContent = "⏳";
    try {
      const foto = await redimensionarFoto(archivo);
      await guardarFotoDatos({ foto });
      toast("Foto de perfil actualizada");
    } catch (ex) {
      toast(ex.message, "error");
    }
  });
}