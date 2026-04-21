import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
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
      builder: (context, child) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final showFrame = screenWidth >= 520;

        if (!showFrame) return child ?? const SizedBox.shrink();

        return ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 900),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 28,
                      offset: Offset(0, 12),
                      color: Color(0x1A000000),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
