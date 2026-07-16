import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'mobile_auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  // Settings state
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _locationServices = true;
  String _selectedLanguage = 'English';
  String _selectedCurrency = 'INR (₹)';

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
        automaticallyImplyLeading: false,
        title: const Text(
          'Settings',
          style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 22),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: primaryGold, size: 24),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Notifications"),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSwitchItem(
                "Push Notifications",
                "Alerts for orders & updates",
                _pushNotifications,
                (v) => setState(() => _pushNotifications = v)),
            _buildSwitchItem(
                "Email Notifications",
                "Weekly style reports & bills",
                _emailNotifications,
                (v) => setState(() => _emailNotifications = v)),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader("Regional Preferences"),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSelectorItem(
                "Language", _selectedLanguage, Icons.translate_rounded),
            _buildSelectorItem(
                "Currency", _selectedCurrency, Icons.payments_rounded),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader("Privacy & Security"),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildSwitchItem(
                "Location Services",
                "Find tailors near you",
                _locationServices,
                (v) => setState(() => _locationServices = v)),
            _buildActionItem("Change Password", Icons.lock_outline_rounded),
            _buildActionItem("Two-Factor Auth", Icons.security_rounded),
          ]),
          const SizedBox(height: 32),
          _buildSectionHeader("Support"),
          const SizedBox(height: 16),
          _buildSettingsCard([
            _buildActionItem("Help Center", Icons.help_outline_rounded),
            _buildActionItem(
                "Contact Master Tailor", Icons.support_agent_rounded),
            _buildActionItem("Privacy Policy", Icons.description_outlined),
          ]),
          const SizedBox(height: 40),
          _buildLogoutButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildWideLayout() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Communication"),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildSwitchItem(
                      "Push Notifications",
                      "Alerts for orders & updates",
                      _pushNotifications,
                      (v) => setState(() => _pushNotifications = v)),
                  _buildSwitchItem(
                      "Email Notifications",
                      "Weekly style reports & bills",
                      _emailNotifications,
                      (v) => setState(() => _emailNotifications = v)),
                  _buildSwitchItem(
                      "Location Services",
                      "Find tailors near you",
                      _locationServices,
                      (v) => setState(() => _locationServices = v)),
                ]),
                const SizedBox(height: 32),
                _buildSectionHeader("Regional"),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildSelectorItem(
                      "Language", _selectedLanguage, Icons.translate_rounded),
                  _buildSelectorItem(
                      "Currency", _selectedCurrency, Icons.payments_rounded),
                ]),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Security"),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildActionItem(
                      "Change Password", Icons.lock_outline_rounded),
                  _buildActionItem(
                      "Two-Factor Authentication", Icons.security_rounded),
                  _buildActionItem("Session Management", Icons.devices_rounded),
                ]),
                const SizedBox(height: 32),
                _buildSectionHeader("RusticFit Support"),
                const SizedBox(height: 16),
                _buildSettingsCard([
                  _buildActionItem("Help Center", Icons.help_outline_rounded),
                  _buildActionItem(
                      "Contact Master Tailor", Icons.support_agent_rounded),
                  _buildActionItem(
                      "Terms of Service", Icons.description_outlined),
                  _buildActionItem(
                      "Privacy Policy", Icons.privacy_tip_outlined),
                ]),
                const SizedBox(height: 40),
                _buildLogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: primaryGold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: List.generate(children.length, (index) {
          if (index == children.length - 1) return children[index];
          return Column(
            children: [
              children[index],
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Divider(height: 1, color: Color(0xFFF1F3F5)),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSwitchItem(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15, color: darkBrown)),
      subtitle: Text(subtitle,
          style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: primaryGold,
        activeTrackColor: primaryGold.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildSelectorItem(String title, String value, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: primaryGold, size: 20),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15, color: darkBrown)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14)),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFFE9ECEF), size: 20),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildActionItem(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Icon(icon, color: darkBrown, size: 20),
      title: Text(title,
          style: const TextStyle(
              fontWeight: FontWeight.w800, fontSize: 15, color: darkBrown)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: Color(0xFFE9ECEF), size: 20),
      onTap: () {},
    );
  }

  void _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.clearSession();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MobileAuthScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _logout,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
        child: const Text(
          "Sign Out Account",
          style: TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.w900,
              fontSize: 15),
        ),
      ),
    );
  }
}
