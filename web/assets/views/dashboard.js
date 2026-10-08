import { money, moneyCorto, num, fecha, hace } from "../supabase-client.js";
import { state, kpisRango, serieRango, rangoFechas, enPeriodo, topProductos, topProveedores, movimientosRecientes, nombreProducto, ventasVigentes } from "../data.js";
import { kpiCard, seccion, tabla, esc, badgeStock, ICONS } from "../ui.js";

export const meta = { id: "dashboard", titulo: "Dashboard General", icono: "📊", grupo: "Principal" };

/* ---------------- atajos del panel de inicio ----------------
   Botones grandes, con lenguaje de todos los días, pensados para que
   no haya que "navegar": se toca y se llega. El orden es el orden del
   trabajo real: vender, cobrar, revisar, comprar. ---------------- */
const ATAJOS = [
  { icono: "🛒", t: "Hacer una venta", sub: "Punto de venta", vista: "ventas", tab: "pos",
    caja: "bg-emerald-100 text-emerald-700", borde: "hover:border-emerald-300" },
  { icono: "💵", t: "La caja", sub: "Abrir o cerrar", vista: "ventas", tab: "caja",
    caja: "bg-amber-100 text-amber-700", borde: "hover:border-amber-300" },
  { icono: "📋", t: "Ver mis ventas", sub: "Historial del día", vista: "ventas", tab: "historial",
    caja: "bg-sky-100 text-sky-700", borde: "hover:border-sky-300" },
  { icono: "📦", t: "Los productos", sub: "Precios y stock", vista: "inventario", tab: "listado",
    caja: "bg-violet-100 text-violet-700", borde: "hover:border-violet-300" },
  { icono: "⚠️", t: "Poco stock", sub: "Revisar faltantes", vista: "inventario", tab: "stock",
    caja: "bg-rose-100 text-rose-700", borde: "hover:border-rose-300" },
  { icono: "👥", t: "Los clientes", sub: "Buscar o registrar", vista: "clientes", tab: "lista",
    caja: "bg-indigo-100 text-indigo-700", borde: "hover:border-indigo-300" },
  { icono: "🚚", t: "Las compras", sub: "A proveedores", vista: "compras", tab: "compras",
    caja: "bg-orange-100 text-orange-700", borde: "hover:border-orange-300" },
  { icono: "👤", t: "Los usuarios", sub: "Altas y permisos", vista: "usuarios", soloAdmin: true,
    caja: "bg-slate-100 text-slate-700", borde: "hover:border-slate-300" },
];

function saludo() {
  const h = new Date().getHours();
  return h < 13 ? "Buenos días" : h < 20 ? "Buenas tardes" : "Buenas noches";
}

/* El nombre vive en la cabecera del shell (index.html / movil.html).
   Si el registro migrado guarda el rol en vez del nombre ("Administrador"),
   mejor no poner nada antes de la coma. */
function nombreCorto() {
  const n = (document.getElementById("nombreUsuario")?.textContent || "").trim();
  if (!n || n === "-" || n.includes("@")) return "";
  const primero = n.split(" ")[0];
  if (["Administrador", "Empleado", "Vendedor"].includes(primero)) return "";
  return primero;
}

function esAdministrador() {
  const r = (document.getElementById("rolUsuario")?.textContent || "").trim();
  return r === "Administrador";
}

function atajo(a) {
  const params = a.tab ? ` data-params='{"tab":"${a.tab}"}'` : "";
  return `
  <button data-ir="${a.vista}"${params}
    class="atajo group bg-white rounded-2xl border-2 border-slate-100 ${a.borde} p-3 md:p-4 text-left shadow-sm flex flex-col justify-between gap-2 min-h-[104px] md:min-h-[116px] hover:shadow-md hover:-translate-y-0.5 active:translate-y-0 transition">
    <span class="w-11 h-11 md:w-12 md:h-12 rounded-xl ${a.caja} flex items-center justify-center text-2xl md:text-[26px] leading-none shrink-0">${a.icono}</span>
    <span class="block">
      <span class="block text-[15px] md:text-base font-bold text-slate-800 leading-tight">${a.t}</span>
      <span class="block text-[11px] md:text-xs text-slate-500 mt-0.5">${a.sub}</span>
    </span>
  </button>`;
}

function bloqueAtajos() {
  const lista = ATAJOS.filter((a) => !a.soloAdmin);
  if (esAdministrador()) lista.push(ATAJOS.find((a) => a.soloAdmin));
  const nombre = nombreCorto();
  return `
  <section class="rounded-2xl bg-gradient-to-br from-[#1e3c72] to-[#2a5298] p-4 md:p-5 shadow-md">
    <div class="flex items-start justify-between gap-3 mb-3 md:mb-4">
      <div class="min-w-0">
        <p class="text-lg md:text-xl font-bold text-white leading-tight">
          ${saludo()}${nombre ? ", " + esc(nombre) : ""} 👋
        </p>
        <p class="text-xs md:text-sm text-blue-100 mt-0.5">
          Toca cualquiera de estos botones para empezar.
        </p>
      </div>
      <span class="text-3xl md:text-4xl shrink-0">📚</span>
    </div>
    <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2.5 md:gap-3">
      ${lista.map(atajo).join("")}
    </div>
  </section>`;
}


/* ---------------- selector de rango de fechas (HU9) ---------------- */
const RANGOS = [
  ["hoy", "Hoy"], ["semana", "Esta semana"], ["mes", "Este mes"], ["personalizado", "Personalizado"],
];
let rango = { opcion: "semana", inicio: "", fin: "" };

function etiquetaRango() {
  const rc = rangoFechas(rango);
  if (rango.opcion === "personalizado") return `personalizado (${rc.inicio} → ${rc.fin})`;
  return (RANGOS.find(([k]) => k === rango.opcion) || [])[1] || "período";
}

function selectorRango() {
  const esPer = rango.opcion === "personalizado";
  return `
  <div class="flex flex-wrap gap-2 items-center mb-4">
    ${RANGOS.map(([k, t]) => `
      <button data-rangoopc="${k}" class="px-3 py-1.5 rounded-lg text-xs font-semibold ${rango.opcion === k ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
    ${esPer ? `
      <input data-rangoini type="date" value="${rango.inicio}" class="px-2 py-1.5 border border-slate-300 rounded-lg text-xs" />
      <span class="text-xs text-slate-400">→</span>
      <input data-rangofin type="date" value="${rango.fin}" class="px-2 py-1.5 border border-slate-300 rounded-lg text-xs" />` : ""}
  </div>`;
}

export function render() {
  const k = kpisRango(rango);
  const s = serieRango(rango);
  const maxS = Math.max(...s.map((x) => x.ventas), 1);
  const rc = rangoFechas(rango);
  const ids = new Set(ventasVigentes().filter((v) => enPeriodo(v.fecha, rc)).map((v) => v.id_venta));
  const idsCompras = new Set(state.compras.filter((c) => enPeriodo(c.fecha, rc)).map((c) => c.id_compra));
  const top = topProductos(5, ids);
  const maxT = Math.max(...top.map((t) => t.unidades), 1);
  const prov = topProveedores(4, idsCompras);
  const movs = movimientosRecientes(5);
  const cajaAbierta = state.apertura_caja.find((a) => Number(a.activo) === 1);
  const bajo = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) <= 5)
    .sort((a, b) => a.stock - b.stock).slice(0, 5);
  const etiqueta = etiquetaRango();

  const chartData = s.map((x) => ({
    label: s.length <= 8
      ? new Date(x.fecha + "T00:00:00").toLocaleDateString("es-BO", { weekday: "short" }).slice(0, 3)
      : x.fecha.slice(8),
    value: x.ventas
  })).reverse();
  const maxChart = Math.max(...chartData.map((d) => d.value), 1);

  // Guardar datos para uso en mount()
  window.__dashboardChartData = chartData;
  window.__dashboardMaxS = maxS;

  return `
  <div class="space-y-4 md:space-y-6 fade">
    ${bloqueAtajos()}

    ${!cajaAbierta ? `
    <div class="bg-amber-50 border-2 border-amber-300 text-amber-900 rounded-xl px-4 py-3 text-sm flex items-center justify-between gap-3">
      <div class="flex items-center gap-2">
        <span class="p-2 bg-amber-100 rounded-lg text-amber-600">${ICONS.alert || '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>'}</span>
        <span>No hay caja abierta. Los totales del día pueden no cuadrar con el efectivo físico.</span>
      </div>
      <button data-ir="ventas" data-params='{"tab":"caja"}' class="px-3 py-1.5 bg-amber-600 text-white text-xs font-semibold rounded-lg hover:bg-amber-700 transition shrink-0">Abrir caja</button>
    </div>` : ""}

    ${selectorRango()}

    <div class="mb-3 px-1 flex items-center justify-between">
      <div>
        <h2 class="text-base font-bold text-slate-700 uppercase tracking-wide">Resumen y Estado del Negocio</h2>
        <p class="text-xs text-slate-500">Métricas en tiempo real de ventas e inventario</p>
      </div>
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
      ${kpiCard({
        label: `Ventas ${etiqueta}`,
        valor: money(k.ventas),
        sub: `${k.count} ventas · ${k.unidades} art.`,
        icono: "money",
        color: "text-emerald-600",
        iconBg: "bg-emerald-50",
        iconColor: "text-emerald-600",
        hoverIconBg: "bg-emerald-100",
        hoverIconColor: "text-emerald-700",
        onClick: "ir('ventas', true, {tab:'historial'})"
      })}
      ${kpiCard({
        label: `Margen bruto ${etiqueta}`,
        valor: money(k.margen),
        sub: `costo de ventas ${money(k.ventas - k.margen)}`,
        icono: "calc",
        color: "text-sky-600",
        iconBg: "bg-sky-50",
        iconColor: "text-sky-600",
        hoverIconBg: "bg-sky-100",
        hoverIconColor: "text-sky-700",
        onClick: "ir('reportes')"
      })}
      ${kpiCard({
        label: `Utilidad ${etiqueta}`,
        valor: money(k.utilidad),
        sub: `gastos ${money(k.gastos)}`,
        icono: "bank",
        color: k.utilidad >= 0 ? "text-violet-600" : "text-red-600",
        iconBg: k.utilidad >= 0 ? "bg-violet-50" : "bg-red-50",
        iconColor: k.utilidad >= 0 ? "text-violet-600" : "text-red-600",
        hoverIconBg: k.utilidad >= 0 ? "bg-violet-100" : "bg-red-100",
        hoverIconColor: k.utilidad >= 0 ? "text-violet-700" : "text-red-700",
        onClick: "ir('reportes')"
      })}
      ${kpiCard({
        label: `Compras ${etiqueta}`,
        valor: money(k.compras),
        sub: `${k.comprasCount} compras`,
        icono: "cart",
        color: "text-orange-600",
        iconBg: "bg-orange-50",
        iconColor: "text-orange-600",
        hoverIconBg: "bg-orange-100",
        hoverIconColor: "text-orange-700",
        onClick: "ir('compras')"
      })}
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
      ${kpiCard({
        label: `Ticket promedio ${etiqueta}`,
        valor: money(k.ticket),
        sub: `${k.count} ventas`,
        icono: "ticket",
        color: "text-slate-700",
        iconBg: "bg-slate-50",
        iconColor: "text-slate-600",
        hoverIconBg: "bg-slate-100",
        hoverIconColor: "text-slate-700",
        compacto: true,
        onClick: "ir('ventas', true, {tab:'historial'})"
      })}
      ${kpiCard({
        label: "Stock bajo",
        valor: num(k.stockBajo),
        sub: `${k.agotados} agotados`,
        icono: "alert",
        color: k.stockBajo ? "text-amber-600" : "text-emerald-600",
        iconBg: k.stockBajo ? "bg-amber-50" : "bg-emerald-50",
        iconColor: k.stockBajo ? "text-amber-600" : "text-emerald-600",
        hoverIconBg: k.stockBajo ? "bg-amber-100" : "bg-emerald-100",
        hoverIconColor: k.stockBajo ? "text-amber-700" : "text-emerald-700",
        compacto: true,
        onClick: "ir('inventario', true, {tab:'stock'})"
      })}
      ${kpiCard({
        label: "Inventario",
        valor: moneyCorto(k.valorInventario),
        sub: `${k.productos} productos`,
        icono: "box",
        color: "text-violet-600",
        iconBg: "bg-violet-50",
        iconColor: "text-violet-600",
        hoverIconBg: "bg-violet-100",
        hoverIconColor: "text-violet-700",
        compacto: true,
        onClick: "ir('inventario')"
      })}
      ${kpiCard({
        label: `Unidades vendidas ${etiqueta}`,
        valor: num(k.unidades),
        sub: `${k.count} ventas`,
        icono: "box",
        color: "text-orange-600",
        iconBg: "bg-orange-50",
        iconColor: "text-orange-600",
        hoverIconBg: "bg-orange-100",
        hoverIconColor: "text-orange-700",
        compacto: true,
        onClick: "ir('ventas', true, {tab:'historial'})"
      })}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
      ${seccion(`Ventas del período · ${etiqueta}`, `
        <div class="w-full h-48 md:h-56" id="chartSemanal">
          <canvas id="graficoSemanal"></canvas>
        </div>
      `, `<span class="text-[10px] text-slate-400">máx ${moneyCorto(maxS)}</span>`)}
      <div class="lg:col-span-1">
      ${seccion("Top productos", top.length ? top.map((t) => `
        <div class="mb-3 last:mb-0">
          <div class="flex justify-between text-xs gap-2">
            <span class="truncate">${esc(t.nombre)}</span>
            <span class="font-semibold text-[#1e3c72] shrink-0">${t.unidades} und · ${moneyCorto(t.ingresos)}</span>
          </div>
          <div class="h-1.5 bg-slate-100 rounded-full mt-1">
            <div class="h-1.5 bg-[#2a5298] rounded-full" style="width:${(t.unidades / maxT) * 100}%"></div>
          </div>
        </div>`).join("") : `<p class="text-sm text-slate-400">Sin ventas</p>`)}
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      ${seccion("Últimas ventas", tabla([
        { t: "Venta", v: (v) => `<span class="font-semibold">#${v.id_venta}</span>` },
        { t: "Fecha", v: (v) => `<span class="text-xs text-slate-500">${fecha(v.fecha)}</span>` },
        { t: "Pago", v: (v) => `<span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-100">${esc(v.metodo_pago || "—")}</span>` },
        { t: "Total", der: 1, v: (v) => `<span class="font-semibold text-emerald-600">${money(v.total)}</span>` },
      ], [...ventasVigentes()].filter((v) => enPeriodo(v.fecha, rc)).sort((a, b) => new Date(b.fecha) - new Date(a.fecha)).slice(0, 6)), "",
        `<button data-ir="ventas" data-params='{"tab":"historial"}' class="text-xs text-[#2a5298] font-semibold">Ver todo →</button>`)}

      ${seccion("Stock bajo", tabla([
        { t: "Producto", v: (p) => `<span class="font-medium">${esc(p.nombre_producto)}</span>` },
        { t: "Código", v: (p) => `<span class="font-mono text-[10px] text-slate-400">${esc(p.codigo || "—")}</span>` },
        { t: "Stock", der: 1, v: (p) => `<span class="font-bold">${p.stock}</span>` },
        { t: "", v: (p) => badgeStock(p.stock) },
      ], bajo), "", `<button data-ir="inventario" data-params='{"tab":"stock"}' class="text-xs text-[#2a5298] font-semibold">Inventario →</button>`)}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
      ${seccion("Últimos movimientos de inventario", movs.length ? movs.map((m) => `
        <div class="flex items-center justify-between text-sm py-1.5 border-b border-slate-50 last:border-0">
          <div class="min-w-0">
            <span class="font-semibold ${m.tipo === "SALIDA" ? "text-amber-600" : m.tipo === "AJUSTE" ? "text-sky-600" : "text-emerald-600"}">${m.tipo}</span>
            <span class="text-slate-600 truncate"> ${esc(nombreProducto(m.id_producto))}</span>
            <span class="text-[10px] text-slate-400"> · ${hace(m.fecha_hora)}</span>
          </div>
          <span class="font-semibold shrink-0">${m.cantidad > 0 ? "+" : ""}${m.cantidad}</span>
        </div>`).join("") : `<p class="text-sm text-slate-400">Sin movimientos todavía. Se generan al vender, comprar o ajustar.</p>`)}

      ${seccion("Compras por proveedor", tabla([
        { t: "Proveedor", v: (p) => esc(p.nombre) },
        { t: "Compras", der: 1, v: (p) => p.compras },
        { t: "Total", der: 1, v: (p) => `<span class="font-semibold text-orange-600">${money(p.total)}</span>` },
      ], prov, { vacio: "Sin compras registradas" }), "",
        `<button data-ir="compras" class="text-xs text-[#2a5298] font-semibold">Compras →</button>`)}
    </div>
  </div>`;
}

let _chart = null;
function initChart() {
  try {
    const chartData = window.__dashboardChartData;
    const maxS = window.__dashboardMaxS;
    if (!chartData || !window.Chart) return;
    
    const ctx = document.getElementById('graficoSemanal');
    if (!ctx) return;
    if (_chart) { _chart.destroy(); _chart = null; }
    
    _chart = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: chartData.map(d => d.label),
        datasets: [{
          label: 'Ventas (Bs)',
          data: chartData.map(d => d.value),
          backgroundColor: 'rgba(30, 60, 114, 0.7)',
          borderColor: '#1e3c72',
          borderWidth: 1,
          borderRadius: 6,
          borderSkipped: false,
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { display: false },
          tooltip: {
            backgroundColor: '#1e3c72',
            titleColor: '#fff',
            bodyColor: '#fff',
            padding: 10,
            displayColors: false,
            callbacks: {
              label: function(ctx) {
                return 'Bs ' + ctx.raw.toLocaleString('es-BO', {minimumFractionDigits: 2});
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            grid: { color: 'rgba(0,0,0,0.05)' },
            ticks: {
              callback: function(value) {
                return 'Bs ' + value.toLocaleString('es-BO');
              }
            }
          },
          x: {
            grid: { display: false },
            ticks: { color: '#64748b', font: { size: 11 } }
          }
        }
      }
    });
  } catch (e) {
    console.warn('Chart.js init failed:', e);
  }
}

export function mount(root, ctx) {
  /* Los [data-ir] (atajos y "ver todo") los resuelve cablearGlobal() en
     app.js, que sí entiende data-params. Aquí: botones del rango y gráfico. */
  root.addEventListener("click", (e) => {
    const r = e.target.closest("[data-rangoopc]");
    if (r) {
      const opcion = r.dataset.rangoopc;
      rango.opcion = opcion;
      if (opcion !== "personalizado") { rango.inicio = ""; rango.fin = ""; }
      ctx.rerender();
      return;
    }
  });
  root.addEventListener("change", (e) => {
    const ini = e.target.closest("[data-rangoini]");
    const fin = e.target.closest("[data-rangofin]");
    if (ini) rango.inicio = ini.value;
    if (fin) rango.fin = fin.value;
    if (ini || fin) ctx.rerender();
  });
  if (window.Chart) {
    initChart();
  } else {
    // Esperar a que Chart.js cargue (se carga en head sin defer)
    const checkChart = setInterval(() => {
      if (window.Chart) {
        clearInterval(checkChart);
        initChart();
      }
    }, 100);
    
    // Timeout de seguridad
    setTimeout(() => clearInterval(checkChart), 5000);
  }
}

/* Se llama tras cada redibujado (app.js dibujar): recrea el gráfico si el
   canvas cambió o el rango de fechas recalculó los datos. */
export function onRender() {
  requestAnimationFrame(() => initChart());
}