/* =====================================================================
   JS base del sistema PHP (reemplaza el reloj, el toggle de tema y los
   atajos de teclado que estaban duplicados en cada pagina).
   Se carga con:  <script src="/includes/base.js"></script>
   ===================================================================== */
(function () {
  "use strict";

  var MESES = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio",
    "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];

  function dos(n) { return String(n).padStart(2, "0"); }

  /* ---------- reloj y fecha ---------- */
  function pintarReloj() {
    var ahora = new Date();
    var reloj = document.getElementById("live-clock") || document.getElementById("txt-reloj");
    var fecha = document.getElementById("live-date") || document.getElementById("txt-fecha");
    if (reloj) reloj.textContent = dos(ahora.getHours()) + ":" + dos(ahora.getMinutes()) + ":" + dos(ahora.getSeconds());
    if (fecha) {
      if (fecha.id === "txt-fecha") {
        fecha.textContent = dos(ahora.getDate()) + "/" + MESES[ahora.getMonth()] + "/" + ahora.getFullYear();
      } else {
        fecha.textContent = dos(ahora.getDate()) + " de " + MESES[ahora.getMonth()] + " de " + ahora.getFullYear();
      }
    }
  }

  /* ---------- tema claro / oscuro / sepia ---------- */
  function iconoTema(tema) {
    return tema === "dark" ? "bi-moon-fill"
      : tema === "sepia" ? "bi-brightness-alt-high-fill"
        : "bi-sun-fill";
  }

  function montarToggleTema() {
    if (document.getElementById("darkModeToggle")) return;
    var guardado = localStorage.getItem("theme") || "light";
    if (typeof window.aplicarTema === "function") window.aplicarTema(guardado);

    var btn = document.createElement("button");
    btn.id = "darkModeToggle";
    btn.type = "button";
    btn.title = "Modo oscuro";
    btn.setAttribute("aria-label", "Cambiar tema");
    btn.className = "btn btn-sm btn-outline-secondary rounded-circle ms-2";
    btn.style.cssText = "width:36px;height:36px;display:flex;align-items:center;justify-content:center;border:1px solid #dee2e6;";
    btn.innerHTML = '<i class="bi ' + iconoTema(guardado) + '"></i>';

    var topbar = document.querySelector(".topbar-widgets") || document.querySelector(".topbar");
    if (!topbar) return;
    var perfil = topbar.querySelector(".user-profile");
    if (perfil) perfil.parentNode.insertBefore(btn, perfil);
    else topbar.appendChild(btn);

    btn.addEventListener("click", function () {
      if (typeof window.ciclarTema === "function") window.ciclarTema();
      var actual = document.documentElement.getAttribute("data-theme") || "light";
      btn.innerHTML = '<i class="bi ' + iconoTema(actual) + '"></i>';
    });
  }

  /* ---------- sidebar plegable ---------- */
  function montarSidebar() {
    var btn = document.getElementById("sidebarToggle");
    var barra = document.getElementById("mainSidebar");
    if (!btn || !barra) return;
    btn.addEventListener("click", function () {
      barra.classList.toggle("collapsed");
      localStorage.setItem("lsm.sidebar", barra.classList.contains("collapsed") ? "1" : "0");
    });
    if (localStorage.getItem("lsm.sidebar") === "1") barra.classList.add("collapsed");
  }

  /* ---------- atajos de teclado ---------- */
  function atajos() {
    document.addEventListener("keydown", function (e) {
      if (!e.ctrlKey) return;
      if (e.key === "n") {
        e.preventDefault();
        var modal = document.querySelector("[data-bs-target]");
        if (modal && window.bootstrap) {
          var el = document.querySelector(modal.getAttribute("data-bs-target"));
          if (el) { window.bootstrap.Modal.getOrCreateInstance(el).show(); return; }
        }
        var nuevo = document.querySelector('a[href*="nuevo.php"]');
        if (nuevo) window.location.href = nuevo.getAttribute("href");
      } else if (e.key === "f") {
        e.preventDefault();
        var buscador = document.getElementById("buscador");
        if (buscador) buscador.focus();
      } else if (e.key === "s") {
        var form = e.target.closest ? e.target.closest("form") : null;
        if (!form) return;
        e.preventDefault();
        var submit = form.querySelector('[type="submit"]');
        if (submit) submit.click();
        else form.submit();
      }
    });
  }

  /* ---------- confirmaciones declarativas ---------- */
  function confirmarAcciones() {
    document.addEventListener("click", function (e) {
      var disparador = e.target.closest("[data-confirmar]");
      if (!disparador) return;
      if (!window.confirm(disparador.getAttribute("data-confirmar"))) {
        e.preventDefault();
        e.stopPropagation();
      }
    }, true);
  }

  function arrancar() {
    pintarReloj();
    setInterval(pintarReloj, 1000);
    montarToggleTema();
    montarSidebar();
    atajos();
    confirmarAcciones();
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", arrancar);
  else arrancar();
})();