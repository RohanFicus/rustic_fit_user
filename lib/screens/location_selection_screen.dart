import 'package:flutter/material.dart';

import '../models/dummy_data.dart';

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
  List<String> _filteredLocations = DummyData.locations;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _filteredLocations = DummyData.locations
          .where((location) => location
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
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
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Detecting your location...'),
                      backgroundColor: darkBrown,
                    ),
                  );
                },
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
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(height: 32),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Text(
                  'POPULAR CITIES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: primaryGold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = _filteredLocations[index];
                    final isSelected = location == widget.currentLocation;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListTile(
                        onTap: () => Navigator.pop(context, location),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        leading: Icon(Icons.location_on_rounded,
                            size: 20,
                            color: isSelected ? primaryGold : Colors.grey[300]),
                        title: Text(
                          location,
                          style: TextStyle(
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? primaryGold : darkBrown,
                            fontSize: 15,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: primaryGold, size: 20)
                            : Icon(Icons.chevron_right_rounded,
                                color: Colors.grey[300], size: 20),
                        tileColor: isSelected
                            ? primaryGold.withValues(alpha: 0.05)
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
