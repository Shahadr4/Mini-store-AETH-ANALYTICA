import '../../../../core/utils/debouncer.dart';
import '../../domain/entities/product_sort.dart';
import 'paged_products_provider.dart';

/// A paged product list with a debounced search box and a sort option.
///
/// Home and the category screen share this, so both get the same rules:
/// typing waits 500 ms, changing the search or the sort reloads from page 1
/// and a clear search shows the normal list again right away. Subclasses only
/// say how to fetch a page for the current [query] and [sort].
abstract class SearchableProductsProvider extends PagedProductsProvider {
  SearchableProductsProvider({Debouncer? debouncer, super.minLoadingTime})
    : _debouncer = debouncer ?? Debouncer();

  final Debouncer _debouncer;

  String _query = '';
  ProductSort _sort = ProductSort.none;

  String get query => _query;
  ProductSort get sort => _sort;

  /// Called on every keystroke; the search runs 500 ms after the last one.
  void search(String text) => _debouncer.run(() => _applyQuery(text.trim()));

  /// Clearing the search shows the normal list again right away.
  void clearSearch() {
    _debouncer.cancel();
    _applyQuery('');
  }

  void setSort(ProductSort sort) {
    if (sort == _sort) return;
    _sort = sort;
    loadFirstPage();
  }

  void _applyQuery(String query) {
    if (query == _query) return;
    _query = query;
    loadFirstPage();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    super.dispose();
  }
}
