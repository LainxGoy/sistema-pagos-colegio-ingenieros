class Cuota {
  final int id;
  final String periodo;
  final int gestion;
  final double monto;
  final String estado; // "PAGADA", "PENDIENTE"
  final String fechaVencimiento;
  final String? estadoRevisionPago; // "PENDIENTE", "APROBADO", "RECHAZADO", or null

  const Cuota({
    required this.id,
    required this.periodo,
    required this.gestion,
    required this.monto,
    required this.estado,
    required this.fechaVencimiento,
    this.estadoRevisionPago,
  });

  bool get isPagada => estado.toUpperCase() == 'PAGADA';
  bool get isPendiente => estado.toUpperCase() == 'PENDIENTE';

  factory Cuota.fromJson(Map<String, dynamic> json) {
    return Cuota(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      periodo: json['periodo']?.toString() ?? '',
      gestion: json['gestion'] is int
          ? json['gestion'] as int
          : int.tryParse(json['gestion']?.toString() ?? '2026') ?? 2026,
      monto: _parseDouble(json['monto']),
      estado: (json['estado']?.toString() ?? 'PENDIENTE').toUpperCase(),
      fechaVencimiento: json['fechaVencimiento']?.toString() ??
          json['fecha_vencimiento']?.toString() ??
          '',
      estadoRevisionPago: json['estadoRevisionPago']?.toString() ??
          json['estado_revision_pago']?.toString() ??
          json['estado_revision']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodo': periodo,
      'gestion': gestion,
      'monto': monto,
      'estado': estado,
      'fechaVencimiento': fechaVencimiento,
      'estadoRevisionPago': estadoRevisionPago,
    };
  }

  Cuota copyWith({
    int? id,
    String? periodo,
    int? gestion,
    double? monto,
    String? estado,
    String? fechaVencimiento,
    String? estadoRevisionPago,
  }) {
    return Cuota(
      id: id ?? this.id,
      periodo: periodo ?? this.periodo,
      gestion: gestion ?? this.gestion,
      monto: monto ?? this.monto,
      estado: estado ?? this.estado,
      fechaVencimiento: fechaVencimiento ?? this.fechaVencimiento,
      estadoRevisionPago: estadoRevisionPago ?? this.estadoRevisionPago,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }
}
