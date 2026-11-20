import '../../../../core/errors/result.dart';
import '../entities/security_entities.dart';

/// Contrato de repositorio para el Módulo de Seguridad y Accesos.
abstract interface class SecurityRepository {
  /// Obtiene los KPIs de seguridad y telemetría.
  Future<Result<SecurityKpiEntity>> getSecurityKpis();

  /// Obtiene la lista de sesiones JWT activas.
  Future<Result<List<SessionEntity>>> getActiveSessions();

  /// Revoca una sesión activa por su JTI.
  Future<Result<void>> revokeSession(String jti);

  /// Obtiene el catálogo de usuarios del sistema con filtro de búsqueda.
  Future<Result<List<UserSecurityEntity>>> getUsers({String? query, String? rol});

  /// Registra un nuevo usuario en el sistema.
  Future<Result<UserSecurityEntity>> createUser({
    required String ci,
    required String nombre,
    required String email,
    required String rol,
    required String sucursal,
    required String password,
  });

  /// Cambia el estado de activación de un usuario (suspender / reactivar).
  Future<Result<UserSecurityEntity>> toggleUserStatus(String userId, bool active);

  /// Realiza un borrado lógico del usuario.
  Future<Result<void>> softDeleteUser(String userId);

  /// Obtiene la matriz de control de acceso RBAC.
  Future<Result<List<RbacPermissionEntity>>> getRbacMatrix();

  /// Actualiza un permiso en la matriz RBAC.
  Future<Result<void>> updateRbacPermission(RbacPermissionEntity permission);

  /// Obtiene los registros forenses de la Bitácora WORM inmutable.
  Future<Result<List<WormAuditLogEntity>>> getWormLogs({
    String? modulo,
    WormSeverity? severidad,
  });

  /// Obtiene el historial de respaldos criptográficos.
  Future<Result<List<BackupEntity>>> getBackups();

  /// Dispara la creación de un nuevo respaldo manual verificado por SHA-256.
  Future<Result<BackupEntity>> triggerManualBackup();
}
