import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../models/tipo_punto.dart';

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

          // Estadísticas por jugador (calculadas en vivo con los puntos
          // detallados que se van registrando en Modo Pro)
          _SectionTitle(titulo: "Estadísticas por Jugador (Modo Pro)"),
          _EstadisticasPorJugador(partido: partido),
        ],
      ),
    );
  }
}

class _EstadisticasPorJugador extends StatelessWidget {
  final PartidoProvider partido;
  const _EstadisticasPorJugador({required this.partido});

  @override
  Widget build(BuildContext context) {
    // clave "dorsal-equipoId" -> nombre + conteo por campo de estadística
    final Map<String, String> nombres = {};
    final Map<String, Map<String, int>> stats = {};

    for (final set in partido.historialSets) {
      for (final punto in set) {
        final tipoNombre = punto['tipo'] as String?;
        final dorsal = punto['jugadorDorsal'] as int?;
        final equipoJugador = punto['jugadorEquipoId'] as int?;
        if (tipoNombre == null || dorsal == null || equipoJugador == null) continue;

        final campo = TipoPuntoInfo.fromNombre(tipoNombre).campoEstadistica;
        if (campo == null) continue;

        final clave = '$dorsal-$equipoJugador';
        nombres[clave] = (punto['jugadorNombre'] as String?) ?? 'Jugador';
        final conteo = stats.putIfAbsent(clave, () => {});
        conteo[campo] = (conteo[campo] ?? 0) + 1;
      }
    }

    if (stats.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            "Aún no hay puntos detallados. Usa la pestaña 'Modo Pro' para registrar cómo fue cada punto.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    const labels = {
      'aces': 'Aces',
      'errores_saque': 'Err. saque',
      'ataques': 'Ataques',
      'errores_ataque': 'Err. ataque',
      'bloqueos': 'Bloqueos',
      'errores_recepcion': 'Err. recep.',
    };

    return Column(
      children: stats.entries.map((entry) {
        final clave = entry.key;
        final conteo = entry.value;
        final dorsal = clave.split('-').first;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "#$dorsal ${nombres[clave]}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: labels.entries.where((l) => conteo[l.key] != null).map((l) {
                    final esNegativo = l.key.startsWith('errores_');
                    return Text(
                      "${l.value}: ${conteo[l.key]}",
                      style: TextStyle(
                        fontSize: 11,
                        color: esNegativo ? Colors.red.shade700 : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
