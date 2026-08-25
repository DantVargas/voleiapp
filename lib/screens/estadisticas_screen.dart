import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../provider/ajustes_provider.dart';
import '../models/tipo_punto.dart';
import '../models/complejo_punto.dart';
import '../widgets/grafico_porcentaje_widget.dart';

class EstadisticasScreen extends StatelessWidget {
  const EstadisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();
    final escala = context.watch<AjustesProvider>().escalaUI;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7),
      appBar: AppBar(
        title: Text("Estadísticas", style: TextStyle(fontSize: 20 * escala)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        elevation: 0.5,
      ),
      body: ListView(
        padding: EdgeInsets.all(16 * escala),
        children: [
          const _SectionTitle(titulo: "Resumen de sets"),
          _ResumenSets(historialSets: partido.historialSets),
          SizedBox(height: 22 * escala),

          const _SectionTitle(titulo: "Distribución de puntos por tipo"),
          _DistribucionPorTipo(partido: partido),
          SizedBox(height: 22 * escala),

          const _SectionTitle(titulo: "Distribución por complejo (K)"),
          _CardContenedor(
            child: GraficoPorcentaje(
              segmentos: _segmentosComplejo(partido),
              textoVacio: "Aún no hay jugadas de rally con su K registrado.",
            ),
          ),
          SizedBox(height: 22 * escala),

          const _SectionTitle(titulo: "Estadísticas por jugador"),
          _EstadisticasPorJugador(partido: partido),
        ],
      ),
    );
  }

  List<SegmentoGrafico> _segmentosComplejo(PartidoProvider partido) {
    final conteo = <int, int>{};
    for (final set in partido.historialSets) {
      for (final punto in set) {
        final k = punto['complejo'] as int?;
        if (k == null) continue;
        conteo[k] = (conteo[k] ?? 0) + 1;
      }
    }
    return ComplejoPunto.valores
        .map((k) => SegmentoGrafico(
              label: ComplejoPunto.labels[k]!,
              valor: conteo[k] ?? 0,
              color: ComplejoPunto.colores[k]!,
            ))
        .toList();
  }
}

/// Contenedor blanco con borde suave — unidad visual base de la pantalla.
class _CardContenedor extends StatelessWidget {
  final Widget child;
  const _CardContenedor({required this.child});

  @override
  Widget build(BuildContext context) {
    final escala = context.watch<AjustesProvider>().escalaUI;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * escala),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String titulo;
  const _SectionTitle({required this.titulo});

  @override
  Widget build(BuildContext context) {
    final escala = context.watch<AjustesProvider>().escalaUI;
    return Padding(
      padding: EdgeInsets.only(bottom: 10 * escala),
      child: Text(
        titulo,
        style: TextStyle(
          fontSize: 13 * escala,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0B0B0B),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

/// Tira horizontal compacta con el resultado de cada set jugado.
class _ResumenSets extends StatelessWidget {
  final List<List<Map<String, dynamic>>> historialSets;
  const _ResumenSets({required this.historialSets});

  @override
  Widget build(BuildContext context) {
    final escala = context.watch<AjustesProvider>().escalaUI;
    final tarjetas = <Widget>[];
    for (int i = 0; i < historialSets.length; i++) {
      final set = historialSets[i];
      if (set.isEmpty) continue;
      final puntosA = set.where((p) => p['equipo'] == 1).length;
      final puntosB = set.where((p) => p['equipo'] == 2).length;
      tarjetas.add(Container(
        margin: EdgeInsets.only(right: 8 * escala),
        padding: EdgeInsets.symmetric(horizontal: 16 * escala, vertical: 10 * escala),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SET ${i + 1}",
              style: TextStyle(fontSize: 9 * escala, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 3 * escala),
            Text(
              "$puntosA - $puntosB",
              style: TextStyle(fontSize: 16 * escala, fontWeight: FontWeight.w900, color: Colors.blueGrey),
            ),
          ],
        ),
      ));
    }

    if (tarjetas.isEmpty) {
      return _CardContenedor(
        child: Text(
          "Todavía no hay sets jugados.",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12 * escala),
        ),
      );
    }

    return SizedBox(
      height: 60 * escala,
      child: ListView(scrollDirection: Axis.horizontal, children: tarjetas),
    );
  }
}

/// Barra apilada con la distribución de "cómo fue el punto", con selector
/// de equipo (los porcentajes se calculan solo sobre los puntos con detalle
/// de Modo Pro).
class _DistribucionPorTipo extends StatefulWidget {
  final PartidoProvider partido;
  const _DistribucionPorTipo({required this.partido});

  @override
  State<_DistribucionPorTipo> createState() => _DistribucionPorTipoState();
}

class _DistribucionPorTipoState extends State<_DistribucionPorTipo> {
  int _equipoSeleccionado = 1;

  @override
  Widget build(BuildContext context) {
    final partido = widget.partido;
    final escala = context.watch<AjustesProvider>().escalaUI;
    final conteo = <TipoPunto, int>{};

    for (final set in partido.historialSets) {
      for (final punto in set) {
        if (punto['equipo'] != _equipoSeleccionado) continue;
        final tipoNombre = punto['tipo'] as String?;
        if (tipoNombre == null) continue;
        final tipo = TipoPuntoInfo.fromNombre(tipoNombre);
        conteo[tipo] = (conteo[tipo] ?? 0) + 1;
      }
    }

    final segmentos = TipoPunto.values
        .map((t) => SegmentoGrafico(label: t.labelCorto, valor: conteo[t] ?? 0, color: t.colorCategoria))
        .toList();

    return _CardContenedor(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _botonEquipo(1, partido.nombreEquipoA, escala)),
              SizedBox(width: 8 * escala),
              Expanded(child: _botonEquipo(2, partido.nombreEquipoB, escala)),
            ],
          ),
          SizedBox(height: 16 * escala),
          GraficoPorcentaje(
            segmentos: segmentos,
            textoVacio: "Aún no hay puntos detallados para este equipo.\nUsa la pestaña 'Modo Pro' para registrarlos.",
          ),
        ],
      ),
    );
  }

  Widget _botonEquipo(int equipoId, String nombre, double escala) {
    final activo = _equipoSeleccionado == equipoId;
    return GestureDetector(
      onTap: () => setState(() => _equipoSeleccionado = equipoId),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8 * escala),
        decoration: BoxDecoration(
          color: activo ? Colors.blueGrey.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activo ? Colors.blueGrey : Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          nombre,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12 * escala,
            fontWeight: FontWeight.bold,
            color: activo ? Colors.blueGrey.shade800 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

/// Estadísticas por jugador (calculadas en vivo con los puntos detallados
/// que se van registrando en Modo Pro), en tarjetas con badges por tipo.
class _EstadisticasPorJugador extends StatelessWidget {
  final PartidoProvider partido;
  const _EstadisticasPorJugador({required this.partido});

  @override
  Widget build(BuildContext context) {
    final escala = context.watch<AjustesProvider>().escalaUI;
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
      return _CardContenedor(
        child: Text(
          "Aún no hay puntos detallados. Usa la pestaña 'Modo Pro' para registrar cómo fue cada punto.",
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12 * escala),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: stats.entries.map((entry) {
        final clave = entry.key;
        final conteo = entry.value;
        final dorsal = clave.split('-').first;

        return Container(
          margin: EdgeInsets.only(bottom: 8 * escala),
          padding: EdgeInsets.all(12 * escala),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "#$dorsal ${nombres[clave]}",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13 * escala),
              ),
              SizedBox(height: 8 * escala),
              Wrap(
                spacing: 8 * escala,
                runSpacing: 6 * escala,
                children: conteo.entries.map((e) {
                  final tipo = _tipoPorCampo(e.key);
                  final color = tipo?.colorCategoria ?? Colors.grey;
                  final label = tipo?.labelCorto ?? e.key;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8 * escala, vertical: 4 * escala),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8 * escala,
                          height: 8 * escala,
                          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                        ),
                        SizedBox(width: 5 * escala),
                        Text(
                          "$label ${e.value}",
                          style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.w700, color: const Color(0xFF52514E)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  TipoPunto? _tipoPorCampo(String campo) {
    for (final t in TipoPunto.values) {
      if (t.campoEstadistica == campo) return t;
    }
    return null;
  }
}