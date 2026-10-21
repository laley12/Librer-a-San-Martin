import { money, moneyCorto, num, fecha } from "../supabase-client.js";
import { state, kpisRango, serieRango, rangoFechas, enPeriodo, topProductos, topProveedores, nombreProducto, ventasVigentes } from "../data.js";
import { kpiCard, seccion, tabla, esc, badgeStock } from "../ui.js";

export const meta = { id: "dashboard", titulo: "Dashboard General", icono: "📊", grupo: "Principal" };

/* ---------------- cabecera y bienvenida ---------------- */
function saludo() {
  const h = new Date().getHours();
  if (h < 12) return "¡Buenos días";
  if (h < 19) return "¡Buenas tardes";
  return "¡Buenas noches";
}

function nombreCorto() {
  const n = (document.getElementById("nombreUsuario")?.textContent || "").trim();
  if (!n || n === "-" || n.includes("@")) return "";
  const primero = n.split(" ")[0];
  if (["Administrador", "Empleado", "Vendedor"].includes(primero)) return "";
  return primero;
}

function esAdministrador() {
  const r = (document.getElementById("rolUsuario")?.textContent || "").trim();
  return r.toLowerCase().includes("admin");
}

function esVendedor() {
  const r = (document.getElementById("rolUsuario")?.textContent || "").trim();
  return r.toLowerCase().includes("vendedor");
}

function bannerBienvenida() {
  const nombre = nombreCorto();
  const saludoTxt = saludo();
  return `
  <section class="rounded-2xl md:rounded-3xl bg-gradient-to-r from-[#1e3c72] via-[#2a5298] to-[#1e3c72] p-5 md:p-6 shadow-md text-white relative overflow-hidden">
    <div class="relative z-10 flex items-center justify-between gap-4">
      <div class="min-w-0">
        <h1 class="text-xl sm:text-2xl md:text-3xl font-black text-white leading-tight">
          ${saludoTxt}${nombre ? `, ${esc(nombre)}` : ""}! 👋
        </h1>
        <p class="text-xs sm:text-sm text-blue-100 font-medium mt-1">
          Todo listo para tu jornada.
        </p>
      </div>
      <div class="w-12 h-12 md:w-14 md:h-14 rounded-2xl bg-white/10 backdrop-blur-xs border border-white/20 flex items-center justify-center text-2xl md:text-3xl shrink-0 shadow-inner">
        📚
      </div>
    </div>
  </section>`;
}

/* ---------------- resumen de hoy (3 tarjetas compactas) ---------------- */
function resumenHoy() {
  const kHoy = kpisRango({ opcion: "hoy" });
  const totalHoy = kHoy.ventas;
  const countHoy = kHoy.count;

  // Consultas reales y honestas de la base de datos (Supabase state)
  const pendientesVentas = state.ventas.filter((v) => v.estado && String(v.estado).toLowerCase().includes("pendiente")).length;
  const pendientesCompras = state.compras.filter((c) => c.estado && String(c.estado).toLowerCase().includes("pendiente")).length;
  const pendientesTotal = pendientesVentas + pendientesCompras;

  const prodsStockBajo = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) <= 5);
  const stockBajoCount = prodsStockBajo.length;

  return `
  <section>
    <div class="grid grid-cols-3 gap-2 sm:gap-3 md:gap-4">
      <!-- Tarjeta 1: Ventas -->
      <button data-ir="ventas" data-params='{"tab":"historial"}'
        class="bg-white rounded-2xl border border-emerald-200/80 hover:border-emerald-500 hover:shadow-md p-2.5 sm:p-3.5 md:p-4 text-center transition-all active:scale-[0.98] shadow-xs flex flex-col items-center justify-center gap-1 group cursor-pointer">
        <span class="w-8 h-8 sm:w-9 sm:h-9 rounded-xl bg-emerald-50 text-emerald-600 flex items-center justify-center text-base sm:text-lg shrink-0 group-hover:scale-105 transition-transform shadow-xs">
          💵
        </span>
        <span class="block text-xs sm:text-base md:text-lg font-black text-slate-900 group-hover:text-emerald-700 transition-colors leading-tight">
          ${money(totalHoy)}
        </span>
        <span class="block text-[11px] sm:text-xs font-bold text-slate-600 uppercase tracking-wider leading-none">
          Ventas
        </span>
        <span class="block text-[9px] sm:text-[11px] text-slate-400 font-medium leading-none">
          ${countHoy} ${countHoy === 1 ? "venta" : "ventas"}
        </span>
      </button>

      <!-- Tarjeta 2: Pendientes -->
      <button data-ir="compras"
        class="bg-white rounded-2xl border border-sky-200/80 hover:border-sky-500 hover:shadow-md p-2.5 sm:p-3.5 md:p-4 text-center transition-all active:scale-[0.98] shadow-xs flex flex-col items-center justify-center gap-1 group cursor-pointer">
        <span class="w-8 h-8 sm:w-9 sm:h-9 rounded-xl bg-sky-50 text-sky-600 flex items-center justify-center text-base sm:text-lg shrink-0 group-hover:scale-105 transition-transform shadow-xs">
          📋
        </span>
        <span class="block text-xs sm:text-base md:text-lg font-black text-slate-900 group-hover:text-sky-700 transition-colors leading-tight">
          ${num(pendientesTotal)}
        </span>
        <span class="block text-[11px] sm:text-xs font-bold text-slate-600 uppercase tracking-wider leading-none">
          Pendientes
        </span>
        <span class="block text-[9px] sm:text-[11px] text-slate-400 font-medium leading-none">
          ${pendientesTotal === 0 ? "0 pendientes" : `${pendientesTotal} pend.`}
        </span>
      </button>

      <!-- Tarjeta 3: Stock Bajo -->
      <button data-ir="inventario" data-params='{"tab":"stock"}'
        class="bg-white rounded-2xl border border-amber-200/80 hover:border-amber-500 hover:shadow-md p-2.5 sm:p-3.5 md:p-4 text-center transition-all active:scale-[0.98] shadow-xs flex flex-col items-center justify-center gap-1 group cursor-pointer">
        <span class="w-8 h-8 sm:w-9 sm:h-9 rounded-xl bg-amber-50 text-amber-600 flex items-center justify-center text-base sm:text-lg shrink-0 group-hover:scale-105 transition-transform shadow-xs">
          ⚠️
        </span>
        <span class="block text-xs sm:text-base md:text-lg font-black ${stockBajoCount > 0 ? "text-amber-600" : "text-slate-900"} leading-tight transition-colors">
          ${num(stockBajoCount)}
        </span>
        <span class="block text-[11px] sm:text-xs font-bold text-slate-600 uppercase tracking-wider leading-none">
          Stock Bajo
        </span>
        <span class="block text-[9px] sm:text-[11px] text-slate-400 font-medium leading-none">
          ${stockBajoCount === 1 ? "1 faltante" : `${stockBajoCount} faltantes`}
        </span>
      </button>
    </div>
  </section>`;
}

/* ---------------- accesos rápidos (2 columnas en móvil) ---------------- */
const ACCESOS_RAPIDOS = [
  {
    icono: "🛒",
    titulo: "Nueva Venta",
    sub: "Punto de venta",
    vista: "ventas",
    tab: "pos",
    bgCard: "bg-gradient-to-b from-emerald-50 via-emerald-50/80 to-emerald-100/60",
    borde: "border-2 border-emerald-200/90 hover:border-emerald-500 hover:shadow-emerald-500/20",
    iconBg: "bg-emerald-600 text-white shadow-md shadow-emerald-600/30",
    textTitle: "text-emerald-950",
    textSub: "text-emerald-700 font-medium",
    roles: ["admin", "empleado", "vendedor"],
  },
  {
    icono: "📋",
    titulo: "Historial",
    sub: "Ver registros",
    vista: "ventas",
    tab: "historial",
    bgCard: "bg-gradient-to-b from-sky-50 via-sky-50/80 to-sky-100/60",
    borde: "border-2 border-sky-200/90 hover:border-sky-500 hover:shadow-sky-500/20",
    iconBg: "bg-sky-600 text-white shadow-md shadow-sky-600/30",
    textTitle: "text-sky-950",
    textSub: "text-sky-700 font-medium",
    roles: ["admin", "empleado", "vendedor"],
  },
  {
    icono: "📦",
    titulo: "Productos",
    sub: "Precios y stock",
    vista: "inventario",
    tab: "listado",
    bgCard: "bg-gradient-to-b from-violet-50 via-violet-50/80 to-violet-100/60",
    borde: "border-2 border-violet-200/90 hover:border-violet-500 hover:shadow-violet-500/20",
    iconBg: "bg-violet-600 text-white shadow-md shadow-violet-600/30",
    textTitle: "text-violet-950",
    textSub: "text-violet-700 font-medium",
    roles: ["admin", "empleado", "vendedor"],
  },
  {
    icono: "⚠️",
    titulo: "Poco Stock",
    sub: "Revisar faltantes",
    vista: "inventario",
    tab: "stock",
    bgCard: "bg-gradient-to-b from-amber-50 via-amber-50/80 to-amber-100/60",
    borde: "border-2 border-amber-200/90 hover:border-amber-500 hover:shadow-amber-500/20",
    iconBg: "bg-amber-500 text-white shadow-md shadow-amber-500/30",
    textTitle: "text-amber-950",
    textSub: "text-amber-800 font-medium",
    roles: ["admin", "empleado"],
  },
  {
    icono: "🚚",
    titulo: "Compras",
    sub: "A proveedores",
    vista: "compras",
    tab: "compras",
    bgCard: "bg-gradient-to-b from-orange-50 via-orange-50/80 to-orange-100/60",
    borde: "border-2 border-orange-200/90 hover:border-orange-500 hover:shadow-orange-500/20",
    iconBg: "bg-orange-500 text-white shadow-md shadow-orange-500/30",
    textTitle: "text-orange-950",
    textSub: "text-orange-800 font-medium",
    roles: ["admin", "empleado"],
  },
  {
    icono: "👤",
    titulo: "Usuarios",
    sub: "Altas y roles",
    vista: "usuarios",
    soloAdmin: true,
    bgCard: "bg-gradient-to-b from-blue-50 via-blue-50/80 to-indigo-100/60",
    borde: "border-2 border-blue-200/90 hover:border-[#1e3c72] hover:shadow-blue-900/20",
    iconBg: "bg-[#1e3c72] text-white shadow-md shadow-blue-950/30",
    textTitle: "text-slate-900",
    textSub: "text-blue-900/80 font-medium",
    roles: ["admin"],
  },
];

function bloqueAccesosRapidos() {
  const admin = esAdministrador();
  const vendedor = esVendedor();
  const rolActual = admin ? "admin" : vendedor ? "vendedor" : "empleado";
  const lista = ACCESOS_RAPIDOS.filter((a) => {
    if (a.soloAdmin && !admin) return false;
    if (a.roles && !a.roles.includes(rolActual)) return false;
    return true;
  });
  return `
  <section class="space-y-2.5">
    <div class="flex items-center justify-between px-0.5">
      <h2 class="text-xs sm:text-sm font-bold text-slate-700 uppercase tracking-wider">Accesos Rápidos</h2>
      <span class="text-[11px] text-slate-400 font-medium">Toca para ingresar</span>
    </div>
    <div class="grid grid-cols-2 md:grid-cols-3 gap-3 md:gap-4">
      ${lista.map((a) => {
        const params = a.tab ? ` data-params='{"tab":"${a.tab}"}'` : "";
        return `
        <button data-ir="${a.vista}"${params}
          class="group ${a.bgCard} ${a.borde} rounded-2xl hover:shadow-lg p-3 sm:p-3.5 md:p-4 text-center transition-all active:scale-[0.98] flex flex-col items-center justify-center gap-2 shadow-xs cursor-pointer">
          <span class="w-12 h-12 sm:w-14 sm:h-14 rounded-2xl flex items-center justify-center text-2xl sm:text-3xl shrink-0 ${a.iconBg} group-hover:scale-105 transition-transform">
            ${a.icono}
          </span>
          <div class="w-full text-center">
            <span class="block text-sm sm:text-base font-bold ${a.textTitle} leading-snug transition-colors">
              ${a.titulo}
            </span>
            <span class="block text-[11px] sm:text-xs ${a.textSub} mt-0.5">
              ${a.sub}
            </span>
          </div>
        </button>`;
      }).join("")}
    </div>
  </section>`;
}

/* ---------------- alerta flotante de stock ---------------- */
function alertaStock(count) {
  if (count <= 0) return "";
  return `
  <div class="rounded-2xl bg-amber-50 border-2 border-amber-300 p-3.5 md:p-4 flex items-center justify-between gap-3 shadow-xs text-amber-950">
    <div class="flex items-center gap-2.5 sm:gap-3 min-w-0">
      <span class="text-xl sm:text-2xl shrink-0">⚠️</span>
      <div class="min-w-0">
        <span class="text-xs sm:text-sm md:text-base font-bold block truncate">
          Hay ${count} ${count === 1 ? "producto" : "productos"} con stock bajo
        </span>
        <span class="text-[11px] sm:text-xs text-amber-800/80 hidden sm:inline">
          Revisa los faltantes para evitar quedarte sin existencias
        </span>
      </div>
    </div>
    <button data-ir="inventario" data-params='{"tab":"stock"}'
      class="shrink-0 px-3 py-1.5 sm:px-4 sm:py-2 rounded-xl bg-amber-500 hover:bg-amber-600 active:scale-95 text-white font-bold text-xs sm:text-sm shadow-xs transition-all flex items-center gap-1 cursor-pointer">
      Revisar <span class="font-bold">&gt;</span>
    </button>
  </div>`;
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
  const ids = new Set(ventasVigentes().filter((v) => enPeriodo(v.fecha, rc)).map((v) => v.id));
  const idsCompras = new Set(state.compras.filter((c) => enPeriodo(c.fecha, rc)).map((c) => c.id));
  const top = topProductos(5, ids);
  const maxT = Math.max(...top.map((t) => t.unidades), 1);
  const prov = topProveedores(4, idsCompras);
  const bajo = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) <= 5)
    .sort((a, b) => a.stock - b.stock).slice(0, 5);
  const bajoTotal = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) <= 5).length;
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
    <!-- 1. Header y Bienvenida -->
    ${bannerBienvenida()}

    <!-- 2. Resumen de hoy (3 tarjetas compactas con datos reales) -->
    ${resumenHoy()}

    <!-- 3. Accesos Rápidos (2 columnas en móvil) -->
    ${bloqueAccesosRapidos()}

    <!-- 4. Alerta Flotante de Stock Bajo -->
    ${alertaStock(bajoTotal)}

    <!-- 5. Métricas Analíticas y Selector de Rango -->
    <div class="pt-2 border-t border-slate-200/80">
      <div class="mb-3 px-1 flex items-center justify-between">
        <div>
          <h2 class="text-base font-bold text-slate-700 uppercase tracking-wide">Resumen y Estado del Negocio</h2>
          <p class="text-xs text-slate-500">Métricas analíticas en tiempo real</p>
        </div>
      </div>
      ${selectorRango()}
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
        sub: `costo de ventas ${money(k.ventas - k.margen)}`,
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
        { t: "Venta", v: (v) => `<span class="font-semibold">#${v.id}</span>` },
        { t: "Fecha", v: (v) => `<span class="text-xs text-slate-500">${fecha(v.fecha)}</span>` },
        { t: "Cliente", v: (v) => esc(v.cliente || "General") },
        { t: "Pago", v: (v) => `<span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-100">${esc(v.metodo_pago || "—")}</span>` },
        { t: "Total", der: 1, v: (v) => `<span class="font-semibold text-emerald-600">${money(v.total)}</span>` },
      ], [...ventasVigentes()].filter((v) => enPeriodo(v.fecha, rc)).sort((a, b) => new Date(b.fecha) - new Date(a.fecha)).slice(0, 6)), "",
        `<button data-ir="ventas" data-params='{"tab":"historial"}' class="text-xs text-[#2a5298] font-semibold">Ver todo →</button>`)}

      ${seccion("Stock bajo", tabla([
        { t: "Producto", v: (p) => `<span class="font-medium">${esc(p.nombre)}</span>` },
        { t: "Código", v: (p) => `<span class="font-mono text-[10px] text-slate-400">${esc(p.codigo || "—")}</span>` },
        { t: "Stock", der: 1, v: (p) => `<span class="font-bold">${p.stock}</span>` },
        { t: "", v: (p) => badgeStock(p.stock) },
      ], bajo), "", `<button data-ir="inventario" data-params='{"tab":"stock"}' class="text-xs text-[#2a5298] font-semibold">Inventario →</button>`)}
    </div>

    <div class="grid grid-cols-1 gap-4">
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

console.log('confetti ok');

window.showWelcome = function() {
  if (typeof confetti !== 'undefined') {
    confetti({ particleCount: 80, spread: 60, origin: { y: 0.6 } });
  }
};