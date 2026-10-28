import '../../../../core/state/safe_change_notifier.dart';
import '../../../../core/utils/min_duration.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_details_usecase.dart';

enum DetailsStatus { loading, success, failure }

class ProductDetailsProvider extends SafeChangeNotifier {
  ProductDetailsProvider(
    this._getProductDetails, {
    this.minLoadingTime = const Duration(milliseconds: 600),
  });

  final GetProductDetailsUseCase _getProductDetails;

  /// The shimmer is shown at least this long, even if the reply is instant.
  final Duration minLoadingTime;

  DetailsStatus _status = DetailsStatus.loading;
  Product? _product;
  String? _errorMessage;

  DetailsStatus get status => _status;
  Product? get product => _product;
  String? get errorMessage => _errorMessage;

  Future<void> load(int id) async {
    _status = DetailsStatus.loading;
    _product = null;
    notifyListeners();

    final result = await withMinDuration(
      _getProductDetails(id),
      minLoadingTime,
    );

    result.when(
      success: (product) {
        _status = DetailsStatus.success;
        _product = product;
      },
      failure: (failure) {
        _status = DetailsStatus.failure;
        _errorMessage = failure.message;
      },
    );
    notifyListeners();
  }
}
