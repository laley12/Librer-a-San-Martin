import '../../../../core/events/domain_event.dart';
import '../entities/security_entities.dart';

/// Evento emitido cuando se revoca una sesión JWT activa.
class SessionRevokedEvent extends DomainEvent {
  final String jti;
  final String usuarioCi;
  final String motivo;

  SessionRevokedEvent({
    required this.jti,
    required this.usuarioCi,
    this.motivo = 'Revocación manual por administrador',
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'security.session_revoked');
}

/// Evento emitido cuando se da de alta un nuevo usuario.
class UserCreatedEvent extends DomainEvent {
  final UserSecurityEntity user;

  UserCreatedEvent({
    required this.user,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'security.user_created');
}

/// Evento emitido cuando se ejecuta un respaldo manual verificado por SHA-256.
class BackupCompletedEvent extends DomainEvent {
  final BackupEntity backup;

  BackupCompletedEvent({
    required this.backup,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'security.backup_completed');
}
