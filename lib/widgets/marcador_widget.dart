import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../provider/ajustes_provider.dart';

class MarcadorWidget extends StatelessWidget {
  /// Si se provee, se llama en vez de `partido.sumarPunto(equipoId)` al
  /// tocar el botón "+" — usado por Modo Pro para abrir el selector de
  /// tipo de punto / jugador antes de anotar.
  final void Function(int equipoId)? onPuntoPersonalizado;

  const MarcadorWidget({super.key, this.onPuntoPersonalizado});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();
    final escala = context.watch<AjustesProvider>().escalaUI;

    return Container(
      height: 50 * escala,
      padding: EdgeInsets.symmetric(horizontal: 10 * escala),
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
            onAdd: () => onPuntoPersonalizado != null ? onPuntoPersonalizado!(1) : partido.sumarPunto(1),
            esIzquierda: true,
            tieneSaque: partido.equipoQueSaca == 1,
            escala: escala,
          ),

          // INFO CENTRAL (Sets y Marcador de Sets)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * escala, vertical: 4 * escala),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              "S${partido.setActual} | ${partido.setsGanadosA}-${partido.setsGanadosB}",
              style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
          ),

          // EQUIPO B
          _buildSeccionEquipo(
            nombre: partido.nombreEquipoB,
            puntos: partido.puntosB,
            color: Colors.red,
            onAdd: () => onPuntoPersonalizado != null ? onPuntoPersonalizado!(2) : partido.sumarPunto(2),
            esIzquierda: false,
            tieneSaque: partido.equipoQueSaca == 2,
            escala: escala,
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
    required double escala,
  }) {
    // Widgets base
    final widgetNombre = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (tieneSaque && !esIzquierda) ...[
          Icon(Icons.sports_volleyball, size: 16 * escala, color: Colors.orange),
          SizedBox(width: 4 * escala),
        ],
        Text(
          nombre.length > 10 ? "${nombre.substring(0, 8)}." : nombre,
          style: TextStyle(fontSize: 11 * escala, fontWeight: FontWeight.bold),
        ),
        if (tieneSaque && esIzquierda) ...[
          SizedBox(width: 4 * escala),
          Icon(Icons.sports_volleyball, size: 16 * escala, color: Colors.orange),
        ],
      ],
    );

    final widgetPuntos = Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * escala, vertical: 4 * escala),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Text(
        "$puntos",
        style: TextStyle(fontSize: 20 * escala, fontWeight: FontWeight.bold, color: color),
      ),
    );

    final widgetBotonSuma = GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: EdgeInsets.all(8 * escala),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(Icons.add, color: Colors.white, size: 16 * escala),
      ),
    );

    // Organizamos según el lado
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: esIzquierda
          ? [
              widgetBotonSuma,
              SizedBox(width: 10 * escala),
              widgetPuntos,
              SizedBox(width: 10 * escala),
              widgetNombre,
            ]
          : [
              widgetNombre,
              SizedBox(width: 10 * escala),
              widgetPuntos,
              SizedBox(width: 10 * escala),
              widgetBotonSuma,
            ],
    );
  }
}
