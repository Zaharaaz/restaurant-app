import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class RestaurantApiService {
  static const String _baseUrl = 'https://restaurant-api.dicoding.dev';
  static const String _imageSmall = '$_baseUrl/images/small/';
  static const String _imageMedium = '$_baseUrl/images/medium/';
  static const String _imageLarge = '$_baseUrl/images/large/';

// getter URL gambar
  String getImageSmall(String pictureId) => '$_imageSmall$pictureId';
  String getImageMedium(String pictureId) => '$_imageMedium$pictureId';
  String getImageLarge(String pictureId) => '$_imageLarge$pictureId';

// get daftar restoran
  Future<Map<String, dynamic>> getRestaurantList() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/list'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": true, "message": "Gagal memuat daftar restoran"};
      }
    } on SocketException {
      return {"error": true, "message": "Tidak ada koneksi internet"};
    } catch (e) {
      return {"error": true, "message": "Terjadi kesalahan: $e"};
    }
  }

// get detail restoran berdasarkan ID
  Future<Map<String, dynamic>> getRestaurantDetail(String id) async {
    try {
      final response = await http.get(Uri.parse("$_baseUrl/detail/$id"));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": true, "message": "Gagal memuat detail restoran"};
      }
    } on SocketException {
      return {"error": true, "message": "Tidak ada koneksi internet"};
    } catch (e) {
      return {"error": true, "message": "Terjadi kesalahan: $e"};
    }
  }

// cari restoran
  Future<Map<String, dynamic>> searchRestaurant(String query) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search?q=$query'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"error": true, "message": "Gagal mencari restoran"};
      }
    } on SocketException {
      return {"error": true, "message": "Tidak ada koneksi internet"};
    } catch (e) {
      return {"error": true, "message": "Terjadi kesalahan: $e"};
    }
  }

// tambah review
  Future<Map<String, dynamic>> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/review'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id, 'name': name, 'review': review}),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {"error": true, "message": "Gagal menambahkan review"};
      }
    } on SocketException {
      return {"error": true, "message": "Tidak ada koneksi internet"};
    } catch (e) {
      return {"error": true, "message": "Terjadi kesalahan: $e"};
    }
  }
}
