/* =====================================================================
   NÚCLEO DE LA APLICACIÓN (compartido por escritorio y móvil)
   - una sola sesión Supabase
   - un solo login
   - un solo registro de vistas
   - una sola carga de datos + Realtime
   ===================================================================== */
import { sb, signIn, signOut, perfilActual, onAuthChange, hace, cambiarClave } from "./supabase-client.js";
import { cargarTodo, conectarRealtime, state } from "./data.js";
import { $, esc, toast } from "./ui.js";

import * as dashboard from "./views/dashboard.js";
import * as ventas from "./views/ventas.js";
import * as inventario from "./views/inventario.js";
import * as compras from "./views/compras.js";
import * as clientes from "./views/clientes.js";
import * as usuarios from "./views/usuarios.js";
import * as reportes from "./views/reportes.js";
import * as auditoria from "./views/auditoria.js";

export const MODULOS = [dashboard, ventas, inventario, compras, clientes, usuarios, reportes, auditoria];

const ORDEN = ["dashboard", "ventas", "inventario", "compras", "clientes", "usuarios", "reportes", "auditoria"];

const BOTONES_MOVIL = [
  { id: "dashboard", icono: "🏠", t: "Inicio" },
  { id: "ventas", icono: "🛒", t: "Venta", params: { tab: "pos" } },
  { id: "inventario", icono: "📦", t: "Inventario" },
  { id: "ventas", icono: "💵", t: "Caja", params: { tab: "caja" } },
];

export const app = {
  modo: "desktop",
  perfil: null,
  vista: "dashboard",
  params: null,
  mounted: new Set(),
};

/* ---------------- login ---------------- */
export function pintarLogin() {
  const el = $("#login");
  if (!el) return;
  el.classList.remove("hidden");
  el.innerHTML = `
  <div class="w-full max-w-md p-6">
    <div class="bg-white rounded-2xl shadow-2xl p-8 fade">
      <div class="text-center mb-6">
        <div class="text-5xl">📚</div>
        <h1 class="mt-3 text-2xl font-bold text-[#1e3c72]">Librería San Martín</h1>
        <p class="text-sm text-slate-500">${app.modo === "movil" ? "Aplicación móvil" : "Panel de administración"}</p>
      </div>
      <form id="formLogin" class="space-y-4">
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Usuario</span>
          <input id="usuario" type="text" required autocomplete="username" autofocus
            placeholder="Ej.: Gustavo" autocapitalize="none" spellcheck="false"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#2a5298] outline-none" />
        </label>
        <label class="block">
          <span class="block text-xs font-semibold text-slate-500 mb-1">Contraseña</span>
          <input id="password" type="password" required autocomplete="current-password"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#2a5298] outline-none" />
        </label>
        <p id="loginError" class="hidden text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2"></p>
        <button class="w-full py-3 rounded-lg bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition">Ingresar</button>
      </form>
    </div>
  </div>`;
  $("#formLogin").addEventListener("submit", async (e) => {
    e.preventDefault();
    const err = $("#loginError");
    err.classList.add("hidden");
    const btn = $("#formLogin button");
    btn.disabled = true;
    btn.textContent = "Ingresando…";
    try {
      await signIn($("#usuario").value.trim(), $("#password").value);
      await arrancar();
    } catch (ex) {
      err.textContent = ex.message;
      err.classList.remove("hidden");
    } finally {
      btn.disabled = false;
      btn.textContent = "Ingresar";
    }
  });
}

/* ---------- cambio de clave obligatorio en el primer ingreso ---------- */
function exigirCambioClave(perfil) {
  return new Promise((resolve) => {
    const wrap = document.createElement("div");
    wrap.className = "fixed inset-0 z-[1000] bg-slate-900/80 backdrop-blur-sm flex items-center justify-center p-4";
    wrap.innerHTML = `
      <div class="bg-white w-full max-w-md rounded-2xl shadow-2xl fade">
        <div class="px-6 pt-6 pb-2 text-center border-b border-slate-100">
          <div class="text-3xl">🔑</div>
            <h2 class="mt-2 text-lg font-bold text-[#1e3c72]">Define tu PIN</h2>
            <p class="text-xs text-slate-500 mt-1">
              Hola <b>${esc(perfil.nombre || perfil.usuario)}</b>. Es tu primer ingreso,
              así que debes crear un PIN propio antes de usar el sistema.
            </p>
        </div>
        <form id="formClave" class="px-6 py-5 space-y-4">
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
          <p id="claveError" class="hidden text-sm text-red-600 bg-red-50 border border-red-200 rounded-lg px-3 py-2"></p>
          <button class="w-full py-3 rounded-lg bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition">
            Guardar PIN
          </button>
          <button type="button" id="salirCambio"
            class="w-full text-xs text-slate-500 hover:text-slate-700 py-1">
            Cerrar sesión
          </button>
        </form>
      </div>`;
    document.body.appendChild(wrap);
    wrap.querySelector("#salirCambio").onclick = async () => {
      await signOut();
      location.reload();
    };
    wrap.querySelector("#formClave").addEventListener("submit", async (e) => {
      e.preventDefault();
      const err = wrap.querySelector("#claveError");
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
      const btn = wrap.querySelector("#formClave button");
      btn.disabled = true;
      btn.textContent = "Guardando…";
      try {
        await cambiarClave(a);
        if (app.perfil) {
          app.perfil.debeCambiarClave = false;
          app.perfil.pinObligatorio = false;
        }
        wrap.remove();
        toast("PIN actualizado");
        resolve();
      } catch (ex) {
        err.textContent = ex.message;
        err.classList.remove("hidden");
      } finally {
        btn.disabled = false;
        btn.textContent = "Guardar PIN";
      }
    });
  });
}

async function pintarShell() {
  const app_ = $("#app");
  app_.classList.remove("hidden");
  $("#login").classList.add("hidden");

  if (app.modo === "desktop") {
    $("#nav").innerHTML = ORDEN.map((id) => {
      const m = mod(id);
      return `<a href="#${id}" data-nav="${id}" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm ${id === app.vista ? "bg-white/15 font-semibold" : "hover:bg-white/10"}">
        <span class="text-base">${m.icono}</span>${m.titulo}</a>`;
    }).join("");
  } else {
    $("#navInferior").innerHTML = BOTONES_MOVIL.map((b, i) => `
      <button data-movil="${i}" class="flex-1 flex flex-col items-center gap-0.5 py-2 text-[10px] font-semibold ${i === navMovilActiva() ? "text-[#2a5298]" : "text-slate-400"}">
        <span class="text-xl leading-none">${b.icono}</span>${b.t}
      </button>`).join("");
    $("#drawer").innerHTML = ORDEN.filter((id) => !["dashboard", "inventario"].includes(id)).map((id) => {
      const m = mod(id);
      return `<button data-ir="${id}" class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-slate-50 text-left">
        <span class="text-lg">${m.icono}</span><span class="text-sm">${m.titulo}</span></button>`;
    }).join("");
  }

  const p = app.perfil;
  if ($("#nombreUsuario")) $("#nombreUsuario").textContent = p.nombre || p.email;
  if ($("#rolUsuario")) $("#rolUsuario").textContent = p.rol;
  if ($("#avatar")) $("#avatar").textContent = (p.nombre || "LS").slice(0, 2).toUpperCase();
}

function navMovilActiva() {
  const i = BOTONES_MOVIL.findIndex((b) => b.id === app.vista &&
    (!b.params || (app.params && app.params.tab === b.params.tab)));
  if (i >= 0) return i;
  return BOTONES_MOVIL.findIndex((b) => b.id === app.vista);
}
function mod(id) {
  return MODULOS.find((m) => m.meta.id === id);
}

/* ---------------- arranque ---------------- */
export async function iniciar(modo) {
  app.modo = modo;
  pintarLogin();
  onAuthChange(async (evento, session) => {
    /* Solo un cierre de sesión real limpia el estado. Durante un refresh de
       token o un cambio de contraseña Supabase emite eventos con sesión
       vacía; si se limpiara el perfil, la app se caería a mitad de sesión. */
    if (evento === "SIGNED_OUT" || (!session && !app.perfil)) {
      app.perfil = null;
      $("#app").classList.add("hidden");
      pintarLogin();
    }
  });
  const perfil = await perfilActual();
  if (perfil) await arrancar();
}

async function arrancar() {
  app.perfil = await perfilActual();
  if (!app.perfil) return pintarLogin();
  await pintarShell();
  if (app.perfil.debeCambiarClave) await exigirCambioClave(app.perfil);
  await recargar();
  conectarRealtime((tabla, payload) => {
    if (tabla === "estado") {
      setRT(payload === "SUBSCRIBED" ? "ok" : "off");
      return;
    }
    programarRecarga();
  });
  const inicial = parseHash();
  ir(inicial.id, true, inicial.params);
  window.addEventListener("hashchange", () => {
    const h = parseHash();
    ir(h.id, true, h.params);
  });
}

/* #vista o #vista/subvista -> { id, params } */
function parseHash() {
  const bruto = location.hash.replace(/^#/, "");
  const [id, sub] = bruto.split("/");
  if (!ORDEN.includes(id)) return { id: "dashboard", params: null };
  return { id, params: sub ? { tab: sub } : null };
}

/* ---------------- datos ---------------- */
export async function recargar() {
  const t = $("#cargando");
  if (t) t.classList.remove("hidden");
  await cargarTodo();
  if (t) t.classList.add("hidden");
  const u = $("#ultimaCarga");
  if (u) u.textContent = state.ultimaCarga ? hace(state.ultimaCarga) : "—";
  pintarShellNav();
  if (app.vista) dibujar(app.vista);
  if (state.errores.length) console.warn("carga con errores:", state.errores);
}

let timer;
function programarRecarga() {
  clearTimeout(timer);
  timer = setTimeout(() => { recargar(); }, 700);
}

function setRT(estado) {
  const d = $("#dotRT"), t = $("#txtRT");
  if (!d) return;
  d.className = `w-2 h-2 rounded-full ${estado === "ok" ? "bg-emerald-400" : "bg-amber-400"}`;
  if (t) t.textContent = estado === "ok" ? "Realtime activo" : "Realtime conectando…";
}

/* ---------------- navegación ---------------- */
export function ir(id, delHash = false, params = null) {
  const m = mod(id);
  if (!m) id = "dashboard";
  if (params && m.abrir) m.abrir(params);
  if (delHash) {
    const destino = "#" + id + (params?.tab ? "/" + params.tab : "");
    if (location.hash !== destino) history.replaceState(null, "", destino);
  }
  app.vista = id;
  app.params = params;
  const cont = $("#vista");
  if (cont) {
    cont.scrollTop = 0;
    if (!app.mounted.has(id)) {
      app.mounted.add(id);
      m.mount(cont, ctx());
    }
    dibujar(id);
  }
  pintarShellNav();
}

function ctx() {
  return {
    perfil: app.perfil,
    modo: app.modo,
    ir: (id, params) => ir(id, true, params),
    rerender: () => dibujar(app.vista),
    recargar: () => recargar(),
  };
}

function dibujar(id) {
  const m = mod(id) || mod("dashboard");
  const cont = $("#vista");
  if (!cont) return;
  const html = m.render();
  if (cont.dataset.actual === id && m.renderIncremental) m.renderIncremental(cont, html);
  else cont.innerHTML = html;
  cont.dataset.actual = id;
  if ($("#titulo")) $("#titulo").textContent = m.meta.titulo;
  if ($("#subtitulo")) $("#subtitulo").textContent = subtitulo(m.meta.id);
  document.title = `${m.meta.titulo} · Librería San Martín`;
}

const SUBT = {
  dashboard: "Resumen general de la librería",
  ventas: "Punto de venta, caja, flujo, devoluciones y ajustes",
  inventario: "Productos, stock, movimientos y categorías",
  compras: "Compras, proveedores y ranking",
  clientes: "CRM, historial y clientes frecuentes",
  usuarios: "Usuarios, roles y sucursales",
  reportes: "Indicadores, ventas vs compras y rotación",
  auditoria: "Consolido de los 8 registros de auditoría",
};
function subtitulo(id) { return SUBT[id] || ""; }

function pintarShellNav() {
  document.querySelectorAll("[data-nav]").forEach((a) => {
    const on = a.dataset.nav === app.vista;
    a.className = `nav-item flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm ${on ? "bg-white/15 font-semibold" : "hover:bg-white/10"}`;
  });
  document.querySelectorAll("[data-movil]").forEach((b, i) => {
    const on = i === navMovilActiva();
    b.className = `flex-1 flex flex-col items-center gap-0.5 py-2 text-[10px] font-semibold ${on ? "text-[#2a5298]" : "text-slate-400"}`;
  });
}

/* ---------------- eventos globales ---------------- */
export function cablearGlobal() {
  document.addEventListener("click", async (e) => {
    if (e.target.closest("#btnSalir")) {
      await signOut();
      location.reload();
      return;
    }
    const m = e.target.closest("[data-movil]");
    if (m) {
      const b = BOTONES_MOVIL[+m.dataset.movil];
      ir(b.id, true, b.params);
      return;
    }
    const irA = e.target.closest("[data-ir]");
    if (irA) {
      cerrarDrawer();
      ir(irA.dataset.ir, true);
      return;
    }
    if (e.target.closest("#btnMenu")) {
      abrirDrawer();
      return;
    }
    if (e.target.closest("#btnCerrarDrawer") || e.target.closest("[data-cerrar]")) return cerrarDrawer();
  });
  document.addEventListener("keydown", (e) => {
    if (e.key === "Escape") cerrarDrawer();
  });
}

function abrirDrawer() {
  const c = $("#cajon");
  if (!c) return;
  c.classList.remove("invisible", "opacity-0");
  c.classList.add("visible", "opacity-100");
  c.querySelector("aside")?.classList.remove("-translate-x-full");
}

function cerrarDrawer() {
  const c = $("#cajon");
  if (!c) return;
  c.querySelector("aside")?.classList.add("-translate-x-full");
  c.classList.add("invisible", "opacity-0");
  c.classList.remove("visible", "opacity-100");
}

/* ---------------- PWA ---------------- */
export function registrarSW() {
  if (!("serviceWorker" in navigator)) return;
  if (location.protocol === "file:") return;
  navigator.serviceWorker.register("/sw.js").catch((e) => console.warn("SW no registrado", e));
}

export { toast, $, esc, sb };