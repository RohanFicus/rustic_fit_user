import 'package:flutter/material.dart';

import '../models/dummy_data.dart';

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

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFF7F5F2);
  static const Color darkBrown = Color(0xFF2D2926);

  @override
  void initState() {
    super.initState();
    final measurements = DummyData.currentUser.bodyMeasurements;
    _chestController = TextEditingController(text: measurements['chest'] ?? '');
    _waistController = TextEditingController(text: measurements['waist'] ?? '');
    _hipsController = TextEditingController(text: measurements['hips'] ?? '');
    _shoulderController =
        TextEditingController(text: measurements['shoulder'] ?? '');
  }

  @override
  void dispose() {
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _shoulderController.dispose();
    super.dispose();
  }

  void _saveMeasurements() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        DummyData.currentUser.bodyMeasurements['chest'] = _chestController.text;
        DummyData.currentUser.bodyMeasurements['waist'] = _waistController.text;
        DummyData.currentUser.bodyMeasurements['hips'] = _hipsController.text;
        DummyData.currentUser.bodyMeasurements['shoulder'] =
            _shoulderController.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Measurements saved successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

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
          "Body Fitting Sizes",
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: primaryGold),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "These measurements will be used as default when you place a new bespoke order.",
                        style: TextStyle(
                          color: darkBrown.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _buildMeasurementField(
                controller: _chestController,
                label: "Chest",
                hint: "Enter chest size",
                icon: Icons.straighten,
              ),
              const SizedBox(height: 20),
              _buildMeasurementField(
                controller: _waistController,
                label: "Waist",
                hint: "Enter waist size",
                icon: Icons.straighten,
              ),
              const SizedBox(height: 20),
              _buildMeasurementField(
                controller: _hipsController,
                label: "Hips",
                hint: "Enter hips size",
                icon: Icons.straighten,
              ),
              const SizedBox(height: 20),
              _buildMeasurementField(
                controller: _shoulderController,
                label: "Shoulder",
                hint: "Enter shoulder size",
                icon: Icons.straighten,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saveMeasurements,
                  style: FilledButton.styleFrom(
                    backgroundColor: primaryGold,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeasurementField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: primaryGold, size: 20),
            suffixText: "Inches",
            suffixStyle:
                TextStyle(color: darkBrown.withOpacity(0.4), fontSize: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryGold, width: 1.5),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            final n = double.tryParse(value);
            if (n == null) {
              return 'Please enter a valid number';
            }
            if (n <= 0 || n > 100) {
              return 'Please enter a realistic measurement (0-100)';
            }
            return null;
          },
        ),
      ],
    );
  }
}
