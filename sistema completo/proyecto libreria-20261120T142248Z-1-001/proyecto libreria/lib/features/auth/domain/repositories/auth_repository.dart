import '../../../../core/errors/result.dart';
import '../entities/user_entity.dart';

/// Contrato abstracto que debe ser implementado en la capa de datos (`data/`).
/// La capa de dominio define QUÉ se necesita, no CÓMO se obtiene.
abstract interface class AuthRepository {
  /// Inicia sesión con credenciales de usuario.
  Future<Result<UserEntity>> login({
    required String email,
    required String password,
  });

  /// Cierra la sesión activa.
  Future<Result<void>> logout();

  /// Obtiene el usuario autenticado actualmente en sesión.
  Future<Result<UserEntity?>> getCurrentUser();
}
