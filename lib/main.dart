import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/jugador_model.dart';
import 'widgets/cancha_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(const MaterialApp(
      home: CanchaPage(),
      debugShowCheckedModeBanner: false,
    ));
  });
}

class CanchaPage extends StatefulWidget {
  const CanchaPage({super.key});
  @override
  State<CanchaPage> createState() => _CanchaPageState();
}

class _CanchaPageState extends State<CanchaPage> {
  // --- ESTADO DEL PARTIDO ---
  bool partidoEmpezado = false;
  bool mostrarSorteo = false;
  
  int puntosA = 0;
  int puntosB = 0;
  int setsGanadosA = 0; 
  int setsGanadosB = 0;
  int? equipoQueSaca;

  final List<Map<String, dynamic>> _historial = [];

  List<Jugador> todosLosJugadores = [
    Jugador(dorsal: 1, posicionCancha: 4, nombre: 'Punta 1', equipoId: 1),
    Jugador(dorsal: 2, posicionCancha: 3, nombre: 'Central 1', equipoId: 1),
    Jugador(dorsal: 5, posicionCancha: 2, nombre: 'Armador', equipoId: 1),
    Jugador(dorsal: 6, posicionCancha: 6, nombre: 'Central 2', equipoId: 1),
    Jugador(dorsal: 7, posicionCancha: 1, nombre: 'Punta 2', equipoId: 1),
    Jugador(dorsal: 8, posicionCancha: 5, nombre: 'Opuesto', equipoId: 1),
    Jugador(dorsal: 99, posicionCancha: 0, nombre: 'Suplente A1', equipoId: 1),
    Jugador(dorsal: 98, posicionCancha: 0, nombre: 'Libero A', equipoId: 1),
    Jugador(dorsal: 3, posicionCancha: 4, nombre: 'Punta 1', equipoId: 2),
    Jugador(dorsal: 4, posicionCancha: 3, nombre: 'Central 1', equipoId: 2),
    Jugador(dorsal: 9, posicionCancha: 2, nombre: 'Armador', equipoId: 2),
    Jugador(dorsal: 10, posicionCancha: 6, nombre: 'Libero B', equipoId: 2),
    Jugador(dorsal: 11, posicionCancha: 1, nombre: 'Punta 2', equipoId: 2),
    Jugador(dorsal: 12, posicionCancha: 5, nombre: 'Opuesto', equipoId: 2),
    Jugador(dorsal: 20, posicionCancha: 0, nombre: 'Suplente B1', equipoId: 2),
  ];

  // --- LÓGICA ---
  void _guardarEstado() {
    final posicionesClonadas = todosLosJugadores.map((j) => j.posicionCancha).toList();
    _historial.add({
      'puntosA': puntosA,
      'puntosB': puntosB,
      'equipoQueSaca': equipoQueSaca,
      'posiciones': posicionesClonadas,
      'partidoEmpezado': partidoEmpezado,
    });
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    final estadoPrevio = _historial.removeLast();
    setState(() {
      puntosA = estadoPrevio['puntosA'];
      puntosB = estadoPrevio['puntosB'];
      equipoQueSaca = estadoPrevio['equipoQueSaca'];
      partidoEmpezado = estadoPrevio['partidoEmpezado'];
      final posiciones = estadoPrevio['posiciones'] as List<int>;
      for (int i = 0; i < todosLosJugadores.length; i++) {
        todosLosJugadores[i].posicionCancha = posiciones[i];
      }
    });
  }

  void _sumarPunto(int id) {
    if (!partidoEmpezado) return;
    _guardarEstado();
    setState(() {
      if (id == 1) {
        puntosA++;
        if (equipoQueSaca == 2) _rotar(1);
        equipoQueSaca = 1;
      } else {
        puntosB++;
        if (equipoQueSaca == 1) _rotar(2);
        equipoQueSaca = 2;
      }
    });
  }

  void _rotar(int id) {
    final mapa = {1: 6, 6: 5, 5: 4, 4: 3, 3: 2, 2: 1};
    for (var j in todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha != 0)) {
      j.posicionCancha = mapa[j.posicionCancha]!;
    }
  }

  // --- INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Voley Manager", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 45,
        leading: IconButton(
          icon: const Icon(Icons.undo, color: Colors.blueGrey),
          onPressed: _historial.isNotEmpty ? _deshacer : null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.blueGrey),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EstadisticasPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.redAccent),
            onPressed: () => _reiniciarConfirmacion(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildModernScoreboard(),
            if (!partidoEmpezado)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => mostrarSorteo = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("EMPEZAR PARTIDO", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  _buildBancaLateral(1, "Banca A", Colors.blue),
                  Expanded(
                    child: Stack(
                      children: [
                        Center(
                          child: CanchaView(
                            jugadores: todosLosJugadores,
                            onJugadorTap: _mostrarOpcionesJugador,
                          ),
                        ),
                        if (mostrarSorteo) _buildOverlaySorteo(),
                      ],
                    ),
                  ),
                  _buildBancaLateral(2, "Banca B", Colors.red),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DEL MARCADOR ---

  Widget _buildModernScoreboard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          _buildScoreGroup(
            teamName: "EQUIPO A",
            points: puntosA,
            color: Colors.blue,
            isServing: equipoQueSaca == 1,
            onAdd: () => _sumarPunto(1),
          ),
          const SizedBox(width: 40), 
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SET", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
              Text("1", style: TextStyle(color: Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(width: 40), 
          _buildScoreGroup(
            teamName: "EQUIPO B",
            points: puntosB,
            color: Colors.red,
            isServing: equipoQueSaca == 2,
            onAdd: () => _sumarPunto(2),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreGroup({
    required String teamName,
    required int points,
    required Color color,
    required bool isServing,
    required VoidCallback onAdd,
  }) {
    bool isTeamA = teamName == "EQUIPO A";
    return Row(
      children: [
        if (!isTeamA) _buildAddButton(onAdd, color),
        const SizedBox(width: 12),
        Column(
          children: [
            Row(
              children: [
                if (isServing && isTeamA) const Icon(Icons.sports_volleyball, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(teamName, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(width: 4),
                if (isServing && !isTeamA) const Icon(Icons.sports_volleyball, color: Colors.orange, size: 16),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Text(
                "$points",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        if (isTeamA) _buildAddButton(onAdd, color),
      ],
    );
  }

  Widget _buildAddButton(VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: partidoEmpezado ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: partidoEmpezado ? color : Colors.grey.shade300,
          shape: BoxShape.circle,
          boxShadow: partidoEmpezado ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 4)] : [],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  // --- OTROS COMPONENTES ---

  Widget _buildBancaLateral(int id, String titulo, Color color) {
    final lista = todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha == 0).toList();
    return Container(
      width: 130,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            width: double.infinity,
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(7))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _agregarJugadorBanca(id),
                  child: const Icon(Icons.add_circle, color: Colors.white, size: 16),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                dense: true,
                visualDensity: VisualDensity.compact,
                leading: CircleAvatar(
                  radius: 10, 
                  backgroundColor: color.withOpacity(0.1), 
                  child: Text("${lista[i].dorsal}", style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))
                ),
                title: Text(lista[i].nombre ?? "", style: const TextStyle(fontSize: 10)),
                onTap: () => _mostrarOpcionesJugador(lista[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlaySorteo() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Sorteo Inicial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("¿Quién saca primero?", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () => setState(() { equipoQueSaca = 1; partidoEmpezado = true; mostrarSorteo = false; }),
                      child: const Text("Saca A", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => setState(() { equipoQueSaca = 2; partidoEmpezado = true; mostrarSorteo = false; }),
                      child: const Text("Saca B", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                TextButton(onPressed: () => setState(() => mostrarSorteo = false), child: const Text("Cancelar"))
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _reiniciarConfirmacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reiniciar"),
        content: const Text("¿Quieres volver a 0-0 y reiniciar el sorteo?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(onPressed: () {
            setState(() { puntosA = 0; puntosB = 0; equipoQueSaca = null; partidoEmpezado = false; _historial.clear(); });
            Navigator.pop(context);
          }, child: const Text("Sí")),
        ],
      ),
    );
  }

  // --- GESTIÓN DE JUGADORES (CRUD) ---

  void _mostrarOpcionesJugador(Jugador j) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Text("Opciones: #${j.dorsal} ${j.nombre}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.orange),
            title: const Text("Editar jugador"),
            onTap: () { Navigator.pop(context); _dialogoEditarJugador(j); },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.green),
            title: Text(j.posicionCancha == 0 ? "Entrar a cancha" : "Mandar a banca"),
            onTap: () { Navigator.pop(context); _seleccionarCambio(j); },
          ),
          if (j.posicionCancha == 0)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Eliminar", style: TextStyle(color: Colors.red)),
              onTap: () { Navigator.pop(context); _eliminarJugador(j); },
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _dialogoEditarJugador(Jugador j) {
    final cN = TextEditingController(text: j.nombre);
    final cD = TextEditingController(text: j.dorsal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Editar #${j.dorsal}"),
        content: Column(
          mainAxisSize: MainAxisSize.min, 
          children: [
            TextField(controller: cN, decoration: const InputDecoration(labelText: "Nombre"), textCapitalization: TextCapitalization.words),
            TextField(controller: cD, decoration: const InputDecoration(labelText: "Dorsal"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              setState(() { j.nombre = cN.text; j.dorsal = int.tryParse(cD.text) ?? j.dorsal; });
              Navigator.pop(context);
            }, 
            child: const Text("Guardar")
          )
        ],
      ),
    );
  }

  void _seleccionarCambio(Jugador jSel) {
    final bool esS = jSel.posicionCancha == 0;
    final lista = todosLosJugadores.where((j) => j.equipoId == jSel.equipoId && (esS ? j.posicionCancha != 0 : j.posicionCancha == 0)).toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(esS ? "Entra por..." : "Sale por..."),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(backgroundColor: jSel.equipoId == 1 ? Colors.blue : Colors.red, child: Text("${lista[i].dorsal}", style: const TextStyle(color: Colors.white, fontSize: 12))),
              title: Text(lista[i].nombre ?? ""),
              onTap: () {
                _guardarEstado();
                setState(() {
                  int pos = esS ? lista[i].posicionCancha : jSel.posicionCancha;
                  if (esS) { lista[i].posicionCancha = 0; jSel.posicionCancha = pos; }
                  else { jSel.posicionCancha = 0; lista[i].posicionCancha = pos; }
                });
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _agregarJugadorBanca(int id) {
    final cN = TextEditingController();
    final cD = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nuevo Suplente"),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: cN, decoration: const InputDecoration(labelText: "Nombre"), textCapitalization: TextCapitalization.words),
          TextField(controller: cD, decoration: const InputDecoration(labelText: "Dorsal"), keyboardType: TextInputType.number),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
          ElevatedButton(onPressed: () {
            setState(() => todosLosJugadores.add(Jugador(nombre: cN.text, dorsal: int.tryParse(cD.text) ?? 0, posicionCancha: 0, equipoId: id)));
            Navigator.pop(context);
          }, child: const Text("Agregar"))
        ],
      ),
    );
  }

  void _eliminarJugador(Jugador j) {
    setState(() => todosLosJugadores.remove(j));
  }
}

class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas")),
      body: const Center(child: Text("Módulo de Estadísticas Próximamente")),
    );
  }
}