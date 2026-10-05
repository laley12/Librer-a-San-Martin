import { money, num, fecha, fechaHora } from "../supabase-client.js";
import { state, repo, kpis, topProveedores, mapaProductos } from "../data.js";
import { esc, toast, modal, tabla, seccion, input, select, exportarCSV } from "../ui.js";

export const meta = { id: "compras", titulo: "Compras & Proveedores", icono: "🛒", grupo: "Operación" };

let tab = "compras";
let carrito = [];
let filtroProv = "";

export function render() {
  return `
  <div class="fade space-y-4">
    <div class="grid grid-cols-3 gap-3">
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Compras del mes</div>
        <div class="text-xl font-bold text-orange-600">${money(kpis().comprasMes)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Proveedores</div>
        <div class="text-xl font-bold text-[#1e3c72]">${num(kpis().proveedores)}</div>
      </div>
      <div class="bg-white rounded-xl border border-slate-200 p-4">
        <div class="text-[10px] uppercase text-slate-400">Compras registradas</div>
        <div class="text-xl font-bold text-slate-700">${num(state.compras.length)}</div>
      </div>
    </div>

    <div class="flex gap-2 overflow-x-auto pb-1">
      ${[["compras", "🧾 Historial"], ["nueva", "➕ Nueva compra"], ["proveedores", "🚚 Proveedores"], ["pagos", "💳 Pagos"], ["top", "📊 Top proveedores"]]
        .map(([k, t]) => `<button data-tab="${k}" class="tab shrink-0 px-3.5 py-2 rounded-lg text-xs font-semibold ${tab === k ? "bg-[#1e3c72] text-white" : "bg-white text-slate-600 border border-slate-200"}">${t}</button>`).join("")}
    </div>
    <div>${panel()}</div>
  </div>`;
}

function panel() {
  if (tab === "nueva") return panelNueva();
  if (tab === "proveedores") return panelProveedores();
  if (tab === "pagos") return panelPagos();
  if (tab === "top") return panelTop();
  return panelHistorial();
}

function panelHistorial() {
  return seccion("Historial de compras", tabla([
    { t: "Compra", v: (c) => `<span class="font-bold">#${c.id_compra}</span>` },
    { t: "Fecha", v: (c) => `<span class="text-xs">${fecha(c.fecha)}</span>` },
    { t: "Proveedor", v: (c) => esc(state.proveedores.find((p) => p.id_proveedor === c.proveedor_id)?.nombre || "—") },
    { t: "Factura", v: (c) => `<span class="font-mono text-[10px] text-slate-500">${esc(c.nro_factura || "—")}</span>` },
    { t: "Productos", der: 1, v: (c) => state.detalle_compras.filter((d) => d.compra_id === c.id_compra).length },
    { t: "Total", der: 1, v: (c) => `<span class="font-bold text-orange-600">${money(c.total)}</span>` },
    { t: "", der: 1, v: (c) => `<button data-detalle="${c.id_compra}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Detalle</button>` },
  ], [...state.compras].sort((a, b) => new Date(b.fecha) - new Date(a.fecha)), { vacio: "Sin compras registradas" }),
    `<button data-export="compras" class="text-xs font-semibold text-[#2a5298] border border-[#2a5298] px-3 py-1.5 rounded-lg">Exportar CSV</button>`);
}

function panelNueva() {
  const total = carrito.reduce((s, l) => s + l.cantidad * l.precio, 0);
  const provs = state.proveedores.filter((p) => Number(p.activo) === 1);
  return `
  <div class="grid grid-cols-1 lg:grid-cols-5 gap-4">
    <div class="lg:col-span-3 space-y-4">
      ${seccion("Productos a recibir", `
        <input id="buscarCompra" list="listaCompra" placeholder="Buscar producto por nombre o código…"
          class="w-full px-3 py-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
        <datalist id="listaCompra">${state.productos.map((p) => `<option value="${esc(p.nombre_producto)} — ${p.codigo}">`).join("")}</datalist>
        <div class="grid grid-cols-2 gap-2 mt-3">
          <button data-add-buscar class="px-3 py-2 rounded-lg text-xs font-semibold bg-[#1e3c72] text-white">Añadir búsqueda</button>
          <span id="avisoBusqueda" class="self-center text-[10px] text-slate-400">Busca por nombre o código y pulsa añadir</span>
        </div>
        <div class="max-h-[40vh] overflow-y-auto space-y-1.5 mt-3">
          ${state.productos.slice(0, 40).map((p) => `
            <button data-add="${p.id_producto}" class="w-full flex items-center justify-between px-3 py-2 rounded-lg border border-slate-100 hover:border-[#2a5298] hover:bg-blue-50/40 text-left">
              <span class="min-w-0"><span class="block text-sm truncate">${esc(p.nombre_producto)}</span>
              <span class="block font-mono text-[10px] text-slate-400">${esc(p.codigo || "")} · stock ${p.stock}</span></span>
              <span class="text-xs font-semibold text-[#1e3c72] shrink-0">costo ${money(p.precio_compra)}</span>
            </button>`).join("")}
        </div>`)}
    </div>
    <div class="lg:col-span-2">
      <div class="lg:sticky lg:top-4 bg-white rounded-xl border border-slate-200 shadow-sm flex flex-col">
        <div class="px-4 py-3 border-b border-slate-100 font-semibold text-sm text-slate-700">Detalle de compra</div>
        <div class="grow divide-y divide-slate-50 max-h-[50vh] overflow-y-auto">
          ${carrito.length ? carrito.map((l) => `
            <div class="px-4 py-2.5 flex items-center justify-between gap-2">
              <div class="min-w-0"><div class="text-xs font-semibold truncate">${esc(l.nombre)}</div>
                <div class="text-[10px] text-slate-400">${money(l.precio)} × ${l.cantidad} = ${money(l.precio * l.cantidad)}</div></div>
              <div class="flex items-center gap-1 shrink-0">
                <button data-cant="${l.productoId}" data-delta="-1" class="w-6 h-6 rounded bg-slate-100 font-bold">−</button>
                <span class="w-6 text-center text-xs font-semibold">${l.cantidad}</span>
                <button data-cant="${l.productoId}" data-delta="1" class="w-6 h-6 rounded bg-slate-100 font-bold">+</button>
                <button data-quitar="${l.productoId}" class="text-slate-300 hover:text-red-500 text-lg">×</button>
              </div>
            </div>`).join("") : `<p class="text-sm text-slate-400 text-center py-10">Sin productos</p>`}
        </div>
        <div class="px-4 py-3 border-t border-slate-100 space-y-3">
          <div class="flex justify-between items-baseline">
            <span class="text-sm text-slate-500">Total</span>
            <span class="text-2xl font-bold text-orange-600">${money(total)}</span>
          </div>
          ${select("Proveedor", [{ v: "", t: "Sin proveedor" }, ...provs.map((p) => ({ v: p.id_proveedor, t: p.nombre }))], { id: "provCompra" })}
          ${input("Nro. de factura", { id: "factura", placeholder: "Opcional" })}
          <button id="btnGuardarCompra" class="w-full py-3 rounded-xl bg-orange-600 hover:bg-orange-700 text-white font-bold text-sm">
            Registrar compra ${carrito.length ? `· ${money(total)}` : ""}
          </button>
        </div>
      </div>
    </div>
  </div>`;
}

function panelProveedores() {
  const lista = filtroProv
    ? state.proveedores.filter((p) => p.nombre.toLowerCase().includes(filtroProv.toLowerCase()))
    : state.proveedores;
  return `
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
    <div class="lg:col-span-2">
      ${seccion(`Proveedores (${lista.length})`, `
        <input id="filtroProv" value="${esc(filtroProv)}" placeholder="Buscar proveedor…" class="w-full px-3 py-2.5 mb-3 border border-slate-300 rounded-lg text-sm outline-none focus:ring-2 focus:ring-[#2a5298]" />
        ${tabla([
          { t: "Proveedor", v: (p) => `<span class="font-medium">${esc(p.nombre)}</span>` },
          { t: "Teléfono", v: (p) => `<span class="text-xs text-slate-500">${esc(p.telefono || "—")}</span>` },
          { t: "Dirección", v: (p) => `<span class="text-xs text-slate-400">${esc(p.direccion || "—")}</span>` },
          { t: "Compras", der: 1, v: (p) => state.compras.filter((c) => c.proveedor_id === p.id_proveedor).length },
          { t: "Total", der: 1, v: (p) => `<span class="font-semibold text-orange-600">${money(state.compras.filter((c) => c.proveedor_id === p.id_proveedor).reduce((s, c) => s + Number(c.total || 0), 0))}</span>` },
          { t: "", der: 1, v: (p) => `<button data-editprov="${p.id_proveedor}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Editar</button>` },
        ], lista, { vacio: "Sin proveedores" })}`)}
    </div>
    ${seccion("Nuevo proveedor", `
      <div class="space-y-3">
        ${input("Nombre", { id: "provNombre", placeholder: "Distribuidora…" })}
        ${input("Teléfono", { id: "provTel", placeholder: "Opcional" })}
        ${input("Dirección", { id: "provDir", placeholder: "Opcional" })}
        <button id="btnGuardarProv" class="w-full px-4 py-2.5 rounded-lg text-sm font-semibold bg-emerald-600 text-white">Guardar proveedor</button>
      </div>`)}
  </div>`;
}

function panelPagos() {
  const filas = state.proveedores.map((p) => {
    const cs = state.compras.filter((c) => c.proveedor_id === p.id_proveedor);
    return { p, compras: cs.length, total: cs.reduce((s, c) => s + Number(c.total || 0), 0), ultima: cs.sort((a, b) => new Date(b.fecha) - new Date(a.fecha))[0]?.fecha };
  }).filter((f) => f.total > 0).sort((a, b) => b.total - a.total);
  return seccion("Pagos a proveedores", `
    <div class="mb-4 bg-blue-50 border border-blue-200 rounded-xl p-4 text-xs text-blue-800">
      ℹ️ El esquema actual no registra pagos parciales ni saldos: se muestra el total comprado por proveedor.
      Para saldos reales hace falta una tabla <code>pagos_proveedor</code> (pendiente de decisión del arquitecto).
    </div>
    ${tabla([
      { t: "Proveedor", v: (f) => `<span class="font-medium">${esc(f.p.nombre)}</span>` },
      { t: "Compras", der: 1, v: (f) => f.compras },
      { t: "Última compra", v: (f) => `<span class="text-xs">${f.ultima ? fecha(f.ultima) : "—"}</span>` },
      { t: "Total comprado", der: 1, v: (f) => `<span class="font-bold text-orange-600">${money(f.total)}</span>` },
    ], filas, { vacio: "Sin compras a proveedores" })}`);
}

function panelTop() {
  return seccion("Ranking de proveedores", tabla([
    { t: "#", v: (_, i) => `<span class="font-bold text-slate-300">${i + 1}</span>` },
    { t: "Proveedor", v: (p) => `<span class="font-medium">${esc(p.nombre)}</span>` },
    { t: "Compras", der: 1, v: (p) => p.compras },
    { t: "Total invertido", der: 1, v: (p) => `<span class="font-bold text-orange-600">${money(p.total)}</span>` },
  ], topProveedores(50), { vacio: "Sin datos" }));
}

function detalleCompra(id) {
  const c = state.compras.find((x) => x.id_compra === id);
  const lineas = state.detalle_compras.filter((d) => d.compra_id === id);
  modal({
    titulo: `Compra #${id}`, ancho: "max-w-md",
    cuerpo: `
      <div class="text-sm space-y-1 mb-4">
        <div class="flex justify-between"><span class="text-slate-500">Proveedor</span><b>${esc(state.proveedores.find((p) => p.id_proveedor === c?.proveedor_id)?.nombre || "—")}</b></div>
        <div class="flex justify-between"><span class="text-slate-500">Fecha</span><b>${fecha(c?.fecha)}</b></div>
        <div class="flex justify-between"><span class="text-slate-500">Factura</span><b>${esc(c?.nro_factura || "—")}</b></div>
      </div>
      ${tabla([
        { t: "Producto", v: (d) => esc(mapaProductos().get(d.producto_id)?.nombre_producto || `#${d.producto_id}`) },
        { t: "Cant", der: 1, v: (d) => d.cantidad },
        { t: "Precio", der: 1, v: (d) => money(d.precio) },
        { t: "Importe", der: 1, v: (d) => `<b>${money(d.cantidad * d.precio)}</b>` },
      ], lineas)}
      <div class="flex justify-between text-base font-bold border-t-2 border-slate-800 mt-3 pt-2"><span>TOTAL</span><span>${money(c?.total)}</span></div>`,
    acciones: [{ texto: "Cerrar", clase: "bg-slate-200 text-slate-700", fn: () => true }],
  });
}

let _ctx = null;

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", async (e) => {
    const t = e.target.closest("[data-tab]");
    if (t) { tab = t.dataset.tab; ctx.rerender(); return; }

    const add = e.target.closest("[data-add]");
    if (add) {
      const p = mapaProductos().get(+add.dataset.add);
      if (!p) return;
      const l = carrito.find((x) => x.productoId === p.id_producto);
      if (l) l.cantidad += 1;
      else carrito.push({ productoId: p.id_producto, nombre: p.nombre_producto, precio: Number(p.precio_compra || 0), cantidad: 1 });
      ctx.rerender();
      return;
    }

    if (e.target.closest("[data-add-buscar]")) {
      const txt = (root.querySelector("#buscarCompra")?.value || "").trim();
      const aviso = root.querySelector("#avisoBusqueda");
      if (!txt) { if (aviso) aviso.textContent = "Escribe o elige un producto primero"; return; }
      const normal = (s) => String(s || "").trim().toLowerCase();
      const exacto = state.productos.find((p) => normal(p.nombre_producto) === normal(txt)
        || normal(p.codigo) === normal(txt));
      const p = exacto || state.productos.find((x) => normal(x.nombre_producto).includes(normal(txt))
        || normal(x.codigo).includes(normal(txt)));
      if (!p) { if (aviso) aviso.textContent = `Sin coincidencias para "${txt}"`; return; }
      const l = carrito.find((x) => x.productoId === p.id_producto);
      if (l) l.cantidad += 1;
      else carrito.push({ productoId: p.id_producto, nombre: p.nombre_producto, precio: Number(p.precio_compra || 0), cantidad: 1 });
      const inp = root.querySelector("#buscarCompra");
      if (inp) inp.value = "";
      if (aviso) aviso.textContent = `${p.nombre_producto} agregado`;
      ctx.rerender();
      return;
    }
    const cant = e.target.closest("[data-cant]");
    if (cant) {
      const l = carrito.find((x) => x.productoId === +cant.dataset.cant);
      if (l) { l.cantidad += +cant.dataset.delta; if (l.cantidad <= 0) carrito = carrito.filter((x) => x.productoId !== l.productoId); }
      ctx.rerender(); return;
    }
    const q = e.target.closest("[data-quitar]");
    if (q) { carrito = carrito.filter((x) => x.productoId !== +q.dataset.quitar); ctx.rerender(); return; }

    const det = e.target.closest("[data-detalle]");
    if (det) return detalleCompra(+det.dataset.detalle);

    const ep = e.target.closest("[data-editprov]");
    if (ep) return editarProveedor(+ep.dataset.editprov);

    if (e.target.closest("#btnGuardarProv")) {
      const nombre = root.querySelector("#provNombre").value.trim();
      if (!nombre) return toast("Escribe el nombre", "warn");
      try {
        await repo.crearProveedor({ nombre, telefono: root.querySelector("#provTel").value || null, direccion: root.querySelector("#provDir").value || null, activo: 1 }, ctx.perfil.usuarioId);
        toast("Proveedor creado");
        await ctx.recargar(); ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    if (e.target.closest("#btnGuardarCompra")) {
      if (!carrito.length) return toast("Agrega productos", "warn");
      try {
        const r = await repo.registrarCompra({
          proveedorId: Number(root.querySelector("#provCompra").value) || null,
          nroFactura: root.querySelector("#factura").value.trim(),
          lineas: carrito, idUsuario: ctx.perfil.usuarioId,
        });
        carrito = [];
        toast(`Compra #${r.compra.id_compra} registrada · ${money(r.total)}`);
        await ctx.recargar();
        tab = "compras";
        ctx.rerender();
      } catch (err) { toast(err.message, "error"); }
      return;
    }

    const ex = e.target.closest("[data-export]");
    if (ex) exportarCSV("compras", [
      { titulo: "Compra", valor: (c) => c.id_compra },
      { titulo: "Fecha", valor: (c) => String(c.fecha).slice(0, 10) },
      { titulo: "Proveedor", valor: (c) => state.proveedores.find((p) => p.id_proveedor === c.proveedor_id)?.nombre || "" },
      { titulo: "Factura", valor: (c) => c.nro_factura || "" },
      { titulo: "Total", valor: (c) => c.total },
    ], [...state.compras].sort((a, b) => new Date(b.fecha) - new Date(a.fecha)));
  });

  root.addEventListener("input", (ev) => {
    if (ev.target.id === "filtroProv") {
      filtroProv = ev.target.value;
      const pos = ev.target.selectionStart;
      ctx.rerender();
      const n = root.querySelector("#filtroProv");
      if (n) { n.focus(); n.setSelectionRange(pos, pos); }
    }
  });
  root.addEventListener("keydown", (ev) => {
    if (ev.target.id === "buscarCompra" && ev.key === "Enter") {
      ev.preventDefault();
      const q = ev.target.value.trim().toLowerCase();
      const p = state.productos.find((x) => x.nombre_producto.toLowerCase().includes(q) || String(x.codigo || "").toLowerCase() === q);
      if (p) { tab = "nueva"; ctx.rerender(); setTimeout(() => { const b = root.querySelector(`[data-add="${p.id_producto}"]`); b?.click(); }, 30); }
    }
  });
}

function editarProveedor(id) {
  const p = state.proveedores.find((x) => x.id_proveedor === id);
  modal({
    titulo: "Editar proveedor", ancho: "max-w-sm",
    cuerpo: `<div class="space-y-3">
      ${input("Nombre", { id: "eNombre", value: esc(p.nombre) })}
      ${input("Teléfono", { id: "eTel", value: esc(p.telefono || "") })}
      ${input("Dirección", { id: "eDir", value: esc(p.direccion || "") })}
    </div>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Guardar", clase: "bg-[#1e3c72] text-white",
        fn: async (w) => {
          await repo.actualizarProveedor(id, {
            nombre: w.querySelector("#eNombre").value.trim(),
            telefono: w.querySelector("#eTel").value.trim() || null,
            direccion: w.querySelector("#eDir").value.trim() || null,
          }, _ctx?.perfil?.usuarioId);
          toast("Proveedor actualizado");
          await _ctx?.recargar(); _ctx?.rerender();
          return true;
        },
      },
    ],
  });
}