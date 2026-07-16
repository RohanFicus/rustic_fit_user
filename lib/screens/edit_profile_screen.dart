import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/dummy_data.dart';
import '../services/data_service.dart';
import '../services/supabase_service.dart';

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
    _dobController = TextEditingController(text: user.dob);
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
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        DummyData.currentUser.avatar = image.path;
      });

      // Upload to Supabase Storage and sync to DB
      try {
        final userId = DummyData.currentUser.id;
        final publicUrl = await SupabaseService.uploadAvatar(image.path, userId);
        if (publicUrl != null) {
          setState(() {
            DummyData.currentUser.avatar = publicUrl;
          });
          await SupabaseService.updateCustomerProfile(DummyData.currentUser);
        }
      } catch (e) {
        print('Failed to sync picked profile image: $e');
      }
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
                _buildProfileField(
                  label: "Date of Birth",
                  hint: "DD/MM/YYYY",
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
              backgroundImage: DummyData.currentUser.avatar.startsWith('http')
                  ? NetworkImage(DummyData.currentUser.avatar)
                  : FileImage(File(DummyData.currentUser.avatar))
                      as ImageProvider,
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

  Widget _buildUpdateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          final newFirstName = _firstNameController.text.trim();
          final newLastName = _lastNameController.text.trim();
          final newEmail = _emailController.text.trim();
          final newDob = _dobController.text.trim();

          setState(() {
            DataService().updateUserData(
              name: newFirstName,
              lastName: newLastName,
              email: newEmail,
              dob: newDob,
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
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGold,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 10,
          shadowColor: primaryGold.withValues(alpha: 0.3),
        ),
        child: const Text(
          "Save Changes",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
      ),
    );
  }
}
