import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/events/event_bus.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/events/user_logged_in_event.dart';
import '../../domain/usecases/login_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Controlador de presentación para la autenticación.
/// Utiliza [ChangeNotifier] para reactividad en Flutter Web y emite
/// eventos al [AppEventBus] para comunicar el estado a otros features desacoplados.
class AuthController extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final AppEventBus eventBus;

  AuthController({
    required this.loginUseCase,
    required this.eventBus,
  });

  AuthStatus _status = AuthStatus.initial;
  UserEntity? _currentUser;
  Failure? _failure;

  AuthStatus get status => _status;
  UserEntity? get currentUser => _currentUser;
  Failure? get failure => _failure;
  bool get isLoading => _status == AuthStatus.loading;
  String? get errorMessage => _failure?.message;

  /// Ejecuta el caso de uso de inicio de sesión y publica el evento en caso de éxito.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _failure = null;
    notifyListeners();

    final result = await loginUseCase(
      LoginParams(email: email, password: password),
    );

    return result.fold(
      onSuccess: (user) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
        _failure = null;
        notifyListeners();

        // COMUNICACIÓN DESACOPLADA (EDA): Emisión al bus de eventos
        eventBus.emit(UserLoggedInEvent(user: user));

        return true;
      },
      onFailure: (failure) {
        _status = AuthStatus.error;
        _failure = failure;
        notifyListeners();
        return false;
      },
    );
  }

  void clearError() {
    if (_failure != null) {
      _failure = null;
      _status = _currentUser != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      notifyListeners();
    }
  }
}
