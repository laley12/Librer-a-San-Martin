library;

/// Excepciones técnicas arrojadas por la capa de datos ([DataSources]).
/// Deben ser capturadas en los repositorios de datos y transformadas
/// en su correspondiente [Failure] de dominio.

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseBody;

  const ServerException({
    required this.message,
    this.statusCode,
    this.responseBody,
  });

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'Error de conectividad de red']);

  @override
  String toString() => 'NetworkException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Error al acceder al almacenamiento local']);

  @override
  String toString() => 'CacheException: $message';
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException([this.message = 'Credenciales no válidas o acceso denegado']);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Recurso no encontrado']);

  @override
  String toString() => 'NotFoundException: $message';
}
