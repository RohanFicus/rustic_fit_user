import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/dummy_data.dart';

class SupabaseService {
  static final _client = Supabase.instance.client;

  // ==========================================
  // CATEGORIES
  // ==========================================

  static Future<List<Category>> fetchCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);

      final list = response as List;
      if (list.isEmpty) return [];

      return list.map((item) {
        final name = item['name']?.toString() ?? '';
        return Category(
          id: item['id'].toString(),
          name: name,
          icon: _getIconPathForName(name),
          image: _getImagePathForCategory(name),
          productCount: 0, // Not explicitly used for UI filtering
        );
      }).toList();
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  // ==========================================
  // PRODUCTS
  // ==========================================

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .from('products')
          .select('*, categories(name)')
          .order('name', ascending: true);

      final list = response as List;
      if (list.isEmpty) return [];

      return list.map((item) {
        final name = item['name']?.toString() ?? '';
        final categoryMap = item['categories'];
        final categoryName = categoryMap != null
            ? categoryMap['name']?.toString() ?? 'Ethnic Wear'
            : 'Ethnic Wear';

        final sizesRaw = item['sizes'];
        final List<String> sizes =
            sizesRaw != null ? List<String>.from(sizesRaw) : ['M', 'L', 'XL'];

        // Image selection logic: check if DB has an image_url
        String image = item['image_url']?.toString() ?? '';
        List<String> images = [image];

        if (image.isEmpty) {
          // Fallback image logic if DB is empty
          image = 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400';
          images = [image];

          // Match with local high-quality dummy assets if matching by name
          try {
            final matchedDummy = DummyData.products
                .firstWhere((p) => p.name.toLowerCase() == name.toLowerCase());
            image = matchedDummy.image;
            images = matchedDummy.images;
          } catch (_) {
            // If no name match, fallback based on category name keywords
            final categoryLower = categoryName.toLowerCase();
            if (categoryLower.contains('western')) {
              image =
                  'https://images.unsplash.com/photo-1566174053879-31528523f8ae?w=400';
              images = [image];
            } else if (categoryLower.contains('indo') ||
                categoryLower.contains('fusion')) {
              image =
                  'https://images.unsplash.com/photo-1612336307429-8a898d10e223?q=80&w=987&auto=format';
              images = [image];
            } else {
              image =
                  'https://images.unsplash.com/photo-1532453288672-3a27e9be9efd?q=80&w=1364';
              images = [image];
            }
          }
        }

        return Product(
          id: item['id'].toString(),
          name: name,
          description: item['description'] ?? '',
          category: categoryName,
          price: (item['price'] as num?)?.toDouble() ?? 0.0,
          image: image,
          images: images,
          sizes: sizes,
          fabric: item['fabric'] ?? 'Cotton Blend',
          color: item['color'] ?? 'Default Color',
          type: item['type'] ?? 'Default Type',
          isReadyToShip: item['is_enabled'] ?? true,
          deliveryDays: 5,
          rating: 4.5,
          reviewCount: 42,
        );
      }).toList();
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }

  // ==========================================
  // ORDERS
  // ==========================================

  static Future<List<Order>> fetchCustomerOrders(String customerId) async {
    try {
      final response = await _client
          .from('orders')
          .select('*, customers(address), tailors(name, address)')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      final list = response as List;
      if (list.isEmpty) return [];

      return list.map((item) {
        final orderNumber = item['order_number']?.toString() ?? '#ORD-0000';
        final rawDate = item['created_at']?.toString() ?? '';
        final orderDate = DateTime.tryParse(rawDate) ?? DateTime.now();

        final customerMap = item['customers'];
        final deliveryAddress = customerMap != null
            ? customerMap['address']?.toString() ?? 'Default Address'
            : 'Default Address';

        final tailorMap = item['tailors'];
        final tailorName = tailorMap != null
            ? tailorMap['name']?.toString() ?? 'Bhandari Tailors'
            : 'Bhandari Tailors';
        final tailorAddress = tailorMap != null
            ? tailorMap['address']?.toString() ?? 'Plot 105, Faridabad'
            : 'Plot 105, Faridabad';

        final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
        final statusStr = item['status']?.toString().toLowerCase() ?? 'pending';

        // Parse items from item_details
        final itemDetails = item['item_details']?.toString() ?? '';
        final orderItems = _parseOrderItems(itemDetails, amount);

        return Order(
          id: item['id'].toString(),
          orderNumber: orderNumber,
          orderDate: orderDate,
          items: orderItems,
          status: _parseOrderStatus(statusStr),
          totalAmount: amount,
          deliveryAddress: deliveryAddress,
          tailorName: tailorName,
          tailorAddress: tailorAddress,
          deliveryDate: orderDate.add(const Duration(days: 14)),
        );
      }).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return [];
    }
  }

  // ==========================================
  // LOCATIONS
  // ==========================================

  static Future<List<String>> fetchLocations() async {
    try {
      final response = await _client
          .from('locations')
          .select()
          .order('city', ascending: true);

      final list = response as List;
      if (list.isEmpty) return [];

      return list.map((item) {
        final city = item['city']?.toString() ?? '';
        final state = item['state']?.toString() ?? '';
        if (city.isNotEmpty && state.isNotEmpty) {
          return '$city, $state';
        }
        return city.isNotEmpty ? city : state;
      }).toList();
    } catch (e) {
      print('Error fetching locations: $e');
      return [];
    }
  }

  // ==========================================
  // PROFILE PERSISTENCE
  // ==========================================

  static Future<void> updateCustomerProfile(User user) async {
    try {
      final payload = {
        'name': user.name,
        'last_name': user.lastName,
        'dob': user.dob,
        'email': user.email,
        'phone': user.phone,
        'avatar_url': user.avatar,
        'address':
            user.savedAddresses.isNotEmpty ? user.savedAddresses.first : '',
        'body_measurements': user.bodyMeasurements,
        'saved_addresses': user.savedAddresses,
        'payment_methods': user.paymentMethods,
      };

      await _client.from('customers').update(payload).eq('id', user.id);
    } catch (e) {
      print('Error updating customer profile in Supabase: $e');
      rethrow;
    }
  }

  static Future<String?> uploadAvatar(String localPath, String userId) async {
    try {
      final file = File(localPath);
      final bytes = await file.readAsBytes();
      final fileExt = localPath.split('.').last.toLowerCase();
      final path = '$userId/avatar.$fileExt';

      await _client.storage.from('avatars').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$fileExt',
              upsert: true,
            ),
          );

      final publicUrl = _client.storage.from('avatars').getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      print('Error uploading avatar to Supabase: $e');
      return null;
    }
  }

  // ==========================================
  // SESSION PERSISTENCE
  // ==========================================

  static const String _sessionKey = 'logged_in_phone';

  static Future<void> saveSession(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, phone);
    } catch (e) {
      print('Error saving login session: $e');
    }
  }

  static Future<String?> getSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_sessionKey);
    } catch (e) {
      print('Error getting saved login session: $e');
      return null;
    }
  }

  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
    } catch (e) {
      print('Error clearing login session: $e');
    }
  }

  static Future<bool> restoreSession(String phone) async {
    try {
      final response = await _client
          .from('customers')
          .select()
          .or('phone.eq.$phone,phone.eq.${phone.replaceAll(' ', '')}')
          .limit(1);

      if (response == null || (response as List).isEmpty) {
        return false;
      }

      final customerData = response.first as Map<String, dynamic>;

      DummyData.currentUser = User(
        id: customerData['id']?.toString() ?? '1',
        name: customerData['name'] ?? 'Unknown Name',
        lastName: customerData['last_name'] ?? '',
        dob: customerData['dob'] ?? '15/05/1995',
        email: customerData['email'] ?? 'unknown@example.com',
        phone: customerData['phone'] ?? phone,
        avatar: customerData['avatar_url'] ??
            'https://picsum.photos/seed/${customerData['name']}/200/200.jpg',
        savedAddresses: customerData['saved_addresses'] != null
            ? List<String>.from(customerData['saved_addresses'] as List)
            : (customerData['address'] != null &&
                    customerData['address'].toString().trim().isNotEmpty
                ? [customerData['address'].toString()]
                : []),
        bodyMeasurements: customerData['body_measurements'] != null
            ? Map<String, String>.from(customerData['body_measurements'] as Map)
            : {
                'chest': '38',
                'waist': '32',
                'hips': '40',
                'shoulder': '16',
              },
        paymentMethods: customerData['payment_methods'] != null
            ? (customerData['payment_methods'] as List)
                .map((item) => Map<String, String>.from(item as Map))
                .toList()
            : [
                {
                  "type": "Visa",
                  "number": "**** **** **** 4242",
                  "expiry": "12/26",
                  "holder": customerData['name'] ?? 'Kim Sharma'
                },
                {
                  "type": "MasterCard",
                  "number": "**** **** **** 5555",
                  "expiry": "08/25",
                  "holder": customerData['name'] ?? 'Kim Sharma'
                },
              ],
      );

      try {
        final dbOrders = await fetchCustomerOrders(DummyData.currentUser.id);
        if (dbOrders.isNotEmpty) {
          DummyData.orders = dbOrders;
        }
      } catch (e) {
        print('Failed to fetch user orders during restore: $e');
      }

      return true;
    } catch (e) {
      print('Error restoring user session: $e');
      return false;
    }
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  static String _getIconPathForName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('traditional') || lower.contains('ethnic')) {
      return 'assets/images/categories/traditional_icon.png';
    }
    if (lower.contains('western')) {
      return 'assets/images/categories/western_icon.png';
    }
    if (lower.contains('indo') || lower.contains('fusion')) {
      return 'assets/images/categories/indo_western_icon.png';
    }
    return 'assets/images/categories/traditional_icon.png';
  }

  static String _getImagePathForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('traditional') || lower.contains('ethnic')) {
      return 'assets/images/categories/traditional.png';
    }
    if (lower.contains('western')) {
      return 'assets/images/categories/western.png';
    }
    if (lower.contains('indo') || lower.contains('fusion')) {
      return 'assets/images/categories/indo_western.png';
    }
    return 'assets/images/categories/traditional.png';
  }

  static OrderStatus _parseOrderStatus(String statusStr) {
    switch (statusStr) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'stitching':
        return OrderStatus.stitching;
      case 'ready':
        return OrderStatus.ready;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  static List<OrderItem> _parseOrderItems(String itemDetails, double amount) {
    if (itemDetails.isEmpty) return [];

    // Format is usually "Product Name - Size"
    final parts = itemDetails.split(' - ');
    final productName = parts.first;
    final size = parts.length > 1 ? parts[1] : 'M';

    // Find the product in loaded products list or return a fallback
    Product product;
    try {
      product = DummyData.products
          .firstWhere((p) => p.name.toLowerCase() == productName.toLowerCase());
    } catch (_) {
      product = Product(
        id: 'temp',
        name: productName,
        description: 'Bespoke item',
        category: 'Custom Outfit',
        price: amount,
        image:
            'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400',
        images: [
          'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400'
        ],
        sizes: [size],
        fabric: 'Bespoke Fabric',
        color: 'Bespoke Color',
        type: 'Stitched Outfit',
        isReadyToShip: false,
        deliveryDays: 14,
        rating: 5.0,
        reviewCount: 1,
      );
    }

    return [
      OrderItem(
        product: product,
        size: size,
        quantity: 1,
        price: amount,
      )
    ];
  }
}
