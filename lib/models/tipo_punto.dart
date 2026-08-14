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

  /// Nombre corto para leyendas de gráficos (donde el label completo no entra).
  String get labelCorto {
    switch (this) {
      case TipoPunto.ataque:
        return 'Ataque';
      case TipoPunto.saque:
        return 'Ace';
      case TipoPunto.bloqueo:
        return 'Bloqueo';
      case TipoPunto.errorSaqueRival:
        return 'Err. saque riv.';
      case TipoPunto.errorAtaqueRival:
        return 'Err. ataque riv.';
      case TipoPunto.errorRecepcionRival:
        return 'Err. recep. riv.';
      case TipoPunto.otro:
        return 'Otro';
    }
  }

  /// Color categórico fijo (identidad, no valor) usado en gráficos y leyendas.
  /// El orden de asignación es fijo — nunca se reordena según los datos.
  Color get colorCategoria {
    switch (this) {
      case TipoPunto.ataque:
        return const Color(0xFF2A78D6); // azul
      case TipoPunto.saque:
        return const Color(0xFFEB6834); // naranja
      case TipoPunto.bloqueo:
        return const Color(0xFF1BAF7A); // aqua
      case TipoPunto.errorSaqueRival:
        return const Color(0xFFEDA100); // amarillo
      case TipoPunto.errorAtaqueRival:
        return const Color(0xFFE87BA4); // magenta
      case TipoPunto.errorRecepcionRival:
        return const Color(0xFF008300); // verde
      case TipoPunto.otro:
        return const Color(0xFF4A3AA7); // violeta
    }
  }
}