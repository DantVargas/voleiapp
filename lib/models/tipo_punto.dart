import 'package:flutter/material.dart';

/// Motivo por el cual se anotó un punto en Modo Pro.
enum TipoPunto {
  ataque,
  saque,
  bloqueo,
  errorSaqueRival,
  errorAtaqueRival,
  errorRecepcionRival,
  otro,
}

extension TipoPuntoInfo on TipoPunto {
  /// true = acción positiva del equipo que anota (ataque/saque/bloqueo).
  /// false = el punto llegó por un error del equipo rival.
  bool get esPositivo =>
      this == TipoPunto.ataque || this == TipoPunto.saque || this == TipoPunto.bloqueo;

  String get label {
    switch (this) {
      case TipoPunto.ataque:
        return 'Ataque (punto directo)';
      case TipoPunto.saque:
        return 'Saque (Ace)';
      case TipoPunto.bloqueo:
        return 'Bloqueo';
      case TipoPunto.errorSaqueRival:
        return 'Error de saque rival';
      case TipoPunto.errorAtaqueRival:
        return 'Error de ataque rival';
      case TipoPunto.errorRecepcionRival:
        return 'Error de recepción rival';
      case TipoPunto.otro:
        return 'Otro / Error general';
    }
  }

  IconData get icono {
    switch (this) {
      case TipoPunto.ataque:
        return Icons.sports_volleyball;
      case TipoPunto.saque:
        return Icons.bolt;
      case TipoPunto.bloqueo:
        return Icons.block;
      case TipoPunto.errorSaqueRival:
        return Icons.report_gmailerrorred;
      case TipoPunto.errorAtaqueRival:
        return Icons.report_gmailerrorred;
      case TipoPunto.errorRecepcionRival:
        return Icons.report_gmailerrorred;
      case TipoPunto.otro:
        return Icons.help_outline;
    }
  }

  /// Campo de la tabla `estadisticas` que debe incrementarse, o null si no aplica.
  String? get campoEstadistica {
    switch (this) {
      case TipoPunto.ataque:
        return 'ataques';
      case TipoPunto.saque:
        return 'aces';
      case TipoPunto.bloqueo:
        return 'bloqueos';
      case TipoPunto.errorSaqueRival:
        return 'errores_saque';
      case TipoPunto.errorAtaqueRival:
        return 'errores_ataque';
      case TipoPunto.errorRecepcionRival:
        return 'errores_recepcion';
      case TipoPunto.otro:
        return null;
    }
  }

  static TipoPunto fromNombre(String nombre) =>
      TipoPunto.values.firstWhere((t) => t.name == nombre, orElse: () => TipoPunto.otro);
}