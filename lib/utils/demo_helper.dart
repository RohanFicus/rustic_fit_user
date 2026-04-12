import '../models/dummy_data.dart';
import '../services/data_service.dart';

class DemoHelper {
  static final DataService _dataService = DataService();

  // Quick access methods for demo purposes
  static List<Category> get categories => _dataService.getCategories();
  static List<Product> get products => _dataService.getProducts();
  static List<Order> get orders => _dataService.getOrders();
  static User get currentUser => _dataService.getCurrentUser();
  static List<Tailor> get tailors => _dataService.getTailors();

  // Demo scenarios
  static void runDemoScenario1() {
    print('=== Demo Scenario 1: Browse Products ===');
    
    // Show all categories
    print('Available Categories:');
    for (var category in categories) {
      print('  - ${category.name} (${category.productCount} products)');
    }
    
    // Show products in Women category
    final womenProducts = _dataService.getProductsByCategory('Women');
    print('\nWomen Products:');
    for (var product in womenProducts) {
      print('  - ${product.name}: ${DummyData.formatPrice(product.price)}');
    }
  }

  static void runDemoScenario2() {
    print('=== Demo Scenario 2: Order Management ===');
    
    // Show active orders
    final activeOrders = _dataService.getActiveOrders();
    print('Active Orders (${activeOrders.length}):');
    for (var order in activeOrders) {
      print('  - ${order.orderNumber}: ${DummyData.getOrderStatusText(order.status)}');
    }
    
    // Simulate order progress
    print('\nSimulating order progress...');
    _dataService.simulateOrderProgress();
    
    final updatedOrder = activeOrders.first;
    print('Order ${updatedOrder.orderNumber} status: ${DummyData.getOrderStatusText(updatedOrder.status)}');
  }

  static void runDemoScenario3() {
    print('=== Demo Scenario 3: User Profile ===');
    
    final user = currentUser;
    print('User Profile:');
    print('  - Name: ${user.name}');
    print('  - Email: ${user.email}');
    print('  - Phone: ${user.phone}');
    print('  - Saved Addresses (${user.savedAddresses.length}):');
    for (var address in user.savedAddresses) {
      print('    * ${address}');
    }
    print('  - Body Measurements:');
    user.bodyMeasurements.forEach((key, value) {
      print('    * ${key}: ${value}');
    });
  }

  static void runDemoScenario4() {
    print('=== Demo Scenario 4: Search & Filter ===');
    
    // Search products
    final searchResults = _dataService.searchProducts('anarkali');
    print('Search Results for "anarkali":');
    for (var product in searchResults) {
      print('  - ${product.name}: ${DummyData.formatPrice(product.price)}');
    }
    
    // Advanced search
    final filteredProducts = _dataService.advancedSearch(
      query: 'suit',
      category: 'Women',
      minPrice: 400,
      maxPrice: 800,
      readyToShip: true,
    );
    print('\nFiltered Products (Women, 400-800, Ready to Ship):');
    for (var product in filteredProducts) {
      print('  - ${product.name}: ${DummyData.formatPrice(product.price)}');
    }
  }

  static void runDemoScenario5() {
    print('=== Demo Scenario 5: Create New Order ===');
    
    // Create a new order
    final product = _dataService.getProductById('1')!;
    final orderItems = [
      OrderItem(
        product: product,
        size: 'M',
        quantity: 1,
        price: product.price,
      ),
    ];
    
    final newOrder = _dataService.createOrder(
      orderItems,
      '123, New Address, Faridabad, Haryana',
    );
    
    print('New Order Created:');
    print('  - Order Number: ${newOrder.orderNumber}');
    print('  - Status: ${DummyData.getOrderStatusText(newOrder.status)}');
    print('  - Total: ${DummyData.formatPrice(newOrder.totalAmount)}');
    print('  - Items: ${newOrder.items.length}');
  }

  static void runDemoScenario6() {
    print('=== Demo Scenario 6: Statistics ===');
    
    final stats = _dataService.getOrderStats();
    print('Order Statistics:');
    stats.forEach((key, value) {
      print('  - ${key}: ${value}');
    });
    
    final categoryStats = _dataService.getCategoryStats();
    print('\nCategory Statistics:');
    categoryStats.forEach((key, value) {
      print('  - ${key}: ${value} products');
    });
  }

  static void runDemoScenario7() {
    print('=== Demo Scenario 7: Favorites ===');
    
    // Toggle favorites
    _dataService.toggleFavorite('1');
    _dataService.toggleFavorite('3');
    
    final favoriteProducts = _dataService.getFavoriteProducts();
    print('Favorite Products:');
    for (var product in favoriteProducts) {
      print('  - ${product.name}: ${DummyData.formatPrice(product.price)}');
    }
  }

  static void runDemoScenario8() {
    print('=== Demo Scenario 8: Recent Activity ===');
    
    final activities = _dataService.getRecentActivity();
    print('Recent Activity:');
    for (var activity in activities) {
      print('  - ${activity['title']}: ${activity['description']}');
    }
  }

  static void runAllDemoScenarios() {
    print('Running All Demo Scenarios...\n');
    
    runDemoScenario1();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario2();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario3();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario4();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario5();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario6();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario7();
    print('\n' + '='*50 + '\n');
    
    runDemoScenario8();
    print('\n' + '='*50 + '\n');
    
    print('All Demo Scenarios Completed!');
  }

  // Quick data access for UI components
  static Map<String, dynamic> getHomeScreenData() {
    return {
      'featuredProducts': products.take(4).toList(),
      'categories': categories.take(3).toList(),
      'recentOrders': orders.take(2).toList(),
      'user': currentUser,
    };
  }

  static Map<String, dynamic> getOrdersScreenData() {
    return {
      'activeOrders': _dataService.getActiveOrders(),
      'completedOrders': _dataService.getCompletedOrders(),
      'cancelledOrders': _dataService.getCancelledOrders(),
    };
  }

  static Map<String, dynamic> getProfileScreenData() {
    return {
      'user': currentUser,
      'orderStats': _dataService.getOrderStats(),
      'recentActivity': _dataService.getRecentActivity(),
    };
  }

  // Sample data for testing specific features
  static Product getSampleProduct() => products.first;
  static Order getSampleOrder() => orders.first;
  static Category getSampleCategory() => categories.first;
  static Tailor getSampleTailor() => tailors.first;

  // Data validation
  static bool validateProductData() {
    print('Validating Product Data...');
    bool isValid = true;
    
    for (var product in products) {
      if (product.name.isEmpty || product.price <= 0) {
        print('  - Invalid product: ${product.name}');
        isValid = false;
      }
    }
    
    print(isValid ? '  - All products are valid!' : '  - Some products are invalid!');
    return isValid;
  }

  static bool validateOrderData() {
    print('Validating Order Data...');
    bool isValid = true;
    
    for (var order in orders) {
      if (order.orderNumber.isEmpty || order.items.isEmpty) {
        print('  - Invalid order: ${order.orderNumber}');
        isValid = false;
      }
    }
    
    print(isValid ? '  - All orders are valid!' : '  - Some orders are invalid!');
    return isValid;
  }

  static void validateAllData() {
    final productValid = validateProductData();
    final orderValid = validateOrderData();
    
    if (productValid && orderValid) {
      print('All data validation passed!');
    } else {
      print('Data validation failed!');
    }
  }
}
