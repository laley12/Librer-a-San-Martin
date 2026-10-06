const CACHE = "lsm-v7";
const BASE = ["/", "/index.html", "/movil.html", "/manifest.webmanifest", "/icono.svg"];
const ASSETS = [
  "/assets/app.js", "/assets/ui.js", "/assets/data.js", "/assets/supabase-client.js",
  "/assets/views/dashboard.js", "/assets/views/ventas.js", "/assets/views/inventario.js",
  "/assets/views/compras.js", "/assets/views/clientes.js", "/assets/views/usuarios.js",
  "/assets/views/reportes.js", "/assets/views/auditoria.js", "/assets/views/perfil.js",
];

self.addEventListener("install", (e) => {
  e.waitUntil(
    caches.open(CACHE)
      .then((c) => c.addAll([...BASE, ...ASSETS]))
      .then(() => self.skipWaiting())
      .catch(() => self.skipWaiting())
  );
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((k) => Promise.all(k.filter((x) => x !== CACHE).map((x) => caches.delete(x))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const url = new URL(e.request.url);
  
  // Solo manejar peticiones GET del mismo origen
  if (e.request.method !== "GET") return;
  if (url.origin !== self.location.origin) return;
  
  // No cachear APIs
  if (url.pathname.startsWith("/rest/") || url.pathname.startsWith("/auth/") || url.pathname.startsWith("/api/")) return;

  e.respondWith(
    fetch(e.request)
      .then((res) => {
        // Solo cachear respuestas exitosas
        if (res.ok) {
          const copia = res.clone();
          caches.open(CACHE).then((c) => c.put(e.request, copia)).catch(() => {});
        }
        return res;
      })
      .catch(() => caches.match(e.request).then((r) => r || caches.match("/movil.html")))
  );
});