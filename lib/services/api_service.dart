import 'dart:convert';
import 'package:flutter/foundation.dart' hide Category;
import 'package:image_picker/image_picker.dart';

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
            final productPriceRaw = item['productPrice'];
            final stitchingPriceRaw = item['stitchingPrice'];
            final priceRaw = item['price'];
            double price = 0.0;
            if (productPriceRaw != null) {
              price = double.tryParse(productPriceRaw.toString()) ?? 0.0;
            }
            if (price == 0.0 && stitchingPriceRaw != null) {
              price = double.tryParse(stitchingPriceRaw.toString()) ?? 0.0;
            }
            if (price == 0.0 && priceRaw != null) {
              price = double.tryParse(priceRaw.toString()) ?? 0.0;
            }
            if (price == 0.0) {
              price = 999.0;
            }

            final name = item['productName']?.toString() ?? 'Formal Outfits';
            final desc = item['description']?.toString() ?? item['productDescription']?.toString() ?? 'Bespoke custom outfit';
            final img = item['productImage']?.toString() ?? 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400';
            
            final rawSizes = item['productSize'] is List ? List<Map<String, dynamic>>.from(item['productSize']) : null;
            final rawMeasurements = item['productMeasurements'] is List ? List<Map<String, dynamic>>.from(item['productMeasurements']) : null;
            
            final gallery = item['productImageGallery'] as List?;
            final List<String> images = [];
            if (gallery != null) {
              for (var imgObj in gallery) {
                final url = imgObj['imageUrl']?.toString();
                if (url != null && url.isNotEmpty) {
                  images.add(url);
                }
              }
            }
            if (images.isEmpty && img.isNotEmpty) {
              images.add(img);
            }

            final sizesList = <String>[];
            if (rawSizes != null) {
              for (var sizeObj in rawSizes) {
                final code = sizeObj['sizeCode']?.toString();
                if (code != null && code.isNotEmpty) {
                  sizesList.add(code);
                }
              }
            }
            if (sizesList.isEmpty) {
              sizesList.addAll(['S', 'M', 'L', 'XL']);
            }

            final fabric = item['fabricDetails']?.toString() ?? 'Premium';
            final deliveryDays = item['estimatedDeliveryDays'] is int 
                ? item['estimatedDeliveryDays'] as int 
                : (int.tryParse(item['estimatedDeliveryDays']?.toString() ?? '') ?? 7);

            return Product(
              id: item['id']?.toString() ?? '',
              name: name,
              description: desc,
              category: categoryName,
              price: price,
              image: img,
              images: images,
              sizes: sizesList,
              fabric: fabric,
              color: 'Custom',
              type: 'Stitch',
              isReadyToShip: false,
              deliveryDays: deliveryDays,
              rating: 4.8,
              reviewCount: 12,
              rawProductSizes: rawSizes,
              rawProductMeasurements: rawMeasurements,
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
            final productPriceRaw = item['productPrice'];
            final stitchingPriceRaw = item['stitchingPrice'];
            final priceRaw = item['price'];
            double price = 0.0;
            if (productPriceRaw != null) {
              price = double.tryParse(productPriceRaw.toString()) ?? 0.0;
            }
            if (price == 0.0 && stitchingPriceRaw != null) {
              price = double.tryParse(stitchingPriceRaw.toString()) ?? 0.0;
            }
            if (price == 0.0 && priceRaw != null) {
              price = double.tryParse(priceRaw.toString()) ?? 0.0;
            }
            if (price == 0.0) {
              price = 999.0;
            }

            final name = item['productName']?.toString() ?? 'Formal Outfits';
            final desc = item['description']?.toString() ?? item['productDescription']?.toString() ?? 'Bespoke custom outfit';
            final img = item['productImage']?.toString() ?? 'https://images.unsplash.com/photo-1595777457583-95e059d581b8?w=400';
            
            final rawSizes = item['productSize'] is List ? List<Map<String, dynamic>>.from(item['productSize']) : null;
            final rawMeasurements = item['productMeasurements'] is List ? List<Map<String, dynamic>>.from(item['productMeasurements']) : null;
            
            final gallery = item['productImageGallery'] as List?;
            final List<String> images = [];
            if (gallery != null) {
              for (var imgObj in gallery) {
                final url = imgObj['imageUrl']?.toString();
                if (url != null && url.isNotEmpty) {
                  images.add(url);
                }
              }
            }
            if (images.isEmpty && img.isNotEmpty) {
              images.add(img);
            }

            final sizesList = <String>[];
            if (rawSizes != null) {
              for (var sizeObj in rawSizes) {
                final code = sizeObj['sizeCode']?.toString();
                if (code != null && code.isNotEmpty) {
                  sizesList.add(code);
                }
              }
            }
            if (sizesList.isEmpty) {
              sizesList.addAll(['S', 'M', 'L', 'XL']);
            }

            final fabric = item['fabricDetails']?.toString() ?? 'Premium';
            final deliveryDays = item['estimatedDeliveryDays'] is int 
                ? item['estimatedDeliveryDays'] as int 
                : (int.tryParse(item['estimatedDeliveryDays']?.toString() ?? '') ?? 7);

            return Product(
              id: item['id']?.toString() ?? '',
              name: name,
              description: desc,
              category: item['categoryName']?.toString() ?? 'Men',
              price: price,
              image: img,
              images: images,
              sizes: sizesList,
              fabric: fabric,
              color: 'Custom',
              type: 'Stitch',
              isReadyToShip: false,
              deliveryDays: deliveryDays,
              rating: 4.8,
              reviewCount: 12,
              rawProductSizes: rawSizes,
              rawProductMeasurements: rawMeasurements,
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

  // ==========================================
  // ORDER CREATION & SERVICE LOCATIONS
  // ==========================================

  static Future<String?> fetchServiceLocationId(String pincode) async {
    try {
      final token = accessToken;
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/service-locations');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] is List) {
          final list = data['data'] as List;
          // Find service location matching pincode
          for (var item in list) {
            if (item['pincode']?.toString() == pincode) {
              return item['id']?.toString();
            }
          }
          // Fallback to first one if pincode not matched
          if (list.isNotEmpty) {
            return list.first['id']?.toString();
          }
        }
      }
    } catch (e) {
      print('Error fetching service locations: $e');
    }
    // Hardcoded fallback from successful response
    return 'dc2027ef-b5ff-4edf-8fb8-f92c5daab801';
  }

  static Future<Map<String, dynamic>?> createOrder({
    required String customerAddressId,
    required String productId,
    required String sizeId,
    required String measurementSource,
    required String specialInstruction,
    required String measurements,
    required List<XFile?> imageFiles,
    required String serviceLocationId,
  }) async {
    try {
      final token = accessToken;
      final url = Uri.parse('https://gwen-postmycotic-overtrustfully.ngrok-free.dev/api/v1/customer/order');
      
      final request = http.MultipartRequest('POST', url);
      
      // Headers
      request.headers.addAll({
        if (token != null) 'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': 'true',
      });
      
      // Fields
      request.fields['customerAddressId'] = customerAddressId;
      request.fields['productId'] = productId;
      request.fields['sizeId'] = sizeId;
      request.fields['measurementSource'] = measurementSource;
      request.fields['specialInstruction'] = specialInstruction;
      request.fields['measurements'] = measurements;
      request.fields['serviceLocationId'] = serviceLocationId;
      
      // Files
      for (var fileItem in imageFiles) {
        if (fileItem != null) {
          if (kIsWeb) {
            final bytes = await fileItem.readAsBytes();
            final multipartFile = http.MultipartFile.fromBytes(
              'images',
              bytes,
              filename: fileItem.name,
            );
            request.files.add(multipartFile);
          } else {
            final multipartFile = await http.MultipartFile.fromPath(
              'images',
              fileItem.path,
            );
            request.files.add(multipartFile);
          }
        }
      }
      
      print('Sending createOrder request to $url');
      print('Fields: ${request.fields}');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      print('createOrder response code: ${response.statusCode}');
      print('createOrder response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return responseData;
      }
    } catch (e) {
      print('Error calling createOrder API: $e');
    }
    return null;
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
