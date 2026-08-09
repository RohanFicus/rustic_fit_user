import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'mobile_auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color darkBrown = Color(0xFF131517);

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Premium Custom Tailoring',
      subtitle: 'EXCLUSIVELY CRAFTED',
      description:
          'Experience the luxury of perfectly fitted clothes, tailored just for you by master craftsmen.',
      image: 'assets/images/banners/banner_1.png',
    ),
    OnboardingItem(
      title: 'Doorstep Measurement',
      subtitle: 'AT YOUR CONVENIENCE',
      description:
          'Book a session and our professional tailors will visit you for precise measurements at your home.',
      image: 'assets/images/banners/banner_2.png',
    ),
    OnboardingItem(
      title: 'Wide Fabric Selection',
      subtitle: 'FINEST MATERIALS',
      description:
          'Choose from a curated collection of premium fabrics from around the world for your next outfit.',
      image: 'assets/images/banners/banner_3.png',
    ),
    OnboardingItem(
      title: 'Perfect Fit Guaranteed',
      subtitle: 'QUALITY ASSURED',
      description:
          'We ensure every stitch is perfect. Your satisfaction with the fit is our top priority.',
      image: 'assets/images/banners/banner_4.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _nextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MobileAuthScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBrown,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Stack(
          children: [
            // Immersive PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        // Parallax Background Image
                        Transform.translate(
                          offset: Offset(
                            _pageController.position.haveDimensions
                                ? (_pageController.page! - index) * 100
                                : 0,
                            0,
                          ),
                          child: Transform.scale(
                            scale: 1.2,
                            child: Image.asset(
                              _items[index].image,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Dark overlay
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.3),
                                Colors.black.withValues(alpha: 0.8),
                                Colors.black,
                              ],
                              stops: const [0.0, 0.4, 0.7, 1.0],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            // Content Overlay
            SafeArea(
              child: Column(
                children: [
                  // Top Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo or App Name
                        const Text(
                          'RUSTIC FIT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        // Skip Button
                        TextButton(
                          onPressed: _navigateToAuth,
                          style: TextButton.styleFrom(
                            foregroundColor:
                                Colors.white.withValues(alpha: 0.6),
                          ),
                          child: const Text(
                            'SKIP',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Glassmorphic Card
                  Container(
                    margin: const EdgeInsets.all(24),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _items.length,
                                  (index) => _buildIndicator(index),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Subtitle
                              Text(
                                _items[_currentPage].subtitle,
                                style: const TextStyle(
                                  color: primaryGold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Title
                              Text(
                                _items[_currentPage].title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Description
                              Text(
                                _items[_currentPage].description,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 15,
                                  height: 1.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 64,
                                child: ElevatedButton(
                                  onPressed: _nextPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryGold,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  child: Text(
                                    _currentPage == _items.length - 1
                                        ? 'GET STARTED'
                                        : 'NEXT',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? primaryGold : Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final String image;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
  });
}
