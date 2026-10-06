<?php
session_start();
include("../config/conexion.php");
include("../includes/csrf.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$search = trim($_GET['q'] ?? '');
$pagina = max(1, intval($_GET['pagina'] ?? 1));
$por_pagina = 20;
$offset = ($pagina - 1) * $por_pagina;

$where = "WHERE p.activo=1";
$params = [];
if ($search !== '') {
    $s = mysqli_real_escape_string($conexion, $search);
    $where .= " AND (p.nombre_producto LIKE '%$s%' OR p.codigo LIKE '%$s%' OR p.codigo_barras LIKE '%$s%' OR c.nombre_categoria LIKE '%$s%')";
}

$total_q = mysqli_query($conexion, "SELECT COUNT(*) as total FROM productos p LEFT JOIN categorias c ON p.categoria_id = c.id_categoria $where");
$total_f = $total_q ? mysqli_fetch_assoc($total_q) : ['total' => 0];
$total_reg = $total_f['total'];
$total_pag = max(1, ceil($total_reg / $por_pagina));

$sql = "SELECT p.*, c.nombre_categoria FROM productos p 
        LEFT JOIN categorias c ON p.categoria_id = c.id_categoria 
        $where ORDER BY p.nombre_producto ASC LIMIT $por_pagina OFFSET $offset";
$productos = mysqli_query($conexion, $sql);
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Editar Precios de Productos - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
:root {
            --body-bg: #f0f3f8;
            --sidebar-bg: #ffffff;
            --sidebar-text: #1e293b;
            --sidebar-hover-bg: #e2e8f0;
            --sidebar-accent: #1e3c72;
            --sidebar-active-bg: linear-gradient(90deg, rgba(30,60,114,0.12), rgba(42,82,152,0.05));
            --sidebar-brand-bg: linear-gradient(135deg, #1e3c72, #2a5298);
            --topbar-bg: rgba(255,255,255,0.85);
            --panel-bg: #ffffff;
            --panel-header-bg: linear-gradient(135deg, #2a5298, #1e3c72);
            --profile-bg: #f1f5f9;
            --profile-text: #333;
            --scrollbar-thumb: rgba(0,0,0,0.12);
            --scrollbar-thumb-hover: rgba(0,0,0,0.25);
            --form-bg: #ffffff;
            --form-text: #212529;
            --form-border: #dee2e6;
            --input-group-bg: #e9ecef;
            --border-color: rgba(0,0,0,0.05);
        }
[data-theme="dark"] {
            --body-bg: #0f172a;
            --sidebar-bg: #1e293b;
            --sidebar-text: #cbd5e1;
            --sidebar-hover-bg: #334155;
            --sidebar-accent: #60a5fa;
            --sidebar-active-bg: linear-gradient(90deg, rgba(59,130,246,0.15), rgba(37,99,235,0.08));
            --sidebar-brand-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --topbar-bg: rgba(30,41,59,0.95);
            --panel-bg: #1e293b;
            --panel-header-bg: linear-gradient(135deg, #0f172a, #1e293b);
            --profile-bg: #334155;
            --profile-text: #e2e8f0;
            --scrollbar-thumb: rgba(255,255,255,0.15);
            --scrollbar-thumb-hover: rgba(255,255,255,0.25);
            --form-bg: #1e293b;
            --form-text: #f1f5f9;
            --form-border: #334155;
            --form-focus-border: #60a5fa;
            --input-group-bg: #0f172a;
            --border-color: rgba(255,255,255,0.06);
        }
body { background: var(--body-bg); font-family: 'Segoe UI', system-ui, -apple-system, sans-serif; margin: 0; overflow-x: hidden; }
.sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; }
.sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; }
.sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
.sidebar-menu::-webkit-scrollbar { width: 4px; }
.sidebar-menu::-webkit-scrollbar-track { background: transparent; }
.sidebar-menu::-webkit-scrollbar-thumb { background: var(--scrollbar-thumb); border-radius: 10px; }
.sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; border-left: 3px solid transparent; }
.sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
.sidebar-menu a:hover { background: var(--sidebar-hover-bg); border-left-color: var(--sidebar-accent); }
.main-content { margin-left: 260px; min-height: 100vh; }
.topbar { display: flex; justify-content: space-between; align-items: center; padding: 12px 25px; background: var(--topbar-bg); backdrop-filter: blur(12px); border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 500; }
.topbar h5 { margin: 0; font-weight: 700; color: var(--sidebar-text); }
.user-profile { display: flex; align-items: center; gap: 12px; }
.user-profile .avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--sidebar-brand-bg); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; }
.user-profile .avatar img { width: 38px; height: 38px; border-radius: 50%; object-fit: cover; }
.panel-custom { background: var(--panel-bg); border-radius: 12px; overflow: hidden; }
.panel-custom-header { background: var(--panel-header-bg); color: #fff; padding: 14px 20px; font-weight: 700; font-size: 1.1rem; }
.panel-custom-body { padding: 20px; }
[data-theme="dark"] .form-control, [data-theme="dark"] .form-select {
            background-color: var(--form-bg); color: var(--form-text); border-color: var(--form-border);
        }
[data-theme="dark"] .form-control:focus, [data-theme="dark"] .form-select:focus {
            border-color: var(--form-focus-border); box-shadow: 0 0 0 0.2rem rgba(96,165,250,0.15);
        }
[data-theme="dark"] .input-group-text { background: var(--input-group-bg) !important; color: var(--form-text); border-color: var(--form-border); }
.form-label { color: var(--profile-text); }
.price-input { width: 100px; text-align: center; font-weight: 600; }
.price-input:focus { border-color: var(--sidebar-accent); box-shadow: 0 0 0 0.2rem rgba(30,60,114,0.15); }
.margin-positivo { color: #16a34a; font-weight: 700; }
.margin-cero { color: #94a3b8; }
.margin-negativo { color: #dc2626; font-weight: 700; }
.toast-container { position: fixed; top: 20px; right: 20px; z-index: 9999; }
    </style>
</head>
<body>

<?php $base_path = '../'; include("../includes/sidebar.php"); ?>

<div class="main-content">
    <div class="topbar">
        <h5><i class="bi bi-currency-dollar me-2"></i>Editar Precios de Productos</h5>
        <div class="user-profile">
            <span style="color:var(--sidebar-text);font-weight:500;"><?php echo htmlspecialchars($_SESSION['nombre'] ?? ''); ?></span>
            <div class="avatar">
                <?php if(!empty($_SESSION['imagen'])): ?>
                    <img src="../assets/uploads/usuarios/<?php echo htmlspecialchars($_SESSION['imagen']); ?>" alt="">
                <?php else: ?>
                    <?php echo strtoupper(substr($_SESSION['nombre'] ?? 'E', 0, 1)); ?>
                <?php endif; ?>
            </div>
        </div>
    </div>

    <div class="container-fluid p-4">
        <div class="d-flex justify-content-between align-items-center mb-3">
            <div>
                <a href="nuevo.php" class="btn btn-outline-secondary btn-sm"><i class="bi bi-arrow-left"></i> Volver a Nueva Compra</a>
                <span class="ms-2 text-muted small"><?php echo $total_reg; ?> producto(s)</span>
            </div>
            <form method="GET" class="d-flex gap-2">
                <div class="input-group">
                    <span class="input-group-text bg-light"><i class="bi bi-search"></i></span>
                    <input type="text" name="q" class="form-control" placeholder="Buscar producto..." value="<?php echo htmlspecialchars($search); ?>">
                </div>
                <button type="submit" class="btn btn-primary" style="background:#1e3c72;border:none;"><i class="bi bi-search"></i></button>
                <?php if ($search): ?>
                    <a href="editar_precios_productos.php" class="btn btn-outline-secondary"><i class="bi bi-x-lg"></i></a>
                <?php endif; ?>
            </form>
        </div>

        <div class="panel-custom shadow-sm">
            <div class="panel-custom-header d-flex justify-content-between align-items-center">
                <span><i class="bi bi-table me-2"></i>Precios de Productos</span>
                <span class="badge bg-light text-dark">Pág. <?php echo $pagina; ?> de <?php echo $total_pag; ?></span>
            </div>
            <div class="panel-custom-body p-0">
                <div class="table-responsive">
                    <table class="table table-hover mb-0" id="priceTable">
                        <thead class="table-light">
                            <tr>
                                <th>Código</th>
                                <th>Producto</th>
                                <th>Categoría</th>
                                <th class="text-center">Stock</th>
                                <th class="text-center">Precio Compra (Bs.)</th>
                                <th class="text-center">Precio Venta (Bs.)</th>
                                <th class="text-center">Ganancia</th>
                                <th class="text-center">%</th>
                                <th class="text-center">Guardar</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php if ($productos && mysqli_num_rows($productos) > 0): ?>
                                <?php while ($p = mysqli_fetch_assoc($productos)): 
                                    $pc = floatval($p['precio_compra'] ?? 0);
                                    $pv = floatval($p['precio'] ?? 0);
                                    $margen = $pv - $pc;
                                    $porcentaje = $pc > 0 ? round(($margen / $pc) * 100, 1) : ($pv > 0 ? 100 : 0);
                                    $margenClass = $margen > 0 ? 'margin-positivo' : ($margen < 0 ? 'margin-negativo' : 'margin-cero');
                                ?>
                                <tr data-id="<?php echo $p['id_producto']; ?>">
                                    <td><span class="text-muted small"><?php echo htmlspecialchars($p['codigo'] ?? ''); ?></span></td>
                                    <td>
                                        <strong><?php echo htmlspecialchars($p['nombre_producto']); ?></strong>
                                        <?php if(!empty($p['talla']) || !empty($p['color'])): ?>
                                            <br><small class="text-muted"><?php echo $p['talla'] ? htmlspecialchars($p['talla']) : ''; ?><?php echo ($p['talla'] && $p['color']) ? ' / ' : ''; ?><?php echo $p['color'] ? htmlspecialchars($p['color']) : ''; ?></small>
                                        <?php endif; ?>
                                    </td>
                                    <td><span class="badge bg-light text-dark border"><?php echo htmlspecialchars($p['nombre_categoria'] ?? ''); ?></span></td>
                                    <td class="text-center fw-bold"><?php echo $p['stock']; ?></td>
                                    <td class="text-center">
                                        <input type="number" step="0.01" min="0" class="form-control form-control-sm price-input mx-auto precio-compra" value="<?php echo number_format($pc, 2, '.', ''); ?>">
                                    </td>
                                    <td class="text-center">
                                        <input type="number" step="0.01" min="0" class="form-control form-control-sm price-input mx-auto precio-venta" value="<?php echo number_format($pv, 2, '.', ''); ?>">
                                    </td>
                                    <td class="text-center <?php echo $margenClass; ?> margen-val">
                                        Bs. <?php echo number_format($margen, 2); ?>
                                    </td>
                                    <td class="text-center <?php echo $margenClass; ?> porcentaje-val">
                                        <?php echo $porcentaje; ?>%
                                    </td>
                                    <td class="text-center">
                                        <button class="btn btn-sm btn-success save-row" data-id="<?php echo $p['id_producto']; ?>" title="Guardar cambios">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </td>
                                </tr>
                                <?php endwhile; ?>
                            <?php else: ?>
                                <tr><td colspan="9" class="text-center text-muted py-4">No se encontraron productos.</td></tr>
                            <?php endif; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <?php if ($total_pag > 1): ?>
        <nav class="mt-3">
            <ul class="pagination justify-content-center">
                <?php for ($i = 1; $i <= $total_pag; $i++): ?>
                    <li class="page-item <?php echo $i == $pagina ? 'active' : ''; ?>">
                        <a class="page-link" href="?pagina=<?php echo $i; ?>&q=<?php echo urlencode($search); ?>"><?php echo $i; ?></a>
                    </li>
                <?php endfor; ?>
            </ul>
        </nav>
        <?php endif; ?>
    </div>
</div>

<div class="toast-container" id="toastContainer"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function showToast(msg, type) {
        type = type || 'success';
        var container = document.getElementById('toastContainer');
        var bg = type === 'success' ? '#16a34a' : '#dc2626';
        var html = '<div style="background:'+bg+';color:#fff;padding:12px 20px;border-radius:8px;margin-bottom:8px;box-shadow:0 4px 12px rgba(0,0,0,0.15);display:flex;align-items:center;gap:8px;">';
        html += '<i class="bi ' + (type === 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill') + '"></i>';
        html += msg + '</div>';
        container.insertAdjacentHTML('beforeend', html);
        setTimeout(function() {
            var el = container.lastElementChild;
            if (el) el.remove();
        }, 3000);
    }

    // Live recalc on input change
    document.querySelectorAll('.precio-compra, .precio-venta').forEach(function(inp) {
        inp.addEventListener('input', function() {
            var tr = this.closest('tr');
            var pc = parseFloat(tr.querySelector('.precio-compra').value) || 0;
            var pv = parseFloat(tr.querySelector('.precio-venta').value) || 0;
            var margen = pv - pc;
            var pct = pc > 0 ? ((margen / pc) * 100).toFixed(1) : (pv > 0 ? '100.0' : '0.0');
            var margenEl = tr.querySelector('.margen-val');
            var pctEl = tr.querySelector('.porcentaje-val');
            margenEl.textContent = 'Bs. ' + margen.toFixed(2);
            pctEl.textContent = pct + '%';
            var cls = margen > 0 ? 'margin-positivo' : (margen < 0 ? 'margin-negativo' : 'margin-cero');
            margenEl.className = 'text-center ' + cls + ' margen-val';
            pctEl.className = 'text-center ' + cls + ' porcentaje-val';
        });
    });

    // Save row via AJAX
    document.querySelectorAll('.save-row').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var tr = this.closest('tr');
            var id = this.getAttribute('data-id');
            var pc = parseFloat(tr.querySelector('.precio-compra').value) || 0;
            var pv = parseFloat(tr.querySelector('.precio-venta').value) || 0;
            var origBtn = this;
            origBtn.disabled = true;
            origBtn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';

            fetch('ajax_guardar_precio.php', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'id_producto=' + id + '&precio_compra=' + pc + '&precio=' + pv + '&csrf_token=' + encodeURIComponent('<?php echo generarCsrf(); ?>')
            })
            .then(function(r) { return r.json(); })
            .then(function(d) {
                if (d.success) {
                    showToast(d.message || 'Precio actualizado');
                } else {
                    showToast(d.message || 'Error al guardar', 'error');
                }
                origBtn.disabled = false;
                origBtn.innerHTML = '<i class="bi bi-check-lg"></i>';
            })
            .catch(function() {
                showToast('Error de conexión', 'error');
                origBtn.disabled = false;
                origBtn.innerHTML = '<i class="bi bi-check-lg"></i>';
            });
        });
    });

    (function() {
        var saved = localStorage.getItem('theme');
        if (window.aplicarTema) { window.aplicarTema(saved || 'light'); }
    })();
</script>
</body>
</html>
