import { sb } from "./supabase-client.js";

/* =====================================================================
   CAPA DE DATOS UNIFICADA (esquema ER · 8 tablas)
   - un solo punto de carga, escritura y suscripción Realtime
   - ventas: cliente es texto libre (ventas.cliente)
   - stock: ajuste directo sobre productos.stock (sin movimientos)
   - sin caja, gastos, recibos, clientes, devoluciones ni auditorías
   ===================================================================== */

export const TABLAS = [
  "usuarios", "categorias", "proveedores", "productos",
  "compras", "detalle_compras", "ventas", "detalle_ventas",
];

export const state = { cargando: false, errores: [], ultimaCarga: null };
TABLAS.forEach((t) => (state[t] = []));

export let estadoRealtime = false;

async function traer(tabla, columnas = "*") {
  const { data, error } = await sb.from(tabla).select(columnas).limit(2000);
  if (error) {
    if (!state.errores.includes(error.message)) state.errores.push(error.message);
    return [];
  }
  return data || [];
}

export async function cargarTodo() {
  state.cargando = true;
  const resultados = await Promise.all(TABLAS.map((t) => traer(t)));
  TABLAS.forEach((t, i) => (state[t] = resultados[i]));
  state.ultimaCarga = new Date();
  state.cargando = false;
  return state;
}

async function insertar(tabla, fila) {
  const { data, error } = await sb.from(tabla).insert(fila).select().single();
  if (error) throw new Error(`${tabla}: ${error.message}`);
  return data;
}

async function actualizar(tabla, patch, filtro) {
  let q = sb.from(tabla).update(patch);
  for (const [k, v] of Object.entries(filtro)) q = q.eq(k, v);
  const { data, error } = await q.select().single();
  if (error) throw new Error(`${tabla}: ${error.message}`);
  return data;
}

async function tokenActual() {
  const { data } = await sb.auth.getSession();
  return data?.session?.access_token || "";
}

export function esActivo(fila) {
  return fila && Number(fila.activo ?? fila.estado) === 1;
}

export const repo = {
  /* ---- Ventas ---- */
  async registrarVenta({ cliente, metodoPago, lineas, idUsuario }) {
    if (!lineas.length) throw new Error("Agrega al menos un producto");
    const total = lineas.reduce((s, l) => s + Number(l.cantidad) * Number(l.precio), 0);
    const venta = await insertar("ventas", {
      fecha: new Date().toISOString().slice(0, 10),
      total,
      metodo_pago: metodoPago,
      cliente: String(cliente || "").trim() || "General",
      usuario_id: idUsuario || null,
    });
    for (const l of lineas) {
      await insertar("detalle_ventas", {
        venta_id: venta.id, producto_id: l.productoId, cantidad: l.cantidad, precio_unitario: l.precio,
      });
    }
    return { venta, total };
  },

  /* ---- Productos & Inventario ---- */
  async ajustarStock({ productoId, stock }) {
    if (stock == null || Number.isNaN(Number(stock)) || Number(stock) < 0) {
      throw new Error("Indica una cantidad válida");
    }
    return actualizar("productos", { stock: Number(stock) }, { id: productoId });
  },

  async crearProducto(datos) {
    return insertar("productos", {
      nombre: datos.nombre,
      codigo: datos.codigo || null,
      categoria_id: datos.categoria_id || null,
      precio_venta: Number(datos.precio_venta ?? datos.precio ?? 0),
      stock: Number(datos.stock ?? 0),
      activo: true,
    });
  },

  async actualizarProducto(id, datos) {
    const patch = { ...datos };
    if (patch.precio_venta != null) patch.precio_venta = Number(patch.precio_venta);
    return actualizar("productos", patch, { id });
  },

  async crearCategoria({ nombre, descripcion }) {
    if (!String(nombre || "").trim()) throw new Error("Escribe el nombre de la categoría");
    return insertar("categorias", { nombre, descripcion: descripcion || null });
  },

  /* ---- Compras & Proveedores ---- */
  async registrarCompra({ proveedorId, lineas, idUsuario }) {
    if (!lineas.length) throw new Error("Agrega al menos un producto");
    const total = lineas.reduce((s, l) => s + Number(l.cantidad) * Number(l.precio), 0);
    const compra = await insertar("compras", {
      proveedor_id: proveedorId || null,
      usuario_id: idUsuario || null,
      fecha: new Date().toISOString().slice(0, 10),
      total,
    });
    for (const l of lineas) {
      await insertar("detalle_compras", {
        compra_id: compra.id, producto_id: l.productoId,
        cantidad: l.cantidad, precio_unitario: l.precio,
      });
    }
    return { compra, total };
  },

  async crearProveedor(datos) {
    return insertar("proveedores", {
      nombre: datos.nombre,
      contacto: datos.contacto || null,
      telefono: datos.telefono || null,
    });
  },

  async actualizarProveedor(id, datos) {
    return actualizar("proveedores", datos, { id });
  },

  /* ---- Usuarios (tabla única) ---- */
  async guardarUsuario({ usuarioId, nombre, rol, estado, idUsuario }) {
    const booleano = estado === true || String(estado).toLowerCase() === "activo";
    return actualizar("usuarios", { nombre, rol, estado: booleano }, { id: usuarioId });
  },

  async cambiarEstadoUsuario({ usuarioId, estado, idUsuario }) {
    const booleano = estado === true || String(estado).toLowerCase() === "activo";
    return actualizar("usuarios", { estado: booleano }, { id: usuarioId });
  },

  async crearUsuario({ nombre, usuario, pin, rol, estado, idUsuario }) {
    const token = await tokenActual();
    const r = await fetch("/api/usuarios-nuevo", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
      body: JSON.stringify({ nombre, usuario, pin, rol, estado }),
    });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j.error || `No se pudo crear el usuario (${r.status})`);
    return j;
  },

  async cambiarPin({ usuarioId, pin }) {
    const token = await tokenActual();
    const r = await fetch("/api/usuario-pin", {
      method: "POST",
      headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
      body: JSON.stringify({ usuario_id: usuarioId, pin }),
    });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j.error || `No se pudo restablecer el PIN (${r.status})`);
    return j;
  },

  async cambiarNombrePropio({ usuarioId, nombre }) {
    return actualizar("usuarios", { nombre }, { id: usuarioId });
  },

  async actualizarPerfilPropio({ usuarioId, nombre, usuario, email, foto }) {
    const patch = {};
    if (nombre !== undefined) patch.nombre = nombre;
    if (usuario !== undefined) patch.usuario = usuario;
    if (email !== undefined) patch.email = email;
    if (foto !== undefined) patch.foto = foto;
    return actualizar("usuarios", patch, { id: usuarioId });
  },
};

/* ---------------- realtime ---------------- */
let canal = null;
export function conectarRealtime(cb) {
  if (canal) return canal;
  const tablas = ["ventas", "detalle_ventas", "productos", "compras"];
  canal = sb.channel("lsm-todo");
  for (const t of tablas) {
    canal.on("postgres_changes", { event: "*", schema: "public", table: t }, (p) => cb(t, p));
  }
  canal.subscribe((estado) => {
    estadoRealtime = estado === "SUBSCRIBED";
    cb("estado", estado);
  });
  return canal;
}

/* ---------------- cálculos compartidos ---------------- */
export function ventasVigentes() {
  return state.ventas;
}

export function mapaProductos() {
  return new Map(state.productos.map((p) => [p.id, p]));
}

export function nombreProducto(id) {
  return mapaProductos().get(id)?.nombre || `Producto #${id}`;
}

function mapaCompras() {
  return new Map(state.compras.map((c) => [c.id, c]));
}

/* Último precio de compra conocido por producto (proxy de costo unitario). */
export function costoUnitario(id) {
  let mejor = 0, mejorFecha = "";
  for (const d of state.detalle_compras) {
    if (String(d.producto_id) !== String(id)) continue;
    const f = String(mapaCompras().get(d.compra_id)?.fecha || "").slice(0, 10);
    if (!mejorFecha || f > mejorFecha) {
      mejor = Number(d.precio_unitario || 0);
      mejorFecha = f;
    }
  }
  return mejor;
}

/* ---------------- filtros por rango de fechas (HU9) ---------------- */
function isoFechaAShort(d) {
  return new Date(d).toISOString().slice(0, 10);
}

export function rangoFechas({ opcion = "mes", inicio = "", fin = "" } = {}) {
  const hoy = new Date();
  const hoyIso = isoFechaAShort(hoy);
  if (opcion === "hoy") return { inicio: hoyIso, fin: hoyIso };
  if (opcion === "semana") {
    const lunes = new Date(hoy);
    lunes.setDate(hoy.getDate() - ((hoy.getDay() + 6) % 7));
    return { inicio: isoFechaAShort(lunes), fin: hoyIso };
  }
  if (opcion === "personalizado") {
    const a = inicio ? String(inicio).slice(0, 10) : hoyIso;
    const b = fin ? String(fin).slice(0, 10) : hoyIso;
    return { inicio: a <= b ? a : b, fin: a <= b ? b : a };
  }
  const primero = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
  return { inicio: isoFechaAShort(primero), fin: hoyIso };
}

export function enPeriodo(fecha, { inicio, fin }) {
  const k = String(fecha || "").slice(0, 10);
  return k >= inicio && k <= fin;
}

export function kpisRango(r) {
  const rc = rangoFechas(r);
  const v = state.ventas.filter((x) => enPeriodo(x.fecha, rc));
  const ids = new Set(v.map((x) => x.id));
  const detalle = state.detalle_ventas.filter((d) => ids.has(d.venta_id));
  const unidades = detalle.reduce((s, d) => s + Number(d.cantidad || 0), 0);
  const ventas = v.reduce((s, x) => s + Number(x.total || 0), 0);
  const costo = detalle.reduce((s, d) => s + Number(d.cantidad || 0) * costoUnitario(d.producto_id), 0);
  const comprasTbl = state.compras.filter((c) => enPeriodo(c.fecha, rc));
  const compras = comprasTbl.reduce((s, c) => s + Number(c.total || 0), 0);
  const activos = state.productos.filter((p) => Number(p.activo) === 1);
  return {
    inicio: rc.inicio, fin: rc.fin,
    ventas, count: v.length, unidades, ticket: v.length ? ventas / v.length : 0,
    compras, comprasCount: comprasTbl.length,
    margen: ventas - costo, utilidad: ventas - costo,
    productos: activos.length,
    stockBajo: activos.filter((p) => Number(p.stock) <= 5).length,
    agotados: activos.filter((p) => Number(p.stock) <= 0).length,
    valorInventario: activos.reduce((s, p) => s + Number(p.stock || 0) * (costoUnitario(p.id) || Number(p.precio_venta || 0)), 0),
    proveedores: state.proveedores.length,
  };
}

/* Serie diaria (ventas y compras) completa dentro del rango, sin huecos. */
export function serieRango(r) {
  const rc = rangoFechas(r);
  const m = new Map();
  const d = new Date(rc.inicio + "T00:00:00");
  const fin = new Date(rc.fin + "T00:00:00");
  for (let x = new Date(d); x.getTime() <= fin.getTime(); x.setDate(x.getDate() + 1)) {
    m.set(isoFechaAShort(x), { ventas: 0, compras: 0 });
  }
  for (const v of state.ventas) {
    const k = String(v.fecha).slice(0, 10);
    if (m.has(k)) m.get(k).ventas += Number(v.total || 0);
  }
  for (const c of state.compras) {
    const k = String(c.fecha).slice(0, 10);
    if (m.has(k)) m.get(k).compras += Number(c.total || 0);
  }
  return [...m.entries()].map(([fecha, v]) => ({ fecha, ...v }));
}

export function kpis() {
  const hoy = new Date().toISOString().slice(0, 10);
  const mes = hoy.slice(0, 7);
  const vHoy = state.ventas.filter((v) => String(v.fecha).slice(0, 10) === hoy);
  const vMes = state.ventas.filter((v) => String(v.fecha).slice(0, 7) === mes);
  const idsHoy = new Set(vHoy.map((v) => v.id));
  const unidades = state.detalle_ventas.filter((d) => idsHoy.has(d.venta_id))
    .reduce((s, d) => s + Number(d.cantidad || 0), 0);
  const activos = state.productos.filter((p) => Number(p.activo) === 1);
  const comprasMes = state.compras.filter((c) => String(c.fecha).slice(0, 7) === mes);
  const costoVentasMes = state.detalle_ventas
    .filter((d) => vMes.some((v) => v.id === d.venta_id))
    .reduce((s, d) => s + Number(d.cantidad || 0) * costoUnitario(d.producto_id), 0);
  const ingresosMes = vMes.reduce((s, v) => s + Number(v.total || 0), 0);
  return {
    hoyTotal: vHoy.reduce((s, v) => s + Number(v.total || 0), 0),
    hoyCount: vHoy.length,
    unidadesHoy: unidades,
    ticket: vHoy.length ? vHoy.reduce((s, v) => s + Number(v.total || 0), 0) / vHoy.length : 0,
    mesTotal: ingresosMes,
    mesCount: vMes.length,
    comprasMes: comprasMes.reduce((s, c) => s + Number(c.total || 0), 0),
    comprasMesCount: comprasMes.length,
    margen: ingresosMes - costoVentasMes,
    utilidadMes: ingresosMes - costoVentasMes,
    ingresosDia: vHoy.reduce((s, v) => s + Number(v.total || 0), 0),
    productos: activos.length,
    stockBajo: activos.filter((p) => Number(p.stock) <= 5).length,
    agotados: activos.filter((p) => Number(p.stock) <= 0).length,
    valorInventario: activos.reduce((s, p) => s + Number(p.stock || 0) * (costoUnitario(p.id) || Number(p.precio_venta || 0)), 0),
    proveedores: state.proveedores.length,
  };
}

export function serie(dias = 7) {
  const m = new Map();
  for (let i = dias - 1; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    m.set(d.toISOString().slice(0, 10), { ventas: 0, compras: 0 });
  }
  for (const v of state.ventas) {
    const k = String(v.fecha).slice(0, 10);
    if (m.has(k)) m.get(k).ventas += Number(v.total || 0);
  }
  for (const c of state.compras) {
    const k = String(c.fecha).slice(0, 10);
    if (m.has(k)) m.get(k).compras += Number(c.total || 0);
  }
  return [...m.entries()].map(([fecha, v]) => ({ fecha, ...v }));
}

export function topProductos(n = 5, idsVentas) {
  const ids = idsVentas instanceof Set ? idsVentas : new Set(state.ventas.map((v) => v.id));
  const m = new Map();
  for (const d of state.detalle_ventas) {
    if (!ids.has(d.venta_id)) continue;
    const a = m.get(d.producto_id) || { unidades: 0, ingresos: 0, costo: 0 };
    a.unidades += Number(d.cantidad || 0);
    a.ingresos += Number(d.cantidad || 0) * Number(d.precio_unitario || 0);
    m.set(d.producto_id, a);
  }
  return [...m.entries()].map(([id, v]) => {
    const p = state.productos.find((x) => x.id === id);
    return { id, ...v, nombre: p?.nombre || `#${id}`, codigo: p?.codigo || "—" };
  })
    .sort((a, b) => b.unidades - a.unidades).slice(0, n);
}

export function topProveedores(n = 5, idsCompras) {
  const compras = idsCompras instanceof Set
    ? state.compras.filter((c) => idsCompras.has(c.id))
    : state.compras;
  return state.proveedores.map((p) => {
    const cs = compras.filter((c) => c.proveedor_id === p.id);
    return {
      id: p.id, nombre: p.nombre,
      compras: cs.length, total: cs.reduce((s, c) => s + Number(c.total || 0), 0),
    };
  }).sort((a, b) => b.total - a.total).slice(0, n);
}