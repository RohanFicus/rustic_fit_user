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

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Premium Custom Tailoring',
      subtitle: 'CRAFTED FOR YOU',
      description:
          'Experience the luxury of perfectly fitted clothes, tailored just for you by master craftsmen.',
      image: 'assets/images/banners/banner_1.png',
      color: const Color(0xFFC9A227),
    ),
    OnboardingItem(
      title: 'Doorstep Measurement',
      subtitle: 'AT YOUR CONVENIENCE',
      description:
          'Book a session and our professional tailors will visit you for precise measurements at your home.',
      image: 'assets/images/banners/banner_2.png',
      color: const Color(0xFF2E7D32),
    ),
    OnboardingItem(
      title: 'Wide Fabric Selection',
      subtitle: 'FINEST MATERIALS',
      description:
          'Choose from a curated collection of premium fabrics from around the world for your next outfit.',
      image: 'assets/images/banners/banner_3.png',
      color: const Color(0xFF1565C0),
    ),
    OnboardingItem(
      title: 'Perfect Fit Guaranteed',
      subtitle: 'QUALITY ASSURED',
      description:
          'We ensure every stitch is perfect. Your satisfaction with the fit is our top priority.',
      image: 'assets/images/banners/banner_4.png',
      color: const Color(0xFFE65100),
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
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _navigateToAuth();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutQuart,
      );
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
      backgroundColor: Colors.black,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowRight): _nextPage,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): _previousPage,
          const SingleActivator(LogicalKeyboardKey.space): _nextPage,
          const SingleActivator(LogicalKeyboardKey.enter): _nextPage,
        },
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _items.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    item: _items[index],
                    isActive: _currentPage == index,
                  );
                },
              ),

              // Glassy Skip Button
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 20,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 1000),
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: TextButton(
                    onPressed: _navigateToAuth,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),

              // Modern Bottom Navigation Section
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      // Page Indicators
                      Expanded(
                        child: Row(
                          children: List.generate(
                            _items.length,
                            (index) => _buildPageIndicator(index),
                          ),
                        ),
                      ),

                      // Navigation Controls
                      Row(
                        children: [
                          if (_currentPage > 0)
                            _buildCircleButton(
                              onPressed: _previousPage,
                              icon: Icons.chevron_left_rounded,
                              isPrimary: false,
                            ),
                          const SizedBox(width: 16),
                          _buildCircleButton(
                            onPressed: _nextPage,
                            icon: _currentPage == _items.length - 1
                                ? Icons.check_rounded
                                : Icons.chevron_right_rounded,
                            isPrimary: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required VoidCallback onPressed,
    required IconData icon,
    required bool isPrimary,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isPrimary
            ? const LinearGradient(
                colors: [Color(0xFFC9A227), Color(0xFFE5C158)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: !isPrimary ? Colors.white.withOpacity(0.1) : null,
        border: !isPrimary
            ? Border.all(color: Colors.white.withOpacity(0.2))
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: const Color(0xFFC9A227).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 64,
            height: 64,
            child: Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.only(right: 8),
      height: 4,
      width: isActive ? 32 : 12,
      decoration: BoxDecoration(
        color:
            isActive ? const Color(0xFFC9A227) : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: const Color(0xFFC9A227).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final Color color;

  OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.image,
    required this.color,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.item,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Background Image with subtle zoom effect
        AnimatedScale(
          scale: isActive ? 1.05 : 1.2,
          duration: const Duration(seconds: 15),
          curve: Curves.linear,
          child: Image.asset(
            item.image,
            width: size.width,
            height: size.height,
            fit: BoxFit.cover,
          ),
        ),

        // Multi-layered Gradient Overlay for better depth
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                  Colors.black.withOpacity(0.9),
                  Colors.black,
                ],
                stops: const [0.0, 0.4, 0.6, 0.85, 1.0],
              ),
            ),
          ),
        ),

        // Animated Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Badge
              _AnimatedContent(
                isActive: isActive,
                delay: 200,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: item.color.withOpacity(0.5), width: 1.5),
                  ),
                  child: Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    style: textTheme.labelSmall?.copyWith(
                      color: item.color,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              _AnimatedContent(
                isActive: isActive,
                delay: 400,
                child: Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                    fontSize: 36,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              _AnimatedContent(
                isActive: isActive,
                delay: 600,
                child: Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withOpacity(0.6),
                    height: 1.6,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.25),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedContent extends StatelessWidget {
  final Widget child;
  final bool isActive;
  final int delay;

  const _AnimatedContent({
    required this.child,
    required this.isActive,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isActive ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      child: AnimatedPadding(
        padding: EdgeInsets.only(top: isActive ? 0 : 40),
        duration: Duration(milliseconds: 800 + delay),
        curve: Curves.easeOutQuint,
        child: child,
      ),
    );
  }
}
