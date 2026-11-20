import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Parámetros de entrada para el caso de uso [LoginUseCase].
class LoginParams {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });
}

/// Caso de Uso atómico para iniciar sesión.
/// Aplica validaciones básicas de negocio antes de consultar el repositorio.
class LoginUseCase implements UseCase<UserEntity, LoginParams> {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Result<UserEntity>> call(LoginParams params) async {
    final email = params.email.trim();
    final password = params.password;

    if (email.isEmpty) {
      return Result.failure(
        const ValidationFailure(message: 'El correo electrónico es requerido'),
      );
    }

    if (!email.contains('@') || !email.contains('.')) {
      return Result.failure(
        const ValidationFailure(message: 'El formato de correo no es válido'),
      );
    }

    if (password.isEmpty || password.length < 6) {
      return Result.failure(
        const ValidationFailure(
          message: 'La contraseña debe tener al menos 6 caracteres',
        ),
      );
    }

    return await _repository.login(email: email, password: password);
  }
}
