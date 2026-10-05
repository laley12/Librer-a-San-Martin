import { money, fecha, fechaHora } from "../supabase-client.js";
import { state, repo, TABLAS_AUDITORIA, auditTrail } from "../data.js";
import { esc, toast, tabla, seccion, exportarCSV, input } from "../ui.js";

export const meta = { id: "auditoria", titulo: "Auditoría General", icono: "🛡️", grupo: "Control" };

let filtro = "Todas";
let busqueda = "";
let pagina = 0;
const POR_PAGINA = 25;

export function render() {
  const todas = auditTrail();
  const modulos = ["Todas", ...TABLAS_AUDITORIA.map((a) => a.modulo)];
  const filtradas = auditTrail(filtro, busqueda);
  const vista = filtradas.slice(pagina * POR_PAGINA, pagina * POR_PAGINA + POR_PAGINA);
  const paginas = Math.max(1, Math.ceil(filtradas.length / POR_PAGINA));

  return `
  <div class="fade space-y-4">
    <div class="bg-white rounded-xl border border-slate-200 p-4">
      <div class="flex flex-wrap gap-2 items-center">
        <div class="flex gap-1.5 overflow-x-auto flex-1 min-w-full pb-1 md:pb-0">
          ${modulos.map((m) => `<button data-mod="${m}" class="shrink-0 px-3 py-1.5 rounded-lg text-xs font-semibold ${filtro === m ? "bg-[#1e3c72] text-white" : "bg-slate-100 text-slate-600"}">${m}</button>`).join("")}
        </div>
        <input id="buscaAudit" value="${esc(busqueda)}" placeholder="Buscar acción…"
          class="w-full md:w-64 px-3 py-2 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
      </div>
      <p class="text-[10px] text-slate-400 mt-3">
        Consolida las ${TABLAS_AUDITORIA.length} tablas de auditoría del sistema en un solo panel filtrable (antes eran 8 páginas separadas).
      </p>
    </div>

    ${seccion(`${filtradas.length} eventos`, tabla([
      { t: "Módulo", v: (r) => `<span class="text-[10px] px-2 py-0.5 rounded-full bg-blue-50 text-[#2a5298] font-semibold">${r.modulo}</span>` },
      { t: "Acción", v: (r) => esc(r.accion || "—") },
      { t: "Usuario", v: (r) => esc(r.usuario) },
      { t: "Fecha", der: 1, v: (r) => `<span class="text-xs text-slate-500">${fechaHora(r.fecha)}</span>` },
    ], vista, { vacio: "Sin eventos para este filtro" }),
      `<button data-export class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar CSV</button>`)}

    ${paginas > 1 ? `<div class="flex items-center justify-center gap-3 text-sm">
      <button data-pag="-1" class="px-3 py-1.5 rounded-lg border border-slate-300 disabled:opacity-40" ${pagina === 0 ? "disabled" : ""}>‹ Anterior</button>
      <span class="text-slate-500">${pagina + 1} / ${paginas}</span>
      <button data-pag="1" class="px-3 py-1.5 rounded-lg border border-slate-300 disabled:opacity-40" ${pagina >= paginas - 1 ? "disabled" : ""}>Siguiente ›</button>
    </div>` : ""}
  </div>`;
}

export function mount(root, ctx) {
  root.addEventListener("click", (e) => {
    const m = e.target.closest("[data-mod]");
    if (m) { filtro = m.dataset.mod; pagina = 0; ctx.rerender(); return; }
    const p = e.target.closest("[data-pag]");
    if (p) { pagina = Math.max(0, pagina + +p.dataset.pag); ctx.rerender(); return; }
    if (e.target.closest("[data-export]")) exportarCSV("auditoria", [
      { titulo: "Módulo", valor: (r) => r.modulo },
      { titulo: "Acción", valor: (r) => r.accion },
      { titulo: "Usuario", valor: (r) => r.usuario },
      { titulo: "Fecha", valor: (r) => String(r.fecha || "").slice(0, 19).replace("T", " ") },
    ], auditTrail(filtro, busqueda));
  });
  root.addEventListener("input", (ev) => {
    if (ev.target.id === "buscaAudit") {
      busqueda = ev.target.value;
      pagina = 0;
      const pos = ev.target.selectionStart;
      ctx.rerender();
      const n = root.querySelector("#buscaAudit");
      if (n) { n.focus(); n.setSelectionRange(pos, pos); }
    }
  });
}