import 'package:flutter/material.dart';
import 'package:rustic_fit/screens/location_selection_screen.dart';
import 'package:rustic_fit/screens/product_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dummy_data.dart';
import '../services/api_service.dart';
import 'sub_categories_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentImageIndex = 0;
  String _selectedCategory = "All";
  String _currentLocation = "Select Location";
  String _searchQuery = "";

  List<String> _heroImages = [
    'https://plus.unsplash.com/premium_photo-1769290472496-62ffdb7003fb?q=80&w=2070&auto=format&fit=crop',
    'https://plus.unsplash.com/premium_photo-1768823132446-915e5707a70d?q=80&w=2073&auto=format&fit=crop',
    'https://plus.unsplash.com/premium_photo-1768823132441-b49d729ae5ca?q=80&w=2070&auto=format&fit=crop',
    'https://plus.unsplash.com/premium_photo-1768823132559-37639ef3f28a?q=80&w=2070&auto=format&fit=crop',
  ];

  List<String> _categories = ["All"];
  List<Product> _filteredProducts = [];
  List<SubCategory> _subCategories = [];
  SubCategory? _selectedSubCategory;
  bool _isLoadingCategories = false;
  bool _isLoadingSubCategories = false;
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _startAutoScroll();
    _initializeLocation();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    try {
      final banners = await ApiService.fetchBanners();
      if (banners.isNotEmpty && mounted) {
        setState(() {
          _heroImages = banners;
        });
      }
    } catch (e) {
      print('Failed to load banners: $e');
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final cats = await ApiService.fetchCategories();
      if (cats.isNotEmpty && mounted) {
        setState(() {
          DummyData.categories = cats;
          _categories = ["All", ...cats.map((c) => c.name)];
        });
      }
    } catch (e) {
      print('Error pre-fetching categories in HomeScreen: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingCategories = false);
      }
      _applyFilters();
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
      print('Error loading subcategories: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingSubCategories = false);
      }
    }
    _applyFilters();
  }

  Future<void> _loadProductsBySubCategory(String subCategoryId, String categoryName) async {
    setState(() {
      _isLoadingProducts = true;
    });
    try {
      final prods = await ApiService.fetchProductsBySubCategory(subCategoryId, categoryName);
      if (mounted) {
        setState(() {
          _filteredProducts = prods;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
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

  Future<void> _initializeLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLoc = prefs.getString('selected_location');

    if (savedLoc != null && savedLoc.isNotEmpty) {
      setState(() {
        _currentLocation = savedLoc;
      });
      return;
    }

    if (DummyData.currentUser.savedAddresses.isNotEmpty) {
      final address = DummyData.currentUser.savedAddresses.first;
      final parts = address.split(', ');
      setState(() {
        if (parts.length >= 2) {
          _currentLocation = parts.sublist(parts.length - 2).join(', ');
        } else {
          _currentLocation = address;
        }
      });
      // Save it as selected location
      await prefs.setString('selected_location', _currentLocation);
    } else {
      setState(() {
        _currentLocation = "Select Location";
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _promptLocationSelection();
      });
    }
  }

  Future<void> _promptLocationSelection() async {
    if (!mounted) return;
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LocationSelectionScreen(currentLocation: "Select Location"),
      ),
    );
    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _currentLocation = result;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_location', result);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _nextImage();
        _startAutoScroll();
      }
    });
  }

  void _nextImage() {
    setState(() {
      _currentImageIndex = (_currentImageIndex + 1) % _heroImages.length;
    });
    _pageController.animateToPage(
      _currentImageIndex,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutQuart,
    );
  }

  void _selectCategory(String category) {
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
        orElse: () => Category(id: '', name: '', icon: '', image: '', productCount: 0),
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
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildHeader(isWide),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 20 : 10,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isWide) _buildWelcomeSection(),
                        _buildHeroBanner(isWide),
                        //if (!isWide) _buildStatsCard(),
                        const SizedBox(height: 12),
                        _buildCategoryTabs(isWide),
                        const SizedBox(height: 12),
                        _buildProductGrid(context, isWide),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isWide)
            Expanded(
              flex: 1,
              child: _buildRightSidebar(),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${DummyData.currentUser.name}!',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF131517),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            DummyData.orders.any((o) =>
                    o.status != OrderStatus.delivered &&
                    o.status != OrderStatus.cancelled)
                ? 'You have active bespoke orders in progress. Check status below.'
                : 'Your bespoke tailoring journey. Start by selecting a garment.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isWide) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 30 : 12,
        vertical: isWide ? 20 : 12,
      ),
      color: Colors.white,
      child: Row(
        children: [
          if (!isWide) ...[
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: 12),
          ],
          _buildLocationPicker(colorScheme),
          const Spacer(),
          if (isWide) _buildWideSearchBar(),
          const SizedBox(width: 24),
          _buildIconButton(Icons.shopping_bag_outlined),
          const SizedBox(width: 12),
          _buildIconButton(Icons.notifications_outlined),
          if (!isWide) ...[
            const SizedBox(width: 8),
            _buildIconButton(Icons.search_rounded),
          ],
        ],
      ),
    );
  }

  Widget _buildWideSearchBar() {
    return Container(
      width: 400,
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
          hintText: 'Search premium designs...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded,
              size: 20, color: Color(0xFFC9A227)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 13),
        ),
      ),
    );
  }

  Widget _buildLocationPicker(ColorScheme colorScheme) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LocationSelectionScreen(currentLocation: _currentLocation),
          ),
        );
        if (result != null && mounted) {
          setState(() => _currentLocation = result);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('selected_location', result);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFC9A227).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined,
                color: Color(0xFFC9A227), size: 18),
            const SizedBox(width: 8),
            Text(
              _currentLocation,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Color(0xFF131517),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 18, color: Color(0xFFC9A227)),
          ],
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

  Widget _buildHeroBanner(bool isWide) {
    return Container(
      height: isWide ? 300 : 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isWide ? 32 : 16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: isWide ? 30 : 15,
            offset: Offset(0, isWide ? 15 : 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentImageIndex = i),
            itemCount: _heroImages.length,
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(isWide ? 32 : 16),
              child: Image.network(_heroImages[index], fit: BoxFit.cover),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isWide ? 32 : 16),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.2),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: isWide ? 40 : 12,
            left: isWide ? 40 : 16,
            right: isWide ? 40 : 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isWide ? 12 : 8,
                            vertical: isWide ? 6 : 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC9A227),
                          borderRadius: BorderRadius.circular(isWide ? 8 : 4),
                        ),
                        child: Text(
                          'LIMITED EDITION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWide ? 10 : 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      SizedBox(height: isWide ? 16 : 6),
                      Text(
                        "The Masterpiece\nCollection 2024",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isWide ? 36 : 18,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      SizedBox(height: isWide ? 12 : 4),
                      Text(
                        "Experience the pinnacle of bespoke tailoring with our curated premium selection.",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: isWide ? 16 : 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isWide)
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF131517),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Explore Collection',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: isWide ? 40 : 12,
            right: isWide ? 40 : 16,
            child: Row(
              children: List.generate(
                _heroImages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentImageIndex == i ? (isWide ? 32 : 16) : 6,
                  height: 6,
                  margin: const EdgeInsets.only(left: 4),
                  decoration: BoxDecoration(
                    color: _currentImageIndex == i
                        ? const Color(0xFFC9A227)
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightSidebar() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFE9ECEF))),
      ),
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //_buildStatsCard(),
            //const SizedBox(height: 32),
            const Text(
              'Upcoming Schedule',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF131517)),
            ),
            const SizedBox(height: 20),
            ..._buildDynamicSchedule(),
            const SizedBox(height: 32),
            const Text(
              'Recent Style Inspo',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF131517)),
            ),
            const SizedBox(height: 20),
            _buildInspoCard('Classic Tuxedo',
                'https://images.unsplash.com/photo-1597983073493-88cd35cf93b0?w=200'),
            const SizedBox(height: 12),
            _buildInspoCard('Modern Ethnic',
                'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=200'),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDynamicSchedule() {
    final activeOrders = DummyData.orders
        .where((o) =>
            o.status != OrderStatus.delivered &&
            o.status != OrderStatus.cancelled)
        .toList();

    if (activeOrders.isEmpty) {
      return [
        _buildScheduleItem(
          'Ready to Customise',
          'Book your first suit',
          'Coordinate tailor now',
          Icons.straighten_rounded,
          const Color(0xFFC9A227),
        ),
      ];
    }

    return activeOrders.map((order) {
      final itemName = order.items.isNotEmpty
          ? order.items.first.product.name
          : 'Garment Bespoke';

      String statusTitle = 'Bespoke Order';
      String dateInfo = 'Pending tailors';
      IconData icon = Icons.checkroom_rounded;
      Color color = const Color(0xFFC9A227);

      switch (order.status) {
        case OrderStatus.pending:
          statusTitle = 'Order Placed';
          dateInfo = 'Awaiting Tailor';
          icon = Icons.shopping_bag_outlined;
          color = Colors.blue;
          break;
        case OrderStatus.confirmed:
          statusTitle = 'Tailor Assigned';
          dateInfo = 'Coordination in progress';
          icon = Icons.straighten_rounded;
          color = Colors.orange;
          break;
        case OrderStatus.stitching:
          statusTitle = 'Stitching & Tailoring';
          dateInfo = 'Master tailor crafting';
          icon = Icons.checkroom_rounded;
          color = Colors.purple;
          break;
        case OrderStatus.ready:
          statusTitle = 'Ready to Dispatch';
          dateInfo = 'Quality check passed';
          icon = Icons.done_all_rounded;
          color = Colors.teal;
          break;
        case OrderStatus.shipped:
          statusTitle = 'Shipped & Out';
          dateInfo = 'Delivery in progress';
          icon = Icons.local_shipping_rounded;
          color = Colors.green;
          break;
        default:
          break;
      }

      return _buildScheduleItem(
        itemName,
        '$statusTitle - ${order.orderNumber}',
        dateInfo,
        icon,
        color,
      );
    }).toList();
  }

  Widget _buildScheduleItem(
      String title, String date, String time, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 4),
                Text('$date • $time',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInspoCard(String title, String url) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(16),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF131517), Color(0xFF2D2926)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Royal Member',
                style: TextStyle(
                    color: Color(0xFFC9A227),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1),
              ),
              Icon(Icons.stars_rounded,
                  color: const Color(0xFFC9A227).withValues(alpha: 0.5),
                  size: 20),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '2,450',
            style: TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Available Points',
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: 0.7,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC9A227)),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          const Text(
            '550 points to Gold status',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Category',
          style: TextStyle(
              fontSize: isWide ? 20 : 16,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF131517)),
        ),
        SizedBox(height: isWide ? 20 : 12),
        SizedBox(
          height: isWide ? 48 : 36,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final isSelected = _selectedCategory == _categories[index];
              return GestureDetector(
                onTap: () => _selectCategory(_categories[index]),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: isWide ? 12 : 8),
                  padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 28 : 16, vertical: isWide ? 12 : 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFC9A227) : Colors.white,
                    borderRadius: BorderRadius.circular(isWide ? 16 : 10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFC9A227)
                          : const Color(0xFFE9ECEF),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFC9A227)
                                  .withValues(alpha: 0.2),
                              blurRadius: isWide ? 12 : 6,
                              offset: Offset(0, isWide ? 6 : 3),
                            )
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _categories[index],
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF4A443F),
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: isWide ? 14 : 11,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_selectedCategory != "All" && (_isLoadingSubCategories || _subCategories.isNotEmpty)) ...[
          const SizedBox(height: 16),
          Text(
            'Sub-categories',
            style: TextStyle(
                fontSize: isWide ? 16 : 13,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A443F)),
          ),
          const SizedBox(height: 10),
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
                          margin: EdgeInsets.only(right: isWide ? 10 : 6),
                          padding: EdgeInsets.symmetric(
                              horizontal: isWide ? 20 : 12, vertical: isWide ? 10 : 5),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF131517) : Colors.white,
                            borderRadius: BorderRadius.circular(isWide ? 12 : 8),
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
                                color: isSelected ? Colors.white : const Color(0xFF4A443F),
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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

  Widget _buildProductGrid(BuildContext context, bool isWide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Most Popular",
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF131517)),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("View All",
                  style: TextStyle(
                      color: Color(0xFFC9A227), fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _isLoadingProducts
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: CircularProgressIndicator(
                    color: Color(0xFFC9A227),
                  ),
                ),
              )
            : _filteredProducts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.checkroom_rounded,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == "All"
                                ? "No products available"
                                : _selectedSubCategory == null
                                    ? "Select a sub-category style to view outfits"
                                    : "No outfits found in this style",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 3 : 2,
                      childAspectRatio: 0.72,
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                    ),
                    itemBuilder: (context, index) => _buildProductCard(
                        context, _filteredProducts[index], index, isWide),
                  ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildProductCard(
      BuildContext context, Product product, int index, bool isWide) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: _HoverProductCard(product: product),
    );
  }
}

class _HoverProductCard extends StatefulWidget {
  final Product product;

  const _HoverProductCard({required this.product});

  @override
  State<_HoverProductCard> createState() => _HoverProductCardState();
}

class _HoverProductCardState extends State<_HoverProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(isWide ? 24 : 14),
              boxShadow: [
                BoxShadow(
                  color: _isHovered
                      ? const Color(0xFFC9A227).withValues(alpha: 0.15)
                      : const Color(0xFFDCD6D0).withValues(alpha: 0.2),
                  blurRadius: _isHovered ? 25 : 15,
                  offset: Offset(0, _isHovered ? 12 : 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(isWide ? 24 : 14)),
                          child: Image.network(widget.product.image,
                              fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: isWide ? 16 : 8,
                        right: isWide ? 16 : 8,
                        child: Container(
                          padding: EdgeInsets.all(isWide ? 8 : 6),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            widget.product.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.product.isFavorite
                                ? Colors.red
                                : Colors.grey[400],
                            size: isWide ? 20 : 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(isWide ? 16 : 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: isWide ? 16 : 13,
                            color: const Color(0xFF131517)),
                      ),
                      SizedBox(height: isWide ? 8 : 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DummyData.formatPrice(widget.product.price),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFC9A227),
                              fontSize: isWide ? 18 : 14,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.star_rounded,
                                  size: isWide ? 16 : 12,
                                  color: const Color(0xFFC9A227)),
                              const SizedBox(width: 4),
                              Text(
                                widget.product.rating.toString(),
                                style: TextStyle(
                                    fontSize: isWide ? 14 : 11,
                                    fontWeight: FontWeight.bold),
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
    );
  }
}
