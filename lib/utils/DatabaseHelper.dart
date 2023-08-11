import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  DatabaseHelper.internal();

  Future<Database> initDatabase() async {
    // Get the path for storing the database file
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    String path = join(appDirectory.path, 'myapp_companies_data.db');

    // Open the database or create if it doesn't exist
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Create the table for storing company data
  void _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS companydata (
        id INTEGER PRIMARY KEY,
        company_name TEXT NOT NULL,
        date DATE NOT NULL
      )
    ''');
  }

  // Insert a new company with date into the database
  Future<int> insertCompany(String name, DateTime date) async {
    Database db = await database;
    Map<String, dynamic> company = {
      'company_name': name,
      'date': DateFormat('yyyy-MM-dd').format(date),
    };
    return await db.insert('companydata', company);
  }

  // Delete a company from the database
  Future<int> deleteCompany(String companyName) async {
    Database db = await database;
    return await db.delete(
      'companydata',
      where: 'company_name = ?',
      whereArgs: [companyName],
    );
  }

  // Retrieve all companies from the database
  Future<List<Map<String, dynamic>>> getAllCompanies() async {
    Database db = await database;
    return await db.query('companydata');
  }

  static Future<void> copyPrepopulatedDatabase() async {
    Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocumentsDirectory.path, 'myapp_companies_data.db');

    // Check if the database already exists
    if (!(await File(dbPath).exists())) {
      // Copy the prepopulated database from assets
      ByteData data = await rootBundle.load('assets/CompanyData.db');
      List<int> bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes);
    }
  }
}
