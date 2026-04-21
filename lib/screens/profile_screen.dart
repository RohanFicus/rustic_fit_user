import 'package:flutter/material.dart';

import '../models/dummy_data.dart';
import '../services/data_service.dart';
import 'order_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryBrown = const Color(0xFF5D4037);
  final Color secondaryBrown = const Color(0xFF8B6B4E);
  final Color bgColor = const Color(0xFFF9F3EE);
  final DataService _dataService = DataService();

  @override
  Widget build(BuildContext context) {
    final user = _dataService.getCurrentUser();
    final recentOrders = _dataService.getOrders();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: null,
        title: Text(
          'Profile',
          style: TextStyle(color: primaryBrown, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications, color: primaryBrown),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Profile Settings'),
            _buildProfileCard(user),
            const SizedBox(height: 24),
            _buildSectionTitle('Account Details'),
            _buildActionGroup([
              _buildActionRow(Icons.straighten, 'Body Fitting Sizes',
                  onTap: () {
                _showSnackBar('Opening Body Fitting Sizes');
              }),
              _buildActionRow(Icons.location_on_outlined, 'Saved Addresses',
                  onTap: () {
                _showSnackBar('Opening Saved Addresses');
              }),
              _buildActionRow(
                  Icons.notifications_none, 'Notification Preferences',
                  onTap: () {
                _showSnackBar('Opening Notification Preferences');
              }),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Support'),
            _buildActionGroup([
              _buildActionRow(Icons.headset_mic_outlined, 'Customer Support',
                  onTap: () {
                _showSnackBar('Connecting to Customer Support');
              }),
              _buildActionRow(Icons.email_outlined, 'Contact Us', onTap: () {
                _showSnackBar('Opening Contact Form');
              }),
              _buildActionRow(Icons.help_outline, 'FAQs', onTap: () {
                _showSnackBar('Opening FAQs');
              }),
            ]),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Orders'),
            if (recentOrders.isNotEmpty)
              ...recentOrders
                  .take(2)
                  .map((order) => _buildOrderCard(order))
                  .toList()
            else
              _buildEmptyOrdersState(),
            const SizedBox(height: 16),
            _buildLoadMoreButton(),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryBrown,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: primaryBrown,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProfileCard(User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.avatar),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primaryBrown)),
                    const SizedBox(height: 4),
                    Text(user.phone,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 14)),
                    Text(user.email,
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: secondaryBrown),
                onPressed: () => _showSnackBar('Editing Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: primaryBrown, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: primaryBrown,
                      fontSize: 16,
                      fontWeight: FontWeight.w500)),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
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
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                firstItem.product.image,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
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
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBrown,
                                fontSize: 16)),
                      ),
                      Text(DummyData.formatPrice(order.totalAmount),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: primaryBrown)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Order ${order.orderNumber}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text('Placed on ${DummyData.formatDate(order.orderDate)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (order.status == OrderStatus.cancelled ||
                          order.status == OrderStatus.delivered)
                        TextButton(
                          onPressed: () => _showSnackBar('Reordering item...'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text('Reorder',
                              style: TextStyle(
                                  color: secondaryBrown,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.shopping_bag_outlined,
                color: Colors.grey[300], size: 48),
            const SizedBox(height: 12),
            Text('No orders yet', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () {
          _showSnackBar('Loading more orders...');
        },
        child: Text('View All Orders',
            style: TextStyle(
                color: primaryBrown,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline)),
      ),
    );
  }
}
