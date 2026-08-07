import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Resumen de sets
          _SectionTitle(titulo: "Resumen de Sets"),
          ...List.generate(partido.historialSets.length, (i) {
            final set = partido.historialSets[i];
            if (set.isEmpty) return const SizedBox.shrink();

            final puntosA = set.where((p) => p['equipo'] == 1).length;
            final puntosB = set.where((p) => p['equipo'] == 2).length;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(
                  "Set ${i + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  "$puntosA - $puntosB",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Placeholder estadísticas por jugador
          _SectionTitle(titulo: "Estadísticas por Jugador"),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Próximamente: aces, errores, bloqueos, recepciones...",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String titulo;
  const _SectionTitle({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
