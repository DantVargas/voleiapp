class Jugador {
  // 1. Propiedades
  final int? id;
  final int? equipoId;
  final String? nombre;
  final int dorsal;
  final String posicionJuego; // central, punta, etc.
  final int posicionCancha;    // 0 = banca, 1-6 = posición en cancha

  // 2. Constructor
  Jugador({
    this.id,
    this.equipoId,
    this.nombre,
    required this.dorsal,
    required this.posicionJuego,
    required this.posicionCancha,
  });

  // 3. Métodos de Conversión (JSON/Map)
  factory Jugador.fromMap(Map<String, dynamic> map) {
    return Jugador(
      id: map['id'],
      equipoId: map['equipo_id'],
      nombre: map['nombre'],
      dorsal: map['dorsal'],
      posicionJuego: map['posicion_juego'],
      posicionCancha: map['posicion_cancha'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipo_id': equipoId,
      'nombre': nombre,
      'dorsal': dorsal,
      'posicion_juego': posicionJuego,
      'posicion_cancha': posicionCancha,
    };
  }

  // 4. Getters y Lógica de Negocio
  bool get esSuplente => posicionCancha == 0;

  Jugador entrarACancha(int nuevaPosicion) {
    return Jugador(
      id: id,
      equipoId: equipoId,
      nombre: nombre,
      dorsal: dorsal,
      posicionJuego: posicionJuego,
      posicionCancha: nuevaPosicion,
    );
  }
}