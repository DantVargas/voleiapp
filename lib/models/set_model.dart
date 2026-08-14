class SetPartido {
  final int? id;
  final int partidoId;
  final int numeroSet;
  int puntosA;
  int puntosB;

  SetPartido({
    this.id,
    required this.partidoId,
    required this.numeroSet,
    this.puntosA = 0,
    this.puntosB = 0,
  });

  // Getters de utilidad
  bool get ganaA => puntosA > puntosB;
  bool get ganaB => puntosB > puntosA;
  String get resultado => '$puntosA - $puntosB';

  SetPartido copyWith({
    int? id,
    int? partidoId,
    int? numeroSet,
    int? puntosA,
    int? puntosB,
  }) {
    return SetPartido(
      id: id ?? this.id,
      partidoId: partidoId ?? this.partidoId,
      numeroSet: numeroSet ?? this.numeroSet,
      puntosA: puntosA ?? this.puntosA,
      puntosB: puntosB ?? this.puntosB,
    );
  }

  factory SetPartido.fromMap(Map<String, dynamic> map) {
    return SetPartido(
      id: map['id'] as int?,
      partidoId: map['partido_id'] as int,
      numeroSet: map['numero_set'] as int,
      puntosA: map['puntos_a'] as int,
      puntosB: map['puntos_b'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'partido_id': partidoId,
      'numero_set': numeroSet,
      'puntos_a': puntosA,
      'puntos_b': puntosB,
    };
  }

  @override
  String toString() =>
      'SetPartido(id: $id, partido: $partidoId, set $numeroSet, $resultado)';
}