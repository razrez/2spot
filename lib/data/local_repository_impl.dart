import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:to_spot/data/dto/spot_of_collection.dart';

import '../domain/entity/collection.dart';
import '../domain/entity/spot.dart';

class LocalDBRepository with ChangeNotifier{
  LocalDBRepository({required this.db}) {
    _loadData();
  }

  final Database db;

  List<Collection> _collections = [];
  List<Spot> _allSpots = [];
  List<SpotOfCollectionId> _spotsOfCollections = [];

  List<Collection> get collections => _collections;
  List<Spot> get spots => _allSpots;
  List<SpotOfCollectionId> get spotsOfCollections => _spotsOfCollections;

  Future<void> _loadData() async {
    final collectionsData = await db.query('collections');
    _collections = collectionsData.map((e) => Collection.fromMap(e)).toList();

    final spotsData = await db.query('spots');
    _allSpots = spotsData.map((e) => Spot.fromMap(e)).toList();

    final spotsOfCollectionsData = await db.query('spot_collections');
    _spotsOfCollections = spotsOfCollectionsData.map((e) => SpotOfCollectionId.fromMap(e)).toList();
    print(_spotsOfCollections.length);
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

  Future<void> addSpotToCollection(Collection selectedCollection, Spot spot) async {
    final res = await db.insert(
      'spot_collections',
      {
        'collection_id': selectedCollection.id,
        'spot_id': spot.id
      },
    );
    print("addSpotToCollection result: ${res}"); // 0 - an error code

    _spotsOfCollections.add(
        SpotOfCollectionId(collectionId: selectedCollection.id!, spotId: spot.id!)
    );

    notifyListeners();
  }

  Future<void> removeSpotFromCollection(Collection collectionRemove, Spot spot) async {
    final res = await db.delete(
      'spot_collections',
      where: 'collection_id = ? AND spot_id = ?',
      whereArgs: [collectionRemove.id, spot.id],
    );
    print("removeSpotFromCollection result: ${res}");

    _spotsOfCollections.remove(
        SpotOfCollectionId(collectionId: collectionRemove.id!, spotId: spot.id!)
    );

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

  Future<void> updateCollectionInfo(Collection updateCollection) async {
    await db.update(
      'collections', updateCollection.toMap(),
      where: 'id = ?',
      whereArgs: [updateCollection.id],
    );

    final oldCollectionVersion = _collections.firstWhere((c) => c.id == updateCollection.id);
    _collections.remove(oldCollectionVersion);

    _collections.add(updateCollection);
    notifyListeners();
  }
}