import 'package:flutter/material.dart';
import '../models/dummy_data.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final Color primaryBrown = const Color(0xFF5D4037);
  final Color accentBrown = const Color(0xFFA67C52);
  final Color lightBg = const Color(0xFFFAF5F1);

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
        title: Text('Order Details',
            style: TextStyle(
                color: primaryBrown,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: primaryBrown),
            onPressed: () {
              _showSnackBar(
                  context, 'Sharing order ${widget.order.orderNumber}');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(),
            _buildOrderStatus(),
            _buildProgressSection(),
            _buildItemsSection(),
            _buildPricingSection(),
            _buildDeliveryInfo(),
            _buildTailorInfo(),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.order.orderNumber,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placed on ${_formatDate(widget.order.orderDate)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(widget.order.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(widget.order.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: primaryBrown),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.order.deliveryAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderStatus() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailedProgressStepper(),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    final isActiveOrder = widget.order.status == OrderStatus.pending ||
        widget.order.status == OrderStatus.confirmed ||
        widget.order.status == OrderStatus.stitching ||
        widget.order.status == OrderStatus.ready ||
        widget.order.status == OrderStatus.shipped;

    if (!isActiveOrder) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentBrown.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentBrown.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: accentBrown, size: 20),
              const SizedBox(width: 8),
              Text(
                'Expected Delivery',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: accentBrown,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_getExpectedDeliveryDays()} days from now',
            style: TextStyle(
              fontSize: 13,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Your order is being processed with care',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items (${widget.order.items.length})',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.order.items.map((item) => _buildOrderItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.product.image,
              width: 60,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Size: ${item.size} | Qty: ${item.quantity}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fabric: ${item.product.fabric}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DummyData.formatPrice(item.price * item.quantity),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryBrown,
                ),
              ),
              if (item.quantity > 1)
                Text(
                  '(${item.quantity} × ${DummyData.formatPrice(item.price)})',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          _priceRow(
              'Subtotal', DummyData.formatPrice(widget.order.totalAmount)),
          _priceRow('Delivery Charges', 'FREE', isFree: true),
          _priceRow('Packaging', 'FREE', isFree: true),
          const Divider(),
          _priceRow(
            'Total Amount',
            DummyData.formatPrice(widget.order.totalAmount),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: primaryBrown),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.order.deliveryAddress,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
          if (widget.order.deliveryDate != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: primaryBrown),
                const SizedBox(width: 8),
                Text(
                  'Delivered on ${_formatDate(widget.order.deliveryDate!)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTailorInfo() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tailor Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryBrown,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.store, size: 16, color: primaryBrown),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.order.tailorName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryBrown,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.order.tailorAddress,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isActiveOrder = widget.order.status == OrderStatus.pending ||
        widget.order.status == OrderStatus.confirmed ||
        widget.order.status == OrderStatus.stitching ||
        widget.order.status == OrderStatus.ready ||
        widget.order.status == OrderStatus.shipped;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isActiveOrder)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _showSnackBar(
                      context, 'Tracking order ${widget.order.orderNumber}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentBrown,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (isActiveOrder) const SizedBox(height: 12),
          if (!isActiveOrder)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showSnackBar(context,
                      'Reordering items from ${widget.order.orderNumber}');
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: accentBrown),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Reorder Items',
                  style: TextStyle(
                    color: accentBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                _showSnackBar(context,
                    'Contact support for order ${widget.order.orderNumber}');
              },
              child: Text(
                'Need Help?',
                style: TextStyle(
                  color: primaryBrown,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedProgressStepper() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stepIcon(Icons.shopping_bag_outlined, "Order Placed",
                _isStepCompleted(0)),
            _stepIcon(Icons.edit_outlined, "Picked Up", _isStepCompleted(1)),
            _stepIcon(
                Icons.colorize_outlined, "Stitching", _isStepCompleted(2)),
            _stepIcon(
                Icons.local_shipping_outlined, "Shipped", _isStepCompleted(3)),
            _stepIcon(
                Icons.check_circle_outline, "Delivered", _isStepCompleted(4)),
          ],
        ),
        const SizedBox(height: 12),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 2,
              color: Colors.grey.shade200,
              margin: const EdgeInsets.symmetric(horizontal: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                5,
                (index) => CircleAvatar(
                  radius: 4,
                  backgroundColor: _getStepColor(index),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Placed',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('Picked Up',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('Stitching',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('Shipped',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
            Text('Delivered',
                style: TextStyle(fontSize: 10, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _stepIcon(IconData icon, String label, bool isActive) {
    Color color = isActive ? primaryBrown : Colors.grey;
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _priceRow(String label, String price,
      {bool isBold = false, bool isFree = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Colors.grey[700],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isFree ? Colors.green : Colors.grey[700],
            ),
          ),
        ],
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

  bool _isStepCompleted(int step) {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return step == 0;
      case OrderStatus.confirmed:
        return step <= 1;
      case OrderStatus.stitching:
        return step <= 2;
      case OrderStatus.ready:
        return step <= 2;
      case OrderStatus.shipped:
        return step <= 3;
      case OrderStatus.delivered:
        return step <= 4;
      case OrderStatus.cancelled:
        return false;
    }
  }

  Color _getStepColor(int step) {
    if (_isStepCompleted(step)) {
      return accentBrown;
    }
    return Colors.grey.shade300;
  }

  int _getExpectedDeliveryDays() {
    switch (widget.order.status) {
      case OrderStatus.pending:
        return 7;
      case OrderStatus.confirmed:
        return 6;
      case OrderStatus.stitching:
        return 4;
      case OrderStatus.ready:
        return 2;
      case OrderStatus.shipped:
        return 1;
      case OrderStatus.delivered:
        return 0;
      case OrderStatus.cancelled:
        return 0;
    }
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: accentBrown,
      ),
    );
  }
}
