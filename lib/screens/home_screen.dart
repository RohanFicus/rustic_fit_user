import 'package:flutter/material.dart';
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

  final List<String> _heroImages = [
    'https://picsum.photos/seed/ethnic-banner1/800/400.jpg',
    'https://picsum.photos/seed/ethnic-banner2/800/400.jpg',
    'https://picsum.photos/seed/ethnic-banner3/800/400.jpg',
    'https://picsum.photos/seed/ethnic-banner4/800/400.jpg',
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
      backgroundColor: const Color(0xFFFDF8F5), // Very light beige/white
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Circular Logo
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              border: Border.all(color: const Color(0xFFD4AF37), width: 1),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://placeholder.com/logo'), // Replace with actual logo asset
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Text("R",
                  style: TextStyle(
                      color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
            ),
          ),
          // Location Selector
          Row(
            children: const [
              Icon(Icons.location_on, color: Color(0xFF8B6B4E), size: 20),
              SizedBox(width: 4),
              Text(
                "Faridabad, Haryana",
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ],
          ),
          // Notification Bell
          const Icon(Icons.notifications, color: Color(0xFF5D4037), size: 28),
        ],
      ),
    );
  }

  // 2. Interactive Image Slider Banner
  Widget _buildHeroBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 180,
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
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(_heroImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),

          // Gradient Overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Slider Indicators
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _heroImages.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      entry.key,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? const Color(0xFFD4AF37)
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Banner Text
          Positioned(
            bottom: 30,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Premium Ethnic Wear",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Handcrafted with Love",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Horizontal Promo Cards (Summer Collection, Wedding Specials, etc.)
  Widget _buildPromoSection() {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _promoCard("Summer Collection", "New Arrivals",
              "https://images.unsplash.com/photo-1581044777550-4cfa60707c03?w=400"),
          _promoCard("Wedding Specials", "",
              "https://images.unsplash.com/photo-1583394060263-f321d5f96732?w=400"),
          _promoCard("Flat 20% Off", "Stitching",
              "https://images.unsplash.com/photo-1556905055-8f358a7a4bb4?w=400"),
        ],
      ),
    );
  }

  Widget _promoCard(String title, String subtitle, String imageUrl) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image:
            DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12)),
            if (subtitle.isNotEmpty)
              Text(subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // 4. Interactive Category Filter Chips
  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () => _selectCategory(category),
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFA67C52)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFA67C52)
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${_selectedCategory} (${filteredProducts.length})",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D4037),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigate to see all products for this category
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("View all $_selectedCategory products"),
                      backgroundColor: const Color(0xFFA67C52),
                    ),
                  );
                },
                child: const Text(
                  "See All",
                  style: TextStyle(
                    color: Color(0xFFA67C52),
                    fontWeight: FontWeight.w500,
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
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 1)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(product.image,
                        width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      product.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: product.isFavorite ? Colors.red : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(DummyData.formatPrice(product.price),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                ],
              ),
            )
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
