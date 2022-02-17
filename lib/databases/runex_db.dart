// ignore_for_file: constant_identifier_names

import 'dart:io';

import 'package:runex/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class RunexDatabase {
  RunexDatabase._privateConstructor();
  static final RunexDatabase instance = RunexDatabase._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ?? await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentDirectory.path, 'runex.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  static const TABLE_NAME = 'runex';
  static const PRIMARY_COLUMN = 'PRIMARY KEY';
  static const INT_TYPE = 'INTEGER';
  static const TEXT_TYPE = 'TEXT';
  static const BOOLEAN_TYPE = 'BOOLEAN';
  static const NOT_NULL = 'NOT NULL';

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $TABLE_NAME(
        id $INT_TYPE $PRIMARY_COLUMN,
        timestamp $TEXT_TYPE $NOT_NULL,
        is_saved $BOOLEAN_TYPE $NOT_NULL
      )
    ''');
  }

  Future<int> create(Runex runex) async {
    Database db = await instance.database;
    return await db.insert(TABLE_NAME, runex.toJson());
  }

  Future<List<Runex>> read() async {
    Database db = await instance.database;
    var runex = await db.query(TABLE_NAME, columns: ['*'], orderBy: 'id');
    List<Runex> runexList = runex.isNotEmpty
        ? runex.map((e) => Runex.fromJson(e)).toList()
        : [];
    return runexList;
  }

  Future<int> update(Runex runex) async {
    Database db = await instance.database;
    return await db.update(TABLE_NAME, runex.toJson(),
        where: 'id = ?', whereArgs: [runex.id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_NAME, where: 'id = ?', whereArgs: [id]);
  }
}
