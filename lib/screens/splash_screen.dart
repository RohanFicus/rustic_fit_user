import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'mobile_auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToAuth();
  }

  _navigateToAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MobileAuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 375,
        height: 812,
        color: const Color(0xFFF5E6D3), // Light beige background
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
            
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular emblem
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFD4AF37), width: 6),
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Large R
                          Text(
                            'R',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              fontFamily: 'Georgia',
                            ),
                          ),
                          SizedBox(height: 8),
                          // RusticFit by Kim text
                          Text(
                            'RusticFit by Kim',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD4AF37),
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Version number with small gold circle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD4AF37),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'V1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
