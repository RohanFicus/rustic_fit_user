import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import '../services/data_service.dart';

class PaymentScreen extends StatelessWidget {
  final Product product;
  final String selectedSize;
  final int quantity;
  final String deliveryAddress;
  final String specialInstructions;
  final String? selectedTailorId;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final bool isStoreSelection;

  const PaymentScreen({
    super.key,
    required this.product,
    required this.selectedSize,
    required this.quantity,
    required this.deliveryAddress,
    this.specialInstructions = '',
    this.selectedTailorId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.isStoreSelection = true,
  });

  final Color primaryBrown = const Color(0xFF5D4037);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Finalize Request", style: TextStyle(color: primaryBrown)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Order Summary",
                style: TextStyle(
                    color: primaryBrown, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildOrderSummaryCard(),
            const SizedBox(height: 24),
            Text("Select Payment Method",
                style: TextStyle(
                    color: primaryBrown, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            _buildPricingBreakdown(),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                final totalPrice = product.price * quantity;
                // Process payment logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Payment of ${DummyData.formatPrice(totalPrice)} processed successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA67C52),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              child: Text(
                  "Pay ${DummyData.formatPrice(product.price * quantity)}",
                  style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 8),
            const Text("100% Safe and Secure Payment",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    final totalPrice = product.price * quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(product.image,
                      width: 60, height: 60, fit: BoxFit.cover)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(product.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBrown)),
                          Text(DummyData.formatPrice(product.price),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBrown))
                        ]),
                    Text("Size: $selectedSize | Quantity: $quantity",
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.local_shipping, size: 14, color: primaryBrown),
                      const SizedBox(width: 4),
                      Text("Delivery in ${product.deliveryDays} Days",
                          style: TextStyle(fontSize: 11))
                    ]),
                  ])),
            ],
          ),
          const Divider(height: 24),
          Text(deliveryAddress,
              style: TextStyle(fontSize: 11, color: Colors.grey)),

          // Show tailor or pickup info
          if (isStoreSelection && selectedTailorId != null) ...[
            const SizedBox(height: 8),
            Text("Tailor: ${_getTailorName(selectedTailorId!)}",
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ] else if (!isStoreSelection &&
              selectedDate != null &&
              selectedTimeSlot != null) ...[
            const SizedBox(height: 8),
            Text("Pickup: ${_formatDate(selectedDate!)} - $selectedTimeSlot",
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],

          if (specialInstructions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Special Instructions: $specialInstructions",
                style: TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          RadioListTile(
              value: 1,
              groupValue: 1,
              onChanged: (v) {},
              title: const Text("Debit / Credit Card"),
              secondary: const Icon(Icons.credit_card)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                TextField(
                    decoration: InputDecoration(
                        hintText: "1234  5678  9012  3456",
                        suffixIcon: Icon(Icons.edit, size: 16))),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                      child: TextField(
                          decoration: InputDecoration(hintText: "John Doe"))),
                  const SizedBox(width: 8),
                  SizedBox(
                      width: 50,
                      child: TextField(
                          decoration: InputDecoration(hintText: "MM"))),
                  const SizedBox(width: 4),
                  SizedBox(
                      width: 50,
                      child: TextField(
                          decoration: InputDecoration(hintText: "YY"))),
                ])
              ],
            ),
          ),
          const Divider(),
          RadioListTile(
              value: 2,
              groupValue: 1,
              onChanged: (v) {},
              title: const Text("UPI"),
              secondary: const Icon(Icons.account_balance_wallet)),
          const Divider(),
          RadioListTile(
              value: 3,
              groupValue: 1,
              onChanged: (v) {},
              title: const Text("Cash on Delivery"),
              secondary: const Icon(Icons.money)),
        ],
      ),
    );
  }

  Widget _buildPricingBreakdown() {
    final subtotal = product.price * quantity;
    final shipping = 0; // Free shipping
    final total = subtotal + shipping;

    return Column(
      children: [
        _priceRow(
            "Subtotal (${quantity} items)", DummyData.formatPrice(subtotal)),
        _priceRow("Free Shipping", DummyData.formatPrice(shipping.toDouble())),
        const Divider(height: 32),
        _priceRow("Total", DummyData.formatPrice(total), isBold: true),
      ],
    );
  }

  Widget _priceRow(String label, String price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(price,
              style: TextStyle(
                  fontSize: isBold ? 18 : 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  String _getTailorName(String tailorId) {
    final dataService = DataService();
    final tailor = dataService.getTailorById(tailorId);
    return tailor?.name ?? 'Unknown Tailor';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
