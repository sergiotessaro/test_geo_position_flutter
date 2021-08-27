

import 'package:projeto_geoposic/device/database/constants.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

class DatabaseHandler {
  static Database? _db;
  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    String dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, "geoposic.db");
    var theDb = await openDatabase(path,
        version: 1, onCreate: _onCreate, onUpgrade: _onUpgrade);
    return theDb;
  }

  void _onUpgrade(Database db, int a, int version) async {}

  void _onCreate(Database db, int version) async {
    await db.execute(geoPosicTable);
  }
}