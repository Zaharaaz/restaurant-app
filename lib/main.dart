import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:restaurant_app/notification/notification_helper.dart';
import 'package:restaurant_app/provider/navigation_provider.dart';
import 'package:restaurant_app/provider/restaurantlist_provider.dart';
import 'package:restaurant_app/provider/local_database_provider.dart';
import 'package:restaurant_app/provider/settings_provider.dart';
import 'package:restaurant_app/provider/theme_provider.dart';
import 'package:restaurant_app/data/api/api_service.dart';
import 'package:restaurant_app/database/db_helper.dart';
import 'package:restaurant_app/screen/home/home_screen.dart';
import 'package:restaurant_app/screen/favorite/favorite_screen.dart';
import 'package:restaurant_app/screen/reminder/setting_screen.dart';
import 'package:restaurant_app/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi timezone untuk notifikasi terjadwal
  tz.initializeTimeZones();
  
  // Inisialisasi notifikasi
  await NotificationHelper.init();
  
  // Set orientasi portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatelessWidget {
  const RestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RestaurantListProvider(
            apiService: RestaurantApiService(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalDatabaseProvider(
            dbHelper: DbHelper(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => NavigationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Restaurant App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode, 
            home: const MainPage(),
          );
        },
      ),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  final List<Widget> _pages = const [
    HomeScreen(),
    FavoriteScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navigationProvider = context.watch<NavigationProvider>();

    return Scaffold(
      body: _pages[navigationProvider.selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationProvider.selectedIndex,
        onTap: (index) => navigationProvider.setIndex(index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: "Favorite",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}