import 'dart:io';

import 'package:dxb_llegada/Models/Llegada.dart';
import 'package:dxb_llegada/Models/LlegadaMaraton.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';

class LlegadaDB {
  LlegadaDB._();

  static final LlegadaDB db = LlegadaDB._();
  Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await getDatabaseInstance();
    return _database;
  }

  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, "llegadasssssssss.db");
    return await openDatabase(path, version: 4,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE LlegadaMaraton ("
          "id integer primary key unique,"
          "idPunto integer,"
          "idUser integer,"
          "numCorredor text,"
          "tiempoLlegada text,"
          "registrado integer"
          ");");
      await db.execute("CREATE TABLE Llegada ("
          "id integer primary key unique,"
          "numCorredor text,"
          "tiempoLlegada text,"
          "respuestasCorrectas integer,"
          "registrado integer"
          ");");
    });
  }

  //Query LLEGADAS
  Future<List<Llegada>> getLlegadas() async {
    final db = await database;
    var result = await db.query("Llegada");
    List<Llegada> list = result.map((c) => Llegada.fromMap(c)).toList();
    return list;
  }

  //Query LLEGADAMARATON
  Future<List<LlegadaMaraton>> getLlegadasMaraton() async {
    final db = await database;
    var result = await db.query("LlegadaMaraton");
    List<LlegadaMaraton> list =
        result.map((c) => LlegadaMaraton.fromMap(c)).toList();
    return list;
  }

  //Query
  Future<Llegada> getLlegada(int id) async {
    final db = await database;
    var result = await db.query("Llegada", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? Llegada.fromMap(result.first) : null;
  }

  //Query
  Future<LlegadaMaraton> getLlegadaMaraton(int id) async {
    final db = await database;
    var result =
        await db.query("LlegadaMaraton", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? LlegadaMaraton.fromMap(result.first) : null;
  }

//Query
  Future<LlegadaMaraton> getLlegadaByEquipo(String numCorredor) async {
    final db = await database;
    var result = await db
        .query("Llegada", where: "numCorredor = ?", whereArgs: [numCorredor]);
    return result.isNotEmpty ? LlegadaMaraton.fromMap(result.first) : null;
  }

  //Insert
  addLlegada(Llegada llegada) async {
    final db = await database;
    /*var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Llegada");
    int id = table.first["id"];
    llegada.id = id;*/
    var raw = await db.insert(
      "Llegada",
      llegada.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  //Insert
  addLlegadaMaraton(LlegadaMaraton llegada) async {
    final db = await database;
    /*var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Llegada");
    int id = table.first["id"];
    llegada.id = id;*/
    var raw = await db.insert(
      "LlegadaMaraton",
      llegada.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  //Delete
  //Delete client with id
  deleteLlegada(int id) async {
    final db = await database;
    return db.delete("Llegada", where: "id = ?", whereArgs: [id]);
  }

  //Delete
  //Delete client with id
  deleteLlegadaMaraton(int id) async {
    final db = await database;
    return db.delete("LlegadaMaraton", where: "id = ?", whereArgs: [id]);
  }

  //Delete all clients
  dropLlegada() async {
    final db = await database;
    db.delete("Llegada");
    //db.rawQuery("DROP TABLE DatosLlegada");
  }

//Delete all clients
  dropLlegadaMaraton() async {
    final db = await database;
    db.delete("LlegadaMaraton");
    //db.rawQuery("DROP TABLE DatosLlegada");
  }

//Update
  updateLlegada(int id, String numCorredor, int registrado) async {
    final db = await database;
    var result = await db.update(
        'Llegada', {'numCorredor': numCorredor, 'registrado': registrado},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

//Update
  updateLlegadaMaraton(int id, String numCorredor, int registrado) async {
    final db = await database;
    var result = await db.update('LlegadaMaraton',
        {'numCorredor': numCorredor, 'registrado': registrado},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Update
  updateEquipo(int id, String numCorredor) async {
    final db = await database;
    var result = await db.update('Llegada', {'numCorredor': numCorredor},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Update
  updateBolsas(int id, int bolsasCompletadas) async {
    final db = await database;
    var result = await db.update(
        'Llegada', {'bolsasCompletadas': bolsasCompletadas},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Update
  updateRespuestas(int id, int respuestas) async {
    final db = await database;
    var result = await db.update('Llegada', {'respuestasCorrectas': respuestas},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
