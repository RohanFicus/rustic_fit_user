import 'package:flutter/material.dart';
import '../models/dummy_data.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Get all data
  List<Category> getCategories() => DummyData.categories;
  List<Product> getProducts() => DummyData.products;
  List<Order> getOrders() => DummyData.orders;
  User getCurrentUser() => DummyData.currentUser;
  List<Tailor> getTailors() => DummyData.tailors;

  // Category methods
  List<Product> getProductsByCategory(String categoryName) {
    return DummyData.getProductsByCategory(categoryName);
  }

  Category? getCategoryById(String id) {
    return DummyData.getCategoryById(id);
  }

  // Product methods
  Product? getProductById(String id) {
    return DummyData.getProductById(id);
  }

  List<Product> searchProducts(String query) {
    return DummyData.products
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            product.description.toLowerCase().contains(query.toLowerCase()) ||
            product.category.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<Product> getFavoriteProducts() {
    return DummyData.products.where((product) => product.isFavorite).toList();
  }

  void toggleFavorite(String productId) {
    Product? product = getProductById(productId);
    if (product != null) {
      product.isFavorite = !product.isFavorite;
    }
  }

  // Order methods
  Order? getOrderById(String id) {
    return DummyData.getOrderById(id);
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return DummyData.getOrdersByStatus(status);
  }

  List<Order> getActiveOrders() {
    return DummyData.orders
        .where((order) =>
            order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled)
        .toList();
  }

  List<Order> getCompletedOrders() {
    return DummyData.orders
        .where((order) => order.status == OrderStatus.delivered)
        .toList();
  }

  List<Order> getCancelledOrders() {
    return DummyData.orders
        .where((order) => order.status == OrderStatus.cancelled)
        .toList();
  }

  // Create new order (for demo purposes)
  Order createOrder(List<OrderItem> items, String deliveryAddress) {
    final newOrder = Order(
      id: (DummyData.orders.length + 1).toString(),
      orderNumber: '#${(DummyData.orders.length + 10000)}',
      orderDate: DateTime.now(),
      items: items,
      status: OrderStatus.pending,
      totalAmount:
          items.fold(0, (sum, item) => sum + (item.price * item.quantity)),
      deliveryAddress: deliveryAddress,
      tailorName: 'Bhandari Tailors',
      tailorAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
    );
    DummyData.orders.add(newOrder);
    return newOrder;
  }

  // Update order status (for demo purposes)
  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    Order? order = getOrderById(orderId);
    if (order != null) {
      order.status = newStatus;
      if (newStatus == OrderStatus.delivered) {
        order.deliveryDate = DateTime.now();
      }
    }
  }

  // Cancel order (for demo purposes)
  void cancelOrder(String orderId) {
    updateOrderStatus(orderId, OrderStatus.cancelled);
  }

  // User methods
  void updateUserData({
    String? name,
    String? email,
    String? phone,
    List<String>? savedAddresses,
    Map<String, String>? bodyMeasurements,
  }) {
    final user = DummyData.currentUser;
    if (name != null) user.name = name;
    if (email != null) user.email = email;
    if (phone != null) user.phone = phone;
    if (savedAddresses != null) user.savedAddresses = savedAddresses;
    if (bodyMeasurements != null) user.bodyMeasurements = bodyMeasurements;
  }

  void addSavedAddress(String address) {
    if (!DummyData.currentUser.savedAddresses.contains(address)) {
      DummyData.currentUser.savedAddresses.add(address);
    }
  }

  void removeSavedAddress(String address) {
    DummyData.currentUser.savedAddresses.remove(address);
  }

  void updateBodyMeasurement(String measurement, String value) {
    DummyData.currentUser.bodyMeasurements[measurement] = value;
  }

  // Tailor methods
  List<Tailor> getAvailableTailors() {
    return DummyData.tailors.where((tailor) => tailor.isAvailable).toList();
  }

  Tailor? getTailorById(String id) {
    try {
      return DummyData.tailors.firstWhere((tailor) => tailor.id == id);
    } catch (e) {
      return null;
    }
  }

  // Statistics methods
  Map<String, int> getCategoryStats() {
    final stats = <String, int>{};
    for (var category in DummyData.categories) {
      stats[category.name] = category.productCount;
    }
    return stats;
  }

  Map<String, double> getOrderStats() {
    final totalOrders = DummyData.orders.length;
    final deliveredOrders = getCompletedOrders().length;
    final cancelledOrders = getCancelledOrders().length;
    final activeOrders = getActiveOrders().length;
    final totalRevenue = DummyData.orders
        .where((order) => order.status != OrderStatus.cancelled)
        .fold(0.0, (sum, order) => sum + order.totalAmount);

    return {
      'totalOrders': totalOrders.toDouble(),
      'deliveredOrders': deliveredOrders.toDouble(),
      'cancelledOrders': cancelledOrders.toDouble(),
      'activeOrders': activeOrders.toDouble(),
      'totalRevenue': totalRevenue,
    };
  }

  List<Map<String, dynamic>> getRecentActivity() {
    final activities = <Map<String, dynamic>>[];

    // Add order activities
    for (var order in DummyData.orders.take(5)) {
      activities.add({
        'type': 'order',
        'title': 'Order ${order.orderNumber}',
        'description':
            '${DummyData.getOrderStatusText(order.status)} - ${DummyData.formatDate(order.orderDate)}',
        'timestamp': order.orderDate,
        'status': order.status,
      });
    }

    // Sort by timestamp
    activities.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
    return activities;
  }

  // Search functionality
  List<Product> advancedSearch({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? readyToShip,
    List<String>? sizes,
  }) {
    List<Product> results = List.from(DummyData.products);

    if (query != null && query.isNotEmpty) {
      results = results
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    if (category != null && category.isNotEmpty) {
      results =
          results.where((product) => product.category == category).toList();
    }

    if (minPrice != null) {
      results = results.where((product) => product.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      results = results.where((product) => product.price <= maxPrice).toList();
    }

    if (readyToShip != null) {
      results = results
          .where((product) => product.isReadyToShip == readyToShip)
          .toList();
    }

    if (sizes != null && sizes.isNotEmpty) {
      results = results
          .where((product) => product.sizes.any((size) => sizes.contains(size)))
          .toList();
    }

    return results;
  }

  // Demo data manipulation methods
  void simulateOrderProgress() {
    final activeOrders = getActiveOrders();
    if (activeOrders.isNotEmpty) {
      final order = activeOrders.first;
      switch (order.status) {
        case OrderStatus.pending:
          updateOrderStatus(order.id, OrderStatus.confirmed);
          break;
        case OrderStatus.confirmed:
          updateOrderStatus(order.id, OrderStatus.stitching);
          break;
        case OrderStatus.stitching:
          updateOrderStatus(order.id, OrderStatus.ready);
          break;
        case OrderStatus.ready:
          updateOrderStatus(order.id, OrderStatus.shipped);
          break;
        case OrderStatus.shipped:
          updateOrderStatus(order.id, OrderStatus.delivered);
          break;
        default:
          break;
      }
    }
  }

  void resetDemoData() {
    // Reset all orders to initial state for demo purposes
    for (var order in DummyData.orders) {
      if (order.id == '1') {
        order.status = OrderStatus.stitching;
      } else if (order.id == '2') {
        order.status = OrderStatus.delivered;
      } else if (order.id == '3') {
        order.status = OrderStatus.cancelled;
      } else if (order.id == '4') {
        order.status = OrderStatus.shipped;
      }
    }
  }
}
