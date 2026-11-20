import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/security_entities.dart';
import '../repositories/security_repository.dart';

/// Caso de Uso: Obtener KPIs de seguridad y telemetría.
class GetSecurityKpisUseCase implements UseCase<SecurityKpiEntity, NoParams> {
  final SecurityRepository _repository;
  GetSecurityKpisUseCase(this._repository);

  @override
  Future<Result<SecurityKpiEntity>> call(NoParams params) {
    return _repository.getSecurityKpis();
  }
}

/// Caso de Uso: Obtener sesiones activas.
class GetActiveSessionsUseCase implements UseCase<List<SessionEntity>, NoParams> {
  final SecurityRepository _repository;
  GetActiveSessionsUseCase(this._repository);

  @override
  Future<Result<List<SessionEntity>>> call(NoParams params) {
    return _repository.getActiveSessions();
  }
}

/// Caso de Uso: Revocar una sesión JWT.
class RevokeSessionUseCase implements UseCase<void, String> {
  final SecurityRepository _repository;
  RevokeSessionUseCase(this._repository);

  @override
  Future<Result<void>> call(String jti) {
    if (jti.isEmpty) {
      return Future.value(
        Result.failure(const ValidationFailure(message: 'El identificador JTI es requerido')),
      );
    }
    return _repository.revokeSession(jti);
  }
}

/// Parámetros para buscar usuarios.
class GetUsersParams {
  final String? query;
  final String? rol;
  const GetUsersParams({this.query, this.rol});
}

/// Caso de Uso: Obtener usuarios con filtros.
class GetUsersUseCase implements UseCase<List<UserSecurityEntity>, GetUsersParams> {
  final SecurityRepository _repository;
  GetUsersUseCase(this._repository);

  @override
  Future<Result<List<UserSecurityEntity>>> call(GetUsersParams params) {
    return _repository.getUsers(query: params.query, rol: params.rol);
  }
}

/// Parámetros para creación de usuario con validación estricta NIST.
class CreateUserParams {
  final String ci;
  final String nombre;
  final String email;
  final String rol;
  final String sucursal;
  final String password;

  const CreateUserParams({
    required this.ci,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.sucursal,
    required this.password,
  });
}

/// Caso de Uso: Crear Usuario con reglas de validación de negocio.
class CreateUserUseCase implements UseCase<UserSecurityEntity, CreateUserParams> {
  final SecurityRepository _repository;
  CreateUserUseCase(this._repository);

  @override
  Future<Result<UserSecurityEntity>> call(CreateUserParams params) async {
    // 1. Validación de Nombre (solo letras y espacios)
    final nameRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (params.nombre.trim().isEmpty || !nameRegex.hasMatch(params.nombre.trim())) {
      return Result.failure(
        const ValidationFailure(
          message: 'El nombre solo debe contener caracteres alfabéticos y espacios.',
        ),
      );
    }

    // 2. Validación de CI (solo números enteros)
    final ciRegex = RegExp(r'^\d+$');
    if (params.ci.trim().isEmpty || !ciRegex.hasMatch(params.ci.trim())) {
      return Result.failure(
        const ValidationFailure(
          message: 'El Carnet de Identidad (CI) solo debe contener dígitos numéricos.',
        ),
      );
    }

    // 3. Validación de Longitud mínima de clave NIST
    if (params.password.length < 8) {
      return Result.failure(
        const ValidationFailure(
          message: 'La contraseña no cumple con la política NIST (mínimo 8 caracteres).',
        ),
      );
    }

    return await _repository.createUser(
      ci: params.ci.trim(),
      nombre: params.nombre.trim(),
      email: params.email.trim(),
      rol: params.rol,
      sucursal: params.sucursal,
      password: params.password,
    );
  }
}

/// Caso de Uso: Suspender o reactivar usuario.
class ToggleUserStatusParams {
  final String userId;
  final bool active;
  const ToggleUserStatusParams({required this.userId, required this.active});
}

class ToggleUserStatusUseCase implements UseCase<UserSecurityEntity, ToggleUserStatusParams> {
  final SecurityRepository _repository;
  ToggleUserStatusUseCase(this._repository);

  @override
  Future<Result<UserSecurityEntity>> call(ToggleUserStatusParams params) {
    return _repository.toggleUserStatus(params.userId, params.active);
  }
}

/// Caso de Uso: Borrado lógico de usuario.
class SoftDeleteUserUseCase implements UseCase<void, String> {
  final SecurityRepository _repository;
  SoftDeleteUserUseCase(this._repository);

  @override
  Future<Result<void>> call(String userId) {
    return _repository.softDeleteUser(userId);
  }
}

/// Caso de Uso: Obtener matriz RBAC.
class GetRbacMatrixUseCase implements UseCase<List<RbacPermissionEntity>, NoParams> {
  final SecurityRepository _repository;
  GetRbacMatrixUseCase(this._repository);

  @override
  Future<Result<List<RbacPermissionEntity>>> call(NoParams params) {
    return _repository.getRbacMatrix();
  }
}

/// Caso de Uso: Actualizar permiso RBAC.
class UpdateRbacPermissionUseCase implements UseCase<void, RbacPermissionEntity> {
  final SecurityRepository _repository;
  UpdateRbacPermissionUseCase(this._repository);

  @override
  Future<Result<void>> call(RbacPermissionEntity permission) {
    return _repository.updateRbacPermission(permission);
  }
}

/// Caso de Uso: Obtener logs de Bitácora WORM.
class GetWormLogsParams {
  final String? modulo;
  final WormSeverity? severidad;
  const GetWormLogsParams({this.modulo, this.severidad});
}

class GetWormLogsUseCase implements UseCase<List<WormAuditLogEntity>, GetWormLogsParams> {
  final SecurityRepository _repository;
  GetWormLogsUseCase(this._repository);

  @override
  Future<Result<List<WormAuditLogEntity>>> call(GetWormLogsParams params) {
    return _repository.getWormLogs(modulo: params.modulo, severidad: params.severidad);
  }
}

/// Caso de Uso: Obtener lista de respaldos.
class GetBackupsUseCase implements UseCase<List<BackupEntity>, NoParams> {
  final SecurityRepository _repository;
  GetBackupsUseCase(this._repository);

  @override
  Future<Result<List<BackupEntity>>> call(NoParams params) {
    return _repository.getBackups();
  }
}

/// Caso de Uso: Ejecutar Respaldo Manual.
class TriggerManualBackupUseCase implements UseCase<BackupEntity, NoParams> {
  final SecurityRepository _repository;
  TriggerManualBackupUseCase(this._repository);

  @override
  Future<Result<BackupEntity>> call(NoParams params) {
    return _repository.triggerManualBackup();
  }
}
