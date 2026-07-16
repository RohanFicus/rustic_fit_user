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
  String _selectedFilter = "Active";
  final List<String> _filters = ["All", "Active", "Completed", "Cancelled"];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      body: Column(
        children: [
          _buildHeader(isWide),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 16,
                vertical: 24,
              ),
              child: isWide ? _buildWideLayout() : _buildMobileLayout(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 20,
        vertical: 20,
      ),
      color: Colors.white,
      child: Row(
        children: [
          const Text(
            'Order Hub',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF131517),
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          if (isWide) _buildFilterTabs(true) else _buildFilterTabs(false),
          if (isWide) ...[
            const SizedBox(width: 24),
            _buildIconButton(Icons.search_rounded),
            const SizedBox(width: 12),
            _buildIconButton(Icons.tune_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterTabs(bool isWide) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 24 : 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFC9A227)
                      : const Color(0xFF8E847C),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 20, color: const Color(0xFF2D2926)),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildDynamicOrdersList(false),
      ],
    );
  }

  Widget _buildWideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildDynamicOrdersList(true),
        ),
        const SizedBox(width: 32),
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildHelpCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF131517),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatRow('Active Orders', '2', const Color(0xFFC9A227)),
          _buildStatRow('Delivered', '12', Colors.green),
          _buildStatRow('Total Spent', '₹1,24,500', Colors.white70),
          const Divider(color: Colors.white10, height: 32),
          const Text(
            'Your items usually arrive in 8-10 days after measurement.',
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: valueColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Assistance?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            'Connect with your personal tailor partner for any queries regarding measurements or alterations.',
            style:
                TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A227),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Chat with Tailor',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicOrdersList(bool isWide) {
    final dataService = DataService();
    List<Order> allOrders = dataService.getOrders();

    List<Order> filteredOrders = _selectedFilter == "All"
        ? allOrders
        : allOrders.where((order) {
            switch (_selectedFilter) {
              case "Active":
                return order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled;
              case "Completed":
                return order.status == OrderStatus.delivered;
              case "Cancelled":
                return order.status == OrderStatus.cancelled;
              default:
                return false;
            }
          }).toList();

    filteredOrders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    if (filteredOrders.isEmpty) return _buildEmptyState();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 20),
      itemBuilder: (context, index) =>
          _buildOrderCard(filteredOrders[index], isWide),
    );
  }

  Widget _buildOrderCard(Order order, bool isWide) {
    final firstItem = order.items.first;
    final isActive = order.status != OrderStatus.delivered &&
        order.status != OrderStatus.cancelled;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (c) => OrderDetailScreen(order: order)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE9ECEF)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      firstItem.product.image,
                      width: isWide ? 100 : 80,
                      height: isWide ? 130 : 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              firstItem.product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                color: Color(0xFF131517),
                              ),
                            ),
                            Text(
                              DummyData.formatPrice(order.totalAmount),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFC9A227),
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Order #${order.orderNumber} • ${_formatDate(order.orderDate)}',
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildStatusBadge(order.status),
                            const Spacer(),
                            if (isActive)
                              TextButton(
                                onPressed: () {},
                                child: const Text('Track Live',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFC9A227))),
                              )
                            else
                              TextButton(
                                onPressed: () {},
                                child: const Text('Reorder',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w800)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: _buildProgressStepper(order.status),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(
            _getStatusText(status).toUpperCase(),
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(OrderStatus status) {
    final steps = ['Ordered', 'Measured', 'Stitching', 'Shipped'];
    int currentStep = _getStepIndex(status);

    return Row(
      children: List.generate(steps.length, (index) {
        bool isPast = index < currentStep;
        bool isCurrent = index == currentStep;
        bool isLast = index == steps.length - 1;

        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: index == 0
                        ? const SizedBox()
                        : Container(
                            height: 2,
                            color: index <= currentStep
                                ? const Color(0xFFC9A227)
                                : const Color(0xFFE9ECEF),
                          ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: index <= currentStep
                          ? const Color(0xFFC9A227)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: index <= currentStep
                            ? const Color(0xFFC9A227)
                            : const Color(0xFFE9ECEF),
                        width: 2,
                      ),
                    ),
                  ),
                  Expanded(
                    child: isLast
                        ? const SizedBox()
                        : Container(
                            height: 2,
                            color: index < currentStep
                                ? const Color(0xFFC9A227)
                                : const Color(0xFFE9ECEF),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent
                      ? const Color(0xFF131517)
                      : (isPast ? const Color(0xFFC9A227) : Colors.grey[400]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  int _getStepIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.stitching:
        return 2;
      case OrderStatus.ready:
        return 2;
      case OrderStatus.shipped:
        return 3;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return 0;
    }
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
        return 'Processing';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.stitching:
        return 'In Stitching';
      case OrderStatus.ready:
        return 'Ready to Ship';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            Icon(Icons.shopping_bag_outlined,
                size: 64, color: Colors.grey[200]),
            const SizedBox(height: 24),
            Text(
              "No $_selectedFilter orders yet",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8E847C)),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (c) => const HomeScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9A227),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Start Crafting Your Style',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
