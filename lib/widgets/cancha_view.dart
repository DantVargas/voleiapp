import 'package:flutter/material.dart';
import '../models/jugador_model.dart';

class CanchaView extends StatelessWidget {
  final List<Jugador> jugadores;

  const CanchaView({super.key, required this.jugadores});

  // ===== COORDENADAS PRECISAS (X, Y) =====
  // Equipo A (Azul - Izquierda): Red está en X = 0.5
  static const Map<int, Offset> posicionesEquipoA = {
    4: Offset(0.38, 0.25), // Ataque Arriba
    3: Offset(0.38, 0.50), // Ataque Centro
    2: Offset(0.38, 0.75), // Ataque Abajo
    5: Offset(0.15, 0.25), // Defensa Arriba
    6: Offset(0.15, 0.50), // Defensa Centro
    1: Offset(0.15, 0.75), // Defensa Abajo (Saque)
  };

  // Equipo B (Rojo - Derecha): Red está en X = 0.5
  static const Map<int, Offset> posicionesEquipoB = {
    2: Offset(0.62, 0.25), // Ataque Arriba
    3: Offset(0.62, 0.50), // Ataque Centro
    4: Offset(0.62, 0.75), // Ataque Abajo
    1: Offset(0.85, 0.25), // Defensa Arriba (Saque)
    6: Offset(0.85, 0.50), // Defensa Centro
    5: Offset(0.85, 0.75), // Defensa Abajo
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2, // Mantiene la forma de la cancha
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Stack(
              children: [
                // FONDO
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/cancha.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          Container(color: Colors.orange.shade300), // Si no carga la imagen
                    ),
                  ),
                ),
                // RED VISUAL CENTRAL
                Center(child: Container(width: 4, color: Colors.white70)),

                // JUGADORES
                ...jugadores.map((j) => _buildJugador(j, width, height)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJugador(Jugador j, double width, double height) {
    final posiciones = j.equipoId == 1 ? posicionesEquipoA : posicionesEquipoB;
    final offset = posiciones[j.posicionCancha];
    
    if (offset == null) return const SizedBox();

    return Positioned(
      left: offset.dx * width,
      top: offset.dy * height,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5), // Centra exactamente la ficha
        child: _camiseta(j),
      ),
    );
  }

  Widget _camiseta(Jugador j) {
    final color = j.equipoId == 1 ? Colors.blue : Colors.red;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 4)],
          ),
          alignment: Alignment.center,
          child: Text(
            "${j.dorsal}",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Text(
          j.nombre ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ],
    );
  }
}