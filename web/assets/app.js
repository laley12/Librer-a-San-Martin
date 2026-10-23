/* =====================================================================
   NÚCLEO DE LA APLICACIÓN (compartido por escritorio y móvil)
   - una sola sesión Supabase
   - un solo login
   - un solo registro de vistas
   - una sola carga de datos + Realtime
   ===================================================================== */
console.log('[LSM] app.js module loaded');
import { sb, signIn, signOut, perfilActual, onAuthChange, hace } from "./supabase-client.js";
import { cargarTodo, conectarRealtime, conectarPresencia, state } from "./data.js";
import { $, esc, toast } from "./ui.js";

import * as dashboard from "./views/dashboard.js";
import * as ventas from "./views/ventas.js";
import * as inventario from "./views/inventario.js";
import * as compras from "./views/compras.js";
import * as usuarios from "./views/usuarios.js";
import * as reportes from "./views/reportes.js";
import * as perfil from "./views/perfil.js";
import * as visor3d from "./views/visor3d.js";

export const MODULOS = [dashboard, ventas, inventario, visor3d, compras, usuarios, reportes, perfil];

const ORDEN = ["dashboard", "ventas", "inventario", "visor3d", "compras", "usuarios", "reportes", "perfil"];

const BOTONES_MOVIL = [
  { id: "dashboard", icono: "🏠", t: "Inicio" },
  { id: "ventas", icono: "🛒", t: "Venta", params: { tab: "pos" } },
  { id: "inventario", icono: "📦", t: "Productos" },
  { id: "perfil", icono: "👤", t: "Perfil" },
];

export const app = {
  modo: "desktop",
  perfil: null,
  vista: "dashboard",
  params: null,
  mounted: new Set(),
};

/* ---------------- confeti y bienvenida ---------------- */
export function lanzarConfeti() {
  const c = window.confetti || (typeof confetti === "function" ? confetti : null);
  if (c) {
    c({ particleCount: 90, spread: 70, origin: { y: 0.6 } });
    setTimeout(() => {
      c({ particleCount: 45, angle: 60, spread: 55, origin: { x: 0.1, y: 0.7 } });
      c({ particleCount: 45, angle: 120, spread: 55, origin: { x: 0.9, y: 0.7 } });
    }, 280);
  }
}

export function mostrarModalBienvenida(p) {
  if (!p) return;
  const antiguo = $("#modalBienvenida");
  if (antiguo) antiguo.remove();

  const iniciales = (p.nombre || p.usuario || "LS").slice(0, 2).toUpperCase();
  const wrap = document.createElement("div");
  wrap.id = "modalBienvenida";
  wrap.className = "fixed inset-0 z-[1000] bg-slate-900/60 backdrop-blur-sm flex items-center justify-center p-4 transition-opacity duration-300";
  wrap.innerHTML = `
    <div class="bg-white w-full max-w-sm rounded-3xl shadow-2xl p-6 text-center border border-slate-100 transform transition-all duration-300 scale-95 opacity-0" id="cajaBienvenida">
      <div class="relative inline-block mb-3">
        ${p.foto
          ? `<img src="${esc(p.foto)}" alt="" class="w-24 h-24 rounded-full object-cover shadow-xl border-4 border-white ring-4 ring-blue-500/20 mx-auto" />`
          : `<div class="w-24 h-24 rounded-full bg-gradient-to-tr from-[#1e3c72] to-[#2a5298] text-white text-3xl font-bold grid place-items-center shadow-xl border-4 border-white ring-4 ring-blue-500/20 mx-auto">
              ${esc(iniciales)}
            </div>`
        }
        <span class="absolute bottom-1 right-1 text-2xl animate-bounce">🎉</span>
      </div>
      <h3 class="text-2xl font-bold text-[#1e3c72]">¡Bienvenido, ${esc(p.nombre || p.usuario)}!</h3>
      <p class="text-xs text-slate-500 mt-1 font-medium">${esc(p.rol || "Usuario")} · Librería San Martín</p>
      
      <div class="mt-4 pt-3 border-t border-slate-100 flex items-center justify-center gap-2 text-emerald-600 text-xs font-semibold">
        <span class="w-2 h-2 rounded-full bg-emerald-500 animate-ping"></span>
        Acceso concedido
      </div>

      <button id="btnCerrarBienvenida" class="mt-5 w-full py-3 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold shadow-lg shadow-blue-900/20 transition active:scale-[0.98]">
        Continuar al Panel
      </button>
    </div>
  `;
  document.body.appendChild(wrap);

  requestAnimationFrame(() => {
    const caja = $("#cajaBienvenida");
    if (caja) {
      caja.classList.remove("scale-95", "opacity-0");
      caja.classList.add("scale-100", "opacity-100");
    }
  });

  lanzarConfeti();

  let timerAutoCierre;
  const cerrar = () => {
    clearTimeout(timerAutoCierre);
    const caja = $("#cajaBienvenida");
    if (caja) caja.classList.add("scale-95", "opacity-0");
    wrap.style.opacity = "0";
    setTimeout(() => wrap.remove(), 300);
  };

  wrap.querySelector("#btnCerrarBienvenida").onclick = cerrar;
  wrap.onclick = (e) => { if (e.target === wrap) cerrar(); };
  timerAutoCierre = setTimeout(cerrar, 3500);
}

/* ---------------- login ---------------- */
export function pintarLogin() {
  console.log('[LSM] pintarLogin called');
  const el = $("#login");
  if (!el) { console.error('[LSM] #login element not found'); return; }
  console.log('[LSM] #login element found, removing hidden class');
  el.classList.remove("hidden");
  el.style.backgroundImage = "url('./assets/images/fondo-login.png')";
  el.style.backgroundSize = "cover";
  el.style.backgroundPosition = "center";
  el.innerHTML = `
  <div class="w-full max-w-md p-6">
    <div class="bg-black/50 backdrop-blur-sm rounded-2xl shadow-2xl p-8 fade">
      <div class="text-center mb-6">
        <img src="./assets/images/logo.png" alt="Logo" class="w-56 md:w-60 max-w-[240px] h-auto mx-auto object-contain drop-shadow-xl mb-3" />
        <h1 class="mt-3 text-2xl font-bold text-white">Librería San Martín</h1>
        <p class="text-sm text-white/80">${app.modo === "movil" ? "Aplicación móvil para el punto de venta" : "Panel de administración"}</p>
      </div>
      <form id="formLogin" class="space-y-4">
        <label class="block">
          <span class="block text-xs font-semibold text-white mb-1.5">Usuario</span>
          <input id="usuario" type="text" required autocomplete="username" autofocus
            placeholder="Ingresa tu usuario" autocapitalize="none" spellcheck="false"
            class="w-full px-3 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#2a5298] focus:border-transparent outline-none transition" />
        </label>
        <label class="block">
          <span class="block text-xs font-semibold text-white mb-1.5">Contraseña (PIN)</span>
          <div class="relative flex items-center">
            <input id="password" type="password" required autocomplete="current-password"
              placeholder="Ingresa tu PIN/Contraseña"
              class="w-full pl-3 pr-10 py-3 border border-slate-300 rounded-lg focus:ring-2 focus:ring-[#2a5298] focus:border-transparent outline-none transition" />
            <button type="button" data-toggle-pass
              class="absolute right-3 text-slate-400 hover:text-white p-1 text-base leading-none transition select-none cursor-pointer"
              title="Ver / Ocultar contraseña" aria-label="Ver u ocultar contraseña">
              👁️
            </button>
          </div>
        </label>
        <p id="loginError" class="hidden items-start gap-2 text-sm text-red-700 bg-red-50 border border-red-200 rounded-lg px-3 py-2.5"></p>
        <button class="w-full py-3 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white font-semibold transition shadow-lg shadow-blue-900/20">Ingresar</button>
      </form>
      <p class="mt-5 text-[11px] text-center text-slate-300">Acceso con usuario y PIN de la librería · RLS activo</p>
    </div>
  </div>`;
  console.log('[LSM] Login form HTML injected');
  $("#formLogin").addEventListener("submit", async (e) => {
    e.preventDefault();
    const btn = $("#formLogin button");
    btn.disabled = true;
    btn.textContent = "Verificando…";
    try {
      console.log('[LSM] Attempting signIn');
      await signIn($("#usuario").value.trim(), $("#password").value);
      console.log('[LSM] signIn success');
      const alerta = mostrarAlertaLogin("exito", "✅ Acceso permitido. Redirigiendo al sistema...");
      await new Promise((r) => setTimeout(r, 2600));
      alerta.remove();
      window.__recienLogueado = true;
      await arrancar();
    } catch (ex) {
      console.error('[LSM] signIn error:', ex);
      const alerta = mostrarAlertaLogin("error", "🚫 Acceso denegado: Usuario o PIN incorrecto.");
      await new Promise((r) => setTimeout(r, 2600));
      alerta.remove();
      btn.disabled = false;
      btn.textContent = "Ingresar";
      $("#password").value = "";
    }
  });
}

function mostrarAlertaLogin(tipo, mensaje) {
  const previa = document.getElementById("alertaLoginCentrada");
  if (previa) previa.remove();

  const esExito = tipo === "exito";
  const modal = document.createElement("div");
  modal.id = "alertaLoginCentrada";
  modal.className = "fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm fade";
  modal.innerHTML = `
    <div class="w-full max-w-md mx-auto p-6 md:p-8 rounded-2xl shadow-2xl text-center border-2 transition-all transform scale-100 ${
      esExito
        ? "bg-emerald-950/95 border-emerald-400 text-white shadow-emerald-500/40"
        : "bg-rose-950/95 border-rose-500 text-white shadow-rose-500/40"
    }">
      <p class="text-base sm:text-lg md:text-xl font-black leading-snug tracking-wide">
        ${mensaje}
      </p>
    </div>
  `;
  document.body.appendChild(modal);
  return modal;
}

/* ---------- cambio de clave obligatorio NO se aplica: el primer ingreso
   entra directo al Dashboard (la creación de PIN es opcional desde Mi Perfil) ---------- */

async function pintarShell() {
  const app_ = $("#app");
  app_.classList.remove("hidden");
  $("#login").classList.add("hidden");

  if ($("#nav")) {
    $("#nav").innerHTML = ORDEN.map((id) => {
      const m = mod(id);
      return `<a href="#${id}" data-nav="${id}" class="nav-item flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm ${id === app.vista ? "bg-white/15 font-semibold" : "hover:bg-white/10"}">
        <span class="text-base">${m.meta.icono}</span>${m.meta.titulo}</a>`;
    }).join("");
  }
  if ($("#navInferior")) {
    $("#navInferior").innerHTML = BOTONES_MOVIL.map((b, i) => `
      <button data-movil="${i}" class="flex-1 flex flex-col items-center justify-center gap-0.5 py-2 text-[10px] font-bold transition-all ${i === navMovilActiva() ? "text-[#1e3c72]" : "text-slate-400"}">
        <span class="nav-icon text-xl leading-none ${i === navMovilActiva() ? "scale-110" : ""}">${b.icono}</span>
        <span>${b.t}</span>
      </button>`).join("");
  }
  if ($("#drawer")) {
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
  conectarPresencia(app.perfil, () => {
    if (app.vista === "usuarios") {
      dibujar("usuarios");
    }
  });
  const inicial = parseHash();
  console.log('[LSM] Initial hash parse:', inicial);
  const destinoInicial = "#" + inicial.id + (inicial.params?.tab ? "/" + inicial.params.tab : "");
  history.replaceState({ id: inicial.id, params: inicial.params }, "", destinoInicial);
  ir(inicial.id, false, inicial.params);

  if (window.__recienLogueado) {
    window.__recienLogueado = false;
    mostrarModalBienvenida(app.perfil);
  }

  // Soporte para botón ATRÁS del celular / navegación en el historial
  window.addEventListener("popstate", (e) => {
    // 1. Si hay un modal abierto en pantalla, cerrarlo con prioridad
    const modales = document.querySelectorAll(".fixed.z-\\[900\\]");
    if (modales.length > 0) {
      modales[modales.length - 1].remove();
      return;
    }
    // 2. Si el cajón / menú lateral está abierto, cerrarlo
    const cajon = $("#cajon");
    if (cajon && !cajon.classList.contains("invisible")) {
      cerrarDrawer();
      return;
    }
    // 3. Volver a la pantalla anterior obedeciendo el historial
    const h = parseHash();
    ir(h.id, false, h.params);
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

/* ---------------- navegación e historial ---------------- */
export function ir(id, pushHash = true, params = null) {
  const m = mod(id);
  if (!m) id = "dashboard";
  if (params && m.abrir) m.abrir(params);

  const destino = "#" + id + (params?.tab ? "/" + params.tab : "");
  if (pushHash) {
    if (location.hash !== destino) {
      history.pushState({ id, params }, "", destino);
    }
  } else {
    if (location.hash !== destino) {
      history.replaceState({ id, params }, "", destino);
    }
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
  if (m.onRender) m.onRender();
  if ($("#titulo")) $("#titulo").textContent = m.meta.titulo;
  if ($("#subtitulo")) $("#subtitulo").textContent = subtitulo(m.meta.id);
  document.title = `${m.meta.titulo} · Librería San Martín`;
}

const SUBT = {
  dashboard: "Resumen general de la librería",
  ventas: "Punto de venta, historial y ajustes",
  inventario: "Productos, stock, valorización y categorías",
  compras: "Compras, proveedores y ranking",
  usuarios: "Usuarios, roles, estado y permisos",
  reportes: "Indicadores, ventas vs compras y rotación",
  perfil: "Tu cuenta, PIN, sesión y versión del sistema",
};
function subtitulo(id) { return SUBT[id] || ""; }

function pintarShellNav() {
  document.querySelectorAll("[data-nav]").forEach((a) => {
    const on = a.dataset.nav === app.vista;
    a.className = `nav-item flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm ${on ? "bg-white/15 font-semibold" : "hover:bg-white/10"}`;
  });
  const activa = navMovilActiva();
  document.querySelectorAll("[data-movil]").forEach((b, i) => {
    const on = i === activa;
    b.className = `flex-1 flex flex-col items-center justify-center gap-0.5 py-2 text-[10px] font-bold transition-all ${on ? "text-[#1e3c72]" : "text-slate-400 hover:text-slate-600"}`;
    const iconSpan = b.querySelector(".nav-icon");
    if (iconSpan) {
      iconSpan.className = `nav-icon text-xl leading-none transition-transform ${on ? "scale-110" : ""}`;
    }
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
    const btnEye = e.target.closest("[data-toggle-pass]");
    if (btnEye) {
      e.preventDefault();
      e.stopPropagation();
      const box = btnEye.closest("div") || btnEye.parentElement;
      const inp = box?.querySelector("input");
      if (inp) {
        const esPass = inp.type === "password";
        inp.type = esPass ? "text" : "password";
        btnEye.textContent = esPass ? "🙈" : "👁️";
        btnEye.title = esPass ? "Ocultar contraseña" : "Ver contraseña";
      }
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
    const navLink = e.target.closest("[data-nav]");
    if (navLink) {
      e.preventDefault();
      ir(navLink.dataset.nav, true);
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
  navigator.serviceWorker.register("/sw.js?v=2.5").then((reg) => {
    reg.update().catch(() => {});
  }).catch((e) => console.warn("SW no registrado", e));
}

export { toast, $, esc, sb };