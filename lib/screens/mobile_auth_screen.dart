import 'dart:convert';
import 'dart:ui';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;

import 'otp_screen.dart';

class MobileAuthScreen extends StatefulWidget {
  const MobileAuthScreen({super.key});

  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color darkBrown = Color(0xFF131517);

  Country _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'India',
    example: 'India',
    displayName: 'India',
    displayNameNoCountryCode: 'IN',
    e164Key: '',
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _requestOtp() async {
    final mobile = _phoneController.text.trim();
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Show loading spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: primaryGold,
        ),
      ),
    );

    try {
      final countryCode = '+${_selectedCountry.phoneCode}';
      final url = Uri.parse(
          'https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/auth/otp/request');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'mobile': mobile,
          'countryCode': countryCode,
        }),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss spinner

      if (response.statusCode == 200 || response.statusCode == 201) {
        String? requestId;
        String? apiMessage;
        bool status = false;
        try {
          final decoded = jsonDecode(response.body);
          if (decoded is Map<String, dynamic>) {
            status = decoded['status'] == true;
            apiMessage = decoded['message']?.toString();
            if (decoded['data'] is Map &&
                decoded['data'].containsKey('requestId')) {
              requestId = decoded['data']['requestId']?.toString();
            }
          }
        } catch (e) {
          print('Error parsing response: $e');
        }

        if (status && requestId != null) {
          final phoneNumber = '$countryCode $mobile';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                phoneNumber: phoneNumber,
                requestId: requestId,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(apiMessage ?? 'Failed to request OTP'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to request OTP: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss spinner
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting OTP: $e'),
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
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
                    maxWidth: isWide ? 1000 : 450,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: isWide
                            ? Row(
                                children: [
                                  Expanded(child: _buildDecorativeSide()),
                                  Expanded(child: _buildFormSide()),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildDecorativeSide(height: 300),
                                  _buildFormSide(),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDecorativeSide({double? height}) {
    final isMobile = height != null;
    return Container(
      height: height ?? 650,
      padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : 48, vertical: isMobile ? 20 : 48),
      decoration: BoxDecoration(
        color: primaryGold.withValues(alpha: 0.1),
        border: Border(
          right: !isMobile
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
          bottom: isMobile
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: primaryGold.withValues(alpha: 0.3)),
            ),
            child: Image.asset(
              'assets/images/logo.png',
              height: isMobile ? 45 : 120,
            ),
          ),
          SizedBox(height: isMobile ? 20 : 32),
          const Text(
            'RUSTIC FIT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 8,
            ),
          ),
          SizedBox(height: isMobile ? 6 : 12),
          Text(
            'BESPOKE TAILORING STUDIO',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryGold.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          if (!isMobile) ...[
            const Spacer(),
            Text(
              'Experience the luxury of perfectly fitted clothes, crafted just for you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFormSide() {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Padding(
      padding: EdgeInsets.all(isWide ? 40 : 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue your bespoke journey',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'MOBILE NUMBER',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: primaryGold.withValues(alpha: 0.8),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                onTap: () {
                  showCountryPicker(
                    context: context,
                    showPhoneCode: true,
                    countryListTheme: CountryListThemeData(
                      backgroundColor: darkBrown,
                      textStyle: const TextStyle(color: Colors.white),
                      searchTextStyle: const TextStyle(color: Colors.white),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    onSelect: (Country country) {
                      setState(() => _selectedCountry = country);
                    },
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Text(_selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      Text(
                        '+${_selectedCountry.phoneCode}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded,
                          size: 20, color: primaryGold),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Phone number',
                    hintStyle:
                        TextStyle(color: Colors.white.withValues(alpha: 0.2)),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: primaryGold, width: 1.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _requestOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'GET OTP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                  child: Divider(color: Colors.white.withValues(alpha: 0.1))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR SIGN IN WITH',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(
                  child: Divider(color: Colors.white.withValues(alpha: 0.1))),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildSocialButton(
                  icon: FontAwesomeIcons.google,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSocialButton(
                  icon: FontAwesomeIcons.apple,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white.withValues(alpha: 0.02),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }
}
