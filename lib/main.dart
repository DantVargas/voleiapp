import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para bloquear la orientación
import 'models/jugador_model.dart';
import 'widgets/cancha_view.dart';

void main() {
  // Aseguramos la inicialización para bloquear la orientación antes de lanzar la app
  WidgetsFlutterBinding.ensureInitialized();
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
  int? ultimoPuntoRotacionA;
  int? ultimoPuntoRotacionB;

  List<Jugador> todosLosJugadores = [
    // EQUIPO A (Azul)
    Jugador(dorsal: 1, posicionCancha: 4, nombre: 'Punta 1', equipoId: 1),
    Jugador(dorsal: 2, posicionCancha: 3, nombre: 'Central 1', equipoId: 1),
    Jugador(dorsal: 5, posicionCancha: 2, nombre: 'Armador', equipoId: 1),
    Jugador(dorsal: 6, posicionCancha: 6, nombre: 'Central 2', equipoId: 1),
    Jugador(dorsal: 7, posicionCancha: 1, nombre: 'Punta 2', equipoId: 1),
    Jugador(dorsal: 8, posicionCancha: 5, nombre: 'Opuesto', equipoId: 1),
    Jugador(dorsal: 99, posicionCancha: 0, nombre: 'Suplente A1', equipoId: 1),
    Jugador(dorsal: 98, posicionCancha: 0, nombre: 'Libero A', equipoId: 1),
    Jugador(dorsal: 97, posicionCancha: 0, nombre: 'Suplente A2', equipoId: 1),
    
    // EQUIPO B (Rojo)
    Jugador(dorsal: 3, posicionCancha: 4, nombre: 'Punta 1', equipoId: 2),
    Jugador(dorsal: 4, posicionCancha: 3, nombre: 'Central 1', equipoId: 2),
    Jugador(dorsal: 9, posicionCancha: 2, nombre: 'Armador', equipoId: 2),
    Jugador(dorsal: 10, posicionCancha: 6, nombre: 'Libero B', equipoId: 2),
    Jugador(dorsal: 11, posicionCancha: 1, nombre: 'Punta 2', equipoId: 2),
    Jugador(dorsal: 12, posicionCancha: 5, nombre: 'Opuesto', equipoId: 2),
    Jugador(dorsal: 20, posicionCancha: 0, nombre: 'Suplente B1', equipoId: 2),
    Jugador(dorsal: 21, posicionCancha: 0, nombre: 'Suplente B2', equipoId: 2),
  ];

  // --- VALIDACIONES ---
  bool _dorsalExiste(int d, int id, {int? excl}) =>
      todosLosJugadores.any((j) => j.equipoId == id && j.dorsal == d && d != excl);

  // --- LÓGICA DE JUEGO ---
  void _sumarPunto(int id) {
    setState(() {
      if (id == 1) {
        puntosA++;
        if (equipoQueSaca == 2) { _rotar(1); ultimoPuntoRotacionA = puntosA; }
        equipoQueSaca = 1;
      } else {
        puntosB++;
        if (equipoQueSaca == 1) { _rotar(2); ultimoPuntoRotacionB = puntosB; }
        equipoQueSaca = 2;
      }
    });
  }

  void _restarPunto(int id) {
    setState(() {
      if (id == 1 && puntosA > 0) {
        if (puntosA == ultimoPuntoRotacionA) { _deshacerRotacion(1); equipoQueSaca = 2; }
        puntosA--;
      } else if (id == 2 && puntosB > 0) {
        if (puntosB == ultimoPuntoRotacionB) { _deshacerRotacion(2); equipoQueSaca = 1; }
        puntosB--;
      }
    });
  }

  void _rotar(int id) {
    final mapa = {1: 6, 6: 5, 5: 4, 4: 3, 3: 2, 2: 1};
    for (var j in todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha != 0)) {
      j.posicionCancha = mapa[j.posicionCancha]!;
    }
  }

  void _deshacerRotacion(int id) {
    final mapa = {6: 1, 1: 2, 2: 3, 3: 4, 4: 5, 5: 6};
    for (var j in todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha != 0)) {
      j.posicionCancha = mapa[j.posicionCancha]!;
    }
  }

  // --- DIÁLOGOS DE GESTIÓN ---
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
            title: const Text("Editar jugador (Nombre/Dorsal)"),
            onTap: () { Navigator.pop(context); _dialogoEditarJugador(j); },
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: Colors.green),
            title: Text(j.posicionCancha == 0 ? "Hacer cambio (Entrar a cancha)" : "Hacer cambio (Mandar a banca)"),
            onTap: () { Navigator.pop(context); _seleccionarCambio(j); },
          ),
          if (j.posicionCancha == 0)
            ListTile(
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text("Eliminar de la banca", style: TextStyle(color: Colors.red)),
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
    String? error;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDS) => AlertDialog(
          title: Text("Editar #${j.dorsal}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: cN, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: cD, decoration: InputDecoration(labelText: "Dorsal", errorText: error), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            ElevatedButton(onPressed: () {
              int? nD = int.tryParse(cD.text);
              if (nD != null) {
                if (_dorsalExiste(nD, j.equipoId, excl: j.dorsal)) {
                  setDS(() => error = "Dorsal $nD ya está en uso");
                } else {
                  setState(() { j.nombre = cN.text; j.dorsal = nD; });
                  Navigator.pop(context);
                }
              }
            }, child: const Text("Guardar"))
          ],
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
        title: Text(esS ? "Sustituir a alguien por: #${jSel.dorsal}" : "Cambiar a #${jSel.dorsal} por:"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: lista.length,
            itemBuilder: (context, i) => ListTile(
              leading: CircleAvatar(backgroundColor: jSel.equipoId == 1 ? Colors.blue : Colors.red, child: Text("${lista[i].dorsal}", style: const TextStyle(color: Colors.white, fontSize: 12))),
              title: Text(lista[i].nombre ?? ""),
              onTap: () {
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
          title: Text("Nuevo Suplente Equipo ${id == 1 ? 'A' : 'B'}"),
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
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mínimo 3 jugadores en banca requeridos"), backgroundColor: Colors.red));
      return;
    }
    setState(() => todosLosJugadores.remove(j));
  }

  // --- INTERFAZ ---
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool esBajo = size.height < 450;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Voley Pro Manager", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.orange,
        centerTitle: true,
        toolbarHeight: esBajo ? 30 : 45,
      ),
      body: Column(
        children: [
          _buildMarcadorReducido(),
          Expanded(
            child: Row(
              children: [
                _buildBancaLateral(1, "Banca A", Colors.blue),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Center(
                      child: CanchaView(
                        jugadores: todosLosJugadores, 
                        onJugadorTap: _mostrarOpcionesJugador
                      ),
                    ),
                  ),
                ),
                _buildBancaLateral(2, "Banca B", Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarcadorReducido() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2)],
      ),
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
        IconButton(onPressed: () => _restarPunto(id), icon: const Icon(Icons.remove_circle_outline, size: 22)),
        Text("$pts", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        SizedBox(
          height: 35,
          child: ElevatedButton(
            onPressed: () => _sumarPunto(id),
            style: ElevatedButton.styleFrom(backgroundColor: color, shape: const StadiumBorder()),
            child: const Text("+1", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Widget _buildBancaLateral(int id, String titulo, Color color) {
    final lista = todosLosJugadores.where((j) => j.equipoId == id && j.posicionCancha == 0).toList();
    return Container(
      width: 145,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            width: double.infinity,
            decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(9))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => _agregarJugadorBanca(id),
                  child: const Icon(Icons.add_circle, color: Colors.white, size: 18),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: lista.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => ListTile(
                dense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                leading: CircleAvatar(radius: 11, backgroundColor: color.withOpacity(0.1), child: Text("${lista[i].dorsal}", style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold))),
                title: Text(lista[i].nombre ?? "", style: const TextStyle(fontSize: 11)),
                onTap: () => _mostrarOpcionesJugador(lista[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}