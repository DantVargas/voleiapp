class Jugador {
  final int? id;
  String? nombre; // Se quita 'final' para permitir la edición directa en el diálogo
  int dorsal;
  int posicionCancha; // 0 para banca, 1-6 para posiciones en cancha
  final String? posicionJuego;
  final int equipoId;

  Jugador({
    this.id,
    this.nombre,
    required this.dorsal,
    required this.posicionCancha,
    this.posicionJuego,
    required this.equipoId,
  });

  // Getters de utilidad
  bool get esSuplente => posicionCancha == 0;
  bool get estaEnCancha => posicionCancha >= 1 && posicionCancha <= 6;

  /// Crea una copia del jugador con campos actualizados.
  /// Útil para operaciones donde prefieras inmutabilidad o para resets.
  Jugador copyWith({
    int? id,
    String? nombre,
    int? dorsal,
    int? posicionCancha,
    String? posicionJuego,
    int? equipoId,
  }) {
    return Jugador(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      dorsal: dorsal ?? this.dorsal,
      posicionCancha: posicionCancha ?? this.posicionCancha,
      posicionJuego: posicionJuego ?? this.posicionJuego,
      equipoId: equipoId ?? this.equipoId,
    );
  }

  /// Crea un objeto Jugador a partir de un Map (útil para SQLite o JSON).
  factory Jugador.fromMap(Map<String, dynamic> map) {
    return Jugador(
      id: map['id'] as int?,
      equipoId: map['equipo_id'] as int,
      nombre: map['nombre'] as String?,
      dorsal: map['dorsal'] as int,
      posicionJuego: map['posicion_juego'] as String?,
      posicionCancha: map['posicion_cancha'] as int,
    );
  }

  /// Convierte el objeto Jugador a un Map.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'equipo_id': equipoId,
      'nombre': nombre,
      'dorsal': dorsal,
      'posicion_juego': posicionJuego,
      'posicion_cancha': posicionCancha,
    };
  }
}