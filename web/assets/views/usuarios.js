import { fechaHora } from "../supabase-client.js";
import { state, repo } from "../data.js";
import { esc, toast, modal, tabla, seccion, input, select } from "../ui.js";

export const meta = { id: "usuarios", titulo: "Usuarios & Roles", icono: "🔐", grupo: "Control" };

const ROLES = ["Administrador", "Empleado", "Vendedor"];

/* Baja lógica (HU2/HU3): por defecto se ocultan los usuarios Inactivo;
   un administrador puede activar "Ver inactivos" para gestionarlos. */
let verInactivos = false;

export function render() {
  const soyAdmin = esAdmin();
  const activosCount = state.usuarios.filter((u) => String(u.estado).toLowerCase() === "activo").length;
  const listaUsuarios = verInactivos
    ? state.usuarios
    : state.usuarios.filter((u) => String(u.estado).toLowerCase() === "activo");
  const mios = state.perfiles.length ? state.perfiles : [];
  const rolEfectivo = (u) => state.perfiles.find((p) => Number(p.usuario_id) === Number(u.id))?.rol || u.rol;

  return `
  <div class="fade space-y-4">
    ${!soyAdmin ? `<div class="bg-amber-50 border border-amber-200 text-amber-800 rounded-xl px-4 py-3 text-sm">
      🔒 Solo un administrador puede crear usuarios o cambiar roles. Aquí puedes revisar la estructura de acceso.
    </div>` : ""}

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-4">
      ${seccion("Mi sesión", `
        <div class="space-y-2 text-sm">
          <div class="flex justify-between"><span class="text-slate-500">Usuario</span><b>${esc(_ctx?.perfil?.nombre || "—")}</b></div>
          <div class="flex justify-between"><span class="text-slate-500">Correo</span><b class="truncate">${esc(_ctx?.perfil?.email || "—")}</b></div>
          <div class="flex justify-between"><span class="text-slate-500">Rol</span><span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-blue-50 text-[#2a5298]">${esc(_ctx?.perfil?.rol || "—")}</span></div>
        </div>`)}

      ${seccion("Acceso por rol", `
        <div class="space-y-2 text-xs">
          <div class="flex gap-2"><span class="px-2 py-0.5 rounded-full bg-violet-100 text-violet-700 font-semibold shrink-0">Administrador</span>
            <span class="text-slate-500">Todo, incluidos usuarios, productos, categorías y anulaciones.</span></div>
          <div class="flex gap-2"><span class="px-2 py-0.5 rounded-full bg-blue-100 text-blue-700 font-semibold shrink-0">Empleado</span>
            <span class="text-slate-500">Ventas, compras, clientes, caja y ajuste de stock.</span></div>
          <div class="flex gap-2"><span class="px-2 py-0.5 rounded-full bg-emerald-100 text-emerald-700 font-semibold shrink-0">Vendedor</span>
            <span class="text-slate-500">Punto de venta, historial y consulta de inventario.</span></div>
        </div>`)}

      ${soyAdmin ? seccion("Invitar por correo (Supabase Auth)", `
        <p class="text-[11px] text-slate-500 mb-3">
          El alta real de la cuenta se hace en Supabase Auth. Luego enlaza el usuario con la fila de <code>usuarios</code> y su perfil.
        </p>
        <div class="space-y-2 text-xs">
          <div class="bg-slate-50 rounded-lg p-3">
            <b>1.</b> Crea el usuario en Supabase → Authentication → Users.
          </div>
          <div class="bg-slate-50 rounded-lg p-3">
            <b>2.</b> Inserta en <code>perfiles</code>: <code>id = auth.users.id</code>, <code>usuario_id</code>, <code>rol</code>.
          </div>
        </div>`) : ""}
    </div>

    ${seccion(`Usuarios del sistema (${activosCount} activos)`, tabla([
      { t: "Nombre", v: (u) => `<span class="font-medium">${esc(u.nombre)}</span>` },
      { t: "Usuario", v: (u) => `<span class="font-mono text-[10px] text-slate-500">${esc(u.usuario)}</span>` },
      { t: "Rol", v: (u) => `<span class="text-[10px] px-2 py-0.5 rounded-full ${rolEfectivo(u) === "Administrador" ? "bg-violet-100 text-violet-700" : rolEfectivo(u) === "Empleado" ? "bg-blue-100 text-blue-700" : "bg-emerald-100 text-emerald-700"}">${esc(rolEfectivo(u) || "—")}</span>` },
      { t: "Estado", v: (u) => `<span class="text-[10px] px-2 py-0.5 rounded-full ${String(u.estado).toLowerCase() === "activo" ? "bg-emerald-100 text-emerald-700" : "bg-red-100 text-red-700"}">${esc(u.estado || "—")}</span>` },
      { t: "Último acceso", v: (u) => `<span class="text-xs text-slate-400">${u.ultimo_acceso ? fechaHora(u.ultimo_acceso) : "Nunca"}</span>` },
      { t: "", der: 1, v: (u) => soyAdmin ? `<button data-editusr="${u.id}" class="text-[10px] px-2 py-1 rounded bg-blue-50 text-[#2a5298] font-semibold">Editar</button>` : "" },
    ], listaUsuarios, { vacio: "Sin usuarios activos" }),
      `<button data-toggle-inactivos class="text-[10px] px-2.5 py-1.5 rounded-lg font-semibold shrink-0 border border-slate-200 ${verInactivos ? "bg-[#1e3c72] text-white" : "bg-slate-100 text-slate-600"}">${verInactivos ? `Ocultar inactivos` : `Ver inactivos (${state.usuarios.length - activosCount})`}</button>`)}

    ${soyAdmin ? seccion("Perfiles de acceso (vinculados a Supabase Auth)", tabla([
      { t: "Nombre", v: (p) => esc(p.nombre || "—") },
      { t: "Cuenta de acceso", v: (p) => `<span class="font-mono text-[10px] text-slate-600">${esc(p.email || "—")}</span>` },
      { t: "Rol", v: (p) => `<span class="text-[10px] px-2 py-0.5 rounded-full bg-blue-50 text-[#2a5298] font-semibold">${esc(p.rol || "—")}${(p.pin_obligatorio || p.debe_cambiar_clave) ? ' <span class="text-amber-600">· PIN temporal</span>' : ""}</span>` },
      { t: "Usuario #", der: 1, v: (p) => (p.usuario_id ? esc(state.usuarios.find((u) => u.id === p.usuario_id)?.nombre || p.usuario_id) : "—") },
      { t: "", der: 1, v: (p) => `<button data-editperfil="${p.id}" class="text-[10px] px-2 py-1 rounded bg-violet-50 text-violet-700 font-semibold">Editar rol</button>` },
    ], mios, { vacio: "Sin perfiles" })) : ""}
  </div>`;
}

function esAdmin() {
  return String(_ctx?.perfil?.rol || "").toLowerCase() === "administrador";
}

function modalUsuario(id) {
  const u = state.usuarios.find((x) => x.id === id);
  const perfil = state.perfiles.find((p) => Number(p.usuario_id) === Number(id));
  modal({
    titulo: "Editar usuario", ancho: "max-w-sm",
    cuerpo: `<div class="space-y-3">
      ${input("Nombre", { id: "uNombre", value: esc(u.nombre) })}
      ${select("Rol", ROLES.map((r) => ({ v: r, t: r })), { id: "uRol", value: perfil?.rol || u.rol })}
      ${select("Estado", [{ v: "Activo", t: "Activo" }, { v: "Inactivo", t: "Inactivo" }], { id: "uEstado", value: u.estado })}
    </div>
    <p class="text-[10px] text-slate-400 mt-3">
      ${perfil
        ? `El rol se guarda en <code>perfiles</code> (${esc(perfil.rol)}) y se refleja en <code>usuarios</code>.`
        : `Este usuario no tiene perfil en <code>perfiles</code>: se actualizará solo la tabla legacy.`}
    </p>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Guardar", clase: "bg-[#1e3c72] text-white",
        fn: async (w) => {
          await repo.guardarUsuario({
            usuarioId: id,
            nombre: w.querySelector("#uNombre").value.trim(),
            rol: w.querySelector("#uRol").value,
            estado: w.querySelector("#uEstado").value,
            idUsuario: _ctx?.perfil?.usuarioId,
          });
          toast("Usuario actualizado");
          await _ctx?.recargar(); _ctx?.rerender();
          return true;
        },
      },
    ],
  });
}

function modalPerfil(uuid) {
  const p = state.perfiles.find((x) => x.id === uuid);
  if (!p) return;
  const vinculado = state.usuarios.find((u) => Number(u.id) === Number(p.usuario_id));
  modal({
    titulo: "Editar perfil de acceso", ancho: "max-w-sm",
    cuerpo: `<div class="space-y-3">
      ${input("Nombre", { id: "pNombre", value: esc(p.nombre || "") })}
      ${select("Rol", ROLES.map((r) => ({ v: r, t: r })), { id: "pRol", value: p.rol })}
      <p class="text-[11px] text-slate-400 bg-slate-50 border border-slate-100 rounded-lg px-3 py-2">
        Sede única: el perfil queda vinculado a la sucursal principal automáticamente.
      </p>
    </div>
    <p class="text-[10px] text-slate-400 mt-3">
      Vinculado a ${vinculado ? esc(vinculado.nombre) : "sin fila en usuarios"} (usuario #${esc(p.usuario_id ?? "—")}).
      Este rol es el que aplican las políticas RLS de Supabase.
    </p>`,
    acciones: [
      { texto: "Cancelar", clase: "bg-slate-200 text-slate-700", fn: () => false },
      {
        texto: "Guardar", clase: "bg-[#1e3c72] text-white",
        fn: async (w) => {
          await repo.guardarPerfil({
            perfilId: p.id,
            rol: w.querySelector("#pRol").value,
            nombre: w.querySelector("#pNombre").value.trim(),
            idUsuario: _ctx?.perfil?.usuarioId,
          });
          toast("Perfil actualizado");
          await _ctx?.recargar(); _ctx?.rerender();
          return true;
        },
      },
    ],
  });
}

let _ctx = null;

export function mount(root, ctx) {
  _ctx = ctx;
  root.addEventListener("click", (e) => {
    const ti = e.target.closest("[data-toggle-inactivos]");
    if (ti) { verInactivos = !verInactivos; ctx.rerender(); return; }
    const ed = e.target.closest("[data-editusr]");
    if (ed) return modalUsuario(+ed.dataset.editusr);
    const ep = e.target.closest("[data-editperfil]");
    if (ep) modalPerfil(ep.dataset.editperfil);
  });
}