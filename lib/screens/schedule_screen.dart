import 'package:flutter/material.dart';
import 'package:rustic_fit/models/dummy_data.dart';
import 'package:rustic_fit/screens/product_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedCategory = "Women";
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> _categories = [
    {"name": "Women", "icon": Icons.woman_rounded},
    {"name": "Men", "icon": Icons.man_rounded},
    {"name": "Kids", "icon": Icons.child_care_rounded},
    {"name": "Bids", "icon": Icons.gavel_rounded},
    {"name": "Best Design", "icon": Icons.auto_awesome_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProducts(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = DummyData.products.where((product) {
        final matchesCategory =
            product.category.toLowerCase() == _selectedCategory.toLowerCase();
        final matchesSearch =
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                product.description
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F2), // Light Cream background
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(colorScheme),
              const SizedBox(height: 24),
              _buildSectionHeader("Browse Categories"),
              const SizedBox(height: 16),
              _buildCategoryList(colorScheme),
              const SizedBox(height: 24),
              _buildSectionHeader("Top Collections"),
              const SizedBox(height: 16),
              _buildMasonryGrid(colorScheme),
              const SizedBox(height: 100), // Space for navigation
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: const Color(0xFF2D2926).withOpacity(0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D2926)),
              decoration: InputDecoration(
                hintText: "Search in $_selectedCategory...",
                hintStyle: TextStyle(
                  color: const Color(0xFF2D2926).withOpacity(0.3),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(Icons.search_rounded,
                    color: Color(0xFFC9A227), size: 20),
                prefixIconConstraints: const BoxConstraints(minWidth: 32),
                suffixIcon: _searchQuery.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = "";
                          });
                          _applyFilters();
                        },
                        child: Icon(Icons.cancel,
                            color: const Color(0xFF2D2926).withOpacity(0.3),
                            size: 18),
                      )
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF2D2926),
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildCategoryList(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _filterProducts(cat['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFC9A227) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFC9A227)
                            : const Color(0xFF2D2926).withOpacity(0.05),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFFC9A227).withOpacity(0.2)
                              : Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      cat['icon'],
                      color:
                          isSelected ? Colors.white : const Color(0xFF2D2926),
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['name'],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF2D2926)
                        : const Color(0xFF2D2926).withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMasonryGrid(ColorScheme colorScheme) {
    if (_filteredProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Column(
            children: [
              Icon(Icons.style_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "No items in $_selectedCategory",
                style: TextStyle(
                    color: Colors.grey[600], fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    // Split products into two columns for masonry effect
    List<Product> leftCol = [];
    List<Product> rightCol = [];
    for (int i = 0; i < _filteredProducts.length; i++) {
      if (i % 2 == 0) {
        leftCol.add(_filteredProducts[i]);
      } else {
        rightCol.add(_filteredProducts[i]);
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftCol.map((product) {
              // Alternate heights for masonry look
              double height = (leftCol.indexOf(product) % 2 == 0) ? 220 : 280;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildStyleCard(product, height, colorScheme),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: rightCol.map((product) {
              // Inverse alternate heights
              double height = (rightCol.indexOf(product) % 2 == 0) ? 280 : 220;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildStyleCard(product, height, colorScheme),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStyleCard(
      Product product, double height, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(product.image),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12,
              bottom: 12,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          DummyData.formatPrice(product.price),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC9A227).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.star, color: Colors.white, size: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
