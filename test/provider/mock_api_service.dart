import 'package:restaurant_app/data/api/api_service.dart';

class MockApiService extends RestaurantApiService {
  bool shouldFail; 
  final Map<String, dynamic> mockResponse;

  MockApiService({
    required this.shouldFail, 
    Map<String, dynamic>? mockResponse,
  }) : mockResponse = mockResponse ?? {
          "error": false,
          "message": "success",
          "count": 2,
          "restaurants": [
            {
              "id": "rqdv5juczeskfw1e867",
              "name": "Melting Pot",
              "description": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...",
              "pictureId": "14",
              "city": "Medan",
              "rating": 4.2
            },
            {
              "id": "s1knt6za9kkfw1e867",
              "name": "Kafe Kita",
              "description": "Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. ...",
              "pictureId": "25",
              "city": "Gorontalo",
              "rating": 4.0
            }
          ]
        };

  @override
  Future<Map<String, dynamic>> getRestaurantList() async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFail) {
      throw Exception('Failed to fetch restaurants');
    }

    return mockResponse;
  }

  @override
  Future<Map<String, dynamic>> getRestaurantDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFail) {
      throw Exception('Failed to fetch restaurant detail');
    }

    return {
      "error": false,
      "message": "success",
      "restaurant": {
        "id": id,
        "name": "Melting Pot",
        "description": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...",
        "city": "Medan",
        "address": "Jln. Pandeglang no 19",
        "pictureId": "14",
        "rating": 4.2,
        "categories": [
          {"name": "Italia"}
        ],
        "menus": {
          "foods": [
            {"name": "Paket rosemary"},
            {"name": "Toastie salmon"}
          ],
          "drinks": [
            {"name": "Es krim"},
            {"name": "Sirup"}
          ]
        },
        "customerReviews": [
          {
            "name": "Ahmad",
            "review": "Tidak rekomendasi untuk pelajar!",
            "date": "13 November 2019"
          }
        ]
      }
    };
  }

  @override
  Future<Map<String, dynamic>> searchRestaurant(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFail) {
      throw Exception('Failed to search restaurants');
    }

    return {
      "error": false,
      "message": "success",
      "count": 1,
      "restaurants": [
        {
          "id": "rqdv5juczeskfw1e867",
          "name": "Melting Pot",
          "description": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. ...",
          "pictureId": "14",
          "city": "Medan",
          "rating": 4.2
        }
      ]
    };
  }

  @override
  Future<Map<String, dynamic>> addReview({
    required String id,
    required String name,
    required String review,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (shouldFail) {
      throw Exception('Failed to add review');
    }

    return {
      "error": false,
      "message": "success",
      "customerReviews": [
        {
          "name": name,
          "review": review,
          "date": "13 November 2019"
        }
      ]
    };
  }

  @override
  String getImageSmall(String pictureId) => 'https://restaurant-api.dicoding.dev/images/small/$pictureId';

  @override
  String getImageMedium(String pictureId) => 'https://restaurant-api.dicoding.dev/images/medium/$pictureId';

  @override
  String getImageLarge(String pictureId) => 'https://restaurant-api.dicoding.dev/images/large/$pictureId';
}