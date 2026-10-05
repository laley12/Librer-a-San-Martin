/* =====================================================================
   UI COMPARTIDA (desktop + móvil)
   ===================================================================== */
import { money } from "./supabase-client.js";

export const $ = (s, r = document) => r.querySelector(s);
export const $$ = (s, r = document) => [...r.querySelectorAll(s)];

export function esc(s) {
  return String(s ?? "").replace(/[&<>"']/g, (c) =>
    ({ "&": "&", "<": "<", ">": ">", '"': """, "'": "'" }[c]));
}

/* ---------------- Toast ---------------- */
let toastTimer;
export function toast(mensaje, tipo = "ok") {
  let t = $("#toast");
  if (!t) {
    t = document.createElement("div");
    t.id = "toast";
    document.body.appendChild(t);
  }
  t.className = `fixed z-[999] left-1/2 -translate-x-1/2 bottom-24 md:bottom-8 px-4 py-2.5 rounded-xl shadow-xl text-white text-sm font-medium transition ${
    tipo === "error" ? "bg-red-600" : tipo === "warn" ? "bg-amber-500" : "bg-slate-900"}`;
  t.textContent = mensaje;
  t.style.opacity = "1";
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => (t.style.opacity = "0"), 3200);
}

/* ---------------- Modal ---------------- */
export function modal({ titulo, cuerpo, ancho = "max-w-lg", acciones = [] }) {
  const wrap = document.createElement("div");
  wrap.className = "fixed inset-0 z-[900] bg-slate-900/60 backdrop-blur-sm flex items-end md:items-center justify-center p-0 md:p-6";
  wrap.innerHTML = `
    <div class="bg-white w-full ${ancho} md:rounded-2xl rounded-t-2xl max-h-[92vh] flex flex-col fade">
      <div class="flex items-center justify-between px-5 py-4 border-b border-slate-200">
        <h3 class="font-bold text-[#1e3c72]">${esc(titulo)}</h3>
        <button data-cerrar class="text-slate-400 hover:text-slate-700 text-xl leading-none">×</button>
      </div>
      <div class="px-5 py-4 overflow-y-auto grow">${cuerpo}</div>
      ${acciones.length ? `<div class="px-5 py-3 border-t border-slate-200 flex gap-2 justify-end bg-slate-50 md:rounded-b-2xl">
        ${acciones.map((a, i) => `<button data-accion="${i}" class="px-4 py-2 rounded-lg text-sm font-semibold ${a.clase}">${esc(a.texto)}</button>`).join("")}
      </div>` : ""}
    </div>`;
  document.body.appendChild(wrap);
  const cerrar = () => wrap.remove();
  wrap.querySelector("[data-cerrar]").onclick = cerrar;
  wrap.onclick = (e) => { if (e.target === wrap) cerrar(); };
  $$("[data-accion]", wrap).forEach((b) => {
    b.onclick = async () => {
      b.disabled = true;
      try {
        const r = await acciones[+b.dataset.accion].fn(wrap);
        if (r !== false) cerrar();
      } catch (err) {
        toast(err.message, "error");
      } finally {
        b.disabled = false;
      }
    };
  });
  return { wrap, cerrar };
}

export function confirmar(mensaje, textoOk = "Confirmar") {
  return new Promise((resolve) => {
    const m = modal({
      titulo: "Confirmar acción", ancho: "max-w-sm",
      cuerpo: `<p class="text-sm text-slate-600">${esc(mensaje)}</p>`,
      acciones: [
        { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => { resolve(false); } },
        { texto: textoOk, clase: "bg-red-600 text-white", fn: () => { resolve(true); return true; } },
      ],
    });
    m.wrap.querySelector("[data-cerrar]").addEventListener("click", () => resolve(false));
  });
}

/* ---------------- Exportador CSV genérico ---------------- */
export function exportarCSV(nombreArchivo, columnas, filas) {
  if (!filas.length) return toast("No hay datos para exportar", "warn");
  const esc2 = (v) => `"${String(v ?? "").replace(/"/g, '""')}"`;
  const csv = [columnas.map((c) => esc2(c.titulo)).join(";"),
    ...filas.map((f) => columnas.map((c) => esc2(c.valor(f))).join(";"))].join("\r\n");
  const blob = new Blob(["\ufeff" + csv], { type: "text/csv;charset=utf-8" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  a.download = `${nombreArchivo}_${new Date().toISOString().slice(0, 10)}.csv`;
  a.click();
  URL.revokeObjectURL(a.href);
  toast(`Exportado: ${a.download}`);
}

/* ---------------- SVG Icons ---------------- */
export const ICONS = {
  money: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>`,
  chart: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"/></svg>`,
  calc: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z"/></svg>`,
  bank: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.5 6H5.25A2.25 2.25 0 003 8.25v10.5A2.25 2.25 0 005.25 21h13.5A2.25 2.25 0 0021 18.75V10.5m-10.5 6L21 3m0 0h-5.25M21 3v5.25"/></svg>`,
  ticket: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 5v2m0 4v2m0 4v2M5 5a2 2 0 00-2 2v10a2 2 0 002 2h14a2 2 0 002-2V7a2 2 0 00-2-2H5z"/></svg>`,
  alert: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>`,
  box: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 7l-8-4-8 4m16 0l-8 4m8-4v10l-8 4m0-10L4 7m8 4v10M4 7v10l8 4"/></svg>`,
  cart: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 11V7a4 4 0 00-8 0v4M5 9h14l1 12H4L5 9z"/></svg>`,
  key: `<svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/></svg>`,
};

/* ---------------- Piezas visuales ---------------- */
export const kpiCard = ({ label, valor, sub, icono, color = "text-[#1e3c72]", compacto = false, onClick, iconBg = "bg-slate-100", iconColor = "text-slate-600", hoverIconBg = "bg-slate-200", hoverIconColor = "text-[#1e3c72]" }) => {
  const svg = ICONS[icono] || (icono ? `<span class="text-xl">${icono}</span>` : "");
  const clickAttr = onClick ? `onclick="${esc(onClick)}"` : "";
  const cursorClass = onClick ? "cursor-pointer" : "";
  return `
  <div ${clickAttr} class="bg-white ${compacto ? "rounded-2xl p-3.5" : "rounded-xl border border-slate-200 p-5"} shadow-sm ${cursorClass} transition-all duration-200 hover:shadow-md hover:border-blue-300 group">
    <div class="flex items-start justify-between gap-2">
      <div class="min-w-0">
        <div class="text-[10px] md:text-xs uppercase tracking-wide text-slate-400">${label}</div>
        <div class="${compacto ? "text-lg" : "text-2xl"} font-bold mt-1 ${color} truncate">${valor}</div>
        ${sub ? `<div class="text-[10px] md:text-xs text-slate-400 mt-0.5 truncate">${sub}</div>` : ""}
      </div>
      ${svg ? `<div class="${compacto ? "p-2" : "p-3"} ${iconBg} rounded-lg group-hover:${hoverIconBg} group-hover:${hoverIconColor} transition-colors shrink-0">${svg}</div>` : ""}
    </div>
  </div>`;
};

export const seccion = (titulo, cuerpo, derecha = "", acciones = "") => `
  <section class="bg-white rounded-xl border border-slate-200 shadow-sm overflow-hidden">
    <div class="px-4 md:px-5 py-3 border-b border-slate-100 flex items-center justify-between gap-3 flex-wrap">
      <h2 class="font-semibold text-slate-700 text-sm">${titulo}</h2>
      <div class="flex items-center gap-3">${acciones}${derecha}</div>
    </div>
    <div class="p-3 md:p-5">${cuerpo}</div>
  </section>`;

export const badgeStock = (stock) => {
  const s = Number(stock);
  if (s <= 0) return `<span class="text-[10px] px-2 py-0.5 rounded-full bg-red-100 text-red-700">Agotado</span>`;
  if (s <= 5) return `<span class="text-[10px] px-2 py-0.5 rounded-full bg-amber-100 text-amber-700">Bajo</span>`;
  return `<span class="text-[10px] px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-700">OK</span>`;
};

export const tabla = (columnas, filas, opciones = {}) => {
  if (!filas.length) return `<p class="text-sm text-slate-400 text-center py-6">${opciones.vacio || "Sin registros"}</p>`;
  return `<div class="overflow-x-auto -mx-3 px-3 md:mx-0 md:px-0">
    <table class="w-full text-sm">
      <thead><tr class="text-left text-[10px] md:text-xs uppercase text-slate-400 border-b border-slate-200">
        ${columnas.map((c) => `<th class="py-2 px-2 ${c.der ? "text-right" : ""} whitespace-nowrap">${c.t}</th>`).join("")}
      </tr></thead>
      <tbody>${filas.map((f, i) => `<tr class="border-b border-slate-50 hover:bg-slate-50/70 ${opciones.filaClase?.(f, i) || ""}">
        ${columnas.map((c) => `<td class="py-2 px-2 ${c.der ? "text-right" : ""} ${c.clase || ""}">${c.v(f, i)}</td>`).join("")}
      </tr>`).join("")}</tbody>
    </table></div>`;
};

export const barras = (datos, max, fmt) => `
  <div class="flex items-end gap-1.5 md:gap-3 h-40 md:h-48">
    ${datos.map((d) => {
      const h = Math.max(3, Math.round((d.v / max) * 100));
      return `<div class="flex-1 flex flex-col items-center gap-1 min-w-0">
        <span class="text-[9px] md:text-[10px] text-slate-400 truncate w-full text-center">${fmt ? fmt(d.v) : d.v}</span>
        <div class="w-full rounded-t-md bg-gradient-to-t from-[#1e3c72] to-[#2a5298]" style="height:${h}%"></div>
        <span class="text-[9px] md:text-[10px] text-slate-500 truncate w-full text-center">${d.etiqueta}</span>
      </div>`;
    }).join("")}
  </div>`;

export const input = (etiqueta, attrs = {}) => `
  <label class="block">
    <span class="block text-xs font-semibold text-slate-500 mb-1">${etiqueta}</span>
    <input ${Object.entries(attrs).map(([k, v]) => `${k}="${v}"`).join(" ")}
      class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298] focus:border-transparent" />
  </label>`;

export const select = (etiqueta, opciones, attrs = {}) => `
  <label class="block">
    <span class="block text-xs font-semibold text-slate-500 mb-1">${etiqueta}</span>
    <select ${Object.entries(attrs).map(([k, v]) => `${k}="${v}"`).join(" ")}
      class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white outline-none focus:ring-2 focus:ring-[#2a5298]">
      ${opciones.map((o) => `<option value="${o.v}">${o.t}</option>`).join("")}
    </select>
  </label>`;

export const btn = (texto, clase = "bg-[#1e3c72] text-white", extra = "") =>
  `<button class="px-4 py-2.5 rounded-lg text-sm font-semibold hover:opacity-90 transition ${clase}" ${extra}>${texto}</button>`;

export { money };