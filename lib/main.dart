import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('SQLite Example'),
        ),
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Database? db;
  List<String> names = [];

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'my_database.db');
    db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE names(id INTEGER PRIMARY KEY, name TEXT)',
        );
      },
    );
    refreshNames();
  }

  Future<void> refreshNames() async {
    final namesFromDB = await db!.query('names');
    setState(() {
      names = namesFromDB.map((item) => item['name'] as String).toList();
    });
  }

  Future<void> addName(String name) async {
    await db!.insert('names', {'name': name});
    refreshNames();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: names.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(names[index]));
            },
          ),
        ),
        TextField(
          onSubmitted: addName,
          decoration: InputDecoration(
            labelText: 'Enter name',
            contentPadding: EdgeInsets.all(8.0),
          ),
        ),
      ],
    );
  }
}
