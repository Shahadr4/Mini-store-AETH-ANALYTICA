class AppRoutes {
  const AppRoutes._();

  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const categories = '/categories';
  static const cart = '/cart';
  static const account = '/account';
  static const orderSuccess = '/order-success';

  static const productDetailsPattern = '/product/:id';
  static const categoryProductsPattern = '/categories/:slug';

  static String productDetails(int id) => '/product/$id';
  static String categoryProducts(String slug) => '/categories/$slug';
}
