import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  final Color primaryBrown = const Color(0xFF5D4037);
  final Color secondaryBrown = const Color(0xFF8B6B4E);
  final Color bgColor = const Color(0xFFF9F3EE);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
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
            //_buildSectionTitle('Profile Settings'),
            _buildProfileCard(),
            const SizedBox(height: 20),

            _buildSectionTitle('Support'),
            _buildActionGroup([
              _buildActionRow(Icons.headset_mic_outlined, 'Customer Support'),
              _buildActionRow(Icons.email_outlined, 'Contact Us'),
            ]),
            const SizedBox(height: 20),

            _buildSectionTitle('More Information'),
            _buildActionGroup([
              _buildActionRow(Icons.headset_outlined, 'Customer Support'),
              _buildActionRow(Icons.mail_outline, 'Contact Us'),
            ]),
            const SizedBox(height: 20),

            // Order Card Section
            _buildOrderCard(),

            const SizedBox(height: 16),
            //_buildLoadMoreButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: primaryBrown,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kim Sharma',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryBrown)),
                    Text('+91 9876543210',
                        style: TextStyle(color: Colors.grey[600])),
                    Text('kim.sharma@example.com',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
          const Divider(height: 32),
          _buildActionRow(Icons.straighten, 'Body Fitting Sizes',
              trailing: 'Edit Profile'),
          const Divider(),
          _buildActionRow(Icons.location_on_outlined, 'Saved Addresses'),
          const Divider(),
          _buildActionRow(Icons.notifications_none, 'Notification Preferences'),
        ],
      ),
    );
  }

  Widget _buildActionGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActionRow(IconData icon, String title, {String? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: secondaryBrown, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title,
                style: TextStyle(color: primaryBrown, fontSize: 15)),
          ),
          if (trailing != null)
            Text(trailing,
                style: TextStyle(
                    color: primaryBrown,
                    fontSize: 13,
                    decoration: TextDecoration.underline)),
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }

  Widget _buildOrderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200',
              width: 80,
              height: 80,
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
                    Text('About Us',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryBrown,
                            fontSize: 16)),
                    Text('₹499',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: primaryBrown)),
                  ],
                ),
                Text('Order #13207 - Placed on February 9, 2024',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.indeterminate_check_box,
                            color: Colors.red[300], size: 16),
                        const SizedBox(width: 4),
                        Text('Cancelled',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 13)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F0EB),
                        foregroundColor: primaryBrown,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child:
                          const Text('Reorder', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide.none,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text('Load More', style: TextStyle(color: primaryBrown)),
      ),
    );
  }
}
