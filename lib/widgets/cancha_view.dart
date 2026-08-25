import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/jugador_model.dart';
import '../provider/ajustes_provider.dart';

class CanchaView extends StatelessWidget {
  final List<Jugador> jugadores;
  final Function(Jugador) onJugadorTap;

  const CanchaView({
    super.key,
    required this.jugadores,
    required this.onJugadorTap,
  });

  static const Map<int, Offset> posicionesEquipoA = {
    4: Offset(0.38, 0.22), 3: Offset(0.38, 0.50), 2: Offset(0.38, 0.78),
    5: Offset(0.15, 0.22), 6: Offset(0.15, 0.50), 1: Offset(0.15, 0.78),
  };

  static const Map<int, Offset> posicionesEquipoB = {
    2: Offset(0.62, 0.22), 3: Offset(0.62, 0.50), 4: Offset(0.62, 0.78),
    1: Offset(0.85, 0.22), 6: Offset(0.85, 0.50), 5: Offset(0.85, 0.78),
  };

  // Ahora recibe el mapa explícitamente en vez de depender del equipoId
  static Map<int, Offset> _posicionesPara(int equipoId) {
    return equipoId == 1 ? posicionesEquipoA : posicionesEquipoB;
  }

  @override
  Widget build(BuildContext context) {
    final escala = context.watch<AjustesProvider>().escalaUI;

    // Proporción ~2:1 (parecida a una cancha real de 18x9m vista de arriba
    // con ambos lados juntos) — en el modo horizontal forzado del celular
    // aprovecha mejor el ancho disponible que una proporción más cuadrada.
    return AspectRatio(
      aspectRatio: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Tamaño de ficha proporcional al espacio real de la cancha, así
          // se ve y se toca cómodo tanto en un celular chico como en una
          // tablet o una ventana de escritorio grande — y además ajustado
          // por la escala elegida en Ajustes.
          final circulo = (w * 0.095).clamp(34.0, 58.0) * escala;
          final fichaWidth = circulo + 12 * escala;
          final fichaHeight = circulo + 20 * escala;

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Stack(
              children: [
                // Fondo cancha
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/cancha.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.orange.shade400),
                    ),
                  ),
                ),

                // Línea/red central
                Center(
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 2)],
                    ),
                  ),
                ),

                // Fichas de jugadores en cancha
                ...jugadores.where((j) => j.estaEnCancha).map((j) {
                  final posiciones = _posicionesPara(j.equipoId);
                  final offset = posiciones[j.posicionCancha];

                  // Si no hay offset válido, no renderizar
                  if (offset == null) return const SizedBox.shrink();

                  return AnimatedPositioned(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutBack,
                    left: offset.dx * w - fichaWidth / 2,
                    top: offset.dy * h - fichaHeight / 2,
                    child: _buildFicha(j, circulo, escala),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFicha(Jugador j, double circulo, double escala) {
    final color = j.equipoId == 1 ? Colors.blue : Colors.red;

    return GestureDetector(
      onTap: () => onJugadorTap(j),
      // Área táctil mínima cómoda aunque el círculo dibujado sea chico.
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circulo,
              height: circulo,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              alignment: Alignment.center,
              child: Text(
                '${j.dorsal}',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: circulo * 0.36),
              ),
            ),
            SizedBox(height: 2 * escala),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4 * escala, vertical: 1 * escala),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                j.nombre ?? '',
                style: TextStyle(
                    fontSize: 9 * escala,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}