import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

/// Contrato para la fuente de datos remota de autenticación.
abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

/// Implementación en memoria/mock para pruebas iniciales en Flutter Web.
/// Posteriormente se sustituye por llamada a cliente HTTP (Dio, http, Supabase, Firebase).
class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Duration delay;
  UserModel? _currentUser;

  MockAuthRemoteDataSourceImpl({this.delay = const Duration(milliseconds: 700)});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulación de latencia de red en cliente web
    if (delay > Duration.zero) await Future.delayed(delay);

    // Validación simulada de backend
    if (password == 'error123') {
      throw const ServerException(
        message: 'Credenciales inválidas en el servidor',
        statusCode: 401,
      );
    }

    // Validación para cuenta Superadmin Harold Eastman
    if (email.toLowerCase().contains('eastman') || email == 'eastmanharold@gmail.com') {
      if (password != 'Eastman123*Sc' && password != '123456') {
        throw const ServerException(
          message: 'Contraseña incorrecta para Harold Eastman. Verifique su clave.',
          statusCode: 401,
        );
      }
      final user = UserModel(
        id: 'usr_eastman_superadmin',
        email: 'eastmanharold@gmail.com',
        name: 'Ing. Harold Eastman Romay',
        role: 'SUPERADMIN',
        createdAt: DateTime(2025, 1, 1),
      );
      _currentUser = user;
      return user;
    }

    final user = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: email.split('@').first.toUpperCase(),
      role: 'ADMINISTRATOR',
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    if (delay > Duration.zero) await Future.delayed(delay);
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }
}
