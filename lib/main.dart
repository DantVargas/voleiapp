import 'package:flutter/material.dart';
import 'models/jugador_model.dart';
import 'widgets/cancha_view.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange), useMaterial3: true),
      home: const CanchaPage(),
    );
  }
}

class CanchaPage extends StatefulWidget {
  const CanchaPage({super.key});

  @override
  State<CanchaPage> createState() => _CanchaPageState();
}

class _CanchaPageState extends State<CanchaPage> {
  int puntosA = 0;
  int puntosB = 0;

  List<Jugador> todosLosJugadores = [
    // EQUIPO A (Azul)
    Jugador(dorsal: 1, posicionCancha: 4, nombre: 'Punta 1', equipoId: 1, posicionJuego: 'Punta'),
    Jugador(dorsal: 2, posicionCancha: 3, nombre: 'Central 1', equipoId: 1, posicionJuego: 'Central'),
    Jugador(dorsal: 5, posicionCancha: 2, nombre: 'Armador', equipoId: 1, posicionJuego: 'Armador'),
    Jugador(dorsal: 6, posicionCancha: 6, nombre: 'Central 2', equipoId: 1, posicionJuego: 'Libero'),
    Jugador(dorsal: 7, posicionCancha: 1, nombre: 'Punta 2', equipoId: 1, posicionJuego: 'Punta'),
    Jugador(dorsal: 8, posicionCancha: 5, nombre: 'Opuesto', equipoId: 1, posicionJuego: 'Opuesto'),
    // EQUIPO B (Rojo)
    Jugador(dorsal: 3, posicionCancha: 4, nombre: 'Punta 1', equipoId: 2, posicionJuego: 'Punta'),
    Jugador(dorsal: 4, posicionCancha: 3, nombre: 'Central 1', equipoId: 2, posicionJuego: 'Central'),
    Jugador(dorsal: 9, posicionCancha: 2, nombre: 'Armador', equipoId: 2, posicionJuego: 'Armador'),
    Jugador(dorsal: 10, posicionCancha: 6, nombre: 'Libero', equipoId: 2, posicionJuego: 'Libero'),
    Jugador(dorsal: 11, posicionCancha: 1, nombre: 'Punta 2', equipoId: 2, posicionJuego: 'Punta'),
    Jugador(dorsal: 12, posicionCancha: 5, nombre: 'Opuesto', equipoId: 2, posicionJuego: 'Opuesto'),
  ];

  void ejecutarRotacion(int equipoId) {
    setState(() {
      for (var j in todosLosJugadores.where((j) => j.equipoId == equipoId)) {
        if (j.posicionCancha == 1) { j.posicionCancha = 6; }
        else if (j.posicionCancha == 6) { j.posicionCancha = 5; }
        else if (j.posicionCancha == 5) { j.posicionCancha = 4; }
        else if (j.posicionCancha == 4) { j.posicionCancha = 3; }
        else if (j.posicionCancha == 3) { j.posicionCancha = 2; }
        else if (j.posicionCancha == 2) { j.posicionCancha = 1; }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Volei App'), backgroundColor: Colors.orange, centerTitle: true),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(child: _buildScore("EQUIPO A", puntosA, Colors.blue, () {
                  setState(() => puntosA++);
                  ejecutarRotacion(1);
                })),
                const Text("VS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Expanded(child: _buildScore("EQUIPO B", puntosB, Colors.red, () {
                  setState(() => puntosB++);
                  ejecutarRotacion(2);
                })),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: CanchaView(jugadores: todosLosJugadores),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScore(String t, int p, Color c, VoidCallback onTap) {
    return Column(
      children: [
        Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        Text("$p", style: const TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
        ElevatedButton(
          onPressed: onTap, 
          style: ElevatedButton.styleFrom(backgroundColor: c, foregroundColor: Colors.white),
          child: const Text("+1"),
        ),
      ],
    );
  }
}