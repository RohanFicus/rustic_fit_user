import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rustic_fit/my_orders_screen.dart';
import 'package:rustic_fit/screens/mobile_auth_screen.dart';
import 'package:rustic_fit/screens/profile_screen.dart';
import 'package:rustic_fit/screens/schedule_screen.dart';
import 'package:rustic_fit/services/api_service.dart';

import '../widgets/custom_bottom_nav.dart';
import 'home_screen.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;
  bool _isExpanded = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ScheduleScreen(),
    const MyOrdersScreen(),
    const ProfileScreen(),
  ];

  final List<NavItem> _navItems = [
    NavItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: 'Dashboard'),
    NavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today,
        label: 'Schedule'),
    NavItem(
        icon: Icons.receipt_long_outlined,
        activeIcon: Icons.receipt_long,
        label: 'Orders'),
    NavItem(
        icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content:
            const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.clearSession();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MobileAuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFCFB),
        extendBody: true,
        body: Row(
          children: [
            if (isWide) _buildSidebar(),
            Expanded(
              child: SafeArea(
                top: !isWide,
                bottom: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.01, 0),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                            parent: animation, curve: Curves.easeOut)),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: _screens[_currentIndex],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: !isWide
            ? CustomBottomNav(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              )
            : null,
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _isExpanded ? 260 : 88,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131517), // Deeper dark sidebar color
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // Logo & Collapse Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 48,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  width: _isExpanded ? 228 : 56, // 260-32 or 88-32
                  child: Row(
                    mainAxisAlignment: _isExpanded
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      if (_isExpanded)
                        IconButton(
                          onPressed: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          icon: const Icon(Icons.chevron_left,
                              color: Colors.white54, size: 20),
                          style: IconButton.styleFrom(
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.05),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!_isExpanded) ...[
            const SizedBox(height: 12),
            IconButton(
              onPressed: () => setState(() => _isExpanded = !_isExpanded),
              icon: const Icon(Icons.chevron_right,
                  color: Colors.white54, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                padding: const EdgeInsets.all(8),
              ),
            ),
          ],
          const SizedBox(height: 40),
          // Nav Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _navItems.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = _currentIndex == index;
                return _SidebarItem(
                  item: item,
                  isSelected: isSelected,
                  isExpanded: _isExpanded,
                  onTap: () => _onTabTapped(index),
                );
              },
            ),
          ),
          // Bottom Items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Column(
              children: [
                // _SidebarItem(
                //   item: NavItem(icon: Icons.person_outline, label: 'Profile'),
                //   isSelected: false,
                //   isExpanded: _isExpanded,
                //   onTap: () {},
                // ),
                const SizedBox(height: 8),
                _SidebarItem(
                  item: NavItem(icon: Icons.logout_rounded, label: 'Logout'),
                  isSelected: false,
                  isExpanded: _isExpanded,
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  NavItem({required this.icon, this.activeIcon, required this.label});
}

class _SidebarItem extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            width: isExpanded ? 236 : 64, // Width inside the padding
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: isExpanded ? 16 : 0),
                  child: Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    color:
                        isSelected ? const Color(0xFF131517) : Colors.white70,
                    size: 24,
                  ),
                ),
                if (isExpanded)
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF131517)
                            : Colors.white70,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.fade,
                      softWrap: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
