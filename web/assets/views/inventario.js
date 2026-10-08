import { money, moneyCorto, num, fecha, fechaHora } from "../supabase-client.js";
import { state, repo, kpis, movimientosRecientes, mapaProductos } from "../data.js";
import { esc, toast, modal, tabla, seccion, input, select, badgeStock, exportarCSV, confirmar } from "../ui.js";

export const meta = { id: "inventario", titulo: "Productos & Inventario", icono: "📦", grupo: "Operación" };

let tab = "listado";
let filtro = { texto: "", vista: "todos", cat: "" };

export function abrir(params = {}) {
  if (params.tab) tab = params.tab;
}

export function render() {
  return `
  <div class="fade space-y-4">
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-3">
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Productos activos</div>
        <div class="text-xl font-bold text-[#1e3c72]">${num(kpis().productos)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Valor del inventario</div>
        <div class="text-xl font-bold text-violet-600">${moneyCorto(kpis().valorInventario)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Stock bajo</div>
        <div class="text-xl font-bold text-amber-600">${num(kpis().stockBajo)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Agotados</div>
        <div class="text-xl font-bold text-red-600">${num(kpis().agotados)}</div>
      </div>
    </div>

    <div class="flex gap-2 overflow-x-auto pb-1">
      ${[["listado", "📋 Listado"], ["stock", "⚠️ Stock bajo"], ["movimientos", "🔄 Movimientos"], ["valor", "💰 Valorización"], ["categorias", "🏷️ Categorías"]]
        .map(([k, t]) => `<button data-tab="${k}" class="tab shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold ${tab === k ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
      <span class="grow"></span>
      ${ctx_ayuda()}
    </div>

    <div>${panel()}</div>
  </div>`;
}

function ctx_ayuda() {
  return `<button data-nuevo class="shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold bg-emerald-600 text-white">+ Nuevo producto</button>`;
}

function productosFiltrados() {
  const q = filtro.texto.toLowerCase();
  let lista;
  if (filtro.vista === "inactivos") {
    lista = state.productos.filter((p) => Number(p.activo) !== 1);
  } else {
    lista = state.productos.filter((p) => Number(p.activo) === 1);
    if (filtro.vista === "bajo") lista = lista.filter((p) => Number(p.stock) <= 5);
    if (filtro.vista === "agotado") lista = lista.filter((p) => Number(p.stock) <= 0);
  }
  if (filtro.cat) lista = lista.filter((p) => String(p.categoria_id) === filtro.cat);
  if (q) lista = lista.filter((p) => p.nombre_producto.toLowerCase().includes(q) || String(p.codigo || "").toLowerCase().includes(q));
  return lista.sort((a, b) => a.nombre_producto.localeCompare(b.nombre_producto));
}

function panel() {
  if (tab === "stock") return panelStockBajo();
  const lista = productosFiltrados();
  if (tab === "movimientos") return panelMovimientos();
  if (tab === "valor") return panelValor();
  if (tab === "categorias") return panelCategorias();
  return panelListado(lista);
}

function panelStockBajo() {
  const bajo = state.productos.filter((p) => Number(p.activo) === 1 && Number(p.stock) <= 5)
    .sort((a, b) => a.stock - b.stock);
  const agotados = bajo.filter((p) => Number(p.stock) <= 0).length;
  return `
  <div class="space-y-4 fade">
    ${bajo.length ? `<div class="bg-amber-50 border-2 border-amber-200 text-amber-900 rounded-xl px-4 py-3 text-sm flex items-center gap-2">
      ⚠️ ${bajo.length} productos en niveles mínimos (stock ≤ 5); ${agotados} agotados. Repón inventario o ajusta existencias.
    </div>` : `<div class="bg-emerald-50 border-2 border-emerald-200 text-emerald-800 rounded-xl px-4 py-3 text-sm">
      ✅ Todo el inventario está por encima del mínimo (5 unidades).
    </div>`}
    ${seccion(`Stock bajo y agotados (${bajo.length})`, tabla([
      { t: "Código", v: (p) => `<span class="font-mono text-[10px] text-slate-500">${esc(p.codigo || "—")}</span>` },
      { t: "Producto", v: (p) => `<span class="font-medium">${esc(p.nombre_producto)}</span>` },
      { t: "Categoría", v: (p) => `<span class="text-xs text-slate-500">${esc(state.categorias.find((c) => c.id_categoria === p.categoria_id)?.nombre_categoria || "—")}</span>` },
      { t: "Precio", der: 1, v: (p) => `<span class="font-semibold">${money(p.precio)}</span>` },
      { t: "Stock", der: 1, v: (p) => `<span class="font-bold ${Number(p.stock) <= 0 ? "text-red-600" : "text-amber-600"}">${p.stock}</span> ${badgeStock(p.stock)}` },
      { t: "", der: 1, v: (p) => `<button data-ajuste="${p.id_producto}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Ajustar</button>` },
    ], bajo, { vacio: "Ningún producto con stock bajo" }))}
  </div>`;
}

function panelListado(lista) {
  return seccion(`Listado de productos (${lista.length})`, `
    <div class="flex flex-wrap gap-2 mb-3">
      <input id="filtroProd" value="${esc(filtro.texto)}" placeholder="Buscar por nombre o código…"
        class="grow min-w-[160px] px-3 py-2.5 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
      <select id="filtroVista" class="px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white">
        <option value="todos" ${filtro.vista === "todos" ? "selected" : ""}>Activos</option>
        <option value="inactivos" ${filtro.vista === "inactivos" ? "selected" : ""}>Inactivos (dados de baja)</option>
        <option value="bajo" ${filtro.vista === "bajo" ? "selected" : ""}>Stock bajo</option>
        <option value="agotado" ${filtro.vista === "agotado" ? "selected" : ""}>Agotados</option>
      </select>
      <select id="filtroCat" class="px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white">
        <option value="">Todas las categorías</option>
        ${state.categorias.map((c) => `<option value="${c.id_categoria}" ${String(filtro.cat) === String(c.id_categoria) ? "selected" : ""}>${esc(c.nombre_categoria)}</option>`).join("")}
      </select>
    </div>
    ${tabla([
      { t: "Código", v: (p) => `<span class="font-mono text-[10px] text-slate-500">${esc(p.codigo || "—")}</span>` },
      { t: "Producto", v: (p) => `<span class="font-medium">${esc(p.nombre_producto)}</span>` },
      { t: "Categoría", v: (p) => `<span class="text-xs text-slate-500">${esc(state.categorias.find((c) => c.id_categoria === p.categoria_id)?.nombre_categoria || "—")}</span>` },
      { t: "Costo", der: 1, v: (p) => `<span class="text-xs text-slate-500">${money(p.precio_compra)}</span>` },
      { t: "Precio", der: 1, v: (p) => `<span class="font-semibold">${money(p.precio)}</span>` },
      { t: "Stock", der: 1, v: (p) => `<span class="font-bold">${p.stock}</span> ${badgeStock(p.stock)}` },
      { t: "", der: 1, v: (p) => `${Number(p.activo) !== 1 ? `<span class="text-[10px] px-2 py-0.5 rounded-full bg-slate-200 text-slate-600 font-semibold">Inactivo</span> ` : ""}<button data-ajuste="${p.id_producto}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Ajustar</button> ${Number(p.activo) === 1 ? `<button data-baja="${p.id_producto}" class="text-[10px] px-2 py-1 rounded bg-red-50 text-red-600 font-semibold">Dar de baja</button>` : `<button data-alta="${p.id_producto}" class="text-[10px] px-2 py-1 rounded bg-emerald-50 text-emerald-700 font-semibold">Reactivar</button>`}` },
    ], lista, { vacio: "Sin productos que coincidan" })}`,
    `<button data-export="productos" class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar CSV</button>`);
}

function panelMovimientos() {
  return seccion("Historial de movimientos", tabla([
    { t: "Fecha", v: (m) => `<span class="text-xs">${fechaHora(m.fecha_hora)}</span>` },
    { t: "Producto", v: (m) => esc(mapaProductos().get(m.id_producto)?.nombre_producto || `#${m.id_producto}`) },
    { t: "Tipo", v: (m) => `<span class="text-[10px] px-2 py-0.5 rounded-full ${m.tipo === "SALIDA" ? "bg-amber-100 text-amber-700" : m.tipo === "AJUSTE" ? "bg-sky-100 text-sky-700" : "bg-emerald-100 text-emerald-700"}">${m.tipo}</span>` },
    { t: "Cantidad", der: 1, v: (m) => `<span class="font-bold ${m.cantidad >= 0 ? "text-emerald-600" : "text-red-600"}">${m.cantidad > 0 ? "+" : ""}${m.cantidad}</span>` },
    { t: "Motivo", v: (m) => `<span class="text-xs text-slate-500">${esc(m.motivo || "—")}</span>` },
    { t: "Usuario", v: (m) => `<span class="text-xs text-slate-400">${esc(state.usuarios.find((u) => u.id === m.id_usuario)?.nombre || "Sistema")}</span>` },
  ], movimientosRecientes(60), { vacio: "Sin movimientos registrados" }));
}

function panelValor() {
  const porCat = new Map();
  for (const p of state.productos.filter((x) => Number(x.activo) === 1)) {
    const k = p.categoria_id || 0;
    const a = porCat.get(k) || { unidades: 0, valor: 0, productos: 0 };
    a.unidades += Number(p.stock || 0);
    a.valor += Number(p.stock || 0) * Number(p.precio_compra || p.precio || 0);
    a.productos += 1;
    porCat.set(k, a);
  }
  const filas = [...porCat.entries()].map(([k, v]) => ({
    id: k,
    nombre: state.categorias.find((c) => c.id_categoria === k)?.nombre_categoria || "Sin categoría",
    ...v,
  })).sort((a, b) => b.valor - a.valor);
  return seccion("Valorización por categoría (a costo)", tabla([
    { t: "Categoría", v: (f) => esc(f.nombre) },
    { t: "Productos", der: 1, v: (f) => f.productos },
    { t: "Unidades", der: 1, v: (f) => num(f.unidades) },
    { t: "Valor", der: 1, v: (f) => `<span class="font-bold text-violet-600">${money(f.valor)}</span>` },
  ], filas, { vacio: "Sin productos" }));
}

function panelCategorias() {
  return `
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2">
      ${seccion("Categorías", tabla([
        { t: "Categoría", v: (c) => esc(c.nombre_categoria) },
        { t: "Código", v: (c) => `<span class="font-mono text-[10px] text-slate-500">${esc(c.codigo_categoria || "—")}</span>` },
        { t: "Productos", der: 1, v: (c) => state.productos.filter((p) => p.categoria_id === c.id_categoria).length },
        { t: "Tienda", der: 1, v: (c) => `<span class="text-[10px] px-2 py-0.5 rounded-full ${Number(c.visible_tienda) === 1 ? "bg-emerald-100 text-emerald-700" : "bg-slate-100 text-slate-500"}">${Number(c.visible_tienda) === 1 ? "Visible" : "Interna"}</span>` },
      ], state.categorias, { vacio: "Sin categorías" }))}
    </div>
    ${seccion("Nueva categoría", `
      <div class="space-y-3">
        ${input("Nombre", { id: "catNombre", placeholder: "Ej: Cuadernos" })}
        ${input("Código", { id: "catCodigo", placeholder: "Opcional" })}
        ${btnGuardar()}
      </div>`)}
  </div>`;
}

function btnGuardar() {
  return `<button id="btnGuardarCategoria" style="width:100%" class="px-4 py-2.5 rounded-lg text-sm font-semibold bg-emerald-600 text-white hover:opacity-90">Guardar categoría</button>`;
}

/* ---------------- modales ---------------- */
function modalAjuste(p) {
  const m = modal({
    titulo: "Ajustar stock", ancho: "max-w-sm",
    cuerpo: `
      <p class="text-sm mb-3"><b>${esc(p.nombre_producto)}</b><br /><span class="text-xs text-slate-500">Stock actual: ${p.stock}</span></p>
      ${input("Cantidad (+ entrada / − salida)", { id: "ajusteCant", type: "number", value: "0" })}
      <div class="mt-3">${input("Motivo", { id: "ajusteMotivo", placeholder: "Merma, corrección, devolución…" })}</div>
      <p class="text-[10px] text-slate-400 mt-2">El ajuste se registra en el historial de movimientos y actualiza el stock al instante.</p>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Aplicar ajuste", clase: "bg-[#1e3c72] text-white",
        fn: async (wrap) => {
          const cantidad = Number(wrap.querySelector("#ajusteCant").value || 0);
          if (!cantidad) return false;
          await repo.ajustarStock({
            productoId: p.id_producto, cantidad,
            motivo: wrap.querySelector("#ajusteMotivo").value || "Ajuste manual",
            idUsuario: ctxId(),
          });
          toast(`Stock ajustado: ${cantidad > 0 ? "+" : ""}${cantidad}`);
          await _ctx?.recargar();
          _ctx?.rerender();
          return true;
        },
      },
    ],
  });
  return m;
}

function modalProducto() {
  const cats = state.categorias.map((c) => ({ v: c.id_categoria, t: c.nombre_categoria }));
  modal({
    titulo: "Nuevo producto", ancho: "max-w-md",
    cuerpo: `
      <div class="space-y-3">
        ${input("Nombre", { id: "pNombre", placeholder: "Nombre del producto" })}
        <div class="grid grid-cols-2 gap-3">
          ${input("Código", { id: "pCodigo", placeholder: "PROD-0021" })}
          ${input("Código de barras", { id: "pBarras", placeholder: "Opcional" })}
        </div>
        <div class="grid grid-cols-3 gap-3">
          ${input("Precio", { id: "pPrecio", type: "number", step: "0.01" })}
          ${input("Costo", { id: "pCosto", type: "number", step: "0.01" })}
          ${input("Stock", { id: "pStock", type: "number" })}
        </div>
        ${select("Categoría", [{ v: "", t: "Sin categoría" }, ...cats], { id: "pCategoria" })}
      </div>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Guardar", clase: "bg-emerald-600 text-white",
        fn: async (w) => {
          const nombre = w.querySelector("#pNombre").value.trim();
          if (!nombre) return false;
          await repo.crearProducto({
            nombre_producto: nombre,
            codigo: w.querySelector("#pCodigo").value.trim() || null,
            codigo_barras: w.querySelector("#pBarras").value.trim() || null,
            precio: Number(w.querySelector("#pPrecio").value || 0),
            precio_compra: Number(w.querySelector("#pCosto").value || 0),
            stock: Number(w.querySelector("#pStock").value || 0),
            categoria_id: Number(w.querySelector("#pCategoria").value) || null,
            activo: 1,
          }, ctxId());
          toast("Producto creado");
          await _ctx?.recargar();
          _ctx?.rerender();
          return true;
        },
      },
    ],
  });
}

let _ctx = null;
export function setCtx(c) { _ctx = c; }
function ctxId() { return _ctx?.perfil?.usuarioId ?? null; }

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", async (e) => {
    const t = e.target.closest("[data-tab]");
    if (t) { tab = t.dataset.tab; ctx.rerender(); return; }

    if (e.target.closest("[data-nuevo]")) return modalProducto();

    const aj = e.target.closest("[data-ajuste]");
    if (aj) {
      const p = mapaProductos().get(+aj.dataset.ajuste);
      if (p) modalAjuste(p);
      return;
    }

    const baja = e.target.closest("[data-baja]");
    if (baja) {
      const p = mapaProductos().get(+baja.dataset.baja);
      if (!p) return;
      if (!(await confirmar(`Dar de baja "${p.nombre_producto}"? Dejará de aparecer en el POS y en las listas operativas, pero su historial se conserva.`, "Dar de baja"))) return;
      try {
        await repo.actualizarProducto(p.id_producto, { activo: 0 }, ctxId());
        toast("Producto dado de baja");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    const alta = e.target.closest("[data-alta]");
    if (alta) {
      const p = mapaProductos().get(+alta.dataset.alta);
      if (!p) return;
      if (!(await confirmar(`Reactivar "${p.nombre_producto}"? Volverá a aparecer en el POS y en las listas operativas.`, "Reactivar"))) return;
      try {
        await repo.actualizarProducto(p.id_producto, { activo: 1 }, ctxId());
        toast("Producto reactivado");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    if (e.target.closest("#btnGuardarCategoria")) {
      const nombre = root.querySelector("#catNombre")?.value.trim();
      if (!nombre) return toast("Escribe el nombre", "warn");
      try {
        await repo.crearCategoria({ nombre_categoria: nombre, codigo_categoria: root.querySelector("#catCodigo").value.trim() || null, activo: 1, visible_tienda: 1 }, ctxId());
        toast("Categoría creada");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    const ex = e.target.closest("[data-export]");
    if (ex) {
      const lista = productosFiltrados();
      exportarCSV("productos", [
        { titulo: "Código", valor: (p) => p.codigo },
        { titulo: "Producto", valor: (p) => p.nombre_producto },
        { titulo: "Categoría", valor: (p) => state.categorias.find((c) => c.id_categoria === p.categoria_id)?.nombre_categoria || "" },
        { titulo: "Costo", valor: (p) => p.precio_compra },
        { titulo: "Precio", valor: (p) => p.precio },
        { titulo: "Stock", valor: (p) => p.stock },
      ], lista);
    }
  });

  root.addEventListener("input", (ev) => {
    if (ev.target.id === "filtroProd") {
      filtro.texto = ev.target.value;
      const pos = ev.target.selectionStart;
      ctx.rerender();
      const n = root.querySelector("#filtroProd");
      if (n) { n.focus(); n.setSelectionRange(pos, pos); }
    }
  });
  root.addEventListener("change", (ev) => {
    if (ev.target.id === "filtroVista") { filtro.vista = ev.target.value; ctx.rerender(); }
    if (ev.target.id === "filtroCat") { filtro.cat = ev.target.value; ctx.rerender(); }
  });
}