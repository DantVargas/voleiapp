import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../database/db_manager.dart';
import '../models/partido_model.dart';
import '../models/set_model.dart';
import '../models/estadistica_model.dart';
import '../provider/ajustes_provider.dart';

class PartidoDetalleScreen extends StatefulWidget {
  final int partidoId;

  const PartidoDetalleScreen({super.key, required this.partidoId});

  @override
  State<PartidoDetalleScreen> createState() => _PartidoDetalleScreenState();
}

class _PartidoDetalleScreenState extends State<PartidoDetalleScreen> {
  Partido? _partido;
  List<SetPartido> _sets = [];
  List<Estadistica> _stats = [];
  bool _cargando = true;
  final _db = DBManager();

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final pMap = await _db.obtenerPartido(widget.partidoId);
    final sRows = await _db.obtenerSetsPorPartido(widget.partidoId);
    final eRows = await _db.obtenerEstadisticasPorPartido(widget.partidoId);
    setState(() {
      _partido = pMap != null ? Partido.fromMap(pMap) : null;
      _sets = sRows.map(SetPartido.fromMap).toList();
      _stats = eRows.map(Estadistica.fromMap).toList();
      _cargando = false;
    });
  }

  // -------------------------------------------------------
  // EDICIÓN DE NOTAS / NOMBRES
  // -------------------------------------------------------
  void _editarCabecera() {
    if (_partido == null) return;
    final ctrlA = TextEditingController(text: _partido!.nombreEquipoA);
    final ctrlB = TextEditingController(text: _partido!.nombreEquipoB);
    final ctrlNotas = TextEditingController(text: _partido!.notas ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar partido"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrlA,
                decoration: const InputDecoration(labelText: "Equipo A", prefixIcon: Icon(Icons.circle, color: Colors.blue, size: 12)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrlB,
                decoration: const InputDecoration(labelText: "Equipo B", prefixIcon: Icon(Icons.circle, color: Colors.red, size: 12)),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: ctrlNotas,
                decoration: const InputDecoration(labelText: "Notas", hintText: "Comentarios, observaciones..."),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              await _db.actualizarPartido(widget.partidoId, {
                'nombre_equipo_a': ctrlA.text.trim().isNotEmpty ? ctrlA.text.trim() : _partido!.nombreEquipoA,
                'nombre_equipo_b': ctrlB.text.trim().isNotEmpty ? ctrlB.text.trim() : _partido!.nombreEquipoB,
                'notas': ctrlNotas.text.trim().isNotEmpty ? ctrlNotas.text.trim() : null,
              });
              if (ctx.mounted) Navigator.pop(ctx);
              _cargarDatos();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // EDICIÓN DE SETS
  // -------------------------------------------------------
  void _editarSet(SetPartido set) {
    final ctrlA = TextEditingController(text: '${set.puntosA}');
    final ctrlB = TextEditingController(text: '${set.puntosB}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Editar Set ${set.numeroSet}"),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ctrlA,
                decoration: InputDecoration(labelText: _partido?.nombreEquipoA ?? 'Equipo A'),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("-", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: TextField(
                controller: ctrlB,
                decoration: InputDecoration(labelText: _partido?.nombreEquipoB ?? 'Equipo B'),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () async {
              final pA = int.tryParse(ctrlA.text) ?? set.puntosA;
              final pB = int.tryParse(ctrlB.text) ?? set.puntosB;
              await _db.actualizarPuntosSet(set.id!, pA, pB);
              if (ctx.mounted) Navigator.pop(ctx);
              _cargarDatos();
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------
  // ESTADÍSTICAS: EDITAR JUGADOR
  // -------------------------------------------------------
  void _editarStats(Estadistica e) {
    final Map<String, int> valores = {
      'aces': e.aces,
      'errores_saque': e.erroresSaque,
      'ataques': e.ataques,
      'errores_ataque': e.erroresAtaque,
      'bloqueos': e.bloqueos,
      'recepciones': e.recepciones,
      'errores_recepcion': e.erroresRecepcion,
    };
    final labels = {
      'aces': 'Aces',
      'errores_saque': 'Errores de saque',
      'ataques': 'Ataques (kills)',
      'errores_ataque': 'Errores de ataque',
      'bloqueos': 'Bloqueos',
      'recepciones': 'Recepciones',
      'errores_recepcion': 'Errores de recepción',
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text(
            "#${e.dorsal} ${e.jugadorNombre}",
            style: const TextStyle(fontSize: 15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: valores.keys.map((key) {
                final isNegativo = key.startsWith('errores_');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          labels[key]!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isNegativo ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                      ),
                      _botonContador(
                        valor: valores[key]!,
                        onMenos: () => setS(() => valores[key] = (valores[key]! - 1).clamp(0, 999)),
                        onMas: () => setS(() => valores[key] = valores[key]! + 1),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final confirmar = await showDialog<bool>(
                  context: ctx,
                  builder: (c) => AlertDialog(
                    title: const Text("Eliminar jugador"),
                    content: Text("¿Quitar a ${e.jugadorNombre} del historial?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("No")),
                      TextButton(
                        onPressed: () => Navigator.pop(c, true),
                        child: const Text("Sí", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
                if (confirmar == true && e.id != null) {
                  await _db.eliminarEstadistica(e.id!);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _cargarDatos();
                }
              },
              child: const Text("Eliminar", style: TextStyle(color: Colors.red, fontSize: 12)),
            ),
            ElevatedButton(
              onPressed: () async {
                await _db.actualizarEstadistica(e.id!, {
                  'aces': valores['aces'],
                  'errores_saque': valores['errores_saque'],
                  'ataques': valores['ataques'],
                  'errores_ataque': valores['errores_ataque'],
                  'bloqueos': valores['bloqueos'],
                  'recepciones': valores['recepciones'],
                  'errores_recepcion': valores['errores_recepcion'],
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _cargarDatos();
              },
              child: const Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // ESTADÍSTICAS: AGREGAR JUGADOR
  // -------------------------------------------------------
  void _agregarJugador() {
    final ctrlNombre = TextEditingController();
    final ctrlDorsal = TextEditingController();
    int equipoSeleccionado = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text("Agregar jugador"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ctrlNombre,
                  decoration: const InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: ctrlDorsal,
                  decoration: const InputDecoration(labelText: "Dorsal"),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Equipo:", style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(_partido?.nombreEquipoA ?? 'A'),
                      selected: equipoSeleccionado == 1,
                      selectedColor: Colors.blue.shade100,
                      onSelected: (_) => setS(() => equipoSeleccionado = 1),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(_partido?.nombreEquipoB ?? 'B'),
                      selected: equipoSeleccionado == 2,
                      selectedColor: Colors.red.shade100,
                      onSelected: (_) => setS(() => equipoSeleccionado = 2),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
            ElevatedButton(
              onPressed: () async {
                if (ctrlNombre.text.trim().isEmpty) return;
                await _db.insertarEstadistica({
                  'partido_id': widget.partidoId,
                  'jugador_nombre': ctrlNombre.text.trim(),
                  'dorsal': int.tryParse(ctrlDorsal.text) ?? 0,
                  'equipo_id': equipoSeleccionado,
                  'aces': 0,
                  'errores_saque': 0,
                  'ataques': 0,
                  'errores_ataque': 0,
                  'bloqueos': 0,
                  'recepciones': 0,
                  'errores_recepcion': 0,
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _cargarDatos();
              },
              child: const Text("Agregar"),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------
  // WIDGET CONTADOR +/-
  // -------------------------------------------------------
  Widget _botonContador({required int valor, required VoidCallback onMenos, required VoidCallback onMas}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: onMenos,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 26, height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.remove, size: 14),
          ),
        ),
        Container(
          width: 32,
          alignment: Alignment.center,
          child: Text('$valor', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
        InkWell(
          onTap: onMas,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 26, height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add, size: 14),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------
  // BUILD
  // -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_partido == null) {
      return const Scaffold(body: Center(child: Text("Partido no encontrado")));
    }

    final escala = context.watch<AjustesProvider>().escalaUI;
    const colorA = Colors.blue;
    const colorB = Colors.red;
    final ganoA = _partido!.setsA > _partido!.setsB;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "${_partido!.nombreEquipoA} vs ${_partido!.nombreEquipoB}",
          style: TextStyle(fontSize: 14 * escala),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 24 * escala),
            tooltip: "Editar partido",
            onPressed: _editarCabecera,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarJugador,
        icon: Icon(Icons.person_add, size: 24 * escala),
        label: Text("Agregar jugador", style: TextStyle(fontSize: 14 * escala)),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(12 * escala, 12 * escala, 12 * escala, 80 * escala),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA ---
            _buildCabecera(ganoA, colorA, colorB, escala),
            SizedBox(height: 12 * escala),

            // --- SETS ---
            _buildSeccion("Resultado por Set", Icons.format_list_numbered, escala),
            SizedBox(height: 6 * escala),
            ..._sets.map((s) => _buildFilaSet(s, escala)),
            if (_sets.isEmpty)
              Padding(
                padding: EdgeInsets.all(8 * escala),
                child: Text("Sin sets registrados", style: TextStyle(color: Colors.grey, fontSize: 14 * escala)),
              ),
            SizedBox(height: 16 * escala),

            // --- NOTAS ---
            if (_partido!.notas != null && _partido!.notas!.isNotEmpty) ...[
              _buildSeccion("Notas", Icons.notes, escala),
              SizedBox(height: 6 * escala),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12 * escala),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(_partido!.notas!, style: TextStyle(fontSize: 13 * escala, color: Colors.black87)),
              ),
              SizedBox(height: 16 * escala),
            ],

            // --- ESTADÍSTICAS ---
            _buildSeccion("Estadísticas por Jugador", Icons.bar_chart, escala),
            SizedBox(height: 6 * escala),

            // Equipo A
            if (_stats.any((e) => e.equipoId == 1)) ...[
              _buildSubtituloEquipo(_partido!.nombreEquipoA, colorA, escala),
              SizedBox(height: 4 * escala),
              _buildTablaStats(_stats.where((e) => e.equipoId == 1).toList(), escala),
              SizedBox(height: 12 * escala),
            ],

            // Equipo B
            if (_stats.any((e) => e.equipoId == 2)) ...[
              _buildSubtituloEquipo(_partido!.nombreEquipoB, colorB, escala),
              SizedBox(height: 4 * escala),
              _buildTablaStats(_stats.where((e) => e.equipoId == 2).toList(), escala),
            ],

            if (_stats.isEmpty)
              Padding(
                padding: EdgeInsets.all(8 * escala),
                child: Text(
                  "Sin estadísticas. Usá el botón para agregar jugadores.",
                  style: TextStyle(color: Colors.grey, fontSize: 14 * escala),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCabecera(bool ganoA, Color colorA, Color colorB, double escala) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * escala, vertical: 14 * escala),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(_partido!.nombreEquipoA,
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorA, fontSize: 14 * escala)),
                if (ganoA)
                  Container(
                    margin: EdgeInsets.only(top: 2 * escala),
                    padding: EdgeInsets.symmetric(horizontal: 6 * escala, vertical: 1 * escala),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("GANADOR", style: TextStyle(fontSize: 8 * escala, color: Colors.blue, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            Text(
              "${_partido!.setsA} - ${_partido!.setsB}",
              style: TextStyle(fontSize: 32 * escala, fontWeight: FontWeight.w900, color: Colors.blueGrey),
            ),
            Column(
              children: [
                Text(_partido!.nombreEquipoB,
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorB, fontSize: 14 * escala)),
                if (!ganoA)
                  Container(
                    margin: EdgeInsets.only(top: 2 * escala),
                    padding: EdgeInsets.symmetric(horizontal: 6 * escala, vertical: 1 * escala),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("GANADOR", style: TextStyle(fontSize: 8 * escala, color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilaSet(SetPartido set, double escala) {
    final ganoA = set.puntosA > set.puntosB;
    return Card(
      margin: EdgeInsets.only(bottom: 4 * escala),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      color: Colors.white,
      child: ListTile(
        dense: true,
        title: Text("Set ${set.numeroSet}", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13 * escala)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${set.puntosA} - ${set.puntosB}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16 * escala,
                color: ganoA ? Colors.blue : Colors.red,
              ),
            ),
            SizedBox(width: 8 * escala),
            IconButton(
              icon: Icon(Icons.edit_outlined, size: 16 * escala),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _editarSet(set),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTablaStats(List<Estadistica> stats, double escala) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Encabezado
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * escala, vertical: 6 * escala),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            ),
            child: Row(
              children: [
                SizedBox(width: 28 * escala, child: Text("#", style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                Expanded(child: Text("Jugador", style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                SizedBox(width: 30 * escala, child: Text("ACE", textAlign: TextAlign.center, style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.green))),
                SizedBox(width: 30 * escala, child: Text("ATQ", textAlign: TextAlign.center, style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.green))),
                SizedBox(width: 30 * escala, child: Text("BLQ", textAlign: TextAlign.center, style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.green))),
                SizedBox(width: 30 * escala, child: Text("REC", textAlign: TextAlign.center, style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.blueGrey))),
                SizedBox(width: 30 * escala, child: Text("ERR", textAlign: TextAlign.center, style: TextStyle(fontSize: 10 * escala, fontWeight: FontWeight.bold, color: Colors.red))),
              ],
            ),
          ),

          // Filas de jugadores
          ...stats.asMap().entries.map((entry) {
            final i = entry.key;
            final e = entry.value;
            return InkWell(
              onTap: () => _editarStats(e),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12 * escala, vertical: 8 * escala),
                decoration: BoxDecoration(
                  border: i < stats.length - 1
                      ? Border(bottom: BorderSide(color: Colors.grey.shade100))
                      : null,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28 * escala,
                      child: Text(
                        "${e.dorsal}",
                        style: TextStyle(fontSize: 11 * escala, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Text(e.jugadorNombre, style: TextStyle(fontSize: 11 * escala, fontWeight: FontWeight.w500)),
                    ),
                    _celdaStat(e.aces, Colors.green, escala),
                    _celdaStat(e.ataques, Colors.green, escala),
                    _celdaStat(e.bloqueos, Colors.green, escala),
                    _celdaStat(e.recepciones, Colors.blueGrey, escala),
                    _celdaStat(e.totalNegativos, Colors.red, escala),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _celdaStat(int valor, Color color, double escala) {
    return SizedBox(
      width: 30 * escala,
      child: Text(
        "$valor",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12 * escala,
          fontWeight: valor > 0 ? FontWeight.bold : FontWeight.normal,
          color: valor > 0 ? color : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, IconData icono, double escala) {
    return Row(
      children: [
        Icon(icono, size: 16 * escala, color: Colors.blueGrey),
        SizedBox(width: 6 * escala),
        Text(
          titulo,
          style: TextStyle(fontSize: 13 * escala, fontWeight: FontWeight.bold, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildSubtituloEquipo(String nombre, Color color, double escala) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * escala, vertical: 3 * escala),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        nombre,
        style: TextStyle(fontSize: 11 * escala, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}
