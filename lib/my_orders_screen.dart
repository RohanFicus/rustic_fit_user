import 'package:flutter/material.dart';

import 'models/dummy_data.dart';
import 'screens/order_detail_screen.dart';
import 'services/data_service.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final Color primaryBrown = const Color(0xFF5D4037);
  final Color accentBrown = const Color(0xFFA67C52);
  final Color lightBg = const Color(0xFFFAF5F1);

  String _selectedFilter = "Active";

  final List<String> _filters = ["All", "Active", "Completed", "Cancelled"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Orders',
            style: TextStyle(
                color: primaryBrown,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.filter_list, color: primaryBrown, size: 28),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSegmentedFilter(),
            const SizedBox(height: 24),
            _buildDynamicOrdersList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicOrdersList() {
    final dataService = DataService();
    List<Order> allOrders = dataService.getOrders();

    // Filter orders based on selected filter
    List<Order> filteredOrders = _selectedFilter == "All"
        ? allOrders
        : allOrders.where((order) {
            switch (_selectedFilter) {
              case "Active":
                return order.status == OrderStatus.pending ||
                    order.status == OrderStatus.confirmed ||
                    order.status == OrderStatus.stitching ||
                    order.status == OrderStatus.ready ||
                    order.status == OrderStatus.shipped;
              case "Completed":
                return order.status == OrderStatus.delivered;
              case "Cancelled":
                return order.status == OrderStatus.cancelled;
              default:
                return false;
            }
          }).toList();

    // Sort orders by date (newest first)
    filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    // Separate active and completed orders
    final activeOrders = filteredOrders
        .where((order) =>
            order.status == OrderStatus.pending ||
            order.status == OrderStatus.confirmed ||
            order.status == OrderStatus.stitching ||
            order.status == OrderStatus.ready ||
            order.status == OrderStatus.shipped)
        .toList();

    final completedOrders = filteredOrders
        .where((order) =>
            order.status == OrderStatus.delivered ||
            order.status == OrderStatus.cancelled)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Active Orders Section
        if (activeOrders.isNotEmpty) ...[
          _buildSectionTitle('Current Orders (${activeOrders.length})'),
          ...activeOrders.map((order) => _buildDynamicOrderCard(order)),
          const SizedBox(height: 24),
        ],

        // Completed Orders Section
        if (completedOrders.isNotEmpty) ...[
          _buildSectionTitle('Order History (${completedOrders.length})'),
          ...completedOrders.map((order) => _buildDynamicOrderCard(order)),
          const SizedBox(height: 16),
        ],

        // Empty State
        if (filteredOrders.isEmpty) _buildEmptyState(),

        // Load More Button (if there are orders)
        if (filteredOrders.isNotEmpty) _buildLoadMoreButton(),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: TextStyle(
              color: primaryBrown, fontSize: 18, fontWeight: FontWeight.w500)),
    );
  }

  // Top Filter: All, Active, Completed, Cancelled
  Widget _buildSegmentedFilter() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: _filters.map((filter) {
          final isActive = filter == _selectedFilter;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? accentBrown : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey[600],
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Dynamic Order Card with Real Data
  Widget _buildDynamicOrderCard(Order order) {
    final firstItem = order.items.first;
    final isActiveOrder = order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.stitching ||
        order.status == OrderStatus.ready ||
        order.status == OrderStatus.shipped;

    return GestureDetector(
        onTap: () {
          // Navigate to order detail screen
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
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header with Product Info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      firstItem.product.image,
                      width: 70,
                      height: 90,
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
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: primaryBrown,
                                      fontSize: 16)),
                            ),
                            Text(DummyData.formatPrice(order.totalAmount),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryBrown,
                                    fontSize: 16)),
                          ],
                        ),
                        Text(
                            '${order.orderNumber} - Placed on ${_formatDate(order.orderDate)}',
                            style: TextStyle(
                                color: Colors.grey[500], fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(order.tailorName,
                            style: TextStyle(
                                color: primaryBrown,
                                fontWeight: FontWeight.w600)),
                        Text(order.tailorAddress,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 11)),
                      ],
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Order Status and Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Action Buttons
                  if (isActiveOrder)
                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Tracking order ${order.orderNumber}'),
                            backgroundColor: accentBrown,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('Track Order',
                          style: TextStyle(color: primaryBrown)),
                    )
                  else
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text('Reordering ${firstItem.product.name}'),
                            backgroundColor: accentBrown,
                          ),
                        );
                      },
                      child:
                          Text('Reorder', style: TextStyle(color: accentBrown)),
                    ),
                ],
              ),

              // Progress Stepper for active orders
              if (isActiveOrder)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildProgressStepper(order.status),
                  ],
                ),
            ],
          ),
        ));
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.stitching:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.blue;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.stitching:
        return 'Stitching';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget _buildProgressStepper(OrderStatus status) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stepIcon(
                Icons.shopping_bag_outlined,
                "Placed",
                status == OrderStatus.pending ||
                    status == OrderStatus.confirmed ||
                    status == OrderStatus.stitching ||
                    status == OrderStatus.ready ||
                    status == OrderStatus.shipped ||
                    status == OrderStatus.delivered),
            _stepIcon(
                Icons.edit_outlined,
                "Picked",
                status == OrderStatus.confirmed ||
                    status == OrderStatus.stitching ||
                    status == OrderStatus.ready ||
                    status == OrderStatus.shipped ||
                    status == OrderStatus.delivered),
            _stepIcon(
                Icons.colorize_outlined,
                "Stitching",
                status == OrderStatus.stitching ||
                    status == OrderStatus.ready ||
                    status == OrderStatus.shipped ||
                    status == OrderStatus.delivered),
            _stepIcon(
                Icons.local_shipping_outlined,
                "Shipped",
                status == OrderStatus.shipped ||
                    status == OrderStatus.delivered),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
                height: 2,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  4,
                  (index) => CircleAvatar(
                      radius: 4,
                      backgroundColor:
                          index == 3 ? Colors.orange : accentBrown)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order in 7 days',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('Picked Up By Tailor Partner',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No $_selectedFilter orders",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Your orders will appear here",
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Navigate to home screen to shop
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentBrown,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Detailed Active Order Card
  Widget _buildActiveOrderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                    'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200',
                    width: 70,
                    height: 90,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Anarkali Suit',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBrown,
                                fontSize: 16)),
                        Text('₹499',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBrown,
                                fontSize: 16)),
                      ],
                    ),
                    Text('Order #15230 - Placed on April 24, 2024',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 12)),
                    const SizedBox(height: 8),
                    Text('Bhandari Tailors',
                        style: TextStyle(
                            color: primaryBrown, fontWeight: FontWeight.w600)),
                    Text(
                        'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
                        style:
                            TextStyle(color: Colors.grey[600], fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),
          // Progress Stepper Section
          _buildStepper(),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Track Order', style: TextStyle(color: primaryBrown)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stepIcon(Icons.shopping_bag_outlined, "Placed", true),
            _stepIcon(Icons.edit_outlined, "Picked", true),
            _stepIcon(Icons.colorize_outlined, "Stitching", true),
            _stepIcon(Icons.local_shipping_outlined, "In Progress", true,
                isGold: true),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
                height: 2,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.symmetric(horizontal: 20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                  4,
                  (index) => CircleAvatar(
                      radius: 4,
                      backgroundColor:
                          index == 3 ? Colors.orange : accentBrown)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order in 7 days',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('Picked Up By Tailor Partner',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _stepIcon(IconData icon, String label, bool isActive,
      {bool isGold = false}) {
    Color color =
        isGold ? Colors.orange : (isActive ? primaryBrown : Colors.grey);
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Order History Cards
  Widget _buildHistoryCard(
      {required String title,
      required String price,
      required String orderId,
      required String date,
      required String status,
      required Color statusColor,
      required bool isCancelled}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                    'https://images.unsplash.com/photo-1597983073493-88cd35cf93b0?w=200',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBrown)),
                        Text(price,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: primaryBrown)),
                      ],
                    ),
                    Text('Order $orderId - Placed on $date',
                        style:
                            TextStyle(color: Colors.grey[500], fontSize: 11)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                            isCancelled
                                ? Icons.indeterminate_check_box
                                : Icons.check_box,
                            color: statusColor.withValues(alpha: 0.7),
                            size: 14),
                        const SizedBox(width: 4),
                        Text(status,
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isCancelled) ...[
            const SizedBox(height: 8),
            Text(
                'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
                style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isCancelled) ...[
                Icon(Icons.analytics_outlined, size: 16, color: primaryBrown),
                const SizedBox(width: 4),
                Text('Track Order',
                    style: TextStyle(color: primaryBrown, fontSize: 13)),
                const Spacer(),
                TextButton(
                    onPressed: () {},
                    child:
                        Text('Reorder', style: TextStyle(color: primaryBrown))),
              ] else
                TextButton(
                    onPressed: () {},
                    child: Text('View Details',
                        style: TextStyle(color: primaryBrown))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        child: Text('Load More',
            style: TextStyle(
                color: primaryBrown, decoration: TextDecoration.underline)),
      ),
    );
  }
}
