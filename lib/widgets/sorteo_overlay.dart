import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../provider/ajustes_provider.dart';

class SorteoOverlay extends StatelessWidget {
  const SorteoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();
    final escala = context.watch<AjustesProvider>().escalaUI;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 40 * escala, vertical: 10 * escala),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: EdgeInsets.all(15 * escala),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400 * escala),
              child: SingleChildScrollView( // <--- AGREGADO PARA PODER HACER SCROLL
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "CONFIGURACIÓN INICIAL",
                      style: TextStyle(fontSize: 14 * escala, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const Divider(),

                    // Fila de Ajustes (Sets y Cambios)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<int>(
                            label: "Sets máx:",
                            value: partido.maxSets,
                            items: const [3, 5],
                            onChanged: (val) => context.read<PartidoProvider>().cambiarMaxSets(val!),
                            escala: escala,
                          ),
                        ),
                        SizedBox(width: 20 * escala),
                        Expanded(
                          child: _buildDropdown<int>(
                            label: "Cambios máx:",
                            value: partido.cambiosMaximos,
                            items: const [6, 12, 15],
                            onChanged: (val) => context.read<PartidoProvider>().configurarPartido(
                              maxCambios: val!,
                              maxTiempos: partido.tiemposMuertosA
                            ),
                            escala: escala,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15 * escala),
                    Text(
                      "¿Quién saca primero?",
                      style: TextStyle(fontSize: 12 * escala, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    SizedBox(height: 10 * escala),

                    // Botones de Saque
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _botonSaque(
                          context,
                          id: 1,
                          nombre: partido.nombreEquipoA,
                          color: Colors.blue,
                          escala: escala,
                        ),
                        SizedBox(width: 10 * escala),
                        _botonSaque(
                          context,
                          id: 2,
                          nombre: partido.nombreEquipoB,
                          color: Colors.red,
                          escala: escala,
                        ),
                      ],
                    ),

                    SizedBox(height: 10 * escala),
                    TextButton(
                      onPressed: () => context.read<PartidoProvider>().cerrarSorteo(),
                      child: Text("CANCELAR", style: TextStyle(color: Colors.grey, fontSize: 11 * escala)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para los dropdowns
  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    required double escala,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10 * escala, color: Colors.grey)),
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: TextStyle(fontSize: 13 * escala, color: Colors.black, fontWeight: FontWeight.bold),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Widget auxiliar para los botones de saque
  Widget _botonSaque(BuildContext context, {required int id, required String nombre, required Color color, required double escala}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12 * escala, vertical: 8 * escala),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => context.read<PartidoProvider>().iniciarPartido(id),
      child: Text("Saca $nombre", style: TextStyle(fontSize: 11 * escala)),
    );
  }
}