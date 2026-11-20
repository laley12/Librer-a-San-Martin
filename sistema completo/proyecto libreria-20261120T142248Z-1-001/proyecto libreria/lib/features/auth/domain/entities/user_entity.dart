/// Entidad de Dominio que representa a un Usuario autenticado.
/// CERO dependencias de Flutter o librerías de infraestructura.
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String role;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity && other.id == id && other.email == email;
  }

  @override
  int get hashCode => Object.hash(id, email);

  @override
  String toString() => 'UserEntity(id: $id, email: $email, role: $role)';
}
