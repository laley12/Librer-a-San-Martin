/* =====================================================================
   NÚCLEO DE LA APLICACIÓN (compartido por escritorio y móvil)
   - una sola sesión Supabase
   - un solo login
   - un solo registro de vistas
   - una sola carga de datos + Realtime
   ===================================================================== */
console.log('[LSM] app.js module loaded');
import { sb, signIn, signOut, perfilActual, onAuthChange, hace } from "./supabase-client.js";
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
import * as perfil from "./views/perfil.js";

export const MODULOS = [dashboard, ventas, inventario, compras, clientes, usuarios, reportes, auditoria, perfil];

const ORDEN = ["dashboard", "ventas", "inventario", "compras", "clientes", "usuarios", "reportes", "auditoria", "perfil"];

const BOTONES_MOVIL = [
  { id: "dashboard", icono: "🏠", t: "Inicio" },
  { id: "ventas", icono: "🛒", t: "Venta", params: { tab: "pos" } },
  { id: "inventario", icono: "📦", t: "Productos" },
  { id: "ventas", icono: "💵", t: "Caja", params: { tab: "caja" } },
  { id: "perfil", icono: "👤", t: "Perfil" },
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
  console.log('[LSM] pintarLogin called');
  const el = $("#login");
  if (!el) { console.error('[LSM] #login element not found'); return; }
  console.log('[LSM] #login element found, removing hidden class');
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
  console.log('[LSM] Login form HTML injected');
  $("#formLogin").addEventListener("submit", async (e) => {
    e.preventDefault();
    const err = $("#loginError");
    err.classList.add("hidden");
    const btn = $("#formLogin button");
    btn.disabled = true;
    btn.textContent = "Ingresando…";
    try {
      console.log('[LSM] Attempting signIn');
      await signIn($("#usuario").value.trim(), $("#password").value);
      console.log('[LSM] signIn success, calling arrancar');
      await arrancar();
    } catch (ex) {
      console.error('[LSM] signIn error:', ex);
      err.textContent = ex.message;
      err.classList.remove("hidden");
    } finally {
      btn.disabled = false;
      btn.textContent = "Ingresar";
    }
  });
}

/* ---------- cambio de clave obligatorio NO se aplica: el primer ingreso
   entra directo al Dashboard (la creación de PIN es opcional desde Mi Perfil) ---------- */

async function pintarShell() {
  const app_ = $("#app");
  app_.classList.remove("hidden");
  $("#login").classList.add("hidden");

  if (app.modo === "desktop") {
    $("#nav").innerHTML = ORDEN.map((id) => {
      const m = mod(id);
      return `<a href="#${id}" data-nav="${id}" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm ${id === app.vista ? "bg-white/15 font-semibold" : "hover:bg-white/10"}">
        <span class="text-base">${m.meta.icono}</span>${m.meta.titulo}</a>`;
    }).join("");
  } else {
    $("#navInferior").innerHTML = BOTONES_MOVIL.map((b, i) => `
      <button data-movil="${i}" class="flex-1 flex flex-col items-center gap-0.5 py-2 text-[10px] font-semibold ${i === navMovilActiva() ? "text-[#2a5298]" : "text-slate-400"}">
        <span class="text-xl leading-none">${b.icono}</span>${b.t}
      </button>`).join("");
    $("#drawer").innerHTML = ORDEN.filter((id) => !["dashboard", "inventario"].includes(id)).map((id) => {
      const m = mod(id);
      const esPerfil = id === "perfil";
      return `${esPerfil ? `<div class="pt-2 mt-2 border-t border-slate-100"></div>` : ""}
      <button data-ir="${id}" class="w-full flex items-center gap-3 px-4 py-3 rounded-xl hover:bg-slate-50 text-left">
        <span class="text-lg">${m.meta.icono}</span><span class="text-sm">${m.meta.titulo}</span></button>`;
    }).join("");
  }

  const p = app.perfil;
  if ($("#nombreUsuario")) $("#nombreUsuario").textContent = p.nombre || p.usuario || p.email;
  if ($("#rolUsuario")) $("#rolUsuario").textContent = p.rol;
  const av = $("#avatar");
  if (av) {
    av.style.overflow = "hidden";
    av.innerHTML = p.foto
      ? `<img src="${esc(p.foto)}" alt="" class="w-full h-full object-cover" />`
      : (p.nombre || "LS").slice(0, 2).toUpperCase();
  }
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
  console.log('[LSM] iniciar called with modo:', modo);
  app.modo = modo;
  pintarLogin();
  onAuthChange(async (evento, session) => {
    console.log('[LSM] onAuthChange event:', evento, session ? 'session exists' : 'no session');
    if (evento === "SIGNED_OUT" || (!session && !app.perfil)) {
      app.perfil = null;
      $("#app").classList.add("hidden");
      pintarLogin();
    }
  });
  console.log('[LSM] Calling perfilActual');
  const perfil = await perfilActual();
  console.log('[LSM] perfilActual returned:', perfil);
  if (perfil) {
    console.log('[LSM] Perfil exists, calling arrancar');
    await arrancar();
  } else {
    console.log('[LSM] No perfil, staying on login');
  }
}

async function arrancar() {
  console.log('[LSM] arrancar started');
  app.perfil = await perfilActual();
  console.log('[LSM] arrancar - perfilActual:', app.perfil);
  if (!app.perfil) { console.log('[LSM] arrancar - no perfil, returning to login'); return pintarLogin(); }
  console.log('[LSM] Calling pintarShell');
  await pintarShell();
  console.log('[LSM] pintarShell done');
  console.log('[LSM] Calling recargar');
  await recargar();
  console.log('[LSM] recargar done');
  conectarRealtime((tabla, payload) => {
    if (tabla === "estado") {
      setRT(payload === "SUBSCRIBED" ? "ok" : "off");
      return;
    }
    programarRecarga();
  });
  const inicial = parseHash();
  console.log('[LSM] Initial hash parse:', inicial);
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

/* data-params='{"tab":"caja"}' -> { tab: "caja" }  (nunca rompe la navegación) */
function paramsDe(el) {
  const bruto = el.dataset.params;
  if (!bruto) return null;
  try { return JSON.parse(bruto); } catch { return null; }
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
  usuarios: "Usuarios, roles y permisos",
  reportes: "Indicadores, ventas vs compras y rotación",
  auditoria: "Consolido de los 8 registros de auditoría",
  perfil: "Tu cuenta, PIN, sesión y versión del sistema",
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
      ir(irA.dataset.ir, true, paramsDe(irA));
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