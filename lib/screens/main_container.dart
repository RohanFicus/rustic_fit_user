import 'package:flutter/material.dart';
import 'package:rustic_fit/my_orders_screen.dart';
import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const MyOrdersScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0xFFF5E6D3),
        child: Stack(
          children: [
            // Ornate corner patterns
            Positioned(
              top: 20,
              left: 20,
              child: _buildOrnatePattern(),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: _buildOrnatePattern(),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildOrnatePattern(),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildOrnatePattern(),
            ),

            // Main content with bottom navigation
            Column(
              children: [
                // Screen content
                Expanded(
                  child: _screens[_currentIndex],
                ),

                // Bottom navigation
                CustomBottomNav(
                  currentIndex: _currentIndex,
                  onTap: _onTabTapped,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnatePattern() {
    return CustomPaint(
      size: const Size(60, 60),
      painter: OrnatePatternPainter(),
    );
  }
}

class OrnatePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Create ornate corner pattern
    path.moveTo(0, 20);
    path.quadraticBezierTo(10, 10, 20, 0);

    path.moveTo(10, 0);
    path.quadraticBezierTo(5, 5, 0, 10);

    path.moveTo(0, 30);
    path.quadraticBezierTo(15, 15, 30, 0);

    // Add decorative circles
    canvas.drawCircle(const Offset(10, 10), 3, paint);
    canvas.drawCircle(const Offset(20, 20), 2, paint);
    canvas.drawCircle(const Offset(15, 30), 2.5, paint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
