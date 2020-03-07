import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:dxb_llegada/DatosLlegada.dart';

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
    String path = join(directory.path, "llegadasss.db");
    return await openDatabase(path, version: 4,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE DatosLlegada ("
          "id integer primary key unique,"
          "numEquipo integer,"
          "tiempoLlegada integer,"
          "registrado integer"
          ")");
    });
  }

  //Query
  Future<List<DatosLlegada>> getLlegadas() async {
    final db = await database;
    var result = await db.query("DatosLlegada");
    List<DatosLlegada> list =
        result.map((c) => DatosLlegada.fromMap(c)).toList();
    return list;
  }

  //Query
  Future<DatosLlegada> getLlegada(int id) async {
    final db = await database;
    var result =
        await db.query("DatosLlegada", where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? DatosLlegada.fromMap(result.first) : null;
  }

//Query
  Future<DatosLlegada> getLlegadaByEquipo(int numEquipo) async {
    final db = await database;
    var result = await db
        .query("DatosLlegada", where: "numEquipo = ?", whereArgs: [numEquipo]);
    return result.isNotEmpty ? DatosLlegada.fromMap(result.first) : null;
  }

  //Insert
  addLlegada(DatosLlegada llegada) async {
    final db = await database;
    /*var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Llegada");
    int id = table.first["id"];
    llegada.id = id;*/
    var raw = await db.insert(
      "DatosLlegada",
      llegada.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return raw;
  }

  //Delete
  //Delete client with id
  deleteLlegada(int id) async {
    final db = await database;
    return db.delete("DatosLlegada", where: "id = ?", whereArgs: [id]);
  }

  //Delete all clients
  resetDB() async {
    final db = await database;
    db.delete("DatosLlegada");
    //db.rawQuery("DROP TABLE DatosLlegada");
  }

//Update
  updateLlegada(int id, int numEquipo, int registrado) async {
    final db = await database;
    var result = await db.update(
        'DatosLlegada', {'numEquipo': numEquipo, 'registrado': registrado},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Update
  updateEquipo(int id, int numEquipo) async {
    final db = await database;
    var result = await db.update('DatosLlegada', {'numEquipo': numEquipo},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Update
  updateBolsas(int id, int bolsasCompletadas) async {
    final db = await database;
    var result = await db.update(
        'DatosLlegada', {'bolsasCompletadas': bolsasCompletadas},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }

  //Update
  updateRespuestas(int id, int respuestas) async {
    final db = await database;
    var result = await db.update(
        'DatosLlegada', {'respuestasCorrectas': respuestas},
        where: 'id = ?', whereArgs: [id]);
    return result;
  }
}
