import 'package:flutter/material.dart';

import '../models/dummy_data.dart';
import '../services/data_service.dart';

class BodyMeasurementsScreen extends StatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  State<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends State<BodyMeasurementsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _chestController;
  late TextEditingController _waistController;
  late TextEditingController _hipsController;
  late TextEditingController _shoulderController;
  late TextEditingController _lengthController;
  late TextEditingController _sleevesController;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    final measurements = DummyData.currentUser.bodyMeasurements;
    _chestController =
        TextEditingController(text: measurements['chest'] ?? '42');
    _waistController =
        TextEditingController(text: measurements['waist'] ?? '36');
    _hipsController = TextEditingController(text: measurements['hips'] ?? '40');
    _shoulderController =
        TextEditingController(text: measurements['shoulder'] ?? '18');
    _lengthController =
        TextEditingController(text: measurements['length'] ?? '29');
    _sleevesController =
        TextEditingController(text: measurements['sleeves'] ?? '25');
  }

  @override
  void dispose() {
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    _lengthController.dispose();
    _sleevesController.dispose();
    super.dispose();
  }

  void _saveMeasurements() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        DataService().updateAllBodyMeasurements({
          'chest': _chestController.text,
          'waist': _waistController.text,
          'hips': _hipsController.text,
          'shoulder': _shoulderController.text,
          'length': _lengthController.text,
          'sleeves': _sleevesController.text,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Bespoke measurements updated'),
          backgroundColor: darkBrown,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      Navigator.pop(context);
    }
  }

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
          "My Measurement Profile",
          style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            _buildSectionTitle("Core Measurements"),
            const SizedBox(height: 16),
            _buildMeasurementGrid(false),
            const SizedBox(height: 48),
            _buildSaveButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(48),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Update Fitting Sizes"),
                  const SizedBox(height: 8),
                  Text(
                    "Maintain your precise measurements for the perfect bespoke fit across all our collections.",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 40),
                  _buildMeasurementGrid(true),
                  const SizedBox(height: 60),
                  _buildSaveButton(),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.all(48),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(),
                const SizedBox(height: 40),
                const Text(
                  "Why correct measurements matter?",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: darkBrown),
                ),
                const SizedBox(height: 24),
                _buildBulletPoint("Bespoke Precision",
                    "Every garment is cut specifically to your dimensions."),
                _buildBulletPoint("Italian Craftsmanship",
                    "Ensures the drape of luxury fabrics is maintained perfectly."),
                _buildBulletPoint("One-time Setup",
                    "Update once, and we use these for all your future orders."),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: darkBrown,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.support_agent_rounded,
                          color: primaryGold, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Need a Professional?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                "Schedule a home visit from our master tailor.",
                                style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryGold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: primaryGold.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: primaryGold, size: 28),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              "Your profile sizes are saved for all future bespoke orders. You can still customize them for specific items during checkout.",
              style: TextStyle(
                  color: darkBrown.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.5,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementGrid(bool isWide) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isWide ? 3 : 2,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: isWide ? 1.5 : 1.2,
      children: [
        _buildMeasurementField(
            _chestController, "Chest", Icons.straighten_rounded),
        _buildMeasurementField(
            _waistController, "Waist", Icons.straighten_rounded),
        _buildMeasurementField(
            _hipsController, "Hips", Icons.straighten_rounded),
        _buildMeasurementField(
            _shoulderController, "Shoulder", Icons.straighten_rounded),
        _buildMeasurementField(
            _lengthController, "Length", Icons.straighten_rounded),
        _buildMeasurementField(
            _sleevesController, "Sleeves", Icons.straighten_rounded),
      ],
    );
  }

  Widget _buildMeasurementField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: darkBrown)),
          const Spacer(),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.start,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, color: primaryGold),
            decoration: InputDecoration(
              hintText: "0.0",
              suffixText: "\"",
              suffixStyle: const TextStyle(
                  color: primaryGold,
                  fontWeight: FontWeight.w900,
                  fontSize: 18),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: darkBrown,
          letterSpacing: -0.5),
    );
  }

  Widget _buildBulletPoint(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: primaryGold, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: darkBrown)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey[500], fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 300,
      child: ElevatedButton(
        onPressed: _saveMeasurements,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: primaryGold.withValues(alpha: 0.3),
        ),
        child: const Text("Save Measurement Profile",
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}
