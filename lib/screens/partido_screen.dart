import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../models/jugador_model.dart';
import '../widgets/cancha_view.dart';
import '../widgets/marcador_widget.dart';
import '../widgets/banca_widget.dart';
import '../widgets/historial_sets_widget.dart';
import '../widgets/sorteo_overlay.dart';
import 'partido_detalle_screen.dart';
import 'dart:async';

class PartidoScreen extends StatelessWidget {
  const PartidoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: null, // Mantenemos el diseño sin AppBar
      body: SafeArea(
        child: Column(
          children: [
            // 1. BARRA SUPERIOR UNIFICADA (Retroceder + Marcador + Ajustes)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(Icons.undo, 
                      color: partido.hayHistorial ? Colors.blueGrey : Colors.grey.shade300, 
                      size: 22),
                    onPressed: partido.hayHistorial ? () => partido.deshacer() : null,
                  ),
                  const Spacer(),
                  const MarcadorWidget(), // El indicador de saque ahora está aquí dentro
                  const Spacer(),
                  // Botón de AJUSTES que reemplaza al de reiniciar directo
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.settings, color: Colors.blueGrey, size: 22),
                    onPressed: () => _mostrarAjustesPartido(context, partido),
                  ),
                ],
              ),
            ),

            // 2. HISTORIAL DE PUNTOS
            const SizedBox(height: 25, child: Center(child: HistorialSetsWidget())),

            // 3. ÁREA DE JUEGO (Paneles laterales + Cancha)
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        // PANEL IZQUIERDO (Equipo A)
                        _buildPanelLateral(context, 1, "A", Colors.blue, partido),

                        // CENTRO: CANCHA
                        Expanded(
                          flex: 5,
                          child: CanchaView(
                            jugadores: partido.todosLosJugadores,
                            onJugadorTap: (j) => _mostrarOpcionesJugador(context, j),
                          ),
                        ),

                        // PANEL DERECHO (Equipo B)
                        _buildPanelLateral(context, 2, "B", Colors.red, partido),
                      ],
                    ),
                  ),

                  // BOTÓN EMPEZAR REUBICADO: Flotando al centro abajo
                  if (!partido.partidoEmpezado)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _botonEmpezarGrande(context, partido),
                      ),
                    ),

                  if (partido.mostrarSorteo) const SorteoOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS SEGÚN TU PROPUESTA ---

  Widget _buildPanelLateral(BuildContext context, int equipoId, String titulo, Color color, PartidoProvider partido) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          _botonTMCompacto(context, equipoId, partido),
          Expanded(child: BancaWidget(equipoId: equipoId, titulo: titulo, color: color)),
          // La info de cambios ahora está despejada
          _infoCambiosCompacta(equipoId, partido),
        ],
      ),
    );
  }

  Widget _botonEmpezarGrande(BuildContext context, PartidoProvider partido) {
    return ElevatedButton.icon(
      onPressed: () {
        if (partido.setActual == 1 && !partido.cronometroSet.isRunning) {
          partido.abrirSorteo();
        } else {
          // Si el set terminó (ej. 25-23), avanzamos y reseteamos marcador
          if (partido.puntosA > 0 || partido.puntosB > 0) {
            partido.avanzarSet();
          } else {
            partido.iniciarSiguienteSet();
          }
        }
      },
      icon: const Icon(Icons.play_arrow),
      label: Text(
        partido.setActual == 1 ? "EMPEZAR PARTIDO" : "INICIAR SET ${partido.setActual}",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
  
  void _mostrarAjustesPartido(BuildContext context, PartidoProvider partido) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Configuración del Encuentro"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cambios Infinitos
            SwitchListTile(
              title: const Text("Cambios Infinitos"),
              subtitle: const Text("Ideal para amistosos"),
              value: partido.cambiosInfinitos,
              onChanged: (val) {
                partido.actualizarConfiguracion(infinitos: val);
                Navigator.pop(ctx);
              },
            ),
            if (!partido.cambiosInfinitos)
              ListTile(
                title: Text("Máx. Cambios: ${partido.cambiosMaximos}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.remove), onPressed: () => partido.actualizarConfiguracion(nuevosCambios: partido.cambiosMaximos - 1)),
                    IconButton(icon: const Icon(Icons.add), onPressed: () => partido.actualizarConfiguracion(nuevosCambios: partido.cambiosMaximos + 1)),
                  ],
                ),
              ),
            const Divider(),
            // Sorteo (Solo si no hay puntos)
            if (partido.puntosA == 0 && partido.puntosB == 0)
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text("Rehacer Sorteo"),
                onTap: () { Navigator.pop(ctx); partido.abrirSorteo(); },
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.save_alt, color: Colors.green),
              title: const Text("Guardar Partido"),
              subtitle: const Text("Guarda en el historial con estadísticas"),
              onTap: () { Navigator.pop(ctx); _mostrarDialogoGuardar(context); },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.refresh, color: Colors.red),
              title: const Text("REINICIAR PARTIDO"),
              onTap: () { Navigator.pop(ctx); _confirmarReinicio(context); },
            ),
          ],
        ),
      ),
    ),
  );
}

  // --- COMPONENTES COMPACTOS ---

  Widget _botonTMCompacto(BuildContext context, int equipoId, PartidoProvider partido) {
    int restantes = equipoId == 1 ? partido.tiemposMuertosA : partido.tiemposMuertosB;
    bool estaActivo = partido.partidoEmpezado && restantes > 0;

    return GestureDetector(
      onTap: estaActivo ? () => _mostrarTimerTiempoMuerto(context, equipoId) : null,
      child: Opacity(
        opacity: estaActivo ? 1.0 : 0.4, 
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: estaActivo ? Colors.orange.shade50 : Colors.grey.shade100,
            border: Border.all(color: estaActivo ? Colors.orange.shade700 : Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text("TM: $restantes", 
            style: TextStyle(fontSize: 9, color: estaActivo ? Colors.orange.shade800 : Colors.grey.shade600, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _infoCambiosCompacta(int equipoId, PartidoProvider partido) {
    int realizados = equipoId == 1 ? partido.cambiosRealizadosA : partido.cambiosRealizadosB;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text("Cambios: $realizados/${partido.cambiosMaximos}",
        style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
    );
  }

  void _mostrarTimerTiempoMuerto(BuildContext context, int equipoId) {
    final provider = context.read<PartidoProvider>();
    provider.usarTiempoMuerto(equipoId);
    int segundos = 30;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (segundos > 0) {
              if (ctx.mounted) setState(() => segundos--);
            } else {
              t.cancel();
              if (ctx.mounted) Navigator.pop(ctx);
            }
          });
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text("TIEMPO MUERTO EQUIPO $equipoId", textAlign: TextAlign.center, style: const TextStyle(fontSize: 14)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("$segundos", style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: Colors.orange)),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () { timer?.cancel(); provider.devolverTiempoMuerto(equipoId); Navigator.pop(ctx); },
                      child: const Text("CANCELAR", style: TextStyle(color: Colors.red)),
                    ),
                    ElevatedButton(
                      onPressed: () { timer?.cancel(); Navigator.pop(ctx); },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      child: const Text("TERMINAR"),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    ).then((_) => timer?.cancel());
  }

  void _mostrarOpcionesJugador(BuildContext context, Jugador jugador) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.edit, size: 20),
              title: const Text("Editar Jugador"),
              onTap: () { Navigator.pop(ctx); _formDialogEdicion(context, jugador); },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.swap_horiz, size: 20),
              title: const Text("Sustitución"),
              onTap: () { Navigator.pop(ctx); _mostrarDialogoCambio(context, jugador); },
            ),
          ],
        ),
      ),
    );
  }

  void _formDialogEdicion(BuildContext context, Jugador jugador) {
    final nombreCtrl = TextEditingController(text: jugador.nombre);
    final dorsalCtrl = TextEditingController(text: jugador.dorsal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: "Nombre")),
            TextField(controller: dorsalCtrl, decoration: const InputDecoration(labelText: "Dorsal"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          TextButton(
            onPressed: () {
              context.read<PartidoProvider>().editarJugador(jugador, nombreCtrl.text, int.tryParse(dorsalCtrl.text) ?? jugador.dorsal);
              Navigator.pop(ctx);
            },
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoCambio(BuildContext context, Jugador jugadorCancha) {
    final partido = context.read<PartidoProvider>();
    final suplentes = partido.jugadoresDeBanca(jugadorCancha.equipoId);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Sustitución"),
        content: SizedBox(
          width: 200,
          child: suplentes.isEmpty
              ? const Text("No hay suplentes.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: suplentes.length,
                  itemBuilder: (context, i) => ListTile(
                    dense: true,
                    title: Text("${suplentes[i].dorsal} - ${suplentes[i].nombre}"),
                    onTap: () {
                      bool exito = partido.realizarCambio(jugadorCancha, suplentes[i]);
                      Navigator.pop(ctx);
                      if (!exito) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Límite alcanzado")));
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }

  void _mostrarDialogoGuardar(BuildContext context) {
    final notasCtrl = TextEditingController();
    final partido = context.read<PartidoProvider>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Guardar Partido"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${partido.nombreEquipoA}  ${partido.setsGanadosA} - ${partido.setsGanadosB}  ${partido.nombreEquipoB}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: notasCtrl,
              decoration: const InputDecoration(
                labelText: "Notas (opcional)",
                hintText: "Comentarios del partido...",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton.icon(
            icon: const Icon(Icons.save_alt, size: 16),
            label: const Text("Guardar"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              final partidoId = await partido.guardarPartido(notas: notasCtrl.text);
              if (context.mounted) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => PartidoDetalleScreen(partidoId: partidoId),
                ));
              }
            },
          ),
        ],
      ),
    );
  }

  void _confirmarReinicio(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("¿Reiniciar partido?"),
        content: const Text("Esta acción borrará todos los puntos y sets actuales."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No")),
          TextButton(
            onPressed: () { context.read<PartidoProvider>().reiniciar(); Navigator.pop(ctx); },
            child: const Text("Sí", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class CronometroWidget extends StatelessWidget {
  const CronometroWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final partido = context.watch<PartidoProvider>();
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        final duration = partido.cronometroSet.elapsed;
        String dosDigitos(int n) => n.toString().padLeft(2, "0");
        final min = dosDigitos(duration.inMinutes.remainder(60));
        final sec = dosDigitos(duration.inSeconds.remainder(60));
        return Text("$min:$sec", 
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey));
      },
    );
  }
}