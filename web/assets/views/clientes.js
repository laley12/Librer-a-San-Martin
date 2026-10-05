import { money, num, fecha } from "../supabase-client.js";
import { state, repo, topClientes, ventasVigentes } from "../data.js";
import { esc, toast, modal, tabla, seccion, input, exportarCSV } from "../ui.js";

export const meta = { id: "clientes", titulo: "Clientes (CRM)", icono: "👥", grupo: "Operación" };

let busqueda = "";
let vista = "lista";

export function render() {
  return `
  <div class="fade space-y-4">
    <div class="grid grid-cols-3 gap-3">
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Clientes activos</div>
        <div class="text-xl font-bold text-[#1e3c72]">${num(state.clientes.filter((c) => Number(c.activo) === 1).length)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Con compras</div>
        <div class="text-xl font-bold text-emerald-600">${num(topClientes(999).filter((c) => c.compras > 0).length)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Total facturado</div>
        <div class="text-xl font-bold text-sky-600">${money(ventasVigentes().reduce((s, v) => s + Number(v.total || 0), 0))}</div>
      </div>
    </div>

    <div class="flex gap-2 overflow-x-auto pb-1">
      ${[["lista", "📋 Lista"], ["frecuentes", "🏆 Frecuentes"], ["nuevo", "➕ Nuevo cliente"]]
        .map(([k, t]) => `<button data-tab="${k}" class="tab shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold ${vista === k ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
    </div>
    <div>${panel()}</div>
  </div>`;
}

function filtrados() {
  const q = busqueda.toLowerCase();
  if (!q) return state.clientes.filter((c) => Number(c.activo) === 1);
  return state.clientes.filter((c) =>
    String(c.nombre_cliente).toLowerCase().includes(q) ||
    String(c.ci_nit || "").toLowerCase().includes(q) ||
    String(c.telefono || "").toLowerCase().includes(q));
}

function panel() {
  if (vista === "frecuentes") return panelFrecuentes();
  if (vista === "nuevo") return panelNuevo();
  const lista = filtrados();
  return seccion(`Clientes (${lista.length})`, `
    <input id="filtroCli" value="${esc(busqueda)}" placeholder="Buscar por nombre, CI/NIT o teléfono…"
      class="w-full px-3 py-2.5 mb-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
    ${tabla([
      { t: "Cliente", v: (c) => `<span class="font-medium">${esc(c.nombre_cliente)}</span>` },
      { t: "CI/NIT", v: (c) => `<span class="text-xs text-slate-500">${esc(c.ci_nit || "—")}</span>` },
      { t: "Teléfono", v: (c) => `<span class="text-xs text-slate-500">${esc(c.telefono || "—")}</span>` },
      { t: "Registro", v: (c) => `<span class="text-xs text-slate-400">${fecha(c.fecha_registro)}</span>` },
      { t: "", der: 1, v: (c) => `<div class="flex gap-1 justify-end">
        <button data-historial="${c.id_cliente}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Historial</button>
        <button data-editar="${c.id_cliente}" class="text-[10px] px-2 py-1 rounded bg-slate-100 text-slate-600 font-semibold">Editar</button>
      </div>` },
    ], lista, { vacio: "Sin clientes registrados" })}`,
    `<button data-export="clientes" class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar CSV</button>`);
}

function panelFrecuentes() {
  return seccion("Clientes frecuentes", tabla([
    { t: "#", v: (_, i) => `<span class="font-bold text-slate-300">${i + 1}</span>` },
    { t: "Cliente", v: (c) => `<span class="font-medium">${esc(c.nombre)}</span>` },
    { t: "Compras", der: 1, v: (c) => c.compras },
    { t: "Total", der: 1, v: (c) => `<span class="font-bold text-emerald-600">${money(c.total)}</span>` },
    { t: "Ticket prom.", der: 1, v: (c) => money(c.compras ? c.total / c.compras : 0) },
  ], topClientes(20), { vacio: "Sin compras de clientes" }));
}

function panelNuevo() {
  return `<div class="max-w-xl">${seccion("Registrar cliente", `
    <div class="space-y-3">
      <div class="grid grid-cols-2 gap-3">
        ${input("Nombre completo", { id: "cNombre", placeholder: "Nombre y apellidos" })}
        ${input("CI/NIT", { id: "cCi", placeholder: "Opcional" })}
      </div>
      <div class="grid grid-cols-2 gap-3">
        ${input("Teléfono", { id: "cTel", placeholder: "Opcional" })}
        ${input("Correo", { id: "cEmail", type: "email", placeholder: "Opcional" })}
      </div>
      ${input("Fecha de nacimiento", { id: "cNac", type: "date" })}
      ${input("Dirección", { id: "cDir", placeholder: "Opcional" })}
      <button id="btnGuardarCliente" class="w-full px-4 py-2.5 rounded-lg text-sm font-semibold bg-emerald-600 text-white">Guardar cliente</button>
    </div>`)}</div>`;
}

function historialCliente(id) {
  const c = state.clientes.find((x) => x.id_cliente === id);
  const todas = state.ventas.filter((v) => v.id_cliente === id);
  const ventas = ventasVigentes().filter((v) => v.id_cliente === id)
    .sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  const anuladas = todas.length - ventas.length;
  const total = ventas.reduce((s, v) => s + Number(v.total || 0), 0);
  modal({
    titulo: `Historial de ${c?.nombre_cliente || ""}`, ancho: "max-w-lg",
    cuerpo: `
      <div class="grid grid-cols-3 gap-2 mb-4 text-center">
        <div class="bg-slate-50 rounded-xl p-3"><div class="text-[10px] text-slate-400">Compras</div><div class="text-lg font-bold">${ventas.length}</div></div>
        <div class="bg-slate-50 rounded-xl p-3"><div class="text-[10px] text-slate-400">Total</div><div class="text-lg font-bold text-emerald-600">${money(total)}</div></div>
        <div class="bg-slate-50 rounded-xl p-3"><div class="text-[10px] text-slate-400">Ticket prom.</div><div class="text-lg font-bold">${money(ventas.length ? total / ventas.length : 0)}</div></div>
      </div>
      <div class="text-xs text-slate-500 mb-2">Cliente: ${esc(c?.nombre_cliente || "")} ${c?.ci_nit ? "· CI/NIT " + esc(c.ci_nit) : ""}
        ${anuladas ? `<span class="text-amber-600">· ${anuladas} anulada(s) excluida(s) del total</span>` : ""}</div>
      ${tabla([
        { t: "Venta", v: (v) => `<b>#${v.id_venta}</b>` },
        { t: "Fecha", v: (v) => fecha(v.fecha) },
        { t: "Pago", v: (v) => esc(v.metodo_pago || "—") },
        { t: "Total", der: 1, v: (v) => `<span class="font-semibold text-emerald-600">${money(v.total)}</span>` },
      ], ventas, { vacio: "Sin compras registradas" })}`,
    acciones: [{ texto: "Cerrar", clase: "bg-slate-200 text-slate-700", fn: () => true }],
  });
}

function editarCliente(id) {
  const c = state.clientes.find((x) => x.id_cliente === id);
  modal({
    titulo: "Editar cliente", ancho: "max-w-sm",
    cuerpo: `<div class="space-y-3">
      ${input("Nombre", { id: "eCliNombre", value: esc(c.nombre_cliente) })}
      <div class="grid grid-cols-2 gap-3">
        ${input("CI/NIT", { id: "eCliCi", value: esc(c.ci_nit || "") })}
        ${input("Teléfono", { id: "eCliTel", value: esc(c.telefono || "") })}
      </div>
      ${input("Correo", { id: "eCliEmail", value: esc(c.email || "") })}
    </div>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Guardar", clase: "bg-[#1e3c72] text-white",
        fn: async (w) => {
          await repo.actualizarCliente(id, {
            nombre_cliente: w.querySelector("#eCliNombre").value.trim(),
            ci_nit: w.querySelector("#eCliCi").value.trim() || null,
            telefono: w.querySelector("#eCliTel").value.trim() || null,
            email: w.querySelector("#eCliEmail").value.trim() || null,
          }, _ctx?.perfil?.usuarioId);
          toast("Cliente actualizado");
          await _ctx?.recargar(); _ctx?.rerender();
          return true;
        },
      },
    ],
  });
}

let _ctx = null;

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", async (e) => {
    const t = e.target.closest("[data-tab]");
    if (t) { vista = t.dataset.tab; ctx.rerender(); return; }
    const h = e.target.closest("[data-historial]");
    if (h) return historialCliente(+h.dataset.historial);
    const ed = e.target.closest("[data-editar]");
    if (ed) return editarCliente(+ed.dataset.editar);

    if (e.target.closest("#btnGuardarCliente")) {
      const nombre = root.querySelector("#cNombre").value.trim();
      if (!nombre) return toast("Escribe el nombre", "warn");
      try {
        await repo.crearCliente({
          nombre_cliente: nombre,
          ci_nit: root.querySelector("#cCi").value.trim() || null,
          telefono: root.querySelector("#cTel").value.trim() || null,
          email: root.querySelector("#cEmail").value.trim() || null,
          fecha_nacimiento: root.querySelector("#cNac").value || null,
          activo: 1,
        }, ctx.perfil.usuarioId);
        toast("Cliente registrado");
        vista = "lista";
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    const ex = e.target.closest("[data-export]");
    if (ex) exportarCSV("clientes", [
      { titulo: "Nombre", valor: (c) => c.nombre_cliente },
      { titulo: "CI/NIT", valor: (c) => c.ci_nit || "" },
      { titulo: "Teléfono", valor: (c) => c.telefono || "" },
      { titulo: "Correo", valor: (c) => c.email || "" },
      { titulo: "Registro", valor: (c) => String(c.fecha_registro || "").slice(0, 10) },
    ], filtrados());
  });

  root.addEventListener("input", (ev) => {
    if (ev.target.id === "filtroCli") {
      busqueda = ev.target.value;
      const pos = ev.target.selectionStart;
      ctx.rerender();
      const n = root.querySelector("#filtroCli");
      if (n) { n.focus(); n.setSelectionRange(pos, pos); }
    }
  });
}