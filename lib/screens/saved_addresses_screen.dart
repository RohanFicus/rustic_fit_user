import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/dummy_data.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFF7F5F2);
  static const Color darkBrown = Color(0xFF2D2926);
  static const Color submitNavy = Color(0xFF1E3A8A);

  void _deleteAddress(int index) {
    setState(() {
      DummyData.currentUser.savedAddresses.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Address removed'),
        backgroundColor: darkBrown,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _addNewAddress() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAddressBottomSheet(),
    ).then((value) {
      if (value != null && value is String) {
        setState(() {
          DummyData.currentUser.savedAddresses.add(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: darkBrown),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Saved Addresses",
          style: TextStyle(color: darkBrown, fontWeight: FontWeight.bold),
        ),
      ),
      body: DummyData.currentUser.savedAddresses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: DummyData.currentUser.savedAddresses.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: darkBrown.withOpacity(0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryGold.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_outlined,
                            color: primaryGold, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Address ${index + 1}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkBrown,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DummyData.currentUser.savedAddresses[index],
                              style: TextStyle(
                                color: darkBrown.withOpacity(0.6),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 18),
                        onPressed: () => _deleteAddress(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewAddress,
        backgroundColor: darkBrown,
        icon: const Icon(Icons.add, color: primaryGold),
        label: const Text(
          "Add New Address",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 80,
            color: darkBrown.withOpacity(0.1),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Saved Addresses",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkBrown,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add a delivery address to get started.",
            style: TextStyle(
              color: darkBrown.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class AddAddressBottomSheet extends StatefulWidget {
  const AddAddressBottomSheet({super.key});

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  String selectedType = 'Home';
  final _addressController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _zipController = TextEditingController();
  static const Color primaryGold = Color(0xFFC9A227);
  String? selectedState;
  String? selectedCity;

  List<String> states = [];
  List<String> cities = [];
  bool isLoadingStates = false;
  bool isLoadingCities = false;
  bool isLocating = false;

  @override
  void initState() {
    super.initState();
    _fetchStates();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLocating = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied';
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _addressController.text =
              "${place.street ?? ''} ${place.subLocality ?? ''}".trim();
          _zipController.text = place.postalCode ?? '';

          // Try to match state
          if (place.administrativeArea != null) {
            final matchedState = states.firstWhere(
              (s) => s
                  .toLowerCase()
                  .contains(place.administrativeArea!.toLowerCase()),
              orElse: () => "",
            );
            if (matchedState.isNotEmpty) {
              selectedState = matchedState;
              _fetchCities(matchedState).then((_) {
                if (place.locality != null) {
                  final matchedCity = cities.firstWhere(
                    (c) =>
                        c.toLowerCase().contains(place.locality!.toLowerCase()),
                    orElse: () => "",
                  );
                  if (matchedCity.isNotEmpty) {
                    setState(() => selectedCity = matchedCity);
                  }
                }
              });
            }
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => isLocating = false);
    }
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
      debugPrint('Error fetching states: $e');
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
      debugPrint('Error fetching cities: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add New Address",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2926),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: isLocating ? null : _getCurrentLocation,
              icon: isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryGold,
                      ),
                    )
                  : const Icon(Icons.my_location, color: primaryGold, size: 20),
              label: Text(
                isLocating ? "Getting Location..." : "Use Current Location",
                style: const TextStyle(
                  color: primaryGold,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildTypeChip("Home", "🏠"),
                const SizedBox(width: 12),
                _buildTypeChip("Office", "🏢"),
                const SizedBox(width: 12),
                _buildTypeChip("PO Box", "📫"),
              ],
            ),
            const SizedBox(height: 24),
            _buildLabel("Address*"),
            _buildTextField(_addressController, "8572 Winding Creek Boule"),
            const SizedBox(height: 12),
            _buildTextField(_apartmentController, "Apartment, suite, etc",
                isRequired: false),
            const SizedBox(height: 20),
            _buildLabel("State*"),
            _buildDropdown(
              value: selectedState,
              hint: isLoadingStates ? "Loading states..." : "Select state",
              items: states,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedState = val);
                  _fetchCities(val);
                }
              },
            ),
            const SizedBox(height: 20),
            _buildLabel("City*"),
            _buildDropdown(
              value: selectedCity,
              hint: isLoadingCities ? "Loading cities..." : "Select city",
              items: cities,
              onChanged: (val) => setState(() => selectedCity = val),
            ),
            const SizedBox(height: 20),
            _buildLabel("ZIP Code*"),
            _buildTextField(_zipController, "Enter ZIP Code"),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_addressController.text.isNotEmpty &&
                          selectedState != null &&
                          selectedCity != null &&
                          _zipController.text.isNotEmpty) {
                        final fullAddress =
                            "${_addressController.text}${_apartmentController.text.isNotEmpty ? ', ' + _apartmentController.text : ''}, $selectedCity, $selectedState ${_zipController.text}";
                        Navigator.pop(context, fullAddress);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGold,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Submit",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, String emoji) {
    final isSelected = selectedType == label;
    return GestureDetector(
      onTap: () => setState(() => selectedType = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black87 : Colors.grey.shade600,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isRequired = true}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 1),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
