import 'dart:async';
import 'domain_event.dart';

/// Contrato para el Bus de Eventos de la aplicación (EDA).
/// Es el único canal permitido para la comunicación entre diferentes features.
abstract interface class AppEventBus {
  /// Emite un evento de dominio hacia el bus para que los suscriptores lo procesen.
  void emit<T extends DomainEvent>(T event);

  /// Retorna un flujo ([Stream]) de eventos filtrados por el tipo [T].
  Stream<T> on<T extends DomainEvent>();

  /// Retorna un flujo con todos los eventos de dominio emitidos.
  Stream<DomainEvent> get allEvents;

  /// Libera los recursos del bus.
  void dispose();
}

/// Implementación reactiva por defecto del Bus de Eventos usando un
/// [StreamController.broadcast].
class DefaultAppEventBus implements AppEventBus {
  final StreamController<DomainEvent> _controller;
  final void Function(DomainEvent event)? onEventLogged;

  DefaultAppEventBus({
    bool sync = false,
    this.onEventLogged,
  }) : _controller = StreamController<DomainEvent>.broadcast(sync: sync);

  @override
  void emit<T extends DomainEvent>(T event) {
    if (_controller.isClosed) return;
    onEventLogged?.call(event);
    _controller.add(event);
  }

  @override
  Stream<T> on<T extends DomainEvent>() {
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  @override
  Stream<DomainEvent> get allEvents => _controller.stream;

  @override
  void dispose() {
    if (!_controller.isClosed) {
      _controller.close();
    }
  }
}
