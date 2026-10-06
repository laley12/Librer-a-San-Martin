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
        echo "OK";
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
        SELECT m.*, u.nombre as nombre_remitente, u.imagen as img_remitente
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

// AJAX: Obtener todos los usuarios con datos de chat
if(isset($_GET['ajax']) && $_GET['ajax'] === 'usuarios') {
    $search = isset($_GET['q']) ? mysqli_real_escape_string($conexion, trim($_GET['q'])) : '';
    $where = "u.id != $id_usuario AND u.estado='Activo'";
    if($search !== '') {
        $where .= " AND u.nombre LIKE '%$search%'";
    }
    $conv = mysqli_query($conexion, "
        SELECT u.id, u.nombre, u.imagen, u.rol,
            (SELECT m.mensaje FROM mensajes_chat m WHERE (m.id_remitente=u.id AND m.id_destinatario=$id_usuario) OR (m.id_remitente=$id_usuario AND m.id_destinatario=u.id) ORDER BY m.fecha_hora DESC LIMIT 1) as ultimo_mensaje,
            (SELECT MAX(m.fecha_hora) FROM mensajes_chat m WHERE (m.id_remitente=u.id AND m.id_destinatario=$id_usuario) OR (m.id_remitente=$id_usuario AND m.id_destinatario=u.id)) as ultima_fecha,
            (SELECT COUNT(*) FROM mensajes_chat WHERE id_remitente=u.id AND id_destinatario=$id_usuario AND leido=0) as no_leidos
        FROM usuarios u
        WHERE $where
        ORDER BY ultima_fecha DESC, u.nombre ASC
    ");
    $output = [];
    while($c = mysqli_fetch_assoc($conv)) {
        $output[] = [
            'id' => $c['id'],
            'nombre' => $c['nombre'],
            'imagen' => $c['imagen'],
            'rol' => $c['rol'],
            'ultimo_mensaje' => htmlspecialchars(substr($c['ultimo_mensaje'] ?? '', 0, 80)),
            'ultima_fecha' => $c['ultima_fecha'],
            'no_leidos' => intval($c['no_leidos'])
        ];
    }
    header('Content-Type: application/json');
    echo json_encode($output);
    exit();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
    <title>Chat Interno - Librería San Martín</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="/includes/base.css">
    <style>
:root{--body-bg:#efeae2;--sidebar-bg:#fff;--sidebar-text:#1e293b;--sidebar-hover-bg:#e2e8f0;--sidebar-accent:#1e3c72;--sidebar-active-bg:linear-gradient(90deg,rgba(30,60,114,0.12),rgba(42,82,152,0.05));--sidebar-brand-bg:linear-gradient(135deg,#1e3c72,#2a5298);--topbar-bg:rgba(255,255,255,0.85);--panel-bg:#fff;--panel-header-bg:linear-gradient(135deg,#075e54,#128c7e);--profile-bg:#f1f5f9;--profile-text:#333;--sub-item-active-bg:#eef2ff;--scrollbar-thumb:rgba(0,0,0,0.12);--scrollbar-thumb-hover:rgba(0,0,0,0.25);--collapse-line:#cbd5e1;--collapse-dash:#94a3b8;--border-color:rgba(0,0,0,0.05);--form-bg:#fff;--form-text:#1e293b;--form-border:#d1d5db;--form-focus-border:#60a5fa;--input-group-bg:#f1f5f9;--chat-fondo:#efeae2;--chat-propio:#d9fdd3;--chat-otro:#fff;--chat-header:#075e54;--user-list-header:#f0f2f5;}
[data-theme="dark"]{--body-bg:#111b21;--sidebar-bg:#1e293b;--sidebar-text:#cbd5e1;--sidebar-hover-bg:#334155;--sidebar-accent:#60a5fa;--sidebar-active-bg:linear-gradient(90deg,rgba(59,130,246,0.15),rgba(37,99,235,0.08));--sidebar-brand-bg:linear-gradient(135deg,#0f172a,#1e293b);--topbar-bg:rgba(30,41,59,0.95);--panel-bg:#1e293b;--panel-header-bg:linear-gradient(135deg,#0b3a33,#0f4f45);--profile-bg:#334155;--profile-text:#e2e8f0;--scrollbar-thumb:rgba(255,255,255,0.15);--scrollbar-thumb-hover:rgba(255,255,255,0.25);--collapse-line:#475569;--collapse-dash:#64748b;--border-color:rgba(255,255,255,0.06);--form-bg:#1e293b;--form-text:#f1f5f9;--form-border:#334155;--form-focus-border:#60a5fa;--input-group-bg:#0f172a;--chat-fondo:#0b141a;--chat-propio:#005c4b;--chat-otro:#202c33;--chat-header:#0b3a33;--user-list-header:#1e293b;}
body{background:var(--body-bg);font-family:'Segoe UI',sans-serif;margin:0;overflow:hidden;height:100vh;}
.app-wrapper{display:flex;height:100vh;overflow:hidden;}
.sidebar.collapsed .sidebar-menu a{padding:12px 10px;justify-content:center;margin-bottom:8px;}
.sidebar.collapsed ~ .chat-app{margin-left:70px;}
[data-theme="dark"] .form-control:focus{background-color:var(--form-bg);color:var(--form-text);border-color:var(--form-focus-border);box-shadow:0 0 0 0.25rem rgba(59,130,246,0.25);}
[data-theme="dark"] .input-group-text{background-color:var(--input-group-bg) !important;}
/* Chat App Layout */
        .chat-app{margin-left:260px;display:flex;height:100vh;overflow:hidden;transition:all 0.3s ease;}
.chat-sidebar{width:380px;min-width:380px;background:var(--panel-bg);display:flex;flex-direction:column;border-right:1px solid var(--border-color);}
.chat-sidebar-header{background:var(--chat-header);color:#fff;padding:14px 18px;display:flex;justify-content:space-between;align-items:center;flex-shrink:0;}
.chat-sidebar-header h6{margin:0;font-size:1rem;font-weight:600;}
.chat-sidebar-header .btn-chat-new{width:36px;height:36px;border-radius:50%;border:none;background:rgba(255,255,255,0.2);color:#fff;display:flex;align-items:center;justify-content:center;font-size:1.1rem;cursor:pointer;transition:background 0.2s;}
.chat-sidebar-header .btn-chat-new:hover{background:rgba(255,255,255,0.3);}
.chat-search{padding:8px 12px;background:var(--user-list-header);flex-shrink:0;}
.chat-search input{width:100%;border:none;border-radius:8px;padding:8px 14px;font-size:0.9rem;background:var(--panel-bg);color:var(--sidebar-text);outline:none;border:1px solid transparent;}
.chat-search input:focus{border-color:var(--sidebar-accent);}
.chat-user-list{flex:1;overflow-y:auto;}
.chat-user-item{display:flex;align-items:center;padding:12px 16px;cursor:pointer;transition:background 0.15s;gap:14px;border-bottom:1px solid var(--border-color);}
.chat-user-item:hover{background:var(--sidebar-hover-bg);}
.chat-user-item.active{background:var(--sidebar-hover-bg);}
.chat-user-item .avatar-wrap{width:48px;height:48px;border-radius:50%;flex-shrink:0;overflow:hidden;position:relative;}
.chat-user-item .avatar-wrap img{width:100%;height:100%;object-fit:cover;border-radius:50%;}
.chat-user-item .avatar-initial{width:48px;height:48px;border-radius:50%;background:linear-gradient(135deg,#075e54,#128c7e);color:#fff;display:flex;align-items:center;justify-content:center;font-size:1.1rem;font-weight:700;flex-shrink:0;}
[data-theme="dark"] .chat-user-item .avatar-initial{background:linear-gradient(135deg,#0b3a33,#0f4f45);}
.chat-user-item .user-info{flex:1;min-width:0;}
.chat-user-item .user-info .user-name{font-weight:600;font-size:0.92rem;color:var(--sidebar-text);display:flex;align-items:center;justify-content:space-between;}
.chat-user-item .user-info .user-name .user-role{font-weight:400;font-size:0.72rem;color:#6b7280;text-transform:uppercase;letter-spacing:0.3px;}
.chat-user-item .user-info .user-preview{font-size:0.82rem;color:#6b7280;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px;}
.chat-user-item .badge-unread{background:#25d366;color:#fff;border-radius:50%;min-width:20px;height:20px;font-size:0.7rem;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;padding:0 4px;}
.chat-user-item .msg-time-small{font-size:0.7rem;color:#6b7280;flex-shrink:0;}
/* Chat Content */
        .chat-content{flex:1;display:flex;flex-direction:column;background:var(--chat-fondo);background-image:var(--chat-bg-pattern);}
.chat-content-header{background:var(--chat-header);color:#fff;padding:10px 18px;display:flex;align-items:center;gap:14px;flex-shrink:0;min-height:56px;box-shadow:0 1px 3px rgba(0,0,0,0.08);}
.chat-content-header .back-btn{display:none;width:36px;height:36px;border-radius:50%;border:none;background:rgba(255,255,255,0.15);color:#fff;align-items:center;justify-content:center;font-size:1.2rem;cursor:pointer;}
.chat-content-header .avatar-sm{width:38px;height:38px;border-radius:50%;overflow:hidden;flex-shrink:0;}
.chat-content-header .avatar-sm img{width:100%;height:100%;object-fit:cover;}
.chat-content-header .avatar-sm-initial{width:38px;height:38px;border-radius:50%;background:rgba(255,255,255,0.2);color:#fff;display:flex;align-items:center;justify-content:center;font-size:0.95rem;font-weight:700;flex-shrink:0;}
.chat-content-header .header-info{flex:1;min-width:0;}
.chat-content-header .header-info .header-name{font-weight:600;font-size:0.95rem;}
.chat-content-header .header-info .header-role{font-size:0.72rem;opacity:0.8;}
/* Messages area */
        .chat-messages{flex:1;overflow-y:auto;padding:20px 40px;display:flex;flex-direction:column;gap:4px;}
.chat-messages .msg-row{display:flex;margin-bottom:4px;}
.chat-messages .msg-row.propio{justify-content:flex-end;}
.chat-messages .msg-row.otro{justify-content:flex-start;}
.chat-messages .bubble{max-width:65%;padding:7px 10px 7px 12px;border-radius:8px;position:relative;word-wrap:break-word;box-shadow:0 1px 1px rgba(0,0,0,0.05);}
.chat-messages .bubble.propio{background:var(--chat-propio);border-top-right-radius:0;}
.chat-messages .bubble.otro{background:var(--chat-otro);border-top-left-radius:0;}
.chat-messages .bubble .msg-text{font-size:0.92rem;color:var(--sidebar-text);line-height:1.4;}
[data-theme="dark"] .chat-messages .bubble.propio .msg-text{color:#e9edef;}
[data-theme="dark"] .chat-messages .bubble.otro .msg-text{color:#e9edef;}
.chat-messages .bubble .msg-time{font-size:0.65rem;color:#6b7280;text-align:right;margin-top:2px;padding-left:30px;}
.chat-messages .date-separator{text-align:center;margin:8px 0;}
.chat-messages .date-separator span{background:rgba(225,245,254,0.92);color:#54656f;padding:4px 14px;border-radius:8px;font-size:0.75rem;font-weight:500;}
[data-theme="dark"] .chat-messages .date-separator span{background:#182229;color:#8696a0;}
/* Input area */
        .chat-input-area{background:var(--user-list-header);padding:8px 18px;display:flex;align-items:center;gap:10px;flex-shrink:0;}
.chat-input-area input{flex:1;border:none;border-radius:8px;padding:10px 16px;font-size:0.92rem;background:var(--panel-bg);color:var(--sidebar-text);outline:none;}
.chat-input-area .btn-send{width:44px;height:44px;border-radius:50%;border:none;background:var(--chat-header);color:#fff;display:flex;align-items:center;justify-content:center;font-size:1.2rem;cursor:pointer;transition:opacity 0.2s;flex-shrink:0;}
.chat-input-area .btn-send:hover{opacity:0.9;}
.chat-input-area .btn-send:disabled{opacity:0.4;cursor:default;}
/* Empty state */
        .chat-empty{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;color:#6b7280;gap:8px;}
.chat-empty i{font-size:4rem;opacity:0.3;}
.chat-empty span{font-size:1rem;}
@media(max-width:992px){
            .chat-sidebar{width:100%;min-width:100%;}
            .chat-content{position:fixed;top:0;left:0;right:0;bottom:0;z-index:1050;display:none;}
            .chat-content.show{display:flex;}
            .chat-content-header .back-btn{display:flex;}
        }
    </style>
</head>
<body>
<?php $base_path = '../'; include '../includes/sidebar.php'; ?>
<div class="chat-app">
    <!-- User list (left panel) -->
    <div class="chat-sidebar" id="chatSidebar">
        <div class="chat-sidebar-header">
            <h6><i class="bi bi-chat-dots-fill me-2"></i>Chat</h6>
            <button class="btn-chat-new" data-bs-toggle="modal" data-bs-target="#modalNuevoChat" title="Nueva conversaci&oacute;n"><i class="bi bi-pencil-fill"></i></button>
        </div>
        <div class="chat-search">
            <input type="text" id="searchUser" placeholder="Buscar o iniciar chat..." autocomplete="off">
        </div>
        <div class="chat-user-list" id="userList">
            <div class="text-center text-muted py-4"><div class="spinner-border spinner-border-sm me-2" role="status"></div>Cargando...</div>
        </div>
    </div>

    <!-- Chat content (right panel) -->
    <div class="chat-content" id="chatContent">
        <div class="chat-empty">
            <i class="bi bi-chat-dots-fill"></i>
            <span>Selecciona un usuario para chatear</span>
        </div>
    </div>
</div>

<!-- Modal Nuevo Chat -->
<div class="modal fade" id="modalNuevoChat" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header" style="background:var(--chat-header);color:#fff;">
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
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
var idUsuario = <?php echo $id_usuario; ?>;
var conversacionActiva = null;
var pollingInterval = null;
var usuarioCache = {};

// Cargar lista de usuarios
function cargarUsuarios(search) {
    var url = 'index.php?ajax=usuarios';
    if(search) url += '&q=' + encodeURIComponent(search);
    fetch(url)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var list = document.getElementById('userList');
            if(data.length === 0) {
                list.innerHTML = '<div class="text-center text-muted py-4"><i class="bi bi-people me-2"></i>Sin usuarios</div>';
                return;
            }
            var html = '';
            data.forEach(function(u) {
                usuarioCache[u.id] = u;
                var initials = u.nombre.charAt(0).toUpperCase();
                var activeClass = (conversacionActiva && conversacionActiva == u.id) ? 'active' : '';
                var badgeHtml = u.no_leidos > 0 ? '<div class="badge-unread">' + u.no_leidos + '</div>' : '';
                var timeHtml = u.ultima_fecha ? '<div class="msg-time-small">' + formatTime(u.ultima_fecha) + '</div>' : '';
                var previewHtml = u.ultimo_mensaje ? '<div class="user-preview">' + u.ultimo_mensaje + '</div>' : '<div class="user-preview" style="font-style:italic;opacity:0.5;">Sin mensajes</div>';
                html += '<div class="chat-user-item ' + activeClass + '" data-id="' + u.id + '" onclick="seleccionarUsuario(' + u.id + ')">';
                if(u.imagen) {
                    html += '<div class="avatar-wrap"><img src="../assets/uploads/usuarios/' + u.imagen + '" alt=""></div>';
                } else {
                    html += '<div class="avatar-initial">' + initials + '</div>';
                }
                html += '<div class="user-info">';
                html += '<div class="user-name">' + u.nombre + ' <span class="user-role">' + (u.rol || '') + '</span></div>';
                html += previewHtml;
                html += '</div>';
                html += timeHtml;
                html += badgeHtml;
                html += '</div>';
            });
            list.innerHTML = html;
        });
}

// Search input
document.getElementById('searchUser').addEventListener('input', function() {
    var q = this.value.trim();
    cargarUsuarios(q);
});

// Seleccionar usuario
function seleccionarUsuario(id) {
    conversacionActiva = id;
    // Mark as read
    fetch('index.php?ajax=marcar_leido&id_destinatario=' + id);
    cargarUsuarios(document.getElementById('searchUser').value.trim());
    cargarConversacion(id);
    if(pollingInterval) clearInterval(pollingInterval);
    pollingInterval = setInterval(function() { cargarMensajes(id, true); }, 3000);
    // Mobile: show chat content
    document.getElementById('chatContent').classList.add('show');
}

function volverLista() {
    document.getElementById('chatContent').classList.remove('show');
    if(pollingInterval) clearInterval(pollingInterval);
}

// Cargar conversacion (header + messages + input)
function cargarConversacion(id) {
    var u = usuarioCache[id] || {};
    var initials = (u.nombre || 'U').charAt(0).toUpperCase();
    var avatarHtml = u.imagen
        ? '<div class="avatar-sm"><img src="../assets/uploads/usuarios/' + u.imagen + '" alt=""></div>'
        : '<div class="avatar-sm-initial">' + initials + '</div>';
    var headerHtml = '<button class="back-btn" onclick="volverLista()"><i class="bi bi-arrow-left"></i></button>'
        + avatarHtml
        + '<div class="header-info"><div class="header-name">' + (u.nombre || 'Usuario') + '</div><div class="header-role">' + (u.rol || '') + '</div></div>';

    var content = document.getElementById('chatContent');
    content.innerHTML = '<div class="chat-content-header">' + headerHtml + '</div>'
        + '<div class="chat-messages" id="chatMessages"></div>'
        + '<div class="chat-input-area">'
        + '<input type="text" id="msgInput" placeholder="Escribe un mensaje..." autocomplete="off">'
        + '<button class="btn-send" id="btnSend" onclick="enviarMensaje()"><i class="bi bi-send-fill"></i></button>'
        + '</div>';

    document.getElementById('msgInput').addEventListener('keydown', function(e) {
        if(e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            enviarMensaje();
        }
    });

    cargarMensajes(id, false);
}

// Cargar mensajes
function cargarMensajes(id_dest, silent) {
    fetch('index.php?ajax=mensajes&id_destinatario=' + id_dest)
        .then(function(r) { return r.json(); })
        .then(function(data) {
            var container = document.getElementById('chatMessages');
            if(!container) return;
            if(data.length === 0) {
                container.innerHTML = '<div class="text-center text-muted py-4"><i class="bi bi-chat-dots me-2"></i>Env&iacute;a el primer mensaje</div>';
                return;
            }
            var html = '';
            var lastDate = '';
            data.forEach(function(m) {
                var cls = m.propio ? 'propio' : 'otro';
                var msgDate = m.fecha_hora ? m.fecha_hora.substring(0,10) : '';
                if(msgDate && msgDate !== lastDate) {
                    lastDate = msgDate;
                    html += '<div class="date-separator"><span>' + formatDate(msgDate) + '</span></div>';
                }
                var timeStr = m.fecha_hora ? m.fecha_hora.substring(11,16) : '';
                html += '<div class="msg-row ' + cls + '">';
                html += '<div class="bubble ' + cls + '">';
                html += '<div class="msg-text">' + m.mensaje + '</div>';
                html += '<div class="msg-time">' + timeStr + '</div>';
                html += '</div></div>';
            });
            container.innerHTML = html;
            container.scrollTop = container.scrollHeight;
            if(!silent) setTimeout(function() { document.getElementById('msgInput')?.focus(); }, 100);
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
        cargarUsuarios(document.getElementById('searchUser').value.trim());
    });
}

// Format helpers
function formatTime(dateStr) {
    if(!dateStr) return '';
    var d = new Date(dateStr.replace(' ', 'T'));
    if(isNaN(d)) return dateStr.substring(11,16);
    var now = new Date();
    var isToday = d.toDateString() === now.toDateString();
    if(isToday) return d.getHours().toString().padStart(2,'0') + ':' + d.getMinutes().toString().padStart(2,'0');
    return d.getDate().toString().padStart(2,'0') + '/' + (d.getMonth()+1).toString().padStart(2,'0');
}

function formatDate(dateStr) {
    if(!dateStr) return '';
    var d = new Date(dateStr + 'T12:00:00');
    if(isNaN(d)) return dateStr;
    var now = new Date();
    var isToday = d.toDateString() === now.toDateString();
    if(isToday) return 'Hoy';
    var yesterday = new Date(now); yesterday.setDate(yesterday.getDate()-1);
    if(d.toDateString() === yesterday.toDateString()) return 'Ayer';
    var months = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];
    return d.getDate() + ' de ' + months[d.getMonth()];
}

// Buscar usuarios para nuevo chat
function iniciarNuevoChat(id, nombre) {
    var modal = bootstrap.Modal.getInstance(document.getElementById('modalNuevoChat'));
    if(modal) modal.hide();
    document.getElementById('searchUser').value = nombre;
    seleccionarUsuario(id);
}

document.getElementById('buscarUsuario')?.addEventListener('input', function() {
    var q = this.value.trim();
    var div = document.getElementById('resultadosBusqueda');
    if(q.length < 2) { div.innerHTML = ''; return; }
    fetch('index.php?ajax=usuarios&q=' + encodeURIComponent(q))
        .then(function(r) { return r.json(); })
        .then(function(data) {
            if(data.length === 0) { div.innerHTML = '<div class="list-group-item text-muted">Sin resultados</div>'; return; }
            var html = '';
            data.forEach(function(u) {
                var initials = u.nombre.charAt(0).toUpperCase();
                html += '<button type="button" class="list-group-item list-group-item-action d-flex align-items-center gap-2" onclick="iniciarNuevoChat(' + u.id + ',\'' + u.nombre.replace(/'/g,"\\'") + '\')">';
                if(u.imagen) html += '<img src="../assets/uploads/usuarios/' + u.imagen + '" style="width:32px;height:32px;border-radius:50%;object-fit:cover;">';
                else html += '<div style="width:32px;height:32px;border-radius:50%;background:var(--chat-header);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:0.8rem;">' + initials + '</div>';
                html += '<span>' + u.nombre + ' <small class="text-muted">' + (u.rol || '') + '</small></span>';
                html += '</button>';
            });
            div.innerHTML = html;
        });
});

// Init
cargarUsuarios();

// Theme + clock
(function() {
    var saved = localStorage.getItem('theme');
    if(window.aplicarTema) window.aplicarTema(saved || 'light');
})();
</script>
</body>
</html>
