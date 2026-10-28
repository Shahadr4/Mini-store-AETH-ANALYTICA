import '../../../../core/error/result.dart';
import '../../../../core/state/safe_change_notifier.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_summary.dart';
import '../../domain/usecases/add_to_cart_usecase.dart';
import '../../domain/usecases/change_quantity_usecase.dart';
import '../../domain/usecases/get_cart_items_usecase.dart';
import '../../domain/usecases/place_order_usecase.dart';
import '../../domain/usecases/remove_from_cart_usecase.dart';

/// The cart. The badge, the product screens and the cart tab all use it.
class CartProvider extends SafeChangeNotifier {
  CartProvider({
    required GetCartItemsUseCase getCartItems,
    required AddToCartUseCase addToCart,
    required ChangeQuantityUseCase changeQuantity,
    required RemoveFromCartUseCase removeFromCart,
    required PlaceOrderUseCase placeOrder,
  }) : _getCartItems = getCartItems,
       _addToCart = addToCart,
       _changeQuantity = changeQuantity,
       _removeFromCart = removeFromCart,
       _placeOrder = placeOrder;

  final GetCartItemsUseCase _getCartItems;
  final AddToCartUseCase _addToCart;
  final ChangeQuantityUseCase _changeQuantity;
  final RemoveFromCartUseCase _removeFromCart;
  final PlaceOrderUseCase _placeOrder;

  bool _isLoading = true;
  List<CartItem> _items = [];
  bool _isPlacingOrder = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<CartItem> get items => _items;
  bool get isPlacingOrder => _isPlacingOrder;

  /// Shown once as a snackbar, e.g. when saving the cart failed.
  String? get errorMessage => _errorMessage;

  bool get isEmpty => _items.isEmpty;

  /// Number of units in the cart (shown on the badge).
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.total);

  int quantityOf(int productId) {
    for (final item in _items) {
      if (item.productId == productId) return item.quantity;
    }
    return 0;
  }

  Future<void> load() async => _apply(await _getCartItems());

  Future<void> add(Product product) async => _apply(await _addToCart(product));

  Future<void> increment(int productId) async =>
      _apply(await _changeQuantity(productId, 1));

  /// Decreasing from 1 removes the item.
  Future<void> decrement(int productId) async =>
      _apply(await _changeQuantity(productId, -1));

  Future<void> remove(int productId) async =>
      _apply(await _removeFromCart(productId));

  /// Called after the error message was shown.
  void clearError() => _errorMessage = null;

  /// Places the dummy order. Returns the summary, or null if it failed.
  Future<OrderSummary?> placeOrder() async {
    if (_isPlacingOrder || isEmpty) return null;
    _isPlacingOrder = true;
    notifyListeners();

    final result = await _placeOrder();

    OrderSummary? summary;
    result.when(
      success: (orderSummary) {
        summary = orderSummary;
        _items = [];
      },
      failure: (failure) => _errorMessage = failure.message,
    );
    _isPlacingOrder = false;
    notifyListeners();
    return summary;
  }

  void _apply(Result<List<CartItem>> result) {
    result.when(
      success: (items) => _items = items,
      failure: (failure) => _errorMessage = failure.message,
    );
    _isLoading = false;
    notifyListeners();
  }
}
