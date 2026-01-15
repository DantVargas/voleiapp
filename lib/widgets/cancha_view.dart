import 'package:flutter/material.dart';
import '../models/jugador_model.dart';

class CanchaView extends StatelessWidget {
  final List<Jugador> jugadores;
  final Function(Jugador) onJugadorTap;

  const CanchaView({
    super.key, 
    required this.jugadores, 
    required this.onJugadorTap
  });

  // Coordenadas fijas para la vista
  static const Map<int, Offset> posicionesEquipoA = {
    4: Offset(0.38, 0.22), 3: Offset(0.38, 0.50), 2: Offset(0.38, 0.78),
    5: Offset(0.15, 0.22), 6: Offset(0.15, 0.50), 1: Offset(0.15, 0.78),
  };

  static const Map<int, Offset> posicionesEquipoB = {
    2: Offset(0.62, 0.22), 3: Offset(0.62, 0.50), 4: Offset(0.62, 0.78),
    1: Offset(0.85, 0.22), 6: Offset(0.85, 0.50), 5: Offset(0.85, 0.78),
  };

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/cancha.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.orange.shade400),
                    ),
                  ),
                ),
                Center(child: Container(width: 2, color: Colors.white70)),
                ...jugadores.where((j) => j.posicionCancha > 0).map((j) {
                  final config = j.equipoId == 1 ? posicionesEquipoA : posicionesEquipoB;
                  final offset = config[j.posicionCancha] ?? const Offset(0, 0);

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    left: offset.dx * w - 22,
                    top: offset.dy * h - 28,
                    child: _buildFicha(j),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFicha(Jugador j) {
    return GestureDetector(
      onTap: () => onJugadorTap(j),
      child: Column(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: j.equipoId == 1 ? Colors.blue : Colors.red,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            alignment: Alignment.center,
            child: Text("${j.dorsal}", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
            child: Text(j.nombre ?? "", 
              style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}