
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/entity/collection.dart';
import '../domain/entity/spot.dart';

class LocalDBRepository with ChangeNotifier{
  LocalDBRepository({required this.db}) {
    _loadData();
  }

  final Database db;

  List<Collection> _collections = [];
  List<Spot> _allSpots = [];

  List<Collection> get collections => _collections;
  List<Spot> get spots => _allSpots;

  Future<void> _loadData() async {
    final collectionsData = await db.query('collections');
    _collections = collectionsData.map((e) => Collection.fromMap(e)).toList();

    final spotsData = await db.query('spots');
    _allSpots = spotsData.map((e) => Spot.fromMap(e)).toList();

    for (final collection in _collections){
      final idsOfSpotsCollection = await db
          .rawQuery('SELECT spot_collections.spot_id FROM spot_collections '
          'WHERE collection_id = ${collection.id}');

      var ids = idsOfSpotsCollection.map((map) => { map['spot_id'] as int}).toList();
      collection.spots.addAll(_allSpots.where((spot) => ids.contains(spot.id)));
    }

    notifyListeners();
  }

  Future<void> addSpot(Spot spot) async {
    final id = await db.insert('spots', spot.toMap());
    spot.id = id;
    _allSpots.add(spot);
    notifyListeners();
  }

  Future<void> removeSpot(Spot spot) async {
    await db.delete(
      'spots',
      where: 'id = ?',
      whereArgs: [spot.id],
    );

    _allSpots.remove(spot);
    notifyListeners();
  }

  Future<void> addCollection(Collection collection) async {
    final id = await db.insert('collections', collection.toMap());

    collection.id = id;
    _collections.add(collection);
    notifyListeners();
  }

  Future<void> removeCollection(Collection collection) async {
    await db.delete(
      where: 'id = ?',
      'collections',
      whereArgs: [collection.id],
    );

    _collections.remove(collection);
    notifyListeners();
  }

  Future<void> addSpotToCollection(int collectionId, Spot spot) async {
    await db.insert(
      'spot_collections',
      {
        'collectionId': collectionId,
        'spot_id': spot.id
      },
    );

    final collection = _collections.firstWhere((c) => c.id == collectionId);
    collection.spots.add(spot);
    notifyListeners();
  }

  Future<void> removeSpotFromCollection(int collectionId, Spot spot) async {
    await db.delete(
      'spot_collections',
      where: 'collectionId = ? AND spotId = ?',
      whereArgs: [collectionId, spot.id],
    );

    final collection = _collections.firstWhere((c) => c.id == collectionId);
    collection.spots.remove(spot);
    notifyListeners();
  }

  Future<void> updateSpot(Spot updatedSpot) async {
    await db.update(
      'spots', updatedSpot.toMap(),
      where: 'id = ?',
      whereArgs: [updatedSpot.id],
    );

    final oldSpotVersion = _allSpots.firstWhere((c) => c.id == updatedSpot.id);
    _allSpots.remove(oldSpotVersion);

    _allSpots.add(updatedSpot);
    notifyListeners();
  }

}