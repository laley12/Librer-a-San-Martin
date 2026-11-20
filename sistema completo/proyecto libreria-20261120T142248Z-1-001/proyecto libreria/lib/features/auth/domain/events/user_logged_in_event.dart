import '../../../../core/events/domain_event.dart';
import '../entities/user_entity.dart';

/// Evento de Dominio emitido cuando un usuario inicia sesión exitosamente.
/// Permite que otros features (ej. Notificaciones, Auditoría, Dashboard)
/// reaccionen sin tener acoplamiento directo con el módulo de Auth.
class UserLoggedInEvent extends DomainEvent {
  final UserEntity user;
  final String ipAddress;

  UserLoggedInEvent({
    required this.user,
    this.ipAddress = 'web-client',
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'auth.user_logged_in');

  @override
  String toString() =>
      'UserLoggedInEvent(userId: ${user.id}, email: ${user.email}, occurredOn: $occurredOn)';
}
