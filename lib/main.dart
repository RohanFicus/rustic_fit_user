import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/mobile_auth_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/main_container.dart';

void main() {
  runApp(const RusticFitApp());
}

class RusticFitApp extends StatelessWidget {
  const RusticFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RusticFit by Kim',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4AF37), // Gold color
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor:
            const Color(0xFFF5E6D3), // Light beige background
      ),
      home: const Scaffold(
        body: Center(
          child: SizedBox(
            width: 375, // iPhone width
            height: 812, // iPhone height
            child: SplashScreen(),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
