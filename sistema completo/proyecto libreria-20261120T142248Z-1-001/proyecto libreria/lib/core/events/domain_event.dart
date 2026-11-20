/// Clase base inmutable para todos los Eventos de Dominio en el sistema.
/// Los eventos son hechos consumados que han ocurrido en el negocio y permiten
/// la comunicación 100% desacoplada entre distintos features.
abstract class DomainEvent {
  /// Identificador único del evento para trazabilidad y logs.
  final String eventId;

  /// Marca temporal exacta en la que ocurrió el evento.
  final DateTime occurredOn;

  /// Nombre identificador del evento.
  final String eventName;

  DomainEvent({
    String? eventId,
    DateTime? occurredOn,
    required this.eventName,
  })  : eventId = eventId ?? _generateUniqueId(),
        occurredOn = occurredOn ?? DateTime.now().toUtc();

  static String _generateUniqueId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'evt_${now}_${identityHashCode(now)}';
  }

  @override
  String toString() => '$eventName (id: $eventId, occurredOn: $occurredOn)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DomainEvent && other.eventId == eventId;
  }

  @override
  int get hashCode => eventId.hashCode;
}
