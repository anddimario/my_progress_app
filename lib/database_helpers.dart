import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// database table and column names
final String tableActivities = 'activities';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnSchedule = 'schedule';
final String columnGoal = 'goal';

// https://pusher.com/tutorials/local-data-flutter

// data model class
class Activity {
  int id;
  String title;
  int schedule;
  String goal;

  Activity();

  // convenience constructor to create a Activity object
  Activity.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    title = map[columnTitle];
    schedule = map[columnSchedule];
    goal = map[columnGoal];
  }

  // convenience method to create a Map from this Activity object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnTitle: title,
      columnSchedule: schedule,
      columnGoal: goal
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static final _databaseName = "MyDatabase.db";
  // Increment this version when you need to change the schema.
  static final _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableActivities (
                $columnId INTEGER PRIMARY KEY,
                $columnTitle TEXT NOT NULL,
                $columnSchedule INTEGER NOT NULL,
                $columnGoal TEXT NOT NULL
              )
              ''');
  }

  // Database helper methods:

  Future<int> insert(Activity activity) async {
    Database db = await database;
    int id = await db.insert(tableActivities, activity.toMap());
    return id;
  }

  Future<Activity> queryActivity(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(tableActivities,
        columns: [columnId, columnTitle, columnSchedule, columnGoal],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Activity.fromMap(maps.first);
    }
    return null;
  }

  // queryAllActivities()
  Future<List<Map>> queryAllActivities() async {
    Database db = await database;
    List<Map> listActivities = await db.query(
      tableActivities,
      columns: [columnId, columnTitle, columnSchedule, columnGoal],
    );
    if (listActivities.length > 0) {
      return listActivities;
    }
    return null;
  }

  Future<int> update(Activity activity) async {
    Database db = await database;
    return await db.update(tableActivities, activity.toMap(), 
    where: '$columnId = ?', whereArgs: [activity.id]);
  }
  
  Future<int> delete(int id) async {
    Database db = await database;
    return await db.delete(tableActivities, where: '$columnId = ?', whereArgs: [id]);
  }

}
