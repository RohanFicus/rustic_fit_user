import 'dart:convert';
import 'dart:io';

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
            colorScheme: const ColorScheme.light(
              primary: primaryGold,
              onPrimary: Colors.white,
              onSurface: darkBrown,
            ),
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
          final customer = responseData['data'];

          // Map customer data into DummyData.currentUser
          DummyData.currentUser = User(
            id: customer['id']?.toString() ?? '1',
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? 40 : 16),
          child: Container(
            width: isWide ? 600 : double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
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
                      fontWeight: FontWeight.w800,
                      color: darkBrown,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your customer details to access premium tailoring services',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
                              color: Colors.white,
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
                              'First Name',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4A443F)),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _firstNameController,
                              style: const TextStyle(fontWeight: FontWeight.w600),
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
                              'Last Name',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4A443F)),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _lastNameController,
                              style: const TextStyle(fontWeight: FontWeight.w600),
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
                        'Email Address',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4A443F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                              'Gender',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A443F),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: darkBrown,
                                  fontSize: 14),
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
                              'Date of Birth',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF4A443F)),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectDate,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: greyBorder),
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
                                            ? Colors.grey[400]
                                            : darkBrown,
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
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGold,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryGold.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save and Continue',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: Colors.grey[400], fontWeight: FontWeight.normal, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: greyBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: greyBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryGold, width: 1.5),
      ),
    );
  }
}
