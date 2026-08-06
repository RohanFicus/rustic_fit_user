import 'package:flutter/material.dart';
import 'package:rustic_fit/models/dummy_data.dart';
import '../services/api_service.dart';
import 'category_products_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  List<Map<String, dynamic>> _categories = [];
  List<SubCategory> _subCategories = [];
  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = true;

  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightBg = Color(0xFFFAF9F6);
  static const Color darkBrown = Color(0xFF131517);

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
    setState(() {
      _isLoadingCategories = true;
    });
    try {
      final cats = await ApiService.fetchCategories();
      if (mounted) {
        setState(() {
          DummyData.categories = cats;
          _categories = [
            {"id": "all", "name": "All", "icon": Icons.all_inclusive_rounded},
            ...cats.map((c) => {
                  "id": c.id,
                  "name": c.name,
                  "icon": _getIconForCategory(c.name),
                  "category": c
                })
          ];
          _isLoadingCategories = false;
        });
        
        _onCategorySelected("All");
      }
    } catch (e) {
      print('Error fetching categories in ScheduleScreen: $e');
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
        });
      }
    }
  }

  void _onCategorySelected(String categoryName) {
    setState(() {
      _selectedCategory = categoryName;
    });

    if (categoryName == "All") {
      _loadAllSubCategories();
    } else {
      final catMap = _categories.firstWhere(
        (c) => c['name'].toLowerCase() == categoryName.toLowerCase(),
        orElse: () => {},
      );
      if (catMap.isNotEmpty && catMap['id'] != null) {
        _loadSubCategories(catMap['id']);
      }
    }
  }

  Future<void> _loadAllSubCategories() async {
    setState(() {
      _isLoadingSubCategories = true;
    });
    try {
      final cats = DummyData.categories.isNotEmpty 
          ? DummyData.categories 
          : await ApiService.fetchCategories();
      
      List<SubCategory> allSubs = [];
      for (var cat in cats) {
        final subs = await ApiService.fetchSubCategories(cat.id);
        allSubs.addAll(subs);
      }
      
      final uniqueSubs = <String, SubCategory>{};
      for (var sub in allSubs) {
        uniqueSubs[sub.id] = sub;
      }
      
      if (mounted) {
        setState(() {
          _subCategories = uniqueSubs.values.toList();
        });
      }
    } catch (e) {
      print('Error loading all subcategories: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubCategories = false);
      }
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
  }

  List<SubCategory> get _filteredSubCategories {
    if (_searchQuery.trim().isEmpty) {
      return _subCategories;
    }
    return _subCategories
        .where((sub) => sub.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: lightBg,
      body: Column(
        children: [
          _buildHeader(isWide),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(isWide),
                Container(width: 1.5, color: const Color(0xFFE9ECEF)),
                Expanded(
                  child: _buildSubCategoryContent(isWide),
                ),
              ],
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

  Widget _buildSidebar(bool isWide) {
    if (_isLoadingCategories) {
      return Container(
        width: isWide ? 240 : 90,
        color: Colors.white,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: primaryGold),
          ),
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
          final isSelected = _selectedCategory == cat['name'];
          final IconData icon = cat['icon'] ?? Icons.category_rounded;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onCategorySelected(cat['name']),
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
                          Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              cat['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : const Color(0xFF131517),
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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
                          Icon(
                            icon,
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            cat['name'].split(' ')[0],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF131517),
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
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
    final filtered = _filteredSubCategories;

    if (_isLoadingSubCategories) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGold),
      );
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.style_outlined, size: 64, color: Color(0xFFE9ECEF)),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                  ? 'No styles matching "$_searchQuery"'
                  : 'No styles available in $_selectedCategory',
              style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.w600),
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
                  '$_selectedCategory Styles',
                  style: TextStyle(
                    fontSize: isWide ? 22 : 18,
                    fontWeight: FontWeight.w900,
                    color: darkBrown,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  '${filtered.length} Options',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWide ? 4 : 2,
                childAspectRatio: 0.85,
                mainAxisSpacing: isWide ? 24 : 16,
                crossAxisSpacing: isWide ? 24 : 16,
              ),
              itemBuilder: (context, index) {
                final sub = filtered[index];
                return _SubCategoryCard(
                  sub: sub,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsScreen(subCategory: sub),
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
    final hasImage = imagePath.isNotEmpty && (imagePath.startsWith('http') || imagePath.startsWith('assets'));

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
                color: _isHovered ? const Color(0xFFC9A227) : const Color(0xFFF1F3F5),
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
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderBackground(),
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
                                      : const Color(0xFFC9A227).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.checkroom_rounded,
                                  color: hasImage ? Colors.white : const Color(0xFFC9A227),
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
                                    color: hasImage ? Colors.white : const Color(0xFF131517),
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
                              color: hasImage ? Colors.grey[300] : Colors.grey[500],
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
