import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_manager.dart';
import '../models/partido_model.dart';
import '../provider/ajustes_provider.dart';
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
    final rows = await DBManager().obtenerPartidos();
    setState(() {
      _partidos = rows.map(Partido.fromMap).toList();
      _cargando = false;
    });
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
      await DBManager().eliminarPartido(partido.id!);
      _cargarPartidos();
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
    final escala = context.watch<AjustesProvider>().escalaUI;
    return Scaffold(
      appBar: AppBar(
        title: Text("Historial de Partidos", style: TextStyle(fontSize: 20 * escala)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 24 * escala),
            onPressed: _cargarPartidos,
            tooltip: "Recargar",
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _partidos.isEmpty
              ? _buildEstadoVacio(escala)
              : RefreshIndicator(
                  onRefresh: _cargarPartidos,
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 12 * escala, vertical: 8 * escala),
                    itemCount: _partidos.length,
                    itemBuilder: (context, i) => _buildCardPartido(_partidos[i], escala),
                  ),
                ),
    );
  }

  Widget _buildEstadoVacio(double escala) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sports_volleyball, size: 60 * escala, color: Colors.grey),
          SizedBox(height: 12 * escala),
          Text(
            "No hay partidos guardados",
            style: TextStyle(fontSize: 16 * escala, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 4 * escala),
          Text(
            "Guardá un partido desde la pantalla de Cancha",
            style: TextStyle(fontSize: 12 * escala, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCardPartido(Partido partido, double escala) {
    final ganoA = partido.setsA > partido.setsB;
    final esFinalizado = partido.finalizado;
    final fecha = _formatFecha(partido.fecha);

    return Card(
      margin: EdgeInsets.only(bottom: 8 * escala),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrirDetalle(partido),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14 * escala, vertical: 10 * escala),
          child: Row(
            children: [
              // Indicador de color del ganador
              Container(
                width: 4 * escala,
                height: 50 * escala,
                decoration: BoxDecoration(
                  color: esFinalizado
                      ? (ganoA ? Colors.blue : Colors.red)
                      : Colors.orange,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 12 * escala),

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
                            fontSize: 13 * escala,
                            color: ganoA && esFinalizado ? Colors.blue : Colors.black87,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8 * escala),
                          child: Text(
                            "${partido.setsA} - ${partido.setsB}",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16 * escala,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                        Text(
                          partido.nombreEquipoB,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13 * escala,
                            color: !ganoA && esFinalizado ? Colors.red : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4 * escala),
                    Row(
                      children: [
                        Text(
                          fecha,
                          style: TextStyle(fontSize: 11 * escala, color: Colors.grey),
                        ),
                        if (partido.notas != null && partido.notas!.isNotEmpty) ...[
                          SizedBox(width: 8 * escala),
                          Icon(Icons.notes, size: 12 * escala, color: Colors.grey),
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
                    padding: EdgeInsets.symmetric(horizontal: 8 * escala, vertical: 3 * escala),
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
                        fontSize: 9 * escala,
                        fontWeight: FontWeight.bold,
                        color: esFinalizado ? Colors.green.shade700 : Colors.orange.shade700,
                      ),
                    ),
                  ),
                  SizedBox(height: 6 * escala),
                  GestureDetector(
                    onTap: () => _eliminarPartido(partido),
                    child: Icon(Icons.delete_outline, size: 18 * escala, color: Colors.grey.shade400),
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
