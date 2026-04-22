import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import 'payment_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  final Product product;

  const AddressSelectionScreen({super.key, required this.product});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  int _selectedAddressIndex = 0;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFF7F5F2);
  static const Color darkBrown = Color(0xFF2D2926);

  final List<Map<String, String>> _addresses = [
    {
      "type": "Home",
      "address": "123 Elegance Avenue, Beverly Hills",
      "city": "Los Angeles, CA 90210",
      "phone": "+1 (555) 123-4567"
    },
    {
      "type": "Office",
      "address": "456 Fashion District, Suite 200",
      "city": "New York, NY 10018",
      "phone": "+1 (555) 987-6543"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Delivery Address",
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          _buildProgressStepper(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Saved Addresses",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: darkBrown,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, color: primaryGold, size: 20),
                        label: const Text(
                          "Add New",
                          style: TextStyle(color: primaryGold, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    _addresses.length,
                    (index) => _buildAddressCard(index),
                  ),
                  const SizedBox(height: 24),
                  _buildQuickAction(
                    Icons.location_on_outlined,
                    "Current Location",
                    "Use your device's GPS for delivery",
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildProgressStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.white,
      child: Row(
        children: [
          _buildStep(1, "Fitting", true, true),
          _buildDivider(true),
          _buildStep(2, "Address", true, false),
          _buildDivider(false),
          _buildStep(3, "Payment", false, false),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isCompleted ? primaryGold : (isActive ? primaryGold : Colors.grey.withOpacity(0.2)),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isCompleted 
              ? const Icon(Icons.check, color: Colors.white, size: 14)
              : Text(
                  step.toString(),
                  style: TextStyle(
                    color: isActive ? Colors.white : darkBrown.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? darkBrown : darkBrown.withOpacity(0.5),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isActive) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? primaryGold : Colors.grey.withOpacity(0.2),
      ),
    );
  }

  Widget _buildAddressCard(int index) {
    final address = _addresses[index];
    final isSelected = _selectedAddressIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryGold : Colors.black.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: primaryGold.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? primaryGold : lightCream,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                address['type'] == 'Home' ? Icons.home_outlined : Icons.work_outline,
                color: isSelected ? Colors.white : primaryGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address['type']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: darkBrown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address['address']!,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    address['city']!,
                    style: TextStyle(
                      color: darkBrown.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    address['phone']!,
                    style: const TextStyle(
                      color: darkBrown,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: primaryGold, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: darkBrown, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: darkBrown,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: darkBrown.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(product: widget.product),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: primaryGold,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "Continue to Payment",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }
}
