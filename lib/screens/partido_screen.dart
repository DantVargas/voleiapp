import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/partido_provider.dart';
import '../models/jugador_model.dart';
import '../models/tipo_punto.dart';
import '../models/complejo_punto.dart';
import '../widgets/cancha_view.dart';
import '../widgets/marcador_widget.dart';
import '../widgets/banca_widget.dart';
import '../widgets/historial_sets_widget.dart';
import '../widgets/sorteo_overlay.dart';
import '../widgets/hoja_inferior.dart';
import 'partido_detalle_screen.dart';
import 'dart:async';

class PartidoScreen extends StatelessWidget {
  /// En Modo Pro, cada punto pide tipo de jugada y jugador antes de anotar.
  final bool modoPro;

  const PartidoScreen({super.key, this.modoPro = false});

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
                  MarcadorWidget(
                    onPuntoPersonalizado:
                        modoPro ? (equipoId) => _mostrarSelectorPunto(context, equipoId) : null,
                  ), // El indicador de saque ahora está aquí dentro
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
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Panel proporcional al ancho real de la pantalla
                        // (celular chico, tablet o ventana web grande) en
                        // vez de un ancho fijo que en pantallas angostas le
                        // roba demasiado espacio a la cancha.
                        final panelWidth = (constraints.maxWidth * 0.12).clamp(64.0, 120.0);
                        return Row(
                          children: [
                            // PANEL IZQUIERDO (Equipo A)
                            _buildPanelLateral(context, 1, "A", Colors.blue, partido, panelWidth),

                            // CENTRO: CANCHA
                            Expanded(
                              flex: 5,
                              child: CanchaView(
                                jugadores: partido.todosLosJugadores,
                                onJugadorTap: (j) => _mostrarOpcionesJugador(context, j),
                              ),
                            ),

                            // PANEL DERECHO (Equipo B)
                            _buildPanelLateral(context, 2, "B", Colors.red, partido, panelWidth),
                          ],
                        );
                      },
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

  Widget _buildPanelLateral(BuildContext context, int equipoId, String titulo, Color color, PartidoProvider partido, double ancho) {
    return SizedBox(
      width: ancho,
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

  // --- MODO PRO: SELECCIÓN DE TIPO DE PUNTO Y JUGADOR ---

  void _mostrarSelectorPunto(BuildContext context, int equipoId) {
    final partido = context.read<PartidoProvider>();
    final nombreEquipo = equipoId == 1 ? partido.nombreEquipoA : partido.nombreEquipoB;
    final equipoSaca = partido.equipoQueSaca;

    // Un Ace solo es posible si este equipo está sacando; un "error de saque
    // rival" solo es posible si el rival es quien está sacando. Si no
    // sabemos quién saca (equipoSaca == null) no filtramos nada.
    final tipos = TipoPunto.values.where((tipo) {
      if (equipoSaca == null) return true;
      if (tipo == TipoPunto.saque) return equipoSaca == equipoId;
      if (tipo == TipoPunto.errorSaqueRival) return equipoSaca != equipoId;
      return true;
    }).toList();

    mostrarHojaInferior(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              "Punto para $nombreEquipo — ¿cómo fue?",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          ...tipos.map((tipo) => ListTile(
                dense: true,
                leading: Icon(
                  tipo.icono,
                  color: tipo == TipoPunto.otro
                      ? Colors.blueGrey
                      : (tipo.esPositivo ? Colors.green.shade700 : Colors.red.shade700),
                ),
                title: Text(tipo.label),
                onTap: () {
                  Navigator.pop(ctx);
                  _procesarTipoPunto(context, equipoId: equipoId, tipo: tipo);
                },
              )),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  /// Resuelve el jugador para el tipo de punto elegido. Cuando la regla del
  /// vóley determina un único jugador posible (Ace o error de saque rival:
  /// siempre lo hace/sufre quien está en la posición 1), se anota directo
  /// sin preguntar; en el resto se abre el selector ya filtrado.
  void _procesarTipoPunto(BuildContext context, {required int equipoId, required TipoPunto tipo}) {
    final partido = context.read<PartidoProvider>();
    final equipoRival = equipoId == 1 ? 2 : 1;

    if (tipo == TipoPunto.otro) {
      partido.sumarPunto(equipoId, tipo: tipo);
      return;
    }

    if (tipo == TipoPunto.saque) {
      final sacador = _jugadorEnPosicion(partido, equipoId, 1);
      if (sacador != null) {
        partido.sumarPunto(equipoId, tipo: tipo, jugador: sacador);
        _mostrarConfirmacion(context, "Ace de #${sacador.dorsal} ${sacador.nombre ?? ''}");
        return;
      }
    }

    if (tipo == TipoPunto.errorSaqueRival) {
      final sacador = _jugadorEnPosicion(partido, equipoRival, 1);
      if (sacador != null) {
        partido.sumarPunto(equipoId, tipo: tipo, jugador: sacador);
        _mostrarConfirmacion(context, "Error de saque de #${sacador.dorsal} ${sacador.nombre ?? ''}");
        return;
      }
    }

    // Si el punto fue por una acción positiva, el jugador es del equipo que
    // anota; si fue por un error, es del equipo rival.
    final equipoJugador = tipo.esPositivo ? equipoId : equipoRival;
    var candidatos =
        partido.todosLosJugadores.where((j) => j.equipoId == equipoJugador && j.estaEnCancha).toList();

    // Solo los delanteros (posiciones 2, 3 y 4) pueden bloquear.
    if (tipo == TipoPunto.bloqueo) {
      candidatos = candidatos.where((j) => [2, 3, 4].contains(j.posicionCancha)).toList();
    }

    candidatos.sort((a, b) => a.posicionCancha.compareTo(b.posicionCancha));

    // Solo las jugadas de rally (no el saque) tienen un "K" — número de
    // ataque del intercambio que terminó el punto.
    const tiposDeRally = {
      TipoPunto.ataque,
      TipoPunto.bloqueo,
      TipoPunto.errorAtaqueRival,
      TipoPunto.errorRecepcionRival,
    };

    _mostrarSelectorJugador(
      context,
      equipoId: equipoId,
      tipo: tipo,
      candidatos: candidatos,
      pedirComplejo: tiposDeRally.contains(tipo),
    );
  }

  Jugador? _jugadorEnPosicion(PartidoProvider partido, int equipoId, int posicion) {
    for (final j in partido.todosLosJugadores) {
      if (j.equipoId == equipoId && j.posicionCancha == posicion) return j;
    }
    return null;
  }

  void _mostrarConfirmacion(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), duration: const Duration(seconds: 2)),
    );
  }

  void _mostrarSelectorJugador(
    BuildContext context, {
    required int equipoId,
    required TipoPunto tipo,
    required List<Jugador> candidatos,
    bool pedirComplejo = false,
  }) {
    final partido = context.read<PartidoProvider>();
    int? complejoSeleccionado;

    mostrarHojaInferior(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                tipo.esPositivo ? "¿Quién hizo el punto?" : "¿Quién cometió el error?",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            if (pedirComplejo) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(
                  "¿En qué K terminó el punto? (opcional)",
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 6,
                  children: ComplejoPunto.valores.map((k) {
                    final activo = complejoSeleccionado == k;
                    final color = ComplejoPunto.colores[k]!;
                    return ChoiceChip(
                      label: Text(ComplejoPunto.labels[k]!, style: const TextStyle(fontSize: 11)),
                      selected: activo,
                      selectedColor: color,
                      labelStyle: TextStyle(color: activo ? Colors.white : Colors.black87),
                      onSelected: (_) => setSheetState(
                        () => complejoSeleccionado = activo ? null : k,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 4),
            ],
            if (candidatos.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "No hay jugadores habilitados en cancha para esta jugada.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ...candidatos.map((j) => ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    child: Text('${j.dorsal}', style: const TextStyle(fontSize: 11)),
                  ),
                  title: Text(j.nombre ?? 'Jugador'),
                  subtitle: Text('Posición ${j.posicionCancha}', style: const TextStyle(fontSize: 10)),
                  onTap: () {
                    Navigator.pop(ctx);
                    partido.sumarPunto(equipoId, tipo: tipo, jugador: j, complejo: complejoSeleccionado);
                  },
                )),
            ListTile(
              dense: true,
              leading: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.grey),
              title: const Text("Sin especificar jugador"),
              onTap: () {
                Navigator.pop(ctx);
                partido.sumarPunto(equipoId, tipo: tipo, complejo: complejoSeleccionado);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _mostrarOpcionesJugador(BuildContext context, Jugador jugador) {
    mostrarHojaInferior(
      context,
      builder: (ctx) => Column(
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
    );
  }

  void _formDialogEdicion(BuildContext context, Jugador jugador) {
    final nombreCtrl = TextEditingController(text: jugador.nombre);
    final dorsalCtrl = TextEditingController(text: jugador.dorsal.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Editar"),
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
          width: 220,
          // Alto acotado a la pantalla disponible: si hay muchos suplentes
          // la lista scrollea en vez de desbordar el diálogo.
          height: suplentes.isEmpty
              ? null
              : (suplentes.length * 48).clamp(0, (MediaQuery.of(ctx).size.height * 0.5).round()).toDouble(),
          child: suplentes.isEmpty
              ? const Text("No hay suplentes.")
              : ListView.builder(
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
        content: SingleChildScrollView(
          child: Column(
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