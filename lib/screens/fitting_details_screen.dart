import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rustic_fit/screens/address_selection_screen.dart';

import '../models/dummy_data.dart';

class FittingDetailsScreen extends StatefulWidget {
  final Product product;

  const FittingDetailsScreen({super.key, required this.product});

  @override
  State<FittingDetailsScreen> createState() => _FittingDetailsScreenState();
}

class _FittingDetailsScreenState extends State<FittingDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  final _lengthController = TextEditingController();
  final _messageController = TextEditingController();

  // Customization Controllers
  late final TextEditingController _fabricController;
  late final TextEditingController _colorController;
  late final TextEditingController _typeController;

  File? _referenceImage;
  final ImagePicker _picker = ImagePicker();

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    _fabricController = TextEditingController(text: widget.product.fabric);
    _colorController = TextEditingController(text: widget.product.color);
    _typeController = TextEditingController(text: widget.product.type);

    // Prefill from current logged-in user
    _nameController.text = DummyData.currentUser.name;
    _phoneController.text = DummyData.currentUser.phone;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    _lengthController.dispose();
    _messageController.dispose();
    _fabricController.dispose();
    _colorController.dispose();
    _typeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _referenceImage = File(image.path);
      });
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
          "Customization & Fitting",
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
          _buildStep(1, "Fitting", true),
          _buildConnector(true),
          _buildStep(2, "Address", false),
          _buildConnector(false),
          _buildStep(3, "Payment", false),
        ],
      ),
    );
  }

  Widget _buildStep(int step, String label, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? primaryGold : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? primaryGold : const Color(0xFFE9ECEF),
              width: 2,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: primaryGold.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          child: Center(
            child: Text(
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(
                "Personal Information", Icons.person_outline_rounded),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: "Full Name",
              hint: "Enter your name",
              icon: Icons.person_rounded,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: "Phone Number",
              hint: "Enter your phone number",
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 40),
            _buildSectionHeader("Body Measurements", Icons.straighten_rounded),
            const SizedBox(height: 8),
            Text(
              "Provide accurate measurements in inches for a perfect bespoke fit.",
              style:
                  TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                    child: _buildMeasurementField(_chestController, "Chest")),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildMeasurementField(_waistController, "Waist")),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _buildMeasurementField(_hipsController, "Hips")),
                const SizedBox(width: 16),
                Expanded(
                    child: _buildMeasurementField(_lengthController, "Length")),
              ],
            ),
            const SizedBox(height: 40),
            _buildSectionHeader(
                "Style Customization", Icons.auto_awesome_rounded),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _fabricController,
              label: "Fabric Selection",
              hint: "E.g., Premium Italian Wool",
              icon: Icons.texture_rounded,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _colorController,
                    label: "Color",
                    hint: "E.g., Charcoal Grey",
                    icon: Icons.palette_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _typeController,
                    label: "Stitch Type",
                    hint: "E.g., Slim Fit",
                    icon: Icons.style_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _messageController,
              label: "Additional Requests",
              hint: "E.g., Side vents, notch lapel details...",
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            _buildTailorSupportCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(40),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                      "Customization Details", Icons.auto_awesome_rounded),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _fabricController,
                    label: "Fabric Choice",
                    hint: "Specify fabric type",
                    icon: Icons.texture_rounded,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _colorController,
                          label: "Desired Color",
                          hint: "Specify color",
                          icon: Icons.palette_rounded,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildTextField(
                          controller: _typeController,
                          label: "Fit Style",
                          hint: "Specify fit type",
                          icon: Icons.style_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildSectionHeader(
                      "Measurement Profile", Icons.straighten_rounded),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                          child: _buildMeasurementField(
                              _chestController, "Chest")),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildMeasurementField(
                              _waistController, "Waist")),
                      const SizedBox(width: 20),
                      Expanded(
                          child:
                              _buildMeasurementField(_hipsController, "Hips")),
                      const SizedBox(width: 20),
                      Expanded(
                          child: _buildMeasurementField(
                              _lengthController, "Length")),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _buildImagePicker(),
                  const SizedBox(height: 32),
                  _buildTextField(
                    controller: _messageController,
                    label: "Specific Styling Instructions",
                    hint: "Detailed notes for the master tailor...",
                    maxLines: 5,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 60),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: const Color(0xFFE9ECEF)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(
                            "Contact Info", Icons.person_outline_rounded),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _nameController,
                          label: "Full Name",
                          hint: "Enter name",
                          icon: Icons.person_rounded,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _phoneController,
                          label: "Phone Number",
                          hint: "Enter phone",
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
                        _buildTailorSupportCard(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildBottomAction(true),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: darkBrown,
              letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: darkBrown),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500),
            prefixIcon:
                icon != null ? Icon(icon, color: primaryGold, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryGold, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
          validator: (value) {
            if (maxLines == 1 && (value == null || value.isEmpty))
              return 'Required';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMeasurementField(
      TextEditingController controller, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w800, color: darkBrown),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w900, color: primaryGold),
          decoration: InputDecoration(
            hintText: "0.0",
            suffixText: "\"",
            suffixStyle: const TextStyle(
                color: primaryGold, fontWeight: FontWeight.w900),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE9ECEF)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: primaryGold, width: 2),
            ),
          ),
          validator: (value) => (value == null || value.isEmpty) ? '' : null,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Design Inspiration",
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: darkBrown),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickImage,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE9ECEF), width: 1.5),
            ),
            child: _referenceImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_referenceImage!,
                            width: double.infinity,
                            height: 160,
                            fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () => setState(() => _referenceImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.close_rounded,
                                size: 18, color: Colors.red),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: primaryGold.withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: const Icon(Icons.add_photo_alternate_rounded,
                            color: primaryGold, size: 32),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Upload design reference or sketch",
                        style: TextStyle(
                            color: darkBrown,
                            fontSize: 13,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "PNG or JPG up to 5MB",
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTailorSupportCard() {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.support_agent_rounded,
                color: primaryGold, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Need Sizing Help?",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  "Our master tailor can guide you via video call.",
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      height: 1.4),
                ),
              ],
            ),
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
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddressSelectionScreen(
                        product: widget.product,
                        customFabric: _fabricController.text,
                        customColor: _colorController.text,
                        customType: _typeController.text,
                      ),
                    ),
                  );
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
                "Continue to Address Selection",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
