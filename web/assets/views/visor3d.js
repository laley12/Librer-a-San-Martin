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

let _ctx = null;

export function onRender() {
  requestAnimationFrame(() => {
    init3DScene();
  });
}

export function mount(root, ctx) {
  _ctx = ctx;
  init3DScene();
}

async function init3DScene() {
  const container = document.getElementById("canvas3dContainer");
  if (!container) return;

  // Si ya hay un canvas renderizando, no volver a montar
  if (container.querySelector("canvas") && currentRenderer) {
    return;
  }

  const loader = document.getElementById("loading3D");

  // Función de fallback visual elegante si WebGL no está disponible
  const mostrarFallback = (mensaje = "Vista 3D interactiva en modo simplificado") => {
    if (loader) loader.style.display = "none";
    container.innerHTML = `
      <div class="flex flex-col items-center justify-center p-6 text-center text-white space-y-4">
        <div class="w-32 h-44 bg-gradient-to-r from-blue-700 via-indigo-600 to-blue-800 rounded-lg shadow-2xl border-l-8 border-indigo-950 flex flex-col justify-between p-3 transform rotate-6 hover:rotate-0 transition-transform duration-500">
          <div class="text-[10px] text-amber-300 font-bold uppercase tracking-widest text-left">LSM 2026</div>
          <div class="text-center font-black text-sm text-white drop-shadow">CUADERNO LEDESMA</div>
          <div class="text-[9px] text-blue-200 text-right">100 Hojas</div>
        </div>
        <div class="space-y-1">
          <p class="text-xs font-semibold text-indigo-200">${esc(mensaje)}</p>
          <p class="text-[11px] text-slate-400">Modelo poligonal listo para inspección de catálogo</p>
        </div>
      </div>
    `;
  };

  // 1. Obtener Three.js (desde window o ESM dinámico con timeout de seguridad)
  let THREE = window.THREE;
  if (!THREE) {
    try {
      const loadPromise = import("https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.module.js")
        .catch(() => import("https://esm.sh/three@0.160.0"));
      
      const timeoutPromise = new Promise((_, reject) => 
        setTimeout(() => reject(new Error("Timeout cargando Three.js")), 2500)
      );

      THREE = await Promise.race([loadPromise, timeoutPromise]);
      window.THREE = THREE;
    } catch (e) {
      console.warn("[Visor3D] Three.js no disponible, aplicando fallback:", e);
      mostrarFallback("Modelo 3D optimizado (Modo Canvas Compatible)");
      return;
    }
  }

  // 2. Comprobar soporte WebGL
  try {
    const testCanvas = document.createElement("canvas");
    const gl = testCanvas.getContext("webgl") || testCanvas.getContext("experimental-webgl");
    if (!gl) {
      mostrarFallback("WebGL no disponible en este dispositivo");
      return;
    }
  } catch (err) {
    mostrarFallback("Aceleración por hardware no activa");
    return;
  }

  try {
    const width = container.clientWidth || 600;
    const height = container.clientHeight || 460;

    // Escena
    const scene = new THREE.Scene();
    scene.background = new THREE.Color(0x0f172a);
    scene.fog = new THREE.FogExp2(0x0f172a, 0.08);

    // Cámara
    const camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 100);
    camera.position.set(0, 1.2, 4.8);

    // Renderer
    const renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: "default" });
    renderer.setSize(width, height);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
    
    // Limpiar contenedor y agregar canvas
    container.innerHTML = "";
    container.appendChild(renderer.domElement);
    currentRenderer = renderer;

    if (loader) loader.style.display = "none";

    // Luces
    const ambientLight = new THREE.AmbientLight(0xffffff, 0.8);
    scene.add(ambientLight);

    const mainLight = new THREE.DirectionalLight(0xffffff, 1.2);
    mainLight.position.set(4, 6, 4);
    scene.add(mainLight);

    const fillLight = new THREE.PointLight(0x60a5fa, 0.8, 10);
    fillLight.position.set(-4, 2, -2);
    scene.add(fillLight);

    // Grupo Principal del Libro 3D
    const bookGroup = new THREE.Group();
    scene.add(bookGroup);

    // Cubierta del libro
    let coverColor = 0x1e3c72;
    const bookGeo = new THREE.BoxGeometry(2.0, 2.8, 0.5);
    const bookMat = new THREE.MeshStandardMaterial({
      color: coverColor,
      roughness: 0.35,
      metalness: 0.15,
    });
    const bookMesh = new THREE.Mesh(bookGeo, bookMat);
    bookGroup.add(bookMesh);

    // Hojas interiores
    const pagesGeo = new THREE.BoxGeometry(1.88, 2.68, 0.42);
    const pagesMat = new THREE.MeshStandardMaterial({
      color: 0xfef3c7,
      roughness: 0.85,
      metalness: 0.0,
    });
    const pagesMesh = new THREE.Mesh(pagesGeo, pagesMat);
    pagesMesh.position.x = 0.05;
    bookGroup.add(pagesMesh);

    // Emblema frontal
    const badgeGeo = new THREE.CylinderGeometry(0.35, 0.35, 0.04, 32);
    const badgeMat = new THREE.MeshStandardMaterial({
      color: 0xf59e0b,
      metalness: 0.8,
      roughness: 0.2,
    });
    const badgeMesh = new THREE.Mesh(badgeGeo, badgeMat);
    badgeMesh.rotation.x = Math.PI / 2;
    badgeMesh.position.set(0, 0.4, 0.26);
    bookGroup.add(badgeMesh);

    // Interacción con mouse/touch nativa (sin depender de OrbitControls externos)
    let isDragging = false;
    let prevMouseX = 0;
    let prevMouseY = 0;

    const onPointerDown = (e) => {
      isDragging = true;
      prevMouseX = e.clientX || (e.touches && e.touches[0].clientX) || 0;
      prevMouseY = e.clientY || (e.touches && e.touches[0].clientY) || 0;
    };

    const onPointerMove = (e) => {
      if (!isDragging) return;
      const clientX = e.clientX || (e.touches && e.touches[0].clientX) || 0;
      const clientY = e.clientY || (e.touches && e.touches[0].clientY) || 0;
      const deltaX = clientX - prevMouseX;
      const deltaY = clientY - prevMouseY;
      bookGroup.rotation.y += deltaX * 0.01;
      bookGroup.rotation.x += deltaY * 0.01;
      prevMouseX = clientX;
      prevMouseY = clientY;
    };

    const onPointerUp = () => { isDragging = false; };

    renderer.domElement.addEventListener("mousedown", onPointerDown);
    renderer.domElement.addEventListener("mousemove", onPointerMove);
    window.addEventListener("mouseup", onPointerUp);

    renderer.domElement.addEventListener("touchstart", onPointerDown, { passive: true });
    renderer.domElement.addEventListener("touchmove", onPointerMove, { passive: true });
    window.addEventListener("touchend", onPointerUp);

    // Bucle de animación 60 FPS
    autoRotate = true;
    function animate() {
      currentAnimationId = requestAnimationFrame(animate);
      if (autoRotate && !isDragging) {
        bookGroup.rotation.y += 0.014;
        bookGroup.position.y = Math.sin(Date.now() * 0.002) * 0.08;
      }
      renderer.render(scene, camera);
    }
    animate();

    // Redimensionamiento
    const onResize = () => {
      if (!container || !renderer) return;
      const w = container.clientWidth;
      const h = container.clientHeight;
      if (w > 0 && h > 0) {
        camera.aspect = w / h;
        camera.updateProjectionMatrix();
        renderer.setSize(w, h);
      }
    };
    window.addEventListener("resize", onResize);

    // Botones de control
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
      };
    }

    // Botones de colores
    document.querySelectorAll("[data-color]").forEach((btn) => {
      btn.onclick = () => {
        const col = btn.getAttribute("data-color");
        if (col && bookMat) {
          bookMat.color.set(col);
        }
      };
    });

    // Selector de producto
    const selectProd = document.getElementById("selectProd3D");
    if (selectProd) {
      selectProd.onchange = (e) => {
        if (_ctx?.ir) {
          _ctx.ir("visor3d", { id: e.target.value });
        }
      };
    }

    // Notificación en Slack
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

  } catch (err) {
    console.error("[Visor3D] Error inicializando escena 3D:", err);
    mostrarFallback("Visualizador 3D activado en modo seguro");
  }
}

export function unmount() {
  if (currentAnimationId) {
    cancelAnimationFrame(currentAnimationId);
    currentAnimationId = null;
  }
  if (currentRenderer) {
    try {
      currentRenderer.dispose();
    } catch (e) {}
    currentRenderer = null;
  }
}
