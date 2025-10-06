import 'package:flutter/material.dart';
import 'package:restaurant_app/database/db_helper.dart';
import 'package:restaurant_app/data/model/restaurant.dart';

enum ResultState { loading, noData, hasData, error }

class LocalDatabaseProvider extends ChangeNotifier {
  final DbHelper dbHelper;

  LocalDatabaseProvider({required this.dbHelper});

  ResultState? _state;
  ResultState? get state => _state;

  String _message = "";
  String get message => _message;

  List<Restaurant> _favorites = [];
  List<Restaurant> get favorites => _favorites;

//ambil semua restoran favorit
  Future<void> getFavorites() async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final data = await dbHelper.getFavorites();
      if (data.isEmpty) {
        _state = ResultState.noData;
        _message = "Belum ada restoran favorit.";
      } else {
        _state = ResultState.hasData;
        _favorites = data;
      }
    } catch (e) {
      _state = ResultState.error;
      _message = "Terjadi kesalahan: $e";
    }
    notifyListeners();
  }

//tambah ke favorit
  Future<void> addFavorite(Restaurant restaurant) async {
    try {
      await dbHelper.insertFavorite(restaurant);
      await getFavorites();
    } catch (e) {
      _state = ResultState.error;
      _message = "Gagal menambahkan ke favorit: $e";
      notifyListeners();
    }
  }

//hapus dari favorit
  Future<void> removeFavorite(String id) async {
    try {
      await dbHelper.removeFavorite(id);
      await getFavorites();
    } catch (e) {
      _state = ResultState.error;
      _message = "Gagal menghapus dari favorit: $e";
      notifyListeners();
    }
  }

//cek fav apa enggak
  Future<bool> isFavorited(String id) async {
    return await dbHelper.isFavorited(id);
  }
}
