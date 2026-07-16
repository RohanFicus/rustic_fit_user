import 'package:flutter/material.dart';
import 'package:rustic_fit/screens/fitting_details_screen.dart';

import '../models/dummy_data.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color primaryGold = Color(0xFFC9A227);
  static const Color lightCream = Color(0xFFFDFCFB);
  static const Color darkBrown = Color(0xFF131517);

  int _selectedImageIndex = 0;
  final List<String> _productImages = [];

  @override
  void initState() {
    super.initState();
    // In a real app, we'd have multiple images. For now, we'll repeat the main one.
    _productImages.addAll([
      widget.product.image,
      'https://images.unsplash.com/photo-1594932224828-b4b059b02417?w=800',
      'https://images.unsplash.com/photo-1598411030247-97d853754988?w=800',
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;

    return Scaffold(
      backgroundColor: lightCream,
      body: isWide ? _buildWideLayout(context) : _buildMobileLayout(context),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                child: _buildProductInfo(),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomAction(context, false),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Row(
      children: [
        // Left Side: Image Gallery
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.white,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: 'product_${widget.product.id}',
                    child: Image.network(
                      _productImages[_selectedImageIndex],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 40,
                  child: _buildBackButton(context),
                ),
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: _buildImageThumbnails(),
                ),
              ],
            ),
          ),
        ),
        // Right Side: Details
        Expanded(
          flex: 1,
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.fromLTRB(60, 80, 60, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: _buildProductInfo(),
                  ),
                ),
                const SizedBox(height: 40),
                _buildBottomAction(context, true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 500,
      pinned: true,
      backgroundColor: darkBrown,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildBackButton(context),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: _buildFavoriteButton(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${widget.product.id}',
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(widget.product.image, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: darkBrown, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
          )
        ],
      ),
      child: IconButton(
        icon: Icon(
          widget.product.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: widget.product.isFavorite ? Colors.red : darkBrown,
          size: 20,
        ),
        onPressed: () {},
      ),
    );
  }

  Widget _buildImageThumbnails() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _productImages.asMap().entries.map((entry) {
        final isSelected = _selectedImageIndex == entry.key;
        return GestureDetector(
          onTap: () => setState(() => _selectedImageIndex = entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 60,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primaryGold : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(entry.value, fit: BoxFit.cover),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.product.category.toUpperCase(),
                    style: const TextStyle(
                      color: primaryGold,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.product.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: darkBrown,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9ECEF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: primaryGold, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    widget.product.rating.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: darkBrown,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          DummyData.formatPrice(widget.product.price),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: primaryGold,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        _buildSpecGrid(),
        const SizedBox(height: 32),
        const Text(
          "Service Highlights",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: darkBrown,
          ),
        ),
        const SizedBox(height: 20),
        _buildHighlightItem(
          Icons.straighten_rounded,
          "Home Measurement",
          "Professional tailor visits your home for perfect sizing.",
        ),
        _buildHighlightItem(
          Icons.auto_awesome_rounded,
          "Bespoke Stitching",
          "Hand-crafted by master artisans with premium Italian finish.",
        ),
        _buildHighlightItem(
          Icons.verified_rounded,
          "Quality Guaranteed",
          "Triple-checked for stitch perfection and fabric integrity.",
        ),
      ],
    );
  }

  Widget _buildSpecGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Garment Specifications",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: darkBrown,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildSpecItem("Fabric", widget.product.fabric)),
              _buildVerticalDivider(),
              Expanded(child: _buildSpecItem("Color", widget.product.color)),
              _buildVerticalDivider(),
              Expanded(child: _buildSpecItem("Type", widget.product.type)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: darkBrown,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: const Color(0xFFE9ECEF),
    );
  }

  Widget _buildHighlightItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: primaryGold, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: darkBrown,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context, bool isWide) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        isWide ? 0 : 24,
        isWide ? 0 : 16,
        isWide ? 0 : 24,
        isWide ? 0 : 32,
      ),
      decoration: BoxDecoration(
        color: isWide ? Colors.transparent : Colors.white,
        border: isWide
            ? null
            : Border(top: BorderSide(color: const Color(0xFFE9ECEF))),
        boxShadow: isWide
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
      ),
      child: Row(
        children: [
          if (!isWide)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Price",
                    style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DummyData.formatPrice(widget.product.price),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: darkBrown,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            flex: isWide ? 1 : 2,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FittingDetailsScreen(product: widget.product),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGold,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 10,
                shadowColor: primaryGold.withValues(alpha: 0.3),
              ),
              child: const Text(
                "Customize & Book Appointment",
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
