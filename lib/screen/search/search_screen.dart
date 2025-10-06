import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/provider/restaurantlist_provider.dart';
import 'package:restaurant_app/provider/restaurantdetail_provider.dart';
import 'package:restaurant_app/screen/detail/detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearch(RestaurantListProvider provider) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      provider.searchRestaurant(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantListProvider(apiService: RestaurantApiService()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Cari Restoran')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Consumer<RestaurantListProvider>(
                builder: (context, provider, _) {
                  return TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearch(provider),
                    decoration: InputDecoration(
                      hintText: "Masukkan nama restoran...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          provider.fetchAllRestaurant();
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<RestaurantListProvider>(
                builder: (context, state, _) {
                  if (state.state == ResultState.loading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state.state == ResultState.hasData) {
                    return ListView.builder(
                      itemCount: state.result.restaurants.length,
                      itemBuilder: (context, index) {
                        final restaurant = state.result.restaurants[index];

                        return ListTile(
                          leading: Image.network(
                            RestaurantApiService().getImageSmall(
                              restaurant.pictureId,
                            ),
                            width: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 50,
                              );
                            },
                          ),
                          title: Text(restaurant.name),
                          subtitle: Text(
                            '${restaurant.city} • ⭐ ${restaurant.rating}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider(
                                  create: (_) => RestaurantDetailProvider(
                                    apiService: RestaurantApiService(),
                                  ),
                                  child: DetailScreen(id: restaurant.id),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  } else if (state.state == ResultState.noData) {
                    return Center(child: Text(state.message));
                  } else if (state.state == ResultState.error) {
                    return Center(child: Text(state.message));
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
