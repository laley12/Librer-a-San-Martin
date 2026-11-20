import '../errors/result.dart';

/// Contrato base para todo Caso de Uso en la arquitectura limpia.
/// Cada caso de uso representa una acción atómica del negocio (Single Responsibility Principle).
///
/// [Output]: El tipo de dato retornado en caso de éxito.
/// [Params]: El objeto que encapsula los parámetros de entrada.
abstract class UseCase<Output, Params> {
  Future<Result<Output>> call(Params params);
}

/// Contrato base para casos de uso que retornan un flujo continuo de datos reactivo.
abstract class StreamUseCase<Output, Params> {
  Stream<Result<Output>> call(Params params);
}

/// Representa la ausencia de parámetros para casos de uso que no requieren argumentos.
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => identical(this, other) || other is NoParams;

  @override
  int get hashCode => 0;
}
