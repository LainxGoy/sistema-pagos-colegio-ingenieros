class Pago {
  final int id;
  final int cuotaId;
  final double monto;
  final String fecha;
  final String? comprobantePath;
  final String estadoRevision; // "PENDIENTE", "APROBADO", "RECHAZADO"

  const Pago({
    required this.id,
    required this.cuotaId,
    required this.monto,
    required this.fecha,
    this.comprobantePath,
    required this.estadoRevision,
  });

  bool get isPendiente => estadoRevision.toUpperCase() == 'PENDIENTE';
  bool get isAprobado => estadoRevision.toUpperCase() == 'APROBADO';
  bool get isRechazado => estadoRevision.toUpperCase() == 'RECHAZADO';

  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      cuotaId: json['cuotaId'] is int
          ? json['cuotaId'] as int
          : (json['cuota_id'] is int
              ? json['cuota_id'] as int
              : int.tryParse(json['cuotaId']?.toString() ??
                      json['cuota_id']?.toString() ??
                      '0') ??
                  0),
      monto: _parseDouble(json['monto']),
      fecha: json['fecha']?.toString() ?? '',
      comprobantePath: json['comprobantePath']?.toString() ??
          json['comprobante_path']?.toString() ??
          json['comprobante']?.toString(),
      estadoRevision: (json['estadoRevision']?.toString() ??
              json['estado_revision']?.toString() ??
              'PENDIENTE')
          .toUpperCase(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cuotaId': cuotaId,
      'monto': monto,
      'fecha': fecha,
      'comprobantePath': comprobantePath,
      'estadoRevision': estadoRevision,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }
}
