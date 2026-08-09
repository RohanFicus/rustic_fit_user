import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_data.dart';
import '../services/api_service.dart';
import 'main_container.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String accessToken;
  final String phoneNumber;

  const ProfileSetupScreen({
    super.key,
    required this.accessToken,
    required this.phoneNumber,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  String? _selectedGender = 'MALE';
  DateTime? _selectedDob;
  File? _profileImage;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);
  static const Color greyBorder = Color(0xFFE9ECEF);

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), // default 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryGold,
              onPrimary: Colors.black,
              surface: darkBrown,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: darkBrown,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
      });
    }
  }

  String _formatDob() {
    if (_selectedDob == null) return '';
    final year = _selectedDob!.year;
    final month = _selectedDob!.month.toString().padLeft(2, '0');
    final day = _selectedDob!.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your Date of Birth'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile');
      var request = http.MultipartRequest('PUT', url);
      
      request.headers.addAll({
        'Authorization': 'Bearer ${widget.accessToken}',
        'ngrok-skip-browser-warning': 'true',
      });

      request.fields['firstName'] = _firstNameController.text.trim();
      request.fields['lastName'] = _lastNameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['gender'] = _selectedGender ?? 'MALE';
      request.fields['dateOfBirth'] = _formatDob();

      if (_profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            _profileImage!.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          final rawData = responseData['data'];
          final customer = (rawData is Map && rawData.containsKey('customer'))
              ? rawData['customer']
              : rawData;

          // Map customer data into DummyData.currentUser
          DummyData.currentUser = User(
            id: customer['id']?.toString() ?? DummyData.currentUser.id,
            name: customer['firstName'] ?? 'Customer',
            lastName: customer['lastName'] ?? '',
            dob: _formatDob(),
            email: _emailController.text.trim(),
            phone: '${customer['countryCode'] ?? ''} ${customer['mobile'] ?? ''}'.trim(),
            avatar: (customer['profileImage'] != null && customer['profileImage'].toString().isNotEmpty)
                ? customer['profileImage'].toString()
                : 'https://picsum.photos/seed/${customer['id']}/200/200.jpg',
            savedAddresses: [
              'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana'
            ],
            bodyMeasurements: {
              'chest': '38',
              'waist': '32',
              'hips': '40',
              'shoulder': '16',
            },
            paymentMethods: [
              {
                "type": "Visa",
                "number": "**** **** **** 4242",
                "expiry": "12/26",
                "holder": customer['firstName'] ?? 'Customer'
              }
            ],
          );

          await ApiService.saveSession(DummyData.currentUser.phone, widget.accessToken);

          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainContainer()),
          );
        } else {
          final message = responseData['message'] ?? 'Failed to update profile';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: darkBrown,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image with dark overlay
          Image.asset(
            'assets/images/banners/banner_1.png',
            fit: BoxFit.cover,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.8),
                  darkBrown,
                ],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 650 : 450,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Complete Your Profile',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your customer details to access premium tailoring services',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Avatar Picker
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 54,
                                    backgroundColor: primaryGold.withValues(alpha: 0.1),
                                    backgroundImage: _profileImage != null
                                        ? FileImage(_profileImage!)
                                        : null,
                                    child: _profileImage == null
                                        ? const Icon(
                                            Icons.person_outline,
                                            size: 40,
                                            color: primaryGold,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: primaryGold,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        size: 16,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Name Fields
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'FIRST NAME',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: primaryGold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _firstNameController,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        validator: (value) => value == null || value.trim().isEmpty
                                            ? 'Enter first name'
                                            : null,
                                        decoration: _inputDecoration('First Name'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'LAST NAME',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: primaryGold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _lastNameController,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        validator: (value) => value == null || value.trim().isEmpty
                                            ? 'Enter last name'
                                            : null,
                                        decoration: _inputDecoration('Last Name'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Email
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EMAIL ADDRESS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    color: primaryGold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Enter email address';
                                    }
                                    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                    if (!emailRegExp.hasMatch(value.trim())) {
                                      return 'Enter a valid email address';
                                    }
                                    return null;
                                  },
                                  decoration: _inputDecoration('email@example.com'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Gender and Date of Birth
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'GENDER',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: primaryGold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<String>(
                                        value: _selectedGender,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                            fontSize: 14),
                                        dropdownColor: darkBrown,
                                        iconEnabledColor: primaryGold,
                                        onChanged: (value) {
                                          setState(() => _selectedGender = value);
                                        },
                                        items: const [
                                          DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                                          DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
                                          DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                                        ],
                                        decoration: _inputDecoration('Gender'),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'DATE OF BIRTH',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          color: primaryGold,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: _selectDate,
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.05),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                _selectedDob == null
                                                    ? 'YYYY-MM-DD'
                                                    : _formatDob(),
                                                style: TextStyle(
                                                  fontWeight: _selectedDob == null
                                                      ? FontWeight.normal
                                                      : FontWeight.w600,
                                                  color: _selectedDob == null
                                                      ? Colors.white.withValues(alpha: 0.2)
                                                      : Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.calendar_today_outlined,
                                                size: 18,
                                                color: primaryGold,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 36),
                            // Submit button
                            SizedBox(
                              width: double.infinity,
                              height: 64,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryGold,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20)),
                                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.black,
                                        ),
                                      )
                                    : const Text(
                                        'SAVE AND CONTINUE',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 2),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.2), fontWeight: FontWeight.normal, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryGold, width: 1.5),
      ),
    );
  }
}
