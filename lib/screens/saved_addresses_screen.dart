import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_data.dart';
import '../services/api_service.dart';
import '../services/data_service.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    try {
      final token = ApiService.accessToken;
      final url = Uri.parse(
          'https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile/addresses');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] is List) {
          final list = responseData['data'] as List;
          final List<String> loaded = [];
          for (var item in list) {
            final line1 = item['addressLine1'] ?? '';
            final line2 = item['addressLine2'] ?? '';
            final city = item['city'] ?? '';
            final state = item['state'] ?? '';
            final pincode = item['pincode'] ?? '';

            final fullAddress =
                "$line1${line2.isNotEmpty ? ', ' + line2 : ''}, $city, $state $pincode";
            loaded.add(fullAddress);
          }
          setState(() {
            DummyData.currentUser.savedAddresses = loaded;
          });
        }
      }
    } catch (e) {
      print('Error fetching saved addresses: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteAddress(int index) {
    setState(() {
      final address = DummyData.currentUser.savedAddresses[index];
      DataService().removeSavedAddress(address);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Address removed from profile'),
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _addNewAddress(bool isWide) {
    if (isWide) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: const AddAddressForm(isDialog: true),
          ),
        ),
      ).then((value) {
        if (value != null && value is String) {
          setState(() {
            DataService().addSavedAddress(value);
          });
        }
      });
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AddAddressForm(isDialog: false),
      ).then((value) {
        if (value != null && value is String) {
          setState(() {
            DataService().addSavedAddress(value);
          });
        }
      });
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
          "My Saved Locations",
          style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryGold,
              ),
            )
          : DummyData.currentUser.savedAddresses.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(isWide ? 48 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("Primary Addresses"),
                          if (isWide)
                            ElevatedButton.icon(
                              onPressed: () => _addNewAddress(true),
                              icon: const Icon(Icons.add_rounded, size: 20),
                              label: const Text("Add New Address"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkBrown,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 20),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      isWide ? _buildWideGrid() : _buildMobileList(),
                    ],
                  ),
                ),
      floatingActionButton: isWide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addNewAddress(false),
              backgroundColor: darkBrown,
              icon: const Icon(Icons.add_rounded, color: primaryGold),
              label: const Text(
                "New Address",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: darkBrown,
          letterSpacing: -0.5),
    );
  }

  Widget _buildWideGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        mainAxisExtent: 200,
      ),
      itemCount: DummyData.currentUser.savedAddresses.length,
      itemBuilder: (context, index) => _buildAddressCard(index, true),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: DummyData.currentUser.savedAddresses.length,
      itemBuilder: (context, index) => _buildAddressCard(index, false),
    );
  }

  Widget _buildAddressCard(int index, bool isWide) {
    return Container(
      margin: EdgeInsets.only(bottom: isWide ? 0 : 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_on_rounded,
                    color: primaryGold, size: 20),
              ),
              IconButton(
                onPressed: () => _deleteAddress(index),
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                  padding: const EdgeInsets.all(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "OFFICE / HOME",
            style: TextStyle(
                color: Colors.grey[400],
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              DummyData.currentUser.savedAddresses[index],
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: darkBrown,
                  fontSize: 14,
                  height: 1.5),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
                color: darkBrown.withValues(alpha: 0.05),
                shape: BoxShape.circle),
            child: Icon(Icons.location_off_rounded,
                size: 64, color: darkBrown.withValues(alpha: 0.1)),
          ),
          const SizedBox(height: 32),
          const Text("No Saved Addresses",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: darkBrown)),
          const SizedBox(height: 12),
          Text("Add your shipping destinations for a faster bespoke checkout.",
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () =>
                _addNewAddress(MediaQuery.of(context).size.width > 900),
            icon: const Icon(Icons.add_rounded),
            label: const Text("Create New Address"),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkBrown,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class AddAddressForm extends StatefulWidget {
  final bool isDialog;
  const AddAddressForm({super.key, required this.isDialog});

  @override
  State<AddAddressForm> createState() => _AddAddressFormState();
}

class _AddAddressFormState extends State<AddAddressForm> {
  String selectedType = 'Home';
  final _addressController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _zipController = TextEditingController();
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color darkBrown = Color(0xFF131517);

  String? selectedState;
  String? selectedCity;
  List<String> states = [];
  List<String> cities = [];
  bool isLoadingStates = false;
  bool isLoadingCities = false;
  bool isLocating = false;
  bool _isSaving = false;

  void _saveAddress() async {
    if (_addressController.text.isEmpty ||
        selectedState == null ||
        selectedCity == null ||
        _zipController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final token = ApiService.accessToken;
      final customerId = DummyData.currentUser.id;

      final url = Uri.parse(
          'https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile/address');

      final payload = {
        "customerId": customerId,
        "addressType": selectedType.toUpperCase(),
        "addressLine1": _addressController.text.trim(),
        "addressLine2": _apartmentController.text.trim(),
        "landmark": "",
        "city": selectedCity,
        "state": selectedState,
        "pincode": _zipController.text.trim(),
        "latitude": 28.408912,
        "longitude": 77.317789,
        "isDefault": DummyData.currentUser.savedAddresses.isEmpty,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(payload),
      );

      if (mounted) {
        setState(() => _isSaving = false);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true) {
          final fullAddress =
              "${_addressController.text}${_apartmentController.text.isNotEmpty ? ', ' + _apartmentController.text : ''}, $selectedCity, $selectedState ${_zipController.text}";

          Navigator.pop(context, fullAddress);
        } else {
          final message = responseData['message'] ?? 'Failed to save address';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save address: ${response.statusCode}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _fetchStates() async {
    setState(() => isLoadingStates = true);
    try {
      final response = await http.post(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/states'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'country': 'India'}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> statesData = data['data']['states'];
        setState(() {
          states = statesData.map((e) => e['name'] as String).toList();
          isLoadingStates = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingStates = false);
    }
  }

  Future<void> _fetchCities(String stateName) async {
    setState(() {
      isLoadingCities = true;
      cities = [];
      selectedCity = null;
    });
    try {
      final response = await http.post(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/state/cities'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'country': 'India', 'state': stateName}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> citiesData = data['data'];
        setState(() {
          cities = citiesData.map((e) => e as String).toList();
          isLoadingCities = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingCities = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(widget.isDialog ? 32 : 0),
        boxShadow: widget.isDialog
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                )
              ]
            : null,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Add New Destination",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: darkBrown)),
            const SizedBox(height: 8),
            Text("Provide your full delivery details for our logistics team.",
                style: TextStyle(color: Colors.grey[500], fontSize: 13)),
            const SizedBox(height: 32),
            _buildLabel("Address Detail"),
            _buildTextField(_addressController, "Street Address, Landmark"),
            const SizedBox(height: 12),
            _buildTextField(
                _apartmentController, "Apartment, Suite, Unit (Optional)"),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("State"),
                      _buildDropdown(
                        value: selectedState,
                        hint: "State",
                        items: states,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedState = val);
                            _fetchCities(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("City"),
                      _buildDropdown(
                        value: selectedCity,
                        hint: "City",
                        items: cities,
                        onChanged: (val) => setState(() => selectedCity = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel("Postal Code"),
            _buildTextField(_zipController, "ZIP / PIN Code",
                keyboardType: TextInputType.number),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20)),
                    child: const Text("Cancel",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text("Save Address",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: darkBrown,
              letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.w500),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFE9ECEF))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryGold, width: 2)),
      ),
    );
  }

  Widget _buildDropdown(
      {required String? value,
      required String hint,
      required List<String> items,
      required Function(String?) onChanged}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          isExpanded: true,
          items: items
              .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
