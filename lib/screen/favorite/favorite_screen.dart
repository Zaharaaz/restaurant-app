import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/provider/local_database_provider.dart';
import 'package:restaurant_app/provider/restaurantdetail_provider.dart';
import 'package:restaurant_app/screen/detail/detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<LocalDatabaseProvider>().getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Restoran Favorit"),
      ),
      body: Consumer<LocalDatabaseProvider>(
        builder: (context, provider, _) {
          if (provider.state == ResultState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (provider.state == ResultState.hasData) {
            return ListView.builder(
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final restaurant = provider.favorites[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        RestaurantApiService()
                            .getImageSmall(restaurant.pictureId),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      restaurant.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle:
                        Text('${restaurant.city} • ⭐ ${restaurant.rating}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider(
                            create: (_) => RestaurantDetailProvider(
                              apiService: RestaurantApiService(),
                            ),
                            child: DetailScreen(id: restaurant.id),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (provider.state == ResultState.noData) {
            return Center(
              child: Text(
                provider.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          } else if (provider.state == ResultState.error) {
            return Center(
              child: Text(
                provider.message,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    );
  }
}
