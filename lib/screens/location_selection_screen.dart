import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;

class LocationSelectionScreen extends StatefulWidget {
  final String currentLocation;

  const LocationSelectionScreen({
    super.key,
    required this.currentLocation,
  });

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDetecting = false;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isDetecting = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied.';
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied, we cannot request permissions.';
      } 

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final lat = position.latitude;
      final lon = position.longitude;
      String locationStr = '';

      // Try using Nominatim API first, especially for Web compatibility
      try {
        final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
        final response = await http.get(
          url,
          headers: {
            'Accept': 'application/json',
            'User-Agent': 'RusticFitApp/1.0',
          },
        ).timeout(const Duration(seconds: 5));
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['address'] != null) {
            final address = data['address'];
            final city = address['city'] ?? address['town'] ?? address['village'] ?? address['suburb'] ?? address['county'] ?? '';
            final state = address['state'] ?? '';
            
            if (city.isNotEmpty && state.isNotEmpty) {
              locationStr = "$city, $state";
            } else if (city.isNotEmpty) {
              locationStr = city;
            } else if (state.isNotEmpty) {
              locationStr = state;
            } else {
              locationStr = address['country'] ?? '';
            }
          }
        }
      } catch (e) {
        print('Nominatim reverse geocoding failed: $e');
      }

      // Fallback to native geocoding plugin (only works on Android/iOS)
      if (locationStr.isEmpty) {
        try {
          final placemarks = await placemarkFromCoordinates(lat, lon);
          if (placemarks.isNotEmpty) {
            final placemark = placemarks.first;
            final city = placemark.locality ?? placemark.subAdministrativeArea ?? '';
            final state = placemark.administrativeArea ?? '';
            
            if (city.isNotEmpty && state.isNotEmpty) {
              locationStr = "$city, $state";
            } else if (city.isNotEmpty) {
              locationStr = city;
            } else if (state.isNotEmpty) {
              locationStr = state;
            } else {
              locationStr = placemark.country ?? 'Unknown Location';
            }
          }
        } catch (e) {
          print('Native geocoding failed: $e');
        }
      }

      if (locationStr.isNotEmpty) {
        if (mounted) {
          Navigator.pop(context, locationStr);
        }
      } else {
        throw 'Could not determine city and state name from GPS coordinates.';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting location: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDetecting = false);
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
          icon: const Icon(Icons.close_rounded, color: darkBrown, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Location',
          style: TextStyle(
              color: darkBrown, fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: isWide ? 600 : double.infinity),
          padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Where should we send our tailor?",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: darkBrown,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Our premium home measurement service is available in select cities.",
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      controller: _searchController,
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          Navigator.pop(context, val.trim());
                        }
                      },
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, color: darkBrown),
                      decoration: InputDecoration(
                        hintText: 'Search for your city...',
                        hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: primaryGold),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              const BorderSide(color: primaryGold, width: 2),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: _isDetecting ? null : _getCurrentLocation,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: primaryGold, size: 20),
                ),
                title: const Text(
                  'Use current location',
                  style: TextStyle(
                      color: darkBrown,
                      fontWeight: FontWeight.w800,
                      fontSize: 16),
                ),
                subtitle: Text('Detection via GPS',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                trailing: _isDetecting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryGold),
                        ),
                      )
                    : const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
