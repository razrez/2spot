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
  List<Spot> _spots = [];

  List<Collection> get collections => _collections;
  List<Spot> get spots => _spots;

  Future<void> _loadData() async {
    final collectionsData = await db.query('collections');
    _collections = collectionsData.map((e) => Collection.fromMap(e)).toList();

    final spotsData = await db.query('spots');
    _spots = spotsData.map((e) => Spot.fromMap(e)).toList();

    /// TODO(инит списка спотов для каждой подборки)
    // for (final collection in _collections){
    //   /// db.query('table', columns: ['group'], where: '"group" = ?', whereArgs: ['my_group']);
    //   /// select id from 'spot_collections' where colle
    //   final spotsOfCollectionData = await db.rawQuery('');
    //   collection.spots.addAll(spotsOfCollectionData.map((e) => Spot.fromMap(e)).toList());
    // }

    notifyListeners();
  }

  Future<void> addSpot(Spot spot) async {
    final id = await db.insert('spots', spot.toMap());
    spot.id = id;
    _spots.add(spot);
    notifyListeners();
  }

  Future<void> removeSpot(Spot spot) async {
    await db.delete(
      'spots',
      where: 'id = ?',
      whereArgs: [spot.id],
    );

    _spots.remove(spot);
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
      'collections',
      where: 'id = ?',
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

}