const { Client } = require("pg");

const connectionString = "postgresql://postgres:galletas.oreo@db.tkypdjfmifywnwwjmcfh.supabase.co:5432/postgres";

async function run() {
  const client = new Client({
    connectionString,
    ssl: { rejectUnauthorized: false },
    connectionTimeoutMillis: 10000,
  });

  try {
    await client.connect();
    console.log(">>> CONECTADO CON EXITO A POSTGRESQL SUPABASE <<<");

    const usuariosRes = await client.query("SELECT * FROM public.usuarios;");
    console.log("PUBLIC.USUARIOS (" + usuariosRes.rows.length + " filas):");
    console.log(JSON.stringify(usuariosRes.rows, null, 2));

    const authRes = await client.query("SELECT id, email, confirmed_at, user_metadata FROM auth.users;");
    console.log("AUTH.USERS (" + authRes.rows.length + " filas):");
    console.log(JSON.stringify(authRes.rows, null, 2));

    const policiesRes = await client.query("SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check FROM pg_policies WHERE schemaname = 'public';");
    console.log("RLS POLICIES:");
    console.log(JSON.stringify(policiesRes.rows, null, 2));

    await client.end();
  } catch (err) {
    console.error("ERROR DE CONEXION/QUERY:", err);
  }
}

run();
