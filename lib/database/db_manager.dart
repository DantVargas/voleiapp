import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBManager {
  static Database? _database;

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
            nombre TEXT NOT NULL,
            dorsal INTEGER,
            posicion TEXT,
            esCapitan INTEGER,
            FOREIGN KEY (equipo_id) REFERENCES equipos (id) ON DELETE SET NULL
          )
        ''');
      },
    );
  }
}