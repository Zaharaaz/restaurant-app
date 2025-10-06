import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/provider/restaurantdetail_provider.dart';
import 'package:restaurant_app/provider/local_database_provider.dart';
import 'package:restaurant_app/data/model/restaurant.dart';

class DetailScreen extends StatefulWidget {
  final String id;

  const DetailScreen({super.key, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<RestaurantDetailProvider>().fetchRestaurantDetail(widget.id);
      context.read<LocalDatabaseProvider>().isFavorited(widget.id);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Restoran"),
        actions: [
          Consumer2<RestaurantDetailProvider, LocalDatabaseProvider>(
            builder: (context, detailProvider, dbProvider, _) {
              if (detailProvider.state != DetailResultState.hasData ||
                  detailProvider.detail == null) {
                return const SizedBox();
              }

              final detail = detailProvider.detail!.restaurant;

              return FutureBuilder<bool>(
                future: dbProvider.isFavorited(detail.id),
                builder: (context, snapshot) {
                  final isFav = snapshot.data ?? false;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context); // ✅ aman

                      if (isFav) {
                        await dbProvider.removeFavorite(detail.id);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Dihapus dari Favorit")),
                        );
                      } else {
                        final restaurantToSave = Restaurant(
                          id: detail.id,
                          name: detail.name,
                          description: detail.description,
                          pictureId: detail.pictureId,
                          city: detail.city,
                          address: detail.address,
                          rating: detail.rating,
                        );

                        await dbProvider.addFavorite(restaurantToSave);
                        if (!mounted) return;
                        messenger.showSnackBar(
                          const SnackBar(content: Text("Ditambahkan ke Favorit")),
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<RestaurantDetailProvider>(
        builder: (context, state, _) {
          if (state.state == DetailResultState.loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state.state == DetailResultState.hasData) {
            if (state.detail == null) {
              return const Center(child: Text('Data restoran tidak tersedia'));
            }

            final detail = state.detail!.restaurant;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      RestaurantApiService().getImageLarge(detail.pictureId),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                      errorBuilder: (c, e, st) => Container(
                        width: double.infinity,
                        height: 220,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nama restoran
                  Text(
                    detail.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi
                  Text(detail.description),
                  const Divider(height: 32),

                  // Rating, alamat
                  Text("Rating: ${detail.rating}"),
                  Text("Kota: ${detail.city}"),
                  Text("Alamat: ${detail.address}"),
                  const Divider(height: 32),

                  // Kategori
                  Text(
                    "Kategori: ${detail.categories.map((c) => c.name).join(', ')}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Divider(height: 32),

                  // Menu makanan
                  Text(
                    "Menu Makanan",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: detail.menus.foods
                        .map((food) => Chip(label: Text(food.name)))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Menu minuman
                  Text(
                    "Menu Minuman",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    children: detail.menus.drinks
                        .map((drink) => Chip(label: Text(drink.name)))
                        .toList(),
                  ),
                  const Divider(height: 32),

                  // Customer Reviews
                  Text(
                    "Review Pelanggan",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Column(
                    children: detail.customerReviews
                        .map(
                          (review) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(review.name),
                              subtitle: Text(review.review),
                              trailing: Text(review.date),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Divider(height: 32),

                  // Form Tambah Review
                  Text(
                    "Tambah Review",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewController,
                    decoration: const InputDecoration(
                      labelText: "Komentar",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () async {
                      if (_nameController.text.isNotEmpty &&
                          _reviewController.text.isNotEmpty) {
                        final messenger =
                            ScaffoldMessenger.of(context); // ✅ aman

                        await state.addReview(
                          widget.id,
                          _nameController.text,
                          _reviewController.text,
                        );

                        if (!mounted) return;

                        _nameController.clear();
                        _reviewController.clear();

                        messenger.showSnackBar(
                          const SnackBar(
                            content: Text("Review berhasil ditambahkan"),
                          ),
                        );
                      }
                    },
                    child: const Text("Kirim Review"),
                  ),
                ],
              ),
            );
          } else if (state.state == DetailResultState.error) {
            return Center(child: Text(state.message));
          } else if (state.state == DetailResultState.noData) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('Unknown state'));
          }
        },
      ),
    );
  }
}
