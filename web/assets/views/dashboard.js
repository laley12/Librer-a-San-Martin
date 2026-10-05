import { money, moneyCorto, num, fecha, hace } from "../supabase-client.js";
import { state, kpis, serie, topProductos, topProveedores, movimientosRecientes, nombreProducto, ventasVigentes } from "../data.js";
import { kpiCard, seccion, tabla, esc, badgeStock, ICONS } from "../ui.js";

export const meta = { id: "dashboard", titulo: "Dashboard General", icono: "📊", grupo: "Principal" };

export function render() {
  const k = kpis();
  const s = serie(7);
  const maxS = Math.max(...s.map((x) => x.ventas), 1);
  const top = topProductos(5);
  const maxT = Math.max(...top.map((t) => t.unidades), 1);
  const prov = topProveedores(4);
  const movs = movimientosRecientes(5);
  const cajaAbierta = state.apertura_caja.find((a) => Number(a.activo) === 1);
  const bajo = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) <= 5)
    .sort((a, b) => a.stock - b.stock).slice(0, 5);

  const chartData = s.map((x) => ({
    label: new Date(x.fecha).toLocaleDateString("es-BO", { weekday: "short" }).slice(0, 3),
    value: x.ventas
  })).reverse();
  const maxChart = Math.max(...chartData.map((d) => d.value), 1);

  return `
  <div class="space-y-4 md:space-y-6 fade">
    ${!cajaAbierta ? `
    <div class="bg-amber-50 border-2 border-amber-300 text-amber-900 rounded-xl px-4 py-3 text-sm flex items-center justify-between gap-3">
      <div class="flex items-center gap-2">
        <span class="p-2 bg-amber-100 rounded-lg text-amber-600">${ICONS.alert || '<svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/></svg>'}</span>
        <span>No hay caja abierta. Los totales del día pueden no cuadrar con el efectivo físico.</span>
      </div>
      <button data-ir="ventas" data-params='{"tab":"caja"}' class="px-3 py-1.5 bg-amber-600 text-white text-xs font-semibold rounded-lg hover:bg-amber-700 transition shrink-0">Abrir caja</button>
    </div>` : ""}

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
      ${kpiCard({
        label: "Ventas hoy",
        valor: money(k.hoyTotal),
        sub: `${k.hoyCount} ventas · ${k.unidadesHoy} art.`,
        icono: "money",
        color: "text-emerald-600",
        iconBg: "bg-emerald-50",
        iconColor: "text-emerald-600",
        hoverIconBg: "bg-emerald-100",
        hoverIconColor: "text-emerald-700",
        onClick: "ir('ventas', true, {tab:'historial'})"
      })}
      ${kpiCard({
        label: "Ventas del mes",
        valor: money(k.mesTotal),
        sub: `${k.mesCount} ventas`,
        icono: "chart",
        color: "text-[#1e3c72]",
        iconBg: "bg-blue-50",
        iconColor: "text-[#1e3c72]",
        hoverIconBg: "bg-blue-100",
        hoverIconColor: "text-blue-700",
        onClick: "ir('ventas', true, {tab:'historial'})"
      })}
      ${kpiCard({
        label: "Margen bruto mes",
        valor: money(k.margen),
        sub: `costo de ventas ${money(k.mesTotal - k.margen)}`,
        icono: "calc",
        color: "text-sky-600",
        iconBg: "bg-sky-50",
        iconColor: "text-sky-600",
        hoverIconBg: "bg-sky-100",
        hoverIconColor: "text-sky-700",
        onClick: "ir('reportes')"
      })}
      ${kpiCard({
        label: "Utilidad del mes",
        valor: money(k.utilidadMes),
        sub: `gastos ${money(k.gastosMes)}`,
        icono: "bank",
        color: k.utilidadMes >= 0 ? "text-violet-600" : "text-red-600",
        iconBg: k.utilidadMes >= 0 ? "bg-violet-50" : "bg-red-50",
        iconColor: k.utilidadMes >= 0 ? "text-violet-600" : "text-red-600",
        hoverIconBg: k.utilidadMes >= 0 ? "bg-violet-100" : "bg-red-100",
        hoverIconColor: k.utilidadMes >= 0 ? "text-violet-700" : "text-red-700",
        onClick: "ir('reportes')"
      })}
    </div>

    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3 md:gap-4">
      ${kpiCard({
        label: "Ticket promedio",
        valor: money(k.ticket),
        sub: "hoy",
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
        label: "Compras del mes",
        valor: money(k.comprasMes),
        sub: `${k.comprasMesCount} compras`,
        icono: "cart",
        color: "text-orange-600",
        iconBg: "bg-orange-50",
        iconColor: "text-orange-600",
        hoverIconBg: "bg-orange-100",
        hoverIconColor: "text-orange-700",
        compacto: true,
        onClick: "ir('compras')"
      })}
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
      ${seccion("Ventas de la semana", `
        <div class="w-full h-48 md:h-56" id="chartSemanal">
          <canvas id="graficoSemanal"></canvas>
        </div>
        <script>
          (function() {
            const ctx = document.getElementById('graficoSemanal');
            if (ctx && window.Chart) {
              new Chart(ctx, {
                type: 'bar',
                data: {
                  labels: ${JSON.stringify(chartData.map(d => d.label))},
                  datasets: [{
                    label: 'Ventas (Bs)',
                    data: ${JSON.stringify(chartData.map(d => d.value))},
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
            }
          })();
        </script>
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
      ], [...ventasVigentes()].sort((a, b) => new Date(b.fecha) - new Date(a.fecha)).slice(0, 6)), "",
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

export function mount(root, ctx) {
  root.addEventListener("click", (e) => {
    const b = e.target.closest("[data-ir]");
    if (b) {
      const params = b.dataset.params ? JSON.parse(b.dataset.params) : undefined;
      ctx.ir(b.dataset.ir, true, params);
    }
  });
}