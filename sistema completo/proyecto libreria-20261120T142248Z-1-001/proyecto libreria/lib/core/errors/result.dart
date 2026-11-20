import 'failures.dart';

/// Tipo monádico [Result] para representar el resultado de una operación que puede
/// tener éxito ([Success]) o fallar ([FailureResult]).
/// Evita el uso descontrolado de excepciones y obliga a gestionar ambos casos.
sealed class Result<T> {
  const Result();

  /// Retorna una instancia exitosa que encapsula los datos.
  factory Result.success(T data) = Success<T>;

  /// Retorna una instancia fallida que encapsula un [Failure].
  factory Result.failure(Failure failure) = FailureResult<T>;

  /// Determina si la operación fue exitosa.
  bool get isSuccess => this is Success<T>;

  /// Determina si la operación falló.
  bool get isFailure => this is FailureResult<T>;

  /// Obtiene los datos en caso de éxito o `null` si falló.
  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        FailureResult() => null,
      };

  /// Obtiene el fallo en caso de error o `null` si fue exitoso.
  Failure? get failureOrNull => switch (this) {
        Success() => null,
        FailureResult(failure: final f) => f,
      };

  /// Ejecuta [onSuccess] si fue exitoso o [onFailure] si falló.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success(data: final d) => onSuccess(d),
      FailureResult(failure: final f) => onFailure(f),
    };
  }

  /// Transforma el valor contenido si es exitoso.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final d) => Result.success(transform(d)),
      FailureResult(failure: final f) => Result.failure(f),
    };
  }
}

/// Representa el resultado exitoso con su valor asociado [data].
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;
}

/// Representa el resultado fallido con su correspondiente [failure].
final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);

  @override
  String toString() => 'FailureResult(failure: $failure)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FailureResult<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;
}
