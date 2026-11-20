import '../../domain/entities/security_entities.dart';
import '../models/security_models.dart';

abstract interface class SecurityRemoteDataSource {
  Future<SecurityKpiEntity> getSecurityKpis();
  Future<List<SessionModel>> getActiveSessions();
  Future<void> revokeSession(String jti);
  Future<List<UserSecurityModel>> getUsers({String? query, String? rol});
  Future<UserSecurityModel> createUser({
    required String ci,
    required String nombre,
    required String email,
    required String rol,
    required String sucursal,
    required String password,
  });
  Future<UserSecurityModel> toggleUserStatus(String userId, bool active);
  Future<void> softDeleteUser(String userId);
  Future<List<RbacPermissionEntity>> getRbacMatrix();
  Future<void> updateRbacPermission(RbacPermissionEntity permission);
  Future<List<WormAuditLogModel>> getWormLogs({String? modulo, WormSeverity? severidad});
  Future<List<BackupModel>> getBackups();
  Future<BackupModel> triggerManualBackup();
}

/// Implementación local/mock rica en datos reales para la Librería San Martín.
class MockSecurityRemoteDataSourceImpl implements SecurityRemoteDataSource {
  final Duration delay;

  MockSecurityRemoteDataSourceImpl({this.delay = Duration.zero});

  Future<void> _wait() async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
  }

  final List<UserSecurityModel> _users = [
    UserSecurityModel(
      id: 'usr_00',
      ci: '4625505',
      nombre: 'Ing. Harold Eastman Romay',
      email: 'eastmanharold@gmail.com',
      rol: 'Superadmin',
      sucursal: 'Casa Matriz - La Guardia',
      activo: true,
      fechaCreacion: DateTime(2025, 1, 1),
      ultimoAcceso: DateTime.now(),
    ),
    UserSecurityModel(
      id: 'usr_01',
      ci: '4872910',
      nombre: 'Lic. Gustavo Guachalla',
      email: 'gguachalla@sanmartin.bo',
      rol: 'Admin TI',
      sucursal: 'Sede Central Santa Cruz',
      activo: true,
      fechaCreacion: DateTime(2025, 1, 10),
      ultimoAcceso: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
    UserSecurityModel(
      id: 'usr_02',
      ci: '3928174',
      nombre: 'Carlos Mario Mendoza',
      email: 'cmendoza@sanmartin.bo',
      rol: 'Administrador',
      sucursal: 'Sede Central Santa Cruz',
      activo: true,
      fechaCreacion: DateTime(2025, 2, 1),
      ultimoAcceso: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    UserSecurityModel(
      id: 'usr_03',
      ci: '5829103',
      nombre: 'Valeria Rivas Soliz',
      email: 'vrivas@sanmartin.bo',
      rol: 'Vendedor/Cajero',
      sucursal: 'Sede Central Santa Cruz',
      activo: true,
      fechaCreacion: DateTime(2025, 2, 15),
      ultimoAcceso: DateTime.now().subtract(const Duration(minutes: 20)),
    ),
    UserSecurityModel(
      id: 'usr_04',
      ci: '7482915',
      nombre: 'Fernando Loayza Paz',
      email: 'floayza@sanmartin.bo',
      rol: 'Vendedor/Cajero',
      sucursal: 'Agencia La Guardia',
      activo: true,
      fechaCreacion: DateTime(2025, 3, 1),
      ultimoAcceso: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    UserSecurityModel(
      id: 'usr_05',
      ci: '6192840',
      nombre: 'Mariana Suarez Justiniano',
      email: 'msuarez@sanmartin.bo',
      rol: 'Inventariador',
      sucursal: 'Sede Central Santa Cruz',
      activo: true,
      fechaCreacion: DateTime(2025, 3, 10),
      ultimoAcceso: DateTime.now().subtract(const Duration(minutes: 45)),
    ),
    UserSecurityModel(
      id: 'usr_06',
      ci: '8294012',
      nombre: 'Jorge Alberto Vaca',
      email: 'jvaca@sanmartin.bo',
      rol: 'Inventariador',
      sucursal: 'Agencia La Guardia',
      activo: true,
      fechaCreacion: DateTime(2025, 4, 1),
      ultimoAcceso: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserSecurityModel(
      id: 'usr_07',
      ci: '9182736',
      nombre: 'Ana Belén Terrazas',
      email: 'aterrazas@sanmartin.bo',
      rol: 'Vendedor/Cajero',
      sucursal: 'Agencia La Guardia',
      activo: true,
      fechaCreacion: DateTime(2025, 4, 15),
      ultimoAcceso: DateTime.now().subtract(const Duration(days: 1)),
    ),
    UserSecurityModel(
      id: 'usr_08',
      ci: '3482910',
      nombre: 'Roberto Carlos Pinto',
      email: 'rpinto@sanmartin.bo',
      rol: 'Administrador',
      sucursal: 'Agencia La Guardia',
      activo: true,
      fechaCreacion: DateTime(2025, 5, 2),
      ultimoAcceso: DateTime.now().subtract(const Duration(days: 2)),
    ),
    UserSecurityModel(
      id: 'usr_09',
      ci: '4928173',
      nombre: 'Daniela Flores Mamani',
      email: 'dflores@sanmartin.bo',
      rol: 'Vendedor/Cajero',
      sucursal: 'Sede Central Santa Cruz',
      activo: false, // Suspendido
      fechaCreacion: DateTime(2025, 5, 10),
      ultimoAcceso: DateTime.now().subtract(const Duration(days: 15)),
    ),
    UserSecurityModel(
      id: 'usr_10',
      ci: '7392816',
      nombre: 'Ernesto Morales Roca',
      email: 'emorales@sanmartin.bo',
      rol: 'Inventariador',
      sucursal: 'Sede Central Santa Cruz',
      activo: true,
      fechaCreacion: DateTime(2025, 6, 1),
      ultimoAcceso: DateTime.now().subtract(const Duration(days: 3)),
    ),
    UserSecurityModel(
      id: 'usr_11',
      ci: '5192847',
      nombre: 'Gabriela Ortiz Saucedo',
      email: 'gortiz@sanmartin.bo',
      rol: 'Vendedor/Cajero',
      sucursal: 'Sede Central Santa Cruz',
      activo: true,
      fechaCreacion: DateTime(2025, 6, 12),
      ultimoAcceso: DateTime.now().subtract(const Duration(hours: 6)),
    ),
  ];

  final List<SessionModel> _sessions = [
    SessionModel(
      jti: 'jti_eastman_superadmin_01',
      usuarioCi: '4625505',
      usuarioNombre: 'Ing. Harold Eastman Romay',
      ipAddress: '190.181.45.12',
      navegador: 'Chrome 125 (Win64)',
      dispositivo: 'Laptop Gerencia / Dirección',
      deviceType: DeviceType.laptop,
      sistemaOperativo: 'Windows 11 Pro 64-bit',
      ubicacionAproximada: 'Santa Cruz de la Sierra (Equipetrol)',
      fechaInicio: DateTime.now().subtract(const Duration(minutes: 25)),
      fechaExpiracion: DateTime.now().add(const Duration(hours: 7, minutes: 35)),
      activa: true,
    ),
    SessionModel(
      jti: 'jti_9a8f7c6e-5d4b-3a21',
      usuarioCi: '4872910',
      usuarioNombre: 'Lic. Gustavo Guachalla',
      ipAddress: '192.168.1.105',
      navegador: 'Chrome 124 (Win64)',
      dispositivo: 'PC Administración Principal',
      deviceType: DeviceType.pc,
      sistemaOperativo: 'Windows 11 Enterprise',
      ubicacionAproximada: 'Casa Matriz - La Guardia',
      fechaInicio: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
      fechaExpiracion: DateTime.now().add(const Duration(hours: 5, minutes: 45)),
      activa: true,
    ),
    SessionModel(
      jti: 'jti_4b3a219f-8c7e-6d5a',
      usuarioCi: '5829103',
      usuarioNombre: 'Valeria Rivas Soliz',
      ipAddress: '192.168.1.112',
      navegador: 'Firefox 125 (Linux)',
      dispositivo: 'Terminal POS 01 - Caja',
      deviceType: DeviceType.pc,
      sistemaOperativo: 'Ubuntu 24.04 LTS (POS)',
      ubicacionAproximada: 'Sede Central Santa Cruz',
      fechaInicio: DateTime.now().subtract(const Duration(hours: 4)),
      fechaExpiracion: DateTime.now().add(const Duration(hours: 4)),
      activa: true,
    ),
    SessionModel(
      jti: 'jti_1f2e3d4c-5b6a-7890',
      usuarioCi: '6192840',
      usuarioNombre: 'Mariana Suarez Justiniano',
      ipAddress: '192.168.1.140',
      navegador: 'Chrome Mobile 124',
      dispositivo: 'Tablet Kárdex / Depósito',
      deviceType: DeviceType.tablet,
      sistemaOperativo: 'Android 14 (Samsung Tab)',
      ubicacionAproximada: 'Bodega Central Santa Cruz',
      fechaInicio: DateTime.now().subtract(const Duration(minutes: 50)),
      fechaExpiracion: DateTime.now().add(const Duration(hours: 7, minutes: 10)),
      activa: true,
    ),
    SessionModel(
      jti: 'jti_7e8f9a0b-1c2d-3e4f',
      usuarioCi: '7482915',
      usuarioNombre: 'Fernando Loayza Paz',
      ipAddress: '10.0.4.15',
      navegador: 'Safari Mobile 17',
      dispositivo: 'Smartphone Supervisión Móvil',
      deviceType: DeviceType.smartphone,
      sistemaOperativo: 'iOS 17.5 (iPhone 15)',
      ubicacionAproximada: 'Agencia La Guardia',
      fechaInicio: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
      fechaExpiracion: DateTime.now().add(const Duration(hours: 6, minutes: 30)),
      activa: true,
    ),
  ];

  final List<RbacPermissionEntity> _rbacMatrix = [
    const RbacPermissionEntity(
      modulo: 'Seguridad y Accesos',
      permiso: 'Gestión de Usuarios y Claves',
      descripcion: 'Alta, baja y reseteo de credenciales de usuario.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Seguridad y Accesos',
      permiso: 'Configuración RBAC y Políticas NIST',
      descripcion: 'Modificación de privilegios y directrices de seguridad.',
      adminTi: true,
      administrador: false,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Seguridad y Accesos',
      permiso: 'Auditoría Bitácora WORM Forense',
      descripcion: 'Inspección de logs inmutables y exportación forense.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Seguridad y Accesos',
      permiso: 'Respaldos Criptográficos Base de Datos',
      descripcion: 'Disparo de backups manuales y verificación SHA-256.',
      adminTi: true,
      administrador: false,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Administración',
      permiso: 'Parametrización Fiscal SIAT',
      descripcion: 'Configuración de llaves criptográficas y CUFD/CUIS.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Administración',
      permiso: 'Gestión de Sucursales y Cajas',
      descripcion: 'Asignación física de agencias y topes de caja.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Compra y Venta',
      permiso: 'Emisión de Facturas y Ventas POS',
      descripcion: 'Operar terminal de punto de venta y generar comprobantes.',
      adminTi: true,
      administrador: true,
      vendedorCajero: true,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Compra y Venta',
      permiso: 'Ajuste de Kárdex y Movimientos PEPS',
      descripcion: 'Ingresos, mermas y traslados de almacén.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: true,
    ),
    const RbacPermissionEntity(
      modulo: 'Compra y Venta',
      permiso: 'Gestión de Órdenes CIF e Importación',
      descripcion: 'Costeo internacional y recepción de proveedores.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: false,
    ),
    const RbacPermissionEntity(
      modulo: 'Reportes',
      permiso: 'Reportes Gerenciales y Financieros',
      descripcion: 'Visualización de estados de resultados y arqueos.',
      adminTi: true,
      administrador: true,
      vendedorCajero: false,
      inventariador: false,
    ),
  ];

  final List<WormAuditLogModel> _wormLogs = [
    WormAuditLogModel(
      id: 'wrm_1092',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      usuario: '4872910 (Lic. G. Guachalla)',
      modulo: 'AUTH_SECURITY',
      operacion: 'POLICY_UPDATE',
      severidad: WormSeverity.advertencia,
      payloadJsonb: '''{
  "event": "NIST_PASSWORD_POLICY_CHANGED",
  "min_length": 14,
  "require_symbols": true,
  "enforced_by": "Lic. G. Guachalla",
  "client_ip": "192.168.1.105",
  "tls_version": "TLSv1.3"
}''',
      hashSha256: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ),
    WormAuditLogModel(
      id: 'wrm_1091',
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 20)),
      usuario: '5829103 (Valeria Rivas)',
      modulo: 'VENTAS_SIAT',
      operacion: 'FACTURA_EMITIDA',
      severidad: WormSeverity.info,
      payloadJsonb: '''{
  "cuf": "4F9A2B81C370D45E6A8B1C2D3E4F5A6B",
  "numero_factura": 14082,
  "monto_total_bs": 345.50,
  "cliente_nit": "1028374029",
  "estado": "VALIDADA_SIN_OBSERVACIONES",
  "firmada_sha256": true
}''',
      hashSha256: '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08',
    ),
    WormAuditLogModel(
      id: 'wrm_1090',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      usuario: 'SYSTEM_GATEWAY',
      modulo: 'AUTH_BRUTE_FORCE',
      operacion: 'LOGIN_BLOCKED_ATTEMPT',
      severidad: WormSeverity.critico,
      payloadJsonb: '''{
  "incident": "MULTIPLE_FAILED_ATTEMPTS",
  "target_account": "admin@sanmartin.bo",
  "source_ip": "181.188.140.23",
  "failed_count": 5,
  "action": "AUTO_IP_BAN_60_MIN",
  "postgres_trigger": "trg_bitacora_inmutable_fire"
}''',
      hashSha256: '5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
    ),
    WormAuditLogModel(
      id: 'wrm_1089',
      timestamp: DateTime.now().subtract(const Duration(hours: 5, minutes: 10)),
      usuario: '6192840 (Mariana Suarez)',
      modulo: 'INVENTARIO_KARDEX',
      operacion: 'AJUSTE_PEPS_VALORADO',
      severidad: WormSeverity.info,
      payloadJsonb: '''{
  "sku": "LIB-QUIM-0092",
  "cantidad": 50,
  "lote": "LOTE-2026-Q1",
  "costo_unitario_cif": 78.40,
  "almacen": "Depósito Central Santa Cruz"
}''',
      hashSha256: '4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a',
    ),
  ];

  final List<BackupModel> _backups = [
    BackupModel(
      id: 'bkp_20261118_0400',
      nombreArchivo: 'sanmartin_prod_full_20261118_0400.dump.gpg',
      fecha: DateTime(2026, 11, 18, 4, 0),
      tipo: 'Full Criptográfico',
      tamano: '482.4 MB',
      checksumSha256: 'a1b2c3d4e5f60718293a4b5c6d7e8f9a0b1c2d3e4f5a6b7c8d9e0f1a2b3c4d5e',
      verificado: true,
    ),
    BackupModel(
      id: 'bkp_20261117_0400',
      nombreArchivo: 'sanmartin_prod_full_20261117_0400.dump.gpg',
      fecha: DateTime(2026, 11, 17, 4, 0),
      tipo: 'Full Criptográfico',
      tamano: '479.1 MB',
      checksumSha256: 'f6e5d4c3b2a10987654321fedcba0987654321fedcba0987654321fedcba0987',
      verificado: true,
    ),
    BackupModel(
      id: 'bkp_20261116_1200',
      nombreArchivo: 'sanmartin_prod_wal_20261116_1200.wal.gpg',
      fecha: DateTime(2026, 11, 16, 12, 0),
      tipo: 'Diferencial WAL',
      tamano: '34.8 MB',
      checksumSha256: '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef',
      verificado: true,
    ),
  ];

  @override
  Future<SecurityKpiEntity> getSecurityKpis() async {
    await _wait();
    return SecurityKpiEntity(
      totalUsuarios: _users.length,
      bloqueos24h: 3,
      sesionesJwtActivas: _sessions.where((s) => s.activa).length,
      integridadWormPorcentaje: 100.0,
      pgbouncerConexiones: 18,
      pgbouncerMaxConexiones: 100,
      cacheHitRatio: 99.42,
      latenciaMs: 42,
    );
  }

  @override
  Future<List<SessionModel>> getActiveSessions() async {
    await _wait();
    return List.from(_sessions.where((s) => s.activa));
  }

  @override
  Future<void> revokeSession(String jti) async {
    await _wait();
    final index = _sessions.indexWhere((s) => s.jti == jti);
    if (index != -1) {
      final current = _sessions[index];
      _sessions[index] = SessionModel(
        jti: current.jti,
        usuarioCi: current.usuarioCi,
        usuarioNombre: current.usuarioNombre,
        ipAddress: current.ipAddress,
        navegador: current.navegador,
        dispositivo: current.dispositivo,
        fechaInicio: current.fechaInicio,
        fechaExpiracion: current.fechaExpiracion,
        activa: false,
      );
    }
  }

  @override
  Future<List<UserSecurityModel>> getUsers({String? query, String? rol}) async {
    await _wait();
    var list = List<UserSecurityModel>.from(_users);
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      list = list
          .where(
            (u) =>
                u.nombre.toLowerCase().contains(q) ||
                u.ci.contains(q) ||
                u.email.toLowerCase().contains(q),
          )
          .toList();
    }
    if (rol != null && rol != 'Todos') {
      list = list.where((u) => u.rol == rol).toList();
    }
    return list;
  }

  @override
  Future<UserSecurityModel> createUser({
    required String ci,
    required String nombre,
    required String email,
    required String rol,
    required String sucursal,
    required String password,
  }) async {
    await _wait();
    final newUser = UserSecurityModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      ci: ci,
      nombre: nombre,
      email: email,
      rol: rol,
      sucursal: sucursal,
      activo: true,
      fechaCreacion: DateTime.now(),
      ultimoAcceso: null,
    );
    _users.insert(0, newUser);
    return newUser;
  }

  @override
  Future<UserSecurityModel> toggleUserStatus(String userId, bool active) async {
    await _wait();
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updated = _users[index].copyWith(activo: active);
      _users[index] = UserSecurityModel(
        id: updated.id,
        ci: updated.ci,
        nombre: updated.nombre,
        email: updated.email,
        rol: updated.rol,
        sucursal: updated.sucursal,
        activo: updated.activo,
        fechaCreacion: updated.fechaCreacion,
        ultimoAcceso: updated.ultimoAcceso,
      );
      return _users[index];
    }
    throw Exception('Usuario no encontrado');
  }

  @override
  Future<void> softDeleteUser(String userId) async {
    await _wait();
    _users.removeWhere((u) => u.id == userId);
  }

  @override
  Future<List<RbacPermissionEntity>> getRbacMatrix() async {
    await _wait();
    return List.from(_rbacMatrix);
  }

  @override
  Future<void> updateRbacPermission(RbacPermissionEntity permission) async {
    await _wait();
    final index = _rbacMatrix.indexWhere(
      (p) => p.modulo == permission.modulo && p.permiso == permission.permiso,
    );
    if (index != -1) {
      _rbacMatrix[index] = permission;
    }
  }

  @override
  Future<List<WormAuditLogModel>> getWormLogs({
    String? modulo,
    WormSeverity? severidad,
  }) async {
    await _wait();
    var list = List<WormAuditLogModel>.from(_wormLogs);
    if (modulo != null && modulo != 'Todos') {
      list = list.where((l) => l.modulo == modulo).toList();
    }
    if (severidad != null) {
      list = list.where((l) => l.severidad == severidad).toList();
    }
    return list;
  }

  @override
  Future<List<BackupModel>> getBackups() async {
    await _wait();
    return List.from(_backups);
  }

  @override
  Future<BackupModel> triggerManualBackup() async {
    await _wait();
    final now = DateTime.now();
    final newBackup = BackupModel(
      id: 'bkp_${now.millisecondsSinceEpoch}',
      nombreArchivo: 'sanmartin_manual_snap_${now.year}${now.month}${now.day}_${now.hour}${now.minute}.dump.gpg',
      fecha: now,
      tipo: 'Manual Criptográfico',
      tamano: '484.2 MB',
      checksumSha256: '7c98fbc184a284693a2e1d7f6b9c8d0e1a2b3c4d5e6f7a8b9c0d1e2f3a4b5c6d',
      verificado: true,
    );
    _backups.insert(0, newBackup);
    return newBackup;
  }
}
