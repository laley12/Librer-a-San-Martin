<?php
session_start();
include("../config/conexion.php");

if(!isset($_SESSION['id'])){
    header("Location: ../login/login.php");
    exit();
}

$id_usuario = intval($_SESSION['id']);

// AJAX: Enviar mensaje
if(isset($_POST['ajax']) && $_POST['ajax'] === 'enviar' && isset($_POST['id_destinatario']) && isset($_POST['mensaje'])) {
    $id_dest = intval($_POST['id_destinatario']);
    $mensaje = mysqli_real_escape_string($conexion, trim($_POST['mensaje']));
    if($id_dest > 0 && $mensaje !== '') {
        mysqli_query($conexion, "INSERT INTO mensajes_chat (id_remitente, id_destinatario, mensaje) VALUES ($id_usuario, $id_dest, '$mensaje')");
    }
    exit();
}

// AJAX: Marcar como leidos
if(isset($_GET['ajax']) && $_GET['ajax'] === 'marcar_leido' && isset($_GET['id_destinatario'])) {
    $id_dest = intval($_GET['id_destinatario']);
    mysqli_query($conexion, "UPDATE mensajes_chat SET leido=1 WHERE id_remitente=$id_dest AND id_destinatario=$id_usuario AND leido=0");
    exit();
}

// AJAX: Obtener mensajes de una conversacion
if(isset($_GET['ajax']) && $_GET['ajax'] === 'mensajes' && isset($_GET['id_destinatario'])) {
    $id_dest = intval($_GET['id_destinatario']);
    $msgs = mysqli_query($conexion, "
        SELECT m.*, u.nombre as nombre_remitente
        FROM mensajes_chat m
        INNER JOIN usuarios u ON m.id_remitente = u.id
        WHERE (m.id_remitente=$id_usuario AND m.id_destinatario=$id_dest)
           OR (m.id_remitente=$id_dest AND m.id_destinatario=$id_usuario)
        ORDER BY m.fecha_hora ASC
    ");
    $output = [];
    while($m = mysqli_fetch_assoc($msgs)) {
        $output[] = [
            'id' => $m['id'],
            'id_remitente' => $m['id_remitente'],
            'nombre_remitente' => $m['nombre_remitente'],
            'mensaje' => htmlspecialchars($m['mensaje']),
            'fecha_hora' => $m['fecha_hora'],
            'propio' => ($m['id_remitente'] == $id_usuario)
        ];
    }
    header('Content-Type: application/json');
    echo json_encode($output);
    exit();
}

// AJAX: Obtener lista de conversaciones
if(isset($_GET['ajax']) && $_GET['ajax'] === 'conversaciones') {
    $conv = mysqli_query($conexion, "
        SELECT u.id, u.nombre, u.imagen,
            (SELECT m.mensaje FROM mensajes_chat m WHERE (m.id_remitente=u.id AND m.id_destinatario=$id_usuario) OR (m.id_remitente=$id_usuario AND m.id_destinatario=u.id) ORDER BY m.fecha_hora DESC LIMIT 1) as ultimo_mensaje,
            (SELECT COUNT(*) FROM mensajes_chat WHERE id_remitente=u.id AND id_destinatario=$id_usuario AND leido=0) as no_leidos
        FROM usuarios u
        WHERE u.id != $id_usuario AND u.estado='Activo'
        HAVING ultimo_mensaje IS NOT NULL OR no_leidos > 0
        ORDER BY (SELECT MAX(fecha_hora) FROM mensajes_chat WHERE (id_remitente=u.id AND id_destinatario=$id_usuario) OR (id_remitente=$id_usuario AND id_destinatario=u.id)) DESC
    ");
    $output = [];
    while($c = mysqli_fetch_assoc($conv)) {
        $output[] = [
            'id' => $c['id'],
            'nombre' => $c['nombre'],
            'imagen' => $c['imagen'],
            'ultimo_mensaje' => htmlspecialchars(substr($c['ultimo_mensaje'] ?? '', 0, 60)),
            'no_leidos' => intval($c['no_leidos'])
        ];
    }
    header('Content-Type: application/json');
    echo json_encode($output);
    exit();
}

// AJAX: Buscar usuarios para iniciar conversacion
if(isset($_GET['ajax']) && $_GET['ajax'] === 'buscar_usuarios' && isset($_GET['q'])) {
    $q = mysqli_real_escape_string($conexion, $_GET['q']);
    $users = mysqli_query($conexion, "SELECT id, nombre FROM usuarios WHERE id != $id_usuario AND estado='Activo' AND nombre LIKE '%$q%' LIMIT 10");
    $output = [];
    while($u = mysqli_fetch_assoc($users)) {
        $output[] = ['id' => $u['id'], 'nombre' => $u['nombre']];
    }
    header('Content-Type: application/json');
    echo json_encode($output);
    exit();
}

// Obtener todos los usuarios activos para el selector
$usuarios = mysqli_query($conexion, "SELECT id, nombre FROM usuarios WHERE id != $id_usuario AND estado='Activo' ORDER BY nombre ASC");
$todos_usuarios = [];
while($u = mysqli_fetch_assoc($usuarios)) $todos_usuarios[] = $u;
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Chat Interno - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
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
            --chat-propio: #dce6f5;
            --chat-otro: #f0f0f0;
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
            --chat-propio: #1e3a5f;
            --chat-otro: #334155;
        }
        body { background: var(--body-bg); font-family: 'Segoe UI', sans-serif; margin: 0; overflow-x: hidden; }
        .sidebar { display: flex; flex-direction: column; width: 260px; height: 100vh; position: fixed; background: var(--sidebar-bg); box-shadow: 4px 0 20px rgba(0,0,0,0.03); z-index: 1000; transition: all 0.3s ease; }
        .sidebar-brand { flex-shrink: 0; background: var(--sidebar-brand-bg); color: #ffffff; padding: 20px; font-size: 1.3rem; font-weight: 700; text-align: center; letter-spacing: 0.5px; }
        .sidebar-menu { flex: 1; overflow-y: auto; overflow-x: hidden; padding: 15px 10px; }
        .sidebar-menu a { display: flex; align-items: center; color: var(--sidebar-text); text-decoration: none; padding: 12px 15px; font-size: 0.95rem; border-radius: 8px; margin-bottom: 5px; transition: all 0.25s ease; cursor: pointer; border-left: 3px solid transparent; }
        .sidebar-menu a i { font-size: 1.1rem; margin-right: 12px; width: 25px; text-align: center; }
        .sidebar-menu a:hover { background: var(--sidebar-hover-bg); color: var(--sidebar-accent); border-left-color: var(--sidebar-accent); }
        .sidebar-menu a.active { background: var(--sidebar-active-bg); color: var(--sidebar-accent); font-weight: 700; border-left: 4px solid var(--sidebar-accent); }
        .sidebar.collapsed { width: 70px; }
        .sidebar.collapsed .sidebar-brand span.brand-text { display: none; }
        .sidebar.collapsed .sidebar-brand { font-size: 1.1rem; padding: 20px 0; text-align: center; }
        .sidebar.collapsed .sidebar-menu { padding: 15px 5px; }
        .sidebar.collapsed .sidebar-menu a { padding: 12px 10px; justify-content: center; margin-bottom: 8px; }
        .sidebar.collapsed .sidebar-menu a i.bi { margin-right: 0 !important; font-size: 1.3rem; }
        .sidebar.collapsed .sidebar-menu a span.menu-text { display: none; }
        .sidebar.collapsed .collapse-toggle .chevron-icon { display: none; }
        .sidebar.collapsed .collapse-submenu, .sidebar.collapsed .collapse-submenu-2 { display: none !important; }
        .sidebar.collapsed ~ .main-content { margin-left: 70px; }
        .main-content { margin-left: 260px; height: 100vh; display: flex; flex-direction: column; transition: all 0.3s ease; }
        .topbar { background: var(--topbar-bg); backdrop-filter: blur(10px); padding: 15px 30px; display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid var(--border-color); flex-shrink: 0; }
        .topbar-title { font-size: 1.2rem; font-weight: 600; color: #1e3c72; }
        .topbar-widgets { display: flex; align-items: center; gap: 12px; }
        .widget-box { padding: 6px 14px; border-radius: 20px; font-size: 0.88rem; font-weight: 600; display: flex; align-items: center; box-shadow: 0 2px 6px rgba(0,0,0,0.02); }
        .widget-time { background: #e0f2fe; color: #0369a1; }
        .widget-date { background: #dcfce7; color: #15803d; }
        .widget-weather { background: #fef3c7; color: #d97706; }
        .user-profile { display: flex; align-items: center; background: var(--profile-bg); padding: 6px 14px; border-radius: 20px; font-size: 0.9rem; color: var(--profile-text); }
        .profile-avatar-wrap { flex-shrink: 0; margin-right: 10px; display: flex; align-items: center; }
        .profile-avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
        .profile-avatar-inicial { width: 36px; height: 36px; border-radius: 50%; background: linear-gradient(135deg, #1e3c72, #2a5298); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; border: 2px solid #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.15); }
        .profile-info { display: flex; flex-direction: column; line-height: 1.2; }
        .profile-name { font-size: 0.88rem; white-space: nowrap; }
        .profile-role { font-size: 0.65rem; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; white-space: nowrap; }

        .chat-container { display: flex; flex: 1; overflow: hidden; }
        .chat-list { width: 320px; min-width: 320px; background: var(--panel-bg); border-right: 1px solid var(--border-color); display: flex; flex-direction: column; }
        .chat-list-header { padding: 16px 20px; border-bottom: 1px solid var(--border-color); font-weight: 600; font-size: 1rem; display: flex; justify-content: space-between; align-items: center; }
        .chat-list-body { flex: 1; overflow-y: auto; }
        .chat-list-item { display: flex; align-items: center; padding: 14px 20px; cursor: pointer; transition: background 0.15s; border-bottom: 1px solid var(--border-color); gap: 12px; }
        .chat-list-item:hover { background: var(--sidebar-hover-bg); }
        .chat-list-item.active { background: var(--sidebar-hover-bg); border-left: 3px solid var(--sidebar-accent); }
        .chat-list-item .avatar { width: 42px; height: 42px; border-radius: 50%; background: var(--sidebar-brand-bg); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1rem; flex-shrink: 0; }
        .chat-list-item .avatar img { width: 42px; height: 42px; border-radius: 50%; object-fit: cover; }
        .chat-list-item .info { flex: 1; min-width: 0; }
        .chat-list-item .info .name { font-weight: 600; font-size: 0.92rem; }
        .chat-list-item .info .preview { font-size: 0.82rem; color: #6b7280; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .chat-list-item .badge-unread { background: #dc3545; color: #fff; border-radius: 50%; min-width: 22px; height: 22px; font-size: 0.75rem; font-weight: 700; display: flex; align-items: center; justify-content: center; padding: 0 5px; }

        .chat-main { flex: 1; display: flex; flex-direction: column; background: var(--body-bg); }
        .chat-main-header { padding: 14px 24px; background: var(--panel-bg); border-bottom: 1px solid var(--border-color); font-weight: 600; display: flex; align-items: center; gap: 12px; flex-shrink: 0; }
        .chat-main-header .avatar-sm { width: 36px; height: 36px; border-radius: 50%; background: var(--sidebar-brand-bg); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 0.9rem; flex-shrink: 0; }
        .chat-messages { flex: 1; overflow-y: auto; padding: 20px 24px; display: flex; flex-direction: column; gap: 12px; }
        .chat-message { max-width: 75%; padding: 10px 16px; border-radius: 16px; position: relative; word-wrap: break-word; }
        .chat-message.propio { align-self: flex-end; background: var(--chat-propio); border-bottom-right-radius: 4px; }
        .chat-message.otro { align-self: flex-start; background: var(--chat-otro); border-bottom-left-radius: 4px; }
        .chat-message .msg-text { font-size: 0.92rem; }
        .chat-message .msg-time { font-size: 0.7rem; color: #6b7280; margin-top: 4px; text-align: right; }
        .chat-input-area { padding: 16px 24px; background: var(--panel-bg); border-top: 1px solid var(--border-color); display: flex; gap: 10px; flex-shrink: 0; }
        .chat-input-area input { flex: 1; border-radius: 20px; padding: 10px 18px; border: 1px solid var(--border-color); background: var(--body-bg); }
        .chat-input-area button { border-radius: 50%; width: 44px; height: 44px; display: flex; align-items: center; justify-content: center; background: #1e3c72; color: #fff; border: none; }

        .no-chat-selected { flex: 1; display: flex; align-items: center; justify-content: center; color: #6b7280; flex-direction: column; gap: 10px; }
        .no-chat-selected i { font-size: 3rem; }
    </style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="main-content">
    <div class="topbar">
        <div class="topbar-title"><i class="bi bi-chat-dots-fill me-2"></i> Chat Interno</div>
        <div class="topbar-widgets">
            <div class="widget-box widget-time"><i class="bi bi-clock-fill me-2"></i> <span id="live-clock">00:00:00</span></div>
            <div class="widget-box widget-date"><i class="bi bi-calendar-event-fill me-2"></i> <span id="live-date">--/--/----</span></div>
            <div class="widget-box widget-weather"><i class="bi bi-sun-fill me-2"></i> <span>17°C</span></div>
            <div class="user-profile shadow-sm">
                <div class="profile-avatar-wrap"><?php if(!empty($_SESSION["imagen"])): ?><img src="../assets/uploads/usuarios/<?php echo $_SESSION["imagen"]; ?>" class="profile-avatar"><?php else: ?><div class="profile-avatar-inicial"><?php echo strtoupper(substr($_SESSION["nombre"],0,1)); ?></div><?php endif; ?></div>
                <div class="profile-info">
                    <div class="profile-name">Hola, <strong><?php echo $_SESSION["nombre"]; ?></strong></div>
                    <div class="profile-role"><?php echo $_SESSION["rol"]; ?></div>
                </div>
            </div>
        </div>
    </div>
    <div class="chat-container">
        <div class="chat-list">
            <div class="chat-list-header">
                <span><i class="bi bi-chat-dots me-2"></i>Conversaciones</span>
                <button class="btn btn-sm btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalNuevoChat"><i class="bi bi-plus-lg"></i></button>
            </div>
            <div class="chat-list-body" id="conversacionesList">
                <div class="text-center text-muted py-4"><i class="bi bi-arrow-clockwise me-1"></i> Cargando...</div>
            </div>
        </div>
        <div class="chat-main" id="chatMain">
            <div class="no-chat-selected">
                <i class="bi bi-chat-dots-fill"></i>
                <span>Selecciona una conversaci&oacute;n</span>
            </div>
        </div>
    </div>
</div>

<!-- Modal Nuevo Chat -->
<div class="modal fade" id="modalNuevoChat" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" style="background:var(--panel-header-bg);color:#fff;">
                <h5 class="modal-title"><i class="bi bi-person-plus me-2"></i>Nueva Conversaci&oacute;n</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Buscar usuario</label>
                    <input type="text" id="buscarUsuario" class="form-control" placeholder="Escribe un nombre...">
                </div>
                <div id="resultadosBusqueda" class="list-group" style="max-height:300px;overflow-y:auto;"></div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancelar</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
var idUsuario = <?php echo $id_usuario; ?>;
var conversacionActiva = null;
var pollingInterval = null;

// Cargar lista de conversaciones
function cargarConversaciones() {
    fetch('index.php?ajax=conversaciones')
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var list = document.getElementById('conversacionesList');
            if(data.length === 0) {
                list.innerHTML = '<div class="text-center text-muted py-4"><i class="bi bi-chat-dots me-2"></i>Sin conversaciones</div>';
                return;
            }
            var html = '';
            data.forEach(function(c) {
                var initials = c.nombre.charAt(0).toUpperCase();
                var activeClass = (conversacionActiva && conversacionActiva == c.id) ? 'active' : '';
                var badgeHtml = c.no_leidos > 0 ? '<div class="badge-unread">' + c.no_leidos + '</div>' : '';
                html += '<div class="chat-list-item ' + activeClass + '" data-id="' + c.id + '" onclick="seleccionarConversacion(' + c.id + ')">';
                if(c.imagen) {
                    html += '<div class="avatar"><img src="../assets/uploads/usuarios/' + c.imagen + '" alt=""></div>';
                } else {
                    html += '<div class="avatar">' + initials + '</div>';
                }
                html += '<div class="info"><div class="name">' + c.nombre + '</div><div class="preview">' + (c.ultimo_mensaje || '') + '</div></div>';
                html += badgeHtml;
                html += '</div>';
            });
            list.innerHTML = html;
        });
}

// Seleccionar conversacion
function seleccionarConversacion(id) {
    conversacionActiva = id;
    // Marcar como leidos
    fetch('index.php?ajax=marcar_leido&id_destinatario=' + id);
    cargarConversaciones();
    cargarMensajes(id);
    if(pollingInterval) clearInterval(pollingInterval);
    pollingInterval = setInterval(function() { cargarMensajes(id, true); }, 5000);
}

// Cargar mensajes
function cargarMensajes(id_dest, silent) {
    fetch('index.php?ajax=mensajes&id_destinatario=' + id_dest)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var main = document.getElementById('chatMain');
            if(data.length === 0) {
                main.innerHTML = '<div class="no-chat-selected"><i class="bi bi-chat-dots-fill"></i><span>Sin mensajes. Env&iacute;a algo.</span></div>';
                return;
            }
            var destName = '';
            var html = '';
            // header
            var listItem = document.querySelector('.chat-list-item[data-id="' + id_dest + '"]');
            if(listItem) {
                destName = listItem.querySelector('.name') ? listItem.querySelector('.name').textContent : 'Usuario';
                var avatarEl = listItem.querySelector('.avatar');
                var avatarHtml = avatarEl ? avatarEl.outerHTML : '<div class="avatar-sm">U</div>';
            } else {
                destName = 'Usuario';
                var avatarHtml = '<div class="avatar-sm">U</div>';
            }
            html += '<div class="chat-main-header">' + avatarHtml + ' ' + destName + '</div>';
            html += '<div class="chat-messages" id="chatMessages">';
            data.forEach(function(m) {
                var cls = m.propio ? 'propio' : 'otro';
                html += '<div class="chat-message ' + cls + '">';
                if(!m.propio) html += '<small class="fw-bold">' + m.nombre_remitente + '</small><br>';
                html += '<div class="msg-text">' + m.mensaje + '</div>';
                html += '<div class="msg-time">' + m.fecha_hora + '</div>';
                html += '</div>';
            });
            html += '</div>';
            html += '<div class="chat-input-area">';
            html += '<input type="text" id="msgInput" class="form-control" placeholder="Escribe un mensaje..." onkeydown="if(event.key===\'Enter\') enviarMensaje()">';
            html += '<button onclick="enviarMensaje()"><i class="bi bi-send-fill"></i></button>';
            html += '</div>';
            main.innerHTML = html;
            // Scroll al fondo
            var msgs = document.getElementById('chatMessages');
            if(msgs) setTimeout(function() { msgs.scrollTop = msgs.scrollHeight; }, 50);
            if(!silent) document.getElementById('msgInput')?.focus();
        });
}

// Enviar mensaje
function enviarMensaje() {
    var input = document.getElementById('msgInput');
    if(!input) return;
    var msg = input.value.trim();
    if(msg === '' || !conversacionActiva) return;
    input.value = '';
    input.focus();
    fetch('index.php', {
        method: 'POST',
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'ajax=enviar&id_destinatario=' + conversacionActiva + '&mensaje=' + encodeURIComponent(msg)
    }).then(function() {
        cargarMensajes(conversacionActiva, true);
        cargarConversaciones();
    });
}

// Buscar usuarios para nuevo chat
document.getElementById('buscarUsuario')?.addEventListener('input', function() {
    var q = this.value.trim();
    var div = document.getElementById('resultadosBusqueda');
    if(q.length < 2) { div.innerHTML = ''; return; }
    fetch('index.php?ajax=buscar_usuarios&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if(data.length === 0) { div.innerHTML = '<div class="list-group-item text-muted">Sin resultados</div>'; return; }
            var html = '';
            data.forEach(function(u) {
                html += '<button type="button" class="list-group-item list-group-item-action" onclick="iniciarChat(' + u.id + ')"><i class="bi bi-person-circle me-2"></i>' + u.nombre + '</button>';
            });
            div.innerHTML = html;
        });
});

function iniciarChat(id) {
    var modal = bootstrap.Modal.getInstance(document.getElementById('modalNuevoChat'));
    if(modal) modal.hide();
    seleccionarConversacion(id);
}

// Inicializar
cargarConversaciones();

function updateClock(){var d=new Date();document.getElementById('live-clock').textContent=d.toLocaleTimeString('es-PE',{hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:false});var day=String(d.getDate()).padStart(2,'0');var months=['Enero','Febrero','Marzo','Abril','Mayo','Junio','Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'];document.getElementById('live-date').textContent=day+' de '+months[d.getMonth()]+' de '+d.getFullYear();}
setInterval(updateClock,1000);updateClock();
(function(){var b=document.createElement('button');b.id='darkModeToggle';b.className='btn btn-sm btn-outline-secondary rounded-circle ms-2';b.style.cssText='width:36px;height:36px;display:flex;align-items:center;justify-content:center;';var s=localStorage.getItem('theme');if(window.aplicarTema){window.aplicarTema(s||'light');}var i=document.createElement('i');i.className=s==='dark'?'bi bi-moon-fill':s==='sepia'?'bi bi-brightness-alt-high-fill':'bi bi-sun-fill';b.appendChild(i);var t=document.querySelector('.topbar-widgets');if(t){var p=t.querySelector('.user-profile');if(p)p.parentNode.insertBefore(b,p);else t.appendChild(b);}
b.addEventListener('click',function(){if(window.ciclarTema){window.ciclarTema();}var c=document.documentElement.getAttribute('data-theme')||'light';this.querySelector('i').className=c==='dark'?'bi bi-moon-fill':c==='sepia'?'bi bi-brightness-alt-high-fill':'bi bi-sun-fill';});})();
document.addEventListener('keydown',function(e){if(e.ctrlKey&&e.key==='s'){var f=document.querySelector('form');if(f&&e.target.closest('form')){e.preventDefault();f.querySelector('[type="submit"]')?.click();}}});
</script>
</body>
</html>
