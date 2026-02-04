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
  int puntosA = 0;
  int puntosB = 0;
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
    });
  }

  void _deshacer() {
    if (_historial.isEmpty) return;
    final estadoPrevio = _historial.removeLast();
    setState(() {
      puntosA = estadoPrevio['puntosA'];
      puntosB = estadoPrevio['puntosB'];
      equipoQueSaca = estadoPrevio['equipoQueSaca'];
      final posiciones = estadoPrevio['posiciones'] as List<int>;
      for (int i = 0; i < todosLosJugadores.length; i++) {
        todosLosJugadores[i].posicionCancha = posiciones[i];
      }
    });
  }

  void _sumarPunto(int id) {
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
    final size = MediaQuery.of(context).size;
    final bool esBajo = size.height < 450;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Voley Manager"),
        backgroundColor: Colors.grey[100],
        centerTitle: true,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.undo),
          onPressed: _historial.isNotEmpty ? _deshacer : null,
        ),
        actions: [
          // BOTÓN PARA IR A LA PÁGINA DE ESTADÍSTICAS
          IconButton(
            icon: const Icon(Icons.bar_chart),
            tooltip: "Estadísticas",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EstadisticasPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _reiniciarConfirmacion(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMarcadorEsteticaAnterior(),
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
                        if (puntosA == 0 && puntosB == 0 && equipoQueSaca == null)
                          _buildOverlaySorteo(),
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
  Widget _buildMarcadorEsteticaAnterior() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlEquipo(1, puntosA, Colors.blue),
          const Text("VS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          _buildControlEquipo(2, puntosB, Colors.red),
        ],
      ),
    );
  }

  Widget _buildControlEquipo(int id, int pts, Color color) {
    bool saca = equipoQueSaca == id;
    return Row(
      children: [
        if (saca) const Icon(Icons.sports_volleyball, color: Colors.orange, size: 24),
        const SizedBox(width: 8),
        Text("$pts", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: equipoQueSaca != null ? () => _sumarPunto(id) : null,
          style: ElevatedButton.styleFrom(backgroundColor: color, shape: const StadiumBorder()),
          child: const Text("+1", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBancaLateral(int id, String titulo, Color color) {
    final lista = todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha == 0).toList();
    return Container(
      width: 140,
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
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
                leading: CircleAvatar(radius: 10, backgroundColor: color.withOpacity(0.1), child: Text("${lista[i].dorsal}", style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.bold))),
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
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Sorteo Inicial", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                      onPressed: () => setState(() => equipoQueSaca = 1),
                      child: const Text("Saca A", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => setState(() => equipoQueSaca = 2),
                      child: const Text("Saca B", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
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
        content: const Text("¿Quieres volver a 0-0?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("No")),
          TextButton(onPressed: () {
            setState(() { puntosA = 0; puntosB = 0; equipoQueSaca = null; _historial.clear(); });
            Navigator.pop(context);
          }, child: const Text("Sí")),
        ],
      ),
    );
  }

  // --- MÉTODOS DE GESTIÓN (Reutilizados de tu código anterior) ---
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

  bool _dorsalExiste(int d, int id, {int? excl}) => todosLosJugadores.any((j) => j.equipoId == id && j.dorsal == d && d != excl);

  void _dialogoEditarJugador(Jugador j) {
  final cN = TextEditingController(text: j.nombre);
  final cD = TextEditingController(text: j.dorsal.toString());
  String? error;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDS) => Scaffold( // Scaffold permite el redimensionamiento
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            // Empuja el contenido hacia arriba según la altura del teclado
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: AlertDialog(
              title: Text("Editar #${j.dorsal}"),
              content: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  TextField(
                    controller: cN, 
                    decoration: const InputDecoration(labelText: "Nombre"),
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextField(
                    controller: cD, 
                    decoration: InputDecoration(labelText: "Dorsal", errorText: error), 
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
                ElevatedButton(
                  onPressed: () {
                    int? nD = int.tryParse(cD.text);
                    if (nD != null) {
                      if (_dorsalExiste(nD, j.equipoId, excl: j.dorsal)) {
                        setDS(() => error = "Dorsal ya en uso");
                      } else {
                        setState(() { j.nombre = cN.text; j.dorsal = nD; });
                        Navigator.pop(context);
                      }
                    }
                  }, 
                  child: const Text("Guardar")
                )
              ],
            ),
          ),
        ),
      ),
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
    String? error;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDS) => AlertDialog(
          title: const Text("Nuevo Suplente"),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: cN, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: cD, decoration: InputDecoration(labelText: "Dorsal", errorText: error), keyboardType: TextInputType.number),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar")),
            ElevatedButton(onPressed: () {
              int? d = int.tryParse(cD.text);
              if (d != null) {
                if (_dorsalExiste(d, id)) {
                  setDS(() => error = "Dorsal ya existe");
                } else {
                  setState(() => todosLosJugadores.add(Jugador(nombre: cN.text, dorsal: d, posicionCancha: 0, equipoId: id)));
                  Navigator.pop(context);
                }
              }
            }, child: const Text("Agregar"))
          ],
        ),
      ),
    );
  }

  void _eliminarJugador(Jugador j) {
    if (todosLosJugadores.where((jug) => jug.equipoId == j.equipoId).length <= 9) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mínimo 3 jugadores en banca"), backgroundColor: Colors.red));
      return;
    }
    setState(() => todosLosJugadores.remove(j));
  }
}class EstadisticasPage extends StatelessWidget {
  const EstadisticasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Estadísticas de jugadores"),
        backgroundColor: Colors.grey[100],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            const Text(
              "Módulo de Estadísticas",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Esta funcionalidad estará disponible próximamente.",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Volver al Partido"),
            )
          ],
        ),
      ),
    );
  }
}