class SpotOfCollectionId {
  SpotOfCollectionId({
    required this.collectionId,
    required this.spotId
  });

  final int collectionId;
  final int spotId;

  factory SpotOfCollectionId.fromMap(Map<String, dynamic> map) {
    return SpotOfCollectionId(
        collectionId: map['collection_id'] as int,
        spotId: map['spot_id'] as int
    );
  }
}