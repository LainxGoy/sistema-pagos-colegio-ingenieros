import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';

class AuthService {
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyNombre = 'auth_user_nombre';
  static const String _keyEmail = 'auth_user_email';
  static const String _keyEstadoHabilitacion = 'auth_estado_habilitacion';
  static const String _keyMontoCuotaActual = 'auth_monto_cuota_actual';

  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Saves the full user session to SharedPreferences.
  Future<void> saveSession(Usuario usuario, {String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    final effectiveToken = token ?? usuario.token;

    if (effectiveToken != null && effectiveToken.isNotEmpty) {
      await prefs.setString(_keyToken, effectiveToken);
    }
    await prefs.setInt(_keyUserId, usuario.id);
    await prefs.setString(_keyNombre, usuario.nombre);
    await prefs.setString(_keyEmail, usuario.email);
    await prefs.setBool(_keyEstadoHabilitacion, usuario.estadoHabilitacion);
    await prefs.setDouble(_keyMontoCuotaActual, usuario.montoCuotaActual);
  }

  /// Retrieves the stored authentication token.
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Retrieves the stored user data. Returns null if no user is stored.
  Future<Usuario?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);
    final nombre = prefs.getString(_keyNombre);

    if (userId == null || nombre == null) {
      return null;
    }

    final token = prefs.getString(_keyToken);
    final email = prefs.getString(_keyEmail) ?? '';
    final estado = prefs.getBool(_keyEstadoHabilitacion) ?? false;
    final monto = prefs.getDouble(_keyMontoCuotaActual) ?? 0.0;

    return Usuario(
      id: userId,
      nombre: nombre,
      email: email,
      token: token,
      estadoHabilitacion: estado,
      montoCuotaActual: monto,
    );
  }

  /// Clears all stored session data.
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyNombre);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyEstadoHabilitacion);
    await prefs.remove(_keyMontoCuotaActual);
  }

  /// Checks whether a valid session token is saved.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    return token != null && token.trim().isNotEmpty;
  }
}
