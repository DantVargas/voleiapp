import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBManager {
  static final DBManager _instance = DBManager._internal();
  factory DBManager() => _instance;
  DBManager._internal();

  static Database? _database;

  // -------------------------------------------------------
  // CONFIGURACIÓN
  // -------------------------------------------------------

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'voleiapp.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _crearTablas,
      onUpgrade: _migrar,
    );
  }

  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE equipos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        categoria TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE jugadores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        equipo_id INTEGER,
        nombre TEXT,
        dorsal INTEGER NOT NULL,
        posicion_juego TEXT,
        posicion_cancha INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (equipo_id) REFERENCES equipos(id) ON DELETE SET NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE partidos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre_equipo_a TEXT NOT NULL,
        nombre_equipo_b TEXT NOT NULL,
        fecha TEXT NOT NULL,
        sets_a INTEGER NOT NULL DEFAULT 0,
        sets_b INTEGER NOT NULL DEFAULT 0,
        estado TEXT NOT NULL DEFAULT "en_curso",
        notas TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partido_id INTEGER NOT NULL,
        numero_set INTEGER NOT NULL,
        puntos_a INTEGER NOT NULL DEFAULT 0,
        puntos_b INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (partido_id) REFERENCES partidos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE estadisticas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partido_id INTEGER NOT NULL,
        jugador_nombre TEXT NOT NULL,
        dorsal INTEGER NOT NULL DEFAULT 0,
        equipo_id INTEGER NOT NULL,
        aces INTEGER NOT NULL DEFAULT 0,
        errores_saque INTEGER NOT NULL DEFAULT 0,
        ataques INTEGER NOT NULL DEFAULT 0,
        errores_ataque INTEGER NOT NULL DEFAULT 0,
        bloqueos INTEGER NOT NULL DEFAULT 0,
        recepciones INTEGER NOT NULL DEFAULT 0,
        errores_recepcion INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (partido_id) REFERENCES partidos(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE puntos_pro (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        partido_id INTEGER NOT NULL,
        numero_set INTEGER NOT NULL,
        equipo_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        jugador_dorsal INTEGER,
        jugador_nombre TEXT,
        jugador_equipo_id INTEGER,
        complejo INTEGER,
        marcador TEXT NOT NULL,
        FOREIGN KEY (partido_id) REFERENCES partidos(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _migrar(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE partidos ADD COLUMN notas TEXT');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS estadisticas (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          partido_id INTEGER NOT NULL,
          jugador_nombre TEXT NOT NULL,
          dorsal INTEGER NOT NULL DEFAULT 0,
          equipo_id INTEGER NOT NULL,
          aces INTEGER NOT NULL DEFAULT 0,
          errores_saque INTEGER NOT NULL DEFAULT 0,
          ataques INTEGER NOT NULL DEFAULT 0,
          errores_ataque INTEGER NOT NULL DEFAULT 0,
          bloqueos INTEGER NOT NULL DEFAULT 0,
          recepciones INTEGER NOT NULL DEFAULT 0,
          errores_recepcion INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (partido_id) REFERENCES partidos(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS puntos_pro (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          partido_id INTEGER NOT NULL,
          numero_set INTEGER NOT NULL,
          equipo_id INTEGER NOT NULL,
          tipo TEXT NOT NULL,
          jugador_dorsal INTEGER,
          jugador_nombre TEXT,
          jugador_equipo_id INTEGER,
          complejo INTEGER,
          marcador TEXT NOT NULL,
          FOREIGN KEY (partido_id) REFERENCES partidos(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 5 && oldVersion >= 4) {
      await db.execute('ALTER TABLE puntos_pro ADD COLUMN complejo INTEGER');
    }
  }

  // -------------------------------------------------------
  // EQUIPOS
  // -------------------------------------------------------

  Future<int> insertarEquipo(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('equipos', row);
  }

  Future<List<Map<String, dynamic>>> obtenerEquipos() async {
    final db = await database;
    return await db.query('equipos');
  }

  // -------------------------------------------------------
  // JUGADORES
  // -------------------------------------------------------

  Future<int> insertarJugador(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('jugadores', row);
  }

  Future<List<Map<String, dynamic>>> obtenerJugadoresPorEquipo(int equipoId) async {
    final db = await database;
    return await db.query(
      'jugadores',
      where: 'equipo_id = ?',
      whereArgs: [equipoId],
    );
  }

  Future<void> actualizarJugador(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('jugadores', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarJugador(int id) async {
    final db = await database;
    await db.delete('jugadores', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> cambiarJugadores(int idEntra, int idSale, int posicion) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('jugadores', {'posicion_cancha': 0},
          where: 'id = ?', whereArgs: [idSale]);
      await txn.update('jugadores', {'posicion_cancha': posicion},
          where: 'id = ?', whereArgs: [idEntra]);
    });
  }

  // -------------------------------------------------------
  // PARTIDOS
  // -------------------------------------------------------

  Future<int> crearPartido({
    required String nombreEquipoA,
    required String nombreEquipoB,
    String? notas,
  }) async {
    final db = await database;
    return await db.insert('partidos', {
      'nombre_equipo_a': nombreEquipoA,
      'nombre_equipo_b': nombreEquipoB,
      'fecha': DateTime.now().toIso8601String(),
      'sets_a': 0,
      'sets_b': 0,
      'estado': 'en_curso',
      'notas': notas,
    });
  }

  Future<List<Map<String, dynamic>>> obtenerPartidos() async {
    final db = await database;
    return await db.query('partidos', orderBy: 'fecha DESC');
  }

  Future<Map<String, dynamic>?> obtenerPartido(int id) async {
    final db = await database;
    final res = await db.query('partidos', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<void> actualizarPartido(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('partidos', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> actualizarMarcadorSets(int partidoId, int setsA, int setsB) async {
    final db = await database;
    await db.update(
      'partidos',
      {'sets_a': setsA, 'sets_b': setsB},
      where: 'id = ?',
      whereArgs: [partidoId],
    );
  }

  Future<void> finalizarPartido(int partidoId) async {
    final db = await database;
    await db.update(
      'partidos',
      {'estado': 'finalizado'},
      where: 'id = ?',
      whereArgs: [partidoId],
    );
  }

  Future<void> eliminarPartido(int id) async {
    final db = await database;
    await db.delete('partidos', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------------------------------------
  // SETS
  // -------------------------------------------------------

  Future<int> crearSet(int partidoId, int numeroSet) async {
    final db = await database;
    return await db.insert('sets', {
      'partido_id': partidoId,
      'numero_set': numeroSet,
      'puntos_a': 0,
      'puntos_b': 0,
    });
  }

  Future<void> actualizarPuntosSet(int setId, int puntosA, int puntosB) async {
    final db = await database;
    await db.update(
      'sets',
      {'puntos_a': puntosA, 'puntos_b': puntosB},
      where: 'id = ?',
      whereArgs: [setId],
    );
  }

  Future<void> actualizarSet(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('sets', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> obtenerSetsPorPartido(int partidoId) async {
    final db = await database;
    return await db.query(
      'sets',
      where: 'partido_id = ?',
      whereArgs: [partidoId],
      orderBy: 'numero_set ASC',
    );
  }

  // -------------------------------------------------------
  // ESTADÍSTICAS
  // -------------------------------------------------------

  Future<int> insertarEstadistica(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('estadisticas', row);
  }

  Future<List<Map<String, dynamic>>> obtenerEstadisticasPorPartido(int partidoId) async {
    final db = await database;
    return await db.query(
      'estadisticas',
      where: 'partido_id = ?',
      whereArgs: [partidoId],
      orderBy: 'equipo_id ASC, jugador_nombre ASC',
    );
  }

  Future<void> actualizarEstadistica(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('estadisticas', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> eliminarEstadistica(int id) async {
    final db = await database;
    await db.delete('estadisticas', where: 'id = ?', whereArgs: [id]);
  }

  // -------------------------------------------------------
  // PUNTOS PRO (detalle punto a punto de Modo Pro)
  // -------------------------------------------------------

  Future<int> insertarPuntoPro(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('puntos_pro', row);
  }

  Future<List<Map<String, dynamic>>> obtenerPuntosProPorPartido(int partidoId) async {
    final db = await database;
    return await db.query(
      'puntos_pro',
      where: 'partido_id = ?',
      whereArgs: [partidoId],
      orderBy: 'id ASC',
    );
  }
}