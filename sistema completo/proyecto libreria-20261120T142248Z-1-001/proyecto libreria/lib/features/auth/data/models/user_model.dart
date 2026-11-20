import '../../domain/entities/user_entity.dart';

/// Modelo de datos (DTO) para la serialización y deserialización de usuarios.
/// Mapea la estructura externa hacia la entidad de dominio pura.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.role,
    required super.createdAt,
  });

  /// Factory para construir el modelo desde un Map/JSON de API.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Serializa el modelo a formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte una entidad de dominio a DTO de datos.
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      role: entity.role,
      createdAt: entity.createdAt,
    );
  }
}
