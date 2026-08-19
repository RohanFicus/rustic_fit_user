import 'package:flutter/material.dart';

import '../models/dummy_data.dart';
import '../widgets/app_network_image.dart';

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
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: lightCream,
      appBar: _buildAppBar(context),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: darkBrown, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Details',
            style: TextStyle(
                color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            '#${widget.order.orderNumber}',
            style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: darkBrown, size: 20),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 24),
          _buildItemsSection(),
          const SizedBox(height: 24),
          _buildTailorInfo(),
          const SizedBox(height: 24),
          _buildDeliveryInfo(),
          const SizedBox(height: 24),
          _buildPricingSection(),
          const SizedBox(height: 40),
          _buildActionButtons(false),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(),
                const SizedBox(height: 32),
                _buildItemsSection(),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildTailorInfo(),
                const SizedBox(height: 24),
                _buildDeliveryInfo(),
                const SizedBox(height: 24),
                _buildPricingSection(),
                const SizedBox(height: 32),
                _buildActionButtons(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Track Progress',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: darkBrown),
              ),
              _buildStatusBadge(widget.order.status),
            ],
          ),
          const SizedBox(height: 32),
          _buildProgressStepper(widget.order.status),
        ],
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
      child: Text(
        _getStatusText(status).toUpperCase(),
        style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5),
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
                                ? primaryGold
                                : const Color(0xFFE9ECEF),
                          ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: index <= currentStep ? primaryGold : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: index <= currentStep
                            ? primaryGold
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
                                ? primaryGold
                                : const Color(0xFFE9ECEF),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                steps[index],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCurrent
                      ? darkBrown
                      : (isPast ? primaryGold : Colors.grey[400]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Items',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: darkBrown),
        ),
        const SizedBox(height: 16),
        ...widget.order.items.map((item) => _buildOrderItem(item)),
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AppNetworkImage(
                imageUrl: item.product.image,
                width: 60,
                height: 80,
                fit: BoxFit.cover),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 6),
                Text(
                  'Size: ${item.size} • Fabric: ${item.fabric ?? item.product.fabric}',
                  style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${item.quantity}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            DummyData.formatPrice(item.price * item.quantity),
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: primaryGold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTailorInfo() {
    return _buildInfoCard(
      'Tailor Partner',
      widget.order.tailorName,
      widget.order.tailorAddress,
      Icons.storefront_rounded,
    );
  }

  Widget _buildDeliveryInfo() {
    return _buildInfoCard(
      'Shipping Address',
      'Primary Residence',
      widget.order.deliveryAddress,
      Icons.local_shipping_rounded,
    );
  }

  Widget _buildInfoCard(
      String section, String title, String subtitle, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: primaryGold),
              const SizedBox(width: 12),
              Text(section,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: darkBrown)),
            ],
          ),
          const SizedBox(height: 20),
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: darkBrown,
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
            'Order Summary',
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 24),
          _priceRow('Subtotal', DummyData.formatPrice(widget.order.totalAmount),
              Colors.white70),
          _priceRow('Shipping', 'FREE', Colors.greenAccent),
          const Divider(color: Colors.white10, height: 32),
          _priceRow('Total Amount',
              DummyData.formatPrice(widget.order.totalAmount), Colors.white,
              isBold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, Color color,
      {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  TextStyle(color: color.withValues(alpha: 0.6), fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isWide) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('Download Invoice',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () {},
            child: const Text('Contact Support',
                style:
                    TextStyle(color: darkBrown, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
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
}
