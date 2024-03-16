import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:to_spot/navbar.dart';

// entry point, prefs, db
void main() async {
  // the WidgetsFlutterBinding.ensureInitialized method is only
  // necessary when running Flutter code outside of the Flutter framework,
  // such as in a console or command-line application.
  WidgetsFlutterBinding.ensureInitialized();

  final db = await openDatabase(
    join(await getDatabasesPath(), 'to_spot.db'),
    onCreate: (db, version) async {
      await db.execute('CREATE TABLE IF NOT EXISTS spots(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, coordinates TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS collections(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, spotId integer, description TEXT)');
      await db.execute('CREATE TABLE IF NOT EXISTS spot_collections(id INTEGER PRIMARY KEY AUTOINCREMENT, collectionId INTEGER FOREIGN KEY FROM collections, spotId INTEGER FOREIGN KEY FROM spots)');
    },
    version: 1,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Spots(db: db)),
        ChangeNotifierProvider(create: (context) => Collections(db: db)),
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


/// Page widgets
class SpotsListPage extends StatelessWidget {
  const SpotsListPage({super.key});

  @override
  Widget build(BuildContext context) {

    // data load
    Provider.of<Spots>(context, listen: false).loadData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Spots'),
      ),
      body: Consumer<Spots>(
        builder: (context, favorites, child) => ListView.builder(
          itemCount: favorites.items.length,
          itemBuilder: (context, index) {
            final item = favorites.items[index];
            return ListTile(
              onTap: () => const AlertDialog.adaptive(
                title: Text('AlertDialog Title'),
                content: Text('AlertDialog description'),
              ),
              title: Text(item.name),
              subtitle: Text(item.coordinates),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => favorites.remove(item),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SpotPage()),
        ),
        tooltip: 'Add Spot',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SpotPage extends StatefulWidget {
  const SpotPage({super.key});

  @override
  State<SpotPage> createState() => _SpotPageState();
}

class CollectionsListPage extends StatelessWidget{
  const CollectionsListPage({super.key});

  @override
  Widget build(BuildContext context) {

    // data load
    Provider.of<Collections>(context, listen: false).loadData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Spots'),
      ),
      body: Consumer<Collections>(
        builder: (context, collections, child) => ListView.builder(
          itemCount: collections.collections.length,
          itemBuilder: (context, index) {
            final collection = collections.collections[index];
            return Column(
              children: [
                ListTile(
                  title: Text(collection.name),
                  subtitle: Text(collection.description),
                ),
                Column(
                  children: collection.spots.map((spot) {
                    return ListTile(
                      title: Text(spot.name),
                      subtitle: Text(spot.coordinates),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CollectionPage()),
        ),
        tooltip: 'Add Spot',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}


/// Page States Management
class _SpotPageState extends State<SpotPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _coordinatesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Spot'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Location Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _coordinatesController,
                decoration: const InputDecoration(labelText: 'Coordinates'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter coordinates';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final coordinates = _coordinatesController.text;
                    Provider.of<Spots>(context,listen: false).add(
                      Spot(id: null, name: name, coordinates: coordinates),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionPageState extends State<CollectionPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Collection'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Collection Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a collection name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text;
                    final description = _descriptionController.text;
                    Provider.of<Collections>(context,listen: false).addCollection(
                      Collection(id: null, name: name, description: description),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// ViewModel or repo
class Collections with ChangeNotifier {
  Collections({required this.db});

  final Database db;

  List<Collection> _collections = [];

  List<Collection> get collections => _collections;

  Future<void> addCollection(Collection collection) async {
    final id = await db.insert('collections', collection.toMap());

    collection.id = id;
    _collections.add(collection);
    notifyListeners();
  }

  Future<void> removeCollection(Collection collection) async {
    await db.delete(
      'collections',
      where: 'id = ?',
      whereArgs: [collection.id],
    );

    _collections.remove(collection);
    notifyListeners();
  }

  Future<void> addSpotToCollection(int collectionId, Spot spot) async {
    await db.insert(
      'favorites',
      {
        'collectionId': collectionId,
        'name': spot.name,
        'coordinates': spot.coordinates,
      },
    );

    final collection = _collections.firstWhere((c) => c.id == collectionId);
    collection.spots.add(spot);
    notifyListeners();
  }

  Future<void> removeSpotFromCollection(int collectionId, Spot spot) async {
    await db.delete(
      'favorites',
      where: 'collectionId = ? AND name = ? AND coordinates = ?',
      whereArgs: [collectionId, spot.name, spot.coordinates],
    );

    final collection = _collections.firstWhere((c) => c.id == collectionId);
    collection.spots.remove(spot);
    notifyListeners();
  }

  Future<void> loadData() async {
    final collectionsData = await db.query('collections');
    _collections = collectionsData.map((e) => Collection.fromMap(e)).toList();

    final spotsData = await db.query('favorites');
    for (final spotData in spotsData) {
      final collection = _collections.firstWhere((c) => c.id == spotData['collectionId']);
      collection.spots.add(Spot.fromMap(spotData));
    }

    notifyListeners();
  }
}

class Spots with ChangeNotifier {
  Spots({required this.db});


  final Database db;

  List<Spot> _items = [];

  List<Spot> get items => _items;

  Future<void> add(Spot location) async {
    final id = await db.insert('favorites', location.toMap());
    location.id = id;
    _items.add(location);
    notifyListeners();
  }

  Future<void> remove(Spot location) async {
    await db.delete(
      'favorites',
      where: 'id = ?',
      whereArgs: [location.id],
    );
    _items.remove(location);
    notifyListeners();
  }

  Future<void> loadData() async {
    final data = await db.query('favorites');
    _items = data.map((e) => Spot.fromMap(e)).toList();
    notifyListeners();
  }

}


/// core entities
class Collection {
  Collection({
    this.id,
    required this.name,
    required this.description,
  });

  int? id;
  final String name;
  final String description;
  final List<Spot> spots= [];

  factory Collection.fromMap(Map<String, dynamic> map) {
    return Collection(
      id: map['id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}

class Spot {
  Spot({
    this.id,
    required this.name,
    required this.coordinates,
  });

  int? id;
  final String name;
  final String coordinates;

  factory Spot.fromMap(Map<String, dynamic> map) {
    return Spot(
      id: map['id'] as int?,
      name: map['name'] as String,
      coordinates: map['coordinates'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coordinates': coordinates,
    };
  }
}