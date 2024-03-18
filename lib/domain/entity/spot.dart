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