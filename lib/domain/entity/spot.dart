import 'dart:typed_data';

class Spot {
  Spot({
    this.id,
    required this.name,
    required this.coordinates,
    this.image
  });

  int? id;
  final String name;
  final String coordinates;
  Uint8List? image;

  factory Spot.fromMap(Map<String, dynamic> map) {
    return Spot(
      id: map['id'] as int?,
      name: map['name'] as String,
      coordinates: map['coordinates'] as String,
      image: map['image'], // Retrieve the image from the BLOB
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'coordinates': coordinates,
      'image': image, // Store the image as a BLOB
    };
  }
}