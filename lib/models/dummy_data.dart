import 'package:flutter/material.dart';

// Colors
class AppColors {
  static const Color primaryBrown = Color(0xFF5D4037);
  static const Color accentBrown = Color(0xFFA67C52);
  static const Color secondaryBrown = Color(0xFF8B6B4E);
  static const Color lightBg = Color(0xFFFAF5F1);
  static const Color gold = Color(0xFFD4AF37);
  static const Color beige = Color(0xFFF5E6D3);
}

// Category Model
class Category {
  final String id;
  final String name;
  final String icon;
  final String image;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.image,
    required this.productCount,
  });
}

// Product Model
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String image;
  final List<String> images;
  final List<String> sizes;
  final String fabric;
  final String color;
  final bool isReadyToShip;
  final int deliveryDays;
  final double rating;
  final int reviewCount;
  bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.image,
    required this.images,
    required this.sizes,
    required this.fabric,
    required this.color,
    required this.isReadyToShip,
    required this.deliveryDays,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
  });
}

// Order Model
class Order {
  final String id;
  final String orderNumber;
  final DateTime orderDate;
  final List<OrderItem> items;
  OrderStatus status;
  final double totalAmount;
  final String deliveryAddress;
  final String tailorName;
  final String tailorAddress;
  DateTime? deliveryDate;

  Order({
    required this.id,
    required this.orderNumber,
    required this.orderDate,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.tailorName,
    required this.tailorAddress,
    this.deliveryDate,
  });
}

class OrderItem {
  final Product product;
  final String size;
  final int quantity;
  final double price;

  OrderItem({
    required this.product,
    required this.size,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  pending,
  confirmed,
  stitching,
  ready,
  shipped,
  delivered,
  cancelled,
}

// User Model
class User {
  String name;
  String email;
  String phone;
  String avatar;
  List<String> savedAddresses;
  Map<String, String> bodyMeasurements;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatar,
    required this.savedAddresses,
    required this.bodyMeasurements,
  });
}

// Tailor Model
class Tailor {
  final String id;
  final String name;
  final String address;
  final double rating;
  final int reviewCount;
  final String image;
  final bool isAvailable;

  Tailor({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.image,
    required this.isAvailable,
  });
}

// Dummy Data
class DummyData {
  // Locations
  static List<String> locations = [
    'Faridabad, Haryana',
    'Gurugram, Haryana',
    'New Delhi, Delhi',
    'Noida, Uttar Pradesh',
    'Ghaziabad, Uttar Pradesh',
    'Mumbai, Maharashtra',
    'Pune, Maharashtra',
    'Bangalore, Karnataka',
    'Hyderabad, Telangana',
    'Chennai, Tamil Nadu',
  ];

  // Categories
  static List<Category> categories = [
    Category(
      id: '1',
      name: 'Women',
      icon: 'female',
      image: 'https://picsum.photos/seed/women-ethnic/400/300.jpg',
      productCount: 45,
    ),
    Category(
      id: '2',
      name: 'Men',
      icon: 'male',
      image: 'https://picsum.photos/seed/men-ethnic/400/300.jpg',
      productCount: 32,
    ),
    Category(
      id: '3',
      name: 'Kids',
      icon: 'child_care',
      image: 'https://picsum.photos/seed/kids-ethnic/400/300.jpg',
      productCount: 28,
    ),
    Category(
      id: '4',
      name: 'Bids',
      icon: 'gavel',
      image: 'https://picsum.photos/seed/bidding-fashion/400/300.jpg',
      productCount: 15,
    ),
    Category(
      id: '5',
      name: 'Best Design',
      icon: 'star',
      image: 'https://picsum.photos/seed/best-design/400/300.jpg',
      productCount: 18,
    ),
  ];

  // Products
  static List<Product> products = [
    Product(
      id: '1',
      name: 'Anarkali Suit',
      description:
          'Elegant Anarkali suit with intricate embroidery and perfect fit for special occasions.',
      category: 'Women',
      price: 499.0,
      image:
          'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?q=80&w=1364&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      images: [
        'https://plus.unsplash.com/premium_photo-1673481601147-ee95199d3896?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      sizes: ['M', 'L', 'XL', 'XXL'],
      fabric: 'Georgette with thread & sequins work',
      color: 'Maroon',
      isReadyToShip: true,
      deliveryDays: 5,
      rating: 4.5,
      reviewCount: 128,
    ),
    Product(
      id: '2',
      name: 'Classic Sherwani',
      description:
          'Traditional sherwani with modern design elements, perfect for weddings and formal events.',
      category: 'Men',
      price: 999.0,
      image:
          'https://images.unsplash.com/photo-1612336307429-8a898d10e223?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      images: [
        'https://images.unsplash.com/photo-1612336307429-8a898d10e223?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1496747611176-843222e1e57c?q=80&w=2073&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      sizes: ['S', 'M', 'L', 'XL', 'XXL'],
      fabric: 'Silk blend with zari work',
      color: 'Beige',
      isReadyToShip: true,
      deliveryDays: 7,
      rating: 4.7,
      reviewCount: 89,
    ),
    Product(
      id: '3',
      name: 'Kids Lehenga',
      description:
          'Beautiful lehenga choli for kids with comfortable fabric and attractive design.',
      category: 'Kids',
      price: 699.0,
      image:
          'https://images.unsplash.com/photo-1542295669297-4d352b042bca?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      images: [
        'https://images.unsplash.com/photo-1605763240000-7e93b172d754?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        'https://images.unsplash.com/photo-1605763240000-7e93b172d754?q=80&w=987&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      ],
      sizes: ['2Y', '3Y', '4Y', '5Y', '6Y'],
      fabric: 'Cotton with printed patterns',
      color: 'Pink',
      isReadyToShip: true,
      deliveryDays: 4,
      rating: 4.3,
      reviewCount: 67,
    ),
    Product(
      id: '4',
      name: 'Saree Collection',
      description:
          'Premium silk saree with traditional patterns and modern color combinations.',
      category: 'Women',
      price: 799.0,
      image: 'https://picsum.photos/seed/silk-saree/400/500.jpg',
      images: [
        'https://picsum.photos/seed/silk-saree/400/500.jpg',
        'https://picsum.photos/seed/saree-blue/400/500.jpg',
        'https://picsum.photos/seed/saree-pattern/400/500.jpg',
      ],
      sizes: ['One Size'],
      fabric: 'Silk with stone work',
      color: 'Royal Blue',
      isReadyToShip: true,
      deliveryDays: 6,
      rating: 4.8,
      reviewCount: 156,
    ),
    Product(
      id: '5',
      name: 'Indo-Western Fusion',
      description:
          'Perfect blend of traditional and modern design, suitable for various occasions.',
      category: 'Women',
      price: 1299.0,
      image: 'https://picsum.photos/seed/indowestern-dress/400/500.jpg',
      images: [
        'https://picsum.photos/seed/indowestern-dress/400/500.jpg',
        'https://picsum.photos/seed/indowestern-black/400/500.jpg',
        'https://picsum.photos/seed/indowestern-design/400/500.jpg',
      ],
      sizes: ['M', 'L', 'XL'],
      fabric: 'Net with heavy embroidery',
      color: 'Black',
      isReadyToShip: false,
      deliveryDays: 10,
      rating: 4.6,
      reviewCount: 92,
    ),
    Product(
      id: '6',
      name: 'Kurta Pajama Set',
      description:
          'Comfortable yet stylish kurta pajama set for casual and semi-formal occasions.',
      category: 'Men',
      price: 899.0,
      image: 'https://picsum.photos/seed/kurta-pajama/400/500.jpg',
      images: [
        'https://picsum.photos/seed/kurta-pajama/400/500.jpg',
        'https://picsum.photos/seed/kurta-white/400/500.jpg',
        'https://picsum.photos/seed/kurta-embroidery/400/500.jpg',
      ],
      sizes: ['S', 'M', 'L', 'XL'],
      fabric: 'Blended fabric with minimal embroidery',
      color: 'White',
      isReadyToShip: true,
      deliveryDays: 3,
      rating: 4.4,
      reviewCount: 78,
    ),
  ];

  // Orders
  static List<Order> orders = [
    Order(
      id: '1',
      orderNumber: '#15230',
      orderDate: DateTime(2024, 4, 24),
      items: [
        OrderItem(
          product: products[0], // Anarkali Suit
          size: 'M',
          quantity: 1,
          price: 499.0,
        ),
      ],
      status: OrderStatus.stitching,
      totalAmount: 499.0,
      deliveryAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      tailorName: 'Bhandari Tailors',
      tailorAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      deliveryDate: DateTime(2024, 5, 1),
    ),
    Order(
      id: '2',
      orderNumber: '#14219',
      orderDate: DateTime(2024, 4, 24),
      items: [
        OrderItem(
          product: products[0], // Anarkali Suit
          size: 'M',
          quantity: 1,
          price: 499.0,
        ),
      ],
      status: OrderStatus.delivered,
      totalAmount: 499.0,
      deliveryAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      tailorName: 'Bhandari Tailors',
      tailorAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      deliveryDate: DateTime(2024, 4, 29),
    ),
    Order(
      id: '3',
      orderNumber: '#13207',
      orderDate: DateTime(2024, 2, 9),
      items: [
        OrderItem(
          product: products[1], // Classic Sherwani
          size: 'L',
          quantity: 1,
          price: 999.0,
        ),
      ],
      status: OrderStatus.cancelled,
      totalAmount: 999.0,
      deliveryAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      tailorName: 'Bhandari Tailors',
      tailorAddress:
          'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
    ),
    Order(
      id: '4',
      orderNumber: '#14567',
      orderDate: DateTime(2024, 3, 15),
      items: [
        OrderItem(
          product: products[2], // Kids Ethnic Wear
          size: '4Y',
          quantity: 2,
          price: 699.0,
        ),
      ],
      status: OrderStatus.shipped,
      totalAmount: 1398.0,
      deliveryAddress: '456, Sector 21, Faridabad, Haryana',
      tailorName: 'Kids Fashion Tailors',
      tailorAddress: '456, Sector 21, Faridabad, Haryana',
      deliveryDate: DateTime(2024, 3, 20),
    ),
  ];

  // User Data
  static User currentUser = User(
    name: 'Kim Sharma',
    email: 'kim.sharma@example.com',
    phone: '+91 9876543210',
    avatar: 'https://picsum.photos/seed/kim-sharma/200/200.jpg',
    savedAddresses: [
      'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      '456, Sector 21, Faridabad, Haryana',
    ],
    bodyMeasurements: {
      'chest': '38',
      'waist': '32',
      'hips': '40',
      'shoulder': '16',
    },
  );

  // Tailors
  static List<Tailor> tailors = [
    Tailor(
      id: '1',
      name: 'Bhandari Tailors',
      address: 'Plot 105, Near Old Faridabad Metro Station, Faridabad, Haryana',
      rating: 4.7,
      reviewCount: 234,
      image: 'https://picsum.photos/seed/bhandari-tailor/200/200.jpg',
      isAvailable: true,
    ),
    Tailor(
      id: '2',
      name: 'Rajesh Fashion Studio',
      address: '123, Sector 15, Faridabad, Haryana',
      rating: 4.5,
      reviewCount: 189,
      image: 'https://picsum.photos/seed/rajesh-fashion/200/200.jpg',
      isAvailable: true,
    ),
    Tailor(
      id: '3',
      name: 'Meena Boutique',
      address: '789, Sector 28, Faridabad, Haryana',
      rating: 4.8,
      reviewCount: 312,
      image: 'https://picsum.photos/seed/meena-boutique/200/200.jpg',
      isAvailable: false,
    ),
  ];

  // Helper Methods
  static List<Product> getProductsByCategory(String categoryName) {
    return products
        .where((product) => product.category == categoryName)
        .toList();
  }

  static List<Order> getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  static Product? getProductById(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  static Order? getOrderById(String id) {
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  // Status Helpers
  static String getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.stitching:
        return 'Stitching';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  static Color getOrderStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.stitching:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  // Format Methods
  static String formatPrice(double price) {
    return 'Rs. ${price.toStringAsFixed(0)}';
  }

  static String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
