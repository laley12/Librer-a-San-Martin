import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/repositories/security_repository.dart';
import '../datasources/security_remote_data_source.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityRemoteDataSource remoteDataSource;

  SecurityRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<SecurityKpiEntity>> getSecurityKpis() async {
    try {
      final kpis = await remoteDataSource.getSecurityKpis();
      return Result.success(kpis);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al cargar KPIs: $e'));
    }
  }

  @override
  Future<Result<List<SessionEntity>>> getActiveSessions() async {
    try {
      final sessions = await remoteDataSource.getActiveSessions();
      return Result.success(sessions);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al consultar sesiones: $e'));
    }
  }

  @override
  Future<Result<void>> revokeSession(String jti) async {
    try {
      await remoteDataSource.revokeSession(jti);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al revocar sesión: $e'));
    }
  }

  @override
  Future<Result<List<UserSecurityEntity>>> getUsers({String? query, String? rol}) async {
    try {
      final users = await remoteDataSource.getUsers(query: query, rol: rol);
      return Result.success(users);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al listar usuarios: $e'));
    }
  }

  @override
  Future<Result<UserSecurityEntity>> createUser({
    required String ci,
    required String nombre,
    required String email,
    required String rol,
    required String sucursal,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.createUser(
        ci: ci,
        nombre: nombre,
        email: email,
        rol: rol,
        sucursal: sucursal,
        password: password,
      );
      return Result.success(user);
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al crear usuario: $e'));
    }
  }

  @override
  Future<Result<UserSecurityEntity>> toggleUserStatus(String userId, bool active) async {
    try {
      final user = await remoteDataSource.toggleUserStatus(userId, active);
      return Result.success(user);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al cambiar estado de usuario: $e'));
    }
  }

  @override
  Future<Result<void>> softDeleteUser(String userId) async {
    try {
      await remoteDataSource.softDeleteUser(userId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al eliminar usuario: $e'));
    }
  }

  @override
  Future<Result<List<RbacPermissionEntity>>> getRbacMatrix() async {
    try {
      final matrix = await remoteDataSource.getRbacMatrix();
      return Result.success(matrix);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al cargar matriz RBAC: $e'));
    }
  }

  @override
  Future<Result<void>> updateRbacPermission(RbacPermissionEntity permission) async {
    try {
      await remoteDataSource.updateRbacPermission(permission);
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al actualizar permiso: $e'));
    }
  }

  @override
  Future<Result<List<WormAuditLogEntity>>> getWormLogs({
    String? modulo,
    WormSeverity? severidad,
  }) async {
    try {
      final logs = await remoteDataSource.getWormLogs(modulo: modulo, severidad: severidad);
      return Result.success(logs);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al cargar bitácora WORM: $e'));
    }
  }

  @override
  Future<Result<List<BackupEntity>>> getBackups() async {
    try {
      final backups = await remoteDataSource.getBackups();
      return Result.success(backups);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al listar respaldos: $e'));
    }
  }

  @override
  Future<Result<BackupEntity>> triggerManualBackup() async {
    try {
      final backup = await remoteDataSource.triggerManualBackup();
      return Result.success(backup);
    } catch (e) {
      return Result.failure(UnknownFailure(message: 'Error al ejecutar respaldo: $e'));
    }
  }
}
