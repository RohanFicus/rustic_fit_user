import 'package:flutter/material.dart';

import '../models/dummy_data.dart';
import '../services/data_service.dart';
import '../services/supabase_service.dart';
import 'body_measurements_screen.dart';
import 'edit_profile_screen.dart';
import 'mobile_auth_screen.dart';
import 'order_detail_screen.dart';
import 'payment_methods_screen.dart';
import 'saved_addresses_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final user = _dataService.getCurrentUser();
    final recentOrders = _dataService.getOrders();

    return Scaffold(
      backgroundColor: lightCream,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(user, isWide),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 20,
                vertical: 32,
              ),
              child: isWide
                  ? _buildWideContent(user, recentOrders)
                  : _buildMobileContent(user, recentOrders),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user, bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isWide ? 40 : 20,
        isWide ? 60 : 40,
        isWide ? 40 : 20,
        isWide ? 40 : 32,
      ),
      decoration: const BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: primaryGold.withValues(alpha: 0.5), width: 2),
                ),
                child: CircleAvatar(
                  radius: isWide ? 50 : 40,
                  backgroundImage: NetworkImage(user.avatar),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: isWide ? 32 : 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: primaryGold, size: 16),
                        const SizedBox(width: 6),
                        const Text(
                          'Royal Member',
                          style: TextStyle(
                              color: primaryGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          user.phone,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isWide)
                ElevatedButton.icon(
                  onPressed: () => _navigateToEditProfile(),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWideContent(User user, List<Order> recentOrders) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Account Settings'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.5,
                children: [
                  _buildLargeActionCard(
                      Icons.straighten_rounded,
                      'Body Measurements',
                      'View and update your custom sizes', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const BodyMeasurementsScreen()));
                  }),
                  _buildLargeActionCard(
                      Icons.location_on_rounded,
                      'Shipping Addresses',
                      'Manage your delivery locations', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const SavedAddressesScreen()));
                  }),
                  _buildLargeActionCard(Icons.notifications_rounded,
                      'Notifications', 'Manage alerts and reminders', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const SettingsScreen()));
                  }),
                  _buildLargeActionCard(Icons.payment_rounded,
                      'Payment Methods', 'Manage your saved cards', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const PaymentMethodsScreen()));
                  }),
                ],
              ),
              const SizedBox(height: 40),
              _buildSectionTitle('Support & Help'),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3,
                children: [
                  _buildSimpleActionRow(
                      Icons.headset_mic_rounded, 'Customer Support', () {}),
                  _buildSimpleActionRow(
                      Icons.help_outline_rounded, 'FAQs', () {}),
                  _buildSimpleActionRow(
                      Icons.settings_rounded, 'Global Settings', () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (c) => const SettingsScreen()));
                  }),
                  _buildSimpleActionRow(
                      Icons.privacy_tip_rounded, 'Privacy Policy', () {}),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Recent Orders'),
              if (recentOrders.isNotEmpty)
                ...recentOrders.take(3).map((order) => _buildOrderCard(order))
              else
                _buildEmptyOrdersState(),
              const SizedBox(height: 32),
              _buildLogoutButton(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileContent(User user, List<Order> recentOrders) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Account Details'),
        _buildActionGroup([
          _buildActionRow(Icons.straighten_outlined, 'Body Fitting Sizes',
              onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => const BodyMeasurementsScreen()));
          }),
          _buildActionRow(Icons.location_on_outlined, 'Saved Addresses',
              onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (c) => const SavedAddressesScreen()));
          }),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle('Recent Orders'),
        if (recentOrders.isNotEmpty)
          ...recentOrders.take(2).map((order) => _buildOrderCard(order))
        else
          _buildEmptyOrdersState(),
        const SizedBox(height: 32),
        _buildLogoutButton(),
      ],
    );
  }

  Widget _buildLargeActionCard(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: primaryGold, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleActionRow(
      IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryGold, size: 20),
            const SizedBox(width: 16),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.clearSession();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MobileAuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded, size: 18),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFFFEBEE)),
          backgroundColor: const Color(0xFFFFEBEE).withValues(alpha: 0.3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    ).then((_) => setState(() {}));
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildActionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: primaryGold, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: darkBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final firstItem = order.items.first;
    final statusColor = DummyData.getOrderStatusColor(order.status);
    final statusText = DummyData.getOrderStatusText(order.status);

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (c) => OrderDetailScreen(order: order))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(firstItem.product.image,
                  width: 50, height: 65, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(firstItem.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5)),
                      Text(DummyData.formatPrice(order.totalAmount),
                          style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              color: primaryGold,
                              fontSize: 14)),
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

  Widget _buildEmptyOrdersState() {
    return Container(
      padding: const EdgeInsets.all(32),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, color: Colors.grey[200], size: 48),
          const SizedBox(height: 16),
          Text('No orders yet',
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
