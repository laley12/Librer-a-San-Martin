import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementación del repositorio de autenticación.
/// Coordina las fuentes de datos y transforma excepciones en [Failure]s de dominio.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return Result.success(userModel);
    } on ServerException catch (e) {
      return Result.failure(
        ServerFailure(
          message: e.message,
          statusCode: e.statusCode,
          code: 'SERVER_AUTH_ERROR',
        ),
      );
    } on NetworkException catch (e) {
      return Result.failure(
        NetworkFailure(message: e.message),
      );
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Error inesperado al autenticar: $e'),
      );
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Error al cerrar sesión: $e'),
      );
    }
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();
      return Result.success(user);
    } catch (e) {
      return Result.failure(
        UnknownFailure(message: 'Error al consultar usuario en sesión: $e'),
      );
    }
  }
}
