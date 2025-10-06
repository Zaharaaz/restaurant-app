import 'dart:convert';

/// Model Restaurant
class Restaurant {
  final String id;
  final String name;
  final String description;
  final String pictureId;
  final String city;
  final String address;
  final double rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.address,
    required this.rating,
  });

  /// Convert dari JSON API
  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      pictureId: json['pictureId'],
      city: json['city'],
      address: json['address'] ?? "",
      rating: (json['rating'] is int)
          ? (json['rating'] as int).toDouble()
          : (json['rating'] as num).toDouble(),
    );
  }

  /// Convert ke Map (untuk SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pictureId': pictureId,
      'city': city,
      'address': address,
      'rating': rating,
    };
  }

  /// Convert dari Map SQLite
  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      pictureId: map['pictureId'],
      city: map['city'],
      address: map['address'],
      rating: (map['rating'] as num).toDouble(),
    );
  }

  /// Alias: convert ke JSON (sama dengan toMap)
  Map<String, dynamic> toJson() => toMap();

  /// Alias: dari JSON ke Restaurant (sama dengan fromMap)
  factory Restaurant.fromDatabaseJson(Map<String, dynamic> json) =>
      Restaurant.fromMap(json);

  /// Untuk debug
  @override
  String toString() {
    return jsonEncode(toMap());
  }
}
