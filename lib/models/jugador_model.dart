class Jugador {
  final int? id;
  final int? equipoId;
  final String nombre;
  final int dorsal;
  final String posicion;
  final bool esCapitan;

  Jugador({
    this.id,
    this.equipoId,
    required this.nombre,
    required this.dorsal,
    required this.posicion,
    this.esCapitan = false,
  });

  // Convierte un objeto Jugador a un Mapa para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'equipo_id': equipoId,
      'nombre': nombre,
      'dorsal': dorsal,
      'posicion': posicion,
      'esCapitan': esCapitan ? 1 : 0,
    };
  }
}