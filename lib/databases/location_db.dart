// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:runex/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class LocationDatabase {
  LocationDatabase._privateConstructor();
  static final LocationDatabase instance =
      LocationDatabase._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ?? await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'location.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static const TABLE_NAME = 'location';
  static const PRIMARY_COLUMN = 'PRIMARY KEY AUTOINCREMENT';
  static const INT_TYPE = 'INTEGER';
  static const TEXT_TYPE = 'TEXT';
  static const NOT_NULL = 'NOT NULL';

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE_NAME(
        id INTEGER PRIMARY KEY,
        latitude $TEXT_TYPE $NOT_NULL,
        longitude $TEXT_TYPE $NOT_NULL,
        timestamp $TEXT_TYPE $NOT_NULL,
        runex_id $INT_TYPE $NOT_NULL,
        FOREIGN KEY (runex_id) REFERENCES runex (id)
      )
    ''');
  }

  Future<int> create(Location location) async {
    Database db = await instance.database;
    return await db.insert(TABLE_NAME, location.toJson());
  }

  Future<List<Location>> read() async {
    Database db = await instance.database;
    var locations = await db.query(TABLE_NAME, columns: ['*'], orderBy: 'id');
    print('Location in db: $locations');

    List<Location> locationList = locations.isNotEmpty
        ? locations.map((e) => Location.fromJson(e)).toList()
        : [];

    return locationList;
  }

  Future<List<Location>> readByRunexId(int runexId) async {
    Database db = await instance.database;
    var locations = await db.query(TABLE_NAME, columns: ['*'], where: 'runex_id = ?',whereArgs: [runexId], orderBy: 'id');
    print('Location in db: $locations');

    List<Location> locationList = locations.isNotEmpty
        ? locations.map((e) => Location.fromJson(e)).toList()
        : [];

    return locationList;
  }



  Future<int> update(Location location) async {
    Database db = await instance.database;
    return await db.update(TABLE_NAME, location.toJson(),
        where: 'id = ?', whereArgs: [location.id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_NAME, where: 'id = ?', whereArgs: [id]);
  }
}
