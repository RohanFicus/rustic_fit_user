import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2.8)),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter OTP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sent to ${widget.phoneNumber}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return Container(
                    width: 50,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface,
                          ),
                      decoration: InputDecoration(
                        counterText: '',
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 14),
                        filled: false,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _getOtpCode().length == 6 ? _verifyOtp : null,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verify',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Column(
                  children: [
                    if (!_canResend)
                      Text(
                        'Resend in $_resendTimer s',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      )
                    else
                      TextButton(
                        onPressed: _resendOtp,
                        child: const Text('Resend OTP'),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      'Didn’t receive the code? Check WhatsApp.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
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
    );
  }
}
