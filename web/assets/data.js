import { sb } from "./supabase-client.js";

/* =====================================================================
   CAPA DE DATOS UNIFICADA
   - una sola carga para todas las vistas (desktop y móvil)
   - un solo punto de escritura (repos)
   - una sola suscripción Realtime
   ===================================================================== */

export const TABLAS = [
  "ventas", "detalle_ventas", "recibos", "productos", "categorias", "clientes",
  "proveedores", "compras", "detalle_compras", "movimientos_inventario", "usuarios",
  "perfiles", "sucursales", "caja_flujo", "gastos", "apertura_caja", "devoluciones",
  "detalle_devoluciones", "historial_precios", "config_impresora",
];

export const TABLAS_AUDITORIA = [
  { tabla: "auditoria_usuarios", modulo: "Usuarios", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
  { tabla: "auditoria_productos", modulo: "Productos", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
  { tabla: "auditoria_ventas", modulo: "Ventas", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
  { tabla: "auditoria_compras", modulo: "Compras", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
  { tabla: "auditoria_proveedores", modulo: "Proveedores", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
  { tabla: "auditoria_categorias", modulo: "Categorías", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
  { tabla: "auditoria_clientes", modulo: "Clientes", columnas: "id_auditoria, accion, fecha_hora" },
  { tabla: "auditoria_inventario", modulo: "Inventario", columnas: "id_auditoria, id_usuario, accion, fecha_hora" },
];

export const state = { cargando: false, errores: [], ultimaCarga: null };
TABLAS.forEach((t) => (state[t] = []));
TABLAS_AUDITORIA.forEach((a) => (state[a.tabla] = []));

/* ---------------- carga ---------------- */
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
  const resultados = await Promise.all([
    ...TABLAS.map((t) => traer(t)),
    ...TABLAS_AUDITORIA.map((a) => traer(a.tabla, a.columnas)),
  ]);
  [...TABLAS, ...TABLAS_AUDITORIA.map((a) => a.tabla)].forEach((t, i) => (state[t] = resultados[i]));
  state.ultimaCarga = new Date();
  state.cargando = false;
  return state;
}

/* ---------------- escrituras ---------------- */
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

async function auditar(tabla, idUsuario, accion) {
  const meta = TABLAS_AUDITORIA.find((a) => a.tabla === tabla);
  const fila = { accion, fecha_hora: new Date().toISOString() };
  if (meta?.columnas.includes("id_usuario")) fila.id_usuario = idUsuario;
  const { error } = await sb.from(tabla).insert(fila);
  if (error) console.warn("auditoría no registrada:", tabla, error.message);
}

export const repo = {
  /* ---- Ventas & Caja ---- */
  async registrarVenta({ clienteId, metodoPago, lineas, idUsuario, estado = "Completado" }) {
    if (!lineas.length) throw new Error("Agrega al menos un producto");
    const total = lineas.reduce((s, l) => s + l.cantidad * l.precio, 0);
    const venta = await insertar("ventas", {
      fecha: new Date().toISOString().slice(0, 10),
      total,
      metodo_pago: metodoPago,
      id_usuario: idUsuario,
      id_cliente: clienteId || null,
      estado,
    });
    for (const l of lineas) {
      await insertar("detalle_ventas", {
        venta_id: venta.id_venta, producto_id: l.productoId, cantidad: l.cantidad, precio: l.precio,
      });
    }
    const recibo = await insertar("recibos", {
      venta_id: venta.id_venta,
      numero_recibo: `R-${String(venta.id_venta).padStart(6, "0")}`,
    });
    await auditar("auditoria_ventas", idUsuario, `Registró venta #${venta.id_venta} por Bs ${total.toFixed(2)}`);
    return { venta, recibo, total };
  },

  async anularVenta(ventaId, idUsuario) {
    const venta = state.ventas.find((v) => v.id_venta === ventaId);
    if (!venta) throw new Error("La venta no existe");
    if (String(venta.estado).toLowerCase() === "anulado") throw new Error("La venta ya está anulada");
    const det = state.detalle_ventas.filter((d) => d.venta_id === ventaId);
    for (const d of det) {
      await insertar("movimientos_inventario", {
        id_producto: d.producto_id, tipo: "AJUSTE", cantidad: d.cantidad,
        motivo: `Anulación venta #${ventaId}`, id_usuario: idUsuario,
      });
    }
    await actualizar("ventas", { estado: "Anulado" }, { id_venta: ventaId });
    await auditar("auditoria_ventas", idUsuario, `Anuló venta #${ventaId} y devolvió el stock`);
    return { ventaId, lineas: det.length };
  },

  async devolverVenta({ ventaId, lineas, motivo, idUsuario }) {
    const venta = state.ventas.find((v) => v.id_venta === ventaId);
    if (!venta) throw new Error("La venta no existe");
    const devolucion = await insertar("devoluciones", {
      id_venta: ventaId, id_usuario: idUsuario, motivo: motivo || null,
      total_devuelto: lineas.reduce((s, l) => s + l.cantidad * l.precio_unitario, 0),
      fecha: new Date().toISOString(),
    });
    for (const l of lineas) {
      await insertar("detalle_devoluciones", {
        id_devolucion: devolucion.id_devolucion, id_producto: l.productoId,
        cantidad: l.cantidad, precio_unitario: l.precio_unitario,
        subtotal: l.cantidad * l.precio_unitario,
      });
      await insertar("movimientos_inventario", {
        id_producto: l.productoId, tipo: "AJUSTE", cantidad: l.cantidad,
        motivo: `Devolución venta #${ventaId}`, id_usuario: idUsuario,
      });
    }
    await auditar("auditoria_ventas", idUsuario, `Registró devolución #${devolucion.id_devolucion} de la venta #${ventaId}`);
    return devolucion;
  },

  async abrirCaja({ montoInicial, idUsuario, observaciones }) {
    return insertar("apertura_caja", {
      id_usuario: idUsuario, monto_inicial: montoInicial, monto_esperado: montoInicial,
      observaciones: observaciones || null, fecha_apertura: new Date().toISOString(),
    });
  },

  async cerrarCaja({ montoFinal, idUsuario, observaciones }) {
    const abierta = state.apertura_caja.find((a) => Number(a.activo) === 1);
    if (!abierta) throw new Error("No hay una caja abierta");
    return actualizar("apertura_caja",
      {
        monto_final: montoFinal,
        fecha_cierre: new Date().toISOString(),
        activo: 0,
        observaciones: observaciones ? `${abierta.observaciones ? abierta.observaciones + " | " : ""}Cierre: ${observaciones}` : abierta.observaciones,
      },
      { id: abierta.id });
  },

  async crearFlujoCaja({ montoApertura, idUsuario }) {
    return insertar("caja_flujo", {
      id_usuario: idUsuario, monto_apertura: montoApertura, estado: "ABIERTA",
      fecha_apertura: new Date().toISOString(),
    });
  },

  async cerrarFlujoCaja({ id, montoCierre }) {
    return actualizar("caja_flujo",
      { monto_cierre: montoCierre, estado: "CERRADA", fecha_cierre: new Date().toISOString() }, { id_caja: id });
  },

  async crearGasto({ descripcion, monto, idUsuario, categoria = "Operativo" }) {
    const g = await insertar("gastos", {
      descripcion, monto, id_usuario: idUsuario, fecha: new Date().toISOString(),
    });
    await auditar("auditoria_ventas", idUsuario, `Registró gasto: ${descripcion} Bs ${monto}`);
    return g;
  },

  /* ---- Productos & Inventario ---- */
  async ajustarStock({ productoId, cantidad, motivo, idUsuario }) {
    const m = await insertar("movimientos_inventario", {
      id_producto: productoId, tipo: "AJUSTE", cantidad, motivo, id_usuario: idUsuario,
      fecha_hora: new Date().toISOString(),
    });
    await auditar("auditoria_inventario", idUsuario, `Ajustó stock del producto #${productoId}: ${cantidad > 0 ? "+" : ""}${cantidad}`);
    return m;
  },

  async crearProducto(datos, idUsuario) {
    const p = await insertar("productos", datos);
    await auditar("auditoria_productos", idUsuario, `Creó producto: ${datos.nombre_producto}`);
    return p;
  },

  async actualizarProducto(id, datos, idUsuario) {
    const anterior = state.productos.find((p) => p.id_producto === id);
    const p = await actualizar("productos", datos, { id_producto: id });
    if (anterior && (datos.precio != null || datos.precio_compra != null)) {
      const antes = Number(anterior.precio || 0), ahora = Number(p.precio || 0);
      if (antes !== ahora) {
        await insertar("historial_precios", {
          id_producto: id, precio_anterior: antes, precio_nuevo: ahora,
          tipo: "VENTA", id_usuario: idUsuario,
          fecha_hora: new Date().toISOString(),
        }).catch(() => {});
      }
    }
    await auditar("auditoria_productos", idUsuario, `Actualizó producto #${id}`);
    return p;
  },

  async crearCategoria(datos, idUsuario) {
    const c = await insertar("categorias", datos);
    await auditar("auditoria_categorias", idUsuario, `Creó categoría: ${datos.nombre_categoria}`);
    return c;
  },

  /* ---- Compras & Proveedores ---- */
  async registrarCompra({ proveedorId, nroFactura, lineas, idUsuario }) {
    if (!lineas.length) throw new Error("Agrega al menos un producto");
    const total = lineas.reduce((s, l) => s + l.cantidad * l.precio, 0);
    const compra = await insertar("compras", {
      proveedor_id: proveedorId || null, nro_factura: nroFactura || null,
      fecha: new Date().toISOString().slice(0, 10), total,
    });
    for (const l of lineas) {
      await insertar("detalle_compras", {
        compra_id: compra.id_compra, producto_id: l.productoId, cantidad: l.cantidad, precio: l.precio,
      });
    }
    await auditar("auditoria_compras", idUsuario, `Registró compra #${compra.id_compra} por Bs ${total.toFixed(2)}`);
    return { compra, total };
  },

  async crearProveedor(datos, idUsuario) {
    const p = await insertar("proveedores", datos);
    await auditar("auditoria_proveedores", idUsuario, `Creó proveedor: ${datos.nombre}`);
    return p;
  },

  async actualizarProveedor(id, datos, idUsuario) {
    const p = await actualizar("proveedores", datos, { id_proveedor: id });
    await auditar("auditoria_proveedores", idUsuario, `Actualizó proveedor #${id}`);
    return p;
  },

  /* ---- Clientes ---- */
  async crearCliente(datos, idUsuario) {
    const c = await insertar("clientes", datos);
    await auditar("auditoria_clientes", idUsuario, `Creó cliente: ${datos.nombre_cliente}`);
    return c;
  },

  async actualizarCliente(id, datos, idUsuario) {
    const c = await actualizar("clientes", datos, { id_cliente: id });
    await auditar("auditoria_clientes", idUsuario, `Actualizó cliente #${id}`);
    return c;
  },

  /* ---- Usuarios ---- */
  async actualizarUsuario(id, datos, idUsuario) {
    return actualizar("usuarios", datos, { id });
  },

  async actualizarPerfil(uuid, datos) {
    return actualizar("perfiles", datos, { id: uuid });
  },

  /* El rol que manda es perfiles.rol; usuarios.rol es la columna legacy. */
  async guardarUsuario({ usuarioId, nombre, rol, estado, idUsuario }) {
    const u = await actualizar("usuarios", { nombre, rol, estado }, { id: usuarioId });
    const perfil = state.perfiles.find((p) => Number(p.usuario_id) === Number(usuarioId));
    if (perfil) {
      await actualizar("perfiles", { rol, nombre }, { id: perfil.id });
    }
    await auditar("auditoria_usuarios", idUsuario,
      `Actualizó usuario #${usuarioId}: rol ${rol}, estado ${estado}`);
    return { usuario: u, perfilActualizado: Boolean(perfil) };
  },

  async guardarPerfil({ perfilId, rol, nombre, sucursalId, idUsuario }) {
    const p = await actualizar("perfiles",
      { rol, nombre, sucursal_id: sucursalId || null }, { id: perfilId });
    const vinculado = state.usuarios.find((u) => Number(u.id) === Number(p.usuario_id));
    if (vinculado) await actualizar("usuarios", { rol, nombre }, { id: vinculado.id });
    await auditar("auditoria_usuarios", idUsuario, `Actualizó perfil de acceso #${p.usuario_id}: rol ${rol}`);
    return p;
  },

  /* ---- Ajustes ---- */
  async guardarConfigImpresora(datos) {
    const actual = state.config_impresora[0];
    if (actual) return actualizar("config_impresora", datos, { id: actual.id });
    return insertar("config_impresora", datos);
  },
};

/* ---------------- realtime ---------------- */
let canal = null;
export function conectarRealtime(cb) {
  if (canal) return canal;
  const tablas = ["ventas", "detalle_ventas", "productos", "movimientos_inventario",
    "compras", "clientes", "proveedores", "caja_flujo", "apertura_caja"];
  canal = sb.channel("lsm-todo");
  for (const t of tablas) {
    canal.on("postgres_changes", { event: "*", schema: "public", table: t }, (p) => cb(t, p));
  }
  canal.subscribe((estado) => cb("estado", estado));
  return canal;
}

/* ---------------- cálculos compartidos ---------------- */
export function ventasVigentes() {
  return state.ventas.filter((v) => String(v.estado || "Completado").toLowerCase() !== "anulado");
}

export function mapaProductos() {
  return new Map(state.productos.map((p) => [p.id_producto, p]));
}

export function nombreProducto(id) {
  return mapaProductos().get(id)?.nombre_producto || `Producto #${id}`;
}

export function kpis() {
  const hoy = new Date().toISOString().slice(0, 10);
  const mes = hoy.slice(0, 7);
  const vigentes = ventasVigentes();
  const vHoy = vigentes.filter((v) => String(v.fecha).slice(0, 10) === hoy);
  const vMes = vigentes.filter((v) => String(v.fecha).slice(0, 7) === mes);
  const idsHoy = new Set(vHoy.map((v) => v.id_venta));
  const unidades = state.detalle_ventas.filter((d) => idsHoy.has(d.venta_id))
    .reduce((s, d) => s + Number(d.cantidad || 0), 0);
  const activos = state.productos.filter((p) => Number(p.activo) === 1);
  const comprasMes = state.compras.filter((c) => String(c.fecha).slice(0, 7) === mes);
  const costoVentasMes = state.detalle_ventas
    .filter((d) => vMes.some((v) => v.id_venta === d.venta_id))
    .reduce((s, d) => {
      const p = state.productos.find((x) => x.id_producto === d.producto_id);
      return s + Number(d.cantidad || 0) * Number(p?.precio_compra || 0);
    }, 0);
  const ingresosMes = vMes.reduce((s, v) => s + Number(v.total || 0), 0);
  const gastosMes = state.gastos.filter((g) => String(g.fecha).slice(0, 7) === mes)
    .reduce((s, g) => s + Number(g.monto || 0), 0);
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
    gastosMes,
    utilidadMes: ingresosMes - costoVentasMes - gastosMes,
    productos: activos.length,
    stockBajo: activos.filter((p) => Number(p.stock) <= 5).length,
    agotados: activos.filter((p) => Number(p.stock) <= 0).length,
    valorInventario: activos.reduce((s, p) => s + Number(p.stock || 0) * Number(p.precio_compra || p.precio || 0), 0),
    clientes: state.clientes.filter((c) => Number(c.activo) === 1).length,
    proveedores: state.proveedores.filter((p) => Number(p.activo) === 1).length,
    movimientos: state.movimientos_inventario.length,
  };
}

export function serie(dias = 7) {
  const m = new Map();
  for (let i = dias - 1; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    m.set(d.toISOString().slice(0, 10), { ventas: 0, compras: 0 });
  }
  for (const v of ventasVigentes()) {
    const k = String(v.fecha).slice(0, 10);
    if (m.has(k)) m.get(k).ventas += Number(v.total || 0);
  }
  for (const c of state.compras) {
    const k = String(c.fecha).slice(0, 10);
    if (m.has(k)) m.get(k).compras += Number(c.total || 0);
  }
  return [...m.entries()].map(([fecha, v]) => ({ fecha, ...v }));
}

export function topProductos(n = 5) {
  const vigentes = new Set(ventasVigentes().map((v) => v.id_venta));
  const m = new Map();
  for (const d of state.detalle_ventas) {
    if (!vigentes.has(d.venta_id)) continue;
    const a = m.get(d.producto_id) || { unidades: 0, ingresos: 0, costo: 0 };
    a.unidades += Number(d.cantidad || 0);
    a.ingresos += Number(d.cantidad || 0) * Number(d.precio || 0);
    m.set(d.producto_id, a);
  }
  return [...m.entries()].map(([id, v]) => ({ id, ...v, ...nombre(id) }))
    .sort((a, b) => b.unidades - a.unidades).slice(0, n);
  function nombre(id) {
    const p = state.productos.find((x) => x.id_producto === id);
    return { nombre: p?.nombre_producto || `#${id}`, codigo: p?.codigo || "—" };
  }
}

export function topProveedores(n = 5) {
  return state.proveedores.map((p) => {
    const cs = state.compras.filter((c) => c.proveedor_id === p.id_proveedor);
    return {
      id: p.id_proveedor, nombre: p.nombre,
      compras: cs.length, total: cs.reduce((s, c) => s + Number(c.total || 0), 0),
    };
  }).sort((a, b) => b.total - a.total).slice(0, n);
}

export function topClientes(n = 5) {
  const vigentes = ventasVigentes();
  return state.clientes.map((c) => {
    const vs = vigentes.filter((v) => v.id_cliente === c.id_cliente);
    return {
      id: c.id_cliente, nombre: c.nombre_cliente,
      compras: vs.length, total: vs.reduce((s, v) => s + Number(v.total || 0), 0),
    };
  }).sort((a, b) => b.total - a.total).slice(0, n);
}

export function movimientosRecientes(n = 10) {
  return [...state.movimientos_inventario]
    .sort((a, b) => new Date(b.fecha_hora) - new Date(a.fecha_hora)).slice(0, n);
}

export function auditTrail(filtro = "Todas", busqueda = "") {
  const q = busqueda.trim().toLowerCase();
  const filas = [];
  for (const a of TABLAS_AUDITORIA) {
    if (filtro !== "Todas" && filtro !== a.modulo) continue;
    for (const r of state[a.tabla]) {
      if (q && !String(r.accion || "").toLowerCase().includes(q)) continue;
      filas.push({
        modulo: a.modulo, accion: r.accion,
        fecha: r.fecha_hora,
        usuario: state.usuarios.find((u) => u.id === r.id_usuario)?.nombre || "Sistema",
      });
    }
  }
  return filas.sort((a, b) => new Date(b.fecha) - new Date(a.fecha));
}