import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_spot/presentation/components/app_navbar.dart';
import 'data/local_repository_impl.dart';

void main() async {
  // the WidgetsFlutterBinding.ensureInitialized method is only
  // necessary when running Flutter code outside of the Flutter framework,
  // such as in a console or command-line application.
  WidgetsFlutterBinding.ensureInitialized();

  final db = await openDatabase(
    join(await getDatabasesPath(), 'toSpots.db'),
    onCreate: (db, version) async {
      await db.execute('CREATE TABLE IF NOT EXISTS spots(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, coordinates TEXT NOT NULL)');
      await db.execute('CREATE TABLE IF NOT EXISTS collections(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, description TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS spot_collections '
          '(collection_id INTEGER NOT NULL,spot_id INTEGER NOT NULL,PRIMARY KEY (collection_id, spot_id),'
          'FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE CASCADE,'
          'FOREIGN KEY (spot_id) REFERENCES spots(id) ON DELETE CASCADE)');
      await db.execute('INSERT INTO spot_collections (collection_id, spot_id) VALUES (1, 1);');
    },
    version: 1,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocalDBRepository(db: db)),
      ],
      child: const MyApp(),
    ),
  );
}


/// root App widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2 Spot',
      theme: ThemeData(useMaterial3: true),
      home: const AppNavigation(),
    );
  }
}
