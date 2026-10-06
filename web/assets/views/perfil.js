import { esc, toast } from "../ui.js";
import { cambiarClave, signOut } from "../supabase-client.js";
import { estadoRealtime, state } from "../data.js";

export const meta = { id: "perfil", titulo: "Mi Perfil", icono: "👤", grupo: "Cuenta" };

export const VERSION = "v1.2";

export function render() {
  const p = _ctx?.perfil || {};
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
      <div class="flex items-center gap-4">
        <div class="w-16 h-16 rounded-full bg-white/20 grid place-items-center text-2xl font-bold shrink-0">${esc(iniciales)}</div>
        <div class="min-w-0">
          <div class="text-lg md:text-xl font-bold leading-tight truncate">${esc(p.nombre || "—")}</div>
          <div class="mt-1.5 inline-block px-2.5 py-0.5 rounded-full bg-white/15 text-[11px] font-semibold">${esc(p.rol || "Empleado")}</div>
        </div>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
      <h2 class="text-[11px] uppercase tracking-wide text-slate-400 font-semibold mb-2">Información del usuario</h2>
      <div class="space-y-2.5 text-sm">
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Usuario</span><b class="text-right">${esc(p.usuario || "—")}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Correo</span><b class="truncate text-right">${esc(p.email || "—")}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">PIN asignado</span><b class="text-right">${esc(pinTexto)}</b></div>
        <div class="flex justify-between gap-3"><span class="text-slate-500 shrink-0">Sede</span><b class="text-right">${esc(sede)} · sede única</b></div>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
      <h2 class="text-[11px] uppercase tracking-wide text-slate-400 font-semibold mb-2">Acciones rápidas</h2>
      <div class="space-y-2">
        <button data-accion="pin"
          class="w-full flex items-center justify-center gap-2 px-4 py-3.5 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition active:scale-[0.98]">
          🔑 Cambiar PIN / Contraseña
        </button>
        <button data-accion="salir"
          class="w-full flex items-center justify-center gap-2 px-4 py-3.5 rounded-xl bg-rose-600 hover:bg-rose-700 text-white font-semibold transition active:scale-[0.98]">
          Salir de la sesión
        </button>
      </div>
    </section>

    <section class="bg-white rounded-2xl border border-slate-200 p-4 shadow-sm">
      <h2 class="text-[11px] uppercase tracking-wide text-slate-400 font-semibold mb-2">Información del sistema</h2>
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
  </div>`;
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
      wrap.remove();
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
  });
}