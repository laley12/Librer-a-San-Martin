import '../../domain/entities/security_entities.dart';

/// DTO para Usuario de Seguridad con soporte de serialización.
class UserSecurityModel extends UserSecurityEntity {
  const UserSecurityModel({
    required super.id,
    required super.ci,
    required super.nombre,
    required super.email,
    required super.rol,
    required super.sucursal,
    required super.activo,
    required super.fechaCreacion,
    super.ultimoAcceso,
  });

  factory UserSecurityModel.fromJson(Map<String, dynamic> json) {
    return UserSecurityModel(
      id: json['id'] as String,
      ci: json['ci'] as String,
      nombre: json['nombre'] as String,
      email: json['email'] as String,
      rol: json['rol'] as String,
      sucursal: json['sucursal'] as String,
      activo: json['activo'] as bool? ?? true,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      ultimoAcceso: json['ultimo_acceso'] != null
          ? DateTime.parse(json['ultimo_acceso'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ci': ci,
      'nombre': nombre,
      'email': email,
      'rol': rol,
      'sucursal': sucursal,
      'activo': activo,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'ultimo_acceso': ultimoAcceso?.toIso8601String(),
    };
  }
}

/// DTO para Sesión JWT con geolocalización y tipo de dispositivo.
class SessionModel extends SessionEntity {
  const SessionModel({
    required super.jti,
    required super.usuarioCi,
    required super.usuarioNombre,
    required super.ipAddress,
    required super.navegador,
    required super.dispositivo,
    super.deviceType = DeviceType.pc,
    super.sistemaOperativo = 'Windows 11 Pro',
    super.ubicacionAproximada = 'Santa Cruz de la Sierra, Bolivia',
    required super.fechaInicio,
    required super.fechaExpiracion,
    super.activa,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      jti: json['jti'] as String,
      usuarioCi: json['usuario_ci'] as String,
      usuarioNombre: json['usuario_nombre'] as String,
      ipAddress: json['ip_address'] as String,
      navegador: json['navegador'] as String,
      dispositivo: json['dispositivo'] as String,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaExpiracion: DateTime.parse(json['fecha_expiracion'] as String),
      activa: json['activa'] as bool? ?? true,
    );
  }
}

/// DTO para Log de Bitácora WORM.
class WormAuditLogModel extends WormAuditLogEntity {
  const WormAuditLogModel({
    required super.id,
    required super.timestamp,
    required super.usuario,
    required super.modulo,
    required super.operacion,
    required super.severidad,
    required super.payloadJsonb,
    required super.hashSha256,
  });

  factory WormAuditLogModel.fromJson(Map<String, dynamic> json) {
    return WormAuditLogModel(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      usuario: json['usuario'] as String,
      modulo: json['modulo'] as String,
      operacion: json['operacion'] as String,
      severidad: WormSeverity.values.firstWhere(
        (e) => e.name == json['severidad'],
        orElse: () => WormSeverity.info,
      ),
      payloadJsonb: json['payload_jsonb'] as String,
      hashSha256: json['hash_sha256'] as String,
    );
  }
}

/// DTO para Respaldo Criptográfico.
class BackupModel extends BackupEntity {
  const BackupModel({
    required super.id,
    required super.nombreArchivo,
    required super.fecha,
    required super.tipo,
    required super.tamano,
    required super.checksumSha256,
    required super.verificado,
  });

  factory BackupModel.fromJson(Map<String, dynamic> json) {
    return BackupModel(
      id: json['id'] as String,
      nombreArchivo: json['nombre_archivo'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      tipo: json['tipo'] as String,
      tamano: json['tamano'] as String,
      checksumSha256: json['checksum_sha256'] as String,
      verificado: json['verificado'] as bool? ?? true,
    );
  }
}
