import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'catatan.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;
  static Database _database;

  String catatanTable = 'catatan_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'catatan.db';

    var catatanDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return catatanDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $catatanTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, '
        '$colDescription TEXT, $colDate TEXT)');
  }

  Future<List<Map<String, dynamic>>> getCatatanMapList() async {
    Database db = await this.database;

    var result = await db.query(catatanTable, orderBy: '$colTitle ASC');
    return result;
  }

  Future<int> insertCatatan(Catatan catatan) async {
    Database db = await this.database;
    var result = await db.insert(catatanTable, catatan.toMap());
    return result;
  }

  Future<int> updateCatatan(Catatan catatan) async {
    var db = await this.database;
    var result = await db.update(catatanTable, catatan.toMap(),
        where: '$colId = ?', whereArgs: [catatan.id]);
    return result;
  }

  Future<int> updateCatatanCompleted(Catatan catatan) async {
    var db = await this.database;
    var result = await db.update(catatanTable, catatan.toMap(),
        where: '$colId = ?', whereArgs: [catatan.id]);
    return result;
  }

  Future<int> deleteCatatan(int id) async {
    var db = await this.database;
    int result =
        await db.rawDelete('DELETE FROM $catatanTable WHERE $colId = $id');
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $catatanTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Catatan>> getListCatatan() async {
    var catatanMapList = await getCatatanMapList();
    int count = catatanMapList.length;

    List<Catatan> catatanList = List<Catatan>();
    for (int i = 0; i < count; i++) {
      catatanList.add(Catatan.fromMapObject(catatanMapList[i]));
    }

    return catatanList;
  }
}
