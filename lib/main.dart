import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/dummy_data.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load data from API into DummyData memory cache
  try {
    final dbCategories = await ApiService.fetchCategories();
    if (dbCategories.isNotEmpty) {
      DummyData.categories = dbCategories;
    }

    final dbProducts = await ApiService.fetchProducts();
    if (dbProducts.isNotEmpty) {
      DummyData.products = dbProducts;
    }

    final dbLocations = await ApiService.fetchLocations();
    if (dbLocations.isNotEmpty) {
      DummyData.locations = dbLocations;
    }
  } catch (e) {
    print('Failed to pre-fetch database data: $e');
  }

  runApp(const RusticFitApp());
}

class RusticFitApp extends StatelessWidget {
  const RusticFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'RusticFit by Kim',
      theme: AppTheme.light(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
