import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'otp_screen.dart';

class MobileAuthScreen extends StatefulWidget {
  const MobileAuthScreen({super.key});

  @override
  State<MobileAuthScreen> createState() => _MobileAuthScreenState();
}

class _MobileAuthScreenState extends State<MobileAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
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
  void initState() {
    super.initState();
    _phoneController.text = '98765 43210';
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 18,
                        offset: Offset(0, 10),
                        color: Color(0x14000000),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(0),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Welcome back',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sign in with your mobile number',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: true,
                        onSelect: (Country country) {
                          setState(() => _selectedCountry = country);
                        },
                      );
                    },
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: colorScheme.outlineVariant),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Text(
                              _selectedCountry.flagEmoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+${_selectedCountry.phoneCode}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Phone number',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    final phoneNumber =
                        '+${_selectedCountry.phoneCode} ${_phoneController.text}';
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            OtpScreen(phoneNumber: phoneNumber),
                      ),
                    );
                  },
                  icon: const Icon(FontAwesomeIcons.whatsapp, size: 18),
                  label: const Text('Get OTP'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'We’ll send a 6-digit OTP to verify your number.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              Text(
                'By continuing, you agree to our Terms and Privacy Policy.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
