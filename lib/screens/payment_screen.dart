import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/dummy_data.dart';
import '../services/api_service.dart';
import 'main_container.dart';

class PaymentScreen extends StatefulWidget {
  final Product product;
  final Map<String, dynamic>? selectedSize;
  final String? customFabric;
  final String? customColor;
  final String? customType;
  final String deliveryAddress;
  final String addressId;
  final String pincode;
  final String? measurementsJson;
  final XFile? referenceImage;
  final String? specialInstruction;

  const PaymentScreen({
    super.key,
    required this.product,
    this.selectedSize,
    this.customFabric,
    this.customColor,
    this.customType,
    required this.deliveryAddress,
    required this.addressId,
    required this.pincode,
    this.measurementsJson,
    this.referenceImage,
    this.specialInstruction,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  int _selectedMethod = 0; // 0: Card, 1: UPI, 2: COD

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Finalize Payment",
          style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          _buildProgressStepper(),
          Expanded(
            child: isWide ? _buildWideLayout() : _buildMobileLayout(),
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : _buildBottomAction(false),
    );
  }

  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: const Color(0xFFE9ECEF))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStep(1, "Fitting", true, true),
          _buildConnector(true),
          _buildStep(2, "Address", true, true),
          _buildConnector(true),
          _buildStep(3, "Payment", true, false),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive, bool isCompleted) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? primaryGold : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted || isActive
                  ? primaryGold
                  : const Color(0xFFE9ECEF),
              width: 2,
            ),
            boxShadow: isActive && !isCompleted
                ? [
                    BoxShadow(
                        color: primaryGold.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    step.toString(),
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey[400],
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? darkBrown : Colors.grey[400],
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isActive) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
      color: isActive ? primaryGold : const Color(0xFFE9ECEF),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummaryCard(false),
          const SizedBox(height: 32),
          _buildSectionHeader(
              "Payment Method", Icons.account_balance_wallet_outlined),
          const SizedBox(height: 16),
          _buildPaymentMethod(
              0, "Credit / Debit Card", Icons.credit_card_rounded),
          _buildPaymentMethod(
              1, "UPI / Digital Wallet", Icons.qr_code_2_rounded),
          _buildPaymentMethod(2, "Cash on Delivery", Icons.payments_rounded),
          const SizedBox(height: 32),
          _buildPriceBreakdown(),
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
                _buildSectionHeader("Select Payment Mode",
                    Icons.account_balance_wallet_outlined),
                const SizedBox(height: 32),
                // _buildPaymentMethod(
                //     0, "Credit / Debit Card", Icons.credit_card_rounded),
                // _buildPaymentMethod(
                //     1, "UPI / Digital Wallet", Icons.qr_code_2_rounded),
                _buildPaymentMethod(
                    0, "Cash on Delivery", Icons.payments_rounded),
                // const SizedBox(height: 40),
                // _buildSectionHeader(
                //     "Price Breakdown", Icons.receipt_long_outlined),
                const SizedBox(height: 24),
                _buildPriceBreakdown(),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildOrderSummaryCard(true),
                const SizedBox(height: 32),
                _buildBottomAction(true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryGold, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w900, color: darkBrown),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryGold.withOpacity(0.04),
            primaryGold.withOpacity(0.08),
            darkBrown.withOpacity(0.02),
          ],
        ),
      ),
      child: const Center(
        child: Opacity(
          opacity: 0.15,
          child: Icon(
            Icons.checkroom_rounded,
            size: 32,
            color: primaryGold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 32 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F3F5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Garment Details",
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w900, color: darkBrown),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  widget.product.image,
                  width: 80,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholderImage(80, 100),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: darkBrown)),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.customFabric ?? widget.product.fabric} • ${widget.customType ?? widget.product.type}",
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DummyData.formatPrice(widget.product.price),
                      style: const TextStyle(
                          color: primaryGold,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
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

  Widget _buildPaymentMethod(int index, String title, IconData icon) {
    final isSelected = _selectedMethod == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryGold : const Color(0xFFE9ECEF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: primaryGold.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10))
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? primaryGold : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? null
                    : [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10)
                      ],
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : primaryGold, size: 22),
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? darkBrown : Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: primaryGold, size: 24)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE9ECEF), width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: darkBrown,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildPriceRow("Garment Total", widget.product.price, Colors.white70),
          const SizedBox(height: 16),
          _buildPriceRow("Master Tailor Visit", 0, Colors.greenAccent,
              isFree: true),
          const SizedBox(height: 16),
          _buildPriceRow("Premium Packaging", 0, Colors.greenAccent,
              isFree: true),
          const SizedBox(height: 16),
          _buildPriceRow("Bespoke Shipping", 0, Colors.greenAccent,
              isFree: true),
          const Divider(color: Colors.white10, height: 48),
          _buildPriceRow("Grand Total", widget.product.price, Colors.white,
              isTotal: true),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double amount, Color color,
      {bool isTotal = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.6),
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            fontSize: isTotal ? 16 : 14,
          ),
        ),
        Text(
          isFree ? "COMPLIMENTARY" : DummyData.formatPrice(amount),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 24 : 15,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 0 : 24),
      decoration: BoxDecoration(
        color: isWide ? Colors.transparent : Colors.white,
        border: isWide
            ? null
            : Border(top: BorderSide(color: const Color(0xFFE9ECEF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(color: primaryGold),
                  ),
                );

                try {
                  // 1. Fetch serviceLocationId
                  final serviceLocationId =
                      await ApiService.fetchServiceLocationId(widget.pincode);

                  // 2. Find sizeId
                  String sizeId =
                      'c535b1f2-0fdd-43da-ac7d-bc4b0d6c3ddc'; // Default L sizeId from prompt
                  if (widget.selectedSize != null) {
                    sizeId = widget.selectedSize!['sizeId']?.toString() ??
                        widget.selectedSize!['id']?.toString() ??
                        sizeId;
                  } else {
                    final rawSizes = widget.product.rawProductSizes;
                    if (rawSizes != null && rawSizes.isNotEmpty) {
                      bool found = false;
                      for (var sizeMap in rawSizes) {
                        final code =
                            sizeMap['sizeCode']?.toString().toUpperCase();
                        if (code == 'L' || code == 'M') {
                          sizeId = sizeMap['sizeId']?.toString() ??
                              sizeMap['id']?.toString() ??
                              sizeId;
                          found = true;
                          break;
                        }
                      }
                      if (!found) {
                        sizeId = rawSizes.first['sizeId']?.toString() ??
                            rawSizes.first['id']?.toString() ??
                            sizeId;
                      }
                    }
                  }

                  // 3. Get measurements JSON from widget
                  final measurementsJson = widget.measurementsJson ?? '[]';

                  // 4. Reference images
                  final List<XFile> imageFiles = [];
                  if (widget.referenceImage != null) {
                    imageFiles.add(widget.referenceImage!);
                  }

                  // 5. Call API
                  final responseMap = await ApiService.createOrder(
                    customerAddressId: widget.addressId.isNotEmpty
                        ? widget.addressId
                        : 'f4669f13-5040-4fb0-af95-5544b2e03917',
                    productId: widget.product.id,
                    sizeId: sizeId,
                    measurementSource: 'CUSTOMER',
                    specialInstruction:
                        widget.specialInstruction?.isNotEmpty == true
                            ? widget.specialInstruction!
                            : 'This is testing Order',
                    measurements: measurementsJson,
                    imageFiles: imageFiles,
                    serviceLocationId: serviceLocationId ??
                        'dc2027ef-b5ff-4edf-8fb8-f92c5daab801',
                  );

                  bool success = false;

                  if (responseMap != null &&
                      responseMap['status'] == true &&
                      responseMap['data'] != null) {
                    final data = responseMap['data'];
                    final orderData = data['order'] != null ? data['order'] : data;
                    final orderId = orderData['id']?.toString() ?? '';
                    final orderNumber = orderData['orderNumber']?.toString() ?? '';
                    final createdAtRaw = orderData['createdAt']?.toString() ?? '';
                    final orderDate =
                        DateTime.tryParse(createdAtRaw) ?? DateTime.now();
                    final totalAmount = double.tryParse(
                            orderData['totalAmount']?.toString() ?? '') ??
                        widget.product.price;

                    final estDeliveryRaw =
                        orderData['estimatedDeliveryDate']?.toString() ?? '';
                    final deliveryDate = DateTime.tryParse(estDeliveryRaw) ??
                        orderDate.add(const Duration(days: 10));

                    final orderStatusStr =
                        orderData['orderStatus']?.toString() ?? 'ORDER_CREATED';
                    OrderStatus orderStatus = OrderStatus.pending;
                    if (orderStatusStr == 'ORDER_CREATED') {
                      orderStatus = OrderStatus.pending;
                    } else if (orderStatusStr.toLowerCase() == 'confirmed') {
                      orderStatus = OrderStatus.confirmed;
                    }

                    final items = [
                      OrderItem(
                        product: widget.product,
                        size: orderData['size']?['sizeCode']?.toString() ??
                            widget.selectedSize?['sizeCode']?.toString() ??
                            'M',
                        quantity: 1,
                        price: widget.product.price,
                      )
                    ];

                    final newOrder = Order(
                      id: orderId,
                      orderNumber: orderNumber,
                      orderDate: orderDate,
                      items: items,
                      status: orderStatus,
                      totalAmount: totalAmount,
                      deliveryAddress: widget.deliveryAddress,
                      tailorName: 'Bhandari Tailors',
                      tailorAddress:
                          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
                      deliveryDate: deliveryDate,
                    );

                    DummyData.orders
                        .insert(0, newOrder); // Prepend to the local list
                    success = true;

                    // Verify payment if payment details exist
                    final paymentData = data['payment'];
                    if (paymentData != null) {
                      final razorpayOrderId =
                          paymentData['razorpayOrderId']?.toString() ?? '';
                      final razorpayPaymentId =
                          paymentData['paymentReference']?.toString() ??
                              paymentData['paymentId']?.toString() ??
                              '';
                      if (orderNumber.isNotEmpty &&
                          razorpayOrderId.isNotEmpty &&
                          razorpayPaymentId.isNotEmpty) {
                        try {
                          await ApiService.verifyOrderPayment(
                            orderNumber: orderNumber,
                            razorpayOrderId: razorpayOrderId,
                            razorpayPaymentId: razorpayPaymentId,
                            razorpaySignature: 'test_signature',
                          );
                        } catch (e) {
                          print('Payment verification error during checkout: $e');
                        }
                      }
                    }
                  }

                  if (mounted) {
                    Navigator.pop(context); // Dismiss loading indicator
                  }

                  if (success) {
                    _showSuccessDialog();
                  } else {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Failed to place order. Please try again.'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Dismiss loading indicator
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.redAccent,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "Authorize & Place Order",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.green, size: 48),
              ),
              const SizedBox(height: 32),
              const Text(
                "Order Secured",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: darkBrown),
              ),
              const SizedBox(height: 16),
              Text(
                "Your bespoke journey has begun. Our master tailor will coordinate your measurement appointment shortly.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.6,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const MainContainer()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text("Return to Studio",
                      style: TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
