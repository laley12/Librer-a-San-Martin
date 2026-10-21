-- ============================================================
-- Libreria San Martin - Alineacion al Diagrama ER Oficial
-- Proyecto: tkypdjfmifywnwwjmcfh
--
-- Convierte el esquema legacy (import MySQL, 30+ tablas) en el
-- modelo relacional de EXACTAMENTE 8 tablas del anteproyecto:
--
--   usuarios        id, nombre, usuario, clave, rol, estado
--   categorias      id, nombre, descripcion
--   proveedores     id, nombre, contacto, telefono
--   productos       id, codigo, nombre, categoria_id, precio_venta,
--                   stock, activo
--   compras         id, proveedor_id, usuario_id, fecha, total
--   detalle_compras id, compra_id, producto_id, cantidad, precio_unitario
--   ventas          id, usuario_id, cliente, fecha, metodo_pago, total
--   detalle_ventas  id, venta_id, producto_id, cantidad, precio_unitario
--
-- Negocio de sede unica (sin sucursales): se eliminan todas las
-- referencias a sucursal y las tablas auxiliares (perfiles,
-- credenciales, clientes, caja, gastos, movimientos, auditorias...).
--
-- AUTENTICACION: el PIN se guarda con hash scrypt en usuarios.clave.
-- Supabase Auth (auth.users) conserva la cuenta por correo sintetico
-- {usuario}@libreriasanmartin.app y las funciones RLS derivan el
-- usuario autenticado desde auth.jwt().email.
--
-- Ejecutar ENTERO en el SQL Editor de Supabase, y despues seed_libreria.sql
-- ============================================================

set search_path = public;

begin;

-- ------------------------------------------------------------
-- 1. Elimina el esquema legacy completo
--    (auth.users y auth.* NO se tocan: conservan las sesiones)
-- ------------------------------------------------------------
do $$
declare t text;
  legacy text[] := array[
    'auditoria','auditoria_categorias','auditoria_clientes','auditoria_compras',
    'auditoria_inventario','auditoria_productos','auditoria_proveedores',
    'auditoria_usuarios','auditoria_ventas','caja_flujo','clientes','gastos',
    'movimientos_inventario','sucursales','apertura_caja','config_impresora',
    'devoluciones','mensajes_chat','pedidos','recibos','detalle_devoluciones',
    'detalle_pedidos','historial_precios','perfiles','credenciales','sesiones',
    'categorias','proveedores','usuarios','ventas','compras','productos',
    'detalle_compras','detalle_ventas'
  ];
begin
  foreach t in array legacy loop
    if exists (select 1 from information_schema.tables
               where table_schema = 'public' and table_name = t) then
      execute format('drop table if exists public.%I cascade', t);
    end if;
  end loop;
end $$;

-- Las funciones de la app (legacy o intentos parciales) deben eliminarse
-- antes de recrearlas: CREATE OR REPLACE no permite cambiar el tipo de retorno.
drop function if exists public.usuario_actual();
drop function if exists public.rol_actual();
drop function if exists public.es_admin();
drop function if exists public.es_operador();
drop function if exists public.fn_actualizar_stock_ventas();
drop function if exists public.fn_actualizar_stock_compras();

-- ------------------------------------------------------------
-- 2. Las 8 tablas del Diagrama ER
-- ------------------------------------------------------------

create table public.usuarios (
    id     uuid primary key default gen_random_uuid(),
    nombre text not null,
    usuario text not null unique,
    clave  text not null,              -- hash scrypt$N$r$p$sal$dk
    rol    text not null default 'Empleado'
           check (rol in ('Administrador','Empleado','Vendedor')),
    estado boolean not null default true  -- true = activo (baja logica)
);
comment on column public.usuarios.clave is
  'Hash scrypt del PIN local (formato scrypt$N$r$p$salB64$hashB64). Solo service_role.';

create table public.categorias (
    id          uuid primary key default gen_random_uuid(),
    nombre      text not null,
    descripcion text default null
);

create table public.proveedores (
    id       uuid primary key default gen_random_uuid(),
    nombre   text not null,
    contacto text default null,
    telefono text default null
);

create table public.productos (
    id          uuid primary key default gen_random_uuid(),
    codigo      text not null unique,
    nombre      text not null,
    categoria_id uuid references public.categorias(id) on delete set null,
    precio_venta numeric(10,2) not null default 0,
    stock       integer not null default 0,
    activo      boolean not null default true   -- baja logica
);

create table public.compras (
    id           uuid primary key default gen_random_uuid(),
    proveedor_id uuid references public.proveedores(id) on delete set null,
    usuario_id   uuid references public.usuarios(id) on delete set null,
    fecha        date not null default current_date,
    total        numeric(10,2) not null default 0
);

create table public.detalle_compras (
    id              uuid primary key default gen_random_uuid(),
    compra_id       uuid not null references public.compras(id) on delete cascade,
    producto_id     uuid not null references public.productos(id) on delete cascade,
    cantidad        integer not null check (cantidad >= 0),
    precio_unitario numeric(10,2) not null default 0
);

create table public.ventas (
    id          uuid primary key default gen_random_uuid(),
    usuario_id  uuid references public.usuarios(id) on delete set null,
    cliente     text default null,
    fecha       date not null default current_date,
    metodo_pago text not null default 'Efectivo',
    total       numeric(10,2) not null default 0
);

create table public.detalle_ventas (
    id              uuid primary key default gen_random_uuid(),
    venta_id        uuid not null references public.ventas(id) on delete cascade,
    producto_id     uuid not null references public.productos(id) on delete cascade,
    cantidad        integer not null check (cantidad >= 0),
    precio_unitario numeric(10,2) not null default 0
);

create index if not exists productos_categoria_idx on public.productos(categoria_id);
create index if not exists compras_proveedor_idx   on public.compras(proveedor_id);
create index if not exists compras_usuario_idx     on public.compras(usuario_id);
create index if not exists ventas_usuario_idx      on public.ventas(usuario_id);
create index if not exists ventas_fecha_idx        on public.ventas(fecha);
create index if not exists det_compra_compra_idx   on public.detalle_compras(compra_id);
create index if not exists det_venta_venta_idx     on public.detalle_ventas(venta_id);

-- ------------------------------------------------------------
-- 3. Funciones RLS (derivan el usuario/rol desde auth.jwt().email:
--    correo sintetico = lower(usuarios.usuario) || '@libreriasanmartin.app')
-- ------------------------------------------------------------
create or replace function public.usuario_actual()
returns uuid
language sql stable security definer set search_path = public as $$
  select u.id
    from public.usuarios u
   where u.estado
     and lower(u.usuario) = lower(split_part(auth.jwt() ->> 'email', '@', 1))
   limit 1;
$$;

create or replace function public.rol_actual()
returns text
language sql stable security definer set search_path = public as $$
  select coalesce(
    (select u.rol from public.usuarios u
      where lower(u.usuario) = lower(split_part(auth.jwt() ->> 'email', '@', 1))
      limit 1), 'anonimo');
$$;

create or replace function public.es_admin()
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.usuarios u
     where lower(u.usuario) = lower(split_part(auth.jwt() ->> 'email', '@', 1))
       and u.rol = 'Administrador' and u.estado);
$$;

create or replace function public.es_operador()
returns boolean
language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.usuarios u
     where lower(u.usuario) = lower(split_part(auth.jwt() ->> 'email', '@', 1))
       and u.rol in ('Administrador','Empleado','Vendedor') and u.estado);
$$;

-- ------------------------------------------------------------
-- 4. Row Level Security
-- ------------------------------------------------------------

alter table public.usuarios        enable row level security;
alter table public.categorias      enable row level security;
alter table public.proveedores     enable row level security;
alter table public.productos       enable row level security;
alter table public.compras         enable row level security;
alter table public.detalle_compras enable row level security;
alter table public.ventas          enable row level security;
alter table public.detalle_ventas  enable row level security;

-- usuarios: cada quien su registro; solo admin ve/toca el resto
drop policy if exists usuarios_select on public.usuarios;
create policy usuarios_select on public.usuarios
  for select to authenticated
  using (id = public.usuario_actual() or public.es_admin());

drop policy if exists usuarios_insert on public.usuarios;
create policy usuarios_insert on public.usuarios
  for insert to authenticated
  with check (public.es_admin());

drop policy if exists usuarios_update on public.usuarios;
create policy usuarios_update on public.usuarios
  for update to authenticated
  using (id = public.usuario_actual() or public.es_admin())
  with check (id = public.usuario_actual() or public.es_admin());

drop policy if exists usuarios_delete on public.usuarios;
create policy usuarios_delete on public.usuarios
  for delete to authenticated
  using (public.es_admin());

-- catalogos: lectura publica, escritura segun rol
drop policy if exists categorias_publica on public.categorias;
create policy categorias_publica on public.categorias
  for select to anon, authenticated using (true);

drop policy if exists categorias_admin on public.categorias;
create policy categorias_admin on public.categorias
  for all to authenticated using (public.es_admin()) with check (public.es_admin());

drop policy if exists productos_publica on public.productos;
create policy productos_publica on public.productos
  for select to anon using (activo);

drop policy if exists productos_select on public.productos;
create policy productos_select on public.productos
  for select to authenticated using (true);

drop policy if exists productos_insert on public.productos;
create policy productos_insert on public.productos
  for insert to authenticated with check (public.es_operador());

drop policy if exists productos_update on public.productos;
create policy productos_update on public.productos
  for update to authenticated using (public.es_operador()) with check (public.es_operador());

drop policy if exists productos_delete on public.productos;
create policy productos_delete on public.productos
  for delete to authenticated using (public.es_admin());

-- tablas operativas: lectura autenticada, escritura segun rol
do $$
declare t text;
  operativas text[] := array[
    'proveedores','compras','detalle_compras','ventas','detalle_ventas'
  ];
begin
  foreach t in array operativas loop
    execute format('drop policy if exists "%I_select" on public.%I', t, t);
    execute format('create policy "%I_select" on public.%I for select to authenticated using (true)', t, t);
    execute format('drop policy if exists "%I_insert" on public.%I', t, t);
    execute format('create policy "%I_insert" on public.%I for insert to authenticated with check (true)', t, t);
    execute format('drop policy if exists "%I_update" on public.%I', t, t);
    execute format('create policy "%I_update" on public.%I for update to authenticated '
                   'using (public.es_operador()) with check (public.es_operador())', t, t);
    execute format('drop policy if exists "%I_delete" on public.%I', t, t);
    execute format('create policy "%I_delete" on public.%I for delete to authenticated using (public.es_admin())', t, t);
  end loop;
end $$;

-- proveedores: lectura publica (select p/anon para el formulario)
drop policy if exists proveedores_publica on public.proveedores;
create policy proveedores_publica on public.proveedores
  for select to anon using (true);

-- la venta se firma con quien la registra
drop policy if exists ventas_firma on public.ventas;
create policy ventas_firma on public.ventas
  for insert to authenticated
  with check (usuario_id is null or usuario_id = public.usuario_actual());

-- ------------------------------------------------------------
-- 5. Stock automatico: compras suman, ventas restan
-- ------------------------------------------------------------
create or replace function public.fn_actualizar_stock_ventas()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.productos
     set stock = greatest(coalesce(stock,0) - coalesce(new.cantidad,0), 0)
   where id = new.producto_id;
  return new;
end $$;
drop trigger if exists trg_stock_ventas on public.detalle_ventas;
create trigger trg_stock_ventas
  after insert on public.detalle_ventas
  for each row execute function public.fn_actualizar_stock_ventas();

create or replace function public.fn_actualizar_stock_compras()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  update public.productos
     set stock = coalesce(stock,0) + coalesce(new.cantidad,0)
   where id = new.producto_id;
  return new;
end $$;
drop trigger if exists trg_stock_compras on public.detalle_compras;
create trigger trg_stock_compras
  after insert on public.detalle_compras
  for each row execute function public.fn_actualizar_stock_compras();

-- ------------------------------------------------------------
-- 6. Realtime
-- ------------------------------------------------------------
do $$
declare t text;
begin
  foreach t in array array['ventas','detalle_ventas','productos','compras'] loop
    if not exists (
      select 1 from pg_publication_tables
       where pubname = 'supabase_realtime' and schemaname = 'public'
         and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end $$;

-- ------------------------------------------------------------
-- 7. Cuenta Administradora (Paso 1 del sprint review)
--    Gustavo es el administrador del negocio. Su cuenta en
--    auth.users (gustavo@libreriasanmartin.app) ya existe y su
--    PIN sigue siendo 12345 (hash scrypt generado con web/api/_lib.js).
-- ------------------------------------------------------------
insert into public.usuarios (nombre, usuario, clave, rol, estado) values (
  'Gustavo Guachalla', 'gustavo',
   'scrypt$16384$8$1$2gvvgUTo9knmxLsL5N/pXg==$3YrlPauTWFlddyQ1ul9G09sukXCrblV9A4FuEx7586c=',
   'Administrador', true);

commit;