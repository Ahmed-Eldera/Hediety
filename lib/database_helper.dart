import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('events.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE events (
      id TEXT PRIMARY KEY,
      name TEXT,
      author TEXT,
      description TEXT,
      location TEXT,
      date TEXT,
      time TEXT,
      category TEXT
    )
    ''');
  }

  Future<void> insertEvent(Map<String, dynamic> event) async {
    final db = await instance.database;
    await db.insert('events', event, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getEvents() async {
    final db = await instance.database;
    return await db.query('events');
  }

  Future<void> deleteEvent(String id) async {
    final db = await instance.database;
    await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
  Future<int> updateEvent(Map<String, dynamic> event) async {
  final db = await instance.database;

  return await db.update(
    'events', // Table name
    {
      'name': event['name'],
      'location': event['location'],
      'date': event['date'],
      'time': event['time'],
      'author': event['author'],
      'description': event['description'],
      'category': event['category'],
    },
    where: 'id = ?',
    whereArgs: [event['id']], // The ID of the event to update
  );
}

}
