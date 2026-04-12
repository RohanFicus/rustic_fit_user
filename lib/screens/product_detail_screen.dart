import 'package:flutter/material.dart';
import 'package:rustic_fit/screens/add_request_screen.dart';
import '../models/dummy_data.dart';
import '../services/data_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  final Color primaryBrown = const Color(0xFF5D4037);
  final Color accentBrown = const Color(0xFFA67C52);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF5F1),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryBrown, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: accentBrown, size: 18),
            const SizedBox(width: 4),
            Text("Faridabad, Haryana",
                style: TextStyle(color: primaryBrown, fontSize: 16)),
            Icon(Icons.keyboard_arrow_down, color: primaryBrown),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications, color: primaryBrown)),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel Placeholder
            _buildImageCarousel(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryBrown)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              DataService().toggleFavorite(product.id);
                            },
                            child: Icon(
                              product.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: product.isFavorite
                                  ? Colors.red
                                  : primaryBrown,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Icon(Icons.share_outlined, color: primaryBrown),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(DummyData.formatPrice(product.price),
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.local_shipping_outlined,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                          product.isReadyToShip
                              ? "Ready to ship"
                              : "Made to order",
                          style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold)),
                      Text("Delivery in ${product.deliveryDays} days"),
                    ],
                  ),
                  const Divider(height: 40),
                  Text("Design Details",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown)),
                  const SizedBox(height: 12),
                  _buildDetailItem("Fabric: ${product.fabric}"),
                  _buildDetailItem("Color: ${product.color}"),
                  _buildDetailItem("Sizes: ${product.sizes.join(', ')}"),
                  _buildDetailItem(
                      "Rating: ${product.rating} (${product.reviewCount} reviews)"),
                  const Divider(height: 40),
                  Text("More Designs",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryBrown)),
                  const SizedBox(height: 12),
                  _buildMoreDesigns(),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            )
          ],
        ),
      ),
      bottomSheet: _buildBottomButton(
          "Add to Request", Icons.calendar_today_outlined, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddRequestScreen(product: product),
          ),
        );
        // Navigate to AddRequestScreen
      }),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            children: product.images
                .map((imageUrl) => Image.network(imageUrl, fit: BoxFit.cover))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  product.images.length,
                  (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: index == 0 ? 12 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: index == 0 ? primaryBrown : Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      )),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.check, color: primaryBrown, size: 18),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildMoreDesigns() {
    final dataService = DataService();
    final relatedProducts = dataService
        .getProductsByCategory(product.category)
        .where((p) => p.id != product.id)
        .take(4)
        .toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: relatedProducts.length,
        itemBuilder: (context, index) {
          final relatedProduct = relatedProducts[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(product: relatedProduct),
                ),
              );
            },
            child: Container(
              width: 90,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(relatedProduct.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(
      String label, IconData icon, VoidCallback onPressed) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: const Color(0xFFFAF5F1),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBrown,
          minimumSize: const Size(double.infinity, 55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(label,
                style: const TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
