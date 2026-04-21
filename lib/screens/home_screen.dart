import 'package:flutter/material.dart';
import 'package:rustic_fit/screens/location_selection_screen.dart';
import 'package:rustic_fit/screens/product_detail_screen.dart';

import '../models/dummy_data.dart';
import '../services/data_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  String _selectedCategory = "All";
  String _currentLocation = "Faridabad, Haryana";

  final List<String> _heroImages = [
    'https://plus.unsplash.com/premium_photo-1769290472496-62ffdb7003fb?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1768823132446-915e5707a70d?q=80&w=2073&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1768823132441-b49d729ae5ca?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1768823132559-37639ef3f28a?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  ];

  final List<String> _categories = [
    "All",
    "Women",
    "Men",
    "Kids",
    "Bids",
    "Best Design"
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll the image slider
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
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
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroBanner(),
                    _buildPromoSection(),
                    _buildCategoryTabs(),
                    _buildProductGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: _buildBottomNav(),
    );
  }

  // 1. Header with Logo, Location, and Notification
  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 10),
                  color: Color(0x12000000),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (context) => LocationSelectionScreen(
                    currentLocation: _currentLocation,
                  ),
                ),
              );

              if (result != null && mounted) {
                setState(() {
                  _currentLocation = result;
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: colorScheme.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    _currentLocation,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            color: colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  // 2. Interactive Image Slider Banner
  Widget _buildHeroBanner() {
    final radius = BorderRadius.circular(24);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      height: 190,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image Slider
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: _heroImages.length,
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: radius,
                child: Image.network(
                  _heroImages[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              borderRadius: radius,
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Slider Indicators
          Positioned(
            bottom: 16,
            right: 20,
            child: Row(
              children: _heroImages.asMap().entries.map((entry) {
                final isSelected = _currentImageIndex == entry.key;
                return Container(
                  width: isSelected ? 20 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                );
              }).toList(),
            ),
          ),

          // Banner Text
          Positioned(
            bottom: 24,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium Ethnic Wear",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Handcrafted with Love",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Horizontal Promo Cards
  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _promoCard("Summer Collection", "New Arrivals",
                  "https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=400"),
              _promoCard("Wedding Specials", "Limited Edition",
                  "https://images.unsplash.com/photo-1595777457583-95e059d581b8?q=80&w=1383&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
              _promoCard("Flat 20% Off", "Stitching & More",
                  "https://images.unsplash.com/photo-1623609163859-ca93c959b98a?q=80&w=986&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _promoCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 130,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
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

  // 4. Interactive Category Filter Chips
  Widget _buildCategoryTabs() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = category == _selectedCategory;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: GestureDetector(
                onTap: () => _selectCategory(category),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? colorScheme.primary : colorScheme.surface,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isSelected ? Colors.white : colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // 5. Product Grid with Category Filtering
  Widget _buildProductGrid(BuildContext context) {
    final dataService = DataService();
    List<Product> allProducts = dataService.getProducts();

    // Filter products based on selected category
    List<Product> filteredProducts = _selectedCategory == "All"
        ? allProducts
        : allProducts
            .where((product) =>
                product.category.toLowerCase() ==
                _selectedCategory.toLowerCase())
            .toList();

    // Show more products (up to 8)
    final productsToShow = filteredProducts.take(8).toList();

    return Column(
      children: [
        // Products header with count
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${_selectedCategory} (${filteredProducts.length})",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  "See All",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Product Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          childAspectRatio: 0.75,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: productsToShow
              .map((product) => _productCard(context, product))
              .toList(),
        ),

        // Show message if no products found
        if (productsToShow.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  "No products found in $_selectedCategory",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Try selecting a different category",
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _productCard(BuildContext context, Product product) {
    final colorScheme = Theme.of(context).colorScheme;

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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
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
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(20)),
                      child: Image.network(product.image, fit: BoxFit.cover),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: product.isFavorite
                            ? Colors.red
                            : colorScheme.onSurfaceVariant,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DummyData.formatPrice(product.price),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          fontSize: 15,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.star,
                                size: 10, color: colorScheme.primary),
                            const SizedBox(width: 2),
                            Text(
                              product.rating.toString(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 6. Bottom Navigation Bar
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFFA67C52),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.grid_view), label: 'Categories'),
        BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag), label: 'Orders'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
