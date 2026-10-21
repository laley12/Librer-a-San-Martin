import { money, num, fecha, fechaHora } from "../supabase-client.js";
import { state, repo, kpis, mapaProductos, ventasVigentes } from "../data.js";
import { $, $$, esc, toast, modal, tabla, seccion, input, select, btn, badgeStock } from "../ui.js";

export const meta = { id: "ventas", titulo: "Punto de Venta", icono: "🧾", grupo: "Operación" };

let tab = "pos";
let carrito = [];
let filtroHistorial = "";
let filtroProd = "";
let metodoPago = "Efectivo";
let pagaCon = 0;

export function abrir(params = {}) {
  if (params.tab) tab = params.tab;
  if (params.limpiar) { carrito = []; pagaCon = 0; }
}

export function render() {
  return `
  <div class="fade space-y-4">
    <div class="flex gap-2 overflow-x-auto pb-1">
      ${[["pos", "🛒 Punto de venta"], ["historial", "📋 Historial"], ["ajustes", "⚙️ Ajustes"]]
        .map(([k, t]) => `<button data-tab="${k}" class="tab shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold ${tab === k ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
    </div>
    <div id="panel">${panel()}</div>
  </div>`;
}

function panel() {
  if (tab === "pos") return panelPOS();
  if (tab === "historial") return panelHistorial();
  return panelAjustes();
}

/* ============ POS ============ */
function cmpFiltro(p) {
  const q = filtroProd.trim().toLowerCase();
  if (!q) return true;
  return p.nombre.toLowerCase().includes(q) || String(p.codigo || "").toLowerCase().includes(q);
}

function tarjetasProducto(lista) {
  return [...lista].sort((a, b) => a.nombre.localeCompare(b.nombre)).map((p) => `
    <button data-add="${p.id}" class="w-full flex items-center justify-between gap-3 p-3 md:p-3.5 rounded-xl border-2 border-slate-100 hover:border-[#1e3c72] hover:bg-blue-50/40 text-left active:scale-[0.98] transition-all bg-white shadow-xs">
      <span class="min-w-0">
        <span class="block text-sm md:text-base font-bold text-slate-900 leading-snug">${esc(p.nombre)}</span>
        <span class="block font-mono text-[11px] text-slate-400 mt-0.5">${esc(p.codigo ? '#' + p.codigo : '')}</span>
      </span>
      <span class="text-right shrink-0">
        <span class="block text-base md:text-lg font-black text-[#1e3c72]">${money(p.precio_venta)}</span>
        <span class="inline-block text-[11px] font-bold px-2 py-0.5 rounded-md mt-0.5 ${Number(p.stock) <= 5 ? "bg-amber-100 text-amber-800" : "bg-slate-100 text-slate-600"}">${Number(p.stock) <= 5 ? `⚠️ Stock: ${p.stock}` : `Stock: ${p.stock}`}</span>
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
        <datalist id="listaProd">${visibles.map((p) => `<option value="${esc(p.nombre)} — ${esc(p.codigo || "")}">`).join("")}</datalist>
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
        <div id="carrito" class="grow overflow-y-auto max-h-[36vh] lg:max-h-[50vh] divide-y divide-slate-100">
          ${carrito.length ? carrito.map((l) => `
            <div class="px-4 py-3.5 flex items-center justify-between gap-2 bg-white">
              <div class="min-w-0">
                <div class="text-sm font-bold text-slate-900 truncate">${esc(l.nombre)}</div>
                <div class="text-xs text-slate-500 font-medium">${money(l.precio)} cada uno</div>
              </div>
              <div class="flex items-center gap-2 shrink-0">
                <button data-cant="${l.productoId}" data-delta="-1" class="w-10 h-10 rounded-xl bg-slate-100 hover:bg-slate-200 text-slate-800 text-xl font-black grid place-items-center active:scale-95 border border-slate-200" title="Restar">−</button>
                <span class="w-7 text-center text-base font-black text-slate-900">${l.cantidad}</span>
                <button data-cant="${l.productoId}" data-delta="1" class="w-10 h-10 rounded-xl bg-[#1e3c72] hover:bg-[#2a5298] text-white text-xl font-black grid place-items-center active:scale-95 shadow-sm" title="Sumar">+</button>
                <span class="w-20 text-right text-base font-black text-[#1e3c72]">${money(l.cantidad * l.precio)}</span>
                <button data-quitar="${l.productoId}" class="w-8 h-8 rounded-lg bg-rose-50 text-rose-600 hover:bg-rose-100 text-lg font-bold flex items-center justify-center transition" aria-label="Quitar">×</button>
              </div>
            </div>`).join("") : `<div class="text-center py-12 px-4"><span class="text-4xl block mb-2">🛒</span><p class="text-sm font-bold text-slate-700">Carrito vacío</p><p class="text-xs text-slate-400 mt-1">Toca cualquier producto de la izquierda para agregarlo a la venta</p></div>`}
        </div>
        <div class="px-4 py-3.5 border-t border-slate-100 space-y-3.5">
          <div class="flex justify-between items-baseline p-2.5 bg-slate-50 rounded-xl border border-slate-100">
            <span class="text-sm font-bold text-slate-600 uppercase tracking-wide">Total a cobrar</span>
            <span class="text-3xl md:text-4xl font-black tracking-tight text-[#1e3c72]">${money(total)}</span>
          </div>
          <div>
            <div class="text-xs uppercase tracking-wide text-slate-500 font-bold mb-2">Método de pago</div>
            <div class="grid grid-cols-2 gap-2.5">
              ${[["Efectivo", "💵 Efectivo"], ["QR / Transferencia", "📱 Cobro con QR"]].map(([m, label]) => `
                <button data-pago="${m}" class="py-3 px-2 rounded-xl text-xs md:text-sm font-bold flex items-center justify-center gap-2 transition active:scale-[0.97] ${metodoPago === m ? "bg-[#1e3c72] text-white shadow-md border-2 border-[#1e3c72]" : "bg-white text-slate-700 border-2 border-slate-200 hover:border-slate-300"}">
                  ${label}
                </button>`).join("")}
            </div>
          </div>
          ${metodoPago === "Efectivo" && total > 0 ? `
          <div class="p-3.5 bg-amber-50/90 border-2 border-amber-200 rounded-2xl space-y-2.5">
            <div class="flex items-center justify-between">
              <span class="text-xs font-bold text-amber-950">💵 ¿Con cuánto paga el cliente?</span>
              <input id="inputPagaCon" type="number" inputmode="decimal" placeholder="Bs…" value="${pagaCon || ''}"
                class="w-28 px-2.5 py-1.5 text-right text-sm font-bold border-2 border-amber-300 rounded-lg outline-none focus:ring-2 focus:ring-amber-500 bg-white" />
            </div>
            <div class="flex items-center gap-1.5 flex-wrap">
              <button data-rapido="${total}" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white text-amber-900 border border-amber-300 hover:bg-amber-100 active:scale-95">Exacto</button>
              ${[10, 20, 50, 100, 200].filter(b => b > total).slice(0, 4).map(b => `
                <button data-rapido="${b}" class="px-2.5 py-1 rounded-lg text-xs font-bold bg-white text-amber-900 border border-amber-300 hover:bg-amber-100 active:scale-95">Bs ${b}</button>
              `).join("")}
            </div>
            <div id="boxVuelto">
              ${pagaCon >= total ? `
                <div class="pt-2 border-t border-amber-200 flex items-center justify-between">
                  <span class="text-xs font-bold text-emerald-900">💵 Vuelto a entregar:</span>
                  <span class="text-xl font-black text-emerald-700 font-mono">${money(pagaCon - total)}</span>
                </div>
              ` : (pagaCon > 0 ? `
                <div class="pt-2 border-t border-amber-200 text-xs font-bold text-amber-800">
                  ⚠️ Faltan: ${money(total - pagaCon)}
                </div>
              ` : '')}
            </div>
          </div>` : ''}
          ${esQR ? (qr.activo !== false ? `
          <div class="rounded-2xl border-2 border-emerald-300 bg-emerald-50/70 p-3.5 text-center space-y-1">
            <img src="${urlQR(qr)}" alt="Código QR de cobro" class="w-36 h-36 mx-auto bg-white p-1.5 rounded-xl border border-slate-200 shadow-sm" />
            <p class="text-xs font-bold text-emerald-800 mt-2">${esc(qr.nombre || "Librería San Martín")}</p>
            <p class="text-[11px] text-slate-500">Muestra este QR al cliente para pagar</p>
          </div>` : `<p class="text-xs text-amber-700 bg-amber-50 border border-amber-200 rounded-xl px-3 py-2 font-medium">QR desactivado · actívalo en Ajustes → Código QR de cobro.</p>`) : ""}
          <div>
            <div class="text-xs uppercase tracking-wide text-slate-500 font-bold mb-1.5">Cliente (opcional)</div>
            <input id="clienteVenta" type="text" placeholder="Cliente general"
              class="w-full px-3 py-2.5 border border-slate-300 rounded-xl text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
          </div>
          <button id="btnVender" class="w-full py-4 rounded-2xl bg-emerald-600 hover:bg-emerald-700 text-white font-black text-base md:text-lg shadow-lg shadow-emerald-700/25 active:scale-[0.98] transition-all">
            Confirmar venta ${carrito.length ? `· ${money(total)}` : ""}
          </button>
          ${carrito.length ? `<button id="btnLimpiar" class="w-full text-xs text-slate-400 hover:text-red-500 font-medium">Vaciar carrito</button>` : ""}
        </div>
      </div>
    </div>
  </div>`;
}

function agregar(productoId, cantidad = 1) {
  const p = mapaProductos().get(String(productoId));
  if (!p) return;
  const linea = carrito.find((l) => l.productoId === p.id);
  const enCarrito = (linea?.cantidad || 0);
  if (Number(p.stock) <= 0) return toast("Producto agotado", "warn");
  if (enCarrito + cantidad > Number(p.stock)) return toast(`Solo hay ${p.stock} unidades`, "warn");
  if (linea) linea.cantidad += cantidad;
  else carrito.push({ productoId: p.id, nombre: p.nombre, precio: Number(p.precio_venta), cantidad });
  refrescarPanel();
}

/* ============ HISTORIAL ============ */
function panelHistorial() {
  const q = filtroHistorial.toLowerCase();
  const filas = [...state.ventas]
    .filter((v) => !q || String(v.id).includes(q) || String(v.metodo_pago || "").toLowerCase().includes(q) ||
      String(v.cliente || "").toLowerCase().includes(q))
    .sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
  return seccion("Historial de ventas", `
    <input id="filtroVentas" value="${esc(filtroHistorial)}" placeholder="Filtrar por número, pago o cliente…"
      class="w-full px-3 py-2.5 mb-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
    ${tabla([
      { t: "Venta", v: (v) => `<span class="font-bold">#${v.id}</span>` },
      { t: "Fecha", v: (v) => `<span class="text-xs">${fecha(v.fecha)}</span>` },
      { t: "Cliente", v: (v) => esc(v.cliente || "General") },
      { t: "Pago", v: (v) => `<span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-100">${esc(v.metodo_pago || "—")}</span>` },
      { t: "Total", der: 1, v: (v) => `<span class="font-bold text-emerald-600">${money(v.total)}</span>` },
      { t: "", der: 1, v: (v) => `<div class="flex gap-1 justify-end">
          <button data-recibo="${v.id}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Recibo</button>
        </div>` },
    ], filas, { vacio: "Sin ventas registradas" })}`,
    `<button data-export="ventas" class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar CSV</button>`);
}

function verRecibo(ventaId) {
  const v = state.ventas.find((x) => String(x.id) === String(ventaId));
  if (!v) return;
  const lineas = state.detalle_ventas.filter((d) => String(d.venta_id) === String(ventaId));
  const numero = `R-${String(v.id).padStart(6, "0")}`;
  modal({
    titulo: `Recibo ${numero}`, ancho: "max-w-md",
    cuerpo: `
      <div class="text-center border-b border-dashed border-slate-300 pb-4 mb-4">
        <div class="text-lg font-bold text-[#1e3c72]">📚 Librería San Martín</div>
        <div class="text-xs text-slate-500">Venta #${v.id} · ${fechaHora(v.fecha)}</div>
      </div>
      <div class="text-sm space-y-1 mb-4">
        <div class="flex justify-between"><span class="text-slate-500">Cliente</span><span class="font-semibold">${esc(v.cliente || "General")}</span></div>
        <div class="flex justify-between"><span class="text-slate-500">Pago</span><span>${esc(v.metodo_pago || "—")}</span></div>
      </div>
      <table class="w-full text-xs mb-3">
        <thead class="text-slate-400 text-[10px] uppercase"><tr><th class="text-left py-1">Producto</th><th class="text-right">Cant</th><th class="text-right">Importe</th></tr></thead>
        <tbody>${lineas.map((l) => `<tr class="border-t border-slate-100">
          <td class="py-1.5">${esc(nombre(l.producto_id))}</td>
          <td class="text-right">${l.cantidad}</td>
          <td class="text-right font-semibold">${money(l.cantidad * l.precio_unitario)}</td></tr>`).join("")}</tbody>
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
    return state.productos.find((p) => String(p.id) === String(id))?.nombre || `#${id}`;
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

/* ============ AJUSTES (QR de cobro) ============ */
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
  const qr = configQR();
  return `
  <div class="grid grid-cols-1 gap-4">
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

    const rapido = e.target.closest("[data-rapido]");
    if (rapido) {
      pagaCon = +rapido.dataset.rapido;
      refrescarPanel();
      return;
    }

    const pago = e.target.closest("[data-pago]");
    if (pago) { metodoPago = pago.dataset.pago; refrescarPanel(); return; }

    const add = e.target.closest("[data-add]");
    if (add) return agregar(add.dataset.add);

    const cant = e.target.closest("[data-cant]");
    if (cant) {
      const id = cant.dataset.cant, d = +cant.dataset.delta;
      const linea = carrito.find((l) => l.productoId === id);
      const p = mapaProductos().get(id);
      if (!linea || !p) return;
      if (linea.cantidad + d > Number(p.stock)) return toast(`Stock máximo ${p.stock}`, "warn");
      linea.cantidad += d;
      if (linea.cantidad <= 0) carrito = carrito.filter((l) => l.productoId !== id);
      return refrescarPanel();
    }

    const quitar = e.target.closest("[data-quitar]");
    if (quitar) { carrito = carrito.filter((l) => l.productoId !== quitar.dataset.quitar); return refrescarPanel(); }

    if (e.target.closest("#btnLimpiar")) { carrito = []; pagaCon = 0; return refrescarPanel(); }

    if (e.target.closest("#btnVender")) {
      if (!carrito.length) return toast("Agrega productos al carrito", "warn");
      try {
        const r = await repo.registrarVenta({
          cliente: $("#clienteVenta").value,
          metodoPago,
          lineas: carrito,
          idUsuario: ctx.perfil.usuarioId,
        });
        carrito = [];
        pagaCon = 0;
        toast(`Venta #${r.venta.id} registrada · ${money(r.total)}`);
        await ctx.recargar();
        verRecibo(r.venta.id);
        ctx.ir("ventas");
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    const rec = e.target.closest("[data-recibo]");
    if (rec) return verRecibo(rec.dataset.recibo);

    if (e.target.closest("#btnGuardarQR")) {
      guardarQR({
        nombre: $("#qrNombre").value.trim(),
        payload: $("#qrPayload").value.trim(),
        activo: $("#qrActivo").checked,
      });
      ctx.rerender();
      return;
    }
  });

  root.addEventListener("input", (e) => {
    if (e.target.id === "inputPagaCon") {
      pagaCon = parseFloat(e.target.value) || 0;
      const total = carrito.reduce((s, l) => s + l.cantidad * l.precio, 0);
      const vEl = $("#boxVuelto");
      if (vEl) {
        if (pagaCon >= total) {
          vEl.innerHTML = `<div class="pt-2 border-t border-amber-200 flex items-center justify-between"><span class="text-xs font-bold text-emerald-900">💵 Vuelto a entregar:</span><span class="text-xl font-black text-emerald-700 font-mono">${money(pagaCon - total)}</span></div>`;
        } else if (pagaCon > 0) {
          vEl.innerHTML = `<div class="pt-2 border-t border-amber-200 text-xs font-bold text-amber-800">⚠️ Faltan: ${money(total - pagaCon)}</div>`;
        } else {
          vEl.innerHTML = ``;
        }
      }
    }
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
        || activos.find((x) => x.nombre.toLowerCase().includes(q));
      if (p) {
        agregar(p.id);
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
    if (p) agregar(p.id);
    else toast("Código no encontrado", "warn");
  };
}