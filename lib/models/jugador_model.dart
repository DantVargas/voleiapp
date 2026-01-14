class Jugador {
  // 1. Propiedades
  final int? id;
  final String? nombre;
  final int dorsal;
  int posicionCancha; // QUITAMOS el 'final' aquí para poder rotar
  final String? posicionJuego; // Le ponemos '?' para que sea opcional
  final int equipoId;

  // 2. Constructor
  Jugador({
    this.id,
    this.nombre,
    required this.dorsal,
    required this.posicionCancha,
    this.posicionJuego, // Quitamos el 'required'
    required this.equipoId,
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