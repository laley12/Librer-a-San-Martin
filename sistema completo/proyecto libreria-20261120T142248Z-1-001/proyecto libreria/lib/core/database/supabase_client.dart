import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Configuración y Cliente Oficial de Supabase para Librería San Martín
/// Proyecto: https://tkypdjfmifywnwwjmcfh.supabase.co
class SupabaseConfig {
  SupabaseConfig._();

  static const String projectUrl = 'https://tkypdjfmifywnwwjmcfh.supabase.co';
  static const String publishableKey = 'sb_publishable_jJy8UBoSuEl7tqiRMvbXxw_V3XtqaCz';

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Inicializa la conexión con Supabase Cloud
  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      await Supabase.initialize(
        url: projectUrl,
        // ignore: deprecated_member_use
        anonKey: publishableKey,
        debug: false,
      );
      _initialized = true;
      developer.log('Supabase inicializado correctamente con $projectUrl', name: 'SupabaseConfig');
    } catch (e, stack) {
      developer.log('Error al inicializar Supabase: $e', name: 'SupabaseConfig', error: e, stackTrace: stack);
      // No rethrow para permitir modo offline/pruebas en local
    }
  }

  /// Instancia directa del cliente de Supabase
  static SupabaseClient get client {
    if (!_initialized) {
      developer.log('Advertencia: Supabase no ha sido inicializado aún.', name: 'SupabaseConfig');
    }
    return Supabase.instance.client;
  }
}
