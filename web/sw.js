const CACHE = "lsm-v44";
const BASE = ["/", "/index.html", "/movil.html", "/manifest.webmanifest", "/icono.svg"];

self.addEventListener("install", (e) => {
  self.skipWaiting();
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys()
      .then((k) => Promise.all(k.map((x) => caches.delete(x))))
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

  // Network First: buscar siempre la versión fresca del servidor
  e.respondWith(
    fetch(e.request)
      .then((res) => {
        if (res.ok) {
          const copia = res.clone();
          caches.open(CACHE).then((c) => c.put(e.request, copia)).catch(() => {});
        }
        return res;
      })
      .catch(() => caches.match(e.request).then((r) => r || caches.match("/movil.html")))
  );
});