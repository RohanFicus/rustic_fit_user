import 'package:flutter/material.dart';

import 'models/dummy_data.dart';
import 'screens/home_screen.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.98),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'My Orders',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.tune_rounded,
                  color: colorScheme.onSurface, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
            child: _buildSegmentedFilter(),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDynamicOrdersList(),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
      ),
    );
  }

  // Top Filter: All, Active, Completed, Cancelled
  Widget _buildSegmentedFilter() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  filter,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isActive ? Colors.white : colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
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
    final colorScheme = Theme.of(context).colorScheme;
    final firstItem = order.items.first;
    final isActiveOrder = order.status == OrderStatus.pending ||
        order.status == OrderStatus.confirmed ||
        order.status == OrderStatus.stitching ||
        order.status == OrderStatus.ready ||
        order.status == OrderStatus.shipped;

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
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'order_img_${order.id}',
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              firstItem.product.image,
                              width: 85,
                              height: 110,
                              fit: BoxFit.cover,
                            ),
                          ),
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
                                  child: Text(
                                    firstItem.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 17,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ),
                                Text(
                                  DummyData.formatPrice(order.totalAmount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.primary,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Order #${order.orderNumber}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.storefront_outlined,
                                    size: 14, color: colorScheme.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    order.tailorName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.tailorAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 0.5),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getStatusText(order.status),
                              style: TextStyle(
                                color: _getStatusColor(order.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isActiveOrder)
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: colorScheme.onSurface,
                            elevation: 0,
                            side: BorderSide(color: colorScheme.outlineVariant),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Track Order',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      else
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.replay_rounded, size: 16),
                          label: const Text('Reorder'),
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isActiveOrder)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildProgressStepper(order.status),
              ),
          ],
        ),
      ),
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    final steps = [
      {'label': 'Placed', 'icon': Icons.shopping_bag_outlined, 'active': true},
      {
        'label': 'Picked',
        'icon': Icons.inventory_2_outlined,
        'active': status != OrderStatus.pending
      },
      {
        'label': 'Stitching',
        'icon': Icons.architecture_rounded,
        'active': status == OrderStatus.stitching ||
            status == OrderStatus.ready ||
            status == OrderStatus.shipped ||
            status == OrderStatus.delivered
      },
      {
        'label': 'Shipped',
        'icon': Icons.local_shipping_outlined,
        'active':
            status == OrderStatus.shipped || status == OrderStatus.delivered
      },
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.map((step) {
            final isActive = step['active'] as bool;
            final color = isActive
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
            return Expanded(
              child: Column(
                children: [
                  Icon(step['icon'] as IconData, size: 18, color: color),
                  const SizedBox(height: 6),
                  Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final isActive = steps[index]['active'] as bool;
                  return Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color:
                          isActive ? colorScheme.primary : colorScheme.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.surfaceVariant,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.3),
                                blurRadius: 4,
                              )
                            ]
                          : [],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated: 7 days',
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (status == OrderStatus.shipped)
                Text(
                  'Out for delivery',
                  style: TextStyle(
                    fontSize: 10,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
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
