import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:recetasapp/models/resena.dart';
import 'package:flutter/foundation.dart';

class ResenaService {
  static final ResenaService instance = ResenaService._init();

  static Database? _database;

  ResenaService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('recetas.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _crearTablas(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS reviews');
        await db.execute('DROP TABLE IF EXISTS resenas');
        await _crearTablas(db);
      },
    );
  }

  Future<void> _crearTablas(Database db) async {
    await db.execute('''
      CREATE TABLE resenas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recetaId INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        comentario TEXT NOT NULL,
        calificacion INTEGER NOT NULL,
        fecha TEXT NOT NULL
      )
    ''');
  }

  Future<void> guardarResena(Resena resena) async {
    final db = await database;

    final id = await db.insert('resenas', resena.toMap());

    debugPrint('ID de reseña guardada: $id');
    debugPrint('ID de receta: ${resena.recetaId}');
  }

  Future<List<Resena>> obtenerResenas(int recetaId) async {
    final db = await database;

    final resultado = await db.query(
      'resenas',
      where: 'recetaId = ?',
      whereArgs: [recetaId],
      orderBy: 'id DESC',
    );

    return resultado.map((map) => Resena.fromMap(map)).toList();
  }
}