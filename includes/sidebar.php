<?php
include_once("csrf.php");
$pagina_uri = $_SERVER['REQUEST_URI'];
$dir_actual = basename(dirname($_SERVER['PHP_SELF']));

function es_activo($modulos, $dir_actual) {
    if (is_array($modulos)) return in_array($dir_actual, $modulos) ? 'active' : '';
    return ($dir_actual === $modulos) ? 'active' : '';
}
function expanded($modulos, $dir_actual) {
    if (is_array($modulos)) return in_array($dir_actual, $modulos) ? 'true' : 'false';
    return ($dir_actual === $modulos) ? 'true' : 'false';
}
function show_collapse($modulos, $dir_actual) {
    if (is_array($modulos)) return in_array($dir_actual, $modulos) ? 'show' : '';
    return ($dir_actual === $modulos) ? 'show' : '';
}
?>
<div class="sidebar" id="mainSidebar">
    <div class="sidebar-brand"><i class="bi bi-list" id="sidebarToggle" style="cursor:pointer;font-size:1.3rem;margin-right:8px;" title="Alternar menú"></i><span class="brand-text">📚 San Martín</span></div>
    <div class="sidebar-menu" id="sidebarMenu">

        <!-- Panel Principal -->
        <a href="<?php echo BASE_PATH; ?>dashboard/index.php" class="<?php echo es_activo('dashboard', $dir_actual); ?>">
            <i class="bi bi-grid-1x2-fill"></i> <span class="menu-text">Panel Principal</span>
        </a>

        <!-- Usuarios con submenú -->
        <a href="#sub-usuarios" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo(['usuarios', 'chat'], $dir_actual); ?>" aria-expanded="<?php echo expanded(['usuarios', 'chat'], $dir_actual); ?>">
            <i class="bi bi-people-fill"></i> <span class="menu-text">Usuarios</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse(['usuarios', 'chat'], $dir_actual); ?>" id="sub-usuarios">
            <a href="<?php echo BASE_PATH; ?>usuarios/nuevo.php"><i class="bi bi-plus-circle"></i> <span class="menu-text">Nuevo Usuario</span></a>
            <a href="<?php echo BASE_PATH; ?>usuarios/index.php"><i class="bi bi-list"></i> <span class="menu-text">Lista de Usuarios</span></a>
            <a href="#sub-info" data-bs-toggle="collapse" class="collapse-toggle" aria-expanded="false">
                <i class="bi bi-info-circle"></i> <span class="menu-text">Información de Usuario</span>
                <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
            </a>
            <div class="collapse collapse-submenu-2" id="sub-info">
                <a href="<?php echo BASE_PATH; ?>usuarios/perfil.php"><i class="bi bi-person-gear"></i> <span class="menu-text">Mi Perfil</span></a>
                <a href="<?php echo BASE_PATH; ?>usuarios/auditoria.php"><i class="bi bi-journal-check"></i> <span class="menu-text">Auditoría</span></a>
            </div>
            <a href="<?php echo BASE_PATH; ?>usuarios/asignar_rol.php"><i class="bi bi-person-badge"></i> <span class="menu-text">Asignar Rol de Usuario</span></a>
            <a href="<?php echo BASE_PATH; ?>chat/index.php">
                <i class="bi bi-chat-dots-fill"></i> <span class="menu-text">Chat Interno</span>
                <?php
                $no_leidos = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM mensajes_chat WHERE id_destinatario={$_SESSION['id']} AND leido=0"));
                if($no_leidos['total'] > 0) { echo ' <span class="badge bg-danger ms-auto">'.$no_leidos['total'].'</span>'; }
                ?>
            </a>
        </div>

        <!-- Categorías con submenú -->
        <a href="#sub-categorias" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('categorias', $dir_actual); ?>" aria-expanded="<?php echo expanded('categorias', $dir_actual); ?>">
            <i class="bi bi-tags-fill"></i> <span class="menu-text">Categorías</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('categorias', $dir_actual); ?>" id="sub-categorias">
            <a href="<?php echo BASE_PATH; ?>categorias/index.php"><i class="bi bi-list"></i> <span class="menu-text">Lista de Categorías</span></a>
            <a href="<?php echo BASE_PATH; ?>categorias/nuevo.php"><i class="bi bi-plus-circle"></i> <span class="menu-text">Nueva Categoría</span></a>
            <a href="<?php echo BASE_PATH; ?>productos/productos_categoria.php"><i class="bi bi-tag"></i> <span class="menu-text">Productos por Categoría</span></a>
        </div>

        <!-- Clientes con submenú -->
        <a href="#sub-clientes" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('clientes', $dir_actual); ?>" aria-expanded="<?php echo expanded('clientes', $dir_actual); ?>">
            <i class="bi bi-person-hearts"></i> <span class="menu-text">Clientes (CRM)</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('clientes', $dir_actual); ?>" id="sub-clientes">
            <a href="<?php echo BASE_PATH; ?>clientes/index.php"><i class="bi bi-list"></i> <span class="menu-text">Lista de Clientes</span></a>
            <a href="<?php echo BASE_PATH; ?>clientes/nuevo.php"><i class="bi bi-person-plus-fill"></i> <span class="menu-text">Nuevo Cliente</span></a>
            <a href="<?php echo BASE_PATH; ?>clientes/historial_compras.php"><i class="bi bi-clock-history"></i> <span class="menu-text">Historial de Compras</span></a>
            <a href="<?php echo BASE_PATH; ?>clientes/top_clientes.php"><i class="bi bi-trophy"></i> <span class="menu-text">Clientes Frecuentes</span></a>
        </div>

        <!-- Productos con submenú -->
        <a href="#sub-productos" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('productos', $dir_actual); ?>" aria-expanded="<?php echo expanded('productos', $dir_actual); ?>">
            <i class="bi bi-book-half"></i> <span class="menu-text">Productos</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('productos', $dir_actual); ?>" id="sub-productos">
            <a href="<?php echo BASE_PATH; ?>productos/index.php"><i class="bi bi-list"></i> <span class="menu-text">Lista de Productos</span></a>
            <a href="<?php echo BASE_PATH; ?>productos/nuevo.php"><i class="bi bi-plus-circle"></i> <span class="menu-text">Nuevo Producto</span></a>
            <a href="<?php echo BASE_PATH; ?>productos/stock_bajo.php"><i class="bi bi-exclamation-triangle"></i> <span class="menu-text">Stock Bajo</span></a>
            <a href="<?php echo BASE_PATH; ?>productos/top_vendidos.php"><i class="bi bi-trophy"></i> <span class="menu-text">Productos Más Vendidos</span></a>
        </div>

        <!-- Proveedores con submenú -->
        <a href="#sub-proveedores" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('proveedores', $dir_actual); ?>" aria-expanded="<?php echo expanded('proveedores', $dir_actual); ?>">
            <i class="bi bi-truck-flatbed"></i> <span class="menu-text">Proveedores</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('proveedores', $dir_actual); ?>" id="sub-proveedores">
            <a href="<?php echo BASE_PATH; ?>proveedores/index.php"><i class="bi bi-list"></i> <span class="menu-text">Lista de Proveedores</span></a>
            <a href="<?php echo BASE_PATH; ?>proveedores/nuevo.php"><i class="bi bi-plus-circle"></i> <span class="menu-text">Nuevo Proveedor</span></a>
            <a href="<?php echo BASE_PATH; ?>proveedores/resumen_compras.php"><i class="bi bi-cart"></i> <span class="menu-text">Compras por Proveedor</span></a>
            <a href="<?php echo BASE_PATH; ?>proveedores/pago_proveedores.php"><i class="bi bi-credit-card"></i> <span class="menu-text">Pagos a Proveedores</span></a>
        </div>

        <!-- Compras con submenú -->
        <a href="#sub-compras" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('compras', $dir_actual); ?>" aria-expanded="<?php echo expanded('compras', $dir_actual); ?>">
            <i class="bi bi-bag-plus-fill"></i> <span class="menu-text">Compras</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('compras', $dir_actual); ?>" id="sub-compras">
            <a href="<?php echo BASE_PATH; ?>compras/index.php"><i class="bi bi-list"></i> <span class="menu-text">Historial de Compras</span></a>
            <a href="<?php echo BASE_PATH; ?>compras/nuevo.php"><i class="bi bi-plus-circle"></i> <span class="menu-text">Nueva Compra</span></a>
            <a href="<?php echo BASE_PATH; ?>compras/compras_periodo.php"><i class="bi bi-calendar-range"></i> <span class="menu-text">Compras por Período</span></a>
    <a href="<?php echo BASE_PATH; ?>compras/editar_precios_productos.php"><i class="bi bi-currency-dollar"></i> <span class="menu-text">Editar Precios</span></a>
        </div>

        <!-- Ventas con submenú -->
        <a href="#sub-ventas" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo(['ventas', 'pedidos'], $dir_actual); ?>" aria-expanded="<?php echo expanded(['ventas', 'pedidos'], $dir_actual); ?>">
            <i class="bi bi-cash-stack"></i> <span class="menu-text">Ventas</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse(['ventas', 'pedidos'], $dir_actual); ?>" id="sub-ventas">
            <a href="<?php echo BASE_PATH; ?>ventas/nuevo.php"><i class="bi bi-plus-circle"></i> <span class="menu-text">Nueva Venta</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/caja.php"><i class="bi bi-safe2"></i> <span class="menu-text">Apertura de Caja</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/historial_turnos.php"><i class="bi bi-clock-history"></i> <span class="menu-text">Historial de Turnos</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/index.php"><i class="bi bi-receipt"></i> <span class="menu-text">Historial de Ventas</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/ventas_periodo.php"><i class="bi bi-calendar-range"></i> <span class="menu-text">Ventas por Periodo</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/top_productos.php"><i class="bi bi-trophy"></i> <span class="menu-text">Top Productos</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/auditoria_ventas.php"><i class="bi bi-shield-check"></i> <span class="menu-text">Auditoría de Ventas</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/recibos.php"><i class="bi bi-receipt-cutoff"></i> <span class="menu-text">Recibos</span></a>
            <a href="<?php echo BASE_PATH; ?>ventas/historial_devoluciones.php"><i class="bi bi-arrow-return-left"></i> <span class="menu-text">Devoluciones</span></a>
            <a href="<?php echo BASE_PATH; ?>pedidos/index.php"><i class="bi bi-cart-check-fill"></i> <span class="menu-text">Pedidos (Web)</span></a>
        </div>

        <!-- Inventario con submenú -->
        <a href="#sub-inventario" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('inventario', $dir_actual); ?>" aria-expanded="<?php echo expanded('inventario', $dir_actual); ?>">
            <i class="bi bi-boxes"></i> <span class="menu-text">Inventario</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('inventario', $dir_actual); ?>" id="sub-inventario">
            <a href="<?php echo BASE_PATH; ?>inventario/index.php"><i class="bi bi-box-seam"></i> <span class="menu-text">Stock Actual</span></a>
            <a href="<?php echo BASE_PATH; ?>inventario/movimientos.php"><i class="bi bi-arrow-left-right"></i> <span class="menu-text">Movimientos</span></a>
            <a href="<?php echo BASE_PATH; ?>inventario/stock_bajo.php"><i class="bi bi-exclamation-triangle"></i> <span class="menu-text">Stock Bajo</span>
                <?php
                $stock_bajo_sidebar = mysqli_fetch_assoc(mysqli_query($conexion, "SELECT COUNT(*) total FROM productos WHERE activo=1 AND stock < 5"));
                if($stock_bajo_sidebar['total'] > 0) { echo ' <span class="badge bg-warning text-dark ms-auto">'.$stock_bajo_sidebar['total'].'</span>'; }
                ?>
            </a>
            <a href="<?php echo BASE_PATH; ?>inventario/ajuste_stock.php"><i class="bi bi-sliders"></i> <span class="menu-text">Ajuste de Stock</span></a>
            <a href="<?php echo BASE_PATH; ?>inventario/valor_inventario.php"><i class="bi bi-cash-coin"></i> <span class="menu-text">Valor del Inventario</span></a>
        </div>

        <!-- Reportes con submenú -->
        <a href="#sub-reportes" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('reportes', $dir_actual); ?>" aria-expanded="<?php echo expanded('reportes', $dir_actual); ?>">
            <i class="bi bi-pie-chart-fill"></i> <span class="menu-text">Reportes</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('reportes', $dir_actual); ?>" id="sub-reportes">
            <a href="<?php echo BASE_PATH; ?>reportes/index.php"><i class="bi bi-graph-up"></i> <span class="menu-text">Dashboard General</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/ventas_periodo.php"><i class="bi bi-cash-coin"></i> <span class="menu-text">Ventas por Período</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/compras_periodo.php"><i class="bi bi-cart"></i> <span class="menu-text">Compras por Período</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/top_productos.php"><i class="bi bi-trophy"></i> <span class="menu-text">Top Productos</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/proveedores_top.php"><i class="bi bi-truck"></i> <span class="menu-text">Top Proveedores</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/stock_bajo.php"><i class="bi bi-exclamation-triangle"></i> <span class="menu-text">Stock Bajo</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/valor_inventario.php"><i class="bi bi-calculator"></i> <span class="menu-text">Valor Inventario</span></a>
            <a href="<?php echo BASE_PATH; ?>reportes/ganancias.php"><i class="bi bi-graph-up-arrow"></i> <span class="menu-text">Ganancias Netas</span></a>
        </div>

        <!-- Registro de Actividad -->
        <a href="#sub-auditoria" data-bs-toggle="collapse" class="collapse-toggle <?php echo es_activo('auditoria', $dir_actual); ?>" aria-expanded="<?php echo expanded('auditoria', $dir_actual); ?>">
            <i class="bi bi-shield-check"></i> <span class="menu-text">Registro de Actividad</span>
            <i class="bi bi-chevron-down chevron-icon ms-auto"></i>
        </a>
        <div class="collapse collapse-submenu <?php echo show_collapse('auditoria', $dir_actual); ?>" id="sub-auditoria">
            <a href="<?php echo BASE_PATH; ?>auditoria/index.php"><i class="bi bi-eye"></i> <span class="menu-text">Ver Actividad</span></a>
        </div>

        <!-- Salir -->
        <a href="#" id="fullscreenToggle" class="mt-3" title="Pantalla completa">
            <i class="bi bi-fullscreen"></i> <span class="menu-text" id="fullscreenLabel">Pantalla Completa</span>
        </a>
        <a href="#" id="themeToggleSidebar" title="Cambiar tema">
            <i class="bi bi-palette"></i> <span class="menu-text" id="themeLabel">Tema</span>
        </a>
        <a href="<?php echo BASE_PATH; ?>login/logout.php" class="text-danger mt-4">
            <i class="bi bi-power text-danger"></i> <span class="menu-text">Salir</span>
        </a>
    </div>
</div>
<div id="sidebarOverlay"></div>
<?php
$mostrar_welcome = !empty($_SESSION['welcome']);
if ($mostrar_welcome) {
    $_SESSION['welcome'] = false;
    $wname = $_SESSION['nombre'] ?? '';
}
?>
<?php if ($mostrar_welcome): ?>
<div class="position-fixed top-0 end-0 p-3" style="z-index: 9999;">
    <div id="welcomeToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3000">
        <div class="d-flex">
            <div class="toast-body">
                <i class="bi bi-check-circle-fill me-2"></i>¡Bienvenido de vuelta, <strong><?php echo htmlspecialchars($wname); ?></strong>! - Sesión iniciada con éxito.
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
        </div>
    </div>
</div>
<?php endif; ?>
<?php include_once("alertas_stock.php"); include_once("alertas_cumpleanos.php"); ?>
<script data-sidebar-script>
var BASE_PATH = '<?php echo defined('BASE_PATH') ? BASE_PATH : '/'; ?>';
(function(){
    var sidebar = document.getElementById('mainSidebar');
    var overlay = document.getElementById('sidebarOverlay');
    if(!sidebar) return;
    if(localStorage.getItem('sidebarCollapsed') === 'true') sidebar.classList.add('collapsed');
    var toggle = document.getElementById('sidebarToggle');
    if(toggle){
        toggle.addEventListener('click', function(e){
            e.preventDefault();
            var isMobile = window.innerWidth < 992;
            if (isMobile) {
                sidebar.classList.toggle('mobile-open');
                if (overlay) overlay.classList.toggle('show');
            } else {
                sidebar.classList.toggle('collapsed');
                localStorage.setItem('sidebarCollapsed', sidebar.classList.contains('collapsed') ? 'true' : 'false');
            }
        });
    }
    if (overlay) {
        overlay.addEventListener('click', function() {
            sidebar.classList.remove('mobile-open');
            overlay.classList.remove('show');
        });
    }
    window.addEventListener('resize', function() {
        if (window.innerWidth >= 992 && sidebar.classList.contains('mobile-open')) {
            sidebar.classList.remove('mobile-open');
            if (overlay) overlay.classList.remove('show');
        }
    });

    function restoreSubmenus() {
        var savedSubs = localStorage.getItem('sidebarSubmenus');
        if (!savedSubs) return;
        try {
            var ids = JSON.parse(savedSubs);
            ids.forEach(function(id) {
                var el = document.getElementById(id);
                if (el) {
                    el.classList.add('show');
                    var parent = document.querySelector('[href="#' + id + '"]');
                    if (parent) parent.setAttribute('aria-expanded', 'true');
                }
            });
        } catch(e) {}
    }

    function saveSubmenus() {
        var openIds = [];
        document.querySelectorAll('.sidebar-menu .collapse.show').forEach(function(el){
            openIds.push(el.id);
        });
        localStorage.setItem('sidebarSubmenus', JSON.stringify(openIds));
    }

    document.querySelectorAll('.sidebar-menu [data-bs-toggle="collapse"]').forEach(function(link){
        link.addEventListener('click', function(){
            setTimeout(saveSubmenus, 100);
        });
    });

    if (typeof bootstrap !== 'undefined') {
        restoreSubmenus();
    } else {
        document.addEventListener('DOMContentLoaded', restoreSubmenus);
    }

    // ====== Temas: Claro / Sepia / Oscuro ======
    var temas = ['light', 'sepia', 'dark'];
    var iconos = {'light': 'bi-sun-fill', 'sepia': 'bi-bookmark-fill', 'dark': 'bi-moon-fill'};
    var etiquetas = {'light': 'Claro', 'sepia': 'Sepia', 'dark': 'Oscuro'};

    // Inyectar themes.css
    (function(){
        var lnk = document.createElement('link');
        lnk.rel = 'stylesheet';
        lnk.href = BASE_PATH + 'assets/css/themes.css';
        document.head.appendChild(lnk);
    })();

    function aplicarTema(tema) {
        if (tema === 'light') {
            document.documentElement.removeAttribute('data-theme');
        } else {
            document.documentElement.setAttribute('data-theme', tema);
        }
        localStorage.setItem('theme', tema);
        // Actualizar icono toggle del sidebar
        var btn = document.getElementById('themeToggleSidebar');
        if (btn) {
            var icon = btn.querySelector('i');
            if (icon) icon.className = 'bi ' + (iconos[tema] || 'bi-palette');
        }
        var lbl = document.getElementById('themeLabel');
        if (lbl) lbl.textContent = 'Tema: ' + (etiquetas[tema] || tema);
    }

    var sessionTema = '<?php echo isset($_SESSION["tema"]) ? $_SESSION["tema"] : "light"; ?>';
    if (temas.indexOf(sessionTema) >= 0) {
        aplicarTema(sessionTema);
    } else {
        var saved = localStorage.getItem('theme');
        if (temas.indexOf(saved) >= 0) aplicarTema(saved);
    }

    // Toggle cíclico: light → sepia → dark → light
    var toggleBtn = document.getElementById('themeToggleSidebar');
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function(e) {
            e.preventDefault();
            var actual = document.documentElement.getAttribute('data-theme') || 'light';
            var idx = temas.indexOf(actual);
            if (idx < 0) idx = 0;
            var nuevo = temas[(idx + 1) % temas.length];
            aplicarTema(nuevo);
            // Guardar en BD via AJAX
            fetch(BASE_PATH + 'config/ajax_guardar_tema.php', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'tema=' + nuevo
            });
        });
    }

    // ====== Pantalla Completa ======
    var fsBtn = document.getElementById('fullscreenToggle');
    function actualizarIconoFullscreen() {
        var isFS = !!(document.fullscreenElement || document.webkitFullscreenElement);
        if (fsBtn) {
            var icon = fsBtn.querySelector('i');
            if (icon) icon.className = 'bi ' + (isFS ? 'bi-fullscreen-exit' : 'bi-fullscreen');
        }
        var lbl = document.getElementById('fullscreenLabel');
        if (lbl) lbl.textContent = isFS ? 'Salir de Pantalla Completa' : 'Pantalla Completa';
        localStorage.setItem('fullscreen', isFS ? 'true' : 'false');
    }
    function entrarFullscreen() {
        var el = document.documentElement;
        if (el.requestFullscreen) {
            el.requestFullscreen();
        } else if (el.webkitRequestFullscreen) {
            el.webkitRequestFullscreen();
        }
    }
    function salirFullscreen() {
        if (document.exitFullscreen) {
            document.exitFullscreen();
        } else if (document.webkitExitFullscreen) {
            document.webkitExitFullscreen();
        }
    }
    function toggleFullscreen() {
        if (document.fullscreenElement || document.webkitFullscreenElement) {
            salirFullscreen();
        } else {
            entrarFullscreen();
        }
    }
    if (fsBtn) {
        fsBtn.addEventListener('click', function(e) {
            e.preventDefault();
            toggleFullscreen();
        });
    }
    document.addEventListener('fullscreenchange', actualizarIconoFullscreen);
    document.addEventListener('webkitfullscreenchange', actualizarIconoFullscreen);
    // Restaurar estado visual al cargar página
    actualizarIconoFullscreen();

    // ====== Navegación SPA eliminada por compatibilidad con hosting web ======
    // Delegación de clics en sidebar
    var sidebarMenu = document.querySelector('.sidebar-menu');
    if (!sidebarMenu) { sidebarMenu = document.querySelector('.sidebar'); }
    // Los enlaces funcionarán de forma predeterminada (recarga completa de página)

    // ====== Modal de confirmación reutilizable ======
    function crearModalConfirm() {
        if (document.getElementById('confirmModal')) return;
        var html = '<div class="modal fade" id="confirmModal" tabindex="-1"><div class="modal-dialog modal-dialog-centered"><div class="modal-content"><div class="modal-body text-center py-4"><i class="bi bi-exclamation-triangle-fill text-warning" style="font-size:2.5rem;"></i><p class="mt-3 fs-5 fw-bold" id="confirmMsg">¿Está seguro?</p></div><div class="modal-footer border-0 justify-content-center pt-0"><button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Cancelar</button><button type="button" id="confirmBtn" class="btn btn-danger px-4"><i class="bi bi-check-circle me-1"></i> Confirmar</button></div></div></div></div>';
        document.body.insertAdjacentHTML('beforeend', html);
    }

    window.showConfirmModal = function(msg, onConfirm) {
        if (typeof bootstrap === 'undefined') { if (onConfirm) onConfirm(); return; }
        crearModalConfirm();
        document.getElementById('confirmMsg').textContent = msg;
        var btn = document.getElementById('confirmBtn');
        btn.onclick = function() {
            if (onConfirm) onConfirm();
            var modal = bootstrap.Modal.getInstance(document.getElementById('confirmModal'));
            if (modal) modal.hide();
        };
        new bootstrap.Modal(document.getElementById('confirmModal')).show();
    };

    // ====== Confirmación con data-confirm (atributo en enlaces/botones) ======
    document.addEventListener('click', function(e) {
        var el = e.target.closest('[data-confirm]');
        if (!el) return;
        e.preventDefault();
        var msg = el.getAttribute('data-confirm');
        var href = el.getAttribute('href');
        var parentForm = el.closest('form');
        showConfirmModal(msg, function() {
            if (href) {
                window.location.href = href;
            } else if (parentForm) {
                parentForm.submit();
            }
        });
    });

    // Welcome toast - notificación auto-dismiss
    (function(){
        var toastEl = document.getElementById('welcomeToast');
        if (!toastEl) return;
        if (typeof bootstrap !== 'undefined') {
            setTimeout(function(){
                var toast = new bootstrap.Toast(toastEl);
                toast.show();
            }, 400);
        }
    })();
})();

// Exponer funciones de tema globalmente para páginas individuales
window.aplicarTema = window.aplicarTema || function(tema) {
    var validos = ['light', 'sepia', 'dark'];
    if (validos.indexOf(tema) < 0) tema = 'light';
    if (tema === 'light') {
        document.documentElement.removeAttribute('data-theme');
    } else {
        document.documentElement.setAttribute('data-theme', tema);
    }
    localStorage.setItem('theme', tema);
    // Actualizar icono del sidebar si existe
    var sideBtn = document.getElementById('themeToggleSidebar');
    if (sideBtn) {
        var icons = {'light': 'bi-sun-fill', 'sepia': 'bi-bookmark-fill', 'dark': 'bi-moon-fill'};
        var icon = sideBtn.querySelector('i');
        if (icon) icon.className = 'bi ' + (icons[tema] || 'bi-palette');
    }
    var sideLbl = document.getElementById('themeLabel');
    if (sideLbl) {
        var labels = {'light': 'Claro', 'sepia': 'Sepia', 'dark': 'Oscuro'};
        sideLbl.textContent = 'Tema: ' + (labels[tema] || tema);
    }
};
window.temaActual = function() {
    return document.documentElement.getAttribute('data-theme') || 'light';
};
// ====== Pantalla completa global ======
window.toggleFullscreen = window.toggleFullscreen || function() {
    if (document.fullscreenElement || document.webkitFullscreenElement) {
        if (document.exitFullscreen) document.exitFullscreen();
        else if (document.webkitExitFullscreen) document.webkitExitFullscreen();
    } else {
        var el = document.documentElement;
        if (el.requestFullscreen) el.requestFullscreen();
        else if (el.webkitRequestFullscreen) el.webkitRequestFullscreen();
    }
};
window.ciclarTema = function() {
    var actual = window.temaActual();
    var map = {'light': 'sepia', 'sepia': 'dark', 'dark': 'light'};
    var nuevo = map[actual] || 'sepia';
    window.aplicarTema(nuevo);
    fetch(BASE_PATH + 'config/ajax_guardar_tema.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'tema=' + nuevo
    });
};
</script>
