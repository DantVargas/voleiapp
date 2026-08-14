import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../models/partido_model.dart';
import 'partido_detalle_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  List<Partido> _partidos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() => _cargando = true);
    try {
      final rows = await ApiClient().obtenerPartidos();
      setState(() {
        _partidos = rows.map(Partido.fromMap).toList();
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo conectar con el servidor")),
        );
      }
    }
  }

  Future<void> _eliminarPartido(Partido partido) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar partido"),
        content: Text(
          "¿Eliminar ${partido.nombreEquipoA} vs ${partido.nombreEquipoB}?\nEsta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancelar")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmar == true && partido.id != null) {
      try {
        await ApiClient().eliminarPartido(partido.id!);
        _cargarPartidos();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No se pudo eliminar: revisá tu conexión")),
          );
        }
      }
    }
  }

  Future<void> _abrirDetalle(Partido partido) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PartidoDetalleScreen(partidoId: partido.id!),
      ),
    );
    _cargarPartidos(); // recarga por si editaron notas o stats
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial de Partidos"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarPartidos,
            tooltip: "Recargar",
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _partidos.isEmpty
              ? _buildEstadoVacio()
              : RefreshIndicator(
                  onRefresh: _cargarPartidos,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: _partidos.length,
                    itemBuilder: (context, i) => _buildCardPartido(_partidos[i]),
                  ),
                ),
    );
  }

  Widget _buildEstadoVacio() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_volleyball, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No hay partidos guardados",
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4),
          Text(
            "Guardá un partido desde la pantalla de Cancha",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPartido(Partido partido) {
    final ganoA = partido.setsA > partido.setsB;
    final esFinalizado = partido.finalizado;
    final fecha = _formatFecha(partido.fecha);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirDetalle(partido),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Indicador de color del ganador
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: esFinalizado
                      ? (ganoA ? Colors.blue : Colors.red)
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),

              // Info central
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          partido.nombreEquipoA,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: ganoA && esFinalizado ? Colors.blue : Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "${partido.setsA} - ${partido.setsB}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        Text(
                          partido.nombreEquipoB,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: !ganoA && esFinalizado ? Colors.red : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          fecha,
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        if (partido.notas != null && partido.notas!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.notes, size: 12, color: Colors.grey),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Badge de estado
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: esFinalizado ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: esFinalizado ? Colors.green.shade200 : Colors.orange.shade200,
                      ),
                    ),
                    child: Text(
                      esFinalizado ? "Finalizado" : "En curso",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: esFinalizado ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _eliminarPartido(partido),
                    child: Icon(Icons.delete_outline, size: 18, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year;
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return "$dia/$mes/$anio  $hora:$min";
  }
}
