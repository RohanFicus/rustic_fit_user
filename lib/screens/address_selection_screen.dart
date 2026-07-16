import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import 'payment_screen.dart';

class AddressSelectionScreen extends StatefulWidget {
  final Product product;
  final String? customFabric;
  final String? customColor;
  final String? customType;

  const AddressSelectionScreen({
    super.key,
    required this.product,
    this.customFabric,
    this.customColor,
    this.customType,
  });

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  int _selectedAddressIndex = 0;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Select Address",
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
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
          _buildStep(2, "Address", true, false),
          _buildConnector(false),
          _buildStep(3, "Payment", false, false),
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
              color: isCompleted || isActive ? primaryGold : const Color(0xFFE9ECEF),
              width: 2,
            ),
            boxShadow: isActive ? [BoxShadow(color: primaryGold.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
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
          _buildSectionHeader("Where should we ship?", Icons.local_shipping_outlined),
          const SizedBox(height: 24),
          ..._addresses.asMap().entries.map((entry) => _buildAddressCard(entry.key, false)),
          const SizedBox(height: 16),
          _buildAddNewCard(false),
          const SizedBox(height: 32),
          _buildQuickActions(),
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
                _buildSectionHeader("Select Delivery Destination", Icons.local_shipping_outlined),
                const SizedBox(height: 32),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 180,
                  ),
                  itemCount: _addresses.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _addresses.length) return _buildAddNewCard(true);
                    return _buildAddressCard(index, true);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 60),
          Expanded(
            flex: 1,
            child: Column(
              children: [
                _buildOrderSummaryCard(),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: darkBrown),
        ),
      ],
    );
  }

  Widget _buildAddressCard(int index, bool isWide) {
    final address = _addresses[index];
    final isSelected = _selectedAddressIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedAddressIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: isWide ? 0 : 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? primaryGold : const Color(0xFFE9ECEF),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? primaryGold.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.02),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryGold : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    address['type']!.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? Colors.white : darkBrown,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: primaryGold, size: 22),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              address['address']!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: darkBrown, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              address['city']!,
              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.phone_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 8),
                Text(
                  address['phone']!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCard(bool isWide) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: isWide ? null : 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE9ECEF), style: BorderStyle.solid),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.add_rounded, color: primaryGold, size: 24),
              ),
              if (isWide) ...[
                const SizedBox(height: 16),
                const Text(
                  "Add New Address",
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: darkBrown),
                ),
              ] else ...[
                const SizedBox(height: 8),
                const Text("Add New Address", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: darkBrown)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Quick Actions",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: darkBrown, letterSpacing: 0.5),
        ),
        const SizedBox(height: 16),
        _buildActionTile(Icons.my_location_rounded, "Use Current Location", "Detect via GPS"),
        const SizedBox(height: 12),
        _buildActionTile(Icons.storefront_rounded, "Pick up from Studio", "Visit our Beverly Hills boutique"),
      ],
    );
  }

  Widget _buildActionTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: darkBrown, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: darkBrown)),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFE9ECEF)),
        ],
      ),
    );
  }

  Widget _buildOrderSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Selected Garment",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: darkBrown),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(widget.product.image, width: 80, height: 100, fit: BoxFit.cover),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      "${widget.customFabric ?? widget.product.fabric} • ${widget.customType ?? widget.product.type}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      DummyData.formatPrice(widget.product.price),
                      style: const TextStyle(color: primaryGold, fontWeight: FontWeight.w900, fontSize: 18),
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

  Widget _buildBottomAction(bool isWide) {
    return Container(
      padding: EdgeInsets.all(isWide ? 0 : 24),
      decoration: BoxDecoration(
        color: isWide ? Colors.transparent : Colors.white,
        border: isWide ? null : Border(top: BorderSide(color: const Color(0xFFE9ECEF))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaymentScreen(
                      product: widget.product,
                      customFabric: widget.customFabric,
                      customColor: widget.customColor,
                      customType: widget.customType,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text(
                "Proceed to Payment",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
