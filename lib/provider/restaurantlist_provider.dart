import 'package:flutter/material.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/restaurant_list.dart';

enum ResultState { loading, noData, hasData, error }

class RestaurantListProvider extends ChangeNotifier {
  final RestaurantApiService apiService;

  RestaurantListProvider({required this.apiService}) {
    fetchAllRestaurant();
  }

  RestaurantList _restaurantResult = RestaurantList(
  error: false,
  message: '',
  count: 0,
  restaurants: [],
  );  
  
  ResultState _state = ResultState.loading;
  String _message = '';

  RestaurantList get result => _restaurantResult;
  ResultState get state => _state;
  String get message => _message;

  /// Fetch semua restoran
  Future<void> fetchAllRestaurant() async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final restaurant = await apiService.getRestaurantList();
      _restaurantResult = RestaurantList.fromJson(restaurant);

      if (_restaurantResult.restaurants.isEmpty) {
        _state = ResultState.noData;
        _message = 'Tidak ada restoran ditemukan';
      } else {
        _state = ResultState.hasData;
      }
      notifyListeners();
    } catch (e) {
      _state = ResultState.error;
      _message = 'Gagal memuat data: $e';
      notifyListeners();
    }
  }

  /// Search restoran
  Future<void> searchRestaurant(String query) async {
    try {
      _state = ResultState.loading;
      notifyListeners();

      final restaurant = await apiService.searchRestaurant(query);
      _restaurantResult = RestaurantList.fromJson(restaurant);

      if (_restaurantResult.restaurants.isEmpty) {
        _state = ResultState.noData;
        _message = 'Restoran tidak ditemukan';
      } else {
        _state = ResultState.hasData;
      }
      notifyListeners();
    } catch (e) {
      _state = ResultState.error;
      _message = 'Gagal mencari restoran: $e';
      notifyListeners();
    }
  }
}
