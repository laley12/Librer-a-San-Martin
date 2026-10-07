import { money, num, fecha, fechaHora, hora } from "../supabase-client.js";
import { state, repo, kpis, mapaProductos, ventasVigentes } from "../data.js";
import { $, $$, esc, toast, modal, confirmar, tabla, seccion, input, select, btn, badgeStock } from "../ui.js";

export const meta = { id: "ventas", titulo: "Ventas & Caja", icono: "🧾", grupo: "Operación" };

let tab = "pos";
let carrito = [];
let filtroHistorial = "";
let filtroProd = "";
let metodoPago = "Efectivo";

export function abrir(params = {}) {
  if (params.tab) tab = params.tab;
  if (params.limpiar) carrito = [];
}

export function render() {
  return `
  <div class="fade space-y-4">
    <div class="flex gap-2 overflow-x-auto pb-1">
      ${[["pos", "🛒 Punto de venta"], ["historial", "📋 Historial"], ["caja", "💵 Apertura / Cierre"],
        ["flujo", "🏦 Flujo de caja"], ["devoluciones", "↩️ Devoluciones"], ["ajustes", "⚙️ Ajustes"]]
        .map(([k, t]) => `<button data-tab="${k}" class="tab shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold ${tab === k ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
    </div>
    <div id="panel">${panel()}</div>
  </div>`;
}

function panel() {
  if (tab === "pos") return panelPOS();
  if (tab === "historial") return panelHistorial();
  if (tab === "caja") return panelCaja();
  if (tab === "devoluciones") return panelDevoluciones();
  if (tab === "ajustes") return panelAjustes();
  return panelFlujo();
}

/* ============ POS ============ */
function cmpFiltro(p) {
  const q = filtroProd.trim().toLowerCase();
  if (!q) return true;
  return p.nombre_producto.toLowerCase().includes(q) || String(p.codigo || "").toLowerCase().includes(q);
}

function tarjetasProducto(lista) {
  return [...lista].sort((a, b) => a.nombre_producto.localeCompare(b.nombre_producto)).map((p) => `
    <button data-add="${p.id_producto}" class="w-full flex items-center justify-between gap-3 px-3 py-2.5 rounded-lg border border-slate-100 hover:border-[#2a5298] hover:bg-blue-50/40 text-left active:bg-blue-50">
      <span class="min-w-0">
        <span class="block text-sm font-medium truncate">${esc(p.nombre_producto)}</span>
        <span class="block font-mono text-[10px] text-slate-400">${esc(p.codigo || "")}</span>
      </span>
      <span class="text-right shrink-0">
        <span class="block text-sm font-bold text-[#1e3c72]">${money(p.precio)}</span>
        <span class="block text-[10px] text-slate-400">stock ${p.stock}</span>
      </span>
    </button>`).join("");
}

function pintarProductos() {
  const activos = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) > 0);
  const visibles = activos.filter(cmpFiltro);
  const lista = $("#listaProductos");
  if (lista) lista.innerHTML = tarjetasProducto(visibles);
  const c = $("#conteoProd");
  if (c) c.textContent = `${visibles.length} de ${activos.length} productos disponibles · ${activos.filter((p) => p.stock <= 5).length} con stock bajo`;
}

function panelPOS() {
  const activos = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) > 0);
  const visibles = activos.filter(cmpFiltro);
  const total = carrito.reduce((s, l) => s + l.cantidad * l.precio, 0);
  const qr = configQR();
  const esQR = metodoPago === "QR / Transferencia";
  return `
  <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
    <div class="lg:col-span-3 space-y-4">
      ${seccion("Buscar producto", `
        <input id="buscarProd" list="listaProd" value="${esc(filtroProd)}" placeholder="Busca por nombre o código de barras…"
          class="w-full px-3 py-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
        <datalist id="listaProd">${visibles.map((p) => `<option value="${esc(p.nombre_producto)} — ${esc(p.codigo || "")}">`).join("")}</datalist>
        <div class="flex flex-wrap gap-2 mt-3">
          <button data-addmode="1" class="px-3 py-2 rounded-lg text-xs font-semibold bg-slate-100 hover:bg-slate-200">Añadir por código</button>
        </div>
        <p id="conteoProd" class="text-[10px] text-slate-400 mt-2">${visibles.length} de ${activos.length} productos disponibles · ${activos.filter((p) => p.stock <= 5).length} con stock bajo</p>`)}
      ${seccion("Productos con stock", `
        <div id="listaProductos" class="max-h-[42vh] lg:max-h-[60vh] overflow-y-auto space-y-1.5 -mx-1 px-1">
          ${tarjetasProducto(visibles)}
        </div>`)}
    </div>

    <div class="lg:col-span-2">
      <div class="lg:sticky lg:top-4 bg-white rounded-xl border border-slate-200 shadow-sm flex flex-col max-h-[90vh]">
        <div class="px-4 py-3 border-b border-slate-100 font-semibold text-slate-700 text-sm">Venta actual</div>
        <div id="carrito" class="grow overflow-y-auto max-h-[36vh] lg:max-h-[50vh] divide-y divide-slate-50">
          ${carrito.length ? carrito.map((l) => `
            <div class="px-4 py-3 flex items-center justify-between gap-2">
              <div class="min-w-0">
                <div class="text-xs font-semibold truncate">${esc(l.nombre)}</div>
                <div class="text-[10px] text-slate-400">${money(l.precio)} cada uno</div>
              </div>
              <div class="flex items-center gap-2 shrink-0">
                <button data-cant="${l.productoId}" data-delta="-1" class="w-9 h-9 rounded-lg bg-slate-100 hover:bg-slate-200 text-lg font-bold grid place-items-center active:scale-95">−</button>
                <span class="w-7 text-center text-sm font-bold">${l.cantidad}</span>
                <button data-cant="${l.productoId}" data-delta="1" class="w-9 h-9 rounded-lg bg-[#1e3c72] hover:bg-[#2a5298] text-white text-lg font-bold grid place-items-center active:scale-95">+</button>
                <span class="w-20 text-right text-sm font-bold">${money(l.cantidad * l.precio)}</span>
                <button data-quitar="${l.productoId}" class="text-slate-300 hover:text-red-500 text-xl leading-none" aria-label="Quitar">×</button>
              </div>
            </div>`).join("") : `<p class="text-sm text-slate-400 text-center py-10">Carrito vacío<br /><span class="text-xs">Toca un producto para agregarlo</span></p>`}
        </div>
        <div class="px-4 py-3 border-t border-slate-100 space-y-3">
          <div class="flex justify-between items-baseline">
            <span class="text-sm text-slate-500">Total</span>
            <span class="text-3xl font-black tracking-tight text-[#1e3c72]">${money(total)}</span>
          </div>
          <div>
            <div class="text-[10px] uppercase tracking-wide text-slate-400 font-semibold mb-1.5">Método de pago</div>
            <div class="grid grid-cols-3 gap-2">
              ${[["Efectivo", "💵"], ["QR / Transferencia", "📱"], ["Tarjeta", "💳"]].map(([m, ico]) => `
                <button data-pago="${m}" class="px-1 py-2.5 rounded-lg text-[11px] font-bold leading-tight transition active:scale-[0.97] ${metodoPago === m ? "bg-[#1e3c72] text-white border border-[#1e3c72] shadow" : "bg-white text-slate-600 border border-slate-300"}">${ico}<br />${m.includes("QR") ? "QR / Transf." : m}</button>`).join("")}
            </div>
          </div>
          ${esQR ? (qr.activo !== false ? `
          <div class="rounded-xl border border-emerald-200 bg-emerald-50/60 p-3 text-center">
            <img src="${urlQR(qr)}" alt="Código QR de cobro" class="w-36 h-36 mx-auto bg-white p-1.5 rounded-lg border border-slate-200" />
            <p class="text-xs font-semibold text-emerald-700 mt-2">${esc(qr.nombre || "Librería San Martín")}</p>
            <p class="text-[10px] text-slate-500 mt-0.5">Pide al cliente escanear antes de presionar Confirmar venta</p>
          </div>` : `<p class="text-[11px] text-amber-600 bg-amber-50 border border-amber-200 rounded-lg px-3 py-2">QR desactivado · actívalo en Ajustes → Código QR de cobro.</p>`) : ""}
          <div>
            <div class="text-[10px] uppercase tracking-wide text-slate-400 font-semibold mb-1.5">Cliente</div>
            <select id="clienteVenta" class="w-full px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white">
              <option value="">Cliente general</option>
              ${state.clientes.filter((c) => Number(c.activo) === 1).map((c) => `<option value="${c.id_cliente}">${esc(c.nombre_cliente)}</option>`).join("")}
            </select>
          </div>
          <button id="btnVender" class="w-full py-3.5 rounded-xl bg-emerald-600 hover:bg-emerald-700 text-white font-bold text-sm shadow active:scale-[0.99]">
            Confirmar venta ${carrito.length ? `· ${money(total)}` : ""}
          </button>
          ${carrito.length ? `<button id="btnLimpiar" class="w-full text-xs text-slate-400 hover:text-red-500">Vaciar carrito</button>` : ""}
        </div>
      </div>
    </div>
  </div>`;
}


function agregar(productoId, cantidad = 1) {
  const p = mapaProductos().get(Number(productoId));
  if (!p) return;
  const linea = carrito.find((l) => l.productoId === p.id_producto);
  const enCarrito = (linea?.cantidad || 0);
  if (Number(p.stock) <= 0) return toast("Producto agotado", "warn");
  if (enCarrito + cantidad > Number(p.stock)) return toast(`Solo hay ${p.stock} unidades`, "warn");
  if (linea) linea.cantidad += cantidad;
  else carrito.push({ productoId: p.id_producto, nombre: p.nombre_producto, precio: Number(p.precio), cantidad });
  refrescarPanel();
}

/* ============ HISTORIAL ============ */
function panelHistorial() {
  const q = filtroHistorial.toLowerCase();
  const filas = [...state.ventas]
    .filter((v) => !q || String(v.id_venta).includes(q) || String(v.metodo_pago || "").toLowerCase().includes(q) ||
      String(v.estado || "").toLowerCase().includes(q))
    .sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  return seccion("Historial de ventas", `
    <input id="filtroVentas" value="${esc(filtroHistorial)}" placeholder="Filtrar por número, pago o estado…"
      class="w-full px-3 py-2.5 mb-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
    ${tabla([
      { t: "Venta", v: (v) => `<span class="font-bold">#${v.id_venta}</span>` },
      { t: "Fecha", v: (v) => `<span class="text-xs">${fecha(v.fecha)}</span>` },
      { t: "Cliente", v: (v) => esc(state.clientes.find((c) => c.id_cliente === v.id_cliente)?.nombre_cliente || "General") },
      { t: "Pago", v: (v) => `<span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-100">${esc(v.metodo_pago || "—")}</span>` },
      { t: "Estado", v: (v) => `<span class="text-[10px] px-2 py-0.5 rounded-full ${v.estado === "Anulado" ? "bg-red-100 text-red-700" : "bg-emerald-100 text-emerald-700"}">${esc(v.estado || "Completado")}</span>` },
      { t: "Total", der: 1, v: (v) => `<span class="font-bold text-emerald-600">${money(v.total)}</span>` },
      { t: "", der: 1, v: (v) => `<div class="flex gap-1 justify-end">
          <button data-recibo="${v.id_venta}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Recibo</button>
          ${String(v.estado || "").toLowerCase() === "anulado" ? "" : `
            <button data-devolver="${v.id_venta}" class="text-[10px] px-2 py-1 rounded bg-amber-50 text-amber-600 font-semibold">Devolver</button>
            <button data-anular="${v.id_venta}" class="text-[10px] px-2 py-1 rounded bg-red-50 text-red-600 font-semibold">Anular</button>`}
        </div>` },
    ], filas, { vacio: "Sin ventas registradas" })}`,
    `<button data-export="ventas" class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar CSV</button>`);
}

function verRecibo(ventaId) {
  const v = state.ventas.find((x) => x.id_venta === ventaId);
  if (!v) return;
  const cliente = state.clientes.find((c) => c.id_cliente === v.id_cliente);
  const lineas = state.detalle_ventas.filter((d) => d.venta_id === ventaId);
  const recibo = state.recibos.find((r) => r.venta_id === ventaId);
  modal({
    titulo: `Recibo ${recibo?.numero_recibo || ""}`, ancho: "max-w-md",
    cuerpo: `
      <div class="text-center border-b border-dashed border-slate-300 pb-4 mb-4">
        <div class="text-lg font-bold text-[#1e3c72]">📚 Librería San Martín</div>
        <div class="text-xs text-slate-500">Venta #${v.id_venta} · ${fechaHora(v.fecha)}</div>
      </div>
      <div class="text-sm space-y-1 mb-4">
        <div class="flex justify-between"><span class="text-slate-500">Cliente</span><span class="font-semibold">${esc(cliente?.nombre_cliente || "General")}</span></div>
        ${cliente?.ci_nit ? `<div class="flex justify-between"><span class="text-slate-500">CI/NIT</span><span>${esc(cliente.ci_nit)}</span></div>` : ""}
        <div class="flex justify-between"><span class="text-slate-500">Pago</span><span>${esc(v.metodo_pago || "—")}</span></div>
      </div>
      <table class="w-full text-xs mb-3">
        <thead class="text-slate-400 text-[10px] uppercase"><tr><th class="text-left py-1">Producto</th><th class="text-right">Cant</th><th class="text-right">Importe</th></tr></thead>
        <tbody>${lineas.map((l) => `<tr class="border-t border-slate-100">
          <td class="py-1.5">${esc(nombre(l.producto_id))}</td>
          <td class="text-right">${l.cantidad}</td>
          <td class="text-right font-semibold">${money(l.cantidad * l.precio)}</td></tr>`).join("")}</tbody>
      </table>
      <div class="flex justify-between text-base font-bold border-t-2 border-slate-800 pt-2 mt-2">
        <span>TOTAL</span><span>${money(v.total)}</span>
      </div>
      ${qrTicket(v)}`,
    acciones: [
      { texto: "Cerrar", clase: "bg-slate-200 text-slate-700", fn: () => true },
      { texto: "Imprimir", clase: "bg-[#1e3c72] text-white", fn: () => { setTimeout(() => window.print(), 100); return true; } },
    ],
  });
  function nombre(id) {
    return state.productos.find((p) => p.id_producto === id)?.nombre_producto || `#${id}`;
  }
}

function qrTicket(v) {
  const esPagoQR = /qr|sinepay|transferencia/i.test(String(v.metodo_pago || ""));
  if (!esPagoQR) return "";
  const qr = configQR();
  if (qr.activo === false) return "";
  return `
  <div class="text-center mt-4 pt-3 border-t border-dashed border-slate-300">
    <img src="${urlQR(qr)}" alt="QR de validación" class="w-28 h-28 mx-auto" />
    <div class="text-[10px] text-slate-500">${esc(qr.nombre || "Librería San Martín")}</div>
  </div>`;
}

/* ============ CAJA ============ */
function panelCaja() {
  const abierta = state.apertura_caja.find((a) => Number(a.activo) === 1);
  const ventasDia = ventasVigentes().filter((v) => String(v.fecha).slice(0, 10) === new Date().toISOString().slice(0, 10));
  const porPago = {};
  for (const v of ventasDia) porPago[v.metodo_pago || "Efectivo"] = (porPago[v.metodo_pago || "Efectivo"] || 0) + Number(v.total || 0);
  const esperado = Number(abierta?.monto_inicial || 0) + ventasDia.reduce((s, v) => s + Number(v.total || 0), 0) - Number(abierta?.monto_esperado || 0);
  return `
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
    ${abierta ? seccion("Caja abierta", `
      <div class="text-center py-3">
        <div class="text-xs text-slate-400">Monto inicial</div>
        <div class="text-3xl font-bold text-[#1e3c72]">${money(abierta.monto_inicial)}</div>
        <div class="text-[10px] text-slate-400 mt-1">Abierta ${fechaHora(abierta.fecha_apertura)} · ${esc(state.usuarios.find((u) => u.id === abierta.id_usuario)?.nombre || "")}</div>
      </div>
      <div class="grid grid-cols-2 gap-2 mt-4">
        ${Object.entries(porPago).map(([k, v]) => `<div class="bg-slate-50 rounded-lg p-3">
          <div class="text-[10px] uppercase text-slate-400">${esc(k)}</div>
          <div class="text-sm font-bold">${money(v)}</div></div>`).join("") || `<p class="text-xs text-slate-400">Sin ventas hoy</p>`}
      </div>
      <div class="mt-4 space-y-3">
        ${input("Monto final contado", { id: "montoFinal", type: "number", step: "0.01", value: String(esperado.toFixed(2)) })}
        ${input("Observaciones", { id: "obsCierre", placeholder: "Diferencias,Novelades…" })}
        ${btn("Cerrar caja", "bg-red-600 text-white", `id="btnCerrarCaja" style="width:100%"`)}
      </div>`)
    : seccion("Apertura de caja", `
      <div class="text-center py-3 text-sm text-slate-500">No hay caja abierta</div>
      <div class="space-y-3">
        ${input("Monto inicial", { id: "montoInicial", type: "number", step: "0.01", placeholder: "0.00" })}
        ${input("Observaciones", { id: "obsApertura", placeholder: "Opcional" })}
        ${btn("Abrir caja", "bg-emerald-600 text-white", `id="btnAbrirCaja" style="width:100%"`)}
      </div>`)}

    ${seccion("Historial de cierres", tabla([
      { t: "Apertura", v: (a) => fechaHora(a.fecha_apertura) },
      { t: "Cierre", v: (a) => (a.fecha_cierre ? fechaHora(a.fecha_cierre) : "—") },
      { t: "Inicial", der: 1, v: (a) => money(a.monto_inicial) },
      { t: "Final", der: 1, v: (a) => `<span class="font-semibold">${a.monto_final != null ? money(a.monto_final) : "—"}</span>` },
      { t: "Estado", v: (a) => `<span class="text-[10px] px-2 py-0.5 rounded-full ${Number(a.activo) === 1 ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"}">${Number(a.activo) === 1 ? "Abierta" : "Cerrada"}</span>` },
    ], [...state.apertura_caja].sort((a, b) => new Date(b.fecha_apertura) - new Date(a.fecha_apertura)).slice(0, 10), { vacio: "Sin aperturas registradas" }))}
  </div>`;
}

/* ============ FLUJO DE CAJA ============ */
function panelFlujo() {
  const k = kpis();
  const abierta = state.caja_flujo.find((c) => c.estado === "ABIERTA");
  const gastos = [...state.gastos].sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  const totalGastos = gastos.reduce((s, g) => s + Number(g.monto || 0), 0);
  return `
  <div class="space-y-4">
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
      <div class="bg-white rounded-xl border border-slate-200 p-4"><div class="text-[10px] uppercase text-slate-400">Ingresos mes</div><div class="text-xl font-bold text-emerald-600">${money(k.mesTotal)}</div></div>
      <div class="bg-white rounded-xl border border-slate-200 p-4"><div class="text-[10px] uppercase text-slate-400">Egresos mes</div><div class="text-xl font-bold text-red-600">${money(k.comprasMes + k.gastosMes)}</div></div>
      <div class="bg-white rounded-xl border border-slate-200 p-4"><div class="text-[10px] uppercase text-slate-400">Gastos registrados</div><div class="text-xl font-bold text-orange-600">${money(totalGastos)}</div></div>
      <div class="bg-white rounded-xl border border-slate-200 p-4"><div class="text-[10px] uppercase text-slate-400">Flujo neto</div><div class="text-xl font-bold ${k.utilidadMes >= 0 ? "text-[#1e3c72]" : "text-red-600"}">${money(k.utilidadMes)}</div></div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      ${abierta ? seccion("Flujo abierto", `
        <div class="grid grid-cols-2 gap-3 text-center">
          <div class="bg-slate-50 rounded-xl p-4"><div class="text-[10px] text-slate-400">Apertura</div><div class="text-xl font-bold">${money(abierta.monto_apertura)}</div></div>
          <div class="bg-slate-50 rounded-xl p-4"><div class="text-[10px] text-slate-400">Cierre esperado</div><div class="text-xl font-bold text-[#1e3c72]">${money(Number(abierta.monto_apertura) + k.mesTotal - k.gastosMes)}</div></div>
        </div>
        <div class="mt-4 space-y-3">
          ${input("Monto de cierre", { id: "cierreFlujo", type: "number", step: "0.01" })}
          ${btn("Cerrar flujo de caja", "bg-red-600 text-white", `id="btnCerrarFlujo" style="width:100%"`)}
        </div>`)
      : seccion("Abrir flujo de caja", `
        <p class="text-sm text-slate-500 mb-3">Registra el fondo con el que inicia el turno.</p>
        ${input("Monto de apertura", { id: "aperturaFlujo", type: "number", step: "0.01", placeholder: "0.00" })}
        ${btn("Abrir flujo", "bg-emerald-600 text-white", `id="btnAbrirFlujo" style="width:100%;margin-top:12px"`)}
        `)}

      ${seccion("Registrar gasto", `
        <div class="space-y-3">
          ${input("Descripción", { id: "gastoDesc", placeholder: "Ej: transporte, servicios…" })}
          <div class="grid grid-cols-2 gap-3">
            ${input("Monto (Bs)", { id: "gastoMonto", type: "number", step: "0.01", placeholder: "0.00" })}
            ${select("Categoría", [{ v: "Operativo", t: "Operativo" }, { v: "Personal", t: "Personal" }, { v: "Servicios", t: "Servicios" }, { v: "Impuesto", t: "Impuesto" }], { id: "gastoCat" })}
          </div>
          ${btn("Registrar gasto", "bg-orange-600 text-white", `id="btnGasto" style="width:100%"`)}
        </div>`)}
    </div>

    ${seccion("Gastos registrados", tabla([
      { t: "Fecha", v: (g) => `<span class="text-xs">${fecha(g.fecha)}</span>` },
      { t: "Descripción", v: (g) => esc(g.descripcion) },
      { t: "Usuario", v: (g) => `<span class="text-xs text-slate-500">${esc(state.usuarios.find((u) => u.id === g.id_usuario)?.nombre || "—")}</span>` },
      { t: "Monto", der: 1, v: (g) => `<span class="font-bold text-red-600">${money(g.monto)}</span>` },
    ], gastos, { vacio: "Sin gastos registrados" }))}
  </div>`;
}

/* ============ DEVOLUCIONES ============ */
function panelDevoluciones() {
  const lista = [...state.devoluciones].sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  const total = lista.reduce((s, d) => s + Number(d.total_devuelto || 0), 0);
  return `
  <div class="space-y-4">
    <div class="grid grid-cols-2 gap-3">
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Devoluciones</div>
        <div class="text-xl font-bold text-[#1e3c72]">${num(lista.length)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Monto devuelto</div>
        <div class="text-xl font-bold text-red-600">${money(total)}</div>
      </div>
    </div>
    ${seccion("Historial de devoluciones", tabla([
      { t: "Devolución", v: (d) => `<span class="font-bold">#${d.id_devolucion}</span>` },
      { t: "Venta", v: (d) => `<span class="text-xs">#${d.id_venta}</span>` },
      { t: "Fecha", v: (d) => `<span class="text-xs">${fechaHora(d.fecha)}</span>` },
      { t: "Motivo", v: (d) => `<span class="text-xs text-slate-500">${esc(d.motivo || "—")}</span>` },
      { t: "Usuario", v: (d) => `<span class="text-xs text-slate-400">${esc(state.usuarios.find((u) => u.id === d.id_usuario)?.nombre || "—")}</span>` },
      { t: "Total", der: 1, v: (d) => `<span class="font-bold text-red-600">${money(d.total_devuelto)}</span>` },
      { t: "", der: 1, v: (d) => `<button data-verdev="${d.id_devolucion}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Detalle</button>` },
    ], lista, { vacio: "Sin devoluciones registradas" }))}
  </div>`;
}

function verDevolucion(id) {
  const d = state.devoluciones.find((x) => x.id_devolucion === id);
  const lineas = state.detalle_devoluciones.filter((x) => x.id_devolucion === id);
  modal({
    titulo: `Devolución #${id}`, ancho: "max-w-md",
    cuerpo: `
      <div class="text-sm space-y-1 mb-4">
        <div class="flex justify-between"><span class="text-slate-500">Venta</span><b>#${d?.id_venta}</b></div>
        <div class="flex justify-between"><span class="text-slate-500">Fecha</span><b>${fechaHora(d?.fecha)}</b></div>
        <div class="flex justify-between"><span class="text-slate-500">Motivo</span><b>${esc(d?.motivo || "—")}</b></div>
      </div>
      ${tabla([
        { t: "Producto", v: (l) => esc(nombreDe(l.id_producto)) },
        { t: "Cant", der: 1, v: (l) => l.cantidad },
        { t: "Subtotal", der: 1, v: (l) => `<b>${money(l.subtotal)}</b>` },
      ], lineas)}
      <div class="flex justify-between text-base font-bold border-t-2 border-slate-800 pt-2 mt-2"><span>TOTAL</span><span>${money(d?.total_devuelto)}</span></div>`,
    acciones: [{ texto: "Cerrar", clase: "bg-slate-200 text-slate-700", fn: () => true }],
  });
}

function nombreDe(id) {
  return mapaProductos().get(id)?.nombre_producto || `#${id}`;
}

function modalDevolucion(ventaId) {
  const lineas = state.detalle_ventas.filter((d) => d.venta_id === ventaId);
  modal({
    titulo: `Devolver productos de la venta #${ventaId}`, ancho: "max-w-lg",
    cuerpo: `
      <div class="space-y-2">
        ${lineas.map((l, i) => `
          <label class="flex items-center gap-3 px-3 py-2 rounded-lg border border-slate-200">
            <input type="checkbox" data-devchk="${i}" class="w-4 h-4 accent-[#2a5298]" />
            <span class="grow text-sm">${esc(nombreDe(l.producto_id))}</span>
            <span class="text-xs text-slate-400">vendidos ${l.cantidad}</span>
            <input type="number" data-devcant="${i}" value="${l.cantidad}" min="1" max="${l.cantidad}"
              class="w-16 px-2 py-1.5 border border-slate-300 rounded-lg text-sm text-right" />
          </label>`).join("")}
      </div>
      <div class="mt-3">${input("Motivo", { id: "motivoDev", placeholder: "Producto defectuoso, cambio…" })}</div>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Registrar devolución", clase: "bg-red-600 text-white",
        fn: async (w) => {
          const sel = [];
          lineas.forEach((l, i) => {
            if (!w.querySelector(`[data-devchk="${i}"]`).checked) return;
            const cant = Number(w.querySelector(`[data-devcant="${i}"]`).value || 0);
            if (cant > 0) sel.push({ productoId: l.producto_id, cantidad: cant, precio_unitario: l.precio });
          });
          if (!sel.length) return false;
          const dev = await repo.devolverVenta({ ventaId, lineas: sel, motivo: w.querySelector("#motivoDev").value, idUsuario: _ctx?.perfil?.usuarioId });
          toast(`Devolución #${dev.id_devolucion} registrada`);
          await _ctx?.recargar(); _ctx?.rerender();
          return true;
        },
      },
    ],
  });
}

/* ============ AJUSTES (impresora + QR) ============ */
const CLAVE_QR = "lsm.qr";
function configQR() {
  try { return JSON.parse(localStorage.getItem(CLAVE_QR)) || {}; } catch { return {}; }
}
function guardarQR(d) {
  localStorage.setItem(CLAVE_QR, JSON.stringify(d));
  toast("Ajustes de QR guardados");
}
function urlQR(d) {
  const dato = d.payload || "libreriasanmartin";
  return `https://api.qrserver.com/v1/create-qr-code/?size=220x220&data=${encodeURIComponent(dato)}`;
}

function panelAjustes() {
  const cfg = state.config_impresora[0] || {};
  const qr = configQR();
  return `
  <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
    ${seccion("Impresión de tickets", `
      <div class="space-y-3">
        ${select("Ancho de papel", [
          { v: 58, t: "58 mm (bobina)" }, { v: 80, t: "80 mm (bobina)" }, { v: 80, t: "A4" },
        ], { id: "impTipo", value: cfg.tipo || 80 })}
        <div class="grid grid-cols-2 gap-3">
          ${input("Ancho (mm)", { id: "impAncho", type: "number", value: cfg.ancho || 80 })}
          ${select("Charset", [{ v: "UTF-8", t: "UTF-8" }, { v: "ISO-8859-1", t: "ISO-8859-1" }], { id: "impCharset", value: cfg.charset || "UTF-8" })}
        </div>
        ${btn("Guardar configuración", "bg-[#1e3c72] text-white", `id="btnGuardarImpresora" style="width:100%"`)}
      </div>`)}

    ${seccion("Código QR de cobro", `
      <div class="space-y-3">
        <div class="flex gap-4 items-center">
          <img src="${urlQR(qr)}" alt="QR" class="w-32 h-32 border border-slate-200 rounded-lg" />
          <p class="text-[11px] text-slate-500 grow">Se muestra en el POS al cobrar por QR y como comprobante en el recibo cuando el pago fue QR/Transferencia.</p>
        </div>
        ${input("Nombre del negocio", { id: "qrNombre", value: esc(qr.nombre || "Librería San Martín") })}
        ${input("Contenido / URL del QR", { id: "qrPayload", value: esc(qr.payload || ""), placeholder: "https://… o texto para el QR" })}
        <label class="flex items-center gap-2 text-xs text-slate-600">
          <input type="checkbox" id="qrActivo" class="w-4 h-4 accent-[#2a5298]" ${qr.activo !== false ? "checked" : ""} />
          Mostrar el QR en el ticket
        </label>
        ${btn("Guardar QR", "bg-emerald-600 text-white", `id="btnGuardarQR" style="width:100%"`)}
      </div>`)}
  </div>`;
}

/* ============ montaje ============ */
function refrescarPanel() {
  const p = $("#panel");
  if (p) p.innerHTML = panel();
  wirePanel();
}

let _ctx = null;

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", async (e) => {
    const t = e.target.closest("[data-tab]");
    if (t) { tab = t.dataset.tab; ctx.rerender(); return; }

    const pago = e.target.closest("[data-pago]");
    if (pago) { metodoPago = pago.dataset.pago; refrescarPanel(); return; }

    const add = e.target.closest("[data-add]");
    if (add) return agregar(+add.dataset.add);

    const cant = e.target.closest("[data-cant]");
    if (cant) {
      const id = +cant.dataset.cant, d = +cant.dataset.delta;
      const linea = carrito.find((l) => l.productoId === id);
      const p = mapaProductos().get(id);
      if (!linea || !p) return;
      if (linea.cantidad + d > Number(p.stock)) return toast(`Stock máximo ${p.stock}`, "warn");
      linea.cantidad += d;
      if (linea.cantidad <= 0) carrito = carrito.filter((l) => l.productoId !== id);
      return refrescarPanel();
    }

    const quitar = e.target.closest("[data-quitar]");
    if (quitar) { carrito = carrito.filter((l) => l.productoId !== +quitar.dataset.quitar); return refrescarPanel(); }

    if (e.target.closest("#btnLimpiar")) { carrito = []; return refrescarPanel(); }

    if (e.target.closest("#btnVender")) {
      if (!carrito.length) return toast("Agrega productos al carrito", "warn");
      try {
        const r = await repo.registrarVenta({
          clienteId: +$("#clienteVenta").value || null,
          metodoPago,
          lineas: carrito,
          idUsuario: ctx.perfil.usuarioId,
        });
        carrito = [];
        toast(`Venta #${r.venta.id_venta} registrada · ${money(r.total)}`);
        await ctx.recargar();
        verRecibo(r.venta.id_venta);
        ctx.ir("ventas");
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    const rec = e.target.closest("[data-recibo]");
    if (rec) return verRecibo(+rec.dataset.recibo);

    const vdev = e.target.closest("[data-verdev]");
    if (vdev) return verDevolucion(+vdev.dataset.verdev);

    const rdev = e.target.closest("[data-devolver]");
    if (rdev) return modalDevolucion(+rdev.dataset.devolver);

    if (e.target.closest("#btnGuardarImpresora")) {
      try {
        await repo.guardarConfigImpresora({
          id_usuario: ctx.perfil.usuarioId,
          tipo: Number($("#impTipo").value || 80),
          ancho: Number($("#impAncho").value || 80),
          charset: $("#impCharset").value,
        });
        toast("Configuración de impresora guardada");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    if (e.target.closest("#btnGuardarQR")) {
      guardarQR({
        nombre: $("#qrNombre").value.trim(),
        payload: $("#qrPayload").value.trim(),
        activo: $("#qrActivo").checked,
      });
      ctx.rerender();
      return;
    }

    const anu = e.target.closest("[data-anular]");
    if (anu) {
      if (!(await confirmar("Se devolverá el stock al inventario y la venta quedará marcada como Anulado. ¿Continuar?", "Anular venta"))) return;
      try {
        await repo.anularVenta(+anu.dataset.anular, ctx.perfil.usuarioId);
        toast("Venta anulada y stock devuelto");
        await ctx.recargar();
        ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    if (e.target.closest("#btnAbrirCaja")) {
      try {
        await repo.abrirCaja({
          montoInicial: Number($("#montoInicial").value || 0),
          idUsuario: ctx.perfil.usuarioId,
          observaciones: $("#obsApertura").value,
        });
        toast("Caja abierta");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }
    if (e.target.closest("#btnCerrarCaja")) {
      try {
        await repo.cerrarCaja({
          montoFinal: Number($("#montoFinal").value || 0),
          idUsuario: ctx.perfil.usuarioId,
          observaciones: $("#obsCierre").value,
        });
        toast("Caja cerrada");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }
    if (e.target.closest("#btnAbrirFlujo")) {
      try {
        await repo.crearFlujoCaja({ montoApertura: Number($("#aperturaFlujo").value || 0), idUsuario: ctx.perfil.usuarioId });
        toast("Flujo de caja abierto");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }
    if (e.target.closest("#btnCerrarFlujo")) {
      const abierta = state.caja_flujo.find((c) => c.estado === "ABIERTA");
      try {
        await repo.cerrarFlujoCaja({ id: abierta.id_caja, montoCierre: Number($("#cierreFlujo").value || 0) });
        toast("Flujo cerrado");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }
    if (e.target.closest("#btnGasto")) {
      try {
        await repo.crearGasto({
          descripcion: $("#gastoDesc").value, monto: Number($("#gastoMonto").value || 0),
          categoria: $("#gastoCat").value, idUsuario: ctx.perfil.usuarioId,
        });
        toast("Gasto registrado");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
    }
  });

  root.addEventListener("input", (e) => {
    if (e.target.id === "buscarProd") {
      filtroProd = e.target.value;
      pintarProductos();
    }
  });

  root.addEventListener("keydown", (e) => {
    if (e.target.id === "buscarProd" && e.key === "Enter") {
      e.preventDefault();
      const q = e.target.value.trim().toLowerCase();
      const activos = state.productos.filter((x) => Number(x.activo) === 1 && Number(x.stock) > 0);
      const p = activos.find((x) => String(x.codigo || "").toLowerCase() === q)
        || activos.find((x) => x.nombre_producto.toLowerCase().includes(q));
      if (p) {
        agregar(p.id_producto);
        filtroProd = "";
        const inp = $("#buscarProd");
        if (inp) inp.value = "";
        pintarProductos();
      }
      else toast("Producto no encontrado", "warn");
    }
    if (e.target.id === "filtroVentas") {
      filtroHistorial = e.target.value;
      const sel = e.target.selectionStart;
      refrescarPanel();
      const nuevo = $("#filtroVentas");
      if (nuevo) { nuevo.focus(); nuevo.setSelectionRange(sel, sel); }
    }
  });

  wirePanel();
}

function wirePanel() {
  const b = $('[data-addmode]');
  if (b) b.onclick = () => {
    const codigo = prompt("Código del producto:");
    if (!codigo) return;
    const p = state.productos.find((x) => String(x.codigo).toLowerCase() === codigo.trim().toLowerCase());
    if (p) agregar(p.id_producto);
    else toast("Código no encontrado", "warn");
  };
}
