import { money, moneyCorto, num, fecha } from "../supabase-client.js";
import { state, kpis, serie, topProductos, topProveedores, topClientes, ventasVigentes } from "../data.js";
import { esc, tabla, seccion, barras, exportarCSV, kpiCard } from "../ui.js";

export const meta = { id: "reportes", titulo: "Reportes Analíticos", icono: "📈", grupo: "Control" };

let rango = 30;
let bloque = "ventas";

const RANGOS = [[7, "7 días"], [30, "30 días"], [90, "90 días"], [365, "12 meses"]];

export function render() {
  const k = kpis();
  const s = serie(rango);
  const max = Math.max(...s.map((x) => x.ventas), 1);
  return `
  <div class="fade space-y-4">
    <div class="flex gap-2 flex-wrap items-center">
      ${RANGOS.map(([n, t]) => `<button data-rango="${n}" class="px-3 py-1.5 rounded-lg text-xs font-semibold ${rango === n ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
      <span class="grow"></span>
      <button data-export class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar serie CSV</button>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
      ${kpiCard({ label: "Ventas del mes", valor: money(k.mesTotal), sub: `${k.mesCount} ventas`, icono: "💰", color: "text-emerald-600", compacto: true })}
      ${kpiCard({ label: "Margen bruto", valor: money(k.margen), sub: `${k.mesTotal ? Math.round((k.margen / k.mesTotal) * 100) : 0}% sobre venta`, icono: "🧮", color: "text-sky-600", compacto: true })}
      ${kpiCard({ label: "Compras del mes", valor: money(k.comprasMes), sub: `${k.comprasMesCount} compras`, icono: "🛒", color: "text-orange-600", compacto: true })}
      ${kpiCard({ label: "Utilidad neta", valor: money(k.utilidadMes), sub: `gastos ${money(k.gastosMes)}`, icono: "🏦", color: k.utilidadMes >= 0 ? "text-violet-600" : "text-red-600", compacto: true })}
    </div>

    ${seccion(`Ventas vs compras · últimos ${RANGOS.find(([n]) => n === rango)[1]}`, barras(s.map((x) => ({
      etiqueta: rango > 90 ? fecha(x.fecha).slice(0, 5) : fecha(x.fecha).slice(0, 5),
      v: x.ventas,
      compras: x.compras,
    })), max, (v) => moneyCorto(v)), `<span class="text-[10px] text-slate-400">máx ${moneyCorto(max)}</span>`)}

    <div class="flex gap-2 overflow-x-auto pb-1">
      ${[["ventas", "Ventas"], ["productos", "Productos"], ["clientes", "Clientes"], ["proveedores", "Proveedores"], ["inventario", "Inventario"]]
        .map(([k2, t]) => `<button data-bloque="${k2}" class="shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold ${bloque === k2 ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
    </div>

    <div>${panel()}</div>
  </div>`;
}

function panel() {
  const s = serie(rango);
  if (bloque === "productos") return panelProductos();
  if (bloque === "clientes") return panelClientes();
  if (bloque === "proveedores") return panelProveedores();
  if (bloque === "inventario") return panelInventario();
  return panelVentas(s);
}

function panelVentas(s) {
  const total = s.reduce((a, x) => a + x.ventas, 0);
  const compras = s.reduce((a, x) => a + x.compras, 0);
  const dias = s.filter((x) => x.ventas > 0).length;
  return seccion("Detalle diario", tabla([
    { t: "Fecha", v: (x) => fecha(x.fecha) },
    { t: "Ventas", der: 1, v: (x) => `<span class="font-semibold text-emerald-600">${money(x.ventas)}</span>` },
    { t: "Compras", der: 1, v: (x) => money(x.compras) },
    { t: "Diferencia", der: 1, v: (x) => `<span class="font-semibold ${x.ventas - x.compras >= 0 ? "text-[#1e3c72]" : "text-red-600"}">${money(x.ventas - x.compras)}</span>` },
  ], [...s].reverse(), { vacio: "Sin datos" }),
    `<span class="text-[10px] text-slate-400">total ${money(total)} · compras ${money(compras)} · promedio día con venta ${money(dias ? total / dias : 0)}</span>`);
}

function panelProductos() {
  const top = topProductos(50);
  const totalU = top.reduce((s, t) => s + t.unidades, 0);
  return seccion("Productos más vendidos", tabla([
    { t: "#", v: (_, i) => `<span class="font-bold text-slate-300">${i + 1}</span>` },
    { t: "Producto", v: (t) => `<span class="font-medium">${esc(t.nombre)}</span>` },
    { t: "Unidades", der: 1, v: (t) => `<span class="font-bold">${t.unidades}</span>` },
    { t: "Ingresos", der: 1, v: (t) => money(t.ingresos) },
    { t: "% del total", der: 1, v: (t) => `<span class="text-slate-500">${totalU ? Math.round((t.unidades / totalU) * 100) : 0}%</span>` },
  ], top, { vacio: "Sin ventas registradas" }));
}

function panelClientes() {
  return seccion("Clientes por facturación", tabla([
    { t: "#", v: (_, i) => `<span class="font-bold text-slate-300">${i + 1}</span>` },
    { t: "Cliente", v: (c) => `<span class="font-medium">${esc(c.nombre)}</span>` },
    { t: "Compras", der: 1, v: (c) => c.compras },
    { t: "Total", der: 1, v: (c) => `<span class="font-bold text-emerald-600">${money(c.total)}</span>` },
    { t: "Ticket prom.", der: 1, v: (c) => money(c.compras ? c.total / c.compras : 0) },
  ], topClientes(50), { vacio: "Sin ventas a clientes" }));
}

function panelProveedores() {
  const lista = topProveedores(100);
  const total = lista.reduce((s, p) => s + p.total, 0);
  return seccion("Proveedores por inversión", tabla([
    { t: "#", v: (_, i) => `<span class="font-bold text-slate-300">${i + 1}</span>` },
    { t: "Proveedor", v: (p) => `<span class="font-medium">${esc(p.nombre)}</span>` },
    { t: "Compras", der: 1, v: (p) => p.compras },
    { t: "Invertido", der: 1, v: (p) => `<span class="font-bold text-orange-600">${money(p.total)}</span>` },
    { t: "%", der: 1, v: (p) => `<span class="text-slate-500">${total ? Math.round((p.total / total) * 100) : 0}%</span>` },
  ], lista, { vacio: "Sin compras registradas" }));
}

function panelInventario() {
  const activos = state.productos.filter((p) => Number(p.activo) === 1);
  const idsVigentes = new Set(ventasVigentes().map((v) => v.id_venta));
  const detalleVigente = state.detalle_ventas.filter((d) => idsVigentes.has(d.venta_id));
  const sinVenta = activos.filter((p) => !detalleVigente.some((d) => d.producto_id === p.id_producto));
  return `<div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
    ${seccion(`Productos sin ninguna venta (${sinVenta.length})`, tabla([
      { t: "Producto", v: (p) => esc(p.nombre_producto) },
      { t: "Stock", der: 1, v: (p) => `<span class="font-bold">${p.stock}</span>` },
      { t: "Valor costo", der: 1, v: (p) => money(Number(p.stock || 0) * Number(p.precio_compra || 0)) },
    ], sinVenta, { vacio: "Todo el inventario tiene salida" }))}
    ${seccion("Distribución por categoría", tabla([
      { t: "Categoría", v: (c) => esc(c.nombre_categoria) },
      { t: "Productos", der: 1, v: (c) => activos.filter((p) => p.categoria_id === c.id_categoria).length },
      { t: "Unidades", der: 1, v: (c) => num(activos.filter((p) => p.categoria_id === c.id_categoria).reduce((s, p) => s + Number(p.stock || 0), 0)) },
    ], state.categorias, { vacio: "Sin categorías" }))}
  </div>`;
}

export function mount(root, ctx) {
  root.addEventListener("click", (e) => {
    const r = e.target.closest("[data-rango]");
    if (r) { rango = +r.dataset.rango; ctx.rerender(); return; }
    const b = e.target.closest("[data-bloque]");
    if (b) { bloque = b.dataset.bloque; ctx.rerender(); return; }
    if (e.target.closest("[data-export]")) {
      const s = serie(rango);
      exportarCSV(`reporte_ventas_${rango}d`, [
        { titulo: "Fecha", valor: (x) => x.fecha },
        { titulo: "Ventas", valor: (x) => x.ventas },
        { titulo: "Compras", valor: (x) => x.compras },
      ], s);
    }
  });
}