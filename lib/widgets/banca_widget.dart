import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../provider/ajustes_provider.dart';
import '../models/jugador_model.dart';

class BancaWidget extends StatelessWidget {
  final int equipoId;
  final String titulo;
  final Color color;

  const BancaWidget({
    super.key,
    required this.equipoId,
    required this.titulo,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();
    final lista = partido.jugadoresDeBanca(equipoId);
    final escala = context.watch<AjustesProvider>().escalaUI;

    return Container(
      // Sin ancho fijo: ocupa todo el panel lateral que le da PartidoScreen,
      // que a su vez se calcula según el ancho real de la pantalla.
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 2 * escala, vertical: 4 * escala),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Cabecera Minimalista
          Container(
            padding: EdgeInsets.symmetric(vertical: 4 * escala),
            width: double.infinity,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Column(
              children: [
                Text(
                  titulo,
                  style: TextStyle(color: Colors.white, fontSize: 9 * escala, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () => _mostrarDialogoJugador(context),
                  child: Icon(Icons.add_circle_outline, color: Colors.white, size: 16 * escala),
                ),
              ],
            ),
          ),

          // Espacio de Suplentes en Cuadrícula (Wrap)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: lista.isEmpty
                  ? const Center(child: Text("—", style: TextStyle(color: Colors.grey)))
                  : SingleChildScrollView(
                      child: Wrap(
                        spacing: 4,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: lista.map((jugador) => _buildJugadorBanca(context, jugador, escala)).toList(),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget de Jugador Individual (Círculo pequeño con dorsal)
  Widget _buildJugadorBanca(BuildContext context, Jugador jugador, double escala) {
    return GestureDetector(
      onTap: () => _mostrarDialogoJugador(context, jugador: jugador),
      onLongPress: () => _confirmarEliminar(context, jugador),
      child: Column(
        children: [
          CircleAvatar(
            radius: 14 * escala, // Tamaño compacto
            backgroundColor: color.withValues(alpha: 0.1),
            child: Text(
              "${jugador.dorsal}",
              style: TextStyle(fontSize: 10 * escala, color: color, fontWeight: FontWeight.bold),
            ),
          ),
          // Nombre pequeño opcional (solo iniciales si prefieres más espacio)
          SizedBox(
            width: 35 * escala,
            child: Text(
              jugador.nombre ?? "",
              style: TextStyle(fontSize: 7 * escala),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- MÉTODOS DE DIÁLOGO (MANTENIDOS IGUAL) ---

  void _mostrarDialogoJugador(BuildContext context, {Jugador? jugador}) {
    final nombreCtrl = TextEditingController(text: jugador?.nombre);
    final dorsalCtrl = TextEditingController(text: jugador?.dorsal?.toString());
    final partido = context.read<PartidoProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(jugador == null ? "Nuevo Jugador" : "Editar Jugador"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
              TextField(controller: dorsalCtrl, decoration: const InputDecoration(labelText: "Dorsal"), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              if (nombreCtrl.text.isNotEmpty) {
                if (jugador == null) {
                  partido.agregarJugador(equipoId, nombreCtrl.text, int.tryParse(dorsalCtrl.text) ?? 0);
                } else {
                  partido.editarJugador(jugador, nombreCtrl.text, int.tryParse(dorsalCtrl.text) ?? jugador.dorsal);
                }
                Navigator.pop(ctx);
              }
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, Jugador jugador) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar"),
        content: Text("¿Quitar a ${jugador.nombre}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () {
              context.read<PartidoProvider>().eliminarJugador(jugador);
              Navigator.pop(ctx);
            },
            child: const Text("Sí", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}