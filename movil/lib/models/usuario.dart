class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? token;
  final bool estadoHabilitacion;
  final double montoCuotaActual;

  const Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.token,
    required this.estadoHabilitacion,
    required this.montoCuotaActual,
  });

  /// Factory constructor to create a Usuario instance from JSON.
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      token: json['token']?.toString(),
      estadoHabilitacion: _parseBool(json['estadoHabilitacion'] ?? json['estado_habilitacion'] ?? json['habilitado']),
      montoCuotaActual: json['montoCuotaActual'] != null
          ? _parseDouble(json['montoCuotaActual'])
          : _parseDouble(json['monto_cuota_actual'] ?? 0),
    );
  }

  /// Converts this Usuario instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'email': email,
      'token': token,
      'estadoHabilitacion': estadoHabilitacion,
      'montoCuotaActual': montoCuotaActual,
    };
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? email,
    String? token,
    bool? estadoHabilitacion,
    double? montoCuotaActual,
  }) {
    return Usuario(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      email: email ?? this.email,
      token: token ?? this.token,
      estadoHabilitacion: estadoHabilitacion ?? this.estadoHabilitacion,
      montoCuotaActual: montoCuotaActual ?? this.montoCuotaActual,
    );
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      return lower == 'true' || lower == '1' || lower == 'habilitado';
    }
    return false;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }
}
