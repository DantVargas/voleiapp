import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';

class MarcadorWidget extends StatelessWidget {
  const MarcadorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // EQUIPO A
          _buildSeccionEquipo(
            nombre: partido.nombreEquipoA,
            puntos: partido.puntosA,
            color: Colors.blue,
            onAdd: () => partido.sumarPunto(1),
            esIzquierda: true,
            tieneSaque: partido.equipoQueSaca == 1,
          ),

          // INFO CENTRAL (Sets y Marcador de Sets)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "S${partido.setActual} | ${partido.setsGanadosA}-${partido.setsGanadosB}",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),

          // EQUIPO B
          _buildSeccionEquipo(
            nombre: partido.nombreEquipoB,
            puntos: partido.puntosB,
            color: Colors.red,
            onAdd: () => partido.sumarPunto(2),
            esIzquierda: false,
            tieneSaque: partido.equipoQueSaca == 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionEquipo({
    required String nombre,
    required int puntos,
    required Color color,
    required VoidCallback onAdd,
    required bool esIzquierda,
    required bool tieneSaque,
  }) {
    // Widgets base
    final widgetNombre = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tieneSaque && !esIzquierda) ...[
          const Icon(Icons.sports_volleyball, size: 16, color: Colors.orange),
          const SizedBox(width: 4),
        ],
        Text(
          nombre.length > 10 ? "${nombre.substring(0, 8)}." : nombre,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
        if (tieneSaque && esIzquierda) ...[
          const SizedBox(width: 4),
          const Icon(Icons.sports_volleyball, size: 16, color: Colors.orange),
        ],
      ],
    );

    final widgetPuntos = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Text(
        "$puntos",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
      ),
    );

    final widgetBotonSuma = GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 16),
      ),
    );

    // Organizamos según el lado
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: esIzquierda
          ? [
              widgetBotonSuma,
              const SizedBox(width: 10),
              widgetPuntos,
              const SizedBox(width: 10),
              widgetNombre,
            ]
          : [
              widgetNombre,
              const SizedBox(width: 10),
              widgetPuntos,
              const SizedBox(width: 10),
              widgetBotonSuma,
            ],
    );
  }
}