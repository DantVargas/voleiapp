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
  int? equipoQueSaca;

  // Configuración
  int maxSets = 3; 
  int puntosParaGanarSet = 25;
  int puntosParaGanarUltimoSet = 15;
  bool modoMataMata = false; 

  // Estado de Sets
  int setsGanadosA = 0;
  int setsGanadosB = 0;
  int setActual = 1;

  String nombreEquipoA = "EQUIPO A";
  String nombreEquipoB = "EQUIPO B";

  // Historial Estructurado
  List<List<Map<String, dynamic>>> historialSets = [[]]; 
  final List<Map<String, dynamic>> _historial = [];

  List<Jugador> todosLosJugadores = [
    Jugador(dorsal: 1, posicionCancha: 4, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 2, posicionCancha: 3, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 5, posicionCancha: 2, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 6, posicionCancha: 6, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 7, posicionCancha: 1, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 8, posicionCancha: 5, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 99, posicionCancha: 0, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 98, posicionCancha: 0, nombre: 'Jugador', equipoId: 1),
    Jugador(dorsal: 3, posicionCancha: 4, nombre: 'Jugador', equipoId: 2),
    Jugador(dorsal: 4, posicionCancha: 3, nombre: 'Jugador', equipoId: 2),
    Jugador(dorsal: 9, posicionCancha: 2, nombre: 'Jugador', equipoId: 2),
    Jugador(dorsal: 10, posicionCancha: 6, nombre: 'Jugador', equipoId: 2),
    Jugador(dorsal: 11, posicionCancha: 1, nombre: 'Jugador', equipoId: 2),
    Jugador(dorsal: 12, posicionCancha: 5, nombre: 'Jugador', equipoId: 2),
    Jugador(dorsal: 20, posicionCancha: 0, nombre: 'Jugador', equipoId: 2),
  ];

  // --- LÓGICA ---

  void _guardarEstado() {
    final posicionesClonadas = todosLosJugadores.map((j) => j.posicionCancha).toList();
    _historial.add({
      'puntosA': puntosA,
      'puntosB': puntosB,
      'setsGanadosA': setsGanadosA,
      'setsGanadosB': setsGanadosB,
      'setActual': setActual,
      'equipoQueSaca': equipoQueSaca,
      'posiciones': posicionesClonadas,
      'partidoEmpezado': partidoEmpezado,
      'historialSets': historialSets.map((set) => List<Map<String, dynamic>>.from(set)).toList(),
    });
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    final estadoPrevio = _historial.removeLast();
    setState(() {
      puntosA = estadoPrevio['puntosA'];
      puntosB = estadoPrevio['puntosB'];
      setsGanadosA = estadoPrevio['setsGanadosA'];
      setsGanadosB = estadoPrevio['setsGanadosB'];
      setActual = estadoPrevio['setActual'];
      equipoQueSaca = estadoPrevio['equipoQueSaca'];
      partidoEmpezado = estadoPrevio['partidoEmpezado'];
      historialSets = List<List<Map<String, dynamic>>>.from(
        estadoPrevio['historialSets'].map((s) => List<Map<String, dynamic>>.from(s))
      );
      final posiciones = estadoPrevio['posiciones'] as List<int>;
      for (int i = 0; i < todosLosJugadores.length; i++) {
        todosLosJugadores[i].posicionCancha = posiciones[i];
      }
    });
    if (Navigator.canPop(context)) Navigator.pop(context);
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

      historialSets[setActual - 1].add({'equipo': id, 'marcador': "$puntosA - $puntosB"});

      int metaPuntos = (setActual == maxSets) ? puntosParaGanarUltimoSet : puntosParaGanarSet;
      bool setTerminado = modoMataMata 
          ? (puntosA >= metaPuntos || puntosB >= metaPuntos)
          : ((puntosA >= metaPuntos || puntosB >= metaPuntos) && (puntosA - puntosB).abs() >= 2);

      if (setTerminado) _finalizarSet(puntosA > puntosB ? 1 : 2);
    });
  }

  void _finalizarSet(int ganadorId) {
    if (ganadorId == 1) setsGanadosA++; else setsGanadosB++;
    int setsParaGanar = (maxSets / 2).ceil();
    if (setsGanadosA >= setsParaGanar || setsGanadosB >= setsParaGanar) {
      _mostrarFinPartido(ganadorId == 1 ? nombreEquipoA : nombreEquipoB);
    } else {
      _mostrarAvisoSet(ganadorId == 1 ? nombreEquipoA : nombreEquipoB);
    }
  }

  void _rotar(int id) {
    final mapa = {1: 6, 6: 5, 5: 4, 4: 3, 3: 2, 2: 1};
    for (var j in todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha != 0)) {
      j.posicionCancha = mapa[j.posicionCancha]!;
    }
  }

  // --- DIÁLOGOS ---

  void _mostrarAvisoSet(String ganador) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text("Set para $ganador"),
        content: const Text("El marcador se reiniciará para el siguiente set."),
        actions: [
          TextButton(onPressed: _deshacer, child: const Text("CORREGIR", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () {
              _guardarEstado();
              setState(() {
                puntosA = 0; puntosB = 0; setActual++;
                if (historialSets.length < setActual) historialSets.add([]);
                
                int saqueInicialPartido = _historial.firstWhere((h) => h['equipoQueSaca'] != null)['equipoQueSaca'];
                equipoQueSaca = (setActual % 2 != 0) ? saqueInicialPartido : (saqueInicialPartido == 1 ? 2 : 1);
              });
              Navigator.pop(context);
            },
            child: const Text("Siguiente Set"),
          )
        ],
      ),
    );
  }

  void _mostrarFinPartido(String ganador) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("¡FIN DEL PARTIDO!"),
        content: Text("Ganador: $ganador\nResultado: $setsGanadosA - $setsGanadosB"),
        actions: [
          TextButton(onPressed: _deshacer, child: const Text("CORREGIR", style: TextStyle(color: Colors.red))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _reiniciarTodo();
            },
            child: const Text("Guardar y Salir"),
          )
        ],
      ),
    );
  }

  void _reiniciarTodo() {
    setState(() {
      puntosA = 0; puntosB = 0;
      setsGanadosA = 0; setsGanadosB = 0;
      setActual = 1;
      partidoEmpezado = false;
      historialSets = [[]]; // Limpieza total del historial visual
      _historial.clear();
      equipoQueSaca = null;
      mostrarSorteo = false;
    });
  }

  // --- INTERFAZ ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Voley Manager", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: true,
        toolbarHeight: 45,
        leading: IconButton(
          icon: const Icon(Icons.undo, color: Colors.blueGrey),
          onPressed: _historial.isNotEmpty ? _deshacer : null,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart, color: Colors.blueGrey), onPressed: () {}),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.redAccent), onPressed: _reiniciarConfirmacion),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildModernScoreboard(),
            _buildHistorialPorSets(), // Historial mejorado con números
            if (!partidoEmpezado)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => mostrarSorteo = true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("EMPEZAR PARTIDO"),
                ),
              ),
            Expanded(
              child: Row(
                children: [
                  _buildBancaLateral(1, "Banca A", Colors.blue),
                  Expanded(
                    child: Stack(
                      children: [
                        Center(child: CanchaView(jugadores: todosLosJugadores, onJugadorTap: (j) {})),
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

  Widget _buildHistorialPorSets() {
    return Container(
      height: 75, // Ajustado para dar espacio a los números
      color: Colors.white,
      child: ListView.builder(
        itemCount: historialSets.length,
        itemBuilder: (context, setIndex) {
          if (historialSets[setIndex].isEmpty && setIndex != setActual - 1) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("S${setIndex + 1}: ", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Colors.blueGrey)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fila de números guía
                        Row(
                          children: List.generate(historialSets[setIndex].length, (i) => 
                            SizedBox(
                              width: 18, 
                              child: Text("${i + 1}", style: const TextStyle(fontSize: 7, color: Colors.grey), textAlign: TextAlign.center)
                            )
                          ),
                        ),
                        // Fila de balones
                        Row(
                          children: historialSets[setIndex].map((punto) => 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Icon(Icons.sports_volleyball, size: 16, color: punto['equipo'] == 1 ? Colors.blue : Colors.red),
                            )
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
          _buildScoreGroup(nombreEquipoA, puntosA, Colors.blue, equipoQueSaca == 1, () => _sumarPunto(1), true),
          const SizedBox(width: 40), 
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("SET", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 10)),
              Text("$setActual", style: TextStyle(color: Colors.grey.shade800, fontSize: 20, fontWeight: FontWeight.w900)),
              Text("$setsGanadosA - $setsGanadosB", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 4),
              _buildModoBoton(),
            ],
          ),
          const SizedBox(width: 40), 
          _buildScoreGroup(nombreEquipoB, puntosB, Colors.red, equipoQueSaca == 2, () => _sumarPunto(2), false),
        ],
      ),
    );
  }

  Widget _buildModoBoton() {
    return GestureDetector(
      onTap: () => setState(() => modoMataMata = !modoMataMata),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: modoMataMata ? Colors.orange.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: modoMataMata ? Colors.orange : Colors.grey.shade300),
        ),
        child: Text(modoMataMata ? "ORO" : "NORMAL", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: modoMataMata ? Colors.orange : Colors.grey)),
      ),
    );
  }

  Widget _buildScoreGroup(String name, int pts, Color color, bool saca, VoidCallback onAdd, bool isA) {
    return Row(
      children: [
        if (!isA) _buildAddButton(onAdd, color),
        const SizedBox(width: 12),
        Column(
          children: [
            GestureDetector(
              onTap: () => _dialogoEditarNombreEquipo(isA),
              child: Row(
                children: [
                  if (saca && isA) const Icon(Icons.sports_volleyball, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(name, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(width: 4),
                  if (saca && !isA) const Icon(Icons.sports_volleyball, color: Colors.orange, size: 16),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text("$pts", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: color)),
            ),
          ],
        ),
        const SizedBox(width: 12),
        if (isA) _buildAddButton(onAdd, color),
      ],
    );
  }

  Widget _buildAddButton(VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: partidoEmpezado ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: partidoEmpezado ? color : Colors.grey.shade300, shape: BoxShape.circle),
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildBancaLateral(int id, String titulo, Color color) {
    final lista = todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha == 0).toList();
    return Container(
      width: 130, margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6), width: double.infinity,
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(7))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                const Icon(Icons.add_circle, color: Colors.white, size: 16)
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                dense: true, visualDensity: VisualDensity.compact,
                leading: CircleAvatar(radius: 10, backgroundColor: color.withOpacity(0.1), child: Text("${lista[i].dorsal}", style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
                title: Text(lista[i].nombre ?? "", style: const TextStyle(fontSize: 10)),
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
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Configuración Inicial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Sets máximos:"),
                    DropdownButton<int>(
                      value: maxSets,
                      items: [3, 5].map((e) => DropdownMenuItem(value: e, child: Text("$e"))).toList(),
                      onChanged: (val) => setState(() => maxSets = val!),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("¿Quién saca primero?", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue), onPressed: () => setState(() { equipoQueSaca = 1; partidoEmpezado = true; mostrarSorteo = false; }), child: Text("Saca $nombreEquipoA")),
                    const SizedBox(width: 10),
                    ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red), onPressed: () => setState(() { equipoQueSaca = 2; partidoEmpezado = true; mostrarSorteo = false; }), child: Text("Saca $nombreEquipoB")),
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

  void _dialogoEditarNombreEquipo(bool esA) {
    final controller = TextEditingController(text: esA ? nombreEquipoA : nombreEquipoB);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nombre del equipo"),
        content: TextField(controller: controller, textCapitalization: TextCapitalization.characters),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(onPressed: () { setState(() { if (esA) nombreEquipoA = controller.text; else nombreEquipoB = controller.text; }); Navigator.pop(context); }, child: const Text("Guardar")),
        ],
      ),
    );
  }

  void _reiniciarConfirmacion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reiniciar"),
        content: const Text("¿Quieres volver a 0-0?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(onPressed: () { _reiniciarTodo(); Navigator.pop(context); }, child: const Text("Sí")),
        ],
      ),
    );
  }
}

class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Estadísticas")),
      body: const Center(child: Text("Módulo de Estadísticas")),
    );
  }
}