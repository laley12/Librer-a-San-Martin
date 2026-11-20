library;

/// Entidades de Dominio para el Módulo de Seguridad, Accesos, RBAC y Auditoría.
/// Cero dependencias de Flutter o librerías de infraestructura.

/// Entidad que representa a un Usuario con información de seguridad y accesos.
class UserSecurityEntity {
  final String id;
  final String ci;
  final String nombre;
  final String email;
  final String rol;
  final String sucursal;
  final bool activo;
  final DateTime fechaCreacion;
  final DateTime? ultimoAcceso;

  const UserSecurityEntity({
    required this.id,
    required this.ci,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.sucursal,
    required this.activo,
    required this.fechaCreacion,
    this.ultimoAcceso,
  });

  /// Retorna el CI enmascarado conforme a normas de privacidad (ej. "487****").
  String get ciEnmascarado {
    if (ci.length <= 3) return '***';
    final prefijo = ci.substring(0, 3);
    final asteriscos = '*' * (ci.length - 3);
    return '$prefijo$asteriscos';
  }

  UserSecurityEntity copyWith({
    String? id,
    String? ci,
    String? nombre,
    String? email,
    String? rol,
    String? sucursal,
    bool? activo,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
  }) {
    return UserSecurityEntity(
      id: id ?? this.id,
      ci: ci ?? this.ci,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      rol: rol ?? this.rol,
      sucursal: sucursal ?? this.sucursal,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
    );
  }
}

/// Tipos de dispositivos para geolocalización y monitoreo de sesiones.
enum DeviceType { pc, laptop, tablet, smartphone }

/// Entidad que representa una Sesión JWT activa en el sistema.
class SessionEntity {
  final String jti;
  final String usuarioCi;
  final String usuarioNombre;
  final String ipAddress;
  final String navegador;
  final String dispositivo;
  final DeviceType deviceType;
  final String sistemaOperativo;
  final String ubicacionAproximada;
  final DateTime fechaInicio;
  final DateTime fechaExpiracion;
  final bool activa;

  const SessionEntity({
    required this.jti,
    required this.usuarioCi,
    required this.usuarioNombre,
    required this.ipAddress,
    required this.navegador,
    required this.dispositivo,
    this.deviceType = DeviceType.pc,
    this.sistemaOperativo = 'Windows 11 Pro',
    this.ubicacionAproximada = 'Santa Cruz de la Sierra, Bolivia',
    required this.fechaInicio,
    required this.fechaExpiracion,
    this.activa = true,
  });
}

/// Permisos granulares de un módulo (Lectura, Escritura, Eliminación).
class ModulePermission {
  final String modulo;
  final bool lectura;
  final bool escritura;
  final bool eliminacion;

  const ModulePermission({
    required this.modulo,
    this.lectura = false,
    this.escritura = false,
    this.eliminacion = false,
  });

  ModulePermission copyWith({
    bool? lectura,
    bool? escritura,
    bool? eliminacion,
  }) {
    return ModulePermission(
      modulo: modulo,
      lectura: lectura ?? this.lectura,
      escritura: escritura ?? this.escritura,
      eliminacion: eliminacion ?? this.eliminacion,
    );
  }
}

/// Definición completa de un Rol RBAC para el Submódulo 2.
class RoleDefinitionEntity {
  final String id;
  final String nombre;
  final String descripcion;
  final bool esSuperAdmin;
  final Map<String, ModulePermission> permisos;

  const RoleDefinitionEntity({
    required this.id,
    required this.nombre,
    required this.descripcion,
    this.esSuperAdmin = false,
    required this.permisos,
  });

  RoleDefinitionEntity copyWith({
    String? nombre,
    String? descripcion,
    bool? esSuperAdmin,
    Map<String, ModulePermission>? permisos,
  }) {
    return RoleDefinitionEntity(
      id: id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      esSuperAdmin: esSuperAdmin ?? this.esSuperAdmin,
      permisos: permisos ?? this.permisos,
    );
  }
}

/// Entidad comprensiva para Políticas de Contraseñas, Bloqueo y Concurrencia (Submódulo 3).
class SecurityPoliciesEntity {
  final int minLength;
  final bool requireUppercase;
  final bool requireNumbers;
  final bool requireSymbols;
  final int tiempoDesbloqueoMinutos;
  final int limiteSesionesConcurrentes; // -1 = Ilimitado
  final int historialClaves; // 3, 5, 10
  final int bloqueoIntentosFallidos; // 3, 5, 10

  const SecurityPoliciesEntity({
    this.minLength = 12,
    this.requireUppercase = true,
    this.requireNumbers = true,
    this.requireSymbols = true,
    this.tiempoDesbloqueoMinutos = 30,
    this.limiteSesionesConcurrentes = 2,
    this.historialClaves = 5,
    this.bloqueoIntentosFallidos = 3,
  });

  SecurityPoliciesEntity copyWith({
    int? minLength,
    bool? requireUppercase,
    bool? requireNumbers,
    bool? requireSymbols,
    int? tiempoDesbloqueoMinutos,
    int? limiteSesionesConcurrentes,
    int? historialClaves,
    int? bloqueoIntentosFallidos,
  }) {
    return SecurityPoliciesEntity(
      minLength: minLength ?? this.minLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireNumbers: requireNumbers ?? this.requireNumbers,
      requireSymbols: requireSymbols ?? this.requireSymbols,
      tiempoDesbloqueoMinutos: tiempoDesbloqueoMinutos ?? this.tiempoDesbloqueoMinutos,
      limiteSesionesConcurrentes: limiteSesionesConcurrentes ?? this.limiteSesionesConcurrentes,
      historialClaves: historialClaves ?? this.historialClaves,
      bloqueoIntentosFallidos: bloqueoIntentosFallidos ?? this.bloqueoIntentosFallidos,
    );
  }
}

/// Entidad que representa una fila de permiso en la Matriz RBAC.
class RbacPermissionEntity {
  final String modulo;
  final String permiso;
  final String descripcion;
  final bool adminTi;
  final bool administrador;
  final bool vendedorCajero;
  final bool inventariador;

  const RbacPermissionEntity({
    required this.modulo,
    required this.permiso,
    required this.descripcion,
    required this.adminTi,
    required this.administrador,
    required this.vendedorCajero,
    required this.inventariador,
  });

  RbacPermissionEntity copyWith({
    String? modulo,
    String? permiso,
    String? descripcion,
    bool? adminTi,
    bool? administrador,
    bool? vendedorCajero,
    bool? inventariador,
  }) {
    return RbacPermissionEntity(
      modulo: modulo ?? this.modulo,
      permiso: permiso ?? this.permiso,
      descripcion: descripcion ?? this.descripcion,
      adminTi: adminTi ?? this.adminTi,
      administrador: administrador ?? this.administrador,
      vendedorCajero: vendedorCajero ?? this.vendedorCajero,
      inventariador: inventariador ?? this.inventariador,
    );
  }
}

/// Entidad que representa un registro inmutable en la Bitácora WORM (ISO 27001).
enum WormSeverity { critico, advertencia, info }

class WormAuditLogEntity {
  final String id;
  final DateTime timestamp;
  final String usuario;
  final String modulo;
  final String operacion;
  final WormSeverity severidad;
  final String payloadJsonb;
  final String hashSha256;

  const WormAuditLogEntity({
    required this.id,
    required this.timestamp,
    required this.usuario,
    required this.modulo,
    required this.operacion,
    required this.severidad,
    required this.payloadJsonb,
    required this.hashSha256,
  });
}

/// Entidad que representa un Respaldo Criptográfico del sistema.
class BackupEntity {
  final String id;
  final String nombreArchivo;
  final DateTime fecha;
  final String tipo; // Full, Diferencial, WAL
  final String tamano;
  final String checksumSha256;
  final bool verificado;

  const BackupEntity({
    required this.id,
    required this.nombreArchivo,
    required this.fecha,
    required this.tipo,
    required this.tamano,
    required this.checksumSha256,
    required this.verificado,
  });
}

/// Entidad que encapsula los KPIs principales de Seguridad.
class SecurityKpiEntity {
  final int totalUsuarios;
  final int bloqueos24h;
  final int sesionesJwtActivas;
  final double integridadWormPorcentaje;
  final int pgbouncerConexiones;
  final int pgbouncerMaxConexiones;
  final double cacheHitRatio;
  final int latenciaMs;

  const SecurityKpiEntity({
    required this.totalUsuarios,
    required this.bloqueos24h,
    required this.sesionesJwtActivas,
    required this.integridadWormPorcentaje,
    required this.pgbouncerConexiones,
    required this.pgbouncerMaxConexiones,
    required this.cacheHitRatio,
    required this.latenciaMs,
  });
}

/// Política de contraseñas bajo estándar NIST SP 800-63B.
class NistPasswordPolicy {
  final int minLength;
  final bool requireUppercase;
  final bool requireNumbers;
  final bool requireSymbols;

  const NistPasswordPolicy({
    this.minLength = 12,
    this.requireUppercase = true,
    this.requireNumbers = true,
    this.requireSymbols = true,
  });

  NistPasswordPolicy copyWith({
    int? minLength,
    bool? requireUppercase,
    bool? requireNumbers,
    bool? requireSymbols,
  }) {
    return NistPasswordPolicy(
      minLength: minLength ?? this.minLength,
      requireUppercase: requireUppercase ?? this.requireUppercase,
      requireNumbers: requireNumbers ?? this.requireNumbers,
      requireSymbols: requireSymbols ?? this.requireSymbols,
    );
  }
}
