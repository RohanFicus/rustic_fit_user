import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_data.dart';
import '../services/data_service.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  final ImagePicker _picker = ImagePicker();
  
  String? _selectedGender = 'MALE';
  File? _newProfileImage;
  bool _isLoading = false;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    final user = DummyData.currentUser;

    _usernameController = TextEditingController(
        text: "${user.name}.${user.lastName}".toLowerCase());
    _firstNameController = TextEditingController(text: user.name);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);

    // Normalize DOB format to YYYY-MM-DD
    String dob = user.dob;
    if (dob.contains('/')) {
      final parts = dob.split('/');
      if (parts.length == 3) {
        dob = "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
      }
    }
    _dobController = TextEditingController(text: dob);
    
    _selectedGender = user.gender.toUpperCase();
    if (_selectedGender != 'MALE' && _selectedGender != 'FEMALE' && _selectedGender != 'OTHER') {
      _selectedGender = 'MALE';
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 5, 15),
      firstDate: DateTime(1950),
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
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _newProfileImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
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
          "Edit Profile",
          style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 40),
                _buildSectionHeader("Account Credentials"),
                const SizedBox(height: 20),
                _buildProfileField(
                  label: "Username",
                  hint: "@username",
                  controller: _usernameController,
                  icon: Icons.alternate_email_rounded,
                ),
                const SizedBox(height: 32),
                _buildSectionHeader("Personal Details"),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildProfileField(
                        label: "First Name",
                        hint: "First",
                        controller: _firstNameController,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildProfileField(
                        label: "Last Name",
                        hint: "Last",
                        controller: _lastNameController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: "Email Address",
                  hint: "email@example.com",
                  controller: _emailController,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Gender",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: darkBrown,
                          letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: darkBrown),
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                      },
                      items: const [
                        DropdownMenuItem(value: 'MALE', child: Text('MALE')),
                        DropdownMenuItem(value: 'FEMALE', child: Text('FEMALE')),
                        DropdownMenuItem(value: 'OTHER', child: Text('OTHER')),
                      ],
                      decoration: InputDecoration(
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
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProfileField(
                  label: "Date of Birth",
                  hint: "YYYY-MM-DD",
                  controller: _dobController,
                  icon: Icons.calendar_today_rounded,
                  readOnly: true,
                  onTap: _selectDate,
                ),
                const SizedBox(height: 48),
                _buildUpdateButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: primaryGold.withValues(alpha: 0.2), width: 2),
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFF1F3F5),
              backgroundImage: _newProfileImage != null
                  ? FileImage(_newProfileImage!)
                  : (DummyData.currentUser.avatar.startsWith('http')
                      ? NetworkImage(DummyData.currentUser.avatar)
                      : FileImage(File(DummyData.currentUser.avatar))
                          as ImageProvider),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: primaryGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: primaryGold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
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
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
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
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final dob = _dobController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(24),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = ApiService.accessToken;
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile');
      var request = http.MultipartRequest('PUT', url);
      
      request.headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });

      request.fields['firstName'] = firstName;
      request.fields['lastName'] = lastName;
      request.fields['email'] = email;
      request.fields['gender'] = _selectedGender ?? 'MALE';
      request.fields['dateOfBirth'] = dob;

      if (_newProfileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profileImage',
            _newProfileImage!.path,
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
          setState(() {
            DummyData.currentUser = User(
              id: customer['id']?.toString() ?? DummyData.currentUser.id,
              name: customer['firstName'] ?? firstName,
              lastName: customer['lastName'] ?? lastName,
              dob: dob,
              email: email,
              phone: '${customer['countryCode'] ?? ''} ${customer['mobile'] ?? ''}'.trim(),
              avatar: (customer['profileImage'] != null && customer['profileImage'].toString().isNotEmpty)
                  ? customer['profileImage'].toString()
                  : DummyData.currentUser.avatar,
              gender: customer['gender'] ?? _selectedGender ?? 'MALE',
              savedAddresses: DummyData.currentUser.savedAddresses,
              bodyMeasurements: DummyData.currentUser.bodyMeasurements,
              paymentMethods: DummyData.currentUser.paymentMethods,
            );
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: darkBrown,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(24),
            ),
          );
          Navigator.pop(context);
        } else {
          final message = responseData['message'] ?? 'Failed to update profile';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(24),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(24),
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
            margin: const EdgeInsets.all(24),
          ),
        );
      }
    }
  }

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: primaryGold.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                "Save Changes",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
      ),
    );
  }
}
