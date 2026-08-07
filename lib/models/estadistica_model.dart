class Estadistica {
  final int? id;
  final int partidoId;
  final String jugadorNombre;
  final int dorsal;
  final int equipoId;
  int aces;
  int erroresSaque;
  int ataques;
  int erroresAtaque;
  int bloqueos;
  int recepciones;
  int erroresRecepcion;

  Estadistica({
    this.id,
    required this.partidoId,
    required this.jugadorNombre,
    required this.dorsal,
    required this.equipoId,
    this.aces = 0,
    this.erroresSaque = 0,
    this.ataques = 0,
    this.erroresAtaque = 0,
    this.bloqueos = 0,
    this.recepciones = 0,
    this.erroresRecepcion = 0,
  });

  int get totalPositivos => aces + ataques + bloqueos;
  int get totalNegativos => erroresSaque + erroresAtaque + erroresRecepcion;

  Estadistica copyWith({
    int? id,
    int? partidoId,
    String? jugadorNombre,
    int? dorsal,
    int? equipoId,
    int? aces,
    int? erroresSaque,
    int? ataques,
    int? erroresAtaque,
    int? bloqueos,
    int? recepciones,
    int? erroresRecepcion,
  }) {
    return Estadistica(
      id: id ?? this.id,
      partidoId: partidoId ?? this.partidoId,
      jugadorNombre: jugadorNombre ?? this.jugadorNombre,
      dorsal: dorsal ?? this.dorsal,
      equipoId: equipoId ?? this.equipoId,
      aces: aces ?? this.aces,
      erroresSaque: erroresSaque ?? this.erroresSaque,
      ataques: ataques ?? this.ataques,
      erroresAtaque: erroresAtaque ?? this.erroresAtaque,
      bloqueos: bloqueos ?? this.bloqueos,
      recepciones: recepciones ?? this.recepciones,
      erroresRecepcion: erroresRecepcion ?? this.erroresRecepcion,
    );
  }

  factory Estadistica.fromMap(Map<String, dynamic> map) {
    return Estadistica(
      id: map['id'] as int?,
      partidoId: map['partido_id'] as int,
      jugadorNombre: map['jugador_nombre'] as String,
      dorsal: map['dorsal'] as int? ?? 0,
      equipoId: map['equipo_id'] as int,
      aces: map['aces'] as int? ?? 0,
      erroresSaque: map['errores_saque'] as int? ?? 0,
      ataques: map['ataques'] as int? ?? 0,
      erroresAtaque: map['errores_ataque'] as int? ?? 0,
      bloqueos: map['bloqueos'] as int? ?? 0,
      recepciones: map['recepciones'] as int? ?? 0,
      erroresRecepcion: map['errores_recepcion'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'partido_id': partidoId,
      'jugador_nombre': jugadorNombre,
      'dorsal': dorsal,
      'equipo_id': equipoId,
      'aces': aces,
      'errores_saque': erroresSaque,
      'ataques': ataques,
      'errores_ataque': erroresAtaque,
      'bloqueos': bloqueos,
      'recepciones': recepciones,
      'errores_recepcion': erroresRecepcion,
    };
  }
}
