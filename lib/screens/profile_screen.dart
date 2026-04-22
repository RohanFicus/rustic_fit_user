import 'package:flutter/material.dart';

import '../models/dummy_data.dart';
import '../services/data_service.dart';
import 'body_measurements_screen.dart';
import 'edit_profile_screen.dart';
import 'order_detail_screen.dart';
import 'saved_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFF7F5F2);
  static const Color darkBrown = Color(0xFF2D2926);

  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final user = _dataService.getCurrentUser();
    final recentOrders = _dataService.getOrders();

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: const Icon(Icons.notifications_outlined, color: darkBrown),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(user),
            const SizedBox(height: 14),
            _buildSectionTitle('Account Details'),
            _buildActionGroup([
              _buildActionRow(Icons.straighten_outlined, 'Body Fitting Sizes',
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BodyMeasurementsScreen(),
                  ),
                );
              }),
              _buildActionRow(Icons.location_on_outlined, 'Saved Addresses',
                  onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedAddressesScreen(),
                  ),
                );
              }),
              _buildActionRow(
                  Icons.notifications_none_outlined, 'Notification Preferences',
                  onTap: () {
                _showSnackBar('Opening Notification Preferences');
              }),
            ]),
            const SizedBox(height: 14),
            _buildSectionTitle('Support'),
            _buildActionGroup([
              _buildActionRow(Icons.headset_mic_outlined, 'Customer Support',
                  onTap: () {
                _showSnackBar('Connecting to Customer Support');
              }),
              _buildActionRow(Icons.email_outlined, 'Contact Us', onTap: () {
                _showSnackBar('Opening Contact Form');
              }),
              _buildActionRow(Icons.help_outline_outlined, 'FAQs', onTap: () {
                _showSnackBar('Opening FAQs');
              }),
            ]),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Recent Orders', paddingBottom: 0),
                TextButton(
                  onPressed: () {
                    // Navigate to orders tab
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: primaryGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (recentOrders.isNotEmpty)
              ...recentOrders
                  .take(2)
                  .map((order) => _buildOrderCard(order))
                  .toList()
            else
              _buildEmptyOrdersState(),
            const SizedBox(height: 40),
            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon:
                    const Icon(Icons.logout, color: Colors.redAccent, size: 18),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {double paddingBottom = 16.0}) {
    return Padding(
      padding: EdgeInsets.only(bottom: paddingBottom, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: darkBrown,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildProfileCard(User user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBrown.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryGold.withOpacity(0.2), width: 1),
            ),
            child: CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(user.avatar),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: darkBrown,
                        letterSpacing: -0.4)),
                const SizedBox(height: 2),
                Text(user.phone,
                    style: TextStyle(
                        color: darkBrown.withOpacity(0.6), fontSize: 12)),
                Text(user.email,
                    style: TextStyle(
                        color: darkBrown.withOpacity(0.4), fontSize: 11)),
              ],
            ),
          ),
          Material(
            color: lightCream,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.edit_outlined, color: primaryGold, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkBrown.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: lightCream.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: primaryGold, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      color: darkBrown,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right,
                color: darkBrown.withOpacity(0.15), size: 18),
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: darkBrown.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                firstItem.product.image,
                width: 50,
                height: 65,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(firstItem.product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
                                fontSize: 13)),
                      ),
                      Text(DummyData.formatPrice(order.totalAmount),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryGold,
                              fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Order #${order.orderNumber}',
                      style: TextStyle(
                          color: darkBrown.withOpacity(0.4), fontSize: 10)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 9,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (order.status == OrderStatus.delivered)
                        const Text(
                          'Rate Product',
                          style: TextStyle(
                            color: primaryGold,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
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

  Widget _buildEmptyOrdersState() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined,
              color: darkBrown.withOpacity(0.05), size: 40),
          const SizedBox(height: 12),
          Text(
            'No orders yet',
            style: TextStyle(
              color: darkBrown.withOpacity(0.4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return const SizedBox.shrink();
  }
}
