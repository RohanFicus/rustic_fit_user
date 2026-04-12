import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'main_container.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _resendTimer = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    print('OTP Screen initState called with phone: ${widget.phoneNumber}');
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
      // Move to next field when a digit is entered
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      }
    } else if (value.isEmpty && index > 0) {
      // Move to previous field when backspace is pressed
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Auto-verify when all 6 digits are entered
    if (_getOtpCode().length == 6) {
      _verifyOtp();
    }
  }

  String _getOtpCode() {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _verifyOtp() {
    final otpCode = _getOtpCode();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFD4AF37),
        ),
      ),
    );

    // Simulate OTP verification
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainContainer()),
        );
        // if (otpCode == '123456') {
        //   // Demo OTP
        //   Navigator.pushReplacement(
        //     context,
        //     MaterialPageRoute(builder: (context) => const MainContainer()),
        //   );
        // } else {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Invalid OTP. Please try again.'),
        //       backgroundColor: Colors.red,
        //     ),
        //   );
        //   // Clear all OTP fields
        //   for (var controller in _otpControllers) {
        //     controller.clear();
        //   }
        // }
      }
    });
  }

  void _resendOtp() {
    if (_canResend) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP resent successfully!'),
          backgroundColor: Color(0xFFD4AF37),
        ),
      );
      _timer?.cancel(); // Cancel existing timer
      _startResendTimer(); // Start new timer
      // Clear all OTP fields
      for (var controller in _otpControllers) {
        controller.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        width: 375,
        height: 812,
        color: const Color(0xFFF5E6D3), // Light beige background
        child: Stack(
          children: [
            // Ornate corner patterns
            Positioned(
              top: 20,
              left: 20,
              child: _buildOrnatePattern(),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: _buildOrnatePattern(),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildOrnatePattern(),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: _buildOrnatePattern(),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Logo/Emblem
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFFD4AF37), width: 3),
                        ),
                        child: const Center(
                          child: Text(
                            'R',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              fontFamily: 'Georgia',
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Title
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone number info
                    Text(
                      'Sent to ${widget.phoneNumber}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 45,
                          height: 55,
                          child: TextField(
                            controller: _otpControllers[index],
                            focusNode: _focusNodes[index],
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD4AF37),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFD4AF37),
                                  width: 3,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                            onChanged: (value) {
                              _onOtpChanged(value, index);
                            },
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 40),

                    // Verify OTP Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37), // Gold color
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _verifyOtp,
                          child: const Center(
                            child: Text(
                              'VERIFY OTP',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFF5E6D3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Resend OTP Section
                    Center(
                      child: Column(
                        children: [
                          if (!_canResend)
                            Text(
                              'Resend OTP in $_resendTimer seconds',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _resendOtp,
                              child: const Text(
                                'Resend OTP',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          const Text(
                            'Didn\'t receive the code? Check your WhatsApp',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrnatePattern() {
    return CustomPaint(
      size: const Size(60, 60),
      painter: OrnatePatternPainter(),
    );
  }
}

class OrnatePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4AF37)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Create ornate corner pattern
    path.moveTo(0, 20);
    path.quadraticBezierTo(10, 10, 20, 0);

    path.moveTo(10, 0);
    path.quadraticBezierTo(5, 5, 0, 10);

    path.moveTo(0, 30);
    path.quadraticBezierTo(15, 15, 30, 0);

    // Add decorative circles
    canvas.drawCircle(const Offset(10, 10), 3, paint);
    canvas.drawCircle(const Offset(20, 20), 2, paint);
    canvas.drawCircle(const Offset(15, 30), 2.5, paint);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
