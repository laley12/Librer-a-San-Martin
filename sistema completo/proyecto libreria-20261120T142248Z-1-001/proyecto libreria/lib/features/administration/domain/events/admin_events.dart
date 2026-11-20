import '../../../../core/events/domain_event.dart';
import '../entities/admin_entities.dart';

/// Evento emitido cuando se registra un nuevo SKU maestro en el catálogo.
class SkuRegisteredEvent extends DomainEvent {
  final SkuEntity sku;

  SkuRegisteredEvent({
    required this.sku,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'admin.sku_registered');
}

/// Evento emitido cuando se actualiza la parametrización fiscal del SIAT.
class FiscalConfigUpdatedEvent extends DomainEvent {
  final FiscalConfigEntity config;

  FiscalConfigUpdatedEvent({
    required this.config,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'admin.fiscal_config_updated');
}

/// Evento emitido cuando se ejecuta una prueba de conexión SOAP/REST con el SIN.
class SiatConnectionTestedEvent extends DomainEvent {
  final bool exitoso;
  final String mensaje;

  SiatConnectionTestedEvent({
    required this.exitoso,
    required this.mensaje,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'admin.siat_connection_tested');
}

/// Evento emitido cuando se crea una nueva sucursal en el sistema.
class BranchCreatedEvent extends DomainEvent {
  final BranchEntity branch;

  BranchCreatedEvent({
    required this.branch,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'admin.branch_created');
}

/// Evento emitido cuando se da de baja formalmente una sucursal.
class BranchDeactivatedEvent extends DomainEvent {
  final BranchEntity branch;
  final String motivo;

  BranchDeactivatedEvent({
    required this.branch,
    required this.motivo,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'admin.branch_deactivated');
}

/// Evento emitido cuando se reactiva una sucursal previamente dada de baja.
class BranchReactivatedEvent extends DomainEvent {
  final BranchEntity branch;

  BranchReactivatedEvent({
    required this.branch,
    super.eventId,
    super.occurredOn,
  }) : super(eventName: 'admin.branch_reactivated');
}
