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
        _id $INT_TYPE $PRIMARY_COLUMN,
        provider_id $TEXT_TYPE $NOT_NULL,
        start_time $TEXT_TYPE $NOT_NULL,
        end_time $TEXT_TYPE,
        distance_total_km $TEXT_TYPE,
        time_total_hours $TEXT_TYPE,
        is_saved $BOOLEAN_TYPE $NOT_NULL,
        _doc_id $TEXT_TYPE,
        month_and_year $TEXT_TYPE $NOT_NULL,
        pace $TEXT_TYPE,
        calories $TEXT_TYPE
      )
    ''');
  }

  Future<int> create(Runex runex) async {
    Database db = await instance.database;
    return await db.insert(TABLE_NAME, runex.toJson());
  }

  Future<List<Runex>> read() async {
    Database db = await instance.database;
    var runex = await db.query(TABLE_NAME, columns: ['*'], orderBy: '_id');
    List<Runex> runexList =
        runex.isNotEmpty ? runex.map((e) => Runex.fromJson(e)).toList() : [];
    return runexList;
  }

  Future<int> getLength() async {
    Database db = await instance.database;
    var runex = await db.query(TABLE_NAME, columns: ['*'], orderBy: '_id');
    List<Runex> runexList =
        runex.isNotEmpty ? runex.map((e) => Runex.fromJson(e)).toList() : [];
    return runexList.length;
  }

  Future<List<Runex>> readById(int id) async {
    Database db = await instance.database;
    var runex = await db.query(TABLE_NAME,
        columns: ['*'], where: '_id = ?', whereArgs: [id]);
    List<Runex> runexList =
        runex.isNotEmpty ? runex.map((e) => Runex.fromJson(e)).toList() : [];
    return runexList;
  }

  Future<List<Runex>> readByProviderId(String providerId) async {
    Database db = await instance.database;
    var runex = await db.query(TABLE_NAME,
        columns: ['*'],
        where: 'provider_id = ?',
        whereArgs: [providerId],
        orderBy: '_id');
    List<Runex> runexList =
        runex.isNotEmpty ? runex.map((e) => Runex.fromJson(e)).toList() : [];
    return runexList;
  }

  Future<List<MonthAndYear>> readByMonthAndYear(String providerId) async {
    Database db = await instance.database;
    var runex = await db.query(TABLE_NAME,
        columns: [
          'month_and_year, SUM(distance_total_km) as distance_total, COUNT(*) as runex_conunt, SUM(time_total_hours) as time_total, SUM(calories) as calories_total'
        ],
        where: 'provider_id = ?',
        whereArgs: [providerId],
        groupBy: 'month_and_year',
        orderBy: '_id');
    List<MonthAndYear> runexList = runex.isNotEmpty
        ? runex.map((e) => MonthAndYear.fromJson(e)).toList()
        : [];
    return runexList;
  }

  Future<int> update(Runex runex) async {
    Database db = await instance.database;
    return await db.update(TABLE_NAME, runex.toJson(),
        where: '_id = ?', whereArgs: [runex.id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(TABLE_NAME, where: '_id = ?', whereArgs: [id]);
  }
}
