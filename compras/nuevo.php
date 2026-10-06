<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
session_start();
include("../config/conexion.php");
if(!isset($_SESSION['id'])){ header("Location: ../login/login.php"); exit(); }
$proveedores = mysqli_query($conexion, "SELECT * FROM proveedores WHERE activo=1 ORDER BY nombre");
$productos = mysqli_query($conexion, "SELECT id_producto, nombre_producto, precio FROM productos WHERE activo=1 ORDER BY nombre_producto ASC");
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Nueva Compra - Librería San Martín</title>
    <link href="<?php echo BASE_URL; ?>assets/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="<?php echo BASE_URL; ?>assets/css/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
:root{--body-bg:#f0f3f8;--sidebar-bg:#fff;--sidebar-text:#1e293b;--sidebar-hover-bg:#e2e8f0;--sidebar-accent:#1e3c72;--sidebar-active-bg:linear-gradient(90deg,rgba(30,60,114,0.12),rgba(42,82,152,0.05));--sidebar-brand-bg:linear-gradient(135deg,#1e3c72,#2a5298);--topbar-bg:rgba(255,255,255,0.85);--panel-bg:#fff;--panel-header-bg:linear-gradient(135deg,#2a5298,#1e3c72);--profile-bg:#f1f5f9;--profile-text:#333;--scrollbar-thumb:rgba(0,0,0,0.12);--border-color:rgba(0,0,0,0.05);}
[data-theme="dark"]{--body-bg:#0f172a;--sidebar-bg:#1e293b;--sidebar-text:#cbd5e1;--sidebar-hover-bg:#334155;--sidebar-accent:#60a5fa;--sidebar-active-bg:linear-gradient(90deg,rgba(59,130,246,0.15),rgba(37,99,235,0.08));--sidebar-brand-bg:linear-gradient(135deg,#0f172a,#1e293b);--topbar-bg:rgba(30,41,59,0.95);--panel-bg:#1e293b;--panel-header-bg:linear-gradient(135deg,#0f172a,#1e293b);--profile-bg:#334155;--profile-text:#e2e8f0;--scrollbar-thumb:rgba(255,255,255,0.15);--border-color:rgba(255,255,255,0.06);}
.sidebar{display:flex;flex-direction:column;width:260px;height:100vh;position:fixed;background:var(--sidebar-bg);box-shadow:4px 0 20px rgba(0,0,0,0.03);z-index:1000;}
.sidebar-brand{flex-shrink:0;background:var(--sidebar-brand-bg);color:#fff;padding:20px;font-size:1.3rem;font-weight:700;text-align:center;}
.sidebar-menu a{display:flex;align-items:center;color:var(--sidebar-text);text-decoration:none;padding:12px 15px;font-size:0.95rem;border-radius:8px;margin-bottom:5px;transition:all 0.25s ease;border-left:3px solid transparent;}
.sidebar-menu a.active{background:var(--sidebar-active-bg);color:var(--sidebar-accent);font-weight:700;border-left:4px solid var(--sidebar-accent);}
.main-content{margin-left:260px;min-height:100vh;}
.topbar{background:var(--topbar-bg);backdrop-filter:blur(10px);padding:15px 30px;display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid var(--border-color);position:sticky;top:0;z-index:999;}
.panel-custom{border:none;border-radius:12px;background:var(--panel-bg);box-shadow:0 4px 15px rgba(0,0,0,0.02);margin-bottom:30px;}
.panel-custom-header{padding:20px;font-size:1.05rem;font-weight:600;color:#fff;border-top-left-radius:12px;border-top-right-radius:12px;background:var(--panel-header-bg);display:flex;justify-content:space-between;align-items:center;}
.panel-custom-body{padding:24px;}
.profile-avatar-wrap{flex-shrink:0;margin-right:10px;}
    </style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-cart-plus me-2"></i> Registrar Nueva Compra</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill"></i> <span id="txt-reloj">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill"></i> <span id="txt-fecha">--/--/----</span></div>
            <div class="user-profile shadow-sm"><div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="<?php echo BASE_URL; ?>assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div><div class="profile-info"><div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div><div class="profile-role"><?php echo $_SESSION["rol"]; ?></div></div></div>
        </div>
    </div>
    <div class="container-fluid p-4">
        <form method="POST" action="guardar.php" id="compraForm">
            <div class="row">
                <div class="col-lg-8">
                    <div class="panel-custom shadow-sm">
                        <div class="panel-custom-header d-flex justify-content-between align-items-center">
                            <span><i class="bi bi-cart4 me-2"></i> Productos</span>
                            <a href="editar_precios_productos.php" class="btn btn-sm btn-light" style="color:#1e3c72;font-weight:600;" target="_blank">
                                <i class="bi bi-currency-dollar me-1"></i>Editar Precios
                            </a>
                        </div>
                        <div class="panel-custom-body p-4">
                            <div class="row g-3 mb-3">
                                <div class="col-md-5">
                                    <label class="form-label fw-bold">Producto</label>
                                    <select id="productoSelect" class="form-select">
                                        <option value="">-- Seleccione --</option>
                                        <?php mysqli_data_seek($productos, 0); while($p = mysqli_fetch_assoc($productos)): ?>
                                        <option value="<?php echo $p['id_producto']; ?>" data-precio_venta="<?php echo $p['precio']; ?>" data-nombre="<?php echo $p['nombre_producto']; ?>">
                                            <?php echo $p['nombre_producto']; ?> (Venta: Bs. <?php echo $p['precio']; ?>)
                                        </option>
                                        <?php endwhile; ?>
                                    </select>
                                </div>
                                <div class="col-md-2">
                                    <label class="form-label fw-bold">Cantidad</label>
                                    <input type="number" id="cantidadInput" class="form-control" value="1" min="1">
                                </div>
                                <div class="col-md-3">
                                    <label class="form-label fw-bold">Precio Compra (c/u)</label>
                                    <input type="number" id="precioCompraInput" class="form-control" value="0" min="0" step="0.01">
                                </div>
                                <div class="col-md-2 d-flex align-items-end">
                                    <button type="button" class="btn btn-success w-100" onclick="agregarProducto()">
                                        <i class="bi bi-plus-circle me-1"></i> Agregar
                                    </button>
                                </div>
                            </div>
                            <div class="small text-muted mb-3"><i class="bi bi-info-circle me-1"></i> El <strong>precio de compra</strong> es lo que paga al proveedor (precio por unidad). El precio de venta se muestra como referencia.</div>
                            <div class="table-responsive">
                                <table class="table table-hover align-middle mb-0">
                                    <thead class="table-light">
                                        <tr>
                                            <th style="width:40px;">N°</th>
                                            <th>Producto</th>
                                            <th style="width:70px;">Cant.</th>
                                            <th style="width:110px;">Precio Compra</th>
                                            <th style="width:100px;">Precio Venta</th>
                                            <th style="width:100px;">Subtotal</th>
                                            <th style="width:50px;"></th>
                                        </tr>
                                    </thead>
                                    <tbody id="cartBody"></tbody>
                                    <tfoot>
                                        <tr class="fw-bold">
                                            <td colspan="5" class="text-end">TOTAL:</td>
                                            <td id="totalDisplay">Bs. 0.00</td>
                                            <td></td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                            <input type="hidden" name="productos_json" id="productosJson">
                            <input type="hidden" name="total" id="totalHidden">
                        </div>
                    </div>
                </div>
                <div class="col-lg-4">
                    <div class="panel-custom shadow-sm">
                        <div class="panel-custom-header">
                            <i class="bi bi-info-circle me-2"></i> Datos de Compra
                        </div>
                        <div class="panel-custom-body p-4">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Fecha</label>
                                <input type="date" name="fecha" class="form-control" value="<?php echo date('Y-m-d'); ?>" required>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">Proveedor</label>
                                <select name="proveedor_id" class="form-select" required>
                                    <option value="">Seleccione un proveedor</option>
                                    <?php mysqli_data_seek($proveedores, 0); while($p = mysqli_fetch_assoc($proveedores)){ ?>
                                    <option value="<?php echo $p['id_proveedor']; ?>"><?php echo htmlspecialchars($p['nombre']); ?></option>
                                    <?php } ?>
                                </select>
                            </div>
                            <div class="mb-3">
                                <label class="form-label fw-bold">N° Factura</label>
                                <input type="text" name="nro_factura" class="form-control" placeholder="Factura del proveedor" required>
                            </div>
                            <hr>
                            <button type="submit" class="btn btn-primary w-100" style="background:#1e3c72;border:none;padding:12px;">
                                <i class="bi bi-check-circle-fill me-1"></i> Registrar Compra
                            </button>
                            <a href="index.php" class="btn btn-outline-secondary w-100 mt-2">Cancelar</a>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </div>
</div>

<script src="<?php echo BASE_URL; ?>assets/js/bootstrap.bundle.min.js"></script>
<script>
    function inicializarRelojYFecha() {
        const ahora = new Date();
        document.getElementById('txt-reloj').textContent = String(ahora.getHours()).padStart(2,'0')+':'+String(ahora.getMinutes()).padStart(2,'0')+':'+String(ahora.getSeconds()).padStart(2,'0');
        const meses = ['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];
        document.getElementById('txt-fecha').textContent = String(ahora.getDate()).padStart(2,'0')+'/'+meses[ahora.getMonth()]+'/'+ahora.getFullYear();
    }
    inicializarRelojYFecha();
    setInterval(inicializarRelojYFecha, 1000);
    (function(){
        var toggle = document.createElement('div');
        toggle.className = 'widget-box';
        toggle.id = 'darkModeToggle';
        toggle.style.cssText = 'cursor:pointer;background:#f1f5f9;border-radius:20px;padding:6px 14px;';
        var savedTheme = localStorage.getItem('theme');
        toggle.innerHTML = '<i class="bi ' + (savedTheme === 'dark' ? 'bi-moon-fill' : savedTheme === 'sepia' ? 'bi-brightness-alt-high-fill' : 'bi-sun-fill') + '"></i>';
        toggle.title = 'Modo oscuro';
        var widgets = document.querySelector('.topbar-widgets');
        if(widgets) {
            var profile = widgets.querySelector('.user-profile');
            widgets.insertBefore(toggle, profile);
            toggle.addEventListener('click', function(){
                if (window.ciclarTema) { window.ciclarTema(); }
                var cur = document.documentElement.getAttribute('data-theme') || 'light';
                toggle.innerHTML = '<i class="bi ' + (cur === 'dark' ? 'bi-moon-fill' : cur === 'sepia' ? 'bi-brightness-alt-high-fill' : 'bi-sun-fill') + '"></i>';
            });
        }
        if (window.aplicarTema) { window.aplicarTema(localStorage.getItem('theme') || 'light'); }
    })();
    document.addEventListener('keydown', function(e){
        if(e.ctrlKey && e.key === 'n'){ e.preventDefault();
            var nl = document.querySelector('a[href*="nuevo.php"]');
            if(nl) window.location.href = nl.getAttribute('href'); }
        if(e.ctrlKey && e.key === 'f'){ e.preventDefault();
            var b = document.getElementById('buscador');
            if(b) b.focus(); }
        if(e.ctrlKey && e.key === 's'){ e.preventDefault();
            var f = document.querySelector('form');
            if(f) f.submit(); }
    });

    var carrito = [];

    function agregarProducto() {
        var select = document.getElementById('productoSelect');
        var cantidad = parseInt(document.getElementById('cantidadInput').value) || 1;
        var precioCompra = parseFloat(document.getElementById('precioCompraInput').value) || 0;
        if (!select.value) { alert('Seleccione un producto'); return; }
        var opt = select.options[select.selectedIndex];
        var id = select.value;
        var nombre = opt.getAttribute('data-nombre');
        var precioVenta = parseFloat(opt.getAttribute('data-precio_venta'));
        if (cantidad < 1) { alert('Cantidad invalida'); return; }
        if (precioCompra <= 0) { alert('Ingrese el precio de compra'); return; }
        var existente = carrito.findIndex(function(p) { return p.id == id; });
        if (existente >= 0) {
            carrito[existente].cantidad += cantidad;
            carrito[existente].precio_compra = precioCompra;
        } else {
            carrito.push({ id: id, nombre: nombre, cantidad: cantidad, precio_compra: precioCompra, precio_venta: precioVenta });
        }
        select.value = '';
        document.getElementById('cantidadInput').value = 1;
        document.getElementById('precioCompraInput').value = '';
        renderizarCarrito();
    }

    function eliminarProducto(index) {
        carrito.splice(index, 1);
        renderizarCarrito();
    }

    function cambiarCantidad(index, nuevaCant) {
        if (nuevaCant < 1) { eliminarProducto(index); return; }
        carrito[index].cantidad = parseInt(nuevaCant);
        renderizarCarrito();
    }

    function renderizarCarrito() {
        var tbody = document.getElementById('cartBody');
        var total = 0;
        var html = '';
        for (var i = 0; i < carrito.length; i++) {
            var p = carrito[i];
            var subtotal = p.cantidad * p.precio_compra;
            total += subtotal;
            html += '<tr>' +
                '<td>' + (i+1) + '</td>' +
                '<td>' + p.nombre + '</td>' +
                '<td><input type="number" class="form-control" style="width:65px;text-align:center;" value="' + p.cantidad + '" min="1" onchange="cambiarCantidad(' + i + ', this.value)"></td>' +
                '<td>Bs. ' + p.precio_compra.toFixed(2) + '</td>' +
                '<td><span class="text-muted">Bs. ' + p.precio_venta.toFixed(2) + '</span></td>' +
                '<td>Bs. ' + subtotal.toFixed(2) + '</td>' +
                '<td><button type="button" class="btn btn-sm btn-danger" onclick="eliminarProducto(' + i + ')"><i class="bi bi-trash"></i></button></td>' +
                '</tr>';
        }
        tbody.innerHTML = html;
        document.getElementById('totalDisplay').textContent = 'Bs. ' + total.toFixed(2);
        document.getElementById('totalHidden').value = total.toFixed(2);
        document.getElementById('productosJson').value = JSON.stringify(carrito);
    }

    document.getElementById('compraForm').addEventListener('submit', function(e) {
        if (carrito.length === 0) {
            e.preventDefault();
            alert('Agregue al menos un producto al carrito');
            return;
        }
    });

    document.getElementById('productoSelect').addEventListener('change', function() {
        var opt = this.options[this.selectedIndex];
        if (opt.value) {
            var precioVenta = parseFloat(opt.getAttribute('data-precio_venta'));
            document.getElementById('precioCompraInput').value = precioVenta.toFixed(2);
        } else {
            document.getElementById('precioCompraInput').value = '';
        }
    });
</script>
</body>
</html>
