import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/dummy_data.dart';
import 'screens/splash_screen.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://giethkxggfmfmmxkittu.supabase.co',
  );
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdpZXRoa3hnZ2ZtZm1teGtpdHR1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQyMTcxMjAsImV4cCI6MjA5OTc5MzEyMH0.0UYre4tFlBazwbetDJ8QEuodPzIpzBmM-_a13ybwoPU',
  );

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Pre-load data from Supabase DB into DummyData memory cache
  try {
    final dbCategories = await SupabaseService.fetchCategories();
    if (dbCategories.isNotEmpty) {
      DummyData.categories = dbCategories;
    }
    
    final dbProducts = await SupabaseService.fetchProducts();
    if (dbProducts.isNotEmpty) {
      DummyData.products = dbProducts;
    }

    final dbLocations = await SupabaseService.fetchLocations();
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
