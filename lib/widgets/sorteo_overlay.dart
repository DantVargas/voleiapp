import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';

class SorteoOverlay extends StatelessWidget {
  const SorteoOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();

    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: SingleChildScrollView( // <--- AGREGADO PARA PODER HACER SCROLL
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "CONFIGURACIÓN INICIAL",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                    ),
                    const Divider(),

                    // Fila de Ajustes (Sets y Cambios)
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<int>(
                            label: "Sets máx:",
                            value: partido.maxSets,
                            items: [3, 5],
                            onChanged: (val) => context.read<PartidoProvider>().cambiarMaxSets(val!),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: _buildDropdown<int>(
                            label: "Cambios máx:",
                            value: partido.cambiosMaximos,
                            items: [6, 12, 15],
                            onChanged: (val) => context.read<PartidoProvider>().configurarPartido(
                              maxCambios: val!, 
                              maxTiempos: partido.tiemposMuertosA
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),
                    const Text(
                      "¿Quién saca primero?",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),

                    // Botones de Saque
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _botonSaque(
                          context, 
                          id: 1, 
                          nombre: partido.nombreEquipoA, 
                          color: Colors.blue
                        ),
                        const SizedBox(width: 10),
                        _botonSaque(
                          context, 
                          id: 2, 
                          nombre: partido.nombreEquipoB, 
                          color: Colors.red
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => context.read<PartidoProvider>().cerrarSorteo(),
                      child: const Text("CANCELAR", style: TextStyle(color: Colors.grey, fontSize: 11)),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        DropdownButton<T>(
          value: value,
          isExpanded: true,
          style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Widget auxiliar para los botones de saque
  Widget _botonSaque(BuildContext context, {required int id, required String nombre, required Color color}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () => context.read<PartidoProvider>().iniciarPartido(id),
      child: Text("Saca $nombre", style: const TextStyle(fontSize: 11)),
    );
  }
}