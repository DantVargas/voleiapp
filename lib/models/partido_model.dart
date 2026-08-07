class Partido {
  final int? id;
  final String nombreEquipoA;
  final String nombreEquipoB;
  final DateTime fecha;
  int setsA;
  int setsB;
  String estado; // 'en_curso' | 'finalizado'
  String? notas;

  Partido({
    this.id,
    required this.nombreEquipoA,
    required this.nombreEquipoB,
    required this.fecha,
    this.setsA = 0,
    this.setsB = 0,
    this.estado = 'en_curso',
    this.notas,
  });

  // Getters de utilidad
  bool get enCurso => estado == 'en_curso';
  bool get finalizado => estado == 'finalizado';
  String get resultado => '$setsA - $setsB';

  Partido copyWith({
    int? id,
    String? nombreEquipoA,
    String? nombreEquipoB,
    DateTime? fecha,
    int? setsA,
    int? setsB,
    String? estado,
    String? notas,
  }) {
    return Partido(
      id: id ?? this.id,
      nombreEquipoA: nombreEquipoA ?? this.nombreEquipoA,
      nombreEquipoB: nombreEquipoB ?? this.nombreEquipoB,
      fecha: fecha ?? this.fecha,
      setsA: setsA ?? this.setsA,
      setsB: setsB ?? this.setsB,
      estado: estado ?? this.estado,
      notas: notas ?? this.notas,
    );
  }

  factory Partido.fromMap(Map<String, dynamic> map) {
    return Partido(
      id: map['id'] as int?,
      nombreEquipoA: map['nombre_equipo_a'] as String,
      nombreEquipoB: map['nombre_equipo_b'] as String,
      fecha: DateTime.parse(map['fecha'] as String),
      setsA: map['sets_a'] as int,
      setsB: map['sets_b'] as int,
      estado: map['estado'] as String,
      notas: map['notas'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre_equipo_a': nombreEquipoA,
      'nombre_equipo_b': nombreEquipoB,
      'fecha': fecha.toIso8601String(),
      'sets_a': setsA,
      'sets_b': setsB,
      'estado': estado,
      'notas': notas,
    };
  }

  @override
  String toString() =>
      'Partido(id: $id, $nombreEquipoA vs $nombreEquipoB, $resultado, $estado)';
}