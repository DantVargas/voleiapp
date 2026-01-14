import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBManager {
  static Database? _database;

  // --- CONFIGURACIÓN Y APERTURA ---

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'voleiapp.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 1. Tabla Equipos
        await db.execute('''
          CREATE TABLE equipos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT NOT NULL,
            categoria TEXT
          )
        ''');

        // 2. Tabla Jugadores
        await db.execute('''
          CREATE TABLE jugadores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            equipo_id INTEGER,
            nombre TEXT,
            dorsal INTEGER NOT NULL,
            posicion_juego TEXT, 
            posicion_cancha INTEGER NOT NULL, 
            FOREIGN KEY (equipo_id) REFERENCES equipos (id) ON DELETE SET NULL
          )
        ''');
      },
    );
  }

  // --- OPERACIONES (CRUD Y LÓGICA) ---

  /// Cambio de jugador de la banca por uno de la cancha
  Future<void> cambiarJugadores(int idEntra, int idSale, int posicion) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // 1. El que sale va a la banca (posición 0)
      await txn.update(
        'jugadores', 
        {'posicion_cancha': 0}, 
        where: 'id = ?', 
        whereArgs: [idSale],
      );
          
      // 2. El que entra toma la posición en la cancha (1-6)
      await txn.update(
        'jugadores', 
        {'posicion_cancha': posicion}, 
        where: 'id = ?', 
        whereArgs: [idEntra],
      );
    });
  }

  /// Método para insertar jugadores inicialmente
  Future<int> insertarJugador(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('jugadores', row);
  }
}