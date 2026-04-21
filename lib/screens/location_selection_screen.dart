import 'package:flutter/material.dart';
import '../models/dummy_data.dart';

class LocationSelectionScreen extends StatefulWidget {
  final String currentLocation;

  const LocationSelectionScreen({
    super.key,
    required this.currentLocation,
  });

  @override
  State<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredLocations = DummyData.locations;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for your city...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colorScheme.surfaceVariant.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          ListTile(
            onTap: () {
              // Handle current location detection
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Detecting current location...')),
              );
            },
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Icon(Icons.my_location, color: colorScheme.primary, size: 20),
            ),
            title: Text(
              'Use current location',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text('Using GPS'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'POPULAR CITIES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredLocations.length,
              itemBuilder: (context, index) {
                final location = _filteredLocations[index];
                final isSelected = location == widget.currentLocation;

                return ListTile(
                  onTap: () => Navigator.pop(context, location),
                  leading: const Icon(Icons.location_city, size: 20),
                  title: Text(
                    location,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: colorScheme.primary)
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
