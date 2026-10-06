<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id_user = intval($_SESSION['id']);
$rol = isset($_SESSION['rol']) ? strtolower(trim($_SESSION['rol'])) : '';

$error = '';
$success = '';

// Check if box is open
$q_caja = mysqli_query($conexion, "SELECT * FROM caja_flujo WHERE id_usuario = $id_user AND estado = 'ABIERTA' ORDER BY id_caja DESC LIMIT 1");
$caja_abierta = mysqli_fetch_assoc($q_caja);

if(isset($_POST['abrir_caja'])){
    $monto = floatval($_POST['monto_apertura']);
    if($caja_abierta) {
        $error = "Ya tienes una caja abierta.";
    } else {
        mysqli_query($conexion, "INSERT INTO caja_flujo (id_usuario, monto_apertura, estado) VALUES ($id_user, $monto, 'ABIERTA')");
        $success = "Caja abierta con éxito por Bs. " . number_format($monto, 2);
        $q_caja = mysqli_query($conexion, "SELECT * FROM caja_flujo WHERE id_usuario = $id_user AND estado = 'ABIERTA' ORDER BY id_caja DESC LIMIT 1");
        $caja_abierta = mysqli_fetch_assoc($q_caja);
    }
}

if(isset($_POST['cerrar_caja'])){
    $id_caja = intval($_POST['id_caja']);
    $monto = floatval($_POST['monto_cierre']);
    mysqli_query($conexion, "UPDATE caja_flujo SET monto_cierre = $monto, fecha_cierre = NOW(), estado = 'CERRADA' WHERE id_caja = $id_caja");
    $success = "Caja cerrada correctamente con Bs. " . number_format($monto, 2);
    $caja_abierta = null;
}

if(isset($_POST['registrar_gasto'])){
    $desc = mysqli_real_escape_string($conexion, trim($_POST['descripcion']));
    $monto = floatval($_POST['monto']);
    if(!$caja_abierta) {
        $error = "No puedes registrar gastos si no tienes una caja abierta.";
    } else {
        mysqli_query($conexion, "INSERT INTO gastos (descripcion, monto, id_usuario) VALUES ('$desc', $monto, $id_user)");
        $success = "Gasto registrado correctamente por Bs. " . number_format($monto, 2);
    }
}

// Historial
$historial_cajas = mysqli_query($conexion, "SELECT * FROM caja_flujo WHERE id_usuario = $id_user ORDER BY id_caja DESC LIMIT 20");
$gastos = mysqli_query($conexion, "SELECT * FROM gastos WHERE DATE(fecha) = CURDATE() ORDER BY id_gasto DESC");

// Cálculos de caja actual
$total_gastos = 0;
$total_ventas = 0;

if($caja_abierta) {
    // Total ventas desde la apertura
    $fecha_apertura = $caja_abierta['fecha_apertura'];
    $q_v = mysqli_query($conexion, "SELECT SUM(total) as t FROM ventas WHERE fecha >= '$fecha_apertura' AND id_usuario = $id_user");
    $r_v = mysqli_fetch_assoc($q_v);
    $total_ventas = floatval($r_v['t']);
    
    // Total gastos desde la apertura
    $q_g = mysqli_query($conexion, "SELECT SUM(monto) as t FROM gastos WHERE fecha >= '$fecha_apertura' AND id_usuario = $id_user");
    $r_g = mysqli_fetch_assoc($q_g);
    $total_gastos = floatval($r_g['t']);
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Caja y Finanzas - Librería San Martín</title>
    
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
            --border-color: rgba(0,0,0,0.05);
            --form-bg: #ffffff;
            --form-text: #333;
            --form-border: #dee2e6;
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
            --border-color: rgba(255,255,255,0.06);
            --form-bg: #1e293b;
            --form-text: #f1f5f9;
            --form-border: #334155;
        }
body { background: var(--body-bg); font-family: 'Segoe UI', sans-serif; margin: 0; overflow-x: hidden; color: var(--profile-text); }
.sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; }
.sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; }
.sidebar-menu { flex: 1; overflow-y: auto; padding: 15px 10px; }
.sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; border-left: 3px solid transparent; }
.sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
.sidebar-menu a:hover { background: var(--sidebar-hover-bg); color: var(--sidebar-accent); border-left-color: var(--sidebar-accent); }
.sidebar-menu a.active { background: var(--sidebar-active-bg); color: var(--sidebar-accent); font-weight: 700; border-left: 4px solid var(--sidebar-accent); }
.main-content { margin-left: 260px; min-height: 100vh; }
.topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); position: sticky; top: 0; z-index: 999; }
.topbar-title { font-size: 1.2rem; font-weight: 600; color: #1e3c72; }
[data-theme="dark"] .topbar-title { color: #60a5fa; }
.user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; }
.profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; margin-right: 10px; }
.panel-custom { border: none; border-radius: 12px; background: var(--panel-bg); box-shadow: 0 4px 15px rgba(0,0,0,0.02); margin-bottom: 30px; }
.panel-custom-header { padding: 20px; font-size: 1.05rem; font-weight: 600; color: #ffffff; border-top-left-radius: 12px; border-top-right-radius: 12px; background: var(--panel-header-bg); }
/* Dark Mode Form */
        [data-theme="dark"] .form-control { background-color: var(--form-bg); color: var(--form-text); border-color: var(--form-border); }
[data-theme="dark"] .input-group-text { background-color: #0f172a; color: var(--form-text); border-color: var(--form-border); }
[data-theme="dark"] .table { color: var(--profile-text); }
[data-theme="dark"] .table-light th { background-color: #334155 !important; color: #f1f5f9; border-color: var(--border-color); }
[data-theme="dark"] .table td { border-color: var(--border-color); }
.stat-card-finance { border-radius: 15px; padding: 20px; color: white; display: flex; align-items: center; justify-content: space-between; }
.stat-card-finance i { font-size: 3rem; opacity: 0.5; }
.stat-card-finance h3 { font-size: 2rem; margin: 0; font-weight: 700; }
.bg-open { background: linear-gradient(135deg, #10b981, #047857); }
.bg-close { background: linear-gradient(135deg, #ef4444, #b91c1c); }
.bg-neutral { background: linear-gradient(135deg, #64748b, #334155); }
    </style>
</head>
<body>

<?php $base_path = '../'; include '../includes/sidebar.php'; ?>

<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-wallet-fill me-2"></i> Finanzas y Control de Caja</div>
        <div class="d-flex align-items-center">
            <button id="darkModeToggle" class="btn btn-sm btn-outline-secondary rounded-circle me-3" style="width:36px;height:36px;"><i class="bi bi-moon-fill"></i></button>
            <div class="user-profile shadow-sm">
                <div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div>
                <div style="line-height:1.2;">
                    <div style="font-size:0.88rem; font-weight:bold;"><?php echo $_SESSION["nombre"]; ?></div>
                    <div style="font-size:0.7rem; opacity:0.8;"><?php echo $_SESSION["rol"]; ?></div>
                </div>
            </div>
        </div>
    </div>

    <div class="container-fluid p-4">
        
        <?php if($error): ?><div class="alert alert-danger"><i class="bi bi-exclamation-triangle-fill me-2"></i><?php echo $error; ?></div><?php endif; ?>
        <?php if($success): ?><div class="alert alert-success"><i class="bi bi-check-circle-fill me-2"></i><?php echo $success; ?></div><?php endif; ?>

        <!-- Sección Superior: Estado de Caja -->
        <div class="row g-4 mb-4">
            <div class="col-md-6">
                <div class="panel-custom shadow-sm h-100 mb-0">
                    <div class="panel-custom-header <?php echo $caja_abierta ? 'bg-open' : 'bg-close'; ?>">
                        <i class="bi <?php echo $caja_abierta ? 'bi-unlock-fill' : 'bi-lock-fill'; ?> me-2"></i> 
                        Estado de Caja: <?php echo $caja_abierta ? 'ABIERTA' : 'CERRADA'; ?>
                    </div>
                    <div class="panel-custom-body p-4 text-center">
                        <?php if($caja_abierta): ?>
                            <h5 class="text-muted mb-3">Caja aperturada el <?php echo date('d/m/Y H:i', strtotime($caja_abierta['fecha_apertura'])); ?></h5>
                            <h2 class="text-success fw-bold mb-4">Bs. <?php echo number_format($caja_abierta['monto_apertura'], 2); ?> <small class="text-muted fs-6">(Monto Inicial)</small></h2>
                            
                            <form method="POST" class="d-inline-block">
                                <input type="hidden" name="id_caja" value="<?php echo $caja_abierta['id_caja']; ?>">
                                <?php 
                                    $efectivo_esperado = $caja_abierta['monto_apertura'] + $total_ventas - $total_gastos;
                                ?>
                                <input type="hidden" name="monto_cierre" value="<?php echo $efectivo_esperado; ?>">
                                <button type="submit" name="cerrar_caja" class="btn btn-danger btn-lg px-5 shadow-sm rounded-pill" data-confirm="¿Confirma que desea cerrar la caja con Bs. <?php echo number_format($efectivo_esperado, 2); ?>?">
                                    <i class="bi bi-lock-fill me-2"></i> Cerrar Caja (Cuadrar)
                                </button>
                            </form>
                            <p class="mt-3 text-muted small"><i class="bi bi-info-circle me-1"></i> Se espera cerrar con <strong>Bs. <?php echo number_format($efectivo_esperado, 2); ?></strong> en caja (Monto Inicial + Ventas - Gastos)</p>
                        <?php else: ?>
                            <h5 class="text-muted mb-4">Debes abrir la caja para poder realizar ventas hoy.</h5>
                            <form method="POST" class="mx-auto" style="max-width: 300px;">
                                <div class="input-group mb-3">
                                    <span class="input-group-text fw-bold">Bs.</span>
                                    <input type="number" step="0.01" name="monto_apertura" class="form-control form-control-lg text-center fw-bold" placeholder="Monto Inicial (Ej. 100.00)" required>
                                </div>
                                <button type="submit" name="abrir_caja" class="btn btn-success btn-lg w-100 shadow-sm rounded-pill">
                                    <i class="bi bi-unlock-fill me-2"></i> Abrir Caja Ahora
                                </button>
                            </form>
                        <?php endif; ?>
                    </div>
                </div>
            </div>

            <!-- Registro de Gastos -->
            <div class="col-md-6">
                <div class="panel-custom shadow-sm h-100 mb-0">
                    <div class="panel-custom-header bg-neutral">
                        <i class="bi bi-receipt-cutoff me-2"></i> Registrar Gasto Operativo
                    </div>
                    <div class="panel-custom-body p-4">
                        <form method="POST">
                            <div class="mb-3">
                                <label class="form-label fw-bold">Descripción del Gasto</label>
                                <input type="text" name="descripcion" class="form-control" placeholder="Ej. Pago de pasajes, compra de bolsas..." required <?php echo !$caja_abierta?'disabled':''; ?>>
                            </div>
                            <div class="mb-4">
                                <label class="form-label fw-bold">Monto (Bs.)</label>
                                <div class="input-group">
                                    <span class="input-group-text">Bs.</span>
                                    <input type="number" step="0.01" name="monto" class="form-control" placeholder="0.00" required <?php echo !$caja_abierta?'disabled':''; ?>>
                                </div>
                            </div>
                            <button type="submit" name="registrar_gasto" class="btn btn-primary w-100" <?php echo !$caja_abierta?'disabled':''; ?>>
                                <i class="bi bi-save me-2"></i> Registrar Gasto (Resta de caja)
                            </button>
                            <?php if(!$caja_abierta): ?>
                                <div class="text-danger small mt-2 text-center"><i class="bi bi-exclamation-circle me-1"></i> Abre la caja para registrar gastos.</div>
                            <?php endif; ?>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <!-- Gastos de hoy -->
            <div class="col-md-5">
                <div class="panel-custom shadow-sm">
                    <div class="panel-custom-header bg-secondary">
                        <i class="bi bi-card-checklist me-2"></i> Gastos de Hoy
                    </div>
                    <div class="panel-custom-body p-0">
                        <table class="table table-hover mb-0">
                            <tbody>
                                <?php if(mysqli_num_rows($gastos) > 0): ?>
                                    <?php while($g = mysqli_fetch_assoc($gastos)): ?>
                                    <tr>
                                        <td class="p-3">
                                            <div class="fw-bold"><?php echo htmlspecialchars($g['descripcion']); ?></div>
                                            <div class="small text-muted"><?php echo date('H:i', strtotime($g['fecha'])); ?></div>
                                        </td>
                                        <td class="text-end p-3 text-danger fw-bold">
                                            - Bs. <?php echo number_format($g['monto'], 2); ?>
                                        </td>
                                    </tr>
                                    <?php endwhile; ?>
                                <?php else: ?>
                                    <tr><td class="text-center py-4 text-muted">No hay gastos registrados hoy.</td></tr>
                                <?php endif; ?>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            
            <!-- Historial de Cajas -->
            <div class="col-md-7">
                <div class="panel-custom shadow-sm">
                    <div class="panel-custom-header">
                        <i class="bi bi-clock-history me-2"></i> Historial de Aperturas/Cierres
                    </div>
                    <div class="panel-custom-body p-3">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle">
                                <thead>
                                    <tr class="table-light">
                                        <th>Estado</th>
                                        <th>Apertura</th>
                                        <th>Cierre</th>
                                        <th class="text-end">Monto Inicial</th>
                                        <th class="text-end">Monto Final</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <?php if(mysqli_num_rows($historial_cajas) > 0): ?>
                                        <?php while($hc = mysqli_fetch_assoc($historial_cajas)): ?>
                                        <tr>
                                            <td>
                                                <?php if($hc['estado'] == 'ABIERTA'): ?>
                                                    <span class="badge bg-success">ABIERTA</span>
                                                <?php else: ?>
                                                    <span class="badge bg-secondary">CERRADA</span>
                                                <?php endif; ?>
                                            </td>
                                            <td><small><?php echo date('d/m/Y H:i', strtotime($hc['fecha_apertura'])); ?></small></td>
                                            <td><small><?php echo $hc['fecha_cierre'] ? date('d/m/Y H:i', strtotime($hc['fecha_cierre'])) : '-'; ?></small></td>
                                            <td class="text-end">Bs. <?php echo number_format($hc['monto_apertura'], 2); ?></td>
                                            <td class="text-end fw-bold">
                                                <?php echo $hc['monto_cierre'] ? 'Bs. '.number_format($hc['monto_cierre'], 2) : '-'; ?>
                                            </td>
                                        </tr>
                                        <?php endwhile; ?>
                                    <?php else: ?>
                                        <tr><td colspan="5" class="text-center py-4 text-muted">No hay registros históricos de caja.</td></tr>
                                    <?php endif; ?>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    // Cambiar tema
    const btn = document.getElementById('darkModeToggle');
    if (window.aplicarTema) { window.aplicarTema(localStorage.getItem('theme') || 'light'); }
    if (btn) {
        var savedT = localStorage.getItem('theme');
        btn.innerHTML = '<i class="bi ' + (savedT === 'dark' ? 'bi-moon-fill' : savedT === 'sepia' ? 'bi-brightness-alt-high-fill' : 'bi-sun-fill') + '"></i>';
        btn.addEventListener('click', () => {
            if (window.ciclarTema) { window.ciclarTema(); }
            var cur = document.documentElement.getAttribute('data-theme') || 'light';
            btn.innerHTML = '<i class="bi ' + (cur === 'dark' ? 'bi-moon-fill' : cur === 'sepia' ? 'bi-brightness-alt-high-fill' : 'bi-sun-fill') + '"></i>';
        });
    }
</script>
</body>
</html>
