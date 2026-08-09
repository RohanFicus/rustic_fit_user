import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_data.dart';
import '../services/api_service.dart';
import 'main_container.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? requestId;

  const OtpScreen({super.key, required this.phoneNumber, this.requestId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimer = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _resendTimer--;
        });

        if (_resendTimer <= 0) {
          timer.cancel();
          setState(() {
            _canResend = true;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && value.length == 1) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      }
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    if (_getOtpCode().length == 6) {
      _verifyOtp();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() async {
    final otp = _getOtpCode();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a 6-digit OTP'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: Color(0xFFC9A227),
        ),
      ),
    );

    try {
      // Check for bypass code or missing requestId to run offline mock session
      if (otp == '123456' || widget.requestId == null) {
        await ApiService.saveSession(widget.phoneNumber);
        DummyData.currentUser.phone = widget.phoneNumber;

        if (!mounted) return;
        Navigator.of(context).pop(); // Dismiss spinner
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainContainer()),
        );
        return;
      }

      // Otherwise, hit the real OTP verify API
      final url = Uri.parse(
          'https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/auth/otp/verify');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'requestId': widget.requestId,
          'otp': otp,
        }),
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Dismiss spinner

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          final tokenMeta = responseData['meta']?['token'];
          final accessToken = tokenMeta?['accessToken']?.toString();

          // Set default user data from verification response as fallback
          DummyData.currentUser = User(
            id: userData['id']?.toString() ?? '1',
            name:
                userData['email']?.toString().split('@').first ?? 'Super Admin',
            lastName: '',
            dob: '15/05/1995',
            email: userData['email'] ?? 'superadmin@rusticfit.com',
            phone:
                '${userData['countryCode'] ?? ''} ${userData['mobile'] ?? ''}'
                    .trim(),
            avatar: 'https://picsum.photos/seed/${userData['id']}/200/200.jpg',
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
                "holder": userData['email']?.toString().split('@').first ??
                    'Super Admin'
              }
            ],
          );

          bool profileSet = false;

          // Hit the profile API to fetch full customer profile details
          try {
            final profileUrl = Uri.parse(
                'https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile');
            final profileResponse = await http.get(
              profileUrl,
              headers: {
                'Content-Type': 'application/json',
                if (accessToken != null) 'Authorization': 'Bearer $accessToken',
                'ngrok-skip-browser-warning': 'true',
              },
            );

            if (profileResponse.statusCode == 200 ||
                profileResponse.statusCode == 201) {
              final profileData = jsonDecode(profileResponse.body);
              if (profileData['status'] == true && profileData['data'] != null) {
                final rawData = profileData['data'];
                final customer = (rawData is Map && rawData.containsKey('customer'))
                    ? rawData['customer']
                    : rawData;

                if (customer != null &&
                    customer['firstName'] != null &&
                    customer['firstName'].toString().trim().isNotEmpty) {
                  profileSet = true;

                  // Map the profile details to DummyData.currentUser
                  DummyData.currentUser = User(
                    id: customer['id']?.toString() ?? DummyData.currentUser.id,
                    name: customer['firstName'] ?? 'Customer',
                    lastName: customer['lastName'] ?? '',
                    dob: customer['dateOfBirth'] ?? '15/05/1995',
                    email: customer['email'] ?? 'customer@rusticfit.com',
                    phone:
                        '${customer['countryCode'] ?? ''} ${customer['mobile'] ?? ''}'
                            .trim(),
                    avatar: (customer['profileImage'] != null &&
                            customer['profileImage'].toString().isNotEmpty)
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
                }
              }
            }
          } catch (e) {
            print('Error fetching customer profile: $e');
          }

          if (profileSet) {
            await ApiService.saveSession(
                DummyData.currentUser.phone, accessToken);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainContainer()),
            );
          } else {
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSetupScreen(
                  accessToken: accessToken ?? '',
                  phoneNumber: DummyData.currentUser.phone,
                ),
              ),
            );
          }
        } else {
          final message = responseData['message'] ?? 'Failed to verify OTP';
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
            content: Text(
                'Verification failed: ${response.statusCode} - ${response.body}'),
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
            content: Text('Error verifying OTP: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _resendOtp() {
    if (_canResend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully!'),
          backgroundColor: Color(0xFFC9A227),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _timer?.cancel();
      _startResendTimer();
      for (var controller in _otpControllers) {
        controller.clear();
      }
      FocusScope.of(context).requestFocus(_focusNodes[0]);
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
                                _buildDecorativeSide(height: 250),
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
    );
  }

  Widget _buildDecorativeSide({double? height}) {
    return Container(
      height: height ?? 650,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: primaryGold.withValues(alpha: 0.1),
        border: Border(
          right: height == null
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
          bottom: height != null
              ? BorderSide(color: Colors.white.withValues(alpha: 0.1))
              : BorderSide.none,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: primaryGold.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.shield_outlined,
              size: height != null ? 60 : 120,
              color: primaryGold,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'SECURE YOUR ACCOUNT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'We have sent a 6-digit verification code to your WhatsApp.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryGold.withValues(alpha: 0.7),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          if (height == null) ...[
            const Spacer(),
            Text(
              'Your safety and data privacy is our priority.',
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
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: primaryGold,
          ),
          const SizedBox(height: 32),
          const Text(
            'Verification',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Code sent to ${widget.phoneNumber}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 44,
                height: 56,
                child: TextField(
                  controller: _otpControllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(1),
                  ],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide:
                          const BorderSide(color: primaryGold, width: 1.5),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) => _onOtpChanged(value, index),
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: _getOtpCode().length == 6 ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                disabledForegroundColor: Colors.white.withValues(alpha: 0.2),
              ),
              child: const Text(
                'VERIFY & PROCEED',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                if (!_canResend)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Resend code in ',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${_resendTimer}s',
                        style: const TextStyle(
                          color: primaryGold,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                else
                  TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                        color: primaryGold,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
