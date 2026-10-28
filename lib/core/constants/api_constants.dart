class ApiConstants {
  const ApiConstants._();

  static const String baseUrl = 'https://dummyjson.com';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';

  static String productById(int id) => '/products/$id';
  static String productsByCategory(String slug) => '/products/category/$slug';

  /// Number of products requested per page.
  static const int pageSize = 10;

  /// Access token lifetime requested at login / refresh (minutes).
  static const int tokenLifetimeMinutes = 60;
}
