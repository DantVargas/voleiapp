import 'package:flutter/material.dart';

/// Fase del rally en la que terminó el punto:
/// K1 = ataque tras la recepción del saque, K2 = contraataque tras defender
/// ese K1, K3/K4 = transiciones siguientes, K5+ = rally largo.
/// Solo aplica a jugadas que involucran un intercambio (ataque, bloqueo,
/// error de ataque/recepción rival) — un ace o error de saque terminan el
/// punto antes de que exista un K.
class ComplejoPunto {
  static const Map<int, String> labels = {1: 'K1', 2: 'K2', 3: 'K3', 4: 'K4', 5: 'K5+'};

  static const Map<int, String> descripciones = {
    1: 'Ataque tras recepción del saque',
    2: 'Contraataque tras defender el K1',
    3: 'Tercer ataque del rally',
    4: 'Cuarto ataque del rally',
    5: 'Rally largo (5 o más)',
  };

  static const Map<int, Color> colores = {
    1: Color(0xFF86B6EF),
    2: Color(0xFF5598E7),
    3: Color(0xFF2A78D6),
    4: Color(0xFF1C5CAB),
    5: Color(0xFF104281),
  };

  static const List<int> valores = [1, 2, 3, 4, 5];
}
