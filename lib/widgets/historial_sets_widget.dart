import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../provider/ajustes_provider.dart';

class HistorialSetsWidget extends StatefulWidget {
  const HistorialSetsWidget({super.key});

  @override
  State<HistorialSetsWidget> createState() => _HistorialSetsWidgetState();
}

class _HistorialSetsWidgetState extends State<HistorialSetsWidget> {
  final ScrollController _scrollController = ScrollController();
  int _ultimoConteo = 0;

  void _scrollToEnd() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();
    final escala = context.watch<AjustesProvider>().escalaUI;
    final historialSets = partido.historialSets;
    final setActualIdx = partido.setActual - 1;
    final conteoActual = historialSets[setActualIdx].length;

    // Solo hacemos scroll cuando llega un nuevo punto
    if (conteoActual != _ultimoConteo) {
      _ultimoConteo = conteoActual;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Etiqueta fija del Set actual
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0 * escala),
            child: Text(
              "S${partido.setActual}:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 10 * escala,
                color: Colors.blueGrey,
              ),
            ),
          ),

          // Área de scroll de los balones
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: historialSets[setActualIdx].length,
              itemBuilder: (context, i) {
                final punto = historialSets[setActualIdx][i];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 1.5 * escala),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Número del punto
                      Text(
                        "${i + 1}",
                        style: TextStyle(fontSize: 7 * escala, color: Colors.grey),
                      ),
                      // Icono del balón
                      Icon(
                        Icons.sports_volleyball,
                        size: 15 * escala, // Un pelín más pequeño para evitar cortes
                        color: punto['equipo'] == 1 ? Colors.blue : Colors.red,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}