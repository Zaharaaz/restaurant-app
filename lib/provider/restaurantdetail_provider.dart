import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/data/restaurant_detail.dart';

enum DetailResultState { loading, hasData, error, noData }

class RestaurantDetailProvider extends ChangeNotifier {
  final RestaurantApiService apiService;

  RestaurantDetailProvider({required this.apiService});

  RestaurantDetail? _restaurantDetail; 
  DetailResultState _state = DetailResultState.loading;
  String _message = '';

  RestaurantDetail? get detail => _restaurantDetail;
  DetailResultState get state => _state;
  String get message => _message;

// Fetch detail restoran
  Future<void> fetchRestaurantDetail(String id) async {
    try {
      _state = DetailResultState.loading;
      _message = '';
      notifyListeners();

      final restaurant = await apiService.getRestaurantDetail(id);
      
// validasi data bukan null
      if (restaurant['restaurant'] != null) {
        _restaurantDetail = RestaurantDetail.fromJson(restaurant);
        _state = DetailResultState.hasData;
      } else {
        _state = DetailResultState.noData;
        _message = 'Data restoran tidak ditemukan';
      }
      
      notifyListeners();
    } catch (e) {
      _state = DetailResultState.error;
      _message = 'Gagal memuat detail restoran: $e';
      notifyListeners();

      developer.log(
        'Error fetching restaurant detail: $e',
        name: 'RestaurantDetailProvider',
        error: e,
      ); 
    }
  }

// Add Review
  Future<void> addReview(String id, String name, String review) async {
    try {
      _state = DetailResultState.loading;
      notifyListeners();

      await apiService.addReview(id: id, name: name, review: review);


      await fetchRestaurantDetail(id);
    } catch (e) {
      _state = DetailResultState.error;
      _message = "Gagal menambahkan review: $e";
      notifyListeners();
    }
  }
}