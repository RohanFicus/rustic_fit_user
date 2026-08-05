import 'package:flutter/material.dart';
import 'package:rustic_fit/models/dummy_data.dart';
import 'package:rustic_fit/screens/product_detail_screen.dart';

import '../services/api_service.dart';
import 'sub_categories_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedCategory = "All";
  List<Product> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.all_inclusive_rounded}
  ];
  List<SubCategory> _subCategories = [];
  SubCategory? _selectedSubCategory;
  bool _isLoadingSubCategories = false;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _getIconForCategory(String name) {
    switch (name) {
      case 'Ethnic Wear':
        return Icons.checkroom_rounded;
      case 'Western Wear':
        return Icons.dry_cleaning_rounded;
      case 'Fusion / Indo-Western':
        return Icons.style_rounded;
      case 'Bridal & Wedding':
        return Icons.celebration_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await ApiService.fetchCategories();
      if (cats.isNotEmpty && mounted) {
        setState(() {
          DummyData.categories = cats;
          _categories = [
            {"name": "All", "icon": Icons.all_inclusive_rounded},
            ...cats.map((c) => {
                  "name": c.name,
                  "icon": _getIconForCategory(c.name),
                })
          ];
        });
      }
    } catch (e) {
      print('Error fetching categories in ScheduleScreen: $e');
    }
  }

  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
    });
    try {
      final subCats = await ApiService.fetchSubCategories(categoryId);
      if (mounted) {
        setState(() {
          _subCategories = subCats;
        });
      }
    } catch (e) {
      print('Error loading subcategories in ScheduleScreen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubCategories = false);
      }
    }
    _applyFilters();
  }

  Future<void> _loadProductsBySubCategory(
      String subCategoryId, String categoryName) async {
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      final prods = await ApiService.fetchProductsBySubCategory(
          subCategoryId, categoryName);
      if (mounted) {
        setState(() {
          _filteredProducts = prods;
        });
      }
    } catch (e) {
      print('Error loading products in ScheduleScreen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
  }

  void _selectSubCategory(SubCategory? subCat) {
    if (_selectedSubCategory == subCat) return;
    setState(() {
      _selectedSubCategory = subCat;
    });

    if (subCat != null) {
      _loadProductsBySubCategory(subCat.id, subCat.categoryName);
    } else {
      _applyFilters();
    }
  }

  void _filterProducts(String category) {
    if (category == "All") {
      setState(() {
        _selectedCategory = "All";
        _selectedSubCategory = null;
        _subCategories = [];
      });
      _applyFilters();
    } else {
      final catObj = DummyData.categories.firstWhere(
        (c) => c.name.toLowerCase() == category.toLowerCase(),
        orElse: () =>
            Category(id: '', name: '', icon: '', image: '', productCount: 0),
      );
      if (catObj.id.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubCategoriesScreen(category: catObj),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = DummyData.products.where((product) {
        final matchesCategory = _selectedCategory == "All" ||
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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCFB),
      body: Column(
        children: [
          _buildHeader(isWide),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 40 : 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide) _buildWelcomeSection(),
                  _buildCategoryTabs(isWide),
                  const SizedBox(height: 32),
                  _buildStyleGrid(isWide),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Style Discovery Studio',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF131517),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Explore curated designs and find your next masterpiece.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF8E847C),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 40 : 20,
        vertical: 20,
      ),
      color: Colors.white,
      child: Row(
        children: [
          if (!isWide) ...[
            const Text(
              'Style Studio',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF131517),
              ),
            ),
            const Spacer(),
          ],
          Expanded(
            flex: isWide ? 0 : 1,
            child: _buildSearchBar(isWide),
          ),
          if (isWide) ...[
            const Spacer(),
            _buildIconButton(Icons.tune_rounded),
            const SizedBox(width: 12),
            _buildIconButton(Icons.notifications_none_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isWide) {
    return Container(
      width: isWide ? 400 : double.infinity,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) {
          setState(() => _searchQuery = v);
          _applyFilters();
        },
        decoration: InputDecoration(
          hintText: 'Search styles, fabrics, designs...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: Color(0xFFC9A227)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, size: 20, color: const Color(0xFF2D2926)),
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categories',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF131517),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isSelected = _selectedCategory == cat['name'];
              return GestureDetector(
                onTap: () => _filterProducts(cat['name']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 20),
                  width: 100,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFC9A227) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC9A227)
                          : const Color(0xFFE9ECEF),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFFC9A227).withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        cat['icon'],
                        color:
                            isSelected ? Colors.white : const Color(0xFFC9A227),
                        size: 28,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['name'].split(' ')[0],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF4A443F),
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedCategory != "All" &&
            (_isLoadingSubCategories || _subCategories.isNotEmpty)) ...[
          const SizedBox(height: 24),
          const Text(
            'Sub-categories',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4A443F),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: isWide ? 42 : 32,
            child: _isLoadingSubCategories
                ? const Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFFC9A227),
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _subCategories.length,
                    itemBuilder: (context, index) {
                      final subCat = _subCategories[index];
                      final isSelected = _selectedSubCategory?.id == subCat.id;
                      final label = subCat.name;

                      return GestureDetector(
                        onTap: () => _selectSubCategory(subCat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 12),
                          padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 20 : 12,
                              vertical: isWide ? 10 : 5),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF131517)
                                : Colors.white,
                            borderRadius:
                                BorderRadius.circular(isWide ? 12 : 8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF131517)
                                  : const Color(0xFFE9ECEF),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF4A443F),
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                fontSize: isWide ? 12 : 10,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ]
      ],
    );
  }

  Widget _buildStyleGrid(bool isWide) {
    if (_isLoadingProducts) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 80),
          child: CircularProgressIndicator(
            color: Color(0xFFC9A227),
          ),
        ),
      );
    }

    if (_filteredProducts.isEmpty) {
      final msg = _selectedCategory == "All"
          ? "No styles found in All"
          : _selectedSubCategory == null
              ? "Select a sub-category style to discover outfits"
              : "No styles found in this sub-category";

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(
            children: [
              Icon(Icons.style_outlined, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 24),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF8E847C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$_selectedCategory Collections",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFF131517),
              ),
            ),
            Text(
              '${_filteredProducts.length} items',
              style: TextStyle(
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredProducts.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 4 : 2,
            childAspectRatio: 0.7,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
          ),
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return _StyleDiscoveryCard(product: product, index: index);
          },
        ),
      ],
    );
  }
}

class _StyleDiscoveryCard extends StatefulWidget {
  final Product product;
  final int index;

  const _StyleDiscoveryCard({required this.product, required this.index});

  @override
  State<_StyleDiscoveryCard> createState() => _StyleDiscoveryCardState();
}

class _StyleDiscoveryCardState extends State<_StyleDiscoveryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (widget.index * 100)),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (c) => ProductDetailScreen(product: widget.product),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _isHovered
                        ? const Color(0xFFC9A227).withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        widget.product.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.2),
                            ],
                            stops: const [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          widget.product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.product.isFavorite
                              ? Colors.red
                              : const Color(0xFF131517),
                          size: 18,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DummyData.formatPrice(widget.product.price),
                                style: const TextStyle(
                                  color: Color(0xFFC9A227),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded,
                                      size: 14, color: Color(0xFFC9A227)),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.product.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
