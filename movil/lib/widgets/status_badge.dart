import 'package:flutter/material.dart';

enum StatusBadgeType {
  habilitado,
  noHabilitado,
  cuotaPagada,
  cuotaPendiente,
  pagoPendiente,
  pagoAprobado,
  pagoRechazado,
}

class StatusBadge extends StatelessWidget {
  final StatusBadgeType? type;
  final String? customLabel;
  final Color? customColor;
  final IconData? customIcon;
  final bool isLarge;

  const StatusBadge({
    super.key,
    this.type,
    this.customLabel,
    this.customColor,
    this.customIcon,
    this.isLarge = false,
  });

  /// Factory for affiliation status (true = HABILITADO, false = NO HABILITADO)
  factory StatusBadge.habilitacion({required bool habilitado, bool isLarge = false}) {
    return StatusBadge(
      type: habilitado ? StatusBadgeType.habilitado : StatusBadgeType.noHabilitado,
      isLarge: isLarge,
    );
  }

  /// Factory for cuota status (PAGADA / PENDIENTE)
  factory StatusBadge.cuota({required String estado, bool isLarge = false}) {
    final upper = estado.toUpperCase();
    return StatusBadge(
      type: upper == 'PAGADA'
          ? StatusBadgeType.cuotaPagada
          : StatusBadgeType.cuotaPendiente,
      isLarge: isLarge,
    );
  }

  /// Factory for payment review status (PENDIENTE / APROBADO / RECHAZADO)
  factory StatusBadge.pagoRevision({required String estadoRevision, bool isLarge = false}) {
    final upper = estadoRevision.toUpperCase();
    StatusBadgeType selectedType;
    switch (upper) {
      case 'APROBADO':
        selectedType = StatusBadgeType.pagoAprobado;
        break;
      case 'RECHAZADO':
        selectedType = StatusBadgeType.pagoRechazado;
        break;
      case 'PENDIENTE':
      default:
        selectedType = StatusBadgeType.pagoPendiente;
        break;
    }
    return StatusBadge(
      type: selectedType,
      isLarge: isLarge,
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 14 : 10,
        vertical: isLarge ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(isLarge ? 20 : 14),
        border: Border.all(
          color: config.borderColor,
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: isLarge ? 18 : 14,
            color: config.textColor,
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: TextStyle(
              color: config.textColor,
              fontWeight: FontWeight.bold,
              fontSize: isLarge ? 14 : 12,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeConfig _getConfig() {
    if (customLabel != null && customColor != null) {
      return _BadgeConfig(
        label: customLabel!,
        icon: customIcon ?? Icons.info_outline,
        textColor: customColor!,
        backgroundColor: customColor!.withValues(alpha: 0.12),
        borderColor: customColor!.withValues(alpha: 0.35),
      );
    }

    switch (type) {
      case StatusBadgeType.habilitado:
        return _BadgeConfig(
          label: 'HABILITADO',
          icon: Icons.check_circle_rounded,
          textColor: const Color(0xFF1B873F),
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
        );
      case StatusBadgeType.noHabilitado:
        return _BadgeConfig(
          label: 'NO HABILITADO',
          icon: Icons.cancel_rounded,
          textColor: const Color(0xFFC62828),
          backgroundColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
        );
      case StatusBadgeType.cuotaPagada:
        return _BadgeConfig(
          label: 'PAGADA',
          icon: Icons.check_rounded,
          textColor: const Color(0xFF2E7D32),
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
        );
      case StatusBadgeType.cuotaPendiente:
        return _BadgeConfig(
          label: 'PENDIENTE',
          icon: Icons.schedule_rounded,
          textColor: const Color(0xFFD84315),
          backgroundColor: const Color(0xFFFBE9E7),
          borderColor: const Color(0xFFFFCCBC),
        );
      case StatusBadgeType.pagoPendiente:
        return _BadgeConfig(
          label: 'En Revisión',
          icon: Icons.hourglass_top_rounded,
          textColor: const Color(0xFFE65100),
          backgroundColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFCC80),
        );
      case StatusBadgeType.pagoAprobado:
        return _BadgeConfig(
          label: 'Aprobado',
          icon: Icons.verified_rounded,
          textColor: const Color(0xFF1B873F),
          backgroundColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
        );
      case StatusBadgeType.pagoRechazado:
        return _BadgeConfig(
          label: 'Rechazado',
          icon: Icons.highlight_off_rounded,
          textColor: const Color(0xFFC62828),
          backgroundColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
        );
      case null:
        return _BadgeConfig(
          label: 'DESCONOCIDO',
          icon: Icons.help_outline,
          textColor: Colors.grey.shade700,
          backgroundColor: Colors.grey.shade100,
          borderColor: Colors.grey.shade300,
        );
    }
  }
}

class _BadgeConfig {
  final String label;
  final IconData icon;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;

  _BadgeConfig({
    required this.label,
    required this.icon,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });
}
