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

// SubCategory Model
class SubCategory {
  final String id;
  final String categoryId;
  final String name;
  final String image;
  final String categoryName;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.image,
    required this.categoryName,
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
  final String type; // Outfit type for stitching
  final bool isReadyToShip;
  final int deliveryDays;
  final double rating;
  final int reviewCount;
  bool isFavorite;
  final List<Map<String, dynamic>>? rawProductSizes;
  final List<Map<String, dynamic>>? rawProductMeasurements;

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
    required this.type,
    required this.isReadyToShip,
    required this.deliveryDays,
    required this.rating,
    required this.reviewCount,
    this.isFavorite = false,
    this.rawProductSizes,
    this.rawProductMeasurements,
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
  final String? fabric;
  final String? color;
  final String? type;

  OrderItem({
    required this.product,
    required this.size,
    required this.quantity,
    required this.price,
    this.fabric,
    this.color,
    this.type,
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
  String id;
  String name;
  String lastName;
  String dob;
  String email;
  String phone;
  String avatar;
  String gender;
  List<String> savedAddresses;
  Map<String, String> bodyMeasurements;
  List<Map<String, String>> paymentMethods;

  User({
    required this.id,
    required this.name,
    required this.lastName,
    required this.dob,
    required this.email,
    required this.phone,
    required this.avatar,
    this.gender = 'MALE',
    required this.savedAddresses,
    required this.bodyMeasurements,
    required this.paymentMethods,
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
  static List<Category> categories = [];

  // Products
  static List<Product> products = [];

  // Orders
  static List<Order> orders = [
    Order(
      id: '1',
      orderNumber: '#15230',
      orderDate: DateTime(2024, 4, 24),
      items: [
        OrderItem(
          product: Product(
            id: '1',
            name: 'Anarkali Suit',
            description: 'Elegant Anarkali suit with intricate embroidery',
            category: 'Ethnic Wear',
            price: 499.0,
            image: 'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?w=400',
            images: [],
            sizes: ['M', 'L'],
            fabric: 'Georgette',
            color: 'Maroon',
            type: 'Three-Piece Suit',
            isReadyToShip: true,
            deliveryDays: 5,
            rating: 4.5,
            reviewCount: 12,
          ),
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
          product: Product(
            id: '1',
            name: 'Anarkali Suit',
            description: 'Elegant Anarkali suit with intricate embroidery',
            category: 'Ethnic Wear',
            price: 499.0,
            image: 'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?w=400',
            images: [],
            sizes: ['M', 'L'],
            fabric: 'Georgette',
            color: 'Maroon',
            type: 'Three-Piece Suit',
            isReadyToShip: true,
            deliveryDays: 5,
            rating: 4.5,
            reviewCount: 12,
          ),
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
          product: Product(
            id: '2',
            name: 'Classic Sherwani',
            description: 'Traditional sherwani with modern design elements',
            category: 'Ethnic Wear',
            price: 999.0,
            image: 'https://images.unsplash.com/photo-1612336307429-8a898d10e223?w=400',
            images: [],
            sizes: ['S', 'M', 'L'],
            fabric: 'Silk blend',
            color: 'Beige',
            type: 'Sherwani Set',
            isReadyToShip: true,
            deliveryDays: 7,
            rating: 4.7,
            reviewCount: 89,
          ),
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
          product: Product(
            id: '3',
            name: 'Evening Gown',
            description: 'Stunning evening gown for formal parties',
            category: 'Western Wear',
            price: 1299.0,
            image: 'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=400',
            images: [],
            sizes: ['M', 'L'],
            fabric: 'Net',
            color: 'Black',
            type: 'Fusion Outfit',
            isReadyToShip: false,
            deliveryDays: 10,
            rating: 4.6,
            reviewCount: 92,
          ),
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
    id: '1',
    name: 'Kim',
    lastName: 'Sharma',
    dob: '15/05/1995',
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
    paymentMethods: [
      {
        "type": "Visa",
        "number": "**** **** **** 4242",
        "expiry": "12/26",
        "holder": "Kim Sharma"
      },
      {
        "type": "MasterCard",
        "number": "**** **** **** 5555",
        "expiry": "08/25",
        "holder": "Kim Sharma"
      },
    ],
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

  static void resetData() {
    currentUser = User(
      id: '1',
      name: 'Kim',
      lastName: 'Sharma',
      dob: '15/05/1995',
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
      paymentMethods: [
        {
          "type": "Visa",
          "number": "**** **** **** 4242",
          "expiry": "12/26",
          "holder": "Kim Sharma"
        },
        {
          "type": "MasterCard",
          "number": "**** **** **** 5555",
          "expiry": "08/25",
          "holder": "Kim Sharma"
        },
      ],
    );

    orders = [
      Order(
        id: '1',
        orderNumber: '#15230',
        orderDate: DateTime(2024, 4, 24),
        items: [
          OrderItem(
            product: products[0],
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
            product: products[0],
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
            product: products[1],
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
            product: products[2],
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
  }
}
