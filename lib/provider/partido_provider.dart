import 'package:flutter/material.dart';
import '../models/jugador_model.dart';
import '../models/tipo_punto.dart';
import '../database/db_manager.dart';

class PartidoProvider extends ChangeNotifier {
  // -------------------------------------------------------
  // ESTADO DEL PARTIDO
  // -------------------------------------------------------
  bool partidoEmpezado = false;
  bool mostrarSorteo = false;

  int puntosA = 0;
  int puntosB = 0;
  int? equipoQueSaca;
  int? _saqueInicial;

  int maxSets = 3;
  int puntosParaGanarSet = 25;
  int puntosParaGanarUltimoSet = 15;
  bool modoMataMata = false;

  int setsGanadosA = 0;
  int setsGanadosB = 0;
  int setActual = 1;

  String nombreEquipoA = "EQUIPO A";
  String nombreEquipoB = "EQUIPO B";

  List<List<Map<String, dynamic>>> historialSets = [[]];
  final List<Map<String, dynamic>> _historial = [];

  // --- VARIABLES DE CONTROL POR SET ---
  int tiemposMuertosA = 2;
  int tiemposMuertosB = 2;
  int maxTiemposPorSet = 2;

  int cambiosRealizadosA = 0;
  int cambiosRealizadosB = 0;
  int cambiosMaximos = 6;
  bool cambiosInfinitos = false;

  // Cronómetro
  Stopwatch cronometroSet = Stopwatch();

  List<Jugador> todosLosJugadores = [
    Jugador(dorsal: 1, posicionCancha: 4, nombre: 'Jugador 1', equipoId: 1),
    Jugador(dorsal: 2, posicionCancha: 3, nombre: 'Jugador 2', equipoId: 1),
    Jugador(dorsal: 5, posicionCancha: 2, nombre: 'Jugador 3', equipoId: 1),
    Jugador(dorsal: 6, posicionCancha: 6, nombre: 'Jugador 4', equipoId: 1),
    Jugador(dorsal: 7, posicionCancha: 1, nombre: 'Jugador 5', equipoId: 1),
    Jugador(dorsal: 8, posicionCancha: 5, nombre: 'Jugador 6', equipoId: 1),
    Jugador(dorsal: 99, posicionCancha: 0, nombre: 'Suplente A1', equipoId: 1),
    Jugador(dorsal: 98, posicionCancha: 0, nombre: 'Suplente A2', equipoId: 1),
    Jugador(dorsal: 3, posicionCancha: 4, nombre: 'Jugador 1', equipoId: 2),
    Jugador(dorsal: 4, posicionCancha: 3, nombre: 'Jugador 2', equipoId: 2),
    Jugador(dorsal: 9, posicionCancha: 2, nombre: 'Jugador 3', equipoId: 2),
    Jugador(dorsal: 10, posicionCancha: 6, nombre: 'Jugador 4', equipoId: 2),
    Jugador(dorsal: 11, posicionCancha: 1, nombre: 'Jugador 5', equipoId: 2),
    Jugador(dorsal: 12, posicionCancha: 5, nombre: 'Jugador 6', equipoId: 2),
    Jugador(dorsal: 20, posicionCancha: 0, nombre: 'Suplente B1', equipoId: 2),
  ];

  // -------------------------------------------------------
  // GETTERS
  // -------------------------------------------------------
  bool get hayHistorial => _historial.isNotEmpty;
  List<Jugador> jugadoresDeBanca(int equipoId) =>
      todosLosJugadores.where((j) => j.equipoId == equipoId && j.posicionCancha == 0).toList();

  // -------------------------------------------------------
  // CONFIGURACIÓN Y SAQUE
  // -------------------------------------------------------
  void configurarPartido({required int maxCambios, required int maxTiempos}) {
    cambiosMaximos = maxCambios;
    maxTiemposPorSet = maxTiempos;
    tiemposMuertosA = maxTiempos;
    tiemposMuertosB = maxTiempos;
    notifyListeners();
  }

  void iniciarPartido(int sacaPrimero) {
    equipoQueSaca = sacaPrimero;
    _saqueInicial = sacaPrimero;
    partidoEmpezado = true;
    mostrarSorteo = false;
    cronometroSet.start();
    notifyListeners();
  }

  void actualizarConfiguracion({int? nuevosSets, int? nuevosCambios, bool? infinitos}) {
    if (nuevosSets != null) maxSets = nuevosSets;
    if (nuevosCambios != null) cambiosMaximos = nuevosCambios;
    if (infinitos != null) cambiosInfinitos = infinitos;
    notifyListeners();
  }

  // -------------------------------------------------------
  // LÓGICA DE JUEGO Y SETS
  // -------------------------------------------------------
  /// [tipo] y [jugador] son opcionales: Modo Cancha los omite, Modo Pro los
  /// completa para poder atribuir el punto a un jugador y a un motivo
  /// (usados luego para calcular las estadísticas reales al guardar).
  void sumarPunto(int equipoId, {TipoPunto? tipo, Jugador? jugador}) {
    if (!partidoEmpezado) return;
    guardarEstado();

    if (equipoId == 1) {
      puntosA++;
      if (equipoQueSaca == 2) _rotar(1);
      equipoQueSaca = 1;
    } else {
      puntosB++;
      if (equipoQueSaca == 1) _rotar(2);
      equipoQueSaca = 2;
    }

    historialSets[setActual - 1].add({
      'equipo': equipoId,
      'marcador': '$puntosA - $puntosB',
      if (tipo != null) 'tipo': tipo.name,
      if (jugador != null) 'jugadorDorsal': jugador.dorsal,
      if (jugador != null) 'jugadorNombre': jugador.nombre,
      if (jugador != null) 'jugadorEquipoId': jugador.equipoId,
    });

    notifyListeners();

    int meta = (setActual == maxSets) ? puntosParaGanarUltimoSet : puntosParaGanarSet;
    bool setTerminado = modoMataMata
        ? (puntosA >= meta || puntosB >= meta)
        : ((puntosA >= meta || puntosB >= meta) && (puntosA - puntosB).abs() >= 2);

    if (setTerminado) {
      _finalizarSet();
    }
  }

  void _finalizarSet() {
    partidoEmpezado = false;
    cronometroSet.stop();
    
    if (puntosA > puntosB) {
      setsGanadosA++;
    } else {
      setsGanadosB++;
    }
    notifyListeners();
  }

  void avanzarSet() {
    if (setActual >= maxSets) return;
    
    guardarEstado();
    puntosA = 0;
    puntosB = 0;
    setActual++;
    
    // Reinicio de variables de control por set
    tiemposMuertosA = maxTiemposPorSet;
    tiemposMuertosB = maxTiemposPorSet;
    cambiosRealizadosA = 0;
    cambiosRealizadosB = 0;
    
    if (historialSets.length < setActual) historialSets.add([]);

    // Saque alternado automático entre sets
    final saque = _saqueInicial ?? 1;
    equipoQueSaca = (setActual % 2 != 0) ? saque : (saque == 1 ? 2 : 1);
    
    cronometroSet.reset(); 
    partidoEmpezado = false; // Espera a presionar "Iniciar Set"
    notifyListeners();
  }

  void iniciarSiguienteSet() {
    cronometroSet.start();
    partidoEmpezado = true;
    notifyListeners();
  }

  // -------------------------------------------------------
  // TIEMPOS MUERTOS Y CAMBIOS
  // -------------------------------------------------------
  void usarTiempoMuerto(int equipoId) {
    if (!partidoEmpezado) return;
    guardarEstado();
    if (equipoId == 1 && tiemposMuertosA > 0) tiemposMuertosA--;
    else if (equipoId == 2 && tiemposMuertosB > 0) tiemposMuertosB--;
    notifyListeners();
  }

  void devolverTiempoMuerto(int equipoId) {
    if (equipoId == 1) tiemposMuertosA++;
    else tiemposMuertosB++;
    notifyListeners();
  }

  bool realizarCambio(Jugador sale, Jugador entra) {
    int equipoId = sale.equipoId;
    int realizados = equipoId == 1 ? cambiosRealizadosA : cambiosRealizadosB;

    // REGLA: Si el partido está detenido (entre sets), el cambio es GRATIS (no suma al contador)
    bool esCambioGratis = !partidoEmpezado && puntosA == 0 && puntosB == 0;

    if (!cambiosInfinitos && !esCambioGratis && realizados >= cambiosMaximos) {
      return false;
    }

    guardarEstado();
    int posicionAnterior = sale.posicionCancha;
    sale.posicionCancha = 0;
    entra.posicionCancha = posicionAnterior;
    
    if (!esCambioGratis) {
      if (equipoId == 1) cambiosRealizadosA++;
      else cambiosRealizadosB++;
    }
    
    notifyListeners();
    return true;
  }

  // -------------------------------------------------------
  // PERSISTENCIA Y UNDO
  // -------------------------------------------------------
  void guardarEstado() {
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
      'tiemposA': tiemposMuertosA,
      'tiemposB': tiemposMuertosB,
      'cambiosA': cambiosRealizadosA,
      'cambiosB': cambiosRealizadosB,
      'historialSets': historialSets.map((s) => List<Map<String, dynamic>>.from(s)).toList(),
    });
  }

  bool deshacer() {
    if (_historial.isEmpty) return false;
    final prev = _historial.removeLast();

    puntosA = prev['puntosA'];
    puntosB = prev['puntosB'];
    setsGanadosA = prev['setsGanadosA'];
    setsGanadosB = prev['setsGanadosB'];
    setActual = prev['setActual'];
    equipoQueSaca = prev['equipoQueSaca'];
    partidoEmpezado = prev['partidoEmpezado'];
    tiemposMuertosA = prev['tiemposA'];
    tiemposMuertosB = prev['tiemposB'];
    cambiosRealizadosA = prev['cambiosA'];
    cambiosRealizadosB = prev['cambiosB'];
    
    historialSets = List<List<Map<String, dynamic>>>.from(
      prev['historialSets'].map((s) => List<Map<String, dynamic>>.from(s)),
    );

    final posiciones = prev['posiciones'] as List<int>;
    for (int i = 0; i < todosLosJugadores.length; i++) {
      todosLosJugadores[i].posicionCancha = posiciones[i];
    }

    notifyListeners();
    return true;
  }

  // -------------------------------------------------------
  // GESTIÓN JUGADORES Y UTILIDADES
  // -------------------------------------------------------
  void _rotar(int equipoId) {
    const mapa = {1: 6, 6: 5, 5: 4, 4: 3, 3: 2, 2: 1};
    for (var j in todosLosJugadores.where((j) => j.equipoId == equipoId && j.posicionCancha != 0)) {
      j.posicionCancha = mapa[j.posicionCancha]!;
    }
  }

  void reiniciar() {
    puntosA = 0; puntosB = 0;
    setsGanadosA = 0; setsGanadosB = 0;
    setActual = 1;
    tiemposMuertosA = maxTiemposPorSet;
    tiemposMuertosB = maxTiemposPorSet;
    cambiosRealizadosA = 0; cambiosRealizadosB = 0;
    partidoEmpezado = false;
    historialSets = [[]];
    _historial.clear();
    equipoQueSaca = null;
    _saqueInicial = null;
    mostrarSorteo = false;
    modoMataMata = false;
    cambiosInfinitos = false;
    cronometroSet.reset();
    notifyListeners();
  }

  // -------------------------------------------------------
  // PERSISTENCIA EN BASE DE DATOS
  // -------------------------------------------------------
  Future<int> guardarPartido({String notas = ''}) async {
    final db = DBManager();

    final partidoId = await db.crearPartido(
      nombreEquipoA: nombreEquipoA,
      nombreEquipoB: nombreEquipoB,
      notas: notas.isNotEmpty ? notas : null,
    );

    await db.actualizarMarcadorSets(partidoId, setsGanadosA, setsGanadosB);
    await db.finalizarPartido(partidoId);

    // Acumuladores de estadísticas por jugador (clave: "dorsal-equipoId"),
    // se rellenan con los puntos detallados que haya registrado Modo Pro.
    final Map<String, Map<String, int>> statsPorJugador = {};
    String claveJugador(int dorsal, int equipoId) => '$dorsal-$equipoId';

    for (int i = 0; i < historialSets.length; i++) {
      final set = historialSets[i];
      if (set.isEmpty) continue;
      final pA = set.where((p) => p['equipo'] == 1).length;
      final pB = set.where((p) => p['equipo'] == 2).length;
      final setId = await db.crearSet(partidoId, i + 1);
      await db.actualizarPuntosSet(setId, pA, pB);

      for (final punto in set) {
        final tipoNombre = punto['tipo'] as String?;
        if (tipoNombre == null) continue; // punto de Modo Cancha, sin detalle

        final tipo = TipoPuntoInfo.fromNombre(tipoNombre);
        await db.insertarPuntoPro({
          'partido_id': partidoId,
          'numero_set': i + 1,
          'equipo_id': punto['equipo'],
          'tipo': tipoNombre,
          'jugador_dorsal': punto['jugadorDorsal'],
          'jugador_nombre': punto['jugadorNombre'],
          'jugador_equipo_id': punto['jugadorEquipoId'],
          'marcador': punto['marcador'],
        });

        final campo = tipo.campoEstadistica;
        final dorsal = punto['jugadorDorsal'] as int?;
        final jugadorEquipoId = punto['jugadorEquipoId'] as int?;
        if (campo == null || dorsal == null || jugadorEquipoId == null) continue;

        final clave = claveJugador(dorsal, jugadorEquipoId);
        final stats = statsPorJugador.putIfAbsent(clave, () => {
              'aces': 0,
              'errores_saque': 0,
              'ataques': 0,
              'errores_ataque': 0,
              'bloqueos': 0,
              'recepciones': 0,
              'errores_recepcion': 0,
            });
        stats[campo] = (stats[campo] ?? 0) + 1;
      }
    }

    // Guardamos una fila de estadísticas por cada jugador actual, usando los
    // valores reales acumulados de Modo Pro (o ceros si no hubo detalle).
    for (final jugador in todosLosJugadores) {
      final clave = claveJugador(jugador.dorsal, jugador.equipoId);
      final stats = statsPorJugador[clave];
      await db.insertarEstadistica({
        'partido_id': partidoId,
        'jugador_nombre': jugador.nombre ?? 'Jugador',
        'dorsal': jugador.dorsal,
        'equipo_id': jugador.equipoId,
        'aces': stats?['aces'] ?? 0,
        'errores_saque': stats?['errores_saque'] ?? 0,
        'ataques': stats?['ataques'] ?? 0,
        'errores_ataque': stats?['errores_ataque'] ?? 0,
        'bloqueos': stats?['bloqueos'] ?? 0,
        'recepciones': stats?['recepciones'] ?? 0,
        'errores_recepcion': stats?['errores_recepcion'] ?? 0,
      });
    }

    return partidoId;
  }

  void abrirSorteo() {
    if (puntosA == 0 && puntosB == 0) {
      mostrarSorteo = true;
      notifyListeners();
    }
  }
  void cerrarSorteo() { mostrarSorteo = false; notifyListeners(); }
  void cambiarMaxSets(int v) { maxSets = v; notifyListeners(); }
  void toggleModoMataMata() { modoMataMata = !modoMataMata; notifyListeners(); }
  
  void eliminarJugador(Jugador jugador) {
    guardarEstado();
    todosLosJugadores.remove(jugador);
    notifyListeners();
  }

  void editarJugador(Jugador j, String n, int d) { 
    guardarEstado();
    j.nombre = n; j.dorsal = d; 
    notifyListeners(); 
  }
  
  void agregarJugador(int id, String n, int d) { 
    todosLosJugadores.add(Jugador(nombre: n, dorsal: d, equipoId: id, posicionCancha: 0));
    notifyListeners(); 
  }
}