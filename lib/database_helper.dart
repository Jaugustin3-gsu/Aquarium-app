import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'aquarium.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE Settings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fish_count INTEGER,
            default_speed REAL,
            default_color INTEGER
          )
        ''');
      },
    );
  }

  Future<void> saveSettings(int fishCount, double speed, int color) async {
    final db = await database;

    // Check if there's already an entry, if so, update it
    final result = await db.query('Settings');
    if (result.isNotEmpty) {
      await db.update(
        'Settings',
        {'fish_count': fishCount, 'default_speed': speed, 'default_color': color},
      );
    } else {
      await db.insert('Settings', {
        'fish_count': fishCount,
        'default_speed': speed,
        'default_color': color,
      });
    }
  }

  Future<Map<String, dynamic>?> loadSettings() async {
    final db = await database;
    final result = await db.query('Settings');
    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }
}
