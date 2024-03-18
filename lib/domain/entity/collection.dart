import 'package:to_spot/domain/entity/spot.dart';


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