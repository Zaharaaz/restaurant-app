import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_app/provider/restaurantdetail_provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/screen/detail/detail_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String restaurantId;

  const LoadingScreen({super.key, required this.restaurantId});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();

    // fetch data detail restoran
    final provider = RestaurantDetailProvider(
      apiService: RestaurantApiService(),
    );

    provider.fetchRestaurantDetail(widget.restaurantId).then((_) {
      if (!mounted) return;

      // kalau sukses, langsung ganti ke DetailScreen bawa providernya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: provider,
            child: DetailScreen(id: widget.restaurantId),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Memuat Data Restoran...", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
