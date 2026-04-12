import 'package:flutter/material.dart';
import '../models/dummy_data.dart';
import '../services/data_service.dart';
import '../utils/demo_helper.dart';

// Example of how to use the dummy data in your Flutter app

class UsageExamples {
  static final DataService _dataService = DataService();

  // Example 1: Using data in Home Screen
  static Widget buildHomeScreenProductGrid() {
    final featuredProducts = DemoHelper.getHomeScreenData()['featuredProducts'] as List<Product>;
    
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
      ),
      itemCount: featuredProducts.length,
      itemBuilder: (context, index) {
        final product = featuredProducts[index];
        return ProductCard(product: product);
      },
    );
  }

  // Example 2: Using data in Orders Screen
  static Widget buildOrdersList() {
    final ordersData = DemoHelper.getOrdersScreenData();
    final activeOrders = ordersData['activeOrders'] as List<Order>;
    
    return ListView.builder(
      itemCount: activeOrders.length,
      itemBuilder: (context, index) {
        final order = activeOrders[index];
        return OrderCard(order: order);
      },
    );
  }

  // Example 3: Using data in Profile Screen
  static Widget buildProfileInfo() {
    final user = DemoHelper.currentUser;
    
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(user.avatar),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(user.email),
        Text(user.phone),
      ],
    );
  }

  // Example 4: Product Detail Screen
  static Widget buildProductDetail(String productId) {
    final product = _dataService.getProductById(productId);
    if (product == null) return const Text('Product not found');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Image.network(product.image, height: 200),
          const SizedBox(height: 16),
          
          // Product Name
          Text(
            product.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          
          // Product Price
          Text(
            DummyData.formatPrice(product.price),
            style: const TextStyle(fontSize: 20, color: Colors.green),
          ),
          const SizedBox(height: 16),
          
          // Product Description
          Text(product.description),
          const SizedBox(height: 16),
          
          // Product Details
          _buildDetailRow('Category', product.category),
          _buildDetailRow('Fabric', product.fabric),
          _buildDetailRow('Color', product.color),
          _buildDetailRow('Sizes', product.sizes.join(', ')),
          _buildDetailRow('Delivery', '${product.deliveryDays} days'),
          _buildDetailRow('Rating', '${product.rating} (${product.reviewCount} reviews)'),
          
          // Add to Cart Button
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Add to cart logic
              _addToCart(product);
            },
            child: const Text('Add to Cart'),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Example 5: Category Screen
  static Widget buildCategoryScreen(String categoryName) {
    final products = _dataService.getProductsByCategory(categoryName);
    
    return Column(
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            '$categoryName (${products.length} products)',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        
        // Products Grid
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ProductCard(product: product);
            },
          ),
        ),
      ],
    );
  }

  // Example 6: Search Screen
  static Widget buildSearchResults(String query) {
    final results = _dataService.searchProducts(query);
    
    if (results.isEmpty) {
      return const Center(
        child: Text('No products found'),
      );
    }
    
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return ListTile(
          leading: Image.network(product.image, width: 50),
          title: Text(product.name),
          subtitle: Text(product.category),
          trailing: Text(DummyData.formatPrice(product.price)),
          onTap: () {
            // Navigate to product detail
          },
        );
      },
    );
  }

  // Example 7: Order Status Tracking
  static Widget buildOrderTracking(String orderId) {
    final order = _dataService.getOrderById(orderId);
    if (order == null) return const Text('Order not found');
    
    return Column(
      children: [
        // Order Info
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ${order.orderNumber}'),
              Text('Status: ${DummyData.getOrderStatusText(order.status)}'),
              Text('Total: ${DummyData.formatPrice(order.totalAmount)}'),
            ],
          ),
        ),
        
        // Status Progress
        _buildStatusProgress(order.status),
        
        // Action Buttons
        if (order.status == OrderStatus.delivered) ...[
          ElevatedButton(
            onPressed: () => _reorderOrder(order),
            child: const Text('Reorder'),
          ),
        ] else if (order.status == OrderStatus.pending) ...[
          ElevatedButton(
            onPressed: () => _cancelOrder(order),
            child: const Text('Cancel Order'),
          ),
        ],
      ],
    );
  }

  static Widget _buildStatusProgress(OrderStatus status) {
    final statuses = OrderStatus.values;
    final currentIndex = statuses.indexOf(status);
    
    return Row(
      children: List.generate(
        statuses.length,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: index <= currentIndex ? Colors.green : Colors.grey,
          ),
        ),
      ),
    );
  }

  // Example 8: User Profile Edit
  static Widget buildProfileEdit() {
    final user = DemoHelper.currentUser;
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _dataService.updateUserData(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
              );
              // Show success message
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  // Action methods
  static void _addToCart(Product product) {
    print('Added to cart: ${product.name}');
    // Implement cart logic
  }

  static void _reorderOrder(Order order) {
    final orderItems = order.items.map((item) => OrderItem(
      product: item.product,
      size: item.size,
      quantity: item.quantity,
      price: item.price,
    )).toList();
    
    _dataService.createOrder(orderItems, order.deliveryAddress);
    print('Order reordered: ${order.orderNumber}');
  }

  static void _cancelOrder(Order order) {
    _dataService.cancelOrder(order.id);
    print('Order cancelled: ${order.orderNumber}');
  }
}

// Widget Components
class ProductCard extends StatelessWidget {
  final Product product;
  
  const ProductCard({super.key, required this.product});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Image.network(
              product.image,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DummyData.formatPrice(product.price),
                  style: const TextStyle(color: Colors.green),
                ),
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber),
                    Text('${product.rating}'),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        product.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: product.isFavorite ? Colors.red : null,
                      ),
                      onPressed: () {
                        DataService().toggleFavorite(product.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  
  const OrderCard({super.key, required this.order});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: DummyData.getOrderStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    DummyData.getOrderStatusText(order.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Items: ${order.items.length}'),
            Text('Total: ${DummyData.formatPrice(order.totalAmount)}'),
            Text('Date: ${DummyData.formatDate(order.orderDate)}'),
          ],
        ),
      ),
    );
  }
}
