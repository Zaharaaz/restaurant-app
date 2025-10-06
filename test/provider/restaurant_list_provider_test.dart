import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/provider/restaurantlist_provider.dart';
import 'package:restaurant_app/data/restaurant_list.dart';
import 'mock_api_service.dart';

void main() {
  group('RestaurantListProvider - Skenario 1: State Awal', () {
    test('Provider harus berhasil dibuat dan memiliki state yang terdefinisi', () {
      // Arrange & Act
      final mockApiService = MockApiService(shouldFail: false);
      final provider = RestaurantListProvider(apiService: mockApiService);
      
      // Assert
      expect(provider, isNotNull);
      expect(provider.state, isA<ResultState>());
      expect(provider.message, isA<String>());
      expect(provider.result, isA<RestaurantList>());
    });
  });

  group('RestaurantListProvider - Skenario 2: API Success', () {
    test('Harus mengembalikan daftar restoran ketika pengambilan data API berhasil', () async {
      // Arrange
      final mockApiService = MockApiService(shouldFail: false);
      final provider = RestaurantListProvider(apiService: mockApiService);
      
      // Act
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Assert
      expect(provider.state, ResultState.hasData);
      expect(provider.message, isEmpty);
      expect(provider.result.restaurants, isNotEmpty);
      expect(provider.result.restaurants.length, 2);
      
      final firstRestaurant = provider.result.restaurants[0];
      expect(firstRestaurant.id, 'rqdv5juczeskfw1e867');
      expect(firstRestaurant.name, 'Melting Pot');
      expect(firstRestaurant.city, 'Medan');
      expect(firstRestaurant.rating, 4.2);
      
      final secondRestaurant = provider.result.restaurants[1];
      expect(secondRestaurant.id, 's1knt6za9kkfw1e867');
      expect(secondRestaurant.name, 'Kafe Kita');
      expect(secondRestaurant.city, 'Gorontalo');
      expect(secondRestaurant.rating, 4.0);
      
      expect(provider.result.error, false);
      expect(provider.result.message, 'success');
      expect(provider.result.count, 2);
    });

    test('Harus mempertahankan data restoran setelah refresh', () async {
      // Arrange
      final mockApiService = MockApiService(shouldFail: false);
      final provider = RestaurantListProvider(apiService: mockApiService);
      
      await Future.delayed(const Duration(milliseconds: 300));
      final initialCount = provider.result.count;
      
      // Act
      await provider.fetchAllRestaurant();
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Assert
      expect(provider.state, ResultState.hasData);
      expect(provider.result.restaurants, isNotEmpty);
      expect(provider.result.count, initialCount);
    });

    test('Harus handle response dengan data restoran kosong', () async {

      final mockApiService = MockApiService(
        shouldFail: false,
        mockResponse: {
          "error": false,
          "message": "success",
          "count": 0,
          "restaurants": []
        },
      );
      
      final provider = RestaurantListProvider(apiService: mockApiService);
      
      // Act
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Assert
      expect(provider.state, ResultState.noData);
      expect(provider.message, 'Tidak ada restoran ditemukan');
      expect(provider.result.restaurants, isEmpty);
      expect(provider.result.count, 0);
    });
  });

  group('RestaurantListProvider - Skenario 3: API Error', () {
  test('Harus mengembalikan kesalahan ketika pengambilan data API gagal', () async {
    final mockApiService = MockApiService(shouldFail: true);
    final provider = RestaurantListProvider(apiService: mockApiService);
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    expect(provider.state, ResultState.error);
    expect(provider.message, contains('Gagal memuat data'));
    expect(provider.result.restaurants, isEmpty);
  });

  test('Harus handle berbagai jenis exception dengan benar', () async {
    final mockApiService = MockApiService(shouldFail: true);
    final provider = RestaurantListProvider(apiService: mockApiService);
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    expect(provider.state, ResultState.error);
    expect(provider.message, contains('Failed to fetch restaurants'));
  });


  test('Harus bisa recover dari error setelah retry berhasil', () async {
 
    final mockApiService = MockApiService(shouldFail: true);
    final provider = RestaurantListProvider(apiService: mockApiService);
    

    await Future.delayed(const Duration(milliseconds: 300));
    expect(provider.state, ResultState.error);
    

    expect(provider.message, isNotEmpty);
    expect(provider.result.restaurants, isEmpty);
  });

  test('Harus handle network error scenario', () async {
    final mockApiService = MockApiService(shouldFail: true);
    final provider = RestaurantListProvider(apiService: mockApiService);
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    expect(provider.state, ResultState.error);
    expect(provider.message, isNotEmpty);
  });

  test('Search restaurant harus handle error dengan benar', () async {

    final mockApiService = MockApiService(shouldFail: true);
    final provider = RestaurantListProvider(apiService: mockApiService);
    
    await Future.delayed(const Duration(milliseconds: 300));
    expect(provider.state, ResultState.error); 
    

    expect(provider.message, contains('Gagal memuat data'));
    });
  });
}