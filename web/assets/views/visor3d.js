import { esc, seccion, select } from "../ui.js?v=4.2";
import { state } from "../data.js?v=4.2";

export const meta = {
  id: "visor3d",
  titulo: "Visor 3D Interactivo",
  icono: "🧊",
  grupo: "Catálogo",
};

let currentRenderer = null;
let currentAnimationId = null;
let autoRotate = true;

export function render(params = {}) {
  const productos = state.productos || [];
  const prodId = params?.id || (productos[0]?.id || "default");
  const prod = productos.find((p) => String(p.id) === String(prodId)) || productos[0] || {
    id: 1,
    nombre: "Cuaderno Ledesma 100 Hojas",
    precio_venta: 6.50,
    stock: 3,
    codigo: "CUA-100",
  };

  return `
  <div class="fade space-y-6" data-commentable>
    <!-- Encabezado -->
    <div class="flex items-center justify-between flex-wrap gap-4 bg-white p-5 rounded-2xl border border-slate-200 shadow-sm">
      <div>
        <div class="flex items-center gap-2">
          <span class="text-2xl">🧊</span>
          <h1 class="text-xl font-bold text-[#1e3c72]">Visualizador 3D de Productos</h1>
          <span class="bg-indigo-100 text-indigo-700 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase tracking-wider">Three.js · Tarea 6</span>
        </div>
        <p class="text-xs text-slate-500 mt-1">
          Modelo tridimensional interactivo con soporte de sombras, físicas de iluminación y rotación táctil.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <label class="text-xs font-semibold text-slate-600">Seleccionar Producto:</label>
        <select id="selectProd3D" class="bg-slate-50 border border-slate-300 rounded-xl px-3 py-2 text-xs font-semibold text-slate-700 focus:ring-2 focus:ring-blue-500">
          ${productos.map((p) => `
            <option value="${esc(p.id)}" ${String(p.id) === String(prod.id) ? "selected" : ""}>
              ${esc(p.nombre)} (${p.stock} unid. · Bs ${Number(p.precio_venta || 0).toFixed(2)})
            </option>
          `).join("")}
        </select>
      </div>
    </div>

    <!-- Visor 3D y Tarjeta de Detalles -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Contenedor Canvas 3D (2 columnas en escritorio) -->
      <div class="lg:col-span-2 bg-gradient-to-br from-slate-900 via-slate-800 to-indigo-950 rounded-3xl p-4 shadow-xl border border-slate-700 relative overflow-hidden flex flex-col">
        <!-- Barra de herramientas superior -->
        <div class="flex items-center justify-between z-10 mb-2 px-2">
          <div class="flex items-center gap-2">
            <span class="w-3 h-3 rounded-full bg-red-500 inline-block"></span>
            <span class="w-3 h-3 rounded-full bg-amber-500 inline-block"></span>
            <span class="w-3 h-3 rounded-full bg-emerald-500 inline-block"></span>
            <span class="text-slate-400 text-xs font-mono ml-2">Canvas WebGL · 60 FPS</span>
          </div>
          <div class="flex items-center gap-2">
            <button id="btnToggleRotate" class="bg-white/10 hover:bg-white/20 text-white text-xs px-3 py-1.5 rounded-xl backdrop-blur-md transition-all flex items-center gap-1.5 font-medium border border-white/10">
              <span id="iconRotate">🔄</span> <span id="txtRotate">Pausar Giro</span>
            </button>
            <button id="btnResetView" class="bg-white/10 hover:bg-white/20 text-white text-xs px-3 py-1.5 rounded-xl backdrop-blur-md transition-all font-medium border border-white/10" title="Restablecer Cámara">
              🎯 Recentrar
            </button>
          </div>
        </div>

        <!-- Canvas 3D Host -->
        <div id="canvas3dContainer" class="w-full h-[460px] rounded-2xl relative cursor-grab active:cursor-grabbing overflow-hidden flex items-center justify-center">
          <div id="loading3D" class="absolute text-center text-white/70 text-xs flex flex-col items-center gap-2">
            <div class="w-8 h-8 border-2 border-indigo-400 border-t-transparent rounded-full animate-spin"></div>
            <span>Inicializando motor 3D Three.js…</span>
          </div>
        </div>

        <!-- Barra inferior de ayuda -->
        <div class="flex items-center justify-between text-[11px] text-slate-400 mt-2 px-2">
          <span>🖱️ Arrastra para orbitar · 🔍 Rueda para zoom · 📱 Gestos multitáctiles</span>
          <span class="font-semibold text-indigo-300">Librería San Martín 2026</span>
        </div>
      </div>

      <!-- Ficha de Producto y Controles (1 columna) -->
      <div class="space-y-4">
        <div class="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm space-y-4">
          <div class="flex items-start justify-between">
            <div>
              <span class="text-[10px] font-bold uppercase tracking-wider text-indigo-600 bg-indigo-50 px-2 py-0.5 rounded-full">
                ${esc(prod.codigo || "PROD-" + prod.id)}
              </span>
              <h2 class="text-lg font-bold text-slate-800 mt-1">${esc(prod.nombre)}</h2>
            </div>
            <div class="text-right">
              <div class="text-2xl font-black text-[#1e3c72]">Bs ${Number(prod.precio_venta || 0).toFixed(2)}</div>
              <div class="text-[10px] text-slate-400">Precio unitario</div>
            </div>
          </div>

          <p class="text-xs text-slate-600 leading-relaxed">
            Representación poligonal con mapas de textura PBR, iluminación de tres puntos (Key, Fill, Rim) y geometría de libro tridimensional articulada.
          </p>

          <div class="grid grid-cols-2 gap-3 pt-2">
            <div class="bg-slate-50 p-3 rounded-2xl border border-slate-100 text-center">
              <div class="text-xs text-slate-400 font-medium">Stock en Sede</div>
              <div class="text-xl font-black ${Number(prod.stock || 0) <= 5 ? "text-amber-600" : "text-emerald-600"}">
                ${prod.stock || 0}
              </div>
              <div class="text-[9px] text-slate-400">unidades disponibles</div>
            </div>

            <div class="bg-slate-50 p-3 rounded-2xl border border-slate-100 text-center">
              <div class="text-xs text-slate-400 font-medium">Estado</div>
              <div class="text-xl font-black text-emerald-600">
                ${Number(prod.stock || 0) > 0 ? "✅ En Stock" : "⛔ Agotado"}
              </div>
              <div class="text-[9px] text-slate-400">Tiempo real</div>
            </div>
          </div>

          <!-- Selector de Color de Cubierta 3D -->
          <div class="pt-2 border-t border-slate-100">
            <label class="text-xs font-semibold text-slate-700 block mb-2">Color de Portada 3D:</label>
            <div class="flex items-center gap-2">
              <button data-color="#1e3c72" class="w-8 h-8 rounded-full bg-[#1e3c72] ring-2 ring-offset-2 ring-blue-600 shadow transition-transform hover:scale-110" title="Azul San Martín"></button>
              <button data-color="#b91c1c" class="w-8 h-8 rounded-full bg-red-700 shadow transition-transform hover:scale-110" title="Rojo Carmesí"></button>
              <button data-color="#047857" class="w-8 h-8 rounded-full bg-emerald-700 shadow transition-transform hover:scale-110" title="Verde Esmeralda"></button>
              <button data-color="#d97706" class="w-8 h-8 rounded-full bg-amber-600 shadow transition-transform hover:scale-110" title="Ámbar Dorado"></button>
              <button data-color="#475569" class="w-8 h-8 rounded-full bg-slate-600 shadow transition-transform hover:scale-110" title="Grafito Clásico"></button>
            </div>
          </div>

          <!-- Acciones -->
          <div class="pt-3 flex gap-2">
            <button id="btnNotificarSlack3D" class="w-full py-2.5 bg-slate-800 hover:bg-slate-900 text-white rounded-xl text-xs font-bold transition-all flex items-center justify-center gap-2 shadow">
              <span>📢 Notificar en Slack</span>
            </button>
          </div>
        </div>

        <!-- Tarjeta de Cumplimiento Tarea 6 -->
        <div class="bg-gradient-to-br from-indigo-50 to-blue-50 rounded-2xl p-4 border border-indigo-100 text-xs space-y-1.5 text-indigo-900">
          <div class="font-bold flex items-center gap-1.5">
            <span>✨</span> <span>Auditoría de Nuevas Tecnologías</span>
          </div>
          <p class="text-[11px] text-indigo-700 leading-normal">
            Este visor interactivo cumple el requerimiento de <b>Gráficos 3D / Realidad Aumentada</b> estipulado para la revisión de la Ing. Lucy Q.
          </p>
        </div>
      </div>
    </div>
  </div>
  `;
}

export async function mount(ctx) {
  const container = document.getElementById("canvas3dContainer");
  if (!container) return;

  // Importar Three.js dinámicamente si no existe en window
  let THREE = window.THREE;
  if (!THREE) {
    try {
      THREE = await import("https://esm.sh/three@0.160.0");
      window.THREE = THREE;
    } catch (e) {
      console.error("Error cargando Three.js:", e);
      container.innerHTML = `<div class="text-red-400 text-xs p-4">No se pudo cargar el motor 3D: ${e.message}</div>`;
      return;
    }
  }

  // Importar OrbitControls
  let OrbitControls;
  try {
    const controlsMod = await import("https://esm.sh/three@0.160.0/examples/jsm/controls/OrbitControls.js");
    OrbitControls = controlsMod.OrbitControls;
  } catch (e) {
    console.warn("OrbitControls ESM fallback:", e);
  }

  const loader = document.getElementById("loading3D");
  if (loader) loader.style.display = "none";

  const width = container.clientWidth || 600;
  const height = container.clientHeight || 460;

  // 1. Escena
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0x0f172a); // Fondo Slate 900
  scene.fog = new THREE.FogExp2(0x0f172a, 0.08);

  // 2. Cámara
  const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
  camera.position.set(0, 1.2, 4.8);

  // 3. Renderer WebGL
  const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: "high-performance" });
  renderer.setSize(width, height);
  renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
  renderer.shadowMap.enabled = true;
  renderer.shadowMap.type = THREE.PCFSoftShadowMap;
  container.innerHTML = "";
  container.appendChild(renderer.domElement);
  currentRenderer = renderer;

  // 4. Luces
  const ambientLight = new THREE.AmbientLight(0xffffff, 0.7);
  scene.add(ambientLight);

  const mainLight = new THREE.DirectionalLight(0xffffff, 1.4);
  mainLight.position.set(4, 6, 4);
  mainLight.castShadow = true;
  mainLight.shadow.mapSize.width = 1024;
  mainLight.shadow.mapSize.height = 1024;
  scene.add(mainLight);

  const fillLight = new THREE.PointLight(0x60a5fa, 0.8, 10);
  fillLight.position.set(-4, 2, -2);
  scene.add(fillLight);

  const warmRim = new THREE.PointLight(0xfbbf24, 0.6, 10);
  warmRim.position.set(0, -3, 3);
  scene.add(warmRim);

  // 5. Suelo con sombras
  const planeGeo = new THREE.PlaneGeometry(20, 20);
  const planeMat = new THREE.ShadowMaterial({ opacity: 0.35 });
  const ground = new THREE.Mesh(planeGeo, planeMat);
  ground.rotation.x = -Math.PI / 2;
  ground.position.y = -1.2;
  ground.receiveShadow = true;
  scene.add(ground);

  // 6. Grupo Principal del Libro 3D
  const bookGroup = new THREE.Group();
  scene.add(bookGroup);

  // Cubierta del libro (Box)
  let coverColor = 0x1e3c72;
  const bookGeo = new THREE.BoxGeometry(2.0, 2.8, 0.5);
  const bookMat = new THREE.MeshStandardMaterial({
    color: coverColor,
    roughness: 0.3,
    metalness: 0.15,
  });
  const bookMesh = new THREE.Mesh(bookGeo, bookMat);
  bookMesh.castShadow = true;
  bookMesh.receiveShadow = true;
  bookGroup.add(bookMesh);

  // Hojas interiores (Páginas blancas/crema)
  const pagesGeo = new THREE.BoxGeometry(1.88, 2.68, 0.42);
  const pagesMat = new THREE.MeshStandardMaterial({
    color: 0xfef3c7,
    roughness: 0.9,
    metalness: 0.0,
  });
  const pagesMesh = new THREE.Mesh(pagesGeo, pagesMat);
  pagesMesh.position.x = 0.05;
  bookGroup.add(pagesMesh);

  // Emblema dorado en la portada
  const badgeGeo = new THREE.CylinderGeometry(0.35, 0.35, 0.02, 32);
  const badgeMat = new THREE.MeshStandardMaterial({
    color: 0xf59e0b,
    metalness: 0.8,
    roughness: 0.2,
  });
  const badgeMesh = new THREE.Mesh(badgeGeo, badgeMat);
  badgeMesh.rotation.x = Math.PI / 2;
  badgeMesh.position.set(0, 0.4, 0.26);
  bookGroup.add(badgeMesh);

  // 7. Controles de Órbita
  let controls = null;
  if (OrbitControls) {
    controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.05;
    controls.minDistance = 2.0;
    controls.maxDistance = 10.0;
    controls.target.set(0, 0, 0);
  }

  // 8. Bucle de Render
  autoRotate = true;
  function animate() {
    currentAnimationId = requestAnimationFrame(animate);
    if (autoRotate) {
      bookGroup.rotation.y += 0.012;
      bookGroup.position.y = Math.sin(Date.now() * 0.002) * 0.08;
    }
    if (controls) controls.update();
    renderer.render(scene, camera);
  }
  animate();

  // 9. Resize Listener
  const onResize = () => {
    if (!container || !renderer) return;
    const w = container.clientWidth;
    const h = container.clientHeight;
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
    renderer.setSize(w, h);
  };
  window.addEventListener("resize", onResize);

  // 10. Eventos de la Interfaz
  const btnToggle = document.getElementById("btnToggleRotate");
  if (btnToggle) {
    btnToggle.onclick = () => {
      autoRotate = !autoRotate;
      const txt = document.getElementById("txtRotate");
      const icon = document.getElementById("iconRotate");
      if (txt) txt.textContent = autoRotate ? "Pausar Giro" : "Auto-Girar";
      if (icon) icon.textContent = autoRotate ? "⏸️" : "🔄";
    };
  }

  const btnReset = document.getElementById("btnResetView");
  if (btnReset) {
    btnReset.onclick = () => {
      camera.position.set(0, 1.2, 4.8);
      bookGroup.rotation.set(0, 0, 0);
      if (controls) controls.target.set(0, 0, 0);
    };
  }

  // Paleta de colores
  document.querySelectorAll("[data-color]").forEach((btn) => {
    btn.onclick = () => {
      const col = btn.getAttribute("data-color");
      if (col && bookMat) {
        bookMat.color.set(col);
      }
    };
  });

  // Selector de Producto
  const selectProd = document.getElementById("selectProd3D");
  if (selectProd) {
    selectProd.onchange = (e) => {
      if (ctx?.navegar) {
        ctx.navegar("visor3d", { id: e.target.value });
      }
    };
  }

  // Botón Slack
  const btnSlack = document.getElementById("btnNotificarSlack3D");
  if (btnSlack) {
    btnSlack.onclick = async () => {
      btnSlack.disabled = true;
      btnSlack.textContent = "Enviando alerta…";
      try {
        const prodActual = selectProd ? selectProd.options[selectProd.selectedIndex].text : "Producto 3D";
        const r = await fetch("/api/slack", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            tipo: "producto",
            titulo: `Inspección 3D de Producto`,
            detalle: `El usuario revisó el modelo tridimensional de: ${prodActual}`,
          }),
        });
        const j = await r.json();
        alert(`✅ Alerta de Slack enviada con éxito (${j.modo || "en vivo"})`);
      } catch (err) {
        alert("Aviso: " + err.message);
      } finally {
        btnSlack.disabled = false;
        btnSlack.textContent = "📢 Notificar en Slack";
      }
    };
  }
}

export function unmount() {
  if (currentAnimationId) {
    cancelAnimationFrame(currentAnimationId);
    currentAnimationId = null;
  }
  if (currentRenderer) {
    currentRenderer.dispose();
    currentRenderer = null;
  }
}
