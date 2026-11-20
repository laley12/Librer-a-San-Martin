/// Clase base abstracta para representar cualquier fallo o error en el sistema.
/// Las capas de dominio y presentación interactúan con [Failure] y nunca
/// directamente con excepciones de bajo nivel.
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => '$runtimeType: $message (code: $code)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.runtimeType == runtimeType &&
        other.message == message &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, code);
}

/// Fallo ocasionado por respuestas erróneas del servidor o API REST/GraphQL.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    super.details,
    this.statusCode,
  });
}

/// Fallo derivado de problemas de conectividad o red no disponible.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No se pudo establecer conexión con el servidor. Verifica tu conexión de red.',
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

/// Fallo al interactuar con almacenamiento local (cache, localStorage, indexedDB).
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.details,
  });
}

/// Fallo de validación de datos en reglas de negocio o formularios.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
    super.details,
  });
}

/// Fallo de autenticación o permisos insuficientes (401/403).
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Sesión no válida o permisos insuficientes.',
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}

/// Fallo cuando un recurso no fue encontrado (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND',
    super.details,
  });
}

/// Fallo genérico o inesperado no clasificado.
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ocurrió un error inesperado en el sistema.',
    super.code = 'UNKNOWN_ERROR',
    super.details,
  });
}
