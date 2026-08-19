import 'package:flutter/material.dart';

import '../models/dummy_data.dart';
import '../services/api_service.dart';
import '../widgets/app_network_image.dart';
import 'category_products_screen.dart';

class SubCategoriesScreen extends StatefulWidget {
  final Category category;

  const SubCategoriesScreen({super.key, required this.category});

  @override
  State<SubCategoriesScreen> createState() => _SubCategoriesScreenState();
}

class _SubCategoriesScreenState extends State<SubCategoriesScreen> {
  List<Category> _categories = [];
  Category? _selectedCategory;
  List<SubCategory> _subCategories = [];

  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = true;
  String _categoriesError = '';
  String _subCategoriesError = '';

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightBg = Color(0xFFFAF9F6);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = '';
    });
    try {
      final cats = await ApiService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = cats;
          _isLoadingCategories = false;

          if (_selectedCategory != null) {
            final matched = cats.where((c) => c.id == _selectedCategory!.id);
            if (matched.isNotEmpty) {
              _selectedCategory = matched.first;
            }
          } else if (cats.isNotEmpty) {
            _selectedCategory = cats.first;
          }
        });

        if (_selectedCategory != null) {
          _fetchSubCategories(_selectedCategory!.id);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _categoriesError = e.toString();
          _isLoadingCategories = false;
          _isLoadingSubCategories = false;
        });
      }
    }
  }

  Future<void> _fetchSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
      _subCategoriesError = '';
    });
    try {
      final data = await ApiService.fetchSubCategories(categoryId);
      if (mounted) {
        setState(() {
          _subCategories = data;
          _isLoadingSubCategories = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _subCategoriesError = e.toString();
          _isLoadingSubCategories = false;
        });
      }
    }
  }

  Widget _buildCategoryIcon(Category cat, bool isSelected) {
    final iconPath = cat.icon;
    final color = isSelected ? Colors.white : Colors.grey[600];

    if (iconPath.startsWith('http') || iconPath.startsWith('https')) {
      return AppNetworkImage(
        imageUrl: iconPath,
        width: 20,
        height: 20,
      );
    } else {
      return Image.asset(
        iconPath,
        width: 20,
        height: 20,
        color: color,
        errorBuilder: (context, error, stackTrace) =>
            Icon(Icons.style_outlined, color: color, size: 20),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: lightBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: darkBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _selectedCategory?.name ?? widget.category.name,
          style: const TextStyle(
            color: darkBrown,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Row(
        children: [
          _buildSidebar(isWide),
          Container(width: 1.5, color: const Color(0xFFE9ECEF)),
          Expanded(
            child: _buildSubCategoryContent(isWide),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(bool isWide) {
    if (_isLoadingCategories) {
      return Container(
        width: isWide ? 240 : 90,
        color: Colors.white,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child:
                CircularProgressIndicator(strokeWidth: 2.5, color: primaryGold),
          ),
        ),
      );
    }

    if (_categoriesError.isNotEmpty) {
      return Container(
        width: isWide ? 240 : 90,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 24),
            const SizedBox(height: 8),
            Text(
              'Error',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: primaryGold),
              onPressed: _loadInitialData,
            )
          ],
        ),
      );
    }

    return Container(
      width: isWide ? 240 : 90,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory?.id == cat.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                if (cat.id != _selectedCategory?.id) {
                  setState(() {
                    _selectedCategory = cat;
                  });
                  _fetchSubCategories(cat.id);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: EdgeInsets.symmetric(
                  vertical: isWide ? 18 : 16,
                  horizontal: isWide ? 20 : 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryGold.withOpacity(0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: isWide
                    ? Row(
                        children: [
                          _buildCategoryIcon(cat, isSelected),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF131517),
                                fontWeight: isSelected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCategoryIcon(cat, isSelected),
                          const SizedBox(height: 6),
                          Text(
                            cat.name.split(' ')[0],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF131517),
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSubCategoryContent(bool isWide) {
    if (_isLoadingSubCategories) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGold),
      );
    }

    if (_subCategoriesError.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Failed to load styles',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _fetchSubCategories(_selectedCategory!.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    if (_subCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checkroom_rounded, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No styles available',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 40.0 : 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Select a Style',
                  style: TextStyle(
                    fontSize: isWide ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: darkBrown,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${_subCategories.length} Options',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Explore bespoke styles in the ${_selectedCategory?.name} collection.',
              style:
                  TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _subCategories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: isWide ? 24 : 16,
                crossAxisSpacing: isWide ? 24 : 16,
              ),
              itemBuilder: (context, index) {
                final sub = _subCategories[index];
                return _SubCategoryCard(
                  sub: sub,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryProductsScreen(subCategory: sub),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SubCategoryCard extends StatefulWidget {
  final SubCategory sub;
  final VoidCallback onTap;

  const _SubCategoryCard({required this.sub, required this.onTap});

  @override
  State<_SubCategoryCard> createState() => _SubCategoryCardState();
}

class _SubCategoryCardState extends State<_SubCategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.sub.image;
    final hasImage = imagePath.isNotEmpty &&
        (imagePath.startsWith('http') || imagePath.startsWith('assets'));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isHovered
                    ? const Color(0xFFC9A227)
                    : const Color(0xFFF1F3F5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFFC9A227).withOpacity(0.12)
                      : Colors.black.withOpacity(0.02),
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
                    child: hasImage
                        ? AppNetworkImage(
                            imageUrl: imagePath,
                            fit: BoxFit.cover,
                          )
                        : _buildPlaceholderBackground(),
                  ),
                  if (hasImage)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.85),
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: !hasImage
                            ? LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.9),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: hasImage
                                      ? const Color(0xFFC9A227).withOpacity(0.8)
                                      : const Color(0xFFC9A227)
                                          .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.checkroom_rounded,
                                  color: hasImage
                                      ? Colors.white
                                      : const Color(0xFFC9A227),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.sub.name.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: hasImage
                                        ? Colors.white
                                        : const Color(0xFF131517),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Curated Custom Fit',
                            style: TextStyle(
                              color: hasImage
                                  ? Colors.grey[300]
                                  : Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC9A227).withOpacity(0.03),
            const Color(0xFFC9A227).withOpacity(0.08),
            const Color(0xFF131517).withOpacity(0.02),
          ],
        ),
      ),
      child: const Center(
        child: Opacity(
          opacity: 0.1,
          child: Icon(
            Icons.checkroom_rounded,
            size: 64,
            color: Color(0xFFC9A227),
          ),
        ),
      ),
    );
  }
}
