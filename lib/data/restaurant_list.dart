// To parse this JSON data, do
//
//     final restaurantList = restaurantListFromJson(jsonString);

import 'dart:convert';

RestaurantList restaurantListFromJson(String str) =>
    RestaurantList.fromJson(json.decode(str));

String restaurantListToJson(RestaurantList data) => json.encode(data.toJson());

class RestaurantList {
  bool error;
  String message;
  int count;
  List<Restaurant> restaurants;

  RestaurantList({
    required this.error,
    required this.message,
    required this.count,
    required this.restaurants,
  });

  factory RestaurantList.fromJson(Map<String, dynamic> json) => RestaurantList(
    error: json["error"] ?? false,
    message: json["message"] ?? '',
    count: json["count"] ?? 0,
    restaurants: json["restaurants"] != null
        ? List<Restaurant>.from(
            json["restaurants"].map((x) => Restaurant.fromJson(x)),
          )
        : [],
  );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "count": count,
    "restaurants": List<dynamic>.from(restaurants.map((x) => x.toJson())),
  };
}

class Restaurant {
  String id;
  String name;
  String description;
  String pictureId;
  String city;
  double rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.pictureId,
    required this.city,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) => Restaurant(
    id: json["id"] ?? '',
    name: json["name"] ?? '',
    description: json["description"] ?? '',
    pictureId: json["pictureId"] ?? '',
    city: json["city"] ?? '',
    rating: (json["rating"] is int)
        ? (json["rating"] as int).toDouble()
        : (json["rating"] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "description": description,
    "pictureId": pictureId,
    "city": city,
    "rating": rating,
  };
}
