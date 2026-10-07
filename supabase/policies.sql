-- ============================================================
-- Libreria San Martin - Supabase
-- Row Level Security + Realtime + automatizacion de stock
-- Ejecutar DESPUES de schema.sql
-- ============================================================

set search_path = public;

-- ------------------------------------------------------------
-- 1. Perfiles: liga auth.users (uuid) con usuarios (integer)
-- ------------------------------------------------------------
create table if not exists public.perfiles (
    id          uuid primary key references auth.users(id) on delete cascade,
    usuario_id  integer unique references public.usuarios(id) on delete cascade,
    rol         text not null default 'Empleado'
                 check (rol in ('Administrador', 'Empleado', 'Vendedor')),
    nombre      text,
    email       text,
    debe_cambiar_clave boolean not null default false,
    sucursal_id integer references public.sucursales(id_sucursal) on delete set null,
    created_at  timestamptz not null default now(),
    foto            text,
    telefono        text,
    correo_contacto text
);

comment on table public.perfiles is
    'Perfil de la app: un registro por usuario de auth.users, enlazado al usuario legacy';
comment on column public.perfiles.email is
    'Correo de la cuenta en Supabase Auth (derivado de usuarios.usuario)';
comment on column public.perfiles.debe_cambiar_clave is
    'true obliga a definir una contraseña propia en el primer ingreso';

alter table public.perfiles enable row level security;

-- columnas añadidas después del primer despliegue (idempotente)
alter table public.perfiles add column if not exists email text;
alter table public.perfiles add column if not exists debe_cambiar_clave boolean not null default false;
alter table public.perfiles add column if not exists pin_obligatorio boolean not null default false;
alter table public.perfiles add column if not exists foto text;
alter table public.perfiles add column if not exists telefono text;
alter table public.perfiles add column if not exists correo_contacto text;

-- ------------------------------------------------------------
-- 1b. Credenciales locales: PIN de 5 digitos
-- ------------------------------------------------------------
-- Supabase Auth exige contrasenas de 6 caracteres o mas, pero la libreria
-- usa PINs numericos cortos (Samuel / 12345). Ademas la tabla legacy
-- `usuarios` nunca tuvo columna de contrasena, asi que el login contra
-- auth.users quedaba en un callejon sin salida: habia que iniciar sesion
-- para fijar la clave, y sin clave no habia sesion.
--
-- El PIN se verifica en el servidor (web/api/login.js) y, si es correcto,
-- se emite una sesion real de Supabase Auth. El navegador nunca ve esta
-- tabla: RLS activa y sin politicas para anon/authenticated.
create table if not exists public.credenciales (
    id          uuid primary key references auth.users(id) on delete cascade,
    clave_hash  text not null,
    actualizado timestamptz not null default now()
);

comment on table public.credenciales is
    'Hash scrypt del PIN local. Solo service_role; nunca se expone al navegador.';
comment on column public.credenciales.clave_hash is
    'Formato scrypt$N$r$p$saltB64$hashB64';
comment on column public.perfiles.pin_obligatorio is
    'true obliga a definir un PIN propio en el primer ingreso';

alter table public.credenciales enable row level security;

revoke all on table public.credenciales from anon, authenticated;
grant select, insert, update on table public.credenciales to service_role;

-- ------------------------------------------------------------
-- 2. Funciones de apoyo para las políticas
-- ------------------------------------------------------------
create or replace function public.usuario_actual()
returns integer
language sql
stable
security definer
set search_path = public
as $$
    select usuario_id from public.perfiles where id = auth.uid()
$$;

create or replace function public.rol_actual()
returns text
language sql
stable
security definer
set search_path = public
as $$
    select coalesce(
        (select rol from public.perfiles where id = auth.uid()),
        'anonimo')
$$;

create or replace function public.es_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1 from public.perfiles
        where id = auth.uid() and rol = 'Administrador')
$$;

create or replace function public.es_operador()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
    select exists (
        select 1 from public.perfiles
        where id = auth.uid()
          and rol in ('Administrador', 'Empleado', 'Vendedor'))
$$;

-- ------------------------------------------------------------
-- 3. Politicas de perfiles
-- ------------------------------------------------------------
drop policy if exists perfiles_select on public.perfiles;
create policy perfiles_select on public.perfiles
    for select to authenticated
    using (id = auth.uid() or public.es_admin());

drop policy if exists perfiles_insert on public.perfiles;
create policy perfiles_insert on public.perfiles
    for insert to authenticated
    with check (id = auth.uid() or public.es_admin());

drop policy if exists perfiles_update on public.perfiles;
create policy perfiles_update on public.perfiles
    for update to authenticated
    using (id = auth.uid() or public.es_admin())
    with check (id = auth.uid() or public.es_admin());

drop policy if exists perfiles_delete on public.perfiles;
create policy perfiles_delete on public.perfiles
    for delete to authenticated
    using (public.es_admin());

-- ------------------------------------------------------------
-- 4. Catalogos de lectura publica (tienda online sin login)
-- ------------------------------------------------------------
alter table public.categorias enable row level security;
alter table public.productos  enable row level security;
alter table public.sucursales enable row level security;

drop policy if exists categorias_publica on public.categorias;
create policy categorias_publica on public.categorias
    for select to anon, authenticated
    using (activo = 1 and visible_tienda = 1);

drop policy if exists categorias_admin on public.categorias;
create policy categorias_admin on public.categorias
    for all to authenticated
    using (public.es_admin()) with check (public.es_admin());

drop policy if exists productos_publica on public.productos;
create policy productos_publica on public.productos
    for select to anon, authenticated
    using (activo = 1);

drop policy if exists productos_admin on public.productos;
create policy productos_admin on public.productos
    for all to authenticated
    using (public.es_admin()) with check (public.es_admin());

drop policy if exists sucursales_publica on public.sucursales;
create policy sucursales_publica on public.sucursales
    for select to anon, authenticated
    using (activo = 1);

drop policy if exists sucursales_admin on public.sucursales;
create policy sucursales_admin on public.sucursales
    for all to authenticated
    using (public.es_admin()) with check (public.es_admin());

-- ------------------------------------------------------------
-- 5. Tablas operativas: lectura/escritura para autenticados,
--    UPDATE y DELETE solo para administradores
-- ------------------------------------------------------------
do $$
declare
    t text;
    operativas text[] := array[
        'ventas', 'detalle_ventas', 'compras', 'detalle_compras',
        'clientes', 'proveedores', 'pedidos', 'detalle_pedidos',
        'devoluciones', 'detalle_devoluciones', 'recibos',
        'movimientos_inventario', 'historial_precios', 'caja_flujo',
        'apertura_caja', 'gastos', 'mensajes_chat', 'config_impresora'
    ];
begin
    foreach t in array operativas loop
        execute format('alter table public.%I enable row level security', t);

        execute format('drop policy if exists "%I_select" on public.%I', t, t);
        execute format(
            'create policy "%I_select" on public.%I for select to authenticated using (true)', t, t);

        execute format('drop policy if exists "%I_insert" on public.%I', t, t);
        execute format(
            'create policy "%I_insert" on public.%I for insert to authenticated with check (true)', t, t);

        execute format('drop policy if exists "%I_update" on public.%I', t, t);
        execute format(
            'create policy "%I_update" on public.%I for update to authenticated '
            'using (public.es_operador()) with check (public.es_operador())', t, t);

        execute format('drop policy if exists "%I_delete" on public.%I', t, t);
        execute format(
            'create policy "%I_delete" on public.%I for delete to authenticated using (public.es_admin())', t, t);
    end loop;
end $$;

-- El chat solo deja ver los mensajes propios
drop policy if exists mensajes_chat_own on public.mensajes_chat;
create policy mensajes_chat_own on public.mensajes_chat
    for select to authenticated
    using (id_remitente = public.usuario_actual()
           or id_destinatario = public.usuario_actual());

-- La venta se firma con el usuario autenticado
drop policy if exists ventas_insert on public.ventas;
drop policy if exists ventas_firma on public.ventas;
create policy ventas_firma on public.ventas
    for insert to authenticated
    with check (id_usuario is null or id_usuario = public.usuario_actual());

-- ------------------------------------------------------------
-- 6. Tablas sensibles: solo administradores
-- ------------------------------------------------------------
do $$
declare
    t text;
    sensibles text[] := array[
        'usuarios', 'auditoria', 'auditoria_categorias',
        'auditoria_clientes', 'auditoria_compras', 'auditoria_inventario',
        'auditoria_productos', 'auditoria_proveedores', 'auditoria_usuarios',
        'auditoria_ventas'
    ];
begin
    foreach t in array sensibles loop
        execute format('alter table public.%I enable row level security', t);

        execute format('drop policy if exists "%I_select" on public.%I', t, t);
        execute format(
            'create policy "%I_select" on public.%I for select to authenticated using (public.es_admin())', t, t);

        execute format('drop policy if exists "%I_insert" on public.%I', t, t);
        execute format(
            'create policy "%I_insert" on public.%I for insert to authenticated with check (public.es_operador())', t, t);

        execute format('drop policy if exists "%I_update" on public.%I', t, t);
        execute format(
            'create policy "%I_update" on public.%I for update to authenticated '
            'using (public.es_admin()) with check (public.es_admin())', t, t);

        execute format('drop policy if exists "%I_delete" on public.%I', t, t);
        execute format(
            'create policy "%I_delete" on public.%I for delete to authenticated using (public.es_admin())', t, t);
    end loop;
end $$;

-- Cada usuario puede leer su propio registro, el admin todos
drop policy if exists usuarios_propio on public.usuarios;
create policy usuarios_propio on public.usuarios
    for select to authenticated
    using (id = public.usuario_actual() or public.es_admin());

-- ------------------------------------------------------------
-- 7. Stock automatico: ventas Restan, compras Suman
--    (dispara el evento Realtime que escucha la app Flutter)
-- ------------------------------------------------------------
create or replace function public.fn_actualizar_stock_ventas()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    update public.productos
       set stock = greatest(coalesce(stock, 0) - coalesce(new.cantidad, 0), 0)
     where id_producto = new.producto_id;

    insert into public.movimientos_inventario
        (id_producto, tipo, cantidad, motivo, id_usuario)
    values
        (new.producto_id, 'SALIDA', coalesce(new.cantidad, 0), 'Venta #' || new.venta_id,
         public.usuario_actual());

    return new;
end $$;

drop trigger if exists trg_stock_ventas on public.detalle_ventas;
create trigger trg_stock_ventas
    after insert on public.detalle_ventas
    for each row execute function public.fn_actualizar_stock_ventas();

create or replace function public.fn_actualizar_stock_compras()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
    update public.productos
       set stock = coalesce(stock, 0) + coalesce(new.cantidad, 0)
     where id_producto = new.producto_id;

    insert into public.movimientos_inventario
        (id_producto, tipo, cantidad, motivo, id_usuario)
    values
        (new.producto_id, 'ENTRADA', coalesce(new.cantidad, 0), 'Compra #' || new.compra_id,
         public.usuario_actual());

    return new;
end $$;

drop trigger if exists trg_stock_compras on public.detalle_compras;
create trigger trg_stock_compras
    after insert on public.detalle_compras
    for each row execute function public.fn_actualizar_stock_compras();

-- ------------------------------------------------------------
-- 8. Realtime: ventas e inventario en la publicacion
-- ------------------------------------------------------------
do $$
declare
    t text;
begin
    foreach t in array array[
        'ventas', 'detalle_ventas', 'productos', 'movimientos_inventario',
        'compras', 'clientes', 'proveedores', 'caja_flujo', 'apertura_caja'
    ] loop
        if not exists (
            select 1 from pg_publication_tables
            where pubname = 'supabase_realtime' and schemaname = 'public'
              and tablename = t
        ) then
            execute format('alter publication supabase_realtime add table public.%I', t);
        end if;
    end loop;
end $$;