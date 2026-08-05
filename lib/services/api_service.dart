import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
// import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import '../models/dummy_data.dart';

class ApiService {
  // static final _client = null;

  // ==========================================
  // CATEGORIES
  // ==========================================

  static Future<List<Category>> fetchCategories() async {
    try {
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/categories');
      final token = accessToken;
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] is List) {
          final list = responseData['data'] as List;
          return list.map((item) {
            final name = item['categoryName']?.toString() ?? '';
            final id = item['id']?.toString() ?? '';
            final image = item['categoryImage']?.toString() ?? '';
            return Category(
              id: id,
              name: name,
              icon: image.isNotEmpty ? image : 'assets/images/categories/traditional_icon.png',
              image: image.isNotEmpty ? image : 'assets/images/categories/traditional.png',
              productCount: 0,
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching categories from API: $e');
    }
    return DummyData.categories;
  }

  static Future<List<SubCategory>> fetchSubCategories(String categoryId) async {
    try {
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/sub-categories?categoryId=$categoryId');
      final token = accessToken;
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] is List) {
          final list = responseData['data'] as List;
          return list.map((item) {
            return SubCategory(
              id: item['id']?.toString() ?? '',
              categoryId: item['categoryId']?.toString() ?? categoryId,
              name: item['subCategoryName']?.toString() ?? '',
              image: item['subCategoryImage']?.toString() ?? '',
              categoryName: item['categoryName']?.toString() ?? '',
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching subcategories: $e');
    }
    return [];
  }

  static Future<List<Product>> fetchProductsBySubCategory(String subCategoryId, String categoryName) async {
    try {
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/products/subcategory/$subCategoryId');
      final token = accessToken;
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] is List) {
          final list = responseData['data'] as List;
          return list.map<Product>((item) {
            final priceRaw = item['price'];
            double price = 999.0;
            if (priceRaw != null) {
              price = double.tryParse(priceRaw.toString()) ?? 999.0;
            }
            final name = item['productName']?.toString() ?? 'Formal Outfits';
            final desc = item['productDescription']?.toString() ?? 'Bespoke custom outfit';
            final img = item['productImage']?.toString() ?? 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400';
            
            return Product(
              id: item['id']?.toString() ?? '',
              name: name,
              description: desc,
              category: categoryName,
              price: price,
              image: img,
              images: [img],
              sizes: ['S', 'M', 'L', 'XL'],
              fabric: 'Premium',
              color: 'Custom',
              type: 'Stitch',
              isReadyToShip: false,
              deliveryDays: 7,
              rating: 4.8,
              reviewCount: 12,
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching products by subcategory: $e');
    }
    return [];
  }

  // ==========================================
  // PRODUCTS
  // ==========================================

  static Future<List<Product>> fetchProducts() async {
    try {
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/products');
      final token = accessToken;
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] is List) {
          final list = responseData['data'] as List;
          return list.map<Product>((item) {
            final priceRaw = item['price'];
            double price = 999.0;
            if (priceRaw != null) {
              price = double.tryParse(priceRaw.toString()) ?? 999.0;
            }
            final name = item['productName']?.toString() ?? 'Formal Outfits';
            final desc = item['productDescription']?.toString() ?? 'Bespoke custom outfit';
            final img = item['productImage']?.toString() ?? 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400';
            
            return Product(
              id: item['id']?.toString() ?? '',
              name: name,
              description: desc,
              category: item['categoryName']?.toString() ?? 'Men',
              price: price,
              image: img,
              images: [img],
              sizes: ['S', 'M', 'L', 'XL'],
              fabric: 'Premium',
              color: 'Custom',
              type: 'Stitch',
              isReadyToShip: false,
              deliveryDays: 7,
              rating: 4.8,
              reviewCount: 12,
            );
          }).toList();
        }
      }
    } catch (e) {
      print('Error fetching products from API: $e');
    }
    return [];
  }

  // ==========================================
  // ORDERS
  // ==========================================

  static Future<List<Order>> fetchCustomerOrders(String customerId) async {
    /*
    try {
      final response = await _client
          .from('orders')
          .select('*, customers(address), tailors(name)')
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);

      final list = response as List;
      if (list.isEmpty) return [];

      return list.map((item) {
        final orderNumber = item['order_number']?.toString() ?? '#ORD-0000';
        final rawDate = item['created_at']?.toString() ?? '';
        final orderDate = DateTime.tryParse(rawDate) ?? DateTime.now();

        final customerMap = item['customers'];
        final deliveryAddress = item['delivery_address']?.toString() ??
            (customerMap != null
                ? customerMap['address']?.toString() ?? 'Default Address'
                : 'Default Address');

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
    */
    return DummyData.orders;
  }

  // ==========================================
  // LOCATIONS
  // ==========================================

  static Future<List<String>> fetchLocations() async {
    /*
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
    */
    return DummyData.locations;
  }

  // ==========================================
  // PROFILE PERSISTENCE
  // ==========================================

  static Future<void> updateCustomerProfile(User user) async {
    /*
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
    */
  }

  static Future<String?> uploadAvatar(String localPath, String userId) async {
    /*
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
    */
    return null;
  }

  // ==========================================
  // SESSION PERSISTENCE
  // ==========================================

  static const String _sessionKey = 'logged_in_phone';
  static const String _tokenKey = 'access_token';
  static String? accessToken;

  static Future<void> saveSession(String phone, [String? token]) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sessionKey, phone);
      if (token != null) {
        await prefs.setString(_tokenKey, token);
        accessToken = token;
      }
    } catch (e) {
      print('Error saving login session: $e');
    }
  }

  static Future<String?> getSavedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      accessToken = prefs.getString(_tokenKey);
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
      await prefs.remove(_tokenKey);
      accessToken = null;
      DummyData.resetData();
    } catch (e) {
      print('Error clearing login session: $e');
    }
  }

  static Future<bool> restoreSession(String phone) async {
    DummyData.currentUser.phone = phone;

    final token = accessToken;
    if (token == null) {
      return true;
    }

    try {
      final response = await http.get(
        Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == true && responseData['data'] != null) {
          final customerMap = responseData['data']['customer'];
          if (customerMap != null) {
            final firstName = customerMap['firstName']?.toString() ?? '';
            final lastName = customerMap['lastName']?.toString() ?? '';
            final dob = customerMap['dob']?.toString() ?? '';
            final email = customerMap['email']?.toString() ?? '';
            final gender = customerMap['gender']?.toString() ?? '';
            final avatarUrl = customerMap['profileImage']?.toString() ?? '';
            final id = customerMap['id']?.toString() ?? '';
            
            DummyData.currentUser = User(
              id: id,
              name: firstName,
              lastName: lastName,
              dob: dob,
              email: email,
              phone: phone,
              avatar: avatarUrl.isNotEmpty ? avatarUrl : 'https://picsum.photos/seed/user/200/200.jpg',
              gender: gender,
              savedAddresses: [],
              bodyMeasurements: {},
              paymentMethods: [],
            );
            
            // Fetch addresses
            try {
              final addrResponse = await http.get(
                Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/profile/addresses'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                  'ngrok-skip-browser-warning': 'true',
                },
              );
              if (addrResponse.statusCode == 200) {
                final addrData = jsonDecode(addrResponse.body);
                if (addrData['status'] == true && addrData['data'] is List) {
                  final List list = addrData['data'];
                  final List<String> loadedAddresses = list.map((item) {
                    final line1 = item['addressLine1']?.toString() ?? '';
                    final line2 = item['addressLine2']?.toString() ?? '';
                    final city = item['city']?.toString() ?? '';
                    final state = item['state']?.toString() ?? '';
                    final pincode = item['pincode']?.toString() ?? '';
                    
                    return "$line1${line2.isNotEmpty ? ', ' + line2 : ''}, $city, $state $pincode";
                  }).toList();
                  
                  DummyData.currentUser.savedAddresses = loadedAddresses;
                }
              }
            } catch (e) {
              print('Error pre-fetching addresses during session restore: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error restoring profile from server: $e');
    }
    return true;
  }

  // ==========================================
  // ORDER CREATION
  // ==========================================

  static Future<bool> createOrder({
    required String customerId,
    required double amount,
    required String itemDetails,
    required String deliveryAddress,
  }) async {
    /*
    try {
      final random = DateTime.now().millisecondsSinceEpoch % 100000;
      final orderNumber = '#ORD-$random';

      final payload = {
        'order_number': orderNumber,
        'customer_id': customerId,
        'amount': amount,
        'status': 'pending',
        'item_details': itemDetails,
        'delivery_address': deliveryAddress,
      };

      await _client.from('orders').insert(payload);
      return true;
    } catch (e) {
      print('Error creating order in Supabase: $e');
      return false;
    }
    */
    return true;
  }

  // ==========================================
  // HELPER METHODS
  // ==========================================

  /*
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
  */

  // ==========================================
  // BANNERS (stored in measurement_templates)
  // ==========================================

  static Future<List<String>> fetchBanners() async {
    /*
    try {
      final response = await _client
          .from('measurement_templates')
          .select()
          .eq('name', 'HomeBanners')
          .eq('category', 'Banner')
          .limit(1);

      if (response == null || (response as List).isEmpty) {
        return [
          'https://plus.unsplash.com/premium_photo-1769290472496-62ffdb7003fb?q=80&w=2070&auto=format&fit=crop',
          'https://plus.unsplash.com/premium_photo-1768823132446-915e5707a70d?q=80&w=2073&auto=format&fit=crop',
          'https://plus.unsplash.com/premium_photo-1768823132441-b49d729ae5ca?q=80&w=2070&auto=format&fit=crop',
          'https://plus.unsplash.com/premium_photo-1768823132559-37639ef3f28a?q=80&w=2070&auto=format&fit=crop',
        ];
      }

      final data = response.first as Map<String, dynamic>;
      final params = data['parameters'];
      if (params is List) {
        return List<String>.from(params);
      }
      return [];
    } catch (e) {
      print('Error fetching banners: $e');
      return [
        'https://plus.unsplash.com/premium_photo-1769290472496-62ffdb7003fb?q=80&w=2070&auto=format&fit=crop',
        'https://plus.unsplash.com/premium_photo-1768823132446-915e5707a70d?q=80&w=2073&auto=format&fit=crop',
        'https://plus.unsplash.com/premium_photo-1768823132441-b49d729ae5ca?q=80&w=2070&auto=format&fit=crop',
        'https://plus.unsplash.com/premium_photo-1768823132559-37639ef3f28a?q=80&w=2070&auto=format&fit=crop',
      ];
    }
    */
    return [
      'https://plus.unsplash.com/premium_photo-1769290472496-62ffdb7003fb?q=80&w=2070&auto=format&fit=crop',
      'https://plus.unsplash.com/premium_photo-1768823132446-915e5707a70d?q=80&w=2073&auto=format&fit=crop',
      'https://plus.unsplash.com/premium_photo-1768823132441-b49d729ae5ca?q=80&w=2070&auto=format&fit=crop',
      'https://plus.unsplash.com/premium_photo-1768823132559-37639ef3f28a?q=80&w=2070&auto=format&fit=crop',
    ];
  }
}
