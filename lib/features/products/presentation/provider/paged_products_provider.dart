import 'package:flutter/foundation.dart';

import '../../../../core/error/result.dart';
import '../../../../core/state/safe_change_notifier.dart';
import '../../../../core/utils/min_duration.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_page.dart';

enum ListStatus { loading, success, failure }

/// Pagination shared by the Home list and the category list.
///
/// * the next `skip` is the number of products already loaded
/// * no request is made when everything is loaded or a request is running
/// * if the next page fails, the items stay and the user can retry
/// * the reply of an old request (e.g. an old search) is ignored
abstract class PagedProductsProvider extends SafeChangeNotifier {
  PagedProductsProvider({
    this.minLoadingTime = const Duration(milliseconds: 600),
  });

  /// The shimmer is shown at least this long, even if the reply is instant.
  final Duration minLoadingTime;

  ListStatus _status = ListStatus.loading;
  List<Product> _products = [];
  int _total = 0; // number of products on the server
  bool _isLoadingMore = false;
  bool _loadMoreFailed = false;
  String? _errorMessage;

  /// Grows on every reload, so replies of older requests can be ignored.
  int _requestId = 0;
  bool _loadingFirstPage = false;

  ListStatus get status => _status;
  List<Product> get products => _products;
  bool get isLoadingMore => _isLoadingMore;
  bool get loadMoreFailed => _loadMoreFailed;
  String? get errorMessage => _errorMessage;

  bool get hasReachedMax => _products.length >= _total;
  bool get isEmpty => _status == ListStatus.success && _products.isEmpty;

  /// Fetches the page that starts at [skip].
  @protected
  Future<Result<ProductPage>> fetchPage(int skip);

  /// Loads the first page and shows the shimmer while it loads.
  ///
  /// With [keepItems] (pull-to-refresh) the old items are remembered, so they
  /// come back if the refresh fails. In that case the error message is returned.
  Future<String?> loadFirstPage({bool keepItems = false}) async {
    final requestId = ++_requestId;
    _loadingFirstPage = true;
    _status = ListStatus.loading;
    _isLoadingMore = false;
    _loadMoreFailed = false;
    if (!keepItems) {
      _products = [];
      _total = 0;
    }
    notifyListeners();

    final result = await withMinDuration(fetchPage(0), minLoadingTime);
    if (requestId != _requestId) return null; // a newer request took over
    _loadingFirstPage = false;

    String? refreshError;
    result.when(
      success: (page) {
        _status = ListStatus.success;
        _products = page.products;
        _total = page.total;
        _errorMessage = null;
      },
      failure: (failure) {
        if (keepItems && _products.isNotEmpty) {
          _status = ListStatus.success;
          refreshError = failure.message;
        } else {
          _status = ListStatus.failure;
          _errorMessage = failure.message;
        }
      },
    );
    notifyListeners();
    return refreshError;
  }

  Future<String?> refresh() => loadFirstPage(keepItems: true);

  Future<void> loadMore() async {
    if (_loadingFirstPage ||
        _status != ListStatus.success ||
        _isLoadingMore ||
        hasReachedMax) {
      return;
    }
    final requestId = _requestId;
    _isLoadingMore = true;
    _loadMoreFailed = false;
    notifyListeners();

    final result = await fetchPage(_products.length);
    if (requestId != _requestId) return;

    result.when(
      success: (page) {
        _products = [..._products, ...page.products];
        // An empty page means there is nothing more, whatever `total` says.
        _total = page.products.isEmpty ? _products.length : page.total;
        _errorMessage = null;
      },
      failure: (failure) {
        _loadMoreFailed = true;
        _errorMessage = failure.message;
      },
    );
    _isLoadingMore = false;
    notifyListeners();
  }
}
